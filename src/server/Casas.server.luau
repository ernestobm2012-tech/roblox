--[[
	🏠 CASITAS
	Un barrio de casitas FUERA del parkour, en el suelo de hierba a los dos lados de la zona de salida.
	  - Cada jugador que entra se queda con una casa libre, y en el tejado pone "🏠 Casa de <su nombre>".
	  - La casa es PRIVADA: la puerta está cerrada para todos menos para su dueño. El dueño pulsa
	    la tecla E en la puerta (o el botón "🏠 Mi casa" de la pantalla) y aparece dentro.
	  - Dentro se van poniendo CAMAS Y MUEBLES que se compran con monedas (en el botón "🏠 Mi casa").
	    Los muebles se colocan solos y se guardan (con el script Guardado).
	  - Al fondo hay una ESTANTERÍA DE TROFEOS: sale un trofeo por cada logro que consigues (script Logros).

	📋 DÓNDE VA: en Roblox Studio, dentro de ServerScriptService, como "Script".
	(Usa las Monedas del marcador que crea el script MiMundo. Habla con la pantalla con un RemoteEvent
	y con una carpeta en ReplicatedStorage. Los muebles se cuentan en atributos "Casa_cama", etc.)
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

-- ⚙️ AJUSTES: ¡cambia estos valores y mira qué pasa!
local AJUSTES = {
	casasPorLado = 6, -- cuántas casas hay a cada lado (el total es el doble)
	distanciaDelCentro = 72, -- lo lejos que están las casas del centro (en X)
	separacion = 28, -- lo separadas que están unas de otras (en Z)
}

local PISO = 0.6 -- la altura del suelo de dentro de las casas

-- 🧺 LOS MUEBLES. "huecos" son los sitios de la casa donde van (x, z); el primero que compras
-- va al primer hueco, el segundo al segundo... Así que no se puede comprar más que huecos hay.
-- Cada pieza: { tam = tamaño, pos = dónde (la y cuenta desde el suelo), color, material, ... }
local MADERA = Color3.fromRGB(150, 100, 60)

local function libros()
	local piezas = {}
	local colores = { Color3.fromRGB(220, 70, 70), Color3.fromRGB(70, 130, 220), Color3.fromRGB(80, 190, 100) }
	for lado = -1, 1, 2 do
		for i, color in colores do
			table.insert(piezas, { tam = Vector3.new(0.15, 0.8, 3.4), pos = Vector3.new(lado * 0.72, 0.9 + (i - 1) * 1.5, 0), color = color })
		end
	end
	return piezas
end

local MUEBLES = {
	{
		id = "cama", nombre = "🛏️ Cama", precio = 20,
		huecos = { { -5.5, 6.5 }, { 0, 6.5 }, { 5.5, 6.5 } },
		partes = {
			{ tam = Vector3.new(3, 0.8, 5.5), pos = Vector3.new(0, 0.4, 0), color = MADERA },
			{ tam = Vector3.new(2.8, 0.5, 4.6), pos = Vector3.new(0, 1.05, -0.2), color = Color3.fromRGB(80, 130, 220) },
			{ tam = Vector3.new(2, 0.4, 1), pos = Vector3.new(0, 1.5, 2), color = Color3.fromRGB(245, 245, 250) },
			{ tam = Vector3.new(3, 2, 0.3), pos = Vector3.new(0, 1.4, 2.7), color = MADERA },
		},
	},
	{
		id = "sofa", nombre = "🛋️ Sofá", precio = 25,
		huecos = { { -4, 0.5 }, { 4, 0.5 } },
		partes = {
			{ tam = Vector3.new(6, 1.2, 2.6), pos = Vector3.new(0, 0.6, 0), color = Color3.fromRGB(200, 80, 80) },
			{ tam = Vector3.new(6, 1.6, 0.7), pos = Vector3.new(0, 2, 0.95), color = Color3.fromRGB(180, 60, 60) },
			{ tam = Vector3.new(0.7, 1.1, 2.6), pos = Vector3.new(-2.65, 1.75, 0), color = Color3.fromRGB(180, 60, 60) },
			{ tam = Vector3.new(0.7, 1.1, 2.6), pos = Vector3.new(2.65, 1.75, 0), color = Color3.fromRGB(180, 60, 60) },
		},
	},
	{
		id = "mesa", nombre = "🍽️ Mesa", precio = 15,
		huecos = { { 0, -4.2 }, { 6.8, -5.2 } },
		partes = {
			{ tam = Vector3.new(3, 0.3, 3), pos = Vector3.new(0, 2.4, 0), color = MADERA },
			{ tam = Vector3.new(0.3, 2.25, 0.3), pos = Vector3.new(-1.25, 1.125, -1.25), color = MADERA },
			{ tam = Vector3.new(0.3, 2.25, 0.3), pos = Vector3.new(1.25, 1.125, -1.25), color = MADERA },
			{ tam = Vector3.new(0.3, 2.25, 0.3), pos = Vector3.new(-1.25, 1.125, 1.25), color = MADERA },
			{ tam = Vector3.new(0.3, 2.25, 0.3), pos = Vector3.new(1.25, 1.125, 1.25), color = MADERA },
		},
	},
	{
		id = "silla", nombre = "🪑 Silla", precio = 8,
		huecos = { { -2.4, -4.2 }, { 2.4, -4.2 }, { 4.6, -2.8 } },
		partes = {
			{ tam = Vector3.new(1.2, 0.25, 1.2), pos = Vector3.new(0, 1.4, 0), color = Color3.fromRGB(180, 120, 70) },
			{ tam = Vector3.new(1.2, 1.3, 0.2), pos = Vector3.new(0, 2.15, 0.5), color = Color3.fromRGB(180, 120, 70) },
			{ tam = Vector3.new(0.2, 1.3, 0.2), pos = Vector3.new(-0.5, 0.65, -0.5), color = MADERA },
			{ tam = Vector3.new(0.2, 1.3, 0.2), pos = Vector3.new(0.5, 0.65, -0.5), color = MADERA },
			{ tam = Vector3.new(0.2, 1.3, 0.2), pos = Vector3.new(-0.5, 0.65, 0.5), color = MADERA },
			{ tam = Vector3.new(0.2, 1.3, 0.2), pos = Vector3.new(0.5, 0.65, 0.5), color = MADERA },
		},
	},
	{
		id = "lampara", nombre = "💡 Lámpara", precio = 10,
		huecos = { { -8.6, 8.6 }, { 8.6, 8.6 }, { -8.6, -8.8 } },
		partes = {
			{ tam = Vector3.new(0.9, 0.2, 0.9), pos = Vector3.new(0, 0.1, 0), color = Color3.fromRGB(60, 60, 70) },
			{ tam = Vector3.new(0.2, 3.6, 0.2), pos = Vector3.new(0, 2, 0), color = Color3.fromRGB(60, 60, 70) },
			{ tam = Vector3.new(1.2, 0.9, 1.2), pos = Vector3.new(0, 4.2, 0), color = Color3.fromRGB(255, 225, 150), material = Enum.Material.Neon, luz = true },
		},
	},
	{
		id = "planta", nombre = "🪴 Planta", precio = 6,
		huecos = { { -8.6, 4.5 }, { 8.6, 4.5 }, { -8.6, -6.5 }, { 8.6, 7 } },
		partes = {
			{ tam = Vector3.new(1.2, 1.1, 1.2), pos = Vector3.new(0, 0.55, 0), color = Color3.fromRGB(190, 100, 60) },
			{ tam = Vector3.new(1.6, 1.6, 1.6), pos = Vector3.new(0, 1.9, 0), color = Color3.fromRGB(60, 170, 70), forma = Enum.PartType.Ball },
		},
	},
	{
		id = "libreria", nombre = "📚 Librería", precio = 30,
		huecos = { { -8.6, -2.5 }, { 8.6, -1.5 } },
		partes = (function()
			local piezas = { { tam = Vector3.new(1.4, 5, 4), pos = Vector3.new(0, 2.5, 0), color = MADERA } }
			for _, libro in libros() do
				table.insert(piezas, libro)
			end
			return piezas
		end)(),
	},
	{
		id = "tele", nombre = "📺 Tele", precio = 40,
		huecos = { { -5.8, -5.5 } },
		partes = {
			{ tam = Vector3.new(4, 0.8, 1.2), pos = Vector3.new(0, 0.4, 0), color = Color3.fromRGB(40, 40, 45) },
			{ tam = Vector3.new(3.6, 2.1, 0.2), pos = Vector3.new(0, 1.9, 0.3), color = Color3.fromRGB(60, 140, 255), material = Enum.Material.Neon },
		},
	},
	{
		id = "nevera", nombre = "🧊 Nevera", precio = 35,
		huecos = { { 8.6, -8 } },
		partes = {
			{ tam = Vector3.new(1.8, 4.6, 1.8), pos = Vector3.new(0, 2.3, 0), color = Color3.fromRGB(235, 235, 240) },
			{ tam = Vector3.new(0.15, 1.2, 0.15), pos = Vector3.new(-0.5, 3, 0.95), color = Color3.fromRGB(150, 150, 160) },
		},
	},
	{
		id = "alfombra", nombre = "🟥 Alfombra", precio = 12,
		huecos = { { 0, -4.2 }, { 0, 1 } },
		partes = {
			{ tam = Vector3.new(8, 0.12, 5), pos = Vector3.new(0, 0.06, 0), color = Color3.fromRGB(190, 60, 70), sinColision = true },
		},
	},
	{
		id = "cuadro", nombre = "🖼️ Cuadro", precio = 10,
		huecos = { { -5.5, 9.4 }, { 0, 9.4 }, { 5.5, 9.4 } },
		partes = {
			{ tam = Vector3.new(3, 2.4, 0.2), pos = Vector3.new(0, 6.5, 0), color = MADERA, sinColision = true },
			{ tam = Vector3.new(2.6, 2, 0.25), pos = Vector3.new(0, 6.5, -0.03), color = Color3.fromRGB(100, 200, 255), material = Enum.Material.Neon, sinColision = true },
		},
	},
}

local PASTELES = {
	Color3.fromRGB(255, 220, 200), Color3.fromRGB(200, 230, 255), Color3.fromRGB(215, 255, 215),
	Color3.fromRGB(255, 245, 190), Color3.fromRGB(235, 215, 255), Color3.fromRGB(255, 210, 230),
}

local casas = {} -- la lista de casas: casas[1], casas[2]...
local logros = nil -- la lista de logros (para los trofeos), cuando esté lista

local carpeta = Instance.new("Folder")
carpeta.Name = "Casas"
carpeta.Parent = workspace

----------------------------------------------------------------------
-- 🧰 HERRAMIENTAS
----------------------------------------------------------------------

local function buscarMueble(id)
	for _, mueble in MUEBLES do
		if mueble.id == id then
			return mueble
		end
	end
	return nil
end

-- Enseña un mensajito en la pantalla de un jugador
local function avisar(jugador, texto, color)
	local pantallaJugador = jugador:FindFirstChild("PlayerGui")
	if not pantallaJugador then
		return
	end
	local viejo = pantallaJugador:FindFirstChild("AvisoCasa")
	if viejo then
		viejo:Destroy()
	end

	local pantalla = Instance.new("ScreenGui")
	pantalla.Name = "AvisoCasa"
	pantalla.ResetOnSpawn = false
	pantalla.Parent = pantallaJugador

	local mensaje = Instance.new("TextLabel")
	mensaje.Size = UDim2.fromScale(0.55, 0.09)
	mensaje.Position = UDim2.fromScale(0.5, 0.8)
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

----------------------------------------------------------------------
-- 🔨 CONSTRUIR UNA CASA
----------------------------------------------------------------------

-- "indice" es el número de la casa y "posicion" dónde está (en el suelo). Mira hacia el centro.
local function construirCasa(indice, posicion)
	local cf = CFrame.lookAt(posicion, Vector3.new(0, posicion.Y, posicion.Z)) -- su "delante" (-Z) mira a la calle
	local casa = { indice = indice, cf = cf, dueno = nil }

	local carpetaCasa = Instance.new("Folder")
	carpetaCasa.Name = "Casa_" .. indice
	carpetaCasa.Parent = carpeta
	casa.muebles = Instance.new("Folder")
	casa.muebles.Name = "Muebles"
	casa.muebles.Parent = carpetaCasa
	casa.trofeos = Instance.new("Folder")
	casa.trofeos.Name = "Trofeos"
	casa.trofeos.Parent = carpetaCasa

	local pared = PASTELES[(indice - 1) % #PASTELES + 1]

	local function parte(nombre, tamano, desplazamiento, color, material)
		local pieza = Instance.new("Part")
		pieza.Name = nombre
		pieza.Size = tamano
		pieza.CFrame = cf * CFrame.new(desplazamiento)
		pieza.Color = color
		pieza.Material = material or Enum.Material.SmoothPlastic
		pieza.Anchored = true
		pieza.CastShadow = false
		pieza.TopSurface = Enum.SurfaceType.Smooth
		pieza.BottomSurface = Enum.SurfaceType.Smooth
		pieza.Parent = carpetaCasa
		return pieza
	end

	-- El suelo, las paredes (el delante tiene un hueco para la puerta) y el tejado
	parte("Suelo", Vector3.new(20, PISO, 20), Vector3.new(0, PISO / 2, 0), Color3.fromRGB(200, 170, 130), Enum.Material.WoodPlanks)
	parte("ParedFondo", Vector3.new(21, 10, 1), Vector3.new(0, PISO + 5, 10), pared)
	parte("ParedIzquierda", Vector3.new(1, 10, 20), Vector3.new(-10, PISO + 5, 0), pared)
	parte("ParedDerecha", Vector3.new(1, 10, 20), Vector3.new(10, PISO + 5, 0), pared)
	parte("FrenteIzquierda", Vector3.new(8, 10, 1), Vector3.new(-6, PISO + 5, -10), pared)
	parte("FrenteDerecha", Vector3.new(8, 10, 1), Vector3.new(6, PISO + 5, -10), pared)
	parte("Dintel", Vector3.new(4, 3, 1), Vector3.new(0, PISO + 8.5, -10), pared)
	local tejado = parte("Tejado", Vector3.new(22, 1, 22), Vector3.new(0, PISO + 10.5, 0), Color3.fromRGB(170, 70, 60))
	parte("Porche", Vector3.new(8, PISO, 8), Vector3.new(0, PISO / 2, -14), Color3.fromRGB(180, 140, 100), Enum.Material.WoodPlanks)

	-- La luz de dentro (siempre encendida)
	local luzTecho = parte("LuzTecho", Vector3.new(4, 0.3, 4), Vector3.new(0, PISO + 9.8, 0), Color3.fromRGB(255, 240, 200), Enum.Material.Neon)
	luzTecho.CanCollide = false
	local luz = Instance.new("PointLight")
	luz.Range = 30
	luz.Brightness = 1.4
	luz.Shadows = false
	luz.Parent = luzTecho

	-- La puerta (cerrada para todos; el dueño entra con el botón E)
	local puerta = parte("Puerta", Vector3.new(4, 7, 1), Vector3.new(0, PISO + 3.5, -10), Color3.fromRGB(120, 75, 40), Enum.Material.Wood)
	casa.entrar = Instance.new("ProximityPrompt")
	casa.entrar.ActionText = "Entrar"
	casa.entrar.ObjectText = "🏠 Casa libre"
	casa.entrar.HoldDuration = 0.3
	casa.entrar.MaxActivationDistance = 12
	casa.entrar.RequiresLineOfSight = false
	casa.entrar.Parent = puerta

	-- La alfombrilla de dentro para SALIR
	local salida = parte("Salida", Vector3.new(4, 0.2, 2), Vector3.new(0, PISO + 0.1, -8.4), Color3.fromRGB(60, 200, 110), Enum.Material.Neon)
	salida.CanCollide = false
	casa.salir = Instance.new("ProximityPrompt")
	casa.salir.ActionText = "Salir de casa"
	casa.salir.ObjectText = "🚪 Puerta"
	casa.salir.HoldDuration = 0.3
	casa.salir.MaxActivationDistance = 8
	casa.salir.RequiresLineOfSight = false
	casa.salir.Parent = salida

	-- Las dos baldas de la estantería de trofeos (en la pared del fondo de la puerta, por dentro)
	for _, altura in { 4.2, 7.2 } do
		for _, lado in { -1, 1 } do
			parte("Balda", Vector3.new(7, 0.4, 1.2), Vector3.new(lado * 6, PISO + altura, -8.9), MADERA, Enum.Material.Wood)
		end
	end

	-- El cartel de encima del tejado
	local cartel = Instance.new("BillboardGui")
	cartel.Size = UDim2.fromOffset(300, 56)
	cartel.StudsOffset = Vector3.new(0, 5, 0)
	cartel.MaxDistance = 220
	cartel.AlwaysOnTop = true
	cartel.Parent = tejado
	casa.etiqueta = Instance.new("TextLabel")
	casa.etiqueta.Size = UDim2.fromScale(1, 1)
	casa.etiqueta.BackgroundTransparency = 1
	casa.etiqueta.Text = "🏠 Casa libre"
	casa.etiqueta.TextScaled = true
	casa.etiqueta.Font = Enum.Font.FredokaOne
	casa.etiqueta.TextColor3 = Color3.fromRGB(255, 255, 255)
	casa.etiqueta.TextStrokeTransparency = 0
	casa.etiqueta.Parent = cartel

	return casa
end

-- Las casas están en dos filas, a los dos lados de la zona de salida
for lado = -1, 1, 2 do
	for i = 1, AJUSTES.casasPorLado do
		local z = (i - (AJUSTES.casasPorLado + 1) / 2) * AJUSTES.separacion
		table.insert(casas, construirCasa(#casas + 1, Vector3.new(lado * AJUSTES.distanciaDelCentro, 0, z)))
	end
end

----------------------------------------------------------------------
-- 🛋️ MUEBLES Y 🏆 TROFEOS
----------------------------------------------------------------------

local function amueblar(casa, jugador)
	casa.muebles:ClearAllChildren()
	for _, mueble in MUEBLES do
		local cantidad = math.min(jugador:GetAttribute("Casa_" .. mueble.id) or 0, #mueble.huecos)
		for k = 1, cantidad do
			local hueco = mueble.huecos[k]
			for _, pieza in mueble.partes do
				local parte = Instance.new("Part")
				parte.Name = mueble.id
				parte.Size = pieza.tam
				parte.CFrame = casa.cf * CFrame.new(hueco[1] + pieza.pos.X, PISO + pieza.pos.Y, hueco[2] + pieza.pos.Z)
				parte.Color = pieza.color
				parte.Material = pieza.material or Enum.Material.SmoothPlastic
				parte.Shape = pieza.forma or Enum.PartType.Block
				parte.Anchored = true
				parte.CanCollide = not pieza.sinColision
				parte.CastShadow = false
				parte.TopSurface = Enum.SurfaceType.Smooth
				parte.BottomSurface = Enum.SurfaceType.Smooth
				parte.Parent = casa.muebles
				if pieza.luz then
					local lamparaLuz = Instance.new("PointLight")
					lamparaLuz.Color = Color3.fromRGB(255, 214, 140)
					lamparaLuz.Range = 22
					lamparaLuz.Brightness = 1.6
					lamparaLuz.Shadows = false
					lamparaLuz.Parent = parte
				end
			end
		end
	end
end

-- Un trofeo por cada logro: dorado si lo tienes, gris con un candado si todavía no
local function ponerTrofeos(casa, jugador)
	casa.trofeos:ClearAllChildren()
	local lista = logros
	if not lista then
		lista = {}
		for i = 1, 12 do
			table.insert(lista, { id = "?" .. i, icono = "🏅", nombre = "Logro" })
		end
	end

	for i, logro in lista do
		if i > 12 then
			break
		end
		local fila = (i - 1) // 6 -- 0 = la balda de abajo, 1 = la de arriba
		local columna = (i - 1) % 6
		local lado = if columna < 3 then -1 else 1
		local x = lado * (4 + 2 * (columna % 3))
		local cima = PISO + (if fila == 0 then 4.4 else 7.4) -- la altura de arriba de la balda
		local conseguido = jugador:GetAttribute("Logro_" .. logro.id) == true

		local pedestal = Instance.new("Part")
		pedestal.Name = "Pedestal"
		pedestal.Size = Vector3.new(1, 0.5, 1)
		pedestal.CFrame = casa.cf * CFrame.new(x, cima + 0.25, -8.9)
		pedestal.Color = Color3.fromRGB(90, 90, 100)
		pedestal.Anchored = true
		pedestal.CanCollide = false
		pedestal.Parent = casa.trofeos

		local copa = Instance.new("Part")
		copa.Name = "Trofeo_" .. logro.id
		copa.Shape = Enum.PartType.Ball
		copa.Size = Vector3.new(0.9, 0.9, 0.9)
		copa.CFrame = casa.cf * CFrame.new(x, cima + 0.95, -8.9)
		copa.Color = if conseguido then Color3.fromRGB(255, 200, 40) else Color3.fromRGB(110, 110, 120)
		copa.Material = if conseguido then Enum.Material.Neon else Enum.Material.SmoothPlastic
		copa.Transparency = if conseguido then 0 else 0.4
		copa.Anchored = true
		copa.CanCollide = false
		copa.Parent = casa.trofeos

		local cartel = Instance.new("BillboardGui")
		cartel.Size = UDim2.fromOffset(70, 70)
		cartel.StudsOffset = Vector3.new(0, 1.3, 0)
		cartel.MaxDistance = 40
		cartel.Parent = copa
		local icono = Instance.new("TextLabel")
		icono.Size = UDim2.fromScale(1, 1)
		icono.BackgroundTransparency = 1
		icono.Text = if conseguido then logro.icono else "🔒"
		icono.TextScaled = true
		icono.Parent = cartel
	end
end

-- La lista de logros la crea el script Logros (si está, enseñamos sus iconos en los trofeos)
task.spawn(function()
	local catalogo = ReplicatedStorage:WaitForChild("CatalogoLogros", 20)
	if not catalogo then
		return
	end
	local fichas = catalogo:GetChildren()
	table.sort(fichas, function(a, b)
		return a:GetAttribute("Orden") < b:GetAttribute("Orden")
	end)
	local lista = {}
	for _, ficha in fichas do
		table.insert(lista, { id = ficha:GetAttribute("Id"), icono = ficha:GetAttribute("Icono"), nombre = ficha:GetAttribute("Nombre") })
	end
	logros = lista
	for _, casa in casas do
		if casa.dueno then
			ponerTrofeos(casa, casa.dueno)
		end
	end
end)

----------------------------------------------------------------------
-- 🚪 ENTRAR Y SALIR
----------------------------------------------------------------------

local function casaDe(jugador)
	local numero = jugador:GetAttribute("CasaNumero")
	return numero and casas[numero]
end

local function irACasa(jugador)
	local casa = casaDe(jugador)
	if not casa then
		avisar(jugador, "Todavía no tienes casa 🏠", Color3.fromRGB(200, 60, 60))
		return
	end
	if jugador:GetAttribute("EnCarrera") then
		avisar(jugador, "No puedes ir a casa durante la carrera 🏁", Color3.fromRGB(200, 60, 60))
		return
	end
	if jugador:GetAttribute("EnCasa") or not jugador.Character then
		return
	end

	jugador:SetAttribute("EnCasa", true) -- el script Niveles no te "tira" por estar lejos de tu nivel
	local destino = casa.cf * CFrame.new(0, 3.5, -6) * CFrame.Angles(0, math.pi, 0) -- mirando hacia dentro
	pcall(function()
		jugador:RequestStreamAroundAsync(destino.Position, 5)
	end)
	local personaje = jugador.Character
	if personaje and personaje.Parent then
		personaje:PivotTo(destino)
		local raiz = personaje:FindFirstChild("HumanoidRootPart")
		if raiz then
			raiz.AssemblyLinearVelocity = Vector3.zero
		end
	end
	avisar(jugador, "🏠 ¡Bienvenido a tu casa!", Color3.fromRGB(40, 160, 80))
end

local function salirDeCasa(jugador)
	if not jugador:GetAttribute("EnCasa") then
		return
	end
	local casa = casaDe(jugador)
	local nivel = jugador:GetAttribute("Nivel") or 1
	jugador:SetAttribute("EnCasa", nil)
	if nivel > 1 or not casa then
		jugador:SetAttribute("SaltarANivel", nivel) -- el script Niveles te lleva de vuelta a tu nivel
	elseif jugador.Character then
		jugador.Character:PivotTo(casa.cf * CFrame.new(0, 3.5, -17)) -- fuera, delante de la puerta
	end
end

for _, casa in casas do
	casa.entrar.Triggered:Connect(function(jugador)
		if casa.dueno == jugador then
			irACasa(jugador)
		elseif casa.dueno then
			avisar(jugador, "🔒 Esta casa es de " .. casa.dueno.DisplayName, Color3.fromRGB(200, 60, 60))
		else
			avisar(jugador, "Esta casa está libre. ¡Todavía no es de nadie!", Color3.fromRGB(90, 90, 120))
		end
	end)
	casa.salir.Triggered:Connect(function(jugador)
		if casa.dueno == jugador then
			salirDeCasa(jugador)
		end
	end)
end

----------------------------------------------------------------------
-- 👤 CADA JUGADOR SE QUEDA CON UNA CASA
----------------------------------------------------------------------

local function adjudicarCasa(jugador)
	for _, casa in casas do
		if not casa.dueno then
			casa.dueno = jugador
			jugador:SetAttribute("CasaNumero", casa.indice)
			casa.etiqueta.Text = "🏠 Casa de " .. jugador.DisplayName
			casa.entrar.ObjectText = "🏠 Casa de " .. jugador.DisplayName
			amueblar(casa, jugador)
			ponerTrofeos(casa, jugador)
			return
		end
	end
	warn("🏠 No quedan casas libres para " .. jugador.Name)
end

local function liberarCasa(jugador)
	local casa = casaDe(jugador)
	if casa and casa.dueno == jugador then
		casa.dueno = nil
		casa.etiqueta.Text = "🏠 Casa libre"
		casa.entrar.ObjectText = "🏠 Casa libre"
		casa.muebles:ClearAllChildren()
		casa.trofeos:ClearAllChildren()
	end
end

local function prepararJugador(jugador)
	jugador.CharacterAdded:Connect(function()
		jugador:SetAttribute("EnCasa", nil) -- si reapareces, ya no estás en casa
	end)

	-- Cuando cambia un mueble o un logro (o se carga lo guardado), la casa se pone al día
	jugador.AttributeChanged:Connect(function(nombre)
		local casa = casaDe(jugador)
		if not casa then
			return
		end
		if string.sub(nombre, 1, 5) == "Casa_" then
			amueblar(casa, jugador)
		elseif string.sub(nombre, 1, 6) == "Logro_" then
			ponerTrofeos(casa, jugador)
		end
	end)

	adjudicarCasa(jugador)
end

Players.PlayerAdded:Connect(prepararJugador)
for _, jugador in Players:GetPlayers() do
	prepararJugador(jugador)
end
Players.PlayerRemoving:Connect(liberarCasa)

----------------------------------------------------------------------
-- 📋 LA LISTA PARA LA PANTALLA Y EL BOTÓN DE COMPRAR
----------------------------------------------------------------------

local catalogoMuebles = Instance.new("Folder")
catalogoMuebles.Name = "CatalogoMuebles"
for orden, mueble in MUEBLES do
	local ficha = Instance.new("Folder")
	ficha.Name = mueble.id
	ficha:SetAttribute("Id", mueble.id)
	ficha:SetAttribute("Nombre", mueble.nombre)
	ficha:SetAttribute("Precio", mueble.precio)
	ficha:SetAttribute("Maximo", #mueble.huecos)
	ficha:SetAttribute("Orden", orden)
	ficha.Parent = catalogoMuebles
end

local evento = Instance.new("RemoteEvent")
evento.Name = "CasaAccion"
evento.Parent = ReplicatedStorage
catalogoMuebles.Parent = ReplicatedStorage -- al final, cuando ya está todo listo

local ultimoPedido = {}
Players.PlayerRemoving:Connect(function(jugador)
	ultimoPedido[jugador] = nil
end)

local function comprarMueble(jugador, id)
	local mueble = buscarMueble(id)
	if not mueble then
		return
	end
	if not casaDe(jugador) then
		avisar(jugador, "Todavía no tienes casa 🏠", Color3.fromRGB(200, 60, 60))
		return
	end
	local atributo = "Casa_" .. id
	local cantidad = jugador:GetAttribute(atributo) or 0
	if cantidad >= #mueble.huecos then
		avisar(jugador, "¡Ya no caben más! (" .. mueble.nombre .. " " .. cantidad .. "/" .. #mueble.huecos .. ")", Color3.fromRGB(90, 90, 120))
		return
	end
	local marcador = jugador:FindFirstChild("leaderstats")
	local monedas = marcador and marcador:FindFirstChild("Monedas")
	if not monedas then
		avisar(jugador, "Todavía no tienes monedas 🪙", Color3.fromRGB(200, 60, 60))
		return
	end
	if monedas.Value < mueble.precio then
		avisar(jugador, "Te faltan " .. (mueble.precio - monedas.Value) .. " 🪙 para " .. mueble.nombre, Color3.fromRGB(200, 60, 60))
		return
	end
	monedas.Value -= mueble.precio
	jugador:SetAttribute(atributo, cantidad + 1) -- esto también coloca el mueble en la casa
	avisar(jugador, "¡" .. mueble.nombre .. " para tu casa! 🎉", Color3.fromRGB(40, 160, 80))
end

evento.OnServerEvent:Connect(function(jugador, accion, id)
	-- Comprobamos que lo que nos manda tiene sentido (¡nunca nos fiamos de la pantalla!)
	if type(accion) ~= "string" or (id ~= nil and type(id) ~= "string") then
		return
	end
	local ahora = os.clock()
	if ahora - (ultimoPedido[jugador] or -100) < 0.4 then
		return
	end
	ultimoPedido[jugador] = ahora

	if accion == "ir" then
		irACasa(jugador)
	elseif accion == "salir" then
		salirDeCasa(jugador)
	elseif accion == "comprar" and id then
		comprarMueble(jugador, id)
	end
end)

print("🏠 Barrio de casitas listo.")
