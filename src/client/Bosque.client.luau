--[[
	🌲 EL BOSQUE DE FONDO
	Hace que el parkour parezca estar EN MEDIO DE UN BOSQUE:
	  - A los dos lados de la pista van saliendo árboles altísimos (troncos y copas verdes) a medida
	    que avanzas, y se van borrando los que dejas atrás.
	  - Una neblina verde suave en el aire.
	  - Luciérnagas que flotan a tu alrededor (se ven sobre todo de noche) y hojas que caen.
	  - EL TIEMPO DEL BOSQUE: niebla espesa por las MAÑANAS 🌫️, rayos de sol entre los árboles ☀️,
	    pájaros 🐦 que cruzan el cielo y ciervos 🦌 que pasean junto a la pista.
	    (Usa la hora del día que pone el script Noche.)

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
	nieblaDeLaManana = 0.38, -- lo que SUBE la niebla por la mañana (0 = nada)
	maximoDePajaros = 4,
	maximoDeCiervos = 2,
	segundosEntreAnimales = { 8, 16 }, -- cada cuánto sale un animal nuevo (mínimo, máximo)
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


----------------------------------------------------------------------
-- 🌫️ ☀️ EL TIEMPO: niebla por la mañana y rayos de sol
----------------------------------------------------------------------

local TweenService = game:GetService("TweenService")

local rayosDeSol = Instance.new("SunRaysEffect")
rayosDeSol.Intensity = 0
rayosDeSol.Spread = 0.7
rayosDeSol.Parent = Lighting

-- Haces de luz: columnas casi invisibles que bajan entre los árboles (se ven de día)
local haces = {}
local anclaDeHaces = Vector3.new(0, 0, -1e6)
local azar = Random.new()

for i = 1, 7 do
	local haz = Instance.new("Part")
	haz.Name = "HazDeSol"
	haz.Size = Vector3.new(azar:NextNumber(3, 7), 90, azar:NextNumber(3, 7))
	haz.Color = Color3.fromRGB(255, 240, 170)
	haz.Material = Enum.Material.Neon
	haz.Transparency = 1
	haz.Anchored = true
	haz.CanCollide = false
	haz.CanTouch = false
	haz.CanQuery = false
	haz.CastShadow = false
	haz.Parent = carpeta
	haces[i] = { parte = haz, dx = azar:NextNumber(-60, 60), dz = azar:NextNumber(-80, 80), dy = azar:NextNumber(-10, 20), giro = azar:NextNumber(-0.3, 0.3) }
end

local function raizDelJugador()
	local personaje = jugador.Character
	return personaje and personaje:FindFirstChild("HumanoidRootPart")
end

task.spawn(function()
	while true do
		local hora = Lighting.ClockTime
		-- 1 = pleno amanecer (a las 7), 0 = ya no hay niebla de mañana
		local manana = math.clamp(1 - math.abs(hora - 7) / 2.5, 0, 1)
		-- 0 = noche, 1 = día
		local dia = math.clamp(math.sin((hora - 6) / 12 * math.pi) * 1.6, 0, 1)

		TweenService:Create(atmosfera, TweenInfo.new(1), {
			Density = AJUSTES.densidadNeblina + manana * AJUSTES.nieblaDeLaManana,
			Color = Color3.fromRGB(165, 205, 150):Lerp(Color3.fromRGB(235, 238, 232), manana),
		}):Play()
		TweenService:Create(rayosDeSol, TweenInfo.new(1), { Intensity = 0.15 * dia }):Play()

		-- Los haces se ven más de día y sobre todo por la mañana
		local transparencia = 1 - (0.12 + 0.08 * manana) * dia
		local raiz = raizDelJugador()
		if raiz then
			if (raiz.Position - anclaDeHaces).Magnitude > 120 then
				anclaDeHaces = raiz.Position
			end
			for _, h in haces do
				h.parte.CFrame = CFrame.new(anclaDeHaces + Vector3.new(h.dx, h.dy, h.dz)) * CFrame.Angles(h.giro, 0, 0.25)
				h.parte.Transparency = transparencia
			end
		end
		task.wait(1)
	end
end)

----------------------------------------------------------------------
-- 🐦 🦌 LOS ANIMALES (solo se ven en tu pantalla)
----------------------------------------------------------------------

local animales = {} -- { modelo, tipo, ... }

local function pieza(modelo, nombre, tamano, cf, color, forma)
	local p = Instance.new("Part")
	p.Name = nombre
	p.Size = tamano
	p.CFrame = cf
	p.Color = color
	p.Material = Enum.Material.SmoothPlastic
	if forma then
		p.Shape = forma
	end
	p.Anchored = true
	p.CanCollide = false
	p.CanTouch = false
	p.CanQuery = false
	p.CastShadow = false
	p.Parent = modelo
	return p
end

local MARRON = Color3.fromRGB(150, 100, 55)
local CREMA = Color3.fromRGB(235, 220, 190)

-- El ciervo mira hacia -Z (hacia delante de su modelo)
local function crearCiervo(posicion)
	local m = Instance.new("Model")
	m.Name = "Ciervo"
	local base = CFrame.new(posicion)
	local cuerpo = pieza(m, "Cuerpo", Vector3.new(1.6, 1.8, 3.6), base * CFrame.new(0, 3.2, 0), MARRON)
	pieza(m, "Vientre", Vector3.new(1.3, 0.6, 3), base * CFrame.new(0, 2.6, 0), CREMA)
	pieza(m, "Cuello", Vector3.new(0.8, 2, 0.8), base * CFrame.new(0, 4.7, -1.7) * CFrame.Angles(math.rad(-25), 0, 0), MARRON)
	pieza(m, "Cabeza", Vector3.new(0.9, 0.9, 1.4), base * CFrame.new(0, 5.6, -2.3), MARRON)
	pieza(m, "Nariz", Vector3.new(0.4, 0.4, 0.3), base * CFrame.new(0, 5.5, -3.1), Color3.fromRGB(40, 30, 30))
	pieza(m, "Cola", Vector3.new(0.5, 0.5, 0.4), base * CFrame.new(0, 3.9, 1.9), Color3.fromRGB(255, 255, 255))
	for _, lado in { -1, 1 } do
		pieza(m, "Pata", Vector3.new(0.4, 2.3, 0.4), base * CFrame.new(lado * 0.55, 1.15, -1.3), MARRON)
		pieza(m, "Pata", Vector3.new(0.4, 2.3, 0.4), base * CFrame.new(lado * 0.55, 1.15, 1.3), MARRON)
		-- Cuernos: una vara con dos ramitas
		pieza(m, "Cuerno", Vector3.new(0.18, 1.6, 0.18), base * CFrame.new(lado * 0.4, 6.5, -2.2) * CFrame.Angles(0, 0, math.rad(-lado * 20)), CREMA)
		pieza(m, "Cuerno", Vector3.new(0.15, 0.9, 0.15), base * CFrame.new(lado * 0.75, 6.9, -2.2) * CFrame.Angles(0, 0, math.rad(lado * 35)), CREMA)
	end
	-- Un trocito de hierba debajo, para que no flote en el aire
	pieza(m, "Hierba", Vector3.new(5, 0.6, 8), base * CFrame.new(0, -0.3, 0), Color3.fromRGB(80, 150, 70))
	m.PrimaryPart = cuerpo
	m.Parent = carpeta
	return m
end

local function crearPajaro(posicion)
	local m = Instance.new("Model")
	m.Name = "Pajaro"
	local base = CFrame.new(posicion)
	local color = Color3.fromRGB(70 + azar:NextInteger(0, 150), 110 + azar:NextInteger(0, 100), 200)
	local cuerpo = pieza(m, "Cuerpo", Vector3.new(1, 0.9, 1.8), base, color, Enum.PartType.Ball)
	pieza(m, "Cabeza", Vector3.new(0.6, 0.6, 0.6), base * CFrame.new(0, 0.2, -1), color, Enum.PartType.Ball)
	pieza(m, "Pico", Vector3.new(0.2, 0.2, 0.4), base * CFrame.new(0, 0.15, -1.4), Color3.fromRGB(255, 190, 40))
	pieza(m, "AlaI", Vector3.new(1.8, 0.1, 0.9), base * CFrame.new(-1.2, 0.1, 0), color)
	pieza(m, "AlaD", Vector3.new(1.8, 0.1, 0.9), base * CFrame.new(1.2, 0.1, 0), color)
	m.PrimaryPart = cuerpo
	m.Parent = carpeta
	return m
end

local function contar(tipo)
	local n = 0
	for _, a in animales do
		if a.tipo == tipo then
			n += 1
		end
	end
	return n
end

local function nuevoAnimal()
	local raiz = raizDelJugador()
	if not raiz then
		return
	end
	local quePonemos = azar:NextNumber() < 0.55 and "pajaro" or "ciervo"
	local lado = azar:NextInteger(0, 1) == 0 and -1 or 1

	if quePonemos == "ciervo" and contar("ciervo") < AJUSTES.maximoDeCiervos then
		-- Pasea junto a la pista, un poco por delante de ti, mirando hacia donde va
		local x = raiz.Position.X + lado * azar:NextNumber(22, 38)
		local z = raiz.Position.Z + azar:NextNumber(40, 90)
		local sentido = azar:NextInteger(0, 1) == 0 and 1 or -1
		local modelo = crearCiervo(Vector3.new(x, raiz.Position.Y - 3.5, z))
		modelo:PivotTo(modelo:GetPivot() * CFrame.Angles(0, sentido == 1 and math.pi or 0, 0))
		table.insert(animales, { modelo = modelo, tipo = "ciervo", velocidad = Vector3.new(0, 0, sentido * azar:NextNumber(4, 7)), vive = 22, fase = azar:NextNumber(0, 6) })
	elseif quePonemos == "pajaro" and contar("pajaro") < AJUSTES.maximoDePajaros then
		-- Cruza el cielo de un lado a otro, más alto que tú
		local z = raiz.Position.Z + azar:NextNumber(-20, 80)
		local inicio = Vector3.new(raiz.Position.X - lado * 120, raiz.Position.Y + azar:NextNumber(8, 28), z)
		local modelo = crearPajaro(inicio)
		modelo:PivotTo(CFrame.lookAt(inicio, inicio + Vector3.new(lado, 0, 0)))
		table.insert(animales, { modelo = modelo, tipo = "pajaro", velocidad = Vector3.new(lado * azar:NextNumber(22, 32), 0, 0), vive = 9, fase = azar:NextNumber(0, 6) })
	end
end

task.spawn(function()
	while true do
		task.wait(azar:NextNumber(AJUSTES.segundosEntreAnimales[1], AJUSTES.segundosEntreAnimales[2]))
		nuevoAnimal()
	end
end)

RunService.Heartbeat:Connect(function(dt)
	for i = #animales, 1, -1 do
		local a = animales[i]
		a.vive -= dt
		a.fase += dt * (a.tipo == "pajaro" and 14 or 4)
		if a.vive <= 0 or not a.modelo.Parent then
			a.modelo:Destroy()
			table.remove(animales, i)
		else
			local cf = a.modelo:GetPivot()
			local nueva = cf + a.velocidad * dt
			if a.tipo == "pajaro" then
				nueva += Vector3.new(0, math.sin(a.fase * 0.3) * 0.05, 0)
				local aleteo = math.sin(a.fase) * 0.6
				local alaI = a.modelo:FindFirstChild("AlaI")
				local alaD = a.modelo:FindFirstChild("AlaD")
				a.modelo:PivotTo(nueva)
				if alaI and alaD then
					-- las alas suben y bajan alrededor del cuerpo
					alaI.CFrame = a.modelo.PrimaryPart.CFrame * CFrame.new(-0.9, 0, 0) * CFrame.Angles(0, 0, -aleteo) * CFrame.new(-0.9, 0, 0)
					alaD.CFrame = a.modelo.PrimaryPart.CFrame * CFrame.new(0.9, 0, 0) * CFrame.Angles(0, 0, aleteo) * CFrame.new(0.9, 0, 0)
				end
			else
				-- el ciervo anda con un balanceito
				a.modelo:PivotTo(nueva * CFrame.new(0, math.sin(a.fase) * 0.01, 0))
			end
		end
	end
end)
