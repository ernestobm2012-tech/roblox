--[[
	⏱️ CRONÓMETRO (parte del servidor)
	Mide cuánto tardas en llegar a la META.
	  - El tiempo EMPIEZA cuando sales de la zona de salida.
	  - Se PARA cuando tocas la META. Si es tu mejor tiempo, ¡es un récord nuevo!
	  - Si vuelves a la salida (o caes en la lava y reapareces), se reinicia.
	  - En el marcador de arriba a la derecha sale la columna "Mejor tiempo" de cada
	    jugador, para ver quién llega antes.

	El reloj que ves en la pantalla lo dibuja el script "Cronometro" (LocalScript).

	📋 DÓNDE VA: en Roblox Studio, dentro de ServerScriptService, como "Script".
	(Usa la META y el marcador que crea el script MiMundo.)
]]

local Players = game:GetService("Players")

-- ⚙️ AJUSTES
local AJUSTES = {
	-- Si te alejas más de estos "studs" de la salida, el cronómetro arranca
	radioDeSalida = 12,
}

-- Esperamos a que MiMundo haya construido la meta
local carpetaMundo = workspace:WaitForChild("MiMundo", 15)
local meta = carpetaMundo and carpetaMundo:WaitForChild("Meta", 15)
if not meta then
	warn("⏱️ No encuentro la Meta. ¿Está el script MiMundo?")
	return
end
local salida = workspace:FindFirstChildWhichIsA("SpawnLocation", true)
local posicionSalida = salida and salida.Position or Vector3.zero

-- Estados de cada jugador: "esperando" (en la salida), "corriendo" o "terminado"
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
				texto.Value = string.format("%.2f s", mejor)
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
	end
	jugador:SetAttribute("CronoFinal", tiempo)
	jugador:SetAttribute("CronoRecord", esRecord)
	ponerEstado(jugador, "terminado")

	print(string.format("⏱️ %s ha llegado a la meta en %.2f segundos", jugador.Name, tiempo))
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
					-- Acabas de salir: ¡YA!
					jugador:SetAttribute("CronoInicio", workspace:GetServerTimeNow())
					ponerEstado(jugador, "corriendo")
				end
			end
		end
	end
end)

print("⏱️ Cronómetro listo.")
