--[[
	🏖️ LA PLAYA (y el mar con todos sus animales)
	Detrás de todo, al otro lado de la zona de salida (¡sigue el camino de madera hacia atrás!),
	hay una PLAYA de arena con palmeras, sombrillas y un MAR donde viven:
	  🦈 tiburones · 🐬 delfines · 🐋 una ballena · 🐢 tortugas · 🐠 peces payaso · 🪼 medusas
	  🐙 pulpos · 🐴 caballitos de mar · 🐡 peces globo · ⭐ estrellas de mar · 🦀 cangrejos · 🦭 focas
	Se pueden TOCAR (pulsa E: el tiburón es amistoso, el pez globo se infla, la estrella gira...)
	y se les puede hacer una FOTO 📸 con la cámara de tu casa (pulsa F).
	El agua llega hasta el pecho: puedes meterte a caminar sin peligro.

	📋 DÓNDE VA: en Roblox Studio, dentro de ServerScriptService, como "Script".
	(Las fotos las cuelga el script Album: este script solo le avisa con el atributo "PedirFotoAnimal".)
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

-- ⚙️ AJUSTES: ¡cambia estos valores y mira qué pasa!
local AJUSTES = {
	centroDelMar = Vector3.new(0, 0, -290), -- el medio del mar
	anchoDeLaPlaya = 300, -- de izquierda a derecha
	zInicioPlaya = -190, -- donde empieza la arena
	zInicioMar = -228, -- donde empieza el agua
	zFinMar = -350, -- el fondo del mar
	alturaDelAgua = 5.5, -- hasta dónde llega el agua (más = más profunda)
	distanciaParaAnimar = 260, -- los animales solo se mueven si hay un jugador así de cerca
}

local SUELO = 0.25 -- altura del suelo (arriba de todo)

local carpeta = Instance.new("Folder")
carpeta.Name = "Playa"
carpeta.Parent = workspace

local azar = Random.new(77)

----------------------------------------------------------------------
-- 🧰 HERRAMIENTAS
----------------------------------------------------------------------

local function parte(padre, nombre, tamano, cf, color, material, forma, transparencia)
	local pieza = Instance.new("Part")
	pieza.Name = nombre
	pieza.Size = tamano
	pieza.CFrame = cf
	pieza.Color = color
	pieza.Material = material or Enum.Material.SmoothPlastic
	pieza.Shape = forma or Enum.PartType.Block
	pieza.Transparency = transparencia or 0
	pieza.Anchored = true
	pieza.CanCollide = false
	pieza.CanQuery = false
	pieza.CastShadow = false
	pieza.TopSurface = Enum.SurfaceType.Smooth
	pieza.BottomSurface = Enum.SurfaceType.Smooth
	pieza.Parent = padre
	return pieza
end

local BOLA = Enum.PartType.Ball
local ID = CFrame.new()

local function avisar(jugador, texto, color)
	local pantallaJugador = jugador:FindFirstChild("PlayerGui")
	if not pantallaJugador then
		return
	end
	local viejo = pantallaJugador:FindFirstChild("AvisoPlaya")
	if viejo then
		viejo:Destroy()
	end
	local pantalla = Instance.new("ScreenGui")
	pantalla.Name = "AvisoPlaya"
	pantalla.ResetOnSpawn = false
	pantalla.Parent = pantallaJugador
	local mensaje = Instance.new("TextLabel")
	mensaje.Size = UDim2.fromOffset(440, 42)
	mensaje.Position = UDim2.new(0.5, -220, 0.2, 0)
	mensaje.BackgroundColor3 = color
	mensaje.BackgroundTransparency = 0.15
	mensaje.TextColor3 = Color3.fromRGB(255, 255, 255)
	mensaje.TextScaled = true
	mensaje.Font = Enum.Font.FredokaOne
	mensaje.Text = texto
	mensaje.Parent = pantalla
	Instance.new("UICorner", mensaje).CornerRadius = UDim.new(0, 10)
	task.delay(3, function()
		pantalla:Destroy()
	end)
end

local function cartel(padre, texto, ancho, alto, desplazamiento, maxDistancia)
	local gui = Instance.new("BillboardGui")
	gui.Size = UDim2.fromOffset(ancho, alto)
	gui.StudsOffset = desplazamiento
	gui.AlwaysOnTop = true
	gui.MaxDistance = maxDistancia or 80
	gui.Parent = padre
	local etiqueta = Instance.new("TextLabel")
	etiqueta.Size = UDim2.fromScale(1, 1)
	etiqueta.BackgroundTransparency = 1
	etiqueta.Text = texto
	etiqueta.TextScaled = true
	etiqueta.Font = Enum.Font.FredokaOne
	etiqueta.TextColor3 = Color3.fromRGB(255, 255, 255)
	etiqueta.TextStrokeTransparency = 0
	etiqueta.Parent = gui
	return gui
end

----------------------------------------------------------------------
-- 🏖️ LA ARENA, EL AGUA Y EL CAMINO
----------------------------------------------------------------------

local zMedio = (AJUSTES.zInicioPlaya + AJUSTES.zFinMar) / 2
local largoTotal = AJUSTES.zInicioPlaya - AJUSTES.zFinMar
local ARENA = Color3.fromRGB(240, 215, 150)

-- El suelo de arena (sirve también de fondo del mar)
local suelo = parte(carpeta, "Arena", Vector3.new(AJUSTES.anchoDeLaPlaya, 3, largoTotal), CFrame.new(0, SUELO - 1.5, zMedio), ARENA, Enum.Material.Sand)
suelo.CanCollide = true
suelo.CanQuery = true

-- El camino de madera desde la zona de salida hasta la playa
local largoCamino = -100 - AJUSTES.zInicioPlaya
local camino = parte(carpeta, "Camino", Vector3.new(10, 0.5, 94), CFrame.new(0, SUELO - 0.1, (-96 + AJUSTES.zInicioPlaya) / 2), Color3.fromRGB(160, 115, 70), Enum.Material.WoodPlanks)
camino.CanCollide = true
camino.CanQuery = true
local carteles = parte(carpeta, "CartelPlaya", Vector3.new(0.5, 5, 0.5), CFrame.new(6.5, 2.5, -104), Color3.fromRGB(110, 80, 50), Enum.Material.Wood)
cartel(carteles, "🏖️ ¡Playa! →  sigue el camino", 300, 50, Vector3.new(0, 3.5, 0), 200)
local cartelFinal = parte(carpeta, "CartelEntrada", Vector3.new(0.5, 5, 0.5), CFrame.new(6.5, 2.5, AJUSTES.zInicioPlaya + 3), Color3.fromRGB(110, 80, 50), Enum.Material.Wood)
cartel(cartelFinal, "🌊 ¡El mar! Mira a los animales (E = tocar, F = foto)", 380, 50, Vector3.new(0, 3.5, 0), 150)

-- El agua: azul y casi transparente. Llega a la altura del pecho y NO se hunde nadie.
local agua = parte(
	carpeta, "Agua",
	Vector3.new(AJUSTES.anchoDeLaPlaya, AJUSTES.alturaDelAgua, AJUSTES.zInicioMar - AJUSTES.zFinMar),
	CFrame.new(0, SUELO + AJUSTES.alturaDelAgua / 2, (AJUSTES.zInicioMar + AJUSTES.zFinMar) / 2),
	Color3.fromRGB(40, 150, 225), Enum.Material.Glass, nil, 0.5
)
-- La orilla: una franja de espuma blanca
parte(carpeta, "Espuma", Vector3.new(AJUSTES.anchoDeLaPlaya, 0.3, 3), CFrame.new(0, SUELO + 0.1, AJUSTES.zInicioMar + 1.5), Color3.fromRGB(245, 250, 255), Enum.Material.Neon, nil, 0.4)

-- Paredes invisibles para no caerse por los bordes (atrás y a los lados)
local function pared(tamano, posicion)
	local p = parte(carpeta, "ParedInvisible", tamano, CFrame.new(posicion), Color3.new(1, 1, 1), nil, nil, 1)
	p.CanCollide = true
	p.CanQuery = true
end
pared(Vector3.new(AJUSTES.anchoDeLaPlaya, 60, 2), Vector3.new(0, 30, AJUSTES.zFinMar - 1))
pared(Vector3.new(2, 60, largoTotal), Vector3.new(AJUSTES.anchoDeLaPlaya / 2 + 1, 30, zMedio))
pared(Vector3.new(2, 60, largoTotal), Vector3.new(-AJUSTES.anchoDeLaPlaya / 2 - 1, 30, zMedio))

----------------------------------------------------------------------
-- 🌴 DECORACIÓN DE LA ARENA
----------------------------------------------------------------------

local function palmera(x, z)
	local altura = azar:NextNumber(8, 11)
	local inclinacion = azar:NextNumber(-8, 8)
	local base = CFrame.new(x, SUELO, z)
	parte(carpeta, "Tronco", Vector3.new(0.9, altura, 0.9), base * CFrame.new(0, altura / 2, 0) * CFrame.Angles(0, 0, math.rad(inclinacion)), Color3.fromRGB(135, 100, 60), Enum.Material.Wood)
	local copa = base * CFrame.new(math.sin(math.rad(inclinacion)) * -altura, altura, 0)
	for i = 0, 5 do
		local hoja = parte(carpeta, "Hoja", Vector3.new(0.4, 0.15, 6), copa * CFrame.Angles(0, math.rad(i * 60), 0) * CFrame.Angles(math.rad(-25), 0, 0) * CFrame.new(0, 0, -3), Color3.fromRGB(60, 150, 60), Enum.Material.Grass)
		hoja.Name = "Hoja"
	end
	parte(carpeta, "Coco", Vector3.new(0.8, 0.8, 0.8), copa * CFrame.new(0.5, -0.5, 0.3), Color3.fromRGB(100, 70, 40), Enum.Material.SmoothPlastic, BOLA)
end

for i = 1, 14 do
	palmera(azar:NextNumber(-140, 140), azar:NextNumber(AJUSTES.zInicioPlaya - 2, AJUSTES.zInicioMar + 8))
end

local COLORES_SOMBRILLA = { Color3.fromRGB(235, 70, 70), Color3.fromRGB(255, 200, 50), Color3.fromRGB(80, 170, 240), Color3.fromRGB(240, 120, 190) }
for i = 1, 6 do
	local x = -75 + i * 25
	local z = azar:NextNumber(AJUSTES.zInicioPlaya - 12, AJUSTES.zInicioMar + 12)
	parte(carpeta, "PalitoSombrilla", Vector3.new(0.25, 6, 0.25), CFrame.new(x, SUELO + 3, z), Color3.fromRGB(240, 240, 240))
	parte(carpeta, "Sombrilla", Vector3.new(7, 0.6, 7), CFrame.new(x, SUELO + 6.2, z), COLORES_SOMBRILLA[(i - 1) % #COLORES_SOMBRILLA + 1], Enum.Material.Fabric, Enum.PartType.Cylinder).CFrame = CFrame.new(x, SUELO + 6.2, z) * CFrame.Angles(0, 0, math.rad(90))
	parte(carpeta, "Toalla", Vector3.new(3, 0.1, 5), CFrame.new(x + 2, SUELO + 0.05, z + 2), COLORES_SOMBRILLA[i % #COLORES_SOMBRILLA + 1], Enum.Material.Fabric)
end

-- Conchas y un castillo de arena
for i = 1, 20 do
	local concha = parte(carpeta, "Concha", Vector3.new(0.6, 0.35, 0.6), CFrame.new(azar:NextNumber(-140, 140), SUELO + 0.15, azar:NextNumber(AJUSTES.zInicioPlaya - 3, AJUSTES.zInicioMar + 2)), Color3.fromRGB(255, 225, 210), Enum.Material.SmoothPlastic, BOLA)
	concha.Name = "Concha"
end
parte(carpeta, "Castillo", Vector3.new(4, 1.5, 4), CFrame.new(40, SUELO + 0.75, -208), Color3.fromRGB(225, 195, 130), Enum.Material.Sand)
parte(carpeta, "TorreCastillo", Vector3.new(1.4, 2.5, 1.4), CFrame.new(40, SUELO + 2.7, -208), Color3.fromRGB(225, 195, 130), Enum.Material.Sand)

----------------------------------------------------------------------
-- 🐾 LOS ANIMALES: cómo se construye cada uno
----------------------------------------------------------------------

-- Todos se construyen en el centro del mundo mirando hacia -Z; luego se mueven con PivotTo.
local modelosDe = {}

modelosDe.tiburon = function(m)
	local gris, blanco = Color3.fromRGB(105, 120, 140), Color3.fromRGB(235, 240, 245)
	local cuerpo = parte(m, "Cuerpo", Vector3.new(2.4, 2.2, 7), ID, gris, nil, BOLA)
	parte(m, "Barriga", Vector3.new(2, 1.2, 6), ID * CFrame.new(0, -0.6, 0), blanco, nil, BOLA)
	parte(m, "Aleta", Vector3.new(0.25, 1.8, 1.4), ID * CFrame.new(0, 1.7, 0.4) * CFrame.Angles(math.rad(-25), 0, 0), gris)
	parte(m, "Cola", Vector3.new(0.25, 2.4, 1.4), ID * CFrame.new(0, 0.5, 3.6) * CFrame.Angles(math.rad(25), 0, 0), gris)
	parte(m, "AletaLado", Vector3.new(2.4, 0.2, 1.2), ID * CFrame.new(-1.6, -0.5, -0.6), gris)
	parte(m, "AletaLado", Vector3.new(2.4, 0.2, 1.2), ID * CFrame.new(1.6, -0.5, -0.6), gris)
	parte(m, "Ojo", Vector3.new(0.3, 0.3, 0.3), ID * CFrame.new(-0.8, 0.4, -2.7), Color3.fromRGB(10, 10, 10), nil, BOLA)
	parte(m, "Ojo", Vector3.new(0.3, 0.3, 0.3), ID * CFrame.new(0.8, 0.4, -2.7), Color3.fromRGB(10, 10, 10), nil, BOLA)
	parte(m, "Sonrisa", Vector3.new(1.2, 0.15, 0.2), ID * CFrame.new(0, -0.6, -3.2), Color3.fromRGB(60, 30, 40))
	return cuerpo
end

modelosDe.delfin = function(m)
	local azul = Color3.fromRGB(110, 150, 190)
	local cuerpo = parte(m, "Cuerpo", Vector3.new(1.6, 1.5, 4.2), ID, azul, nil, BOLA)
	parte(m, "Barriga", Vector3.new(1.3, 0.8, 3.6), ID * CFrame.new(0, -0.4, 0), Color3.fromRGB(235, 240, 245), nil, BOLA)
	parte(m, "Pico", Vector3.new(0.5, 0.45, 1.2), ID * CFrame.new(0, -0.1, -2.5), azul, nil, BOLA)
	parte(m, "Aleta", Vector3.new(0.2, 1.1, 0.8), ID * CFrame.new(0, 1, 0.3) * CFrame.Angles(math.rad(-25), 0, 0), azul)
	parte(m, "Cola", Vector3.new(2, 0.2, 0.9), ID * CFrame.new(0, 0.2, 2.5), azul)
	parte(m, "Ojo", Vector3.new(0.2, 0.2, 0.2), ID * CFrame.new(-0.5, 0.3, -1.7), Color3.fromRGB(10, 10, 10), nil, BOLA)
	parte(m, "Ojo", Vector3.new(0.2, 0.2, 0.2), ID * CFrame.new(0.5, 0.3, -1.7), Color3.fromRGB(10, 10, 10), nil, BOLA)
	return cuerpo
end

modelosDe.ballena = function(m)
	local azul, claro = Color3.fromRGB(50, 85, 135), Color3.fromRGB(190, 205, 225)
	local cuerpo = parte(m, "Cuerpo", Vector3.new(8, 5.5, 18), ID, azul, nil, BOLA)
	parte(m, "Barriga", Vector3.new(7, 3, 15), ID * CFrame.new(0, -1.6, -0.5), claro, nil, BOLA)
	parte(m, "Cola", Vector3.new(7, 0.6, 3), ID * CFrame.new(0, 0.8, 9.5) * CFrame.Angles(math.rad(-10), 0, 0), azul)
	parte(m, "AletaLado", Vector3.new(4, 0.4, 2), ID * CFrame.new(-4.6, -1.8, -3), azul)
	parte(m, "AletaLado", Vector3.new(4, 0.4, 2), ID * CFrame.new(4.6, -1.8, -3), azul)
	parte(m, "Ojo", Vector3.new(0.6, 0.6, 0.6), ID * CFrame.new(-3.8, 0.5, -6.2), Color3.fromRGB(10, 10, 10), nil, BOLA)
	parte(m, "Ojo", Vector3.new(0.6, 0.6, 0.6), ID * CFrame.new(3.8, 0.5, -6.2), Color3.fromRGB(10, 10, 10), nil, BOLA)
	return cuerpo
end

modelosDe.tortuga = function(m)
	local verde, piel = Color3.fromRGB(70, 130, 70), Color3.fromRGB(150, 175, 100)
	local cuerpo = parte(m, "Cuerpo", Vector3.new(3, 1.3, 3.6), ID, verde, nil, BOLA)
	parte(m, "Cabeza", Vector3.new(0.9, 0.8, 1), ID * CFrame.new(0, 0.1, -2.1), piel, nil, BOLA)
	for _, lado in { -1, 1 } do
		parte(m, "Aleta", Vector3.new(1.8, 0.2, 0.9), ID * CFrame.new(lado * 2, -0.3, -0.9) * CFrame.Angles(0, math.rad(lado * 25), 0), piel)
		parte(m, "Aleta", Vector3.new(1.2, 0.2, 0.7), ID * CFrame.new(lado * 1.5, -0.3, 1.4), piel)
	end
	parte(m, "Dibujo", Vector3.new(1.6, 0.2, 1.8), ID * CFrame.new(0, 0.65, 0), Color3.fromRGB(100, 160, 80), nil, BOLA)
	return cuerpo
end

modelosDe.pezpayaso = function(m)
	local naranja = Color3.fromRGB(255, 125, 30)
	local cuerpo = parte(m, "Cuerpo", Vector3.new(0.7, 0.8, 1.6), ID, naranja, nil, BOLA)
	parte(m, "Raya", Vector3.new(0.75, 0.85, 0.25), ID * CFrame.new(0, 0, -0.2), Color3.fromRGB(255, 255, 255), nil, BOLA)
	parte(m, "Cola", Vector3.new(0.1, 0.7, 0.6), ID * CFrame.new(0, 0, 0.95), naranja)
	parte(m, "Ojo", Vector3.new(0.15, 0.15, 0.15), ID * CFrame.new(-0.3, 0.15, -0.55), Color3.fromRGB(10, 10, 10), nil, BOLA)
	return cuerpo
end

modelosDe.medusa = function(m)
	local rosa = Color3.fromRGB(255, 150, 215)
	local cuerpo = parte(m, "Cuerpo", Vector3.new(2.2, 1.6, 2.2), ID, rosa, Enum.Material.Neon, BOLA, 0.35)
	for i = 0, 5 do
		local a = math.rad(i * 60)
		parte(m, "Tentaculo", Vector3.new(0.12, 2, 0.12), ID * CFrame.new(math.cos(a) * 0.7, -1.6, math.sin(a) * 0.7), rosa, Enum.Material.Neon, nil, 0.3)
	end
	return cuerpo
end

modelosDe.pulpo = function(m)
	local rojo = Color3.fromRGB(205, 75, 90)
	local cuerpo = parte(m, "Cuerpo", Vector3.new(2.2, 2.4, 2.2), ID * CFrame.new(0, 1.4, 0), rojo, nil, BOLA)
	parte(m, "Ojo", Vector3.new(0.4, 0.4, 0.3), ID * CFrame.new(-0.5, 1.5, -1), Color3.fromRGB(255, 255, 255), nil, BOLA)
	parte(m, "Ojo", Vector3.new(0.4, 0.4, 0.3), ID * CFrame.new(0.5, 1.5, -1), Color3.fromRGB(255, 255, 255), nil, BOLA)
	parte(m, "Pupila", Vector3.new(0.2, 0.2, 0.2), ID * CFrame.new(-0.5, 1.5, -1.15), Color3.fromRGB(10, 10, 10), nil, BOLA)
	parte(m, "Pupila", Vector3.new(0.2, 0.2, 0.2), ID * CFrame.new(0.5, 1.5, -1.15), Color3.fromRGB(10, 10, 10), nil, BOLA)
	for i = 0, 7 do
		local a = math.rad(i * 45)
		parte(m, "Tentaculo", Vector3.new(0.4, 0.4, 2.2), ID * CFrame.new(math.cos(a) * 1.4, 0.3, math.sin(a) * 1.4) * CFrame.Angles(0, -a + math.rad(90), 0), rojo)
	end
	return cuerpo
end

modelosDe.caballito = function(m)
	local amarillo = Color3.fromRGB(255, 205, 50)
	local cuerpo = parte(m, "Cuerpo", Vector3.new(0.7, 1.5, 0.7), ID, amarillo, nil, BOLA)
	parte(m, "Cabeza", Vector3.new(0.6, 0.6, 0.6), ID * CFrame.new(0, 0.9, -0.2), amarillo, nil, BOLA)
	parte(m, "Hocico", Vector3.new(0.2, 0.2, 0.6), ID * CFrame.new(0, 0.85, -0.6), amarillo)
	parte(m, "Cola", Vector3.new(0.2, 0.9, 0.2), ID * CFrame.new(0, -1.05, 0.2), amarillo)
	parte(m, "Aleta", Vector3.new(0.1, 0.5, 0.4), ID * CFrame.new(0, 0.2, 0.4), Color3.fromRGB(255, 130, 60))
	return cuerpo
end

modelosDe.pezglobo = function(m)
	local color = Color3.fromRGB(240, 205, 90)
	local cuerpo = parte(m, "Cuerpo", Vector3.new(1.7, 1.7, 1.9), ID, color, nil, BOLA)
	for i = 0, 7 do
		local a = math.rad(i * 45)
		parte(m, "Pincho", Vector3.new(0.1, 0.1, 0.5), ID * CFrame.new(math.cos(a) * 0.85, math.sin(a) * 0.85, 0) * CFrame.Angles(0, 0, a) * CFrame.Angles(0, math.rad(90), 0), Color3.fromRGB(150, 120, 50))
	end
	parte(m, "Ojo", Vector3.new(0.3, 0.3, 0.3), ID * CFrame.new(-0.5, 0.3, -0.8), Color3.fromRGB(10, 10, 10), nil, BOLA)
	parte(m, "Ojo", Vector3.new(0.3, 0.3, 0.3), ID * CFrame.new(0.5, 0.3, -0.8), Color3.fromRGB(10, 10, 10), nil, BOLA)
	parte(m, "Cola", Vector3.new(0.1, 0.9, 0.7), ID * CFrame.new(0, 0, 1.2), color)
	return cuerpo
end

modelosDe.estrella = function(m)
	local naranja = Color3.fromRGB(255, 140, 60)
	local cuerpo = parte(m, "Cuerpo", Vector3.new(0.9, 0.3, 0.9), ID, naranja, nil, BOLA)
	for i = 0, 4 do
		parte(m, "Brazo", Vector3.new(0.5, 0.25, 1.6), ID * CFrame.Angles(0, math.rad(i * 72), 0) * CFrame.new(0, 0, -0.9), naranja)
	end
	return cuerpo
end

modelosDe.cangrejo = function(m)
	local rojo = Color3.fromRGB(225, 70, 55)
	local cuerpo = parte(m, "Cuerpo", Vector3.new(1.6, 0.7, 1.1), ID * CFrame.new(0, 0.5, 0), rojo, nil, BOLA)
	for _, lado in { -1, 1 } do
		parte(m, "Pinza", Vector3.new(0.6, 0.4, 0.6), ID * CFrame.new(lado * 1.1, 0.7, -0.7), rojo, nil, BOLA)
		parte(m, "Brazo", Vector3.new(0.2, 0.2, 0.8), ID * CFrame.new(lado * 0.9, 0.6, -0.4) * CFrame.Angles(0, math.rad(lado * 30), 0), rojo)
		parte(m, "Patas", Vector3.new(0.2, 0.2, 1.2), ID * CFrame.new(lado * 1, 0.2, 0.2), rojo)
		parte(m, "Ojo", Vector3.new(0.2, 0.3, 0.2), ID * CFrame.new(lado * 0.3, 1, -0.4), Color3.fromRGB(10, 10, 10), nil, BOLA)
	end
	return cuerpo
end

modelosDe.foca = function(m)
	local gris = Color3.fromRGB(135, 140, 150)
	local cuerpo = parte(m, "Cuerpo", Vector3.new(2, 1.7, 4.4), ID * CFrame.new(0, 0.85, 0), gris, nil, BOLA)
	parte(m, "Cabeza", Vector3.new(1.2, 1.1, 1.3), ID * CFrame.new(0, 1.7, -1.9), gris, nil, BOLA)
	parte(m, "Hocico", Vector3.new(0.5, 0.4, 0.4), ID * CFrame.new(0, 1.55, -2.5), Color3.fromRGB(30, 30, 35), nil, BOLA)
	parte(m, "Ojo", Vector3.new(0.2, 0.2, 0.2), ID * CFrame.new(-0.35, 1.95, -2.35), Color3.fromRGB(10, 10, 10), nil, BOLA)
	parte(m, "Ojo", Vector3.new(0.2, 0.2, 0.2), ID * CFrame.new(0.35, 1.95, -2.35), Color3.fromRGB(10, 10, 10), nil, BOLA)
	parte(m, "Aleta", Vector3.new(1.6, 0.2, 0.8), ID * CFrame.new(-1.4, 0.4, -0.6), gris)
	parte(m, "Aleta", Vector3.new(1.6, 0.2, 0.8), ID * CFrame.new(1.4, 0.4, -0.6), gris)
	parte(m, "Cola", Vector3.new(1.2, 0.2, 0.8), ID * CFrame.new(0, 0.4, 2.4), gris)
	return cuerpo
end

----------------------------------------------------------------------
-- 🎬 EL MOVIMIENTO Y EL TOQUE
----------------------------------------------------------------------

local animales = {} -- cada uno: { modelo, clave, mover = function(a) -> CFrame, pausa, t, emoji, reaccion }
local contadorDeFotos = 0

local function burbuja(a, texto)
	local cuerpo = a.modelo.PrimaryPart
	local gui = Instance.new("BillboardGui")
	gui.Size = UDim2.fromOffset(110, 44)
	gui.StudsOffset = Vector3.new(0, 4, 0)
	gui.AlwaysOnTop = true
	gui.MaxDistance = 90
	gui.Parent = cuerpo
	local etiqueta = Instance.new("TextLabel")
	etiqueta.Size = UDim2.fromScale(1, 1)
	etiqueta.BackgroundTransparency = 1
	etiqueta.Text = texto
	etiqueta.TextScaled = true
	etiqueta.Parent = gui
	task.delay(2.2, function()
		gui:Destroy()
	end)
end

-- crea el animal: lo construye, le pone sus botones y lo apunta en la lista
local function nuevo(clave, nombre, escala, mover, saludo, extra)
	local modelo = Instance.new("Model")
	modelo.Name = nombre
	local cuerpo = modelosDe[clave](modelo)
	modelo.PrimaryPart = cuerpo
	if escala ~= 1 then
		for _, p in modelo:GetChildren() do
			if p:IsA("BasePart") then
				p.Size *= escala
				p.CFrame = CFrame.new(p.Position * escala) * (p.CFrame - p.CFrame.Position)
			end
		end
	end
	modelo.Parent = carpeta
	local a = { tamanoOriginal = cuerpo.Size, modelo = modelo, clave = clave, mover = mover, pausa = 0, t = azar:NextNumber(0, 50), inflado = 1, nombre = nombre }
	if extra then
		for k, v in extra do
			a[k] = v
		end
	end

	local tocar = Instance.new("ProximityPrompt")
	tocar.ActionText = "Tocar"
	tocar.ObjectText = nombre
	tocar.HoldDuration = 0
	tocar.MaxActivationDistance = 16
	tocar.RequiresLineOfSight = false
	tocar.KeyboardKeyCode = Enum.KeyCode.E
	tocar.Parent = cuerpo
	tocar.Triggered:Connect(function(jugador)
		a.pausa = 3
		burbuja(a, saludo)
		if a.alTocar then
			a.alTocar(a, jugador)
		end
		jugador:SetAttribute("Estad_animalesTocados", (jugador:GetAttribute("Estad_animalesTocados") or 0) + 1)
	end)

	local foto = Instance.new("ProximityPrompt")
	foto.ActionText = "Hacer una foto 📸"
	foto.ObjectText = nombre
	foto.HoldDuration = 0
	foto.MaxActivationDistance = 16
	foto.RequiresLineOfSight = false
	foto.KeyboardKeyCode = Enum.KeyCode.F
	foto.UIOffset = Vector2.new(0, -56)
	foto.Parent = cuerpo
	foto.Triggered:Connect(function(jugador)
		if (jugador:GetAttribute("Casa_camara") or 0) < 1 then
			avisar(jugador, "📷 Necesitas la cámara (cómprala en Mi casa → Muebles)", Color3.fromRGB(200, 90, 60))
			return
		end
		a.pausa = 2
		contadorDeFotos += 1
		jugador:SetAttribute("PedirFotoAnimal", clave .. ":" .. contadorDeFotos) -- el script Album cuelga la foto
	end)

	table.insert(animales, a)
	return a
end

local C = AJUSTES.centroDelMar
local PI2 = math.pi * 2

-- Nadar en círculos: centro, radio, vueltas por segundo (negativo = al revés), altura (y)
local function circulo(centro, radio, vel, altura, fase)
	return function(a)
		local ang = fase + a.t * vel * PI2
		local pos = Vector3.new(centro.X + math.cos(ang) * radio, SUELO + altura(a), centro.Z + math.sin(ang) * radio)
		local sentido = if vel >= 0 then 1 else -1
		local dir = Vector3.new(-math.sin(ang), 0, math.cos(ang)) * sentido
		return CFrame.lookAt(pos, pos + dir)
	end
end

local function altura(constante)
	return function()
		return constante
	end
end

-- 🦈 Tiburones
for i = 1, 3 do
	local radio = 16 + i * 9
	nuevo("tiburon", "Tiburón", 1, circulo(C, radio, (if i % 2 == 0 then -1 else 1) * (0.02 + i * 0.002), function(a)
		return 2.5 + math.sin(a.t * 0.8 + i) * 0.6
	end, i * 2.1), "¡Es amistoso! 🦈💙")
end

-- 🐬 Delfines (saltan fuera del agua)
for i = 1, 2 do
	local centro = C + Vector3.new(i == 1 and -40 or 40, 0, 15)
	nuevo("delfin", "Delfín", 1, circulo(centro, 14, 0.04 * (if i == 1 then 1 else -1), function(a)
		return 2 + math.abs(math.sin(a.t * 0.9 + i * 2)) * 7 -- sube y baja: a veces salta por encima del agua
	end, i), "¡Fiuu fiuu! 🐬🎵", {
		alTocar = function(a)
			a.t += 1.2 -- da un saltito más
		end,
	})
end

-- 🐋 La ballena (grande, lenta y lejos)
nuevo("ballena", "Ballena azul", 1, circulo(C + Vector3.new(0, 0, -30), 55, 0.007, altura(3), 0), "¡Buuuuh! 🐋🌊")

-- 🐢 Tortugas marinas
for i = 1, 2 do
	nuevo("tortuga", "Tortuga marina", 1, circulo(C + Vector3.new(i == 1 and -60 or 55, 0, 25), 11, 0.012 * (if i == 1 then 1 else -1), altura(1.6), i * 3), "¡Hola! 🐢💚")
end

-- 🐠 Peces payaso (un bancho que nada junto)
for i = 1, 6 do
	nuevo("pezpayaso", "Pez payaso", 1, circulo(C + Vector3.new(-25, 0, 40), 6 + (i % 3) * 1.4, 0.07, function(a)
		return 2 + math.sin(a.t * 2 + i) * 0.5
	end, i * 1.0), "¡Glub glub! 🐠")
end

-- 🪼 Medusas (suben y bajan despacito)
for i = 1, 4 do
	nuevo("medusa", "Medusa", 1, circulo(C + Vector3.new(-50 + i * 28, 0, -55 + (i % 2) * 20), 4, 0.02, function(a)
		return 1.8 + (math.sin(a.t * 0.6 + i * 1.7) + 1) * 1.1
	end, i), "¡Blup! 🪼✨")
end

-- 🐙 Pulpos (se quedan en el fondo moviéndose un poquito)
for i = 1, 2 do
	local pos = C + Vector3.new(i == 1 and -15 or 25, 0, 55 - i * 8)
	nuevo("pulpo", "Pulpo", 1, function(a)
		return CFrame.new(pos.X, SUELO + 0.1 + math.sin(a.t * 1.3) * 0.15, pos.Z) * CFrame.Angles(0, math.sin(a.t * 0.4) * 0.8 + i, 0)
	end, "¡Hola con 8 brazos! 🐙")
end

-- 🐴 Caballitos de mar
for i = 1, 3 do
	nuevo("caballito", "Caballito de mar", 1, circulo(C + Vector3.new(-5 + i * 10, 0, 62), 3, 0.03, function(a)
		return 2.2 + math.sin(a.t * 1.1 + i * 2) * 0.8
	end, i), "¡Hiii! 🐴")
end

-- 🐡 Peces globo (¡al tocarlos se inflan!)
for i = 1, 2 do
	nuevo("pezglobo", "Pez globo", 1, circulo(C + Vector3.new(i == 1 and 5 or -5, 0, 35), 9 + i * 3, 0.03 * (if i == 1 then 1 else -1), function(a)
		return 2.2 + math.sin(a.t + i) * 0.5
	end, i * 2), "¡Puf! 🐡", {
		alTocar = function(a)
			a.inflado = 2.2
			task.delay(2.5, function()
				a.inflado = 1
			end)
		end,
	})
end

-- ⭐ Estrellas de mar (en la orilla y en el fondo; ¡giran al tocarlas!)
for i = 1, 8 do
	local x = azar:NextNumber(-100, 100)
	local z = azar:NextNumber(AJUSTES.zInicioMar - 20, AJUSTES.zInicioMar + 12)
	local giro = azar:NextNumber(0, 6)
	nuevo("estrella", "Estrella de mar", 1.3, function(a)
		return CFrame.new(x, SUELO + 0.18, z) * CFrame.Angles(0, giro + a.giro, 0)
	end, "¡Soy una estrella! ⭐", {
		giro = 0,
		alTocar = function(a)
			-- da una vuelta entera (suave) usando el tiempo
			task.spawn(function()
				for _ = 1, 30 do
					a.giro += math.rad(12)
					task.wait(0.03)
				end
			end)
		end,
	})
end

-- 🦀 Cangrejos (andan de lado por la arena)
for i = 1, 4 do
	local x = -90 + i * 45
	local z = azar:NextNumber(AJUSTES.zInicioPlaya - 6, AJUSTES.zInicioMar + 2)
	nuevo("cangrejo", "Cangrejo", 1, function(a)
		return CFrame.new(x + math.sin(a.t * 0.5 + i) * 7, SUELO + 0.1, z)
	end, "¡Clac clac! 🦀✂️", {
		alTocar = function(a)
			a.t += 4
		end,
	})
end

-- 🦭 Focas (descansan en la orilla)
for i = 1, 2 do
	local x = i == 1 and -35 or 70
	nuevo("foca", "Foca", 1, function(a)
		return CFrame.new(x, SUELO, AJUSTES.zInicioMar + 5) * CFrame.Angles(0, math.rad(180 + math.sin(a.t * 0.3) * 10), 0)
	end, "¡Aaarf! 🦭💦")
end

-- Colocamos a todos en su sitio de salida
for _, a in animales do
	a.modelo:PivotTo(a.mover(a))
end

----------------------------------------------------------------------
-- ⏱️ EL BUCLE (solo mueve a los animales si hay alguien cerca)
----------------------------------------------------------------------

local hayAlguien = false
task.spawn(function()
	while true do
		hayAlguien = false
		for _, jugador in Players:GetPlayers() do
			local raiz = jugador.Character and jugador.Character:FindFirstChild("HumanoidRootPart")
			if raiz and (raiz.Position - Vector3.new(C.X, raiz.Position.Y, C.Z + 40)).Magnitude < AJUSTES.distanciaParaAnimar then
				hayAlguien = true
				break
			end
		end
		task.wait(1)
	end
end)

local acumulado = 0
RunService.Heartbeat:Connect(function(dt)
	acumulado += dt
	if acumulado < 1 / 30 or not hayAlguien then
		return -- (se mueven 30 veces por segundo y solo si hay alguien por aquí)
	end
	local paso = acumulado
	acumulado = 0
	for _, a in animales do
		if a.pausa > 0 then
			a.pausa -= paso
		else
			a.t += paso
		end
		local cf = a.mover(a)
		if a.inflado ~= 1 or a.escalaActual then
			-- el pez globo crece al tocarlo y luego vuelve a su tamaño (suave)
			local actual = a.escalaActual or 1
			actual += (a.inflado - actual) * math.min(1, paso * 6)
			if math.abs(actual - 1) < 0.01 and a.inflado == 1 then
				actual = 1
				a.escalaActual = nil
			else
				a.escalaActual = actual
			end
			a.modelo.PrimaryPart.Size = a.tamanoOriginal * actual
		end
		a.modelo:PivotTo(cf)
	end
end)

print("🏖️ Playa lista: ¡a por los animales!")
