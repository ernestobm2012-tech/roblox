--[[
	🏁 MODO CARRERA
	Los jugadores se apuntan con el botón "🏁 Carrera". Cuando hay suficientes, empieza una cuenta
	atrás y TODOS salen a la vez desde el nivel 1. ¡Gana el primero en llegar al nivel que toque!
	  - El ganador se lleva monedas 🪙 y su nombre sale en la pantalla de todos.
	  - Al terminar, todos vuelven a su nivel de siempre (la carrera no cambia tu nivel guardado).
	  - Si alguien bate el récord de carrera, ¡también se avisa a todos!

	📋 DÓNDE VA: en Roblox Studio, dentro de ServerScriptService, como "Script".
	(Usa los checkpoints que construye el script Niveles y lleva a los jugadores con el atributo
	"SaltarANivel". Habla con la pantalla con un RemoteEvent y con atributos del mundo.)
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local DataStoreService = game:GetService("DataStoreService")

-- ⚙️ AJUSTES: ¡cambia estos valores y mira qué pasa!
local AJUSTES = {
	nivelObjetivo = 10, -- gana el primero en llegar a este nivel (tiene que ser 2 o más)
	minimoJugadores = 2, -- cuántos hacen falta para empezar
	segundosDeEspera = 20, -- espera desde que hay suficientes hasta que sale la carrera
	cuentaAtras = 3, -- 3, 2, 1...
	segundosMaximos = 900, -- si nadie llega en este tiempo, se acaba
	premioGanador = 100, -- monedas del ganador
	premioParticipacion = 10, -- monedas de los demás que han llegado a correr
	nombreDelGuardado = "MiMundoRecords_v1", -- aquí se guarda el récord de carrera
}

local almacenRecords = DataStoreService:GetDataStore(AJUSTES.nombreDelGuardado)

local inscritos = {} -- los que se han apuntado
local participantes = {} -- los que están corriendo
local estado = "esperando" -- "esperando", "cuenta", "enCurso" o "fin"
local ganador = nil
local tiempoGanador = 0

local evento = Instance.new("RemoteEvent")
evento.Name = "Carrera"
evento.Parent = ReplicatedStorage

----------------------------------------------------------------------
-- 🧰 HERRAMIENTAS
----------------------------------------------------------------------

local function contar(tabla)
	local total = 0
	for _ in tabla do
		total += 1
	end
	return total
end

local function formatearTiempo(segundos)
	local total = math.floor(segundos)
	return string.format("%d:%02d", total // 60, total % 60)
end

-- Lo que pone arriba en la pantalla de todos (vacío = no se enseña nada)
local function ponerTexto(texto)
	workspace:SetAttribute("CarreraTexto", texto)
end

local function sumarMonedas(jugador, cantidad)
	local marcador = jugador:FindFirstChild("leaderstats")
	local monedas = marcador and marcador:FindFirstChild("Monedas")
	if monedas then
		monedas.Value += cantidad
	end
end

-- Un mensaje grande para TODOS los jugadores
local function anunciarATodos(texto, nombreGui, alturaEnPantalla)
	print("📣 " .. texto)
	for _, jugador in Players:GetPlayers() do
		local pantallaJugador = jugador:FindFirstChild("PlayerGui")
		if pantallaJugador then
			local viejo = pantallaJugador:FindFirstChild(nombreGui)
			if viejo then
				viejo:Destroy()
			end
			local pantalla = Instance.new("ScreenGui")
			pantalla.Name = nombreGui
			pantalla.ResetOnSpawn = false
			pantalla.Parent = pantallaJugador

			local mensaje = Instance.new("TextLabel")
			mensaje.Size = UDim2.fromScale(0.6, 0.1)
			mensaje.Position = UDim2.fromScale(0.5, alturaEnPantalla)
			mensaje.AnchorPoint = Vector2.new(0.5, 0.5)
			mensaje.BackgroundColor3 = Color3.fromRGB(190, 130, 0)
			mensaje.BackgroundTransparency = 0.1
			mensaje.TextColor3 = Color3.fromRGB(255, 255, 255)
			mensaje.TextScaled = true
			mensaje.Font = Enum.Font.FredokaOne
			mensaje.Text = texto
			mensaje.Parent = pantalla

			local esquinas = Instance.new("UICorner")
			esquinas.CornerRadius = UDim.new(0, 14)
			esquinas.Parent = mensaje

			task.delay(7, function()
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
	end
end

-- ¿Es el mejor tiempo de carrera de todos los tiempos? Si sí, lo avisamos.
local function comprobarRecord(jugador, tiempo)
	local funciono, resultado = pcall(function()
		return almacenRecords:UpdateAsync("recordCarrera", function(viejo)
			if viejo and viejo.tiempo and viejo.tiempo <= tiempo then
				return nil -- el de antes era mejor
			end
			return { tiempo = tiempo, nombre = jugador.DisplayName, userId = jugador.UserId }
		end)
	end)
	if funciono and resultado and resultado.userId == jugador.UserId and math.abs(resultado.tiempo - tiempo) < 0.001 then
		anunciarATodos("⏱️ ¡RÉCORD DE CARRERA! " .. jugador.DisplayName .. ": " .. formatearTiempo(tiempo), "AnuncioRecordCarrera", 0.4)
	end
end

----------------------------------------------------------------------
-- 🔔 APUNTARSE Y SALIR
----------------------------------------------------------------------

evento.OnServerEvent:Connect(function(jugador, accion)
	if type(accion) ~= "string" then
		return
	end
	if accion == "unirse" then
		if estado == "cuenta" or estado == "enCurso" then
			return -- la carrera ya ha empezado: hay que esperar a la siguiente
		end
		inscritos[jugador] = true
		jugador:SetAttribute("EnCarrera", true)
	elseif accion == "salir" then
		inscritos[jugador] = nil
		participantes[jugador] = nil
		jugador:SetAttribute("EnCarrera", nil)
	end
end)

Players.PlayerRemoving:Connect(function(jugador)
	inscritos[jugador] = nil
	participantes[jugador] = nil
end)

----------------------------------------------------------------------
-- 🏆 LLEGAR A LA META DE LA CARRERA
----------------------------------------------------------------------

local carpetaMundo = workspace:WaitForChild("MiMundo", 30)
local nivelMeta = math.max(AJUSTES.nivelObjetivo, 2)
local metaCarrera = carpetaMundo and carpetaMundo:WaitForChild("Checkpoint_" .. nivelMeta, 90)
if not metaCarrera then
	warn("🏁 No encuentro el checkpoint del nivel " .. nivelMeta .. ". El modo carrera no funcionará.")
	return
end
local salida = carpetaMundo:WaitForChild("Checkpoint_1", 30)

metaCarrera.Touched:Connect(function(otro)
	if estado ~= "enCurso" or ganador then
		return
	end
	local personaje = otro.Parent
	local jugador = personaje and Players:GetPlayerFromCharacter(personaje)
	if jugador and participantes[jugador] then
		ganador = jugador
	end
end)

----------------------------------------------------------------------
-- 🏁 UNA CARRERA
----------------------------------------------------------------------

-- Esperamos (un poco) a que el jugador llegue a la salida de la carrera
local function esperarLlegada(jugador)
	for _ = 1, 40 do
		local raiz = jugador.Character and jugador.Character:FindFirstChild("HumanoidRootPart")
		if raiz and salida and (raiz.Position - salida.Position).Magnitude < 40 then
			return
		end
		task.wait(0.25)
	end
end

local function correrCarrera()
	estado = "cuenta"
	workspace:SetAttribute("CarreraEstado", estado)
	participantes = {}
	for jugador in inscritos do
		participantes[jugador] = true
	end
	inscritos = {}

	-- Todos a la salida
	ponerTexto("🏁 ¡Todos a la salida!")
	for jugador in participantes do
		jugador:SetAttribute("SaltarANivel", 1)
	end
	for jugador in participantes do
		esperarLlegada(jugador)
	end

	-- Cuenta atrás: todos quietos
	for jugador in participantes do
		local raiz = jugador.Character and jugador.Character:FindFirstChild("HumanoidRootPart")
		if raiz then
			raiz.Anchored = true
		end
	end
	for numero = AJUSTES.cuentaAtras, 1, -1 do
		ponerTexto("🏁 " .. numero)
		task.wait(1)
	end
	for jugador in participantes do
		local raiz = jugador.Character and jugador.Character:FindFirstChild("HumanoidRootPart")
		if raiz then
			raiz.Anchored = false
		end
	end

	-- ¡YA!
	estado = "enCurso"
	workspace:SetAttribute("CarreraEstado", estado)
	ganador = nil
	local inicio = os.clock()
	while not ganador and os.clock() - inicio < AJUSTES.segundosMaximos and contar(participantes) > 0 do
		ponerTexto("🏁 ¡Carrera al nivel " .. nivelMeta .. "!  ⏱️ " .. formatearTiempo(os.clock() - inicio))
		task.wait(0.5)
	end
	tiempoGanador = os.clock() - inicio

	-- Final
	estado = "fin"
	workspace:SetAttribute("CarreraEstado", estado)
	if ganador then
		local nombre = ganador.DisplayName
		anunciarATodos("🏆 ¡" .. nombre .. " gana la carrera! " .. formatearTiempo(tiempoGanador), "AnuncioCarrera", 0.28)
		ponerTexto("🏆 ¡Gana " .. nombre .. "!")
		for jugador in participantes do
			sumarMonedas(jugador, if jugador == ganador then AJUSTES.premioGanador else AJUSTES.premioParticipacion)
		end
		ganador:SetAttribute("Estad_carrerasGanadas", (ganador:GetAttribute("Estad_carrerasGanadas") or 0) + 1) -- para los logros
		task.spawn(comprobarRecord, ganador, tiempoGanador)
	else
		ponerTexto("🏁 Nadie ha llegado. ¡Otra vez!")
	end
	task.wait(5)

	-- Cada uno vuelve a su nivel de siempre
	for jugador in participantes do
		jugador:SetAttribute("EnCarrera", nil)
		jugador:SetAttribute("Estad_carreras", (jugador:GetAttribute("Estad_carreras") or 0) + 1) -- para las misiones
		jugador:SetAttribute("SaltarANivel", jugador:GetAttribute("Nivel") or 1)
	end
	participantes = {}
	ganador = nil
	ponerTexto("")
end

-- El bucle de siempre: esperar jugadores, esperar un poco, correr, otra vez...
task.spawn(function()
	while true do
		estado = "esperando"
		workspace:SetAttribute("CarreraEstado", estado)
		ponerTexto("")
		while contar(inscritos) < AJUSTES.minimoJugadores do
			if contar(inscritos) > 0 then
				ponerTexto("🏁 Carrera: faltan jugadores (" .. contar(inscritos) .. "/" .. AJUSTES.minimoJugadores .. ")")
			end
			task.wait(0.5)
		end

		local restante = AJUSTES.segundosDeEspera
		while restante > 0 and contar(inscritos) >= AJUSTES.minimoJugadores do
			ponerTexto("🏁 La carrera empieza en " .. restante .. " s (" .. contar(inscritos) .. " jugadores)")
			task.wait(1)
			restante -= 1
		end
		if contar(inscritos) >= AJUSTES.minimoJugadores then
			correrCarrera()
		end
	end
end)

print("🏁 Modo carrera listo.")
