--[[
	🌲 EL BOSQUE DE FONDO
	Hace que el parkour parezca estar EN MEDIO DE UN BOSQUE:
	  - A los dos lados de la pista van saliendo árboles altísimos (troncos y copas verdes) a medida
	    que avanzas, y se van borrando los que dejas atrás.
	  - Una neblina verde suave en el aire.
	  - Luciérnagas que flotan a tu alrededor (se ven sobre todo de noche) y hojas que caen.

	Todo se dibuja SOLO en tu pantalla (no pesa nada y no hace falta guardarlo).

	📋 DÓNDE VA: en Roblox Studio, dentro de StarterPlayer > StarterPlayerScripts,
	como "LocalScript".
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")

local jugador = Players.LocalPlayer

-- ⚙️ AJUSTES: ¡cambia estos valores y mira qué pasa!
local AJUSTES = {
	largoDeCadaTrozo = 50, -- el bosque se pone por "trozos" de esta longitud
	trozosDetras = 4, -- cuántos trozos se quedan detrás de ti
	trozosDelante = 9, -- cuántos se ponen por delante
	arbolesPorLado = 3, -- árboles en cada trozo, a cada lado
	distanciaMinima = 110, -- lo cerca que puede estar un árbol de la pista
	distanciaMaxima = 300, -- lo lejos que puede estar
	zEmpiezaElBosque = 120, -- por delante de este sitio empieza el bosque del parkour (antes está el de la salida)
	densidadNeblina = 0.22, -- 0 = nada, 0.5 = mucha
}

local carpeta = Instance.new("Folder")
carpeta.Name = "BosqueLocal"
carpeta.Parent = workspace

----------------------------------------------------------------------
-- 🌫️ LA NEBLINA VERDE
----------------------------------------------------------------------

local atmosfera = Instance.new("Atmosphere")
atmosfera.Density = AJUSTES.densidadNeblina
atmosfera.Offset = 0.2
atmosfera.Color = Color3.fromRGB(165, 205, 150)
atmosfera.Decay = Color3.fromRGB(95, 135, 85)
atmosfera.Glare = 0
atmosfera.Haze = 1.2
atmosfera.Parent = Lighting

----------------------------------------------------------------------
-- 🌳 LOS ÁRBOLES (que van saliendo según avanzas)
----------------------------------------------------------------------

-- La altura de la pista en cada sitio: la sacamos de los checkpoints que tengamos cerca
local puntos = {} -- { z = ..., y = ... } ordenados por z

local function actualizarPuntos()
	local mundo = workspace:FindFirstChild("MiMundo")
	if not mundo then
		return
	end
	local lista = {}
	for _, hijo in mundo:GetChildren() do
		if hijo:IsA("BasePart") and string.sub(hijo.Name, 1, 11) == "Checkpoint_" then
			table.insert(lista, { z = hijo.Position.Z, y = hijo.Position.Y + hijo.Size.Y / 2 })
		end
	end
	table.sort(lista, function(a, b)
		return a.z < b.z
	end)
	puntos = lista
end

local function alturaEn(z, respaldo)
	local total = #puntos
	if total == 0 then
		return respaldo
	end
	if z <= puntos[1].z then
		return puntos[1].y
	end
	if z >= puntos[total].z then
		return puntos[total].y
	end
	local bajo, alto = 1, total
	while alto - bajo > 1 do
		local medio = (bajo + alto) // 2
		if puntos[medio].z <= z then
			bajo = medio
		else
			alto = medio
		end
	end
	local a, b = puntos[bajo], puntos[alto]
	return a.y + (b.y - a.y) * (z - a.z) / (b.z - a.z)
end

local function crearParte(padre, tamano, posicion, color, material, forma)
	local parte = Instance.new("Part")
	parte.Size = tamano
	parte.Position = posicion
	parte.Color = color
	parte.Material = material
	parte.Shape = forma or Enum.PartType.Block
	parte.Anchored = true
	parte.CanCollide = false
	parte.CanTouch = false
	parte.CanQuery = false
	parte.CastShadow = false
	parte.TopSurface = Enum.SurfaceType.Smooth
	parte.BottomSurface = Enum.SurfaceType.Smooth
	parte.Parent = padre
	return parte
end

local trozos = {} -- trozos[numero] = la carpeta con los árboles de ese trozo

local function crearTrozo(numero, alturaDeRespaldo)
	local trozo = Instance.new("Folder")
	trozo.Name = "Trozo_" .. numero
	local azar = Random.new(numero * 7919 + 13) -- el mismo trozo siempre sale igual (para todos los jugadores)

	for lado = -1, 1, 2 do
		for _ = 1, AJUSTES.arbolesPorLado do
			local x = lado * azar:NextNumber(AJUSTES.distanciaMinima, AJUSTES.distanciaMaxima)
			local z = (numero + azar:NextNumber()) * AJUSTES.largoDeCadaTrozo
			local cima = alturaEn(z, alturaDeRespaldo) + azar:NextNumber(-50, 25)
			local alto = azar:NextNumber(260, 420)
			local ancho = azar:NextNumber(5, 9)

			-- El tronco, altísimo (sale de muy abajo, ¡es un bosque gigante!)
			crearParte(trozo, Vector3.new(ancho, alto, ancho), Vector3.new(x, cima - alto / 2, z), Color3.fromRGB(95, 65, 40), Enum.Material.Wood)

			-- La copa: tres bolas de hojas
			for _ = 1, 3 do
				local diametro = azar:NextNumber(45, 80)
				local verde = Color3.fromRGB(azar:NextInteger(40, 70), azar:NextInteger(120, 170), azar:NextInteger(40, 70))
				crearParte(
					trozo,
					Vector3.new(diametro, diametro, diametro),
					Vector3.new(x + azar:NextNumber(-18, 18), cima + azar:NextNumber(-10, 18), z + azar:NextNumber(-18, 18)),
					verde,
					Enum.Material.Grass,
					Enum.PartType.Ball
				)
			end
		end
	end

	trozo.Parent = carpeta
	return trozo
end

local function ponerAlDia()
	local personaje = jugador.Character
	local raiz = personaje and personaje:FindFirstChild("HumanoidRootPart")
	if not raiz then
		return
	end
	local actual = math.floor(raiz.Position.Z / AJUSTES.largoDeCadaTrozo)
	local primero = actual - AJUSTES.trozosDetras
	local ultimo = actual + AJUSTES.trozosDelante

	-- Ponemos los trozos que faltan (solo donde ya empieza el parkour)
	for numero = primero, ultimo do
		if not trozos[numero] and (numero + 1) * AJUSTES.largoDeCadaTrozo > AJUSTES.zEmpiezaElBosque then
			trozos[numero] = crearTrozo(numero, raiz.Position.Y)
		end
	end
	-- Y borramos los que ya quedan lejos
	for numero, trozo in trozos do
		if numero < primero - 1 or numero > ultimo + 1 then
			trozo:Destroy()
			trozos[numero] = nil
		end
	end
end

task.spawn(function()
	local contador = 0
	while true do
		if contador % 10 == 0 then
			actualizarPuntos() -- cada 5 segundos miramos qué checkpoints hay cerca
		end
		ponerAlDia()
		contador += 1
		task.wait(0.5)
	end
end)

----------------------------------------------------------------------
-- ✨ LUCIÉRNAGAS Y HOJAS (siguen a tu cámara)
----------------------------------------------------------------------

local camara = workspace.CurrentCamera

local function crearNube(tamano, desplazamiento)
	local nube = Instance.new("Part")
	nube.Size = tamano
	nube.Transparency = 1
	nube.Anchored = true
	nube.CanCollide = false
	nube.CanTouch = false
	nube.CanQuery = false
	nube.Parent = workspace
	RunService.RenderStepped:Connect(function()
		nube.Position = camara.CFrame.Position + desplazamiento
	end)
	return nube
end

-- Luciérnagas: puntitos amarillo-verdosos que flotan despacio
local luciernagas = Instance.new("ParticleEmitter")
luciernagas.Rate = 10
luciernagas.Lifetime = NumberRange.new(4, 6)
luciernagas.Speed = NumberRange.new(0.5, 2)
luciernagas.SpreadAngle = Vector2.new(180, 180)
luciernagas.Size = NumberSequence.new(0.5)
luciernagas.LightEmission = 1
luciernagas.Color = ColorSequence.new(Color3.fromRGB(225, 255, 120))
luciernagas.Transparency = NumberSequence.new({
	NumberSequenceKeypoint.new(0, 1),
	NumberSequenceKeypoint.new(0.2, 0.1),
	NumberSequenceKeypoint.new(0.8, 0.1),
	NumberSequenceKeypoint.new(1, 1),
})
luciernagas.Parent = crearNube(Vector3.new(70, 25, 70), Vector3.new(0, 4, 0))

-- Hojas que caen despacio
local hojas = Instance.new("ParticleEmitter")
hojas.Rate = 4
hojas.Lifetime = NumberRange.new(7, 9)
hojas.Speed = NumberRange.new(3, 6)
hojas.EmissionDirection = Enum.NormalId.Bottom
hojas.Acceleration = Vector3.new(2, -1, 1)
hojas.Rotation = NumberRange.new(0, 360)
hojas.RotSpeed = NumberRange.new(-60, 60)
hojas.Size = NumberSequence.new(0.7)
hojas.Color = ColorSequence.new(Color3.fromRGB(120, 175, 60), Color3.fromRGB(215, 140, 40))
hojas.Parent = crearNube(Vector3.new(90, 1, 90), Vector3.new(0, 40, 0))
