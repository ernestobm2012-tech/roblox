--[[
	⏱️ CRONÓMETRO (parte del servidor)
	Mide cuánto tardas en llegar a la META.
	  - El tiempo EMPIEZA cuando sales de la zona de salida (empezando desde el nivel 1).
	  - Se PARA cuando tocas la META (¡al final de los 500 niveles!). Si es tu mejor tiempo,
	    ¡es un récord nuevo!
	  - Si te caes, el reloj sigue corriendo (vuelves a tu checkpoint). Solo se reinicia si vuelves
	    a la salida.
	  - Si entras a jugar y sigues en un nivel guardado, no hay reloj hasta que vuelvas a la salida.
	  - En el marcador de arriba a la derecha sale la columna "Mejor tiempo" de cada
	    jugador, para ver quién llega antes.

	El reloj que ves en la pantalla lo dibuja el script "Cronometro" (LocalScript).

	📋 DÓNDE VA: en Roblox Studio, dentro de ServerScriptService, como "Script".
	(Usa la META y el marcador que crea el script MiMundo.)
]]

local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")
local TweenService = game:GetService("TweenService")

-- ⚙️ AJUSTES
local AJUSTES = {
	-- Si te alejas más de estos "studs" de la salida, el cronómetro arranca
	radioDeSalida = 12,
}

-- Escribe un tiempo como minutos:segundos (o horas:minutos:segundos). Va más tranquilo que con decimales.
local function formatearTiempo(segundos)
	local total = math.floor(segundos)
	local horas = total // 3600
	local minutos = (total % 3600) // 60
	local resto = total % 60
	if horas > 0 then
		return string.format("%d:%02d:%02d", horas, minutos, resto)
	end
	return string.format("%d:%02d", minutos, resto)
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
			mensaje.BackgroundColor3 = Color3.fromRGB(60, 90, 190)
			mensaje.BackgroundTransparency = 0.1
			mensaje.TextColor3 = Color3.fromRGB(255, 255, 255)
			mensaje.TextScaled = true
			mensaje.Font = Enum.Font.FredokaOne
			mensaje.Text = texto
			mensaje.Parent = pantalla

			local esquinas = Instance.new("UICorner")
			esquinas.CornerRadius = UDim.new(0, 14)
			esquinas.Parent = mensaje

			task.delay(8, function()
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

-- ¿Es el mejor tiempo de TODOS los jugadores de todos los tiempos? (se guarda en los servidores de Roblox;
-- si el guardado no está activado, simplemente no se mira)
local almacenRecords = DataStoreService:GetDataStore("MiMundoRecords_v1")

local function comprobarRecordDelMundo(jugador, tiempo)
	local funciono, resultado = pcall(function()
		return almacenRecords:UpdateAsync("recordMeta", function(viejo)
			if viejo and viejo.tiempo and viejo.tiempo <= tiempo then
				return nil -- el de antes era mejor
			end
			return { tiempo = tiempo, nombre = jugador.DisplayName, userId = jugador.UserId }
		end)
	end)
	if funciono and resultado and resultado.userId == jugador.UserId and math.abs(resultado.tiempo - tiempo) < 0.001 then
		anunciarATodos("🌟 ¡RÉCORD DEL MUNDO! " .. jugador.DisplayName .. ": " .. formatearTiempo(tiempo), "AnuncioRecordMundo", 0.36)
	end
end

-- Esperamos a que MiMundo haya construido la meta
local carpetaMundo = workspace:WaitForChild("MiMundo", 15)
local meta = carpetaMundo and carpetaMundo:WaitForChild("Meta", 90)
if not meta then
	warn("⏱️ No encuentro la Meta. ¿Está el script MiMundo?")
	return
end
local salida = workspace:FindFirstChildWhichIsA("SpawnLocation", true)
local posicionSalida = salida and salida.Position or Vector3.zero

-- Estados de cada jugador: "esperando" (en la salida), "corriendo", "terminado" o "sinreloj"
local estado = {}

local function ponerEstado(jugador, nuevo)
	estado[jugador] = nuevo
	jugador:SetAttribute("CronoEstado", nuevo) -- el LocalScript lo lee para dibujar el reloj
end

----------------------------------------------------------------------
-- 🏅 COLUMNA "MEJOR TIEMPO" EN EL MARCADOR
----------------------------------------------------------------------

local function prepararJugador(jugador)
	ponerEstado(jugador, "esperando")

	task.spawn(function()
		local marcador = jugador:WaitForChild("leaderstats", 30)
		if not marcador then
			return
		end

		local texto = Instance.new("StringValue")
		texto.Name = "Mejor tiempo"

		local function actualizar()
			local mejor = jugador:GetAttribute("MejorTiempo")
			if type(mejor) == "number" and mejor > 0 then
				texto.Value = formatearTiempo(mejor)
			else
				texto.Value = "--"
			end
		end
		actualizar()
		jugador:GetAttributeChangedSignal("MejorTiempo"):Connect(actualizar)
		texto.Parent = marcador
	end)
end

Players.PlayerAdded:Connect(prepararJugador)
for _, jugador in Players:GetPlayers() do
	prepararJugador(jugador)
end
Players.PlayerRemoving:Connect(function(jugador)
	estado[jugador] = nil
end)

----------------------------------------------------------------------
-- 🏁 LLEGAR A LA META
----------------------------------------------------------------------

meta.Touched:Connect(function(otro)
	local personaje = otro.Parent
	local jugador = personaje and Players:GetPlayerFromCharacter(personaje)
	if not jugador or estado[jugador] ~= "corriendo" then
		return
	end

	local tiempo = workspace:GetServerTimeNow() - jugador:GetAttribute("CronoInicio")
	local mejor = jugador:GetAttribute("MejorTiempo")
	local esRecord = type(mejor) ~= "number" or mejor <= 0 or tiempo < mejor

	if esRecord then
		jugador:SetAttribute("MejorTiempo", tiempo)
		anunciarATodos("⏱️ ¡" .. jugador.DisplayName .. " ha batido su récord de tiempo! " .. formatearTiempo(tiempo), "AnuncioRecord", 0.24)
		task.spawn(comprobarRecordDelMundo, jugador, tiempo)
	end
	jugador:SetAttribute("CronoFinal", tiempo)
	jugador:SetAttribute("CronoRecord", esRecord)
	ponerEstado(jugador, "terminado")

	print("⏱️ " .. jugador.Name .. " ha llegado a la meta en " .. formatearTiempo(tiempo))
end)

----------------------------------------------------------------------
-- 🚦 ARRANCAR Y REINICIAR EL RELOJ
----------------------------------------------------------------------

task.spawn(function()
	while true do
		task.wait(0.1)
		for jugador, actual in estado do
			local personaje = jugador.Character
			local raiz = personaje and personaje:FindFirstChild("HumanoidRootPart")
			if raiz then
				local hacia = raiz.Position - posicionSalida
				local distancia = Vector3.new(hacia.X, 0, hacia.Z).Magnitude

				if distancia <= AJUSTES.radioDeSalida then
					-- Estás en la salida: el reloj espera
					if actual ~= "esperando" then
						ponerEstado(jugador, "esperando")
					end
				elseif actual == "esperando" then
					if (jugador:GetAttribute("Nivel") or 1) <= 1 then
						-- Acabas de salir desde el principio: ¡YA!
						jugador:SetAttribute("CronoInicio", workspace:GetServerTimeNow())
						ponerEstado(jugador, "corriendo")
					else
						-- Has aparecido en un nivel guardado: no se puede medir el tiempo desde el principio
						ponerEstado(jugador, "sinreloj")
					end
				end
			end
		end
	end
end)

print("⏱️ Cronómetro listo.")
