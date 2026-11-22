--[[
	🌍 MI MUNDO (la base)
	Este script prepara lo de la zona de salida:
	  - El suelo y el punto de salida
	  - Monedas que giran y se pueden recoger
	  - Un marcador con tus Monedas y Victorias

	Los 500 niveles, la lava y la meta los construye el script "Niveles".
	La noche y las farolas, el script "Noche".

	📋 DÓNDE VA: en Roblox Studio, dentro de ServerScriptService, como "Script".
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

-- ⚙️ AJUSTES: ¡cambia estos números y mira qué pasa!
local AJUSTES = {
	numeroDeMonedas = 10, -- cuántas monedas hay por el mapa
	segundosParaQueVuelvaLaMoneda = 5, -- tiempo hasta que reaparece una moneda
}

-- Todo lo que construimos va dentro de esta carpeta, para tenerlo ordenado
local carpeta = Instance.new("Folder")
carpeta.Name = "MiMundo"
carpeta.Parent = workspace

----------------------------------------------------------------------
-- 🧰 HERRAMIENTAS (funciones que usamos muchas veces)
----------------------------------------------------------------------

-- Crea un bloque y lo pone en el mundo
local function crearBloque(nombre, tamano, posicion, color, material)
	local bloque = Instance.new("Part")
	bloque.Name = nombre
	bloque.Size = tamano
	bloque.Position = posicion
	bloque.Color = color
	bloque.Material = material or Enum.Material.SmoothPlastic
	bloque.Anchored = true -- anclado = no se cae
	bloque.TopSurface = Enum.SurfaceType.Smooth
	bloque.BottomSurface = Enum.SurfaceType.Smooth
	bloque.Parent = carpeta
	return bloque
end

-- Cuando algo toca un bloque, averigua si es un jugador
local function buscarJugador(parteQueToca)
	local personaje = parteQueToca.Parent
	local humanoide = personaje and personaje:FindFirstChildOfClass("Humanoid")
	if humanoide then
		return Players:GetPlayerFromCharacter(personaje), humanoide
	end
	return nil, nil
end

-- Suma puntos en el marcador de un jugador
local function sumarPuntos(jugador, nombre, cantidad)
	local marcador = jugador:FindFirstChild("leaderstats")
	local valor = marcador and marcador:FindFirstChild(nombre)
	if valor then
		valor.Value += cantidad
	end
end

----------------------------------------------------------------------
-- 🏅 MARCADOR (arriba a la derecha de la pantalla)
----------------------------------------------------------------------

local function crearMarcador(jugador)
	local marcador = Instance.new("Folder")
	marcador.Name = "leaderstats" -- tiene que llamarse así para que Roblox lo enseñe

	local monedas = Instance.new("IntValue")
	monedas.Name = "Monedas"
	monedas.Parent = marcador

	local victorias = Instance.new("IntValue")
	victorias.Name = "Victorias"
	victorias.Parent = marcador

	marcador.Parent = jugador
end

Players.PlayerAdded:Connect(crearMarcador)
for _, jugador in Players:GetPlayers() do
	crearMarcador(jugador)
end

----------------------------------------------------------------------
-- 🌱 SUELO Y PUNTO DE SALIDA
----------------------------------------------------------------------

-- Si el mundo no tiene suelo, ponemos uno de hierba
if not workspace:FindFirstChild("Baseplate") then
	crearBloque("Suelo", Vector3.new(200, 2, 200), Vector3.new(0, -1, 0), Color3.fromRGB(90, 170, 80), Enum.Material.Grass)
end

-- Si no hay sitio donde aparecer, creamos uno
local salida = workspace:FindFirstChildWhichIsA("SpawnLocation", true)
if not salida then
	salida = Instance.new("SpawnLocation")
	salida.Name = "Salida"
	salida.Size = Vector3.new(8, 1, 8)
	salida.Position = Vector3.new(0, 0.5, 0)
	salida.Anchored = true
	salida.Color = Color3.fromRGB(60, 140, 255)
	salida.Duration = 0 -- sin escudo al aparecer
	salida.Parent = carpeta
end

----------------------------------------------------------------------
-- 🪙 MONEDAS
----------------------------------------------------------------------

local monedas = {}
local azar = Random.new()

for i = 1, AJUSTES.numeroDeMonedas do
	-- Ponemos cada moneda en un sitio al azar, a un lado del parkour
	local lado = if azar:NextNumber() < 0.5 then -1 else 1
	local posicion = Vector3.new(lado * azar:NextNumber(15, 60), 3, azar:NextNumber(-40, 60))

	local moneda = crearBloque("Moneda" .. i, Vector3.new(0.4, 3, 3), posicion, Color3.fromRGB(255, 200, 0), Enum.Material.Neon)
	moneda.Shape = Enum.PartType.Cylinder
	moneda.CanCollide = false
	table.insert(monedas, { parte = moneda, posicion = posicion })

	local activa = true
	moneda.Touched:Connect(function(otro)
		if not activa then
			return
		end
		local jugador = buscarJugador(otro)
		if not jugador then
			return
		end

		activa = false
		moneda.Transparency = 1 -- la moneda "desaparece"
		sumarPuntos(jugador, "Monedas", 1)

		task.delay(AJUSTES.segundosParaQueVuelvaLaMoneda, function()
			moneda.Transparency = 0
			activa = true
		end)
	end)
end

-- Hacemos que todas las monedas giren sin parar
RunService.Heartbeat:Connect(function()
	local giro = os.clock() * 2
	for _, moneda in monedas do
		moneda.parte.CFrame = CFrame.new(moneda.posicion) * CFrame.Angles(0, giro, 0)
	end
end)

print("🌍 ¡Mundo construido!")
