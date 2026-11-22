--[[
	🗼 NIVELES (500 niveles, cada uno más difícil)
	Construye una pista larguísima de plataformas de colores. Está dividida en 500 niveles:
	  - Cada nivel empieza en un CHECKPOINT (plataforma blanca grande con su número y una farola).
	  - Si tocas la lava, te caes o te mueres, vuelves al checkpoint del último nivel que alcanzaste.
	  - Cada nivel es un poquito más difícil que el anterior:
	      · plataformas más pequeñas · saltos más largos · más plataformas por nivel
	      · más subidas · más zigzag
	      · desde el nivel 60: plataformas ROJAS que se caen al pisarlas
	      · desde el nivel 150: plataformas AZULES que se mueven de lado a lado
	  - Al llegar a un nivel nuevo ganas monedas 🪙.
	  - Al final del nivel 500 está la META 🏆. Al ganar, vuelves a empezar desde el nivel 1.
	  - Tu nivel se ve en el marcador y (con el script Guardado) se guarda para la próxima vez.

	📋 DÓNDE VA: en Roblox Studio, dentro de ServerScriptService, como "Script".
	(Usa la carpeta del mundo y el marcador que crea el script MiMundo.)
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")
local TweenService = game:GetService("TweenService")

-- ⚙️ AJUSTES: ¡cambia estos números y mira qué pasa! (Prueba primero con pocos niveles)
local AJUSTES = {
	numeroDeNiveles = 500,
	semilla = 12345, -- mismo número = mismo mundo. ¡Cámbialo y sale una pista distinta!
	inicio = Vector3.new(0, 0.5, 95), -- dónde está el checkpoint del nivel 1 (en el borde del suelo)
	recompensaPorNivel = 1, -- monedas por llegar a un nivel nuevo
	segundosParaReaparecer = 2, -- lo que tardas en volver tras caerte

	-- Dificultad: el nivel 1 usa los valores "Fácil" y el último nivel los "Difícil".
	-- Los niveles del medio van poco a poco de uno a otro.
	plataformasFacil = 3, plataformasDificil = 9, -- cuántas plataformas hay en cada nivel
	tamanoFacil = 10, tamanoDificil = 4, -- lo grande que es cada plataforma
	huecoFacil = 2.5, huecoDificil = 6.2, -- lo lejos que está la siguiente
	subidaFacil = 0.4, subidaDificil = 2.5, -- cuánto suben las plataformas
	desvioFacil = 0, desvioDificil = 9, -- cuánto zigzaguean de lado a lado

	-- A partir de qué nivel aparecen las plataformas especiales
	nivelPlataformasQueCaen = 60,
	nivelPlataformasQueSeMueven = 150,

	farolaCadaNiveles = 1, -- una farola cada tantos checkpoints (sube el número si va lento)
	nivelesPorLote = 20, -- cuántos niveles construye de golpe antes de "respirar"
}

-- Límites para que los saltos SIEMPRE se puedan hacer (no los subas mucho)
local HUECO_MAXIMO = 7 -- hueco más grande posible entre dos plataformas
local SUBIDA_MAXIMA = 4.5 -- lo más que puede subir una plataforma
local LIMITE_LADO = 22 -- lo lejos que puede zigzaguear la pista del centro

local N = math.max(AJUSTES.numeroDeNiveles, 1)

-- Reaparecer más rápido tras caerse
pcall(function()
	Players.RespawnTime = AJUSTES.segundosParaReaparecer
end)

-- Esperamos a que MiMundo cree su carpeta
local carpetaMundo = workspace:WaitForChild("MiMundo", 30)
if not carpetaMundo then
	warn("🗼 No encuentro la carpeta MiMundo. ¿Está el script MiMundo?")
	return
end

local carpeta = Instance.new("Folder")
carpeta.Name = "Niveles"
carpeta.Parent = carpetaMundo

local checkpoints = {} -- checkpoints[nivel] = la plataforma blanca de ese nivel
local nivelDe = {} -- nivelDe[jugador] = el nivel del último checkpoint que tocó
local yaAparecio = {} -- para no mover al jugador la primera vez que entra
local movibles = {} -- plataformas que se mueven
local mundoListo = false

----------------------------------------------------------------------
-- 🧰 HERRAMIENTAS
----------------------------------------------------------------------

local function lerp(a, b, t)
	return a + (b - a) * t
end

local function crearBloque(nombre, tamano, posicion, color, material, padre)
	local bloque = Instance.new("Part")
	bloque.Name = nombre
	bloque.Size = tamano
	bloque.Position = posicion
	bloque.Color = color
	bloque.Material = material
	bloque.Anchored = true
	bloque.CastShadow = false
	bloque.TopSurface = Enum.SurfaceType.Smooth
	bloque.BottomSurface = Enum.SurfaceType.Smooth
	bloque.Parent = padre
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

local function crearCartel(parte, texto, ancho, alto, desplazamiento)
	local cartel = Instance.new("BillboardGui")
	cartel.Size = UDim2.fromOffset(ancho, alto)
	cartel.StudsOffset = desplazamiento
	cartel.AlwaysOnTop = true
	cartel.MaxDistance = 150 -- solo se ve de cerca (para ir ligero con tantos niveles)
	cartel.Parent = parte

	local etiqueta = Instance.new("TextLabel")
	etiqueta.Size = UDim2.fromScale(1, 1)
	etiqueta.BackgroundTransparency = 1
	etiqueta.Text = texto
	etiqueta.TextScaled = true
	etiqueta.Font = Enum.Font.FredokaOne
	etiqueta.TextColor3 = Color3.fromRGB(255, 255, 255)
	etiqueta.TextStrokeTransparency = 0
	etiqueta.Parent = cartel
end

-- Enseña un mensajito en la pantalla de un jugador
local function avisar(jugador, texto, color)
	local pantallaJugador = jugador:FindFirstChild("PlayerGui")
	if not pantallaJugador then
		return
	end
	local viejo = pantallaJugador:FindFirstChild("AvisoNivel")
	if viejo then
		viejo:Destroy()
	end

	local pantalla = Instance.new("ScreenGui")
	pantalla.Name = "AvisoNivel"
	pantalla.ResetOnSpawn = false
	pantalla.Parent = pantallaJugador

	local mensaje = Instance.new("TextLabel")
	mensaje.Size = UDim2.fromScale(0.5, 0.09)
	mensaje.Position = UDim2.fromScale(0.5, 0.72)
	mensaje.AnchorPoint = Vector2.new(0.5, 0.5)
	mensaje.BackgroundColor3 = color
	mensaje.BackgroundTransparency = 0.1
	mensaje.TextColor3 = Color3.fromRGB(255, 255, 255)
	mensaje.TextScaled = true
	mensaje.Font = Enum.Font.FredokaOne
	mensaje.Text = texto
	mensaje.Parent = pantalla

	local esquinas = Instance.new("UICorner")
	esquinas.CornerRadius = UDim.new(0, 14)
	esquinas.Parent = mensaje

	task.delay(2.5, function()
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

local function sumarMonedas(jugador, cantidad)
	local marcador = jugador:FindFirstChild("leaderstats")
	local monedas = marcador and marcador:FindFirstChild("Monedas")
	if monedas then
		monedas.Value += cantidad
	end
end

----------------------------------------------------------------------
-- 💡 FAROLAS (se encienden cuando se hace de noche: lo hace el script Noche)
----------------------------------------------------------------------

-- "base" es el punto donde se apoya el poste. "lado" (1 o -1) es hacia dónde cuelga el brazo.
local function crearFarola(base, lado)
	local metal = Color3.fromRGB(45, 45, 55)
	crearBloque("Farola_Poste", Vector3.new(0.7, 10, 0.7), base + Vector3.new(0, 5, 0), metal, Enum.Material.Metal, carpeta)
	crearBloque("Farola_Brazo", Vector3.new(3, 0.5, 0.5), base + Vector3.new(-lado * 1.4, 10.1, 0), metal, Enum.Material.Metal, carpeta)

	local cabeza = crearBloque(
		"Farola_Luz",
		Vector3.new(1.8, 1.8, 1.8),
		base + Vector3.new(-lado * 2.8, 9.6, 0),
		Color3.fromRGB(255, 225, 150),
		Enum.Material.Neon,
		carpeta
	)
	cabeza.Shape = Enum.PartType.Ball

	local luz = Instance.new("PointLight")
	luz.Color = Color3.fromRGB(255, 214, 140)
	luz.Range = 32
	luz.Brightness = 2.5
	luz.Shadows = false
	luz.Parent = cabeza
	CollectionService:AddTag(luz, "FarolaLuz") -- el script Noche las apaga de día y las enciende de noche
end

----------------------------------------------------------------------
-- 🧭 LLEVAR AL JUGADOR A SU CHECKPOINT
----------------------------------------------------------------------

local function irAlCheckpoint(jugador)
	local personaje = jugador.Character
	local punto = checkpoints[nivelDe[jugador] or 1]
	if not personaje or not punto then
		return
	end
	personaje:PivotTo(punto.CFrame + Vector3.new(0, 4, 0))
	local raiz = personaje:FindFirstChild("HumanoidRootPart")
	if raiz then
		raiz.AssemblyLinearVelocity = Vector3.zero -- paramos cualquier caída
	end
end

local function actualizarMarcador(jugador)
	local marcador = jugador:FindFirstChild("leaderstats")
	local valor = marcador and marcador:FindFirstChild("Nivel")
	if valor then
		valor.Value = nivelDe[jugador] or 1
	end
end

local function llegarANivel(jugador, nivel)
	local actual = nivelDe[jugador]
	if not actual or nivel <= actual then
		return
	end
	nivelDe[jugador] = nivel
	jugador:SetAttribute("Nivel", nivel) -- el script Guardado lo guarda
	actualizarMarcador(jugador)
	sumarMonedas(jugador, AJUSTES.recompensaPorNivel)
	avisar(jugador, "✅ ¡Checkpoint! Nivel " .. nivel .. " de " .. N, Color3.fromRGB(40, 160, 80))
end

----------------------------------------------------------------------
-- 🧱 PIEZAS DE LOS NIVELES
----------------------------------------------------------------------

local function ponerCheckpoint(nivel, x, y, z)
	local punto = crearBloque(
		"Checkpoint_" .. nivel,
		Vector3.new(14, 1, 14),
		Vector3.new(x, y - 0.5, z),
		Color3.fromRGB(235, 245, 255),
		Enum.Material.SmoothPlastic,
		carpetaMundo
	)
	crearCartel(punto, "NIVEL " .. nivel, 150, 50, Vector3.new(0, 4, 0))

	punto.Touched:Connect(function(otro)
		local jugador = buscarJugador(otro)
		if jugador then
			llegarANivel(jugador, nivel)
		end
	end)

	if nivel % AJUSTES.farolaCadaNiveles == 0 then
		local lado = if nivel % 2 == 0 then 1 else -1
		crearFarola(Vector3.new(x + lado * 6, y, z + 4), lado)
	end
	return punto
end

-- Plataforma que se cae un momento después de pisarla (y vuelve a aparecer)
local function hacerQueCaiga(parte, colorNormal)
	local cayendo = false
	parte.Touched:Connect(function(otro)
		if cayendo or not buscarJugador(otro) then
			return
		end
		cayendo = true
		parte.Color = Color3.fromRGB(255, 60, 40)
		task.wait(0.6)
		parte.Transparency = 1
		parte.CanCollide = false
		task.wait(3)
		parte.Color = colorNormal
		parte.Transparency = 0
		parte.CanCollide = true
		cayendo = false
	end)
end

local function ponerPlataforma(nivel, numero, x, y, z, tamano)
	-- ¿Qué tipo de plataforma es? Cuanto más alto el nivel, más especiales hay.
	local tirada = Random.new(AJUSTES.semilla + nivel * 100 + numero):NextNumber()
	local probCae = 0.35 * math.clamp((nivel - AJUSTES.nivelPlataformasQueCaen) / math.max(N - AJUSTES.nivelPlataformasQueCaen, 1), 0, 1)
	local probMueve = 0.3 * math.clamp((nivel - AJUSTES.nivelPlataformasQueSeMueven) / math.max(N - AJUSTES.nivelPlataformasQueSeMueven, 1), 0, 1)

	local color = Color3.fromHSV((nivel * 0.025) % 1, 0.75, 1)
	local tipo = "normal"
	if nivel >= AJUSTES.nivelPlataformasQueCaen and tirada < probCae then
		tipo = "cae"
		color = Color3.fromRGB(255, 140, 40)
	elseif nivel >= AJUSTES.nivelPlataformasQueSeMueven and tirada < probCae + probMueve then
		tipo = "mueve"
		color = Color3.fromRGB(80, 220, 255)
	end

	local posicion = Vector3.new(x, y - 0.5, z)
	local parte = crearBloque("Plataforma_" .. nivel .. "_" .. numero, Vector3.new(tamano, 1, tamano), posicion, color, Enum.Material.Neon, carpeta)

	if tipo == "cae" then
		hacerQueCaiga(parte, color)
	elseif tipo == "mueve" then
		local azarLocal = Random.new(AJUSTES.semilla + nivel * 1000 + numero)
		table.insert(movibles, {
			parte = parte,
			origen = posicion,
			amplitud = azarLocal:NextNumber(4, 7),
			velocidad = azarLocal:NextNumber(0.9, 1.6),
			fase = azarLocal:NextNumber(0, 6.28),
		})
	end
end

-- Lava debajo de cada nivel: si te caes, la tocas y vuelves a tu checkpoint
local function crearLava(nivel, zInicio, zFin, alturaMinima)
	local largo = zFin - zInicio + 30
	local lava = crearBloque(
		"Lava_" .. nivel,
		Vector3.new(120, 1, largo),
		Vector3.new(0, alturaMinima - 30, (zInicio + zFin) / 2),
		Color3.fromRGB(255, 70, 0),
		Enum.Material.Neon,
		carpeta
	)
	lava.Touched:Connect(function(otro)
		local _, humanoide = buscarJugador(otro)
		if humanoide then
			humanoide.Health = 0
		end
	end)
end

local function ponerMeta(x, y, z)
	local meta = crearBloque("Meta", Vector3.new(16, 1, 16), Vector3.new(x, y - 0.5, z), Color3.fromRGB(255, 215, 0), Enum.Material.Neon, carpetaMundo)
	crearCartel(meta, "🏆 ¡META!", 200, 60, Vector3.new(0, 6, 0))
	crearFarola(Vector3.new(x + 7, y, z), 1)

	local yaGanaron = {} -- para no contar la misma victoria muchas veces
	meta.Touched:Connect(function(otro)
		local jugador = buscarJugador(otro)
		if not jugador or yaGanaron[jugador] or not nivelDe[jugador] then
			return
		end
		yaGanaron[jugador] = true

		local marcador = jugador:FindFirstChild("leaderstats")
		local victorias = marcador and marcador:FindFirstChild("Victorias")
		if victorias then
			victorias.Value += 1
		end
		avisar(jugador, "🏆 ¡HAS GANADO LOS " .. N .. " NIVELES! 🎉", Color3.fromRGB(200, 150, 0))

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

		task.wait(3)

		-- Vuelta a empezar desde el nivel 1
		nivelDe[jugador] = 1
		jugador:SetAttribute("Nivel", 1)
		actualizarMarcador(jugador)
		local salida = workspace:FindFirstChildWhichIsA("SpawnLocation", true)
		if jugador.Character and salida then
			jugador.Character:PivotTo(salida.CFrame + Vector3.new(0, 4, 0))
		end
		yaGanaron[jugador] = nil
	end)
end

----------------------------------------------------------------------
-- 🎲 CÓMO SE CALCULA CADA SALTO
----------------------------------------------------------------------

local azar = Random.new(AJUSTES.semilla)

-- Calcula dónde va la siguiente plataforma. "d" va de 0 (fácil) a 1 (difícil).
-- Devuelve la nueva x, la nueva altura (y) y la nueva z.
local function paso(x, y, z, tamanoActual, tamanoSiguiente, d)
	local media = (tamanoActual + tamanoSiguiente) / 2

	-- Hueco entre los bordes de las dos plataformas
	local hueco = lerp(AJUSTES.huecoFacil, AJUSTES.huecoDificil, d) * azar:NextNumber(0.75, 1.15)
	hueco = math.min(hueco, HUECO_MAXIMO)

	-- Zigzag de lado a lado
	local desvio = azar:NextNumber(-1, 1) * lerp(AJUSTES.desvioFacil, AJUSTES.desvioDificil, d)
	local nuevaX = math.clamp(x + desvio, -LIMITE_LADO, LIMITE_LADO)
	desvio = nuevaX - x

	-- Si se desvía más que el tamaño de las plataformas, el salto es en diagonal (más largo):
	-- acortamos el hueco para que siga siendo posible
	local extra = math.max(0, math.abs(desvio) - media)
	if extra > 0 then
		hueco = math.min(hueco, math.sqrt(math.max(HUECO_MAXIMO ^ 2 - extra ^ 2, 1)))
	end

	-- Subida (o, a veces, bajada)
	local subida
	if azar:NextNumber() < 0.15 then
		subida = -azar:NextNumber(0.5, 1.5)
	else
		subida = lerp(AJUSTES.subidaFacil, AJUSTES.subidaDificil, d) * azar:NextNumber(0.3, 1)
	end
	-- Cuanto más largo el hueco, menos puede subir (si no, sería imposible)
	subida = math.min(subida, SUBIDA_MAXIMA * (1 - hueco / HUECO_MAXIMO))

	return nuevaX, y + subida, z + media + hueco
end

----------------------------------------------------------------------
-- 🏗️ CONSTRUIR LOS NIVELES
----------------------------------------------------------------------

local function construirMundo()
	-- Farolas por la zona de salida, la tienda y la catapulta
	local zonaSalida = {
		Vector3.new(-9, 0, 8), Vector3.new(9, 0, 8),
		Vector3.new(-9, 0, 18), Vector3.new(9, 0, 18),
		Vector3.new(-30, 0, 4), Vector3.new(14, 0, -6), Vector3.new(34, 0, 12), Vector3.new(-30, 0, -10),
	}
	for i, posicion in zonaSalida do
		crearFarola(posicion, if posicion.X < 0 then 1 else -1)
	end

	local x, y, z = AJUSTES.inicio.X, AJUSTES.inicio.Y + 0.5, AJUSTES.inicio.Z -- y = la altura de arriba de la plataforma

	for nivel = 1, N do
		local d = (nivel - 1) / math.max(N - 1, 1) -- 0 = nivel fácil, 1 = nivel difícil
		local cantidad = math.floor(lerp(AJUSTES.plataformasFacil, AJUSTES.plataformasDificil, d) + 0.5)
		local tamano = lerp(AJUSTES.tamanoFacil, AJUSTES.tamanoDificil, d)

		checkpoints[nivel] = ponerCheckpoint(nivel, x, y, z)
		local zInicio = z - 7
		local alturaMinima = y
		local tamanoActual = 14

		for numero = 1, cantidad do
			x, y, z = paso(x, y, z, tamanoActual, tamano, d)
			ponerPlataforma(nivel, numero, x, y, z, tamano)
			tamanoActual = tamano
			alturaMinima = math.min(alturaMinima, y)
		end

		-- Último salto: hacia el checkpoint del siguiente nivel (o la meta)
		local esElUltimo = nivel == N
		local tamanoSiguiente = if esElUltimo then 16 else 14
		x, y, z = paso(x, y, z, tamanoActual, tamanoSiguiente, d * 0.8)
		alturaMinima = math.min(alturaMinima, y)

		crearLava(nivel, zInicio, z + 8, alturaMinima)
		if esElUltimo then
			ponerMeta(x, y, z)
		end

		if nivel % AJUSTES.nivelesPorLote == 0 then
			task.wait() -- respiramos un momento para no atascar el juego
		end
	end

	mundoListo = true
	print("🗼 ¡" .. N .. " niveles construidos! La meta está a " .. math.floor(z) .. " studs de la salida.")
end

----------------------------------------------------------------------
-- 👤 CADA JUGADOR
----------------------------------------------------------------------

-- Si hay un nivel guardado (lo pone el script Guardado) vamos a ese checkpoint
local function adoptarNivelGuardado(jugador)
	while not mundoListo do
		task.wait(0.25)
	end
	local guardado = jugador:GetAttribute("Nivel")
	if jugador.Parent and type(guardado) == "number" and nivelDe[jugador] and guardado > nivelDe[jugador] and checkpoints[guardado] then
		nivelDe[jugador] = guardado
		actualizarMarcador(jugador)
		irAlCheckpoint(jugador)
		avisar(jugador, "👋 ¡Sigues en el nivel " .. guardado .. "!", Color3.fromRGB(60, 100, 200))
	end
end

local function prepararJugador(jugador)
	nivelDe[jugador] = 1
	if jugador:GetAttribute("Nivel") == nil then
		jugador:SetAttribute("Nivel", 1)
	end
	yaAparecio[jugador] = jugador.Character ~= nil

	-- Cuando reaparece (porque se ha caído o ha muerto), lo llevamos a su checkpoint
	jugador.CharacterAdded:Connect(function(personaje)
		if yaAparecio[jugador] then
			personaje:WaitForChild("HumanoidRootPart")
			irAlCheckpoint(jugador)
		end
		yaAparecio[jugador] = true
	end)

	-- Columna "Nivel" en el marcador
	task.spawn(function()
		local marcador = jugador:WaitForChild("leaderstats", 30)
		if marcador and not marcador:FindFirstChild("Nivel") then
			local valor = Instance.new("IntValue")
			valor.Name = "Nivel"
			valor.Value = nivelDe[jugador] or 1
			valor.Parent = marcador
		end
	end)

	-- Nivel guardado de otras veces (puede llegar un poco más tarde)
	jugador:GetAttributeChangedSignal("Nivel"):Connect(function()
		task.spawn(adoptarNivelGuardado, jugador)
	end)
	task.spawn(adoptarNivelGuardado, jugador)
end

Players.PlayerAdded:Connect(prepararJugador)
for _, jugador in Players:GetPlayers() do
	prepararJugador(jugador)
end
Players.PlayerRemoving:Connect(function(jugador)
	nivelDe[jugador] = nil
	yaAparecio[jugador] = nil
end)

----------------------------------------------------------------------
-- 🔁 COSAS QUE PASAN SIEMPRE
----------------------------------------------------------------------

-- Plataformas azules: se mueven de lado a lado (solo las que tienen a un jugador cerca)
RunService.Heartbeat:Connect(function()
	if #movibles == 0 then
		return
	end
	local posiciones = {}
	for _, jugador in Players:GetPlayers() do
		local raiz = jugador.Character and jugador.Character:FindFirstChild("HumanoidRootPart")
		if raiz then
			table.insert(posiciones, raiz.Position)
		end
	end
	if #posiciones == 0 then
		return
	end

	local tiempo = os.clock()
	for _, m in movibles do
		for _, posicion in posiciones do
			if (posicion - m.origen).Magnitude < 250 then
				local lado = math.sin(tiempo * m.velocidad + m.fase) * m.amplitud
				m.parte.CFrame = CFrame.new(m.origen + Vector3.new(lado, 0, 0))
				break
			end
		end
	end
end)

-- Red de seguridad: si alguien cae muy por debajo de su checkpoint, vuelve a él
task.spawn(function()
	while true do
		task.wait(0.5)
		for jugador, nivel in nivelDe do
			local personaje = jugador.Character
			local humanoide = personaje and personaje:FindFirstChildOfClass("Humanoid")
			local raiz = personaje and personaje:FindFirstChild("HumanoidRootPart")
			local punto = checkpoints[nivel]
			if humanoide and raiz and punto and humanoide.Health > 0 and raiz.Position.Y < punto.Position.Y - 150 then
				humanoide.Health = 0
			end
		end
	end
end)

task.spawn(construirMundo)
