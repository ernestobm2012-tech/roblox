--[[
	🏢 PISOS PARA TU CASA (hasta 4)
	Tu casa empieza con 1 piso. Con monedas puedes comprar más pisos, hasta 4 en total:
	  🛏️ Piso 2: dormitorio (2 camas)      🎮 Piso 3: sala de juegos (tele, sofá y puffs)
	  🔭 Piso 4: mirador de cristal con telescopio
	Cada piso nuevo sube el tejado. Para moverte entre pisos usa el botón "🛗 Ascensor" de
	"🏠 Mi casa" (también lo pueden usar tus visitas). Los pisos que compras se guardan.

	📋 DÓNDE VA: en Roblox Studio, dentro de ServerScriptService, como "Script".
	(Usa la marca "CasaOrigen" y la pieza "Tejado" del script Casas, el atributo "Casa_pisos" del jugador,
	que guarda el script Guardado, y el marcador de monedas de MiMundo.)
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")

-- ⚙️ AJUSTES: ¡cambia estos valores y mira qué pasa!
local AJUSTES = {
	precios = { 150, 300, 600 }, -- lo que cuestan el piso 2, el 3 y el 4
	maximoDePisos = 4,
}

local NOMBRES = { "Planta baja", "🛏️ Dormitorio", "🎮 Sala de juegos", "🔭 Mirador" }
local PISO = 0.6 -- la altura del suelo de la planta baja (igual que en Casas)
local ALTO = 11 -- lo que sube cada piso

local function yBase(k)
	return PISO + ALTO * (k - 1)
end

local ultimaCompra = {}
local redibujoPendiente = {}

----------------------------------------------------------------------
-- 📋 LO QUE VE LA PANTALLA
----------------------------------------------------------------------

local catalogo = Instance.new("Folder")
catalogo.Name = "CatalogoPisos"
for k = 2, AJUSTES.maximoDePisos do
	local ficha = Instance.new("Folder")
	ficha.Name = "Piso" .. k
	ficha:SetAttribute("Numero", k)
	ficha:SetAttribute("Nombre", NOMBRES[k])
	ficha:SetAttribute("Precio", AJUSTES.precios[k - 1])
	ficha.Parent = catalogo
end
catalogo.Parent = ReplicatedStorage

local evento = Instance.new("RemoteEvent")
evento.Name = "PisosAccion"
evento.Parent = ReplicatedStorage

local function avisar(jugador, texto, color)
	local pantallaJugador = jugador:FindFirstChild("PlayerGui")
	if not pantallaJugador then
		return
	end
	local viejo = pantallaJugador:FindFirstChild("AvisoPisos")
	if viejo then
		viejo:Destroy()
	end
	local pantalla = Instance.new("ScreenGui")
	pantalla.Name = "AvisoPisos"
	pantalla.ResetOnSpawn = false
	pantalla.Parent = pantallaJugador
	local mensaje = Instance.new("TextLabel")
	mensaje.Size = UDim2.fromOffset(460, 44)
	mensaje.Position = UDim2.new(0.5, -230, 0.22, 0)
	mensaje.BackgroundColor3 = color
	mensaje.BackgroundTransparency = 0.12
	mensaje.TextColor3 = Color3.fromRGB(255, 255, 255)
	mensaje.TextScaled = true
	mensaje.Font = Enum.Font.FredokaOne
	mensaje.Text = texto
	mensaje.Parent = pantalla
	Instance.new("UICorner", mensaje).CornerRadius = UDim.new(0, 12)
	task.delay(4, function()
		pantalla:Destroy()
	end)
end

----------------------------------------------------------------------
-- 🧰 CONSTRUIR
----------------------------------------------------------------------

local function buscarOrigen(indice)
	for _, marca in CollectionService:GetTagged("CasaOrigen") do
		if marca:GetAttribute("Indice") == indice then
			return marca
		end
	end
	return nil
end

local function duenoDe(indice)
	for _, jugador in Players:GetPlayers() do
		if jugador:GetAttribute("CasaNumero") == indice then
			return jugador
		end
	end
	return nil
end

local function pisosDe(jugador)
	local n = jugador and jugador:GetAttribute("Casa_pisos")
	if type(n) ~= "number" then
		return 1
	end
	return math.clamp(math.floor(n), 1, AJUSTES.maximoDePisos)
end

local function pieza(padre, nombre, tamano, cf, color, material, forma, transparencia)
	local p = Instance.new("Part")
	p.Name = nombre
	p.Size = tamano
	p.CFrame = cf
	p.Color = color
	p.Material = material or Enum.Material.SmoothPlastic
	p.Shape = forma or Enum.PartType.Block
	p.Transparency = transparencia or 0
	p.Anchored = true
	p.CanCollide = true
	p.CastShadow = false
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	p.Parent = padre
	return p
end

local BOLA = Enum.PartType.Ball

-- Lo que hay dentro de cada piso (x, z medidos desde el centro de la casa; y = suelo del piso)
local function decorar(carpeta, base, k)
	local y = yBase(k)
	local function p(nombre, tam, x, dy, z, color, material, forma, transp)
		local obj = pieza(carpeta, nombre, tam, base * CFrame.new(x, y + dy, z), color, material, forma, transp)
		obj.CanCollide = false -- el decorado no estorba para andar
		return obj
	end
	if k == 2 then
		for i, x in { -6, 6 } do
			p("CamaMarco", Vector3.new(4, 1, 7), x, 0.5, 5.5, if i == 1 then Color3.fromRGB(100, 140, 230) else Color3.fromRGB(230, 120, 165), Enum.Material.Wood)
			p("Colchon", Vector3.new(3.6, 0.5, 6.6), x, 1.25, 5.5, Color3.fromRGB(250, 250, 255), Enum.Material.Fabric)
			p("Almohada", Vector3.new(3, 0.5, 1.4), x, 1.7, 8.2, Color3.fromRGB(255, 240, 200), Enum.Material.Fabric)
		end
		p("Alfombra", Vector3.new(9, 0.12, 7), 0, 0.06, -1, Color3.fromRGB(255, 190, 215), Enum.Material.Fabric)
		p("Armario", Vector3.new(4, 7, 1.6), 0, 3.5, 9.1, Color3.fromRGB(150, 100, 60), Enum.Material.Wood)
		p("Peluche", Vector3.new(1.4, 1.4, 1.4), 0, 0.7, 2, Color3.fromRGB(190, 130, 80), Enum.Material.Fabric, BOLA)
	elseif k == 3 then
		p("Alfombra", Vector3.new(12, 0.12, 9), 0, 0.06, -1, Color3.fromRGB(90, 190, 120), Enum.Material.Fabric)
		p("TeleMarco", Vector3.new(8, 4, 0.5), 0, 4.5, 9.4, Color3.fromRGB(30, 30, 35))
		p("TelePantalla", Vector3.new(7.4, 3.4, 0.1), 0, 4.5, 9.1, Color3.fromRGB(60, 120, 230), Enum.Material.Neon)
		p("SofaAsiento", Vector3.new(8, 1.2, 3), 0, 0.6, 2.6, Color3.fromRGB(200, 70, 90), Enum.Material.Fabric)
		p("SofaRespaldo", Vector3.new(8, 2.2, 0.8), 0, 2.1, 1.2, Color3.fromRGB(180, 55, 75), Enum.Material.Fabric)
		p("Puf", Vector3.new(2.4, 2.4, 2.4), -7, 1.2, -3, Color3.fromRGB(255, 200, 60), Enum.Material.Fabric, BOLA)
		p("Puf", Vector3.new(2.4, 2.4, 2.4), 7, 1.2, -3, Color3.fromRGB(80, 170, 255), Enum.Material.Fabric, BOLA)
		p("Puf", Vector3.new(2.4, 2.4, 2.4), -6, 1.2, -6.5, Color3.fromRGB(170, 100, 230), Enum.Material.Fabric, BOLA)
		p("Maquinita", Vector3.new(3, 6, 2.5), -8, 3, 6, Color3.fromRGB(60, 60, 130))
		p("MaquinitaPantalla", Vector3.new(2.4, 1.6, 0.1), -8, 4.2, 4.7, Color3.fromRGB(255, 220, 80), Enum.Material.Neon)
	elseif k == 4 then
		local alfombra = p("Alfombra", Vector3.new(0.12, 10, 10), 0, 0.06, -1, Color3.fromRGB(70, 90, 170), Enum.Material.Fabric, Enum.PartType.Cylinder)
		alfombra.CFrame = base * CFrame.new(0, y + 0.06, -1) * CFrame.Angles(0, 0, math.rad(90))
		p("TelescopioPie", Vector3.new(0.4, 3, 0.4), 0, 1.5, -1, Color3.fromRGB(80, 80, 90), Enum.Material.Metal)
		local tubo = p("TelescopioTubo", Vector3.new(0.9, 0.9, 4.5), 0, 3.4, -2.2, Color3.fromRGB(230, 230, 240), Enum.Material.Metal, Enum.PartType.Cylinder)
		tubo.CFrame = base * CFrame.new(0, y + 3.4, -2.4) * CFrame.Angles(math.rad(-20), math.rad(90), 0)
		p("TelescopioLente", Vector3.new(1.1, 1.1, 0.3), 0, 4.1, -4.4, Color3.fromRGB(100, 200, 255), Enum.Material.Neon, BOLA)
		p("Sillon", Vector3.new(3.5, 2, 3.5), 6, 1, 5, Color3.fromRGB(230, 150, 70), Enum.Material.Fabric)
		p("Sillon", Vector3.new(3.5, 2, 3.5), -6, 1, 5, Color3.fromRGB(230, 150, 70), Enum.Material.Fabric)
		p("Planta", Vector3.new(2, 2.5, 2), 0, 1.25, 8.3, Color3.fromRGB(60, 160, 70), Enum.Material.Grass, BOLA)
	end
end

local function construir(origen, jugador)
	local casaCarpeta = origen.Parent
	local n = pisosDe(jugador)
	local base = origen.CFrame

	local viejo = casaCarpeta:FindFirstChild("Pisos")
	if viejo then
		viejo:Destroy()
	end
	local carpeta = Instance.new("Folder")
	carpeta.Name = "Pisos"
	carpeta.Parent = casaCarpeta

	-- El tejado siempre va arriba del todo
	local tejado = casaCarpeta:FindFirstChild("Tejado")
	if tejado then
		tejado.CFrame = base * CFrame.new(0, yBase(n) + 10.5, 0)
	end
	if n == 1 then
		return
	end

	local fondo = casaCarpeta:FindFirstChild("ParedFondo")
	local colorPared = fondo and fondo.Color or Color3.fromRGB(240, 230, 210)

	-- Los suelos entre piso y piso
	for k = 1, n - 1 do
		pieza(carpeta, "Losa", Vector3.new(22, 1, 22), base * CFrame.new(0, yBase(k) + 10.5, 0), Color3.fromRGB(200, 170, 130), Enum.Material.WoodPlanks)
	end

	-- Las paredes, la luz y el decorado de cada piso de arriba
	for k = 2, n do
		local y = yBase(k)
		local cristal = k == 4 -- el mirador tiene paredes de cristal
		local color = if cristal then Color3.fromRGB(170, 215, 240) else colorPared
		local material = if cristal then Enum.Material.Glass else Enum.Material.SmoothPlastic
		local transp = if cristal then 0.55 else 0
		for _, datos in {
			{ Vector3.new(21, 10, 1), Vector3.new(0, y + 5, 10) },
			{ Vector3.new(21, 10, 1), Vector3.new(0, y + 5, -10) },
			{ Vector3.new(1, 10, 20), Vector3.new(-10, y + 5, 0) },
			{ Vector3.new(1, 10, 20), Vector3.new(10, y + 5, 0) },
		} do
			local pared = pieza(carpeta, "ParedPiso", datos[1], base * CFrame.new(datos[2]), color, material, nil, transp)
			pared:SetAttribute("Pintable", not cristal)
		end
		if not cristal then
			-- unas ventanas en la fachada
			for _, x in { -5, 5 } do
				local ventana = pieza(carpeta, "Ventana", Vector3.new(4, 3.5, 0.2), base * CFrame.new(x, y + 5.5, -10.6), Color3.fromRGB(150, 210, 245), Enum.Material.Glass, nil, 0.4)
				ventana.CanCollide = false
			end
		end
		local luzTecho = pieza(carpeta, "LuzTecho", Vector3.new(4, 0.3, 4), base * CFrame.new(0, y + 9.8, 0), Color3.fromRGB(255, 240, 200), Enum.Material.Neon)
		luzTecho.CanCollide = false
		local luz = Instance.new("PointLight")
		luz.Range = 30
		luz.Brightness = 1.2
		luz.Shadows = false
		luz.Parent = luzTecho
		decorar(carpeta, base, k)
	end
end

-- Si el dueño repinta las paredes, las de arriba se repintan igual
local function repintar(origen)
	local carpeta = origen.Parent:FindFirstChild("Pisos")
	local fondo = origen.Parent:FindFirstChild("ParedFondo")
	if not carpeta or not fondo then
		return
	end
	for _, objeto in carpeta:GetChildren() do
		if objeto.Name == "ParedPiso" and objeto:GetAttribute("Pintable") then
			objeto.Color = fondo.Color
		end
	end
end

local function programar(jugador)
	if redibujoPendiente[jugador] then
		return
	end
	redibujoPendiente[jugador] = true
	task.delay(1.5, function()
		redibujoPendiente[jugador] = nil
		if not jugador.Parent then
			return
		end
		local numero = jugador:GetAttribute("CasaNumero")
		local origen = numero and buscarOrigen(numero)
		if origen then
			construir(origen, jugador)
		end
	end)
end

local function vigilar(jugador)
	jugador.AttributeChanged:Connect(function(nombre)
		if nombre == "CasaNumero" or nombre == "Casa_pisos" then
			programar(jugador)
		elseif nombre == "Casa_pared" or string.sub(nombre, 1, 10) == "Casa_pared" then
			task.delay(0.8, function()
				local numero = jugador:GetAttribute("CasaNumero")
				local origen = numero and buscarOrigen(numero)
				if origen then
					repintar(origen)
				end
			end)
		end
	end)
	if jugador:GetAttribute("CasaNumero") then
		programar(jugador)
	end
end

Players.PlayerAdded:Connect(vigilar)
for _, jugador in Players:GetPlayers() do
	vigilar(jugador)
end

Players.PlayerRemoving:Connect(function(jugador)
	ultimaCompra[jugador] = nil
	redibujoPendiente[jugador] = nil
	-- Se va el dueño: la casa vuelve a tener 1 piso para el siguiente
	local numero = jugador:GetAttribute("CasaNumero")
	local origen = numero and buscarOrigen(numero)
	if origen then
		construir(origen, nil)
	end
end)

----------------------------------------------------------------------
-- 🛒 COMPRAR PISOS Y 🛗 ASCENSOR
----------------------------------------------------------------------

evento.OnServerEvent:Connect(function(jugador, accion, valor)
	if type(accion) ~= "string" then
		return
	end

	if accion == "comprar" then
		local ahora = os.clock()
		if ultimaCompra[jugador] and ahora - ultimaCompra[jugador] < 1 then
			return
		end
		ultimaCompra[jugador] = ahora
		if not jugador:GetAttribute("CasaNumero") then
			return
		end
		local actuales = pisosDe(jugador)
		if actuales >= AJUSTES.maximoDePisos then
			return
		end
		local precio = AJUSTES.precios[actuales]
		local marcador = jugador:FindFirstChild("leaderstats")
		local monedas = marcador and marcador:FindFirstChild("Monedas")
		if not monedas or monedas.Value < precio then
			avisar(jugador, "Te faltan monedas 🪙 (cuesta " .. precio .. ")", Color3.fromRGB(200, 60, 60))
			return
		end
		monedas.Value -= precio
		jugador:SetAttribute("Casa_pisos", actuales + 1)
		avisar(jugador, "🏢 ¡Piso " .. (actuales + 1) .. " listo! " .. NOMBRES[actuales + 1], Color3.fromRGB(60, 150, 90))

	elseif accion == "ir" and type(valor) == "number" and valor == valor then
		-- El ascensor: solo dentro de una casa, y solo a pisos que existan
		if jugador:GetAttribute("EnCasa") ~= true then
			return
		end
		local indice = jugador:GetAttribute("CasaVisitada") or jugador:GetAttribute("CasaNumero")
		local origen = indice and buscarOrigen(indice)
		if not origen then
			return
		end
		local piso = math.floor(valor)
		if piso < 1 or piso > pisosDe(duenoDe(indice)) then
			return
		end
		local personaje = jugador.Character
		if personaje and personaje.Parent then
			personaje:PivotTo(origen.CFrame * CFrame.new(0, yBase(piso) + 3.5, -7.2) * CFrame.Angles(0, math.pi, 0))
			local raiz = personaje:FindFirstChild("HumanoidRootPart")
			if raiz then
				raiz.AssemblyLinearVelocity = Vector3.zero
			end
		end
	end
end)

print("🏢 Pisos listos.")
