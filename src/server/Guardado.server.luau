--[[
	💾 GUARDADO
	Guarda en los servidores de Roblox lo que ganas, para que la próxima vez que juegues
	lo sigas teniendo:
	  - 🪙 Monedas
	  - 🏆 Victorias
	  - 🛒 Las mejoras de la tienda (salto, correr, brillo) y los 🎁 cofres que has abierto
	  - 🎨 Los colores y estelas que has comprado (y el que llevas puesto), tus 🐾 mascotas y su nivel
	  - 🏅 Tus logros y los contadores para conseguirlos · 🏠 Los muebles de tu casita
	  - 📅 El progreso de tus misiones del día
	  - 🗼 El nivel en el que vas
	  - ⏱️ Tu mejor tiempo (récord)

	Se guarda solo: cada minuto, cuando sales del juego y cuando se cierra el juego.

	⚠️ IMPORTANTE: para que funcione en Roblox Studio hay que
	   1) Publicar el mundo (Archivo → Publicar en Roblox) y
	   2) Activar "Habilitar acceso de Studio a servicios de API"
	      (Inicio → Configuración del juego → Seguridad).
	   Si no, verás un aviso en Vista → Salida y el juego funcionará, pero SIN guardar.

	📋 DÓNDE VA: en Roblox Studio, dentro de ServerScriptService, como "Script".
	(Habla con los otros scripts a través de "atributos" del jugador, así que no
	necesita nada más. Usa el marcador que crea el script MiMundo.)
]]

local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")

-- ⚙️ AJUSTES
local AJUSTES = {
	-- Nombre del "cajón" donde se guarda. Si lo cambias, ¡todos empiezan de cero!
	nombreDelGuardado = "MiMundoDatos_v1",
	segundosEntreGuardados = 60,
	intentos = 3, -- cuántas veces lo intenta si Roblox falla
}

-- Los atributos del jugador que empiezan así se guardan (los ponen la tienda y los cofres)
local PREFIJOS = { "Compra_", "Cofre_", "Mejora_", "Estilo_", "Equipo_", "Mision_", "Logro_", "Casa_", "Mascota_", "Estad_", "Venta_", "Foto_", "Premio_", "Reto_" }

-- Qué valores se pueden guardar: sí/no, números y textos cortitos (el color o la estela que llevas)
local function valorValido(valor)
	return valor == true or type(valor) == "number" or (type(valor) == "string" and #valor <= 40)
end

local function esParaGuardar(nombre)
	for _, prefijo in PREFIJOS do
		if string.sub(nombre, 1, #prefijo) == prefijo then
			return true
		end
	end
	return false
end

local almacen = DataStoreService:GetDataStore(AJUSTES.nombreDelGuardado)

local cargado = {} -- cargado[jugador] = true cuando hemos leído sus datos bien
local ocupado = {} -- ocupado[jugador] = true mientras se está guardando

local function clave(jugador)
	return "Jugador_" .. jugador.UserId
end

----------------------------------------------------------------------
-- 📥 CARGAR
----------------------------------------------------------------------

-- Devuelve: funcionó (true/false), datos guardados (o nil si es la primera vez)
local function leerDatos(jugador)
	for intento = 1, AJUSTES.intentos do
		local funciono, resultado = pcall(function()
			return almacen:GetAsync(clave(jugador))
		end)
		if funciono then
			return true, resultado
		end
		warn("💾 No pude leer los datos de " .. jugador.Name .. " (intento " .. intento .. "): " .. tostring(resultado))
		task.wait(2)
	end
	warn(
		"💾 ⚠️ NO SE GUARDARÁ NADA en esta partida. ¿Has publicado el mundo y activado "
			.. "'Habilitar acceso de Studio a servicios de API' en Configuración del juego → Seguridad?"
	)
	return false, nil
end

local function cargarJugador(jugador)
	local marcador = jugador:WaitForChild("leaderstats", 30)
	if not marcador then
		return
	end

	local funciono, datos = leerDatos(jugador)
	if not funciono or not jugador.Parent then
		return -- sin datos leídos NO guardamos, para no borrar lo que ya tenía
	end

	if datos then
		local monedas = marcador:FindFirstChild("Monedas")
		local victorias = marcador:FindFirstChild("Victorias")
		if monedas then
			monedas.Value += datos.monedas or 0
		end
		if victorias then
			victorias.Value += datos.victorias or 0
		end
		for id in datos.compras or {} do
			jugador:SetAttribute("Compra_" .. id, true) -- (guardados antiguos)
		end
		for nombre, valor in datos.extras or {} do
			if esParaGuardar(nombre) and valorValido(valor) then
				jugador:SetAttribute(nombre, valor) -- la tienda, los cofres y el estilo lo ven y se lo ponen
			end
		end
		if type(datos.nivel) == "number" and datos.nivel > (jugador:GetAttribute("Nivel") or 1) then
			jugador:SetAttribute("Nivel", datos.nivel) -- el script Niveles te lleva a tu checkpoint
		end
		if type(datos.mejorTiempo) == "number" and datos.mejorTiempo > 0 then
			jugador:SetAttribute("MejorTiempo", datos.mejorTiempo)
		end
		print("💾 ¡Datos de " .. jugador.Name .. " cargados!")
	else
		print("💾 " .. jugador.Name .. " juega por primera vez: empezamos de cero.")
	end

	cargado[jugador] = true
	jugador:SetAttribute("DatosCargados", true) -- otros scripts (como Misiones) esperan a esto
end

----------------------------------------------------------------------
-- 📤 GUARDAR
----------------------------------------------------------------------

local function recogerDatos(jugador)
	local marcador = jugador:FindFirstChild("leaderstats")
	local monedas = marcador and marcador:FindFirstChild("Monedas")
	local victorias = marcador and marcador:FindFirstChild("Victorias")

	local extras = {}
	for nombre, valor in jugador:GetAttributes() do
		if esParaGuardar(nombre) and valorValido(valor) then
			extras[nombre] = valor
		end
	end

	return {
		monedas = monedas and monedas.Value or 0,
		victorias = victorias and victorias.Value or 0,
		nivel = jugador:GetAttribute("Nivel") or 1,
		mejorTiempo = jugador:GetAttribute("MejorTiempo") or 0,
		extras = extras,
	}
end

local function guardar(jugador)
	if not cargado[jugador] then
		return
	end
	-- Si ya se está guardando, esperamos a que termine
	if ocupado[jugador] then
		while ocupado[jugador] do
			task.wait(0.2)
		end
		return
	end

	ocupado[jugador] = true
	local datos = recogerDatos(jugador)
	for intento = 1, AJUSTES.intentos do
		local funciono, error = pcall(function()
			almacen:SetAsync(clave(jugador), datos)
		end)
		if funciono then
			break
		end
		warn("💾 No pude guardar a " .. jugador.Name .. " (intento " .. intento .. "): " .. tostring(error))
		task.wait(2)
	end
	ocupado[jugador] = nil
end

----------------------------------------------------------------------
-- 🔌 CUÁNDO SE GUARDA
----------------------------------------------------------------------

Players.PlayerAdded:Connect(cargarJugador)
for _, jugador in Players:GetPlayers() do
	task.spawn(cargarJugador, jugador)
end

Players.PlayerRemoving:Connect(function(jugador)
	guardar(jugador)
	cargado[jugador] = nil
end)

-- Cuando se cierra el juego, guardamos a todos y esperamos a que acaben
game:BindToClose(function()
	local pendientes = 0
	for _, jugador in Players:GetPlayers() do
		pendientes += 1
		task.spawn(function()
			guardar(jugador)
			pendientes -= 1
		end)
	end
	while pendientes > 0 do
		task.wait(0.2)
	end
end)

-- Guardado automático cada cierto tiempo
task.spawn(function()
	while true do
		task.wait(AJUSTES.segundosEntreGuardados)
		for _, jugador in Players:GetPlayers() do
			task.spawn(guardar, jugador)
		end
	end
end)

print("💾 Guardado listo.")
