--[[
	🚀 CATAPULTA
	Construye una catapulta al lado de la salida.
	Cuando te subes a la plataforma verde, el brazo se mueve y... ¡te lanza por los aires
	hasta el sitio que elijas en AJUSTES (al principio, la META)!

	📋 DÓNDE VA: en Roblox Studio, dentro de ServerScriptService, como "Script".
]]

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

-- ⚙️ AJUSTES: ¡cambia estos valores y mira qué pasa!
local AJUSTES = {
	-- A dónde te lanza. Puede ser "Meta" o una plataforma, por ejemplo "Plataforma6"
	destino = "Meta",
	-- Cuánto tarda el vuelo. Más segundos = vuelo más alto y más lento
	segundosDeVuelo = 2.5,
	-- Si no encuentra el destino, te lanza hacia arriba con esta fuerza
	fuerzaHaciaArriba = 150,
	-- Dónde está la catapulta (X, Y, Z)
	posicion = Vector3.new(-16, 1, 6),
	-- Color de la madera de la catapulta
	colorMadera = Color3.fromRGB(150, 100, 60),
}

-- Esperamos a que exista la carpeta del mundo (la crea el script MiMundo)
local carpetaMundo = workspace:WaitForChild("MiMundo", 10)
local parteDestino = carpetaMundo and carpetaMundo:WaitForChild(AJUSTES.destino, 10)

local carpeta = Instance.new("Folder")
carpeta.Name = "Catapulta"
carpeta.Parent = workspace

----------------------------------------------------------------------
-- 🧰 HERRAMIENTAS
----------------------------------------------------------------------

local function crearBloque(nombre, tamano, cframe, color, material)
	local bloque = Instance.new("Part")
	bloque.Name = nombre
	bloque.Size = tamano
	bloque.CFrame = cframe
	bloque.Color = color
	bloque.Material = material or Enum.Material.Wood
	bloque.Anchored = true
	bloque.TopSurface = Enum.SurfaceType.Smooth
	bloque.BottomSurface = Enum.SurfaceType.Smooth
	bloque.Parent = carpeta
	return bloque
end

----------------------------------------------------------------------
-- 🔨 CONSTRUIMOS LA CATAPULTA
----------------------------------------------------------------------

-- La catapulta mira hacia el destino
local mirarHacia = AJUSTES.posicion + Vector3.new(0, 0, 10)
if parteDestino then
	mirarHacia = Vector3.new(parteDestino.Position.X, AJUSTES.posicion.Y, parteDestino.Position.Z)
end
local orientacion = CFrame.lookAt(AJUSTES.posicion, mirarHacia)

-- Base de madera
crearBloque("Base", Vector3.new(8, 2, 8), orientacion, AJUSTES.colorMadera)

-- Plataforma verde donde te subes
local plataforma = crearBloque(
	"PlataformaDeLanzamiento",
	Vector3.new(6, 0.6, 6),
	orientacion * CFrame.new(0, 1.3, 0),
	Color3.fromRGB(60, 230, 90),
	Enum.Material.Neon
)

-- Brazo de la catapulta (a un lado) con su cesta en la punta
local eje = orientacion * CFrame.new(4.6, 2, 3)
crearBloque("Eje", Vector3.new(1.4, 1.4, 1.4), eje, Color3.fromRGB(90, 90, 90), Enum.Material.Metal)
local brazo = crearBloque("Brazo", Vector3.new(1, 1, 9), eje, AJUSTES.colorMadera)
local cesta = crearBloque("Cesta", Vector3.new(2, 1, 2), eje, Color3.fromRGB(110, 70, 40))

-- Mueve el brazo: 0 grados = tumbado, 90 grados = de pie
local function ponerBrazo(grados)
	local cframeBrazo = eje * CFrame.Angles(math.rad(grados), 0, 0) * CFrame.new(0, 0, -4.5)
	brazo.CFrame = cframeBrazo
	cesta.CFrame = cframeBrazo * CFrame.new(0, 0.8, -4)
end

local angulo = Instance.new("NumberValue")
angulo.Value = 10
angulo.Changed:Connect(ponerBrazo)
ponerBrazo(angulo.Value)

-- Cartel encima de la catapulta
local cartel = Instance.new("BillboardGui")
cartel.Size = UDim2.fromOffset(180, 60)
cartel.StudsOffset = Vector3.new(0, 5, 0)
cartel.Parent = plataforma

local texto = Instance.new("TextLabel")
texto.Size = UDim2.fromScale(1, 1)
texto.BackgroundTransparency = 1
texto.Text = "🚀 CATAPULTA\n¡Súbete!"
texto.TextScaled = true
texto.Font = Enum.Font.FredokaOne
texto.TextColor3 = Color3.fromRGB(255, 255, 255)
texto.TextStrokeTransparency = 0
texto.Parent = cartel

----------------------------------------------------------------------
-- 💥 LANZAR AL JUGADOR
----------------------------------------------------------------------

local TIEMPO_DE_EMPUJON = 0.15 -- segundos que dura el empujón

-- Calcula la velocidad para caer justo en el destino (¡matemáticas de verdad!)
local function calcularVelocidad(desde)
	if not parteDestino then
		return Vector3.new(0, AJUSTES.fuerzaHaciaArriba, 0)
	end
	local llegada = parteDestino.Position + Vector3.new(0, parteDestino.Size.Y / 2 + 3, 0)
	local distancia = llegada - desde
	local T = AJUSTES.segundosDeVuelo
	local gravedad = workspace.Gravity
	local tiempoCayendo = T - TIEMPO_DE_EMPUJON
	local subida = 0.5 * gravedad * tiempoCayendo * tiempoCayendo / T
	return distancia / T + Vector3.new(0, subida, 0)
end

local lanzando = {} -- para no lanzar dos veces seguidas al mismo personaje

local function lanzar(personaje)
	local raiz = personaje:FindFirstChild("HumanoidRootPart")
	if not raiz then
		return
	end

	-- Despegamos del suelo
	local humanoide = personaje:FindFirstChildOfClass("Humanoid")
	if humanoide then
		humanoide:ChangeState(Enum.HumanoidStateType.Jumping)
	end

	-- Le damos un empujón muy fuerte durante un momento
	local agarre = Instance.new("Attachment")
	agarre.Parent = raiz
	local empujon = Instance.new("LinearVelocity")
	empujon.Attachment0 = agarre
	empujon.MaxForce = math.huge
	empujon.VectorVelocity = calcularVelocidad(raiz.Position)
	empujon.Parent = raiz

	-- ✨ Brillitos mientras vuela
	local brillos = Instance.new("Sparkles")
	brillos.Parent = raiz

	task.delay(TIEMPO_DE_EMPUJON, function()
		empujon:Destroy()
		agarre:Destroy()
	end)
	task.delay(AJUSTES.segundosDeVuelo + 1, function()
		brillos:Destroy()
	end)
end

plataforma.Touched:Connect(function(otro)
	local personaje = otro.Parent
	local humanoide = personaje and personaje:FindFirstChildOfClass("Humanoid")
	if not humanoide or humanoide.Health <= 0 or lanzando[personaje] then
		return
	end
	if not Players:GetPlayerFromCharacter(personaje) then
		return
	end
	lanzando[personaje] = true

	-- El brazo se levanta de golpe...
	TweenService:Create(angulo, TweenInfo.new(0.15, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Value = 100 }):Play()
	lanzar(personaje)

	-- ...y vuelve despacio a su sitio
	task.wait(1)
	TweenService:Create(angulo, TweenInfo.new(1), { Value = 10 }):Play()
	task.wait(1)
	lanzando[personaje] = nil
end)

print("🚀 ¡Catapulta lista!")
