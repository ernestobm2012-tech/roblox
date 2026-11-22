--[[
	🗼 NIVELES (500 niveles, cada uno más difícil)
	Construye una pista larguísima de plataformas de colores. Está dividida en 500 niveles:
	  - Cada nivel empieza en un CHECKPOINT (plataforma blanca grande con su número y una farola).
	  - Si tocas la lava, te caes o te mueres, vuelves a tu último checkpoint.
	  - Cada nivel es un poquito más difícil que el anterior:
	      · plataformas más pequeñas · saltos más largos · más zigzag
	      · cada nivel es más LARGO (de 3 a 20 plataformas) y más ALTO (más escalones que suben)
	      · desde el nivel 60: plataformas NARANJAS que se caen al pisarlas
	      · desde el nivel 150: plataformas AZULES que se mueven de lado a lado
	  - Muchos niveles tienen un TRAMO DE OBSTÁCULOS (una plataforma larga). ¡Hay que saltar!
	      · desde el nivel 10: cubos fijos (muros bajos) ......... no hacen daño
	      · desde el nivel 20: charcos de lava ................... ¡queman!
	      · desde el nivel 30: rodillos que ruedan ............... ¡te matan!
	      · desde el nivel 80: cuadrados que se deslizan ......... ¡te matan!
	      · desde el nivel 250: BARRAS DE LAVA que giran ......... ¡te matan!
	  - Al llegar a un nivel nuevo ganas monedas 🪙. Cada 100 niveles, ¡todos lo ven en pantalla!
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

	-- Dificultad: el nivel 1 usa los valores "Fácil" y el último nivel los "Difícil".
	-- Los niveles del medio van poco a poco de uno a otro.
	plataformasFacil = 3, plataformasDificil = 20, -- cuántas plataformas hay en cada nivel (más = nivel más LARGO)
	tamanoFacil = 10, tamanoDificil = 4, -- lo grande que es cada plataforma
	huecoFacil = 2.5, huecoDificil = 6.2, -- lo lejos que está la siguiente
	subidaFacil = 0.4, subidaDificil = 4, -- cuánto suben las plataformas (más = nivel más ALTO)
	desvioFacil = 0, desvioDificil = 9, -- cuánto zigzaguean de lado a lado

	-- A partir de qué nivel aparecen las plataformas especiales
	nivelPlataformasQueCaen = 60,
	nivelPlataformasQueSeMueven = 150,

	-- Tramos de obstáculos: una plataforma larga con cosas que saltar
	nivelDeLosTramos = 10, -- desde qué nivel hay tramos
	probabilidadTramoFacil = 0.3, probabilidadTramoDificil = 0.9, -- 0.5 = en la mitad de los niveles
	nivelCubos = 10, -- desde qué nivel aparece cada obstáculo
	nivelCharcos = 20,
	nivelRodillos = 30,
	nivelCuadrados = 80,
	nivelBarras = 250,

	farolaCadaNiveles = 1, -- una farola cada tantos checkpoints (sube el número si va lento)
	nivelesPorLote = 20, -- cuántos niveles construye de golpe antes de "respirar"
}

-- Límites para que los saltos SIEMPRE se puedan hacer (no los subas mucho)
local HUECO_MAXIMO = 7 -- hueco más grande posible entre dos plataformas
local SUBIDA_MAXIMA = 4.5 -- lo más que puede subir una plataforma
local LIMITE_LADO = 22 -- lo lejos que puede zigzaguear la pista del centro
local ANCHO_TRAMO = 12 -- lo ancho que es un tramo de obstáculos
local ZONA = 14 -- el espacio que ocupa cada obstáculo dentro de un tramo

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
local nivelDe = {} -- nivelDe[jugador] = el checkpoint donde reaparece
local nivelMaximo = {} -- nivelMaximo[jugador] = el nivel más alto que ha alcanzado
local yaAparecio = {} -- para no mover al jugador la primera vez que entra
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
-- 🧭 CHECKPOINTS Y NIVELES DE CADA JUGADOR
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
		valor.Value = nivelMaximo[jugador] or 1
	end
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
end

-- Una plataforma larga con "cantidad" obstáculos, uno detrás de otro
local function ponerTramo(nivel, x, y, z, largo, cantidad, d)
	local azarLocal = Random.new(AJUSTES.semilla + nivel * 10007)
	local lista = obstaculosDisponibles(nivel)
	crearBloque("Tramo_" .. nivel, Vector3.new(ANCHO_TRAMO, 1, largo), Vector3.new(x, y - 0.5, z), Color3.fromHSV((nivel * 0.025) % 1, 0.5, 0.9), Enum.Material.Neon, carpeta)

	for i = 1, cantidad do
		local zc = z - largo / 2 + 6 + ZONA * (i - 0.5)
		local tipo = elegirObstaculo(lista, azarLocal)
		ponerObstaculo(tipo, nivel .. "_" .. i, x, y, zc, d, azarLocal)
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
	hacerMortal(lava)
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

-- Calcula dónde va la siguiente plataforma. "d" va de 0 (fácil) a 1 (difícil).
-- "zActual/zSiguiente" son lo largas que son las plataformas (hacia delante) y
-- "xActual/xSiguiente" lo anchas que son (de lado).
-- Devuelve la nueva x, la nueva altura (y) y la nueva z.
local function paso(x, y, z, zActual, zSiguiente, xActual, xSiguiente, d)
	local mediaZ = (zActual + zSiguiente) / 2
	local mediaX = (xActual + xSiguiente) / 2

	-- Hueco entre los bordes de las dos plataformas
	local hueco = lerp(AJUSTES.huecoFacil, AJUSTES.huecoDificil, d) * azar:NextNumber(0.75, 1.15)
	hueco = math.min(hueco, HUECO_MAXIMO)

	-- Zigzag de lado a lado
	local desvio = azar:NextNumber(-1, 1) * lerp(AJUSTES.desvioFacil, AJUSTES.desvioDificil, d)
	local nuevaX = math.clamp(x + desvio, -LIMITE_LADO, LIMITE_LADO)
	desvio = nuevaX - x

	-- Si se desvía más que el ancho de las plataformas, el salto es en diagonal (más largo):
	-- acortamos el hueco para que siga siendo posible
	local extra = math.max(0, math.abs(desvio) - mediaX)
	if extra > 0 then
		hueco = math.min(hueco, math.sqrt(math.max(HUECO_MAXIMO ^ 2 - extra ^ 2, 1)))
	end

	-- Subida (o, a veces, bajada)
	local subida
	if azar:NextNumber() < 0.15 then
		subida = -azar:NextNumber(0.5, 1.5)
	else
		subida = lerp(AJUSTES.subidaFacil, AJUSTES.subidaDificil, d) * azar:NextNumber(lerp(0.3, 0.7, d), 1)
		-- A veces es un "escalón": sube bastante, pero con el hueco cortito.
		-- Cuanto más alto el nivel, más escalones hay (así los niveles son cada vez más altos).
		if azar:NextNumber() < lerp(0.2, 0.85, d) then
			subida = math.min(subida * 1.5, SUBIDA_MAXIMA)
			hueco = math.max(math.min(hueco, HUECO_MAXIMO * (1 - subida / SUBIDA_MAXIMA)), 1)
		end
	end
	-- Cuanto más largo el hueco, menos puede subir (si no, sería imposible)
	subida = math.min(subida, SUBIDA_MAXIMA * (1 - hueco / HUECO_MAXIMO))

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
		local cantidad = math.floor(lerp(AJUSTES.plataformasFacil, AJUSTES.plataformasDificil, d) + 0.5)
		local tamano = lerp(AJUSTES.tamanoFacil, AJUSTES.tamanoDificil, d)

		-- ¿Este nivel tiene un tramo de obstáculos? ¿Cuántos obstáculos?
		local obstaculos = 0
		if nivel >= AJUSTES.nivelDeLosTramos and #obstaculosDisponibles(nivel) > 0 then
			local azarTramo = Random.new(AJUSTES.semilla + nivel * 7919)
			if azarTramo:NextNumber() < lerp(AJUSTES.probabilidadTramoFacil, AJUSTES.probabilidadTramoDificil, d) then
				obstaculos = math.clamp(1 + math.floor(d * 3 + azarTramo:NextNumber(0, 0.99)), 1, 4)
			end
		end

		checkpoints[nivel] = ponerCheckpoint(nivel, x, y, z)
		local zInicio = z - 7
		local alturaMinima = y
		local anchoActual, largoActual = 14, 14 -- el checkpoint mide 14 x 14

		for numero = 1, cantidad do
			x, y, z = paso(x, y, z, largoActual, tamano, anchoActual, tamano, d)
			ponerPlataforma(nivel, numero, x, y, z, tamano)
			anchoActual, largoActual = tamano, tamano
			alturaMinima = math.min(alturaMinima, y)
		end

		if obstaculos > 0 then
			local largo = ZONA * obstaculos + 12
			x, y, z = paso(x, y, z, largoActual, largo, anchoActual, ANCHO_TRAMO, d * 0.7)
			ponerTramo(nivel, x, y, z, largo, obstaculos, d)
			anchoActual, largoActual = ANCHO_TRAMO, largo
			alturaMinima = math.min(alturaMinima, y)
		end

		-- Último salto: hacia el checkpoint del siguiente nivel (o la meta)
		local esElUltimo = nivel == N
		local tamanoSiguiente = if esElUltimo then 16 else 14
		x, y, z = paso(x, y, z, largoActual, tamanoSiguiente, anchoActual, tamanoSiguiente, d * 0.8)
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
			if humanoide and raiz and punto and humanoide.Health > 0 and raiz.Position.Y < punto.Position.Y - 150 then
				humanoide.Health = 0
			end
		end
	end
end)

task.spawn(construirMundo)
