--[[
	🌲 BOSQUE (la zona de salida)
	Convierte el suelo de la zona de salida en un prado de hierba y planta un BOSQUE alrededor:
	robles redondos y pinos, arbustos y rocas, por detrás de las casitas y a los lados.

	(El bosque del fondo del parkour lo dibuja el script "Bosque" del cliente, en tu pantalla.)

	📋 DÓNDE VA: en Roblox Studio, dentro de ServerScriptService, como "Script".
	(Usa la carpeta del mundo que crea el script MiMundo.)
]]

local AJUSTES = {
	semilla = 4242, -- mismo número = mismo bosque. ¡Cámbialo y salen los árboles en otros sitios!
	separacion = 9, -- lo separados que están los árboles (más grande = menos árboles)
	colorHierba = Color3.fromRGB(70, 140, 60),
}

-- Esperamos a que MiMundo cree su carpeta
local carpetaMundo = workspace:WaitForChild("MiMundo", 30)
if not carpetaMundo then
	warn("🌲 No encuentro la carpeta MiMundo. ¿Está el script MiMundo?")
	return
end

local carpeta = Instance.new("Folder")
carpeta.Name = "Bosque"
carpeta.Parent = workspace

local azar = Random.new(AJUSTES.semilla)

----------------------------------------------------------------------
-- 🌱 EL PRADO
----------------------------------------------------------------------

-- El suelo de la plantilla "Baseplate" es gris: lo pintamos de hierba
local suelo = workspace:FindFirstChild("Baseplate")
if suelo and suelo:IsA("BasePart") then
	suelo.Color = AJUSTES.colorHierba
	suelo.Material = Enum.Material.Grass
	for _, hijo in suelo:GetChildren() do
		if hijo:IsA("Texture") or hijo:IsA("Decal") then
			hijo:Destroy() -- quitamos la cuadrícula gris
		end
	end
end

----------------------------------------------------------------------
-- 🌳 LOS ÁRBOLES
----------------------------------------------------------------------

local function crearParte(nombre, tamano, posicion, color, material, forma)
	local parte = Instance.new("Part")
	parte.Name = nombre
	parte.Size = tamano
	parte.CFrame = CFrame.new(posicion)
	parte.Color = color
	parte.Material = material
	parte.Shape = forma or Enum.PartType.Block
	parte.Anchored = true
	parte.CastShadow = false
	parte.TopSurface = Enum.SurfaceType.Smooth
	parte.BottomSurface = Enum.SurfaceType.Smooth
	parte.Parent = carpeta
	return parte
end

local function verde()
	return Color3.fromRGB(azar:NextInteger(40, 70), azar:NextInteger(120, 175), azar:NextInteger(40, 70))
end

-- Un roble: tronco marrón y una copa redonda de hojas
local function crearRoble(x, z)
	local alto = azar:NextNumber(11, 17)
	local ancho = azar:NextNumber(2, 3)
	crearParte("Tronco", Vector3.new(ancho, alto, ancho), Vector3.new(x, alto / 2, z), Color3.fromRGB(100, 68, 42), Enum.Material.Wood)
	local copa = azar:NextNumber(11, 16)
	local hojas = crearParte("Copa", Vector3.new(copa, copa, copa), Vector3.new(x, alto + copa * 0.3, z), verde(), Enum.Material.Grass, Enum.PartType.Ball)
	hojas.CanCollide = false
	if azar:NextNumber() < 0.5 then
		local pequena = copa * 0.65
		local otra = crearParte("Copa", Vector3.new(pequena, pequena, pequena), Vector3.new(x + azar:NextNumber(-4, 4), alto + copa * 0.6, z + azar:NextNumber(-4, 4)), verde(), Enum.Material.Grass, Enum.PartType.Ball)
		otra.CanCollide = false
	end
end

-- Un pino: tronco y tres "platos" de hojas, cada vez más pequeños
local function crearPino(x, z)
	local alto = azar:NextNumber(14, 20)
	crearParte("Tronco", Vector3.new(2, alto, 2), Vector3.new(x, alto / 2, z), Color3.fromRGB(90, 60, 38), Enum.Material.Wood)
	local base = azar:NextNumber(12, 15)
	for piso = 0, 2 do
		local diametro = base - piso * 3.5
		local plato = crearParte("Hojas", Vector3.new(3, diametro, diametro), Vector3.new(x, alto * 0.45 + piso * 4, z), Color3.fromRGB(30, 100 + piso * 12, 55), Enum.Material.Grass, Enum.PartType.Cylinder)
		plato.CFrame = CFrame.new(x, alto * 0.45 + piso * 4, z) * CFrame.Angles(0, 0, math.rad(90)) -- tumbado, como un plato
		plato.CanCollide = false
	end
end

local function crearArbusto(x, z)
	local tamano = azar:NextNumber(2.5, 4)
	crearParte("Arbusto", Vector3.new(tamano, tamano * 0.8, tamano), Vector3.new(x, tamano * 0.35, z), verde(), Enum.Material.Grass, Enum.PartType.Ball)
end

local function crearRoca(x, z)
	local tamano = azar:NextNumber(2, 4)
	crearParte("Roca", Vector3.new(tamano * 1.3, tamano, tamano), Vector3.new(x, tamano * 0.35, z), Color3.fromRGB(125, 125, 130), Enum.Material.Slate, Enum.PartType.Ball)
end

local function plantar(x, z)
	local tirada = azar:NextNumber()
	if tirada < 0.4 then
		crearRoble(x, z)
	elseif tirada < 0.75 then
		crearPino(x, z)
	elseif tirada < 0.92 then
		crearArbusto(x, z)
	else
		crearRoca(x, z)
	end
end

-- El bosque rodea la zona de salida: a los dos lados (por detrás de las casitas) y por detrás.
-- Por delante (donde empieza el parkour) lo dejamos libre.
local separacion = AJUSTES.separacion
for lado = -1, 1, 2 do
	for z = -96, 82, separacion do
		plantar(lado * azar:NextNumber(90, 97), z + azar:NextNumber(-3, 3))
	end
end
for x = -80, 80, separacion do
	plantar(x + azar:NextNumber(-3, 3), -azar:NextNumber(90, 97))
end

-- Y unos arbolitos y arbustos sueltos por el prado (lejos de las casas, la tienda y el camino)
for _ = 1, 14 do
	local lado = if azar:NextNumber() < 0.5 then -1 else 1
	plantar(lado * azar:NextNumber(37, 45), azar:NextNumber(-82, 70))
end

print("🌲 Bosque plantado.")
