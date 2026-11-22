--[[
	🌍 MI MUNDO
	Este script construye el mundo cuando empieza el juego:
	  - Un parkour (obby) de plataformas de colores que suben
	  - Lava debajo: ¡si la tocas, vuelves a empezar!
	  - Una META con trofeo al final
	  - Monedas que giran y se pueden recoger
	  - Un marcador con tus Monedas y Victorias

	📋 DÓNDE VA: en Roblox Studio, dentro de ServerScriptService, como "Script".
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

-- ⚙️ AJUSTES: ¡cambia estos números y mira qué pasa!
local AJUSTES = {
	numeroDePlataformas = 12, -- cuántas plataformas tiene el parkour
	distanciaEntrePlataformas = 10, -- más grande = saltos más difíciles
	subidaPorPlataforma = 2, -- cuánto sube cada plataforma
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
-- 🌈 PARKOUR DE PLATAFORMAS
----------------------------------------------------------------------

local N = AJUSTES.numeroDePlataformas
local distancia = AJUSTES.distanciaEntrePlataformas
local subida = AJUSTES.subidaPorPlataforma

for i = 1, N do
	local posicion = Vector3.new(0, i * subida, 10 + i * distancia)
	local color = Color3.fromHSV(i / N, 0.8, 1) -- cada plataforma de un color del arcoíris
	crearBloque("Plataforma" .. i, Vector3.new(6, 1, 6), posicion, color)
end

----------------------------------------------------------------------
-- 🔥 LAVA (¡no la toques!)
----------------------------------------------------------------------

local inicioLava = 15
local finLava = 10 + (N + 1) * distancia + 8
local lava = crearBloque(
	"Lava",
	Vector3.new(16, 1, finLava - inicioLava),
	Vector3.new(0, 0.5, (inicioLava + finLava) / 2),
	Color3.fromRGB(255, 70, 0),
	Enum.Material.Neon
)

lava.Touched:Connect(function(otro)
	local _, humanoide = buscarJugador(otro)
	if humanoide then
		humanoide.Health = 0
	end
end)

----------------------------------------------------------------------
-- 🏆 META
----------------------------------------------------------------------

local posicionMeta = Vector3.new(0, (N + 1) * subida, 10 + (N + 1) * distancia + 3)
local meta = crearBloque("Meta", Vector3.new(12, 1, 12), posicionMeta, Color3.fromRGB(255, 215, 0), Enum.Material.Neon)

-- Cartel flotante encima de la meta
local cartel = Instance.new("BillboardGui")
cartel.Size = UDim2.fromOffset(200, 60)
cartel.StudsOffset = Vector3.new(0, 6, 0)
cartel.AlwaysOnTop = true
cartel.Parent = meta

local textoCartel = Instance.new("TextLabel")
textoCartel.Size = UDim2.fromScale(1, 1)
textoCartel.BackgroundTransparency = 1
textoCartel.Text = "🏆 ¡META!"
textoCartel.TextScaled = true
textoCartel.Font = Enum.Font.FredokaOne
textoCartel.TextColor3 = Color3.fromRGB(255, 255, 255)
textoCartel.TextStrokeTransparency = 0
textoCartel.Parent = cartel

local yaGanaron = {} -- para no contar la misma victoria muchas veces

meta.Touched:Connect(function(otro)
	local jugador = buscarJugador(otro)
	if not jugador or yaGanaron[jugador] then
		return
	end
	yaGanaron[jugador] = true
	sumarPuntos(jugador, "Victorias", 1)

	-- ✨ Brillitos de celebración
	local personaje = jugador.Character
	local raiz = personaje and personaje:FindFirstChild("HumanoidRootPart")
	if raiz then
		local brillos = Instance.new("Sparkles")
		brillos.Parent = raiz
		task.delay(3, function()
			brillos:Destroy()
		end)
	end

	-- A los 3 segundos, vuelve a la salida para jugar otra vez
	task.wait(3)
	if jugador.Character then
		jugador.Character:PivotTo(salida.CFrame + Vector3.new(0, 4, 0))
	end
	yaGanaron[jugador] = nil
end)

Players.PlayerRemoving:Connect(function(jugador)
	yaGanaron[jugador] = nil
end)

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
