--[[
	🗼 NIVELES (500 niveles, cada uno más difícil, más largo y más alto)
	Construye una pista larguísima de plataformas de colores. Está dividida en 500 niveles:
	  - Cada nivel empieza en un CHECKPOINT (plataforma blanca con su número, una moneda,
	    una farola y un SOL BLANCO encima). Si tocas la lava, te caes o te mueres, vuelves a
	    tu último checkpoint.
	  - NO todos los niveles son iguales. Algunos tienen una forma especial (se ve en el cartel
	    del checkpoint): ⭕ CÍRCULOS en zigzag (por ejemplo el nivel 7), 🔥 CUADRADOS entre LAVA,
	    🪵 VIGAS finitas y 🗼 TORRES altísimas.
	  - Cada nivel es más difícil, más LARGO y más ALTO que el anterior:
	      · el nivel 1 es bajito y el 500 sube muchísimo (cada nivel sube un poquito más)
	      · plataformas más pequeñas y más separadas · más zigzag
	      · desde el nivel 60: plataformas NARANJAS que se caen al pisarlas
	      · desde el nivel 150: plataformas AZULES que se mueven de lado a lado
	      · desde el nivel 300: plataformas de HIELO que resbalan
	      · desde el nivel 40: plataformas VERDES trampolín que te lanzan hacia arriba
	  - Hay un TRAMO DE OBSTÁCULOS (una plataforma larga) en muchos niveles:
	      · rodillos que ruedan: en TODOS los niveles del 1 al 200 ........ ¡te matan!
	      · cubos fijos (muros bajos) desde el 10 ......................... no hacen daño
	      · charcos de lava desde el 20 ................................... ¡queman!
	      · cuadrados que se deslizan desde el 80 ......................... ¡te matan!
	      · BARRAS DE LAVA que giran desde el 250 ......................... ¡te matan!
	  - Hay LAVA debajo de todos los saltos, y PAREDES a los lados para no salirse de la pista.
	  - Monedas 🪙 por todas partes (más grandes en los checkpoints) y un COFRE SORPRESA 🎁
	    en los niveles 50, 100, 150...
	  - El checkpoint del nivel 250 es ENORME (un bloque de unos 5 metros).
	  - Al llegar a un nivel nuevo ganas monedas y sale confeti 🎉. Cada 100 niveles, ¡todos lo ven en pantalla!
	  - Al final del nivel 500 está la META 🏆. Al ganar, vuelves a empezar desde el nivel 1.
	  - Tu nivel se ve en el marcador y (con el script Guardado) se guarda para la próxima vez.
	  - Puedes volver a un checkpoint que ya hayas alcanzado (lo hace el script SaltoCheckpoint).

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
	anunciarCadaNiveles = 100, -- cada cuántos niveles se avisa a TODOS los jugadores

	-- Altura: cuántos studs sube cada nivel. El nivel 1 sube lo mínimo y el último lo máximo;
	-- los de en medio van subiendo poco a poco (cada uno un poquito más que el anterior).
	-- Más altura = más plataformas por nivel (así también es más LARGO).
	alturaPrimerNivel = 6, alturaUltimoNivel = 60,
	subidaMediaPorPaso = 3, -- cuánto sube de media cada plataforma
	plataformasMinimas = 3,

	-- Dificultad: el nivel 1 usa los valores "Fácil" y el último nivel los "Difícil".
	tamanoFacil = 10, tamanoDificil = 4, -- lo grande que es cada plataforma
	huecoFacil = 2.5, huecoDificil = 6.2, -- lo lejos que está la siguiente
	desvioFacil = 0, desvioDificil = 9, -- cuánto zigzaguean de lado a lado

	-- A partir de qué nivel aparecen las plataformas especiales
	nivelPlataformasQueCaen = 60,
	nivelPlataformasQueSeMueven = 150,
	nivelPlataformasDeHielo = 300,
	nivelTrampolines = 40, -- desde aquí hay plataformas trampolín
	fuerzaTrampolin = 85, -- lo fuerte que te lanzan hacia arriba

	-- Niveles con forma especial, para que no todos sean iguales:
	-- "circulos" = plataformas redondas en zigzag · "lava" = cuadrados pequeños entre lava ·
	-- "vigas" = tablones finos y largos · "torre" = escalera altísima con pilares
	temasFijos = { [7] = "circulos", [12] = "lava", [15] = "vigas", [20] = "torre" },
	probabilidadTema = 0.4, -- en el resto de niveles (desde el 3): de cada 10, unos 4 tienen forma especial

	-- Tramos de obstáculos: una plataforma larga con cosas que saltar
	nivelDeLosTramos = 10, -- desde qué nivel hay tramos "al azar" (antes solo hay los de rodillos)
	probabilidadTramoFacil = 0.3, probabilidadTramoDificil = 0.9, -- 0.5 = en la mitad de los niveles
	rodillosGarantizadosHasta = 200, -- hasta este nivel TODOS los niveles tienen un rodillo
	nivelCubos = 10, -- desde qué nivel aparece cada obstáculo
	nivelCharcos = 20,
	nivelRodillos = 1,
	nivelCuadrados = 80,
	nivelBarras = 250,

	-- Checkpoints
	nivelCheckpointGrande = 250, -- este nivel tiene un checkpoint ENORME
	tamanoCheckpointGrande = 18, -- 5 metros ≈ 18 studs (de ancho, de largo y de grueso)
	monedaDelCheckpoint = 5, -- lo que vale la moneda de cada checkpoint
	monedaDeLasPlataformas = 1, -- lo que vale cada moneda de las plataformas
	segundosParaQueVuelvaLaMoneda = 60,
	cofreCadaNiveles = 50, -- un cofre sorpresa cada tantos niveles
	cofreBase = 30, cofreExtra = 10, -- monedas del cofre = base + extra por cada 50 niveles (y un poco al azar)

	farolaCadaNiveles = 1, -- una farola cada tantos checkpoints (sube el número si va lento)
	nivelesPorLote = 10, -- cuántos niveles construye de golpe antes de "respirar"
}

-- Límites para que los saltos SIEMPRE se puedan hacer (no los subas mucho)
local HUECO_MAXIMO = 7 -- hueco más grande posible entre dos plataformas
local SUBIDA_MAXIMA = 4.5 -- lo más que puede subir una plataforma
local LIMITE_LADO = 22 -- lo lejos que puede zigzaguear la pista del centro
local PARED_X = LIMITE_LADO + 18 -- a qué distancia del centro están las paredes
local ANCHO_TRAMO = 12 -- lo ancho que es un tramo de obstáculos
local ZONA = 14 -- el espacio que ocupa cada obstáculo dentro de un tramo
local LAVA_GRUPO = 4 -- cada cuántas plataformas hay un trozo de lava cerca

local N = math.max(AJUSTES.numeroDeNiveles, 1)
workspace:SetAttribute("TotalNiveles", N) -- para la barra de progreso de la pantalla

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

local carpetaMonedas = Instance.new("Folder")
carpetaMonedas.Name = "Monedas"
carpetaMonedas.Parent = carpetaMundo

local checkpoints = {} -- checkpoints[nivel] = la plataforma blanca de ese nivel
local nivelDe = {} -- nivelDe[jugador] = el checkpoint donde reaparece
local nivelMaximo = {} -- nivelMaximo[jugador] = el nivel más alto que ha alcanzado
local yaAparecio = {} -- para no mover al jugador la primera vez que entra
local teletransportando = {} -- jugadores que se están moviendo a un checkpoint
local animados = {} -- cosas que se mueven: { origen = Vector3, mover = function(tiempo) }
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

-- Hace que una parte mate a quien la toque (lava, rodillos, barras...)
local function hacerMortal(parte)
	parte.Touched:Connect(function(otro)
		local _, humanoide = buscarJugador(otro)
		if humanoide then
			humanoide.Health = 0
		end
	end)
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

-- Enseña un cartel en la pantalla de un jugador y lo hace desaparecer solo
local function mostrarCartel(jugador, nombre, texto, color, alturaEnPantalla, segundos)
	local pantallaJugador = jugador:FindFirstChild("PlayerGui")
	if not pantallaJugador then
		return
	end
	local viejo = pantallaJugador:FindFirstChild(nombre)
	if viejo then
		viejo:Destroy()
	end

	local pantalla = Instance.new("ScreenGui")
	pantalla.Name = nombre
	pantalla.ResetOnSpawn = false
	pantalla.Parent = pantallaJugador

	local mensaje = Instance.new("TextLabel")
	mensaje.Size = UDim2.fromScale(0.55, 0.09)
	mensaje.Position = UDim2.fromScale(0.5, alturaEnPantalla)
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

	task.delay(segundos, function()
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

local function avisar(jugador, texto, color)
	mostrarCartel(jugador, "AvisoNivel", texto, color, 0.72, 2.5)
end

-- Un mensaje grande para TODOS los jugadores
local function anunciarATodos(texto)
	print("📣 " .. texto)
	for _, jugador in Players:GetPlayers() do
		mostrarCartel(jugador, "AnuncioNivel", texto, Color3.fromRGB(190, 130, 0), 0.3, 6)
	end
end

local function sumarMonedas(jugador, cantidad)
	local marcador = jugador:FindFirstChild("leaderstats")
	local monedas = marcador and marcador:FindFirstChild("Monedas")
	if monedas then
		monedas.Value += cantidad
	end
end

----------------------------------------------------------------------
-- 💡 FAROLAS, ☀️ SOL Y 🪙 MONEDAS
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

-- Un sol BLANCO brillante flotando encima de un checkpoint
local function ponerSol(x, y, z)
	local blanco = Color3.fromRGB(255, 255, 255)
	local sol = crearBloque("Sol", Vector3.new(4, 4, 4), Vector3.new(x, y + 18, z), blanco, Enum.Material.Neon, carpeta)
	sol.Shape = Enum.PartType.Ball
	sol.CanCollide = false
	local halo = crearBloque("SolHalo", Vector3.new(9, 9, 9), Vector3.new(x, y + 18, z), blanco, Enum.Material.Neon, carpeta)
	halo.Shape = Enum.PartType.Ball
	halo.Transparency = 0.85
	halo.CanCollide = false
end

-- Una moneda que se recoge al tocarla (y vuelve a aparecer). Gira en la pantalla de cada jugador
-- gracias al script GirarMonedas.
local function crearMoneda(nombre, posicion, valor)
	local moneda = crearBloque(nombre, Vector3.new(0.5, 3, 3), posicion, Color3.fromRGB(255, 200, 0), Enum.Material.Neon, carpetaMonedas)
	moneda.Shape = Enum.PartType.Cylinder
	moneda.CanCollide = false
	CollectionService:AddTag(moneda, "MonedaGiratoria")

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
		sumarMonedas(jugador, valor)
		task.delay(AJUSTES.segundosParaQueVuelvaLaMoneda, function()
			moneda.Transparency = 0
			activa = true
		end)
	end)
end

-- Un cofre sorpresa con monedas (cada jugador lo abre una sola vez)
local function ponerCofre(nivel, x, y, z)
	local base = crearBloque("Cofre_" .. nivel, Vector3.new(4, 2.4, 2.6), Vector3.new(x - 4.5, y + 1.2, z - 3), Color3.fromRGB(140, 90, 50), Enum.Material.Wood, carpeta)
	crearBloque("CofreTapa_" .. nivel, Vector3.new(4.2, 0.9, 2.8), Vector3.new(x - 4.5, y + 2.85, z - 3), Color3.fromRGB(255, 200, 0), Enum.Material.Neon, carpeta)

	local chispas = Instance.new("ParticleEmitter")
	chispas.Enabled = false
	chispas.Rate = 0
	chispas.Lifetime = NumberRange.new(0.8, 1.4)
	chispas.Speed = NumberRange.new(8, 16)
	chispas.SpreadAngle = Vector2.new(180, 180)
	chispas.Color = ColorSequence.new(Color3.fromRGB(255, 220, 80))
	chispas.Size = NumberSequence.new(0.6)
	chispas.Parent = base

	local boton = Instance.new("ProximityPrompt")
	boton.ActionText = "Abrir cofre"
	boton.ObjectText = "🎁 Cofre sorpresa"
	boton.HoldDuration = 0.5
	boton.MaxActivationDistance = 10
	boton.RequiresLineOfSight = false
	boton.Parent = base

	boton.Triggered:Connect(function(jugador)
		local atributo = "Cofre_" .. nivel -- el script Guardado se acuerda de los cofres abiertos
		if jugador:GetAttribute(atributo) then
			avisar(jugador, "Ya has abierto este cofre 🎁", Color3.fromRGB(90, 90, 120))
			return
		end
		local monedas = math.floor((AJUSTES.cofreBase + nivel / AJUSTES.cofreCadaNiveles * AJUSTES.cofreExtra) * Random.new():NextNumber(0.8, 1.5))
		jugador:SetAttribute(atributo, true)
		sumarMonedas(jugador, monedas)
		chispas:Emit(40)
		avisar(jugador, "🎁 ¡Cofre sorpresa! +" .. monedas .. " monedas", Color3.fromRGB(200, 150, 0))
	end)
end

----------------------------------------------------------------------
-- 🧭 CHECKPOINTS Y NIVELES DE CADA JUGADOR
----------------------------------------------------------------------

local function irAlCheckpoint(jugador)
	local punto = checkpoints[nivelDe[jugador] or 1]
	if not punto or not jugador.Character then
		return
	end
	teletransportando[jugador] = true

	-- Si el mundo se carga por trozos (StreamingEnabled), pedimos que cargue la zona de destino
	pcall(function()
		jugador:RequestStreamAroundAsync(punto.Position, 5)
	end)

	local personaje = jugador.Character
	if personaje and personaje.Parent then
		personaje:PivotTo(punto.CFrame + Vector3.new(0, punto.Size.Y / 2 + 4, 0))
		local raiz = personaje:FindFirstChild("HumanoidRootPart")
		if raiz then
			raiz.AssemblyLinearVelocity = Vector3.zero -- paramos cualquier caída
		end
	end
	teletransportando[jugador] = nil
end

local function actualizarMarcador(jugador)
	local marcador = jugador:FindFirstChild("leaderstats")
	local valor = marcador and marcador:FindFirstChild("Nivel")
	if valor then
		valor.Value = nivelMaximo[jugador] or 1
	end
end

-- Una explosión de confeti de colores en un checkpoint
local function lanzarConfeti(punto)
	if not punto then
		return
	end
	local confeti = punto:FindFirstChild("Confeti")
	if not confeti then
		confeti = Instance.new("ParticleEmitter")
		confeti.Name = "Confeti"
		confeti.Enabled = false
		confeti.Rate = 0
		confeti.Lifetime = NumberRange.new(1.5, 2.5)
		confeti.Speed = NumberRange.new(20, 40)
		confeti.SpreadAngle = Vector2.new(60, 60)
		confeti.EmissionDirection = Enum.NormalId.Top
		confeti.Acceleration = Vector3.new(0, -25, 0)
		confeti.Size = NumberSequence.new(0.7)
		confeti.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 80, 80)),
			ColorSequenceKeypoint.new(0.33, Color3.fromRGB(255, 220, 60)),
			ColorSequenceKeypoint.new(0.66, Color3.fromRGB(80, 220, 120)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(80, 160, 255)),
		})
		confeti.Parent = punto
	end
	confeti:Emit(40)
end

-- Se llama al tocar el checkpoint de un nivel
local function llegarANivel(jugador, nivel)
	local actual = nivelDe[jugador]
	if not actual or nivel == actual then
		return
	end
	nivelDe[jugador] = nivel -- ahora reapareces aquí

	if nivel > nivelMaximo[jugador] then
		nivelMaximo[jugador] = nivel
		jugador:SetAttribute("Nivel", nivel) -- el script Guardado lo guarda
		actualizarMarcador(jugador)
		sumarMonedas(jugador, AJUSTES.recompensaPorNivel)
		avisar(jugador, "✅ ¡Checkpoint! Nivel " .. nivel .. " de " .. N, Color3.fromRGB(40, 160, 80))
		lanzarConfeti(checkpoints[nivel])
		if nivel % AJUSTES.anunciarCadaNiveles == 0 then
			anunciarATodos("🎉 ¡" .. jugador.DisplayName .. " ha llegado al nivel " .. nivel .. "!")
		end
	else
		avisar(jugador, "📍 Checkpoint del nivel " .. nivel, Color3.fromRGB(60, 100, 200))
	end
end

-- Volver a un checkpoint que ya has alcanzado (lo pide el script SaltoCheckpoint)
local function saltarANivel(jugador, nivel)
	if type(nivel) ~= "number" or not nivelMaximo[jugador] then
		return
	end
	nivel = math.floor(nivel)
	if nivel < 1 or nivel > nivelMaximo[jugador] or not checkpoints[nivel] then
		return
	end
	nivelDe[jugador] = nivel
	irAlCheckpoint(jugador)
	avisar(jugador, "🚀 ¡Has saltado al nivel " .. nivel .. "!", Color3.fromRGB(60, 100, 200))
end

----------------------------------------------------------------------
-- 🧱 PIEZAS DE LOS NIVELES
----------------------------------------------------------------------

-- El checkpoint del nivel 250 es un bloque enorme; los demás son planos
local function tamanoDeCheckpoint(nivel)
	if nivel == AJUSTES.nivelCheckpointGrande then
		local grande = AJUSTES.tamanoCheckpointGrande
		return Vector3.new(grande, grande, grande)
	end
	return Vector3.new(14, 1, 14)
end

-- Cómo es cada nivel: "normal" o una forma especial
local NOMBRES_TEMA = {
	circulos = "⭕ Círculos",
	lava = "🔥 Cuadrados en la lava",
	vigas = "🪵 Vigas",
	torre = "🗼 Torre",
}
local TEMAS = { "circulos", "lava", "vigas", "torre" }

local function temaDelNivel(nivel)
	local fijo = AJUSTES.temasFijos[nivel]
	if fijo then
		return fijo
	end
	if nivel < 3 then
		return "normal" -- los primeros niveles son para aprender
	end
	local azarTema = Random.new(AJUSTES.semilla + nivel * 313)
	if azarTema:NextNumber() < AJUSTES.probabilidadTema then
		return TEMAS[azarTema:NextInteger(1, #TEMAS)]
	end
	return "normal"
end

-- "y" es la altura de ARRIBA de la plataforma
local function ponerCheckpoint(nivel, x, y, z, tamano, tema)
	local punto = crearBloque(
		"Checkpoint_" .. nivel,
		tamano,
		Vector3.new(x, y - tamano.Y / 2, z),
		Color3.fromRGB(235, 245, 255),
		Enum.Material.SmoothPlastic,
		carpetaMundo
	)
	local nombreTema = NOMBRES_TEMA[tema]
	if nombreTema then
		crearCartel(punto, "NIVEL " .. nivel .. "\n" .. nombreTema, 220, 90, Vector3.new(0, tamano.Y / 2 + 5, 0))
	else
		crearCartel(punto, "NIVEL " .. nivel, 150, 50, Vector3.new(0, tamano.Y / 2 + 4, 0))
	end

	punto.Touched:Connect(function(otro)
		local jugador = buscarJugador(otro)
		if jugador then
			llegarANivel(jugador, nivel)
		end
	end)

	if nivel % AJUSTES.farolaCadaNiveles == 0 then
		local lado = if nivel % 2 == 0 then 1 else -1
		crearFarola(Vector3.new(x + lado * (tamano.X / 2 - 1), y, z + 4), lado)
	end
	ponerSol(x, y, z)
	crearMoneda("MonedaCheckpoint_" .. nivel, Vector3.new(x, y + 2.5, z - 4), AJUSTES.monedaDelCheckpoint)
	if nivel % AJUSTES.cofreCadaNiveles == 0 then
		ponerCofre(nivel, x, y, z)
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

local ultimoRebote = {}

-- Trampolín: te lanza hacia arriba
local function rebotar(jugador, personaje)
	local raiz = personaje:FindFirstChild("HumanoidRootPart")
	if not raiz or (ultimoRebote[jugador] or 0) + 0.6 > os.clock() then
		return
	end
	ultimoRebote[jugador] = os.clock()
	local agarre = Instance.new("Attachment")
	agarre.Parent = raiz
	local empujon = Instance.new("LinearVelocity")
	empujon.Attachment0 = agarre
	empujon.MaxForce = math.huge
	local velocidad = raiz.AssemblyLinearVelocity
	empujon.VectorVelocity = Vector3.new(velocidad.X, AJUSTES.fuerzaTrampolin, velocidad.Z)
	empujon.Parent = raiz
	task.delay(0.15, function()
		empujon:Destroy()
		agarre:Destroy()
	end)
end

-- "ancho" es de lado a lado y "largo" hacia delante. "tema" es la forma del nivel.
local function ponerPlataforma(nivel, numero, x, y, z, ancho, largo, tema)
	-- ¿Qué tipo de plataforma es? Cuanto más alto el nivel, más especiales hay.
	-- (Los niveles con forma especial usan plataformas normales.)
	local tirada = Random.new(AJUSTES.semilla + nivel * 100 + numero):NextNumber()
	local function probabilidad(desde, maximo)
		return maximo * math.clamp((nivel - desde) / math.max(N - desde, 1), 0, 1)
	end

	local color = Color3.fromHSV((nivel * 0.025) % 1, 0.75, 1)
	local material = Enum.Material.Neon
	local tipo = "normal"
	if tema == "normal" then
		local probCae = probabilidad(AJUSTES.nivelPlataformasQueCaen, 0.3)
		local probMueve = probabilidad(AJUSTES.nivelPlataformasQueSeMueven, 0.25)
		local probHielo = probabilidad(AJUSTES.nivelPlataformasDeHielo, 0.2)
		local probTrampolin = if nivel >= AJUSTES.nivelTrampolines then 0.1 else 0
		if nivel >= AJUSTES.nivelPlataformasQueCaen and tirada < probCae then
			tipo = "cae"
			color = Color3.fromRGB(255, 140, 40)
		elseif nivel >= AJUSTES.nivelPlataformasQueSeMueven and tirada < probCae + probMueve then
			tipo = "mueve"
			color = Color3.fromRGB(80, 220, 255)
		elseif nivel >= AJUSTES.nivelPlataformasDeHielo and tirada < probCae + probMueve + probHielo then
			tipo = "hielo"
			color = Color3.fromRGB(190, 235, 255)
			material = Enum.Material.Ice
		elseif tirada < probCae + probMueve + probHielo + probTrampolin then
			tipo = "trampolin"
			color = Color3.fromRGB(60, 255, 100)
		end
	end

	local nombre = "Plataforma_" .. nivel .. "_" .. numero
	local posicion = Vector3.new(x, y - 0.5, z)
	local parte
	if tema == "circulos" then
		-- Un disco plano: el cilindro está "de pie" y lo tumbamos
		parte = crearBloque(nombre, Vector3.new(1, ancho, ancho), posicion, color, material, carpeta)
		parte.Shape = Enum.PartType.Cylinder
		parte.CFrame = CFrame.new(posicion) * CFrame.Angles(0, 0, math.rad(90))
	else
		parte = crearBloque(nombre, Vector3.new(ancho, 1, largo), posicion, color, material, carpeta)
	end

	if tipo == "cae" then
		hacerQueCaiga(parte, color)
	elseif tipo == "hielo" then
		-- Casi sin rozamiento: ¡resbala! (densidad, rozamiento, rebote, peso del rozamiento, peso del rebote)
		parte.CustomPhysicalProperties = PhysicalProperties.new(0.5, 0, 0, 100, 1)
	elseif tipo == "trampolin" then
		parte.Touched:Connect(function(otro)
			local jugador = buscarJugador(otro)
			if jugador and jugador.Character then
				rebotar(jugador, jugador.Character)
			end
		end)
	elseif tipo == "mueve" then
		local azarLocal = Random.new(AJUSTES.semilla + nivel * 1000 + numero)
		local amplitud = azarLocal:NextNumber(4, 7)
		local velocidad = azarLocal:NextNumber(0.9, 1.6)
		local fase = azarLocal:NextNumber(0, 6.28)
		table.insert(animados, {
			origen = posicion,
			mover = function(tiempo)
				parte.CFrame = CFrame.new(posicion + Vector3.new(math.sin(tiempo * velocidad + fase) * amplitud, 0, 0))
			end,
		})
	end

	if tema == "lava" then
		-- Un charco de lava casi a ras de la plataforma: ¡es un cuadrado en medio de la lava!
		-- (De largo solo sobresale un poquito, para no tapar el siguiente salto.)
		local lava = crearBloque(
			"LavaPlana_" .. nivel .. "_" .. numero,
			Vector3.new(ancho + 16, 0.5, largo + 1),
			Vector3.new(x, y - 0.8, z),
			Color3.fromRGB(255, 90, 0),
			Enum.Material.Neon,
			carpeta
		)
		hacerMortal(lava)
	elseif tema == "torre" then
		-- Un pilar altísimo debajo
		crearBloque("Pilar_" .. nivel .. "_" .. numero, Vector3.new(3, 40, 3), Vector3.new(x, y - 21, z), Color3.fromRGB(110, 110, 120), Enum.Material.Concrete, carpeta)
	end

	-- Una moneda encima de una de cada dos plataformas
	if numero % 2 == 0 then
		crearMoneda("Moneda_" .. nivel .. "_" .. numero, Vector3.new(x, y + 3, z), AJUSTES.monedaDeLasPlataformas)
	end
end

----------------------------------------------------------------------
-- 🚧 TRAMOS DE OBSTÁCULOS
----------------------------------------------------------------------

local COLOR_PELIGRO = Color3.fromRGB(255, 50, 50)
local COLOR_LAVA = Color3.fromRGB(255, 90, 0)

-- Qué obstáculos hay en un nivel, con "peso" (los más nuevos salen más)
local function obstaculosDisponibles(nivel)
	local lista = {}
	if nivel >= AJUSTES.nivelCubos then
		table.insert(lista, { "cubo", 0.5 })
	end
	if nivel >= AJUSTES.nivelCharcos then
		table.insert(lista, { "charco", 1 })
	end
	if nivel >= AJUSTES.nivelRodillos then
		table.insert(lista, { "rodillo", 2 })
	end
	if nivel >= AJUSTES.nivelCuadrados then
		table.insert(lista, { "cuadrado", 2 })
	end
	if nivel >= AJUSTES.nivelBarras then
		table.insert(lista, { "barra", 3 })
	end
	return lista
end

local function elegirObstaculo(lista, azarLocal)
	local total = 0
	for _, elemento in lista do
		total += elemento[2]
	end
	local tirada = azarLocal:NextNumber() * total
	for _, elemento in lista do
		tirada -= elemento[2]
		if tirada <= 0 then
			return elemento[1]
		end
	end
	return lista[#lista][1]
end

-- Un obstáculo en el centro (x, y, zc). "y" es la altura de arriba de la plataforma.
local function ponerObstaculo(tipo, nombre, x, y, zc, d, azarLocal)
	local fase = azarLocal:NextNumber(0, 6.28)

	if tipo == "cubo" then
		-- Un muro bajo de lado a lado: hay que saltarlo (no hace daño)
		local alto = lerp(2, 3.5, d)
		crearBloque("Cubo_" .. nombre, Vector3.new(ANCHO_TRAMO, alto, 2), Vector3.new(x, y + alto / 2, zc), Color3.fromRGB(150, 150, 160), Enum.Material.Concrete, carpeta)
	elseif tipo == "charco" then
		-- Un charco de lava de lado a lado: hay que saltarlo
		local largo = lerp(3, 6, d)
		local charco = crearBloque("Charco_" .. nombre, Vector3.new(ANCHO_TRAMO, 0.4, largo), Vector3.new(x, y + 0.2, zc), COLOR_LAVA, Enum.Material.Neon, carpeta)
		charco.CanCollide = false
		hacerMortal(charco)
	elseif tipo == "rodillo" then
		-- Un rodillo que va y viene rodando por el tramo: hay que saltarlo
		local diametro = lerp(3, 4.5, d)
		local radio = diametro / 2
		local rodillo = crearBloque("Rodillo_" .. nombre, Vector3.new(ANCHO_TRAMO - 0.5, diametro, diametro), Vector3.new(x, y + radio, zc), COLOR_PELIGRO, Enum.Material.Neon, carpeta)
		rodillo.Shape = Enum.PartType.Cylinder
		rodillo.CanCollide = false
		hacerMortal(rodillo)
		local velocidad = lerp(1.2, 2.4, d)
		table.insert(animados, {
			origen = Vector3.new(x, y, zc),
			mover = function(tiempo)
				local desplazamiento = math.sin(tiempo * velocidad + fase) * 5
				rodillo.CFrame = CFrame.new(x, y + radio, zc + desplazamiento) * CFrame.Angles(desplazamiento / radio, 0, 0)
			end,
		})
	elseif tipo == "cuadrado" then
		-- Un cuadrado que se desliza de lado a lado: salta por encima o esquívalo
		local lado = lerp(3, 4.5, d)
		local cuadrado = crearBloque("Cuadrado_" .. nombre, Vector3.new(lado, lado, lado), Vector3.new(x, y + lado / 2, zc), COLOR_PELIGRO, Enum.Material.Neon, carpeta)
		cuadrado.CanCollide = false
		hacerMortal(cuadrado)
		local velocidad = lerp(1.2, 2.4, d)
		local recorrido = ANCHO_TRAMO / 2 - lado / 2 - 0.2
		table.insert(animados, {
			origen = Vector3.new(x, y, zc),
			mover = function(tiempo)
				cuadrado.CFrame = CFrame.new(x + math.sin(tiempo * velocidad + fase) * recorrido, y + lado / 2, zc)
			end,
		})
	elseif tipo == "barra" then
		-- Una barra de lava que gira como una hélice: hay que saltarla cuando pasa
		local barra = crearBloque("Barra_" .. nombre, Vector3.new(ANCHO_TRAMO - 1, 1.2, 1.2), Vector3.new(x, y + 0.7, zc), COLOR_LAVA, Enum.Material.Neon, carpeta)
		barra.CanCollide = false
		hacerMortal(barra)
		local velocidad = lerp(1.2, 2.4, d) * (if azarLocal:NextNumber() < 0.5 then 1 else -1)
		table.insert(animados, {
			origen = Vector3.new(x, y, zc),
			mover = function(tiempo)
				barra.CFrame = CFrame.new(x, y + 0.7, zc) * CFrame.Angles(0, tiempo * velocidad + fase, 0)
			end,
		})
	end

	-- Una moneda flotando encima: ¡se coge al saltar el obstáculo!
	crearMoneda("MonedaObstaculo_" .. nombre, Vector3.new(x, y + 6, zc), AJUSTES.monedaDeLasPlataformas)
end

-- Una plataforma larga con "cantidad" obstáculos, uno detrás de otro
local function ponerTramo(nivel, x, y, z, largo, cantidad, d, forzarRodillo)
	local azarLocal = Random.new(AJUSTES.semilla + nivel * 10007)
	local lista = obstaculosDisponibles(nivel)
	if #lista == 0 then
		lista = { { "rodillo", 1 } }
	end
	crearBloque("Tramo_" .. nivel, Vector3.new(ANCHO_TRAMO, 1, largo), Vector3.new(x, y - 0.5, z), Color3.fromHSV((nivel * 0.025) % 1, 0.5, 0.9), Enum.Material.Neon, carpeta)

	for i = 1, cantidad do
		local zc = z - largo / 2 + 6 + ZONA * (i - 0.5)
		local tipo = if i == 1 and forzarRodillo then "rodillo" else elegirObstaculo(lista, azarLocal)
		ponerObstaculo(tipo, nivel .. "_" .. i, x, y, zc, d, azarLocal)
	end
end

----------------------------------------------------------------------
-- 🔥 LAVA Y PAREDES
----------------------------------------------------------------------

-- Lava muy abajo de cada nivel: si te caes, la tocas y vuelves a tu checkpoint
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
	hacerMortal(lava)
end

-- Lava cerquita, justo debajo de los saltos (un trozo cada pocas plataformas)
local function crearLavaCerca(nivel, piezas)
	for primera = 1, #piezas, LAVA_GRUPO do
		local ultima = math.min(primera + LAVA_GRUPO - 1, #piezas)
		local alturaMinima = piezas[primera].y
		for i = primera, ultima do
			alturaMinima = math.min(alturaMinima, piezas[i].y)
		end
		local zInicio = piezas[primera].z - piezas[primera].mz - 4
		local zFin = piezas[ultima].z + piezas[ultima].mz + (if ultima == #piezas then 10 else 4)
		local lava = crearBloque(
			"LavaCerca_" .. nivel .. "_" .. primera,
			Vector3.new(PARED_X * 2, 1, zFin - zInicio),
			Vector3.new(0, alturaMinima - 9, (zInicio + zFin) / 2),
			COLOR_LAVA,
			Enum.Material.Neon,
			carpeta
		)
		hacerMortal(lava)
	end
end

-- Paredes altas y transparentes a los dos lados de la pista, para no salirse
local function crearParedes(nivel, zInicio, zFin, alturaMinima, alturaMaxima)
	local alto = (alturaMaxima - alturaMinima) + 140
	for _, lado in { -1, 1 } do
		local pared = crearBloque(
			"Pared_" .. nivel .. "_" .. lado,
			Vector3.new(1, alto, zFin - zInicio),
			Vector3.new(lado * PARED_X, alturaMinima - 20 + alto / 2, (zInicio + zFin) / 2),
			Color3.fromRGB(150, 200, 255),
			Enum.Material.Glass,
			carpeta
		)
		pared.Transparency = 0.75
		pared.CanTouch = false
	end
end

local function ponerMeta(x, y, z)
	local meta = crearBloque("Meta", Vector3.new(16, 1, 16), Vector3.new(x, y - 0.5, z), Color3.fromRGB(255, 215, 0), Enum.Material.Neon, carpetaMundo)
	crearCartel(meta, "🏆 ¡META!", 200, 60, Vector3.new(0, 6, 0))
	crearFarola(Vector3.new(x + 7, y, z), 1)
	ponerSol(x, y, z)

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
		anunciarATodos("🏆 ¡" .. jugador.DisplayName .. " ha ganado los " .. N .. " niveles! 🎉")

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
		nivelMaximo[jugador] = 1
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

-- Reparte la altura de un nivel entre sus saltos (unos suben más y otros menos)
local function repartirSubida(altura, pasos, azarLocal, variacion)
	local pesos = {}
	local total = 0
	for i = 1, pasos do
		pesos[i] = azarLocal:NextNumber(1 - variacion, 1 + variacion)
		total += pesos[i]
	end
	for i = 1, pasos do
		pesos[i] = math.min(altura * pesos[i] / total, SUBIDA_MAXIMA)
	end
	return pesos
end

-- Calcula dónde va la siguiente plataforma. "d" va de 0 (fácil) a 1 (difícil).
-- "zActual/zSiguiente" son lo largas que son las plataformas (hacia delante) y
-- "xActual/xSiguiente" lo anchas que son (de lado). "subida" es cuánto sube este salto.
-- "desvioForzado" (opcional) obliga a moverse de lado justo esa cantidad (para el zigzag de los círculos).
-- Devuelve la nueva x, la nueva altura (y) y la nueva z.
local function paso(x, y, z, zActual, zSiguiente, xActual, xSiguiente, d, subida, desvioForzado)
	local mediaZ = (zActual + zSiguiente) / 2
	local mediaX = (xActual + xSiguiente) / 2

	-- Hueco entre los bordes de las dos plataformas
	local hueco = lerp(AJUSTES.huecoFacil, AJUSTES.huecoDificil, d) * azar:NextNumber(0.75, 1.15)
	hueco = math.min(hueco, HUECO_MAXIMO)

	-- Zigzag de lado a lado
	local desvio = desvioForzado or (azar:NextNumber(-1, 1) * lerp(AJUSTES.desvioFacil, AJUSTES.desvioDificil, d))
	local nuevaX = math.clamp(x + desvio, -LIMITE_LADO, LIMITE_LADO)
	desvio = nuevaX - x

	-- Si se desvía más que el ancho de las plataformas, el salto es en diagonal (más largo):
	-- acortamos el hueco para que siga siendo posible
	local extra = math.max(0, math.abs(desvio) - mediaX)
	if extra > 0 then
		hueco = math.min(hueco, math.sqrt(math.max(HUECO_MAXIMO ^ 2 - extra ^ 2, 1)))
	end

	-- Cuanto más sube, más cortito el hueco (si no, sería imposible)
	hueco = math.max(math.min(hueco, HUECO_MAXIMO * (1 - subida / SUBIDA_MAXIMA)), 1)

	return nuevaX, y + subida, z + mediaZ + hueco
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
	for _, posicion in zonaSalida do
		crearFarola(posicion, if posicion.X < 0 then 1 else -1)
	end

	local x, y, z = AJUSTES.inicio.X, AJUSTES.inicio.Y + 0.5, AJUSTES.inicio.Z -- y = la altura de arriba de la plataforma

	for nivel = 1, N do
		local d = (nivel - 1) / math.max(N - 1, 1) -- 0 = nivel fácil, 1 = nivel difícil
		local tema = temaDelNivel(nivel)

		-- Cuánto sube este nivel (las torres suben mucho más) y cuántas plataformas tiene
		local altura = lerp(AJUSTES.alturaPrimerNivel, AJUSTES.alturaUltimoNivel, d)
		if tema == "torre" then
			altura *= 1.8
		end
		local subidaMedia = if tema == "torre" then 3.9 else AJUSTES.subidaMediaPorPaso
		local cantidad = math.max(AJUSTES.plataformasMinimas, math.ceil(altura / subidaMedia))

		-- La forma de las plataformas: ancho (de lado a lado) y largo (hacia delante)
		local ancho = lerp(AJUSTES.tamanoFacil, AJUSTES.tamanoDificil, d)
		local largo = ancho
		if tema == "circulos" then
			ancho = lerp(9, 5, d)
			largo = ancho
		elseif tema == "lava" then
			ancho = lerp(6, 3.5, d)
			largo = ancho
		elseif tema == "vigas" then
			ancho = lerp(4, 2.2, d)
			largo = 11
		end

		-- ¿Este nivel tiene un tramo de obstáculos? ¿Cuántos obstáculos? ¿Lleva rodillo?
		local obstaculos = 0
		local azarTramo = Random.new(AJUSTES.semilla + nivel * 7919)
		if nivel >= AJUSTES.nivelDeLosTramos and #obstaculosDisponibles(nivel) > 0 then
			if azarTramo:NextNumber() < lerp(AJUSTES.probabilidadTramoFacil, AJUSTES.probabilidadTramoDificil, d) then
				obstaculos = math.clamp(1 + math.floor(d * 3 + azarTramo:NextNumber(0, 0.99)), 1, 4)
			end
		end
		local conRodillo = nivel <= AJUSTES.rodillosGarantizadosHasta
		if conRodillo then
			obstaculos = math.max(obstaculos, 1 + math.floor(d * 3))
		end

		-- Cuánto sube cada salto de este nivel (suman justo la altura del nivel)
		local pasosTotales = cantidad + (if obstaculos > 0 then 1 else 0) + 1
		local variacion = if tema == "torre" then 0.1 else 0.4
		local subidas = repartirSubida(altura, pasosTotales, Random.new(AJUSTES.semilla + nivel * 4001), variacion)
		local indice = 0
		local function siguienteSubida()
			indice += 1
			return subidas[indice]
		end

		local tamanoCheckpoint = tamanoDeCheckpoint(nivel)
		checkpoints[nivel] = ponerCheckpoint(nivel, x, y, z, tamanoCheckpoint, tema)
		local zInicio = z - tamanoCheckpoint.Z / 2
		local alturaMinima = y
		local alturaMaxima = y
		local anchoActual, largoActual = tamanoCheckpoint.X, tamanoCheckpoint.Z
		local piezas = { { z = z, mz = tamanoCheckpoint.Z / 2, y = y } } -- para poner lava cerquita

		local signoZigzag = 1
		for numero = 1, cantidad do
			local desvioForzado = nil
			if tema == "circulos" then
				-- Zigzag: un salto a la derecha, otro a la izquierda...
				desvioForzado = signoZigzag * lerp(4, 8, d)
				signoZigzag = -signoZigzag
			end
			x, y, z = paso(x, y, z, largoActual, largo, anchoActual, ancho, d, siguienteSubida(), desvioForzado)
			ponerPlataforma(nivel, numero, x, y, z, ancho, largo, tema)
			anchoActual, largoActual = ancho, largo
			alturaMinima = math.min(alturaMinima, y)
			alturaMaxima = math.max(alturaMaxima, y)
			table.insert(piezas, { z = z, mz = largo / 2, y = y })
		end

		if obstaculos > 0 then
			local largoTramo = ZONA * obstaculos + 12
			x, y, z = paso(x, y, z, largoActual, largoTramo, anchoActual, ANCHO_TRAMO, d * 0.7, siguienteSubida())
			ponerTramo(nivel, x, y, z, largoTramo, obstaculos, d, conRodillo)
			anchoActual, largoActual = ANCHO_TRAMO, largoTramo
			alturaMinima = math.min(alturaMinima, y)
			alturaMaxima = math.max(alturaMaxima, y)
			table.insert(piezas, { z = z, mz = largoTramo / 2, y = y })
		end

		-- Último salto: hacia el checkpoint del siguiente nivel (o la meta)
		local esElUltimo = nivel == N
		local siguiente = if esElUltimo then Vector3.new(16, 1, 16) else tamanoDeCheckpoint(nivel + 1)
		x, y, z = paso(x, y, z, largoActual, siguiente.Z, anchoActual, siguiente.X, d * 0.8, siguienteSubida())
		alturaMinima = math.min(alturaMinima, y)
		alturaMaxima = math.max(alturaMaxima, y)

		crearLava(nivel, zInicio, z + 8, alturaMinima)
		crearLavaCerca(nivel, piezas)
		crearParedes(nivel, zInicio, z + 8, alturaMinima, alturaMaxima)
		if esElUltimo then
			ponerMeta(x, y, z)
		end

		if nivel % AJUSTES.nivelesPorLote == 0 then
			task.wait() -- respiramos un momento para no atascar el juego
		end
	end

	mundoListo = true
	print("🗼 ¡" .. N .. " niveles construidos! La meta está a " .. math.floor(z) .. " studs de la salida y a " .. math.floor(y) .. " de altura.")
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
	if jugador.Parent and type(guardado) == "number" and nivelMaximo[jugador] and guardado > nivelMaximo[jugador] and checkpoints[guardado] then
		nivelMaximo[jugador] = guardado
		nivelDe[jugador] = guardado
		actualizarMarcador(jugador)
		irAlCheckpoint(jugador)
		avisar(jugador, "👋 ¡Sigues en el nivel " .. guardado .. "!", Color3.fromRGB(60, 100, 200))
	end
end

local function prepararJugador(jugador)
	nivelDe[jugador] = 1
	nivelMaximo[jugador] = 1
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
			valor.Value = nivelMaximo[jugador] or 1
			valor.Parent = marcador
		end
	end)

	-- Nivel guardado de otras veces (puede llegar un poco más tarde)
	jugador:GetAttributeChangedSignal("Nivel"):Connect(function()
		task.spawn(adoptarNivelGuardado, jugador)
	end)
	task.spawn(adoptarNivelGuardado, jugador)

	-- El script SaltoCheckpoint nos pide llevar al jugador a un checkpoint (ya pagado)
	jugador:GetAttributeChangedSignal("SaltarANivel"):Connect(function()
		local nivel = jugador:GetAttribute("SaltarANivel")
		if nivel ~= nil then
			jugador:SetAttribute("SaltarANivel", nil)
			saltarANivel(jugador, nivel)
		end
	end)
end

Players.PlayerAdded:Connect(prepararJugador)
for _, jugador in Players:GetPlayers() do
	prepararJugador(jugador)
end
Players.PlayerRemoving:Connect(function(jugador)
	nivelDe[jugador] = nil
	nivelMaximo[jugador] = nil
	yaAparecio[jugador] = nil
	teletransportando[jugador] = nil
end)

----------------------------------------------------------------------
-- 🔁 COSAS QUE PASAN SIEMPRE
----------------------------------------------------------------------

-- Plataformas azules, rodillos, cuadrados y barras: se mueven (solo las que tienen a un jugador cerca)
RunService.Heartbeat:Connect(function()
	if #animados == 0 then
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
	for _, cosa in animados do
		for _, posicion in posiciones do
			if (posicion - cosa.origen).Magnitude < 250 then
				cosa.mover(tiempo)
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
			if humanoide and raiz and punto and humanoide.Health > 0 and not teletransportando[jugador] and raiz.Position.Y < punto.Position.Y - 150 then
				humanoide.Health = 0
			end
		end
	end
end)

task.spawn(construirMundo)
