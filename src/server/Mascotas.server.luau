--[[
	🐾 MASCOTAS (que SUBEN DE NIVEL)
	Se compran con 🪙 monedas (unas 30), te SIGUEN a todas partes y te hacen CORRER MÁS RÁPIDO.
	Puedes tener todas las que quieras, pero solo una puesta a la vez.

	⭐ ¡Suben de nivel mientras juegas! La mascota que llevas puesta gana experiencia (XP):
	  - un poquito por cada rato que juegas con ella
	  - por cada moneda que recoges
	  - por cada nivel nuevo del parkour que alcanzas
	Cada vez que sube de nivel, CORRES MÁS, la mascota se hace un poquito MÁS GRANDE y sale un aviso.
	Cada mascota guarda su propio nivel (con el script Guardado).

	✨ ¡EVOLUCIÓN! Cuando una mascota llega al NIVEL 30 CAMBIA DE ASPECTO: se convierte en su forma
	final (el Perrito en Lobo, el Gatito en León, el Dragoncito en Dragón...), con otro color, piezas
	nuevas, un aura de chispas y +2 de velocidad extra.

	Se eligen en el botón "🐾 Mascotas" de la pantalla (script Mascotas del cliente).

	📋 DÓNDE VA: en Roblox Studio, dentro de ServerScriptService, como "Script".
	(Usa las Monedas del marcador que crea el script MiMundo. Dice cuánta velocidad extra te dan con
	el atributo "BonusMascota", que suma el script Tienda. Habla con la pantalla con un RemoteEvent
	y con una carpeta en ReplicatedStorage.)
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

-- ⚙️ AJUSTES: ¡cambia estos valores y mira qué pasa!
local AJUSTES = {
	nivelMaximo = 30, -- hasta qué nivel puede subir una mascota
	divisorNivel = 8, -- XP para llegar al nivel N = esto x (N - 1) x (N - 1). Más grande = sube más despacio
	bonusPorNivel = 0.15, -- velocidad extra por cada nivel de la mascota
	escalaPorNivel = 0.02, -- lo que crece la mascota con cada nivel
	xpPorMoneda = 1, -- XP por cada moneda recogida
	xpPorNivelDelMundo = 5, -- XP por cada nivel nuevo del parkour
	segundosPorXP = 10, -- 1 XP cada tantos segundos jugando
	bonusEvolucion = 2, -- velocidad extra cuando la mascota ya ha evolucionado (nivel máximo)
}

local PREFIJO_XP = "Mascota_xp_" -- el XP de cada mascota se guarda como Mascota_xp_perrito, etc.

-- 🧺 LAS MASCOTAS
-- "bonus" = velocidad extra al correr con la mascota en el nivel 1 (sin mascota corres a 16).
-- "extras" son las piezas que les dan forma: { tamaño, posición, color, ¿brilla? } (la posición es respecto al cuerpo).
-- "evolucion" es su forma final, que sale al llegar al nivel máximo: otro nombre, otro color, piezas
-- nuevas (que se suman a las de antes) y el color de las chispas de su aura.
local ORELLAS = Color3.fromRGB(130, 85, 45)
local MASCOTAS = {
	{
		id = "perrito", nombre = "🐶 Perrito", precio = 30, bonus = 2, color = Color3.fromRGB(200, 140, 80),
		extras = {
			{ Vector3.new(0.5, 1.1, 0.5), Vector3.new(-1.05, 0.7, 0), ORELLAS },
			{ Vector3.new(0.5, 1.1, 0.5), Vector3.new(1.05, 0.7, 0), ORELLAS },
			{ Vector3.new(0.5, 0.4, 0.5), Vector3.new(0, -0.1, -1.25), Color3.fromRGB(40, 30, 30) }, -- la nariz
		},
		evolucion = {
			nombre = "🐺 Lobo", color = Color3.fromRGB(140, 145, 165), particulas = Color3.fromRGB(180, 210, 255),
			extras = {
				{ Vector3.new(2, 2.2, 0.2), Vector3.new(0, -0.2, 1.3), Color3.fromRGB(220, 50, 50) }, -- una capa de superhéroe
				{ Vector3.new(1.4, 0.3, 0.3), Vector3.new(0, 0.1, -1.0), Color3.fromRGB(80, 200, 255), true }, -- un collar que brilla
			},
		},
	},
	{
		id = "gatito", nombre = "🐱 Gatito", precio = 30, bonus = 2, color = Color3.fromRGB(150, 150, 165),
		extras = {
			{ Vector3.new(0.6, 0.9, 0.4), Vector3.new(-0.75, 1.15, 0), Color3.fromRGB(120, 120, 135) },
			{ Vector3.new(0.6, 0.9, 0.4), Vector3.new(0.75, 1.15, 0), Color3.fromRGB(120, 120, 135) },
			{ Vector3.new(0.25, 0.25, 1.6), Vector3.new(0, -0.4, 1.6), Color3.fromRGB(120, 120, 135) }, -- la cola
		},
		evolucion = {
			nombre = "🦁 León", color = Color3.fromRGB(225, 175, 65), particulas = Color3.fromRGB(255, 200, 80),
			extras = {
				{ Vector3.new(3.4, 3.4, 0.5), Vector3.new(0, 0.1, 0.9), Color3.fromRGB(170, 105, 30) }, -- la melena
				{ Vector3.new(0.8, 0.5, 0.3), Vector3.new(0, 1.5, -0.2), Color3.fromRGB(255, 215, 50), true }, -- una corona
			},
		},
	},
	{
		id = "pollito", nombre = "🐥 Pollito", precio = 30, bonus = 2, color = Color3.fromRGB(255, 225, 70),
		extras = {
			{ Vector3.new(0.6, 0.4, 0.7), Vector3.new(0, -0.15, -1.3), Color3.fromRGB(255, 140, 30) }, -- el pico
		},
		evolucion = {
			nombre = "🦅 Águila", color = Color3.fromRGB(165, 115, 60), particulas = Color3.fromRGB(255, 240, 150),
			extras = {
				{ Vector3.new(2.6, 0.25, 1.5), Vector3.new(-2.2, 0.2, 0.3), Color3.fromRGB(120, 80, 40) }, -- ala izquierda
				{ Vector3.new(2.6, 0.25, 1.5), Vector3.new(2.2, 0.2, 0.3), Color3.fromRGB(120, 80, 40) }, -- ala derecha
				{ Vector3.new(1.2, 0.7, 0.6), Vector3.new(0, 1.2, -0.2), Color3.fromRGB(245, 245, 250) }, -- cabeza blanca
			},
		},
	},
	{
		id = "conejito", nombre = "🐰 Conejito", precio = 40, bonus = 3, color = Color3.fromRGB(245, 245, 250),
		extras = {
			{ Vector3.new(0.4, 1.8, 0.3), Vector3.new(-0.5, 1.9, 0), Color3.fromRGB(255, 200, 215) },
			{ Vector3.new(0.4, 1.8, 0.3), Vector3.new(0.5, 1.9, 0), Color3.fromRGB(255, 200, 215) },
		},
		evolucion = {
			nombre = "🦄 Unicornio", color = Color3.fromRGB(255, 235, 250), particulas = Color3.fromRGB(255, 150, 230),
			extras = {
				{ Vector3.new(0.3, 1.5, 0.3), Vector3.new(0, 2.0, -0.6), Color3.fromRGB(255, 120, 220), true }, -- el cuerno
				{ Vector3.new(0.5, 0.7, 0.5), Vector3.new(0, 1.0, 0.95), Color3.fromRGB(255, 90, 90) }, -- la crin de colores
				{ Vector3.new(0.5, 0.7, 0.5), Vector3.new(0, 0.3, 1.25), Color3.fromRGB(255, 220, 70) },
				{ Vector3.new(0.5, 0.7, 0.5), Vector3.new(0, -0.4, 1.35), Color3.fromRGB(90, 150, 255) },
			},
		},
	},
	{
		id = "dragoncito", nombre = "🐲 Dragoncito", precio = 60, bonus = 5, color = Color3.fromRGB(70, 190, 90),
		extras = {
			{ Vector3.new(0.3, 0.8, 0.3), Vector3.new(-0.5, 1.4, -0.2), Color3.fromRGB(255, 150, 40) },
			{ Vector3.new(0.3, 0.8, 0.3), Vector3.new(0.5, 1.4, -0.2), Color3.fromRGB(255, 150, 40) },
			{ Vector3.new(0.6, 0.6, 1.8), Vector3.new(0, -0.4, 1.7), Color3.fromRGB(50, 150, 70) }, -- la cola
		},
		evolucion = {
			nombre = "🐉 Dragón", color = Color3.fromRGB(205, 60, 55), particulas = Color3.fromRGB(255, 130, 30),
			extras = {
				{ Vector3.new(3, 0.25, 2), Vector3.new(-2.7, 0.7, 0.5), Color3.fromRGB(255, 130, 30), true }, -- ala izquierda
				{ Vector3.new(3, 0.25, 2), Vector3.new(2.7, 0.7, 0.5), Color3.fromRGB(255, 130, 30), true }, -- ala derecha
				{ Vector3.new(0.5, 0.5, 0.5), Vector3.new(0, 0.3, 0.9), Color3.fromRGB(255, 200, 60), true }, -- una escama brillante
			},
		},
	},
	{
		id = "robot", nombre = "🤖 Robot", precio = 80, bonus = 6, color = Color3.fromRGB(170, 175, 190), cuadrado = true,
		extras = {
			{ Vector3.new(0.15, 1, 0.15), Vector3.new(0, 1.7, 0), Color3.fromRGB(90, 90, 100) }, -- la antena
			{ Vector3.new(0.4, 0.4, 0.4), Vector3.new(0, 2.3, 0), Color3.fromRGB(255, 80, 80) },
		},
		evolucion = {
			nombre = "🛸 Mega Robot", color = Color3.fromRGB(110, 195, 255), particulas = Color3.fromRGB(120, 255, 255),
			extras = {
				{ Vector3.new(2.8, 0.2, 2.8), Vector3.new(0, 3.1, 0), Color3.fromRGB(255, 230, 80), true }, -- un aro brillante
				{ Vector3.new(0.9, 0.9, 0.9), Vector3.new(-1.8, 0, 0), Color3.fromRGB(110, 110, 125) }, -- hombreras
				{ Vector3.new(0.9, 0.9, 0.9), Vector3.new(1.8, 0, 0), Color3.fromRGB(110, 110, 125) },
			},
		},
	},
}

local mascotas = {} -- mascotas[jugador] = { modelo, cframe, fase, etiqueta }
local entrada = {} -- entrada[jugador] = cuándo entró (para esperar a que se cargue lo guardado)

workspace:SetAttribute("MascotaDivisor", AJUSTES.divisorNivel) -- la pantalla los usa para calcular el nivel
workspace:SetAttribute("MascotaNivelMaximo", AJUSTES.nivelMaximo)

local carpeta = Instance.new("Folder")
carpeta.Name = "Mascotas"
carpeta.Parent = workspace

----------------------------------------------------------------------
-- 🧰 HERRAMIENTAS
----------------------------------------------------------------------

local function buscar(id)
	for _, mascota in MASCOTAS do
		if mascota.id == id then
			return mascota
		end
	end
	return nil
end

-- El nivel que corresponde a una cantidad de XP
local function nivelDeXP(xp)
	return math.min(AJUSTES.nivelMaximo, 1 + math.floor(math.sqrt(xp / AJUSTES.divisorNivel)))
end

-- ¿Ya se ha cargado lo guardado? (si no se carga nunca, esperamos 20 segundos y seguimos)
local function listo(jugador)
	return jugador:GetAttribute("DatosCargados") == true or os.clock() - (entrada[jugador] or os.clock()) > 20
end

-- Enseña un mensajito en la pantalla de un jugador
local function avisar(jugador, texto, color)
	local pantallaJugador = jugador:FindFirstChild("PlayerGui")
	if not pantallaJugador then
		return
	end
	local viejo = pantallaJugador:FindFirstChild("AvisoMascota")
	if viejo then
		viejo:Destroy()
	end

	local pantalla = Instance.new("ScreenGui")
	pantalla.Name = "AvisoMascota"
	pantalla.ResetOnSpawn = false
	pantalla.Parent = pantallaJugador

	local mensaje = Instance.new("TextLabel")
	mensaje.Size = UDim2.fromScale(0.55, 0.09)
	mensaje.Position = UDim2.fromScale(0.5, 0.9)
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

	task.delay(3, function()
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

-- Construye el muñequito de una mascota (cuerpo + ojos + sus piezas + cartelito con el nivel).
-- Si "evolucionada" es verdad, le pone su forma final.
local function crearModelo(datos, evolucionada)
	local modelo = Instance.new("Model")
	modelo.Name = "Mascota"

	local function crearParte(nombre, tamano, posicion, color, forma, brilla)
		local parte = Instance.new("Part")
		parte.Name = nombre
		parte.Size = tamano
		parte.Position = posicion
		parte.Color = color
		parte.Shape = forma
		parte.Material = if brilla then Enum.Material.Neon else Enum.Material.SmoothPlastic
		parte.Anchored = true
		parte.CanCollide = false
		parte.CanTouch = false
		parte.CanQuery = false
		parte.CastShadow = false
		parte.TopSurface = Enum.SurfaceType.Smooth
		parte.BottomSurface = Enum.SurfaceType.Smooth
		parte.Parent = modelo
		return parte
	end

	local colorCuerpo = if evolucionada then datos.evolucion.color else datos.color
	local cuerpo = crearParte("Cuerpo", Vector3.new(2.4, 2.4, 2.4), Vector3.zero, colorCuerpo, if datos.cuadrado then Enum.PartType.Block else Enum.PartType.Ball)
	modelo.PrimaryPart = cuerpo

	-- Los ojos miran hacia delante (que es hacia -Z)
	local negro = Color3.fromRGB(20, 20, 25)
	crearParte("OjoIzquierdo", Vector3.new(0.45, 0.45, 0.45), Vector3.new(-0.5, 0.3, -1.05), negro, Enum.PartType.Ball)
	crearParte("OjoDerecho", Vector3.new(0.45, 0.45, 0.45), Vector3.new(0.5, 0.3, -1.05), negro, Enum.PartType.Ball)

	for _, extra in datos.extras do
		crearParte("Pieza", extra[1], extra[2], extra[3], Enum.PartType.Block, extra[4])
	end

	-- Su forma final: piezas nuevas y un aura de chispas
	if evolucionada then
		for _, extra in datos.evolucion.extras do
			crearParte("PiezaEvolucion", extra[1], extra[2], extra[3], Enum.PartType.Block, extra[4])
		end
		local aura = Instance.new("ParticleEmitter")
		aura.Rate = 12
		aura.Lifetime = NumberRange.new(1, 1.6)
		aura.Speed = NumberRange.new(1, 3)
		aura.SpreadAngle = Vector2.new(180, 180)
		aura.Size = NumberSequence.new(0.6, 0)
		aura.LightEmission = 1
		aura.Transparency = NumberSequence.new(0.2, 1)
		aura.Color = ColorSequence.new(datos.evolucion.particulas)
		aura.Parent = cuerpo
	end

	-- El cartelito flotante con su nombre y su nivel
	local cartel = Instance.new("BillboardGui")
	cartel.Size = UDim2.fromOffset(170, 34)
	cartel.StudsOffset = Vector3.new(0, 3.2, 0)
	cartel.MaxDistance = 70
	cartel.AlwaysOnTop = true
	cartel.Parent = cuerpo
	local etiqueta = Instance.new("TextLabel")
	etiqueta.Name = "Etiqueta"
	etiqueta.Size = UDim2.fromScale(1, 1)
	etiqueta.BackgroundTransparency = 1
	etiqueta.TextScaled = true
	etiqueta.Font = Enum.Font.FredokaOne
	etiqueta.TextColor3 = Color3.fromRGB(255, 255, 255)
	etiqueta.TextStrokeTransparency = 0
	etiqueta.Text = if evolucionada then datos.evolucion.nombre else datos.nombre
	etiqueta.Parent = cartel

	return modelo, etiqueta
end

----------------------------------------------------------------------
-- 🐾 PONERSE LA MASCOTA Y SUBIR DE NIVEL
----------------------------------------------------------------------

local ponerMascota -- (se define más abajo)

-- Pone al día todo lo que depende del nivel de la mascota: tu velocidad, su tamaño y su cartelito
local function actualizarMascota(jugador)
	-- El nivel más alto de todas tus mascotas (lo usan los logros)
	local maximo = 0
	for nombre, valor in jugador:GetAttributes() do
		if string.sub(nombre, 1, #PREFIJO_XP) == PREFIJO_XP and type(valor) == "number" then
			maximo = math.max(maximo, nivelDeXP(valor))
		end
	end
	jugador:SetAttribute("MascotaMaxNivel", maximo)

	local datos = buscar(jugador:GetAttribute("Equipo_mascota"))
	local actual = mascotas[jugador]
	if not datos or not actual then
		jugador:SetAttribute("BonusMascota", 0)
		jugador:SetAttribute("MascotaNivel", 0)
		return
	end

	local nivel = nivelDeXP(jugador:GetAttribute(PREFIJO_XP .. datos.id) or 0)
	local evoluciona = nivel >= AJUSTES.nivelMaximo
	if actual.evolucionada ~= evoluciona then
		ponerMascota(jugador) -- ¡ha evolucionado! Se hace de nuevo con su forma final
		return
	end

	jugador:SetAttribute("MascotaNivel", nivel)
	local bonus = datos.bonus + (nivel - 1) * AJUSTES.bonusPorNivel + (if evoluciona then AJUSTES.bonusEvolucion else 0)
	jugador:SetAttribute("BonusMascota", bonus) -- el script Tienda lo suma a tu velocidad
	actual.modelo:ScaleTo(1 + (nivel - 1) * AJUSTES.escalaPorNivel)
	actual.etiqueta.Text = (if evoluciona then datos.evolucion.nombre .. " ⭐" else datos.nombre) .. " · Nv " .. nivel
end

-- Le damos experiencia a la mascota que lleva puesta el jugador
local function darXP(jugador, cantidad)
	local datos = buscar(jugador:GetAttribute("Equipo_mascota"))
	if not datos or not mascotas[jugador] or cantidad <= 0 then
		return
	end
	local atributo = PREFIJO_XP .. datos.id
	local viejo = jugador:GetAttribute(atributo) or 0
	jugador:SetAttribute(atributo, viejo + cantidad) -- el script Guardado se acuerda
	local nivelViejo = nivelDeXP(viejo)
	local nivelNuevo = nivelDeXP(viejo + cantidad)
	actualizarMascota(jugador)
	if nivelNuevo >= AJUSTES.nivelMaximo and nivelViejo < AJUSTES.nivelMaximo then
		avisar(jugador, "✨ ¡" .. datos.nombre .. " ha EVOLUCIONADO en " .. datos.evolucion.nombre .. "!", Color3.fromRGB(150, 70, 220))
	elseif nivelNuevo > nivelViejo then
		avisar(jugador, "🎉 ¡" .. datos.nombre .. " ha subido al nivel " .. nivelNuevo .. "!", Color3.fromRGB(190, 130, 0))
	end
end

local function quitarMascota(jugador)
	local actual = mascotas[jugador]
	if actual then
		actual.modelo:Destroy()
		mascotas[jugador] = nil
	end
end

function ponerMascota(jugador)
	-- Guardamos dónde estaba la mascota (por si solo estamos cambiándole la forma)
	local anterior = mascotas[jugador]
	local cframeAnterior = anterior and anterior.cframe
	quitarMascota(jugador)
	local datos = buscar(jugador:GetAttribute("Equipo_mascota"))
	if not datos then
		actualizarMascota(jugador)
		return
	end

	local evolucionada = nivelDeXP(jugador:GetAttribute(PREFIJO_XP .. datos.id) or 0) >= AJUSTES.nivelMaximo
	local modelo, etiqueta = crearModelo(datos, evolucionada)
	local raiz = jugador.Character and jugador.Character:FindFirstChild("HumanoidRootPart")
	local inicio = cframeAnterior or (if raiz then raiz.CFrame * CFrame.new(3.2, 0.2, 3.2) else CFrame.new(0, 5, 0))
	modelo:PivotTo(inicio)
	modelo.Parent = carpeta
	mascotas[jugador] = { modelo = modelo, cframe = inicio, fase = math.random() * 6, etiqueta = etiqueta, evolucionada = evolucionada }
	actualizarMascota(jugador)
end

-- Cada fotograma la mascota se acerca (suavemente) a un sitio detrás de su dueño, flotando un poquito
RunService.Heartbeat:Connect(function(dt)
	local tiempo = os.clock()
	for jugador, mascota in mascotas do
		local raiz = jugador.Character and jugador.Character:FindFirstChild("HumanoidRootPart")
		if raiz then
			local objetivo = raiz.CFrame * CFrame.new(3.2, 0.2 + math.sin(tiempo * 3 + mascota.fase) * 0.4, 3.2)
			if (mascota.cframe.Position - objetivo.Position).Magnitude > 60 then
				mascota.cframe = objetivo -- si te has teletransportado lejos, viene de golpe
			else
				mascota.cframe = mascota.cframe:Lerp(objetivo, math.clamp(dt * 8, 0, 1))
			end
			mascota.modelo:PivotTo(mascota.cframe)
		end
	end
end)

local function prepararJugador(jugador)
	entrada[jugador] = os.clock()

	-- Cuando cambias de mascota (o se carga la guardada)
	jugador:GetAttributeChangedSignal("Equipo_mascota"):Connect(function()
		ponerMascota(jugador)
	end)

	-- Qué cosas dan experiencia: las monedas que recoges y los niveles nuevos del parkour.
	-- (Lo que se carga de la partida anterior no cuenta: solo lo que haces ahora.)
	local ultimo = {
		Estad_monedas = jugador:GetAttribute("Estad_monedas") or 0,
		Nivel = jugador:GetAttribute("Nivel") or 1,
	}
	jugador.AttributeChanged:Connect(function(nombre)
		if nombre == "Estad_monedas" or nombre == "Nivel" then
			local nuevo = jugador:GetAttribute(nombre) or 0
			local viejo = ultimo[nombre]
			ultimo[nombre] = nuevo
			if nuevo > viejo and listo(jugador) then
				darXP(jugador, (nuevo - viejo) * (if nombre == "Nivel" then AJUSTES.xpPorNivelDelMundo else AJUSTES.xpPorMoneda))
			end
		elseif string.sub(nombre, 1, #PREFIJO_XP) == PREFIJO_XP then
			actualizarMascota(jugador) -- se ha cargado (o cambiado) el nivel de una mascota
		end
	end)

	ponerMascota(jugador)
end

Players.PlayerAdded:Connect(prepararJugador)
for _, jugador in Players:GetPlayers() do
	prepararJugador(jugador)
end
Players.PlayerRemoving:Connect(function(jugador)
	quitarMascota(jugador)
	entrada[jugador] = nil
end)

-- Y un poquito de XP por cada rato que juegas con la mascota puesta
task.spawn(function()
	while true do
		task.wait(AJUSTES.segundosPorXP)
		for _, jugador in Players:GetPlayers() do
			if listo(jugador) then
				darXP(jugador, 1)
			end
		end
	end
end)

----------------------------------------------------------------------
-- 📋 LA LISTA PARA LA PANTALLA Y EL BOTÓN DE COMPRAR
----------------------------------------------------------------------

local catalogo = Instance.new("Folder")
catalogo.Name = "CatalogoMascotas"
for orden, mascota in MASCOTAS do
	local ficha = Instance.new("Folder")
	ficha.Name = mascota.id
	ficha:SetAttribute("Id", mascota.id)
	ficha:SetAttribute("Nombre", mascota.nombre)
	ficha:SetAttribute("Precio", mascota.precio)
	ficha:SetAttribute("Bonus", mascota.bonus)
	ficha:SetAttribute("NombreEvolucion", mascota.evolucion.nombre)
	ficha:SetAttribute("Color", mascota.color)
	ficha:SetAttribute("Orden", orden)
	ficha.Parent = catalogo
end

local evento = Instance.new("RemoteEvent")
evento.Name = "MascotaAccion"
evento.Parent = ReplicatedStorage
catalogo.Parent = ReplicatedStorage -- al final, cuando ya está todo listo

local ultimoPedido = {}
Players.PlayerRemoving:Connect(function(jugador)
	ultimoPedido[jugador] = nil
end)

evento.OnServerEvent:Connect(function(jugador, accion, id)
	-- Comprobamos que lo que nos manda tiene sentido (¡nunca nos fiamos de la pantalla!)
	if type(accion) ~= "string" or type(id) ~= "string" then
		return
	end
	local ahora = os.clock()
	if ahora - (ultimoPedido[jugador] or -100) < 0.3 then
		return
	end
	ultimoPedido[jugador] = ahora

	-- Quitarse la mascota
	if accion == "equipar" and id == "" then
		jugador:SetAttribute("Equipo_mascota", "")
		return
	end

	local datos = buscar(id)
	if not datos then
		return
	end
	local atributoCompra = "Estilo_mascota_" .. id -- (el script Guardado guarda todo lo que empieza por "Estilo_")

	if accion == "equipar" then
		if jugador:GetAttribute(atributoCompra) then
			jugador:SetAttribute("Equipo_mascota", id)
		end
	elseif accion == "comprar" then
		if jugador:GetAttribute(atributoCompra) then
			jugador:SetAttribute("Equipo_mascota", id) -- ya la tienes: te la pones
			return
		end
		local marcador = jugador:FindFirstChild("leaderstats")
		local monedas = marcador and marcador:FindFirstChild("Monedas")
		if not monedas then
			avisar(jugador, "Todavía no tienes monedas 🪙", Color3.fromRGB(200, 60, 60))
			return
		end
		if monedas.Value < datos.precio then
			avisar(jugador, "Te faltan " .. (datos.precio - monedas.Value) .. " 🪙 para " .. datos.nombre, Color3.fromRGB(200, 60, 60))
			return
		end
		monedas.Value -= datos.precio
		jugador:SetAttribute(atributoCompra, true)
		jugador:SetAttribute("Equipo_mascota", id)
		avisar(jugador, "¡" .. datos.nombre .. " es tu mascota! Corres +" .. datos.bonus .. " más rápido 🎉", Color3.fromRGB(40, 160, 80))
	end
end)

print("🐾 Mascotas listas.")
