--[[
	🏆 EL RETO DE LA SEMANA (temporadas)
	Cada semana hay un RETO NUEVO para todos, por ejemplo:
	  - 💪 Llega 80 niveles más arriba SIN MORIR
	  - 🪙 Recoge 400 monedas · 🎯 Lanza 20 dardos · 🍳 Cocina 6 platos · 📸 Haz 3 fotos
	  - 🏠 Recibe 3 visitas · 🛋️ Compra 4 muebles · 🏁 Corre 2 carreras · 🗼 Sube 40 niveles
	Al cumplirlo ganas MONEDAS y un PREMIO ESPECIAL PARA TU CASA: una decoración que sale en el jardín
	(⛲ fuente, 🗽 estatua, 🏮 farolillos, 🚀 cohete, 🦩 flamenco o 🌈 arcoíris).
	Cada 4 semanas empieza una TEMPORADA nueva. Los premios se guardan (con el script Guardado).
	El reto cambia los jueves a las 00:00 (hora UTC). Se ve en el botón "🏆 Reto semanal".

	📋 DÓNDE VA: en Roblox Studio, dentro de ServerScriptService, como "Script".
	(Otros scripts le cuentan lo que pasa sumando 1 a contadores "Estad_..." del jugador. Usa la marca
	"CasaOrigen" del script Casas para poner los premios en el jardín. Habla con la pantalla con un
	RemoteEvent, una carpeta en ReplicatedStorage y atributos del mundo.)
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local TweenService = game:GetService("TweenService")

-- ⚙️ AJUSTES: ¡cambia estos valores y mira qué pasa!
local AJUSTES = {
	monedasSiYaTienesElPremio = 100, -- si el premio de la semana ya lo tenías, te damos monedas
	segundosEntreRevisiones = 30,
	semanasPorTemporada = 4,
}

local SEMANA = 604800 -- los segundos que tiene una semana

-- 🧺 LOS RETOS (uno por semana, van rotando)
-- "tipo" dice qué hay que hacer; "objetivo" cuánto (en el de "sinMorir" es cuántos niveles hay que subir).
local RETOS = {
	{ tipo = "sinMorir", objetivo = 80, monedas = 300 },
	{ tipo = "monedas", objetivo = 400, monedas = 150 },
	{ tipo = "carreras", objetivo = 2, monedas = 150 },
	{ tipo = "visitas", objetivo = 3, monedas = 150 },
	{ tipo = "muebles", objetivo = 4, monedas = 150 },
	{ tipo = "dardos", objetivo = 20, monedas = 120 },
	{ tipo = "comidas", objetivo = 6, monedas = 120 },
	{ tipo = "fotos", objetivo = 3, monedas = 120 },
	{ tipo = "sinMorir", objetivo = 30, monedas = 200 },
	{ tipo = "nivel", objetivo = 40, monedas = 200 },
}

-- Qué contador "Estad_" sirve para cada tipo de reto
local CONTADORES = {
	Estad_monedas = "monedas",
	Estad_carreras = "carreras",
	Estad_visitas = "visitas",
	Estad_muebles = "muebles",
	Estad_dardos = "dardos",
	Estad_comidas = "comidas",
	Estad_fotos = "fotos",
}

-- Dónde sale cada premio en el jardín (x, z; el primero en el primer sitio...). Son los mismos sitios
-- que deja libres el script Casas (SITIOS_DE_PREMIOS).
local SITIOS = { { -7.5, -13.5 }, { -7.5, -16 }, { 7.5, -13.5 }, { 7.5, -17 }, { 7.5, -20.5 }, { 4.5, -22.5 } }

local ultimoValor = {}
local entrada = {}
local redibujoPendiente = {}

----------------------------------------------------------------------
-- 🧰 HERRAMIENTAS PARA DIBUJAR LOS PREMIOS
----------------------------------------------------------------------

local function parte(carpeta, nombre, tamano, base, x, y, z, color, material, forma)
	local pieza = Instance.new("Part")
	pieza.Name = nombre
	pieza.Size = tamano
	pieza.CFrame = base * CFrame.new(x, y, z)
	pieza.Color = color
	pieza.Material = material or Enum.Material.SmoothPlastic
	pieza.Shape = forma or Enum.PartType.Block
	pieza.Anchored = true
	pieza.CanCollide = false
	pieza.CastShadow = false
	pieza.Parent = carpeta
	return pieza
end

-- Un cilindro "de pie" (el cilindro de Roblox viene tumbado, así que lo giramos)
local function cilindro(carpeta, nombre, altura, diametro, base, x, y, z, color, material)
	local pieza = parte(carpeta, nombre, Vector3.new(altura, diametro, diametro), base, x, y, z, color, material, Enum.PartType.Cylinder)
	pieza.CFrame = base * CFrame.new(x, y, z) * CFrame.Angles(0, 0, math.rad(90))
	return pieza
end

local ORO = Color3.fromRGB(255, 200, 40)
local GRIS = Color3.fromRGB(165, 170, 180)

-- 🧺 LOS PREMIOS (uno por semana, van rotando). Cada uno sabe dibujarse en su sitio del jardín.
local PREMIOS = {
	{
		id = "fuente", nombre = "Fuente", icono = "⛲",
		construir = function(c, b)
			cilindro(c, "Fuente", 0.7, 3.4, b, 0, 0.35, 0, GRIS, Enum.Material.Concrete)
			cilindro(c, "Agua", 0.2, 2.9, b, 0, 0.75, 0, Color3.fromRGB(90, 180, 255), Enum.Material.Neon)
			cilindro(c, "Columna", 1.6, 0.5, b, 0, 1.5, 0, GRIS, Enum.Material.Concrete)
			cilindro(c, "Plato", 0.25, 1.6, b, 0, 2.35, 0, GRIS, Enum.Material.Concrete)
			cilindro(c, "Agua", 0.12, 1.3, b, 0, 2.5, 0, Color3.fromRGB(90, 180, 255), Enum.Material.Neon)
		end,
	},
	{
		id = "estatua", nombre = "Estatua dorada", icono = "🗽",
		construir = function(c, b)
			parte(c, "Pedestal", Vector3.new(1.6, 1, 1.6), b, 0, 0.5, 0, GRIS, Enum.Material.Concrete)
			parte(c, "Piernas", Vector3.new(0.7, 1.2, 0.5), b, 0, 1.6, 0, ORO, Enum.Material.Metal)
			parte(c, "Cuerpo", Vector3.new(0.9, 1, 0.5), b, 0, 2.7, 0, ORO, Enum.Material.Metal)
			parte(c, "Brazo", Vector3.new(0.25, 1.1, 0.25), b, -0.65, 3.0, 0, ORO, Enum.Material.Metal)
			parte(c, "Brazo", Vector3.new(0.25, 1.1, 0.25), b, 0.65, 3.0, 0, ORO, Enum.Material.Metal)
			parte(c, "Cabeza", Vector3.new(0.7, 0.7, 0.7), b, 0, 3.5, 0, ORO, Enum.Material.Metal, Enum.PartType.Ball)
			parte(c, "Estrella", Vector3.new(0.45, 0.45, 0.45), b, 0, 4.2, 0, Color3.fromRGB(255, 240, 120), Enum.Material.Neon)
		end,
	},
	{
		id = "farolillos", nombre = "Farolillos", icono = "🏮",
		construir = function(c, b)
			parte(c, "Poste", Vector3.new(0.15, 3.4, 0.15), b, 0, 1.7, 0, Color3.fromRGB(60, 50, 50), Enum.Material.Wood)
			parte(c, "Brazo", Vector3.new(2.4, 0.12, 0.12), b, 0, 3.3, 0, Color3.fromRGB(60, 50, 50), Enum.Material.Wood)
			for i, dx in { -1.1, 0, 1.1 } do
				local faro = parte(c, "Farolillo", Vector3.new(0.7, 0.85, 0.7), b, dx, 2.9, 0, Color3.fromRGB(255, 70 + i * 30, 70), Enum.Material.Neon, Enum.PartType.Ball)
				if i == 2 then
					local luz = Instance.new("PointLight")
					luz.Color = Color3.fromRGB(255, 190, 120)
					luz.Range = 16
					luz.Brightness = 1.5
					luz.Shadows = false
					luz.Parent = faro
					CollectionService:AddTag(luz, "FarolaLuz") -- el script Noche la enciende de noche
				end
			end
		end,
	},
	{
		id = "cohete", nombre = "Cohete", icono = "🚀",
		construir = function(c, b)
			local rojo = Color3.fromRGB(230, 60, 60)
			cilindro(c, "Cuerpo", 3, 1.2, b, 0, 1.7, 0, Color3.fromRGB(245, 245, 250))
			parte(c, "Punta", Vector3.new(1.2, 1.2, 1.2), b, 0, 3.4, 0, rojo, Enum.Material.SmoothPlastic, Enum.PartType.Ball)
			parte(c, "Aleta", Vector3.new(0.15, 1, 0.8), b, -0.7, 0.7, 0, rojo)
			parte(c, "Aleta", Vector3.new(0.15, 1, 0.8), b, 0.7, 0.7, 0, rojo)
			parte(c, "Aleta", Vector3.new(0.8, 1, 0.15), b, 0, 0.7, -0.7, rojo)
			parte(c, "Aleta", Vector3.new(0.8, 1, 0.15), b, 0, 0.7, 0.7, rojo)
			parte(c, "Ventana", Vector3.new(0.5, 0.5, 0.5), b, 0, 2.3, -0.5, Color3.fromRGB(100, 200, 255), Enum.Material.Neon, Enum.PartType.Ball)
		end,
	},
	{
		id = "flamenco", nombre = "Flamenco rosa", icono = "🦩",
		construir = function(c, b)
			local rosa = Color3.fromRGB(255, 130, 175)
			parte(c, "Pata", Vector3.new(0.12, 1.8, 0.12), b, 0, 0.9, 0, rosa)
			parte(c, "Cuerpo", Vector3.new(0.9, 0.9, 1.3), b, 0, 2.0, 0, rosa, Enum.Material.SmoothPlastic, Enum.PartType.Ball)
			parte(c, "Cuello", Vector3.new(0.15, 1.2, 0.15), b, 0, 2.9, -0.4, rosa)
			parte(c, "Cabeza", Vector3.new(0.35, 0.35, 0.35), b, 0, 3.55, -0.4, rosa, Enum.Material.SmoothPlastic, Enum.PartType.Ball)
			parte(c, "Pico", Vector3.new(0.14, 0.12, 0.4), b, 0, 3.5, -0.7, Color3.fromRGB(40, 40, 45))
		end,
	},
	{
		id = "arcoiris", nombre = "Arcoíris", icono = "🌈",
		construir = function(c, b)
			local colores = {
				Color3.fromRGB(235, 60, 60), Color3.fromRGB(255, 150, 50), Color3.fromRGB(255, 225, 60), Color3.fromRGB(80, 210, 100),
				Color3.fromRGB(70, 160, 255), Color3.fromRGB(110, 90, 230), Color3.fromRGB(190, 90, 220),
			}
			for i, color in colores do
				local alto = 1 + 1.8 * math.sin((i - 1) / 6 * math.pi) -- las columnas suben y bajan formando el arco
				parte(c, "Columna", Vector3.new(0.5, alto, 0.5), b, (i - 4) * 0.55, alto / 2, 0, color, Enum.Material.Neon)
			end
		end,
	},
}

----------------------------------------------------------------------
-- 📋 LO QUE VE LA PANTALLA (la lista de premios y los datos de la semana)
----------------------------------------------------------------------

local catalogo = Instance.new("Folder")
catalogo.Name = "CatalogoPremios"
for orden, premio in PREMIOS do
	local ficha = Instance.new("Folder")
	ficha.Name = premio.id
	ficha:SetAttribute("Id", premio.id)
	ficha:SetAttribute("Nombre", premio.nombre)
	ficha:SetAttribute("Icono", premio.icono)
	ficha:SetAttribute("Orden", orden)
	ficha.Parent = catalogo
end
catalogo.Parent = ReplicatedStorage

local evento = Instance.new("RemoteEvent")
evento.Name = "RetoAccion"
evento.Parent = ReplicatedStorage

local function semanaActual()
	return os.time() // SEMANA
end

local function retoDeLaSemana(semana)
	return RETOS[semana % #RETOS + 1]
end

local function premioDeLaSemana(semana)
	return PREMIOS[(semana + 2) % #PREMIOS + 1]
end

local function publicarSemana()
	local semana = semanaActual()
	local reto = retoDeLaSemana(semana)
	workspace:SetAttribute("RetoSemana", semana)
	workspace:SetAttribute("RetoTemporada", semana // AJUSTES.semanasPorTemporada + 1)
	workspace:SetAttribute("RetoSemanaDeTemporada", semana % AJUSTES.semanasPorTemporada + 1)
	workspace:SetAttribute("RetoTipo", reto.tipo)
	workspace:SetAttribute("RetoObjetivo", reto.objetivo)
	workspace:SetAttribute("RetoMonedas", reto.monedas)
	workspace:SetAttribute("RetoPremio", premioDeLaSemana(semana).id)
end
publicarSemana()

----------------------------------------------------------------------
-- 🧰 AVISOS Y MONEDAS
----------------------------------------------------------------------

local function avisar(jugador, texto, color)
	local pantallaJugador = jugador:FindFirstChild("PlayerGui")
	if not pantallaJugador then
		return
	end
	local viejo = pantallaJugador:FindFirstChild("AvisoReto")
	if viejo then
		viejo:Destroy()
	end

	local pantalla = Instance.new("ScreenGui")
	pantalla.Name = "AvisoReto"
	pantalla.ResetOnSpawn = false
	pantalla.Parent = pantallaJugador

	local mensaje = Instance.new("TextLabel")
	mensaje.Size = UDim2.fromScale(0.65, 0.1)
	mensaje.Position = UDim2.fromScale(0.5, 0.3)
	mensaje.AnchorPoint = Vector2.new(0.5, 0.5)
	mensaje.BackgroundColor3 = color
	mensaje.BackgroundTransparency = 0.1
	mensaje.TextColor3 = Color3.fromRGB(255, 255, 255)
	mensaje.TextScaled = true
	mensaje.Font = Enum.Font.FredokaOne
	mensaje.Text = texto
	mensaje.Parent = pantalla

	local esquinas = Instance.new("UICorner")
	esquinas.CornerRadius = UDim.new(0, 14)
	esquinas.Parent = mensaje

	task.delay(5, function()
		if pantalla.Parent then
			local desaparecer = TweenService:Create(mensaje, TweenInfo.new(0.6), {
				TextTransparency = 1,
				BackgroundTransparency = 1,
			})
			desaparecer:Play()
			desaparecer.Completed:Wait()
			pantalla:Destroy()
		end
	end)
end

local function sumarMonedas(jugador, cantidad)
	local marcador = jugador:FindFirstChild("leaderstats")
	local monedas = marcador and marcador:FindFirstChild("Monedas")
	if monedas then
		monedas.Value += cantidad
	end
end

-- ¿Ya se ha cargado lo guardado? (si no se carga nunca, esperamos 20 segundos y seguimos)
local function listo(jugador)
	return jugador:GetAttribute("DatosCargados") == true or os.clock() - (entrada[jugador] or os.clock()) > 20
end

----------------------------------------------------------------------
-- 🏆 EL RETO DE CADA JUGADOR
----------------------------------------------------------------------

local function iniciarIntento(jugador)
	-- Empieza (o repite) el reto de "sin morir": hay que subir "objetivo" niveles desde donde estás ahora
	local reto = retoDeLaSemana(semanaActual())
	local desde = jugador:GetAttribute("Nivel") or 1
	jugador:SetAttribute("Reto_desde", desde)
	jugador:SetAttribute("Reto_objetivo", desde + reto.objetivo)
	jugador:SetAttribute("Reto_progreso", 0)
	jugador:SetAttribute("Reto_vivo", 1)
end

local function reiniciarReto(jugador, semana)
	for nombre in jugador:GetAttributes() do
		if string.sub(nombre, 1, 5) == "Reto_" then
			jugador:SetAttribute(nombre, nil)
		end
	end
	local reto = retoDeLaSemana(semana)
	jugador:SetAttribute("Reto_semana", semana)
	jugador:SetAttribute("Reto_progreso", 0)
	if reto.tipo == "sinMorir" then
		iniciarIntento(jugador)
	else
		jugador:SetAttribute("Reto_objetivo", reto.objetivo)
	end
end

local function completarReto(jugador)
	if jugador:GetAttribute("Reto_hecho") then
		return
	end
	jugador:SetAttribute("Reto_hecho", true)
	local semana = semanaActual()
	local reto = retoDeLaSemana(semana)
	local premio = premioDeLaSemana(semana)
	sumarMonedas(jugador, reto.monedas)

	if jugador:GetAttribute("Premio_" .. premio.id) then
		sumarMonedas(jugador, AJUSTES.monedasSiYaTienesElPremio)
		avisar(jugador, "🏆 ¡RETO CUMPLIDO! +" .. reto.monedas .. " 🪙 y +" .. AJUSTES.monedasSiYaTienesElPremio .. " 🪙 (¡ya tenías " .. premio.icono .. "!)", Color3.fromRGB(190, 130, 0))
	else
		jugador:SetAttribute("Premio_" .. premio.id, true) -- el script Guardado se acuerda; la casa lo pone en el jardín
		avisar(jugador, "🏆 ¡RETO CUMPLIDO! +" .. reto.monedas .. " 🪙 y para tu jardín: " .. premio.icono .. " " .. premio.nombre, Color3.fromRGB(190, 130, 0))
	end
end

-- Suma progreso a un reto de este tipo (monedas, dardos...)
local function sumarProgreso(jugador, tipo, cantidad)
	local reto = retoDeLaSemana(semanaActual())
	if reto.tipo ~= tipo or jugador:GetAttribute("Reto_hecho") or jugador:GetAttribute("Reto_semana") ~= semanaActual() then
		return
	end
	local objetivo = jugador:GetAttribute("Reto_objetivo") or reto.objetivo
	local progreso = math.min((jugador:GetAttribute("Reto_progreso") or 0) + cantidad, objetivo)
	jugador:SetAttribute("Reto_progreso", progreso)
	if progreso >= objetivo then
		completarReto(jugador)
	end
end

-- Si ha empezado una semana nueva, el reto empieza de cero
local function comprobarSemana(jugador)
	local semana = semanaActual()
	if jugador:GetAttribute("Reto_semana") ~= semana then
		reiniciarReto(jugador, semana)
		avisar(jugador, "🏆 ¡Hay un reto nuevo esta semana!", Color3.fromRGB(60, 100, 200))
	end
end

-- El reto de "sin morir": si te mueres, se rompe (hasta que pulses "Nuevo intento")
local function vigilarMuertes(jugador, personaje)
	local humanoide = personaje:WaitForChild("Humanoid", 10)
	if not humanoide then
		return
	end
	humanoide.Died:Connect(function()
		local reto = retoDeLaSemana(semanaActual())
		if reto.tipo == "sinMorir" and jugador:GetAttribute("Reto_vivo") == 1 and not jugador:GetAttribute("Reto_hecho") then
			jugador:SetAttribute("Reto_vivo", 0)
			avisar(jugador, "💀 Te has caído: el reto se ha roto. ¡Pulsa 'Nuevo intento' en 🏆 Reto semanal!", Color3.fromRGB(180, 60, 60))
		end
	end)
end

local function prepararJugador(jugador)
	ultimoValor[jugador] = {}
	entrada[jugador] = os.clock()

	jugador.CharacterAdded:Connect(function(personaje)
		vigilarMuertes(jugador, personaje)
	end)
	if jugador.Character then
		task.spawn(vigilarMuertes, jugador, jugador.Character)
	end

	local nivelAnterior = jugador:GetAttribute("Nivel") or 1
	jugador.AttributeChanged:Connect(function(nombre)
		local tipo = CONTADORES[nombre]
		if tipo then
			local nuevo = jugador:GetAttribute(nombre) or 0
			local viejo = ultimoValor[jugador][nombre] or 0
			ultimoValor[jugador][nombre] = nuevo
			if nuevo > viejo and listo(jugador) then
				sumarProgreso(jugador, tipo, nuevo - viejo)
			end
		elseif nombre == "Nivel" then
			local nivel = jugador:GetAttribute("Nivel") or 1
			local reto = retoDeLaSemana(semanaActual())
			if nivel > nivelAnterior and listo(jugador) then
				if reto.tipo == "nivel" then
					sumarProgreso(jugador, "nivel", nivel - nivelAnterior)
				elseif reto.tipo == "sinMorir" and jugador:GetAttribute("Reto_vivo") == 1 and not jugador:GetAttribute("Reto_hecho") then
					local desde = jugador:GetAttribute("Reto_desde") or nivel
					jugador:SetAttribute("Reto_progreso", math.max(0, math.min(nivel - desde, reto.objetivo)))
					if nivel >= (jugador:GetAttribute("Reto_objetivo") or math.huge) then
						completarReto(jugador)
					end
				end
			end
			nivelAnterior = nivel
		end
	end)

	-- Esperamos a que el script Guardado haya cargado lo de otras veces (si no, hasta 20 segundos)
	task.spawn(function()
		local espera = 0
		while jugador.Parent and not jugador:GetAttribute("DatosCargados") and espera < 20 do
			task.wait(0.5)
			espera += 0.5
		end
		if jugador.Parent then
			nivelAnterior = jugador:GetAttribute("Nivel") or 1
			comprobarSemana(jugador)
		end
	end)
end

Players.PlayerAdded:Connect(prepararJugador)
for _, jugador in Players:GetPlayers() do
	prepararJugador(jugador)
end
Players.PlayerRemoving:Connect(function(jugador)
	ultimoValor[jugador] = nil
	entrada[jugador] = nil
	redibujoPendiente[jugador] = nil
end)

-- Si empieza una semana nueva con el juego abierto
task.spawn(function()
	while true do
		task.wait(AJUSTES.segundosEntreRevisiones)
		publicarSemana()
		for _, jugador in Players:GetPlayers() do
			if jugador:GetAttribute("Reto_semana") ~= nil then
				comprobarSemana(jugador)
			end
		end
	end
end)

evento.OnServerEvent:Connect(function(jugador, accion)
	if accion ~= "nuevoIntento" then
		return
	end
	local reto = retoDeLaSemana(semanaActual())
	if reto.tipo == "sinMorir" and jugador:GetAttribute("Reto_semana") == semanaActual() and not jugador:GetAttribute("Reto_hecho") and jugador:GetAttribute("Reto_vivo") ~= 1 then
		iniciarIntento(jugador)
		avisar(jugador, "🔁 ¡Nuevo intento! Sube " .. reto.objetivo .. " niveles sin caerte", Color3.fromRGB(60, 100, 200))
	end
end)

----------------------------------------------------------------------
-- 🏡 LOS PREMIOS EN EL JARDÍN DE CADA CASA
----------------------------------------------------------------------

local function buscarOrigen(indice)
	for _, marca in CollectionService:GetTagged("CasaOrigen") do
		if marca:GetAttribute("Indice") == indice then
			return marca
		end
	end
	return nil
end

local function ponerPremios(jugador)
	local numero = jugador:GetAttribute("CasaNumero")
	local origen
	for _ = 1, 40 do
		numero = jugador:GetAttribute("CasaNumero")
		origen = numero and buscarOrigen(numero)
		if origen or not jugador.Parent then
			break
		end
		task.wait(0.5)
	end
	if not origen then
		return
	end
	local carpeta = origen.Parent:FindFirstChild("Premios")
	if not carpeta then
		carpeta = Instance.new("Folder")
		carpeta.Name = "Premios"
		carpeta.Parent = origen.Parent
	end
	carpeta:ClearAllChildren()
	for i, premio in PREMIOS do
		if jugador:GetAttribute("Premio_" .. premio.id) == true then
			premio.construir(carpeta, origen.CFrame * CFrame.new(SITIOS[i][1], 0.2, SITIOS[i][2]))
		end
	end
end

-- Junta varios cambios seguidos (al cargar lo guardado llegan muchos) y dibuja una sola vez
local function programarPremios(jugador)
	if redibujoPendiente[jugador] then
		return
	end
	redibujoPendiente[jugador] = true
	task.delay(1.5, function()
		redibujoPendiente[jugador] = nil
		if jugador.Parent then
			ponerPremios(jugador)
		end
	end)
end

local function vigilarPremios(jugador)
	jugador.AttributeChanged:Connect(function(nombre)
		if nombre == "CasaNumero" or string.sub(nombre, 1, 7) == "Premio_" then
			programarPremios(jugador)
		end
	end)
	if jugador:GetAttribute("CasaNumero") then
		programarPremios(jugador)
	end
end

Players.PlayerAdded:Connect(vigilarPremios)
for _, jugador in Players:GetPlayers() do
	vigilarPremios(jugador)
end
Players.PlayerRemoving:Connect(function(jugador)
	-- Se va el dueño: se quitan los premios del jardín
	local numero = jugador:GetAttribute("CasaNumero")
	local origen = numero and buscarOrigen(numero)
	local carpeta = origen and origen.Parent:FindFirstChild("Premios")
	if carpeta then
		carpeta:ClearAllChildren()
	end
end)

print("🏆 Reto semanal listo.")
