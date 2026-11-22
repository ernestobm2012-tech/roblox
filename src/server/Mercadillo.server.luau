--[[
	🛍️ EL PUESTECITO DEL JARDÍN
	En el jardín de cada casa hay un puestecito con una mesa y un toldo. Su dueño puede VENDER sus muebles
	a los demás jugadores, ¡con precios de MONEDAS DEL JUEGO (nada de Robux)!
	  - El dueño elige en "🏠 Mi casa" → "🛍️ Mi puesto" qué mueble vende y a qué precio (de 1 a 999 🪙).
	    Caben 3 cosas a la vez.
	  - Los demás se acercan al puesto y pulsan E en el mueble que quieren comprar.
	  - Si compran, el mueble pasa de la casa del vendedor a la de quien lo compra y las monedas hacen
	    el camino contrario. Las dos cosas pasan a la vez, así que no se puede perder ni copiar nada.
	  - Solo se vende mientras el dueño está jugando.

	📋 DÓNDE VA: en Roblox Studio, dentro de ServerScriptService, como "Script".
	(Usa la marca "CasaOrigen" que pone el script Casas y los muebles "Casa_cama", etc. Los anuncios del
	puesto son atributos "Venta_1_id" y "Venta_1_precio". Habla con la pantalla con un RemoteEvent.)
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local TweenService = game:GetService("TweenService")

-- ⚙️ AJUSTES
local AJUSTES = {
	huecos = 3, -- cuántas cosas caben a la vez en el puesto
	precioMinimo = 1,
	precioMaximo = 999,
}

local evento = Instance.new("RemoteEvent")
evento.Name = "MercadilloAccion"
evento.Parent = ReplicatedStorage

local puestos = {} -- puestos[numeroDeCasa] = { cartel = ..., huecos = { { cubo, boton, etiqueta }, ... } }

----------------------------------------------------------------------
-- 🧰 HERRAMIENTAS
----------------------------------------------------------------------

local function avisar(jugador, texto, color)
	local pantallaJugador = jugador:FindFirstChild("PlayerGui")
	if not pantallaJugador then
		return
	end
	local viejo = pantallaJugador:FindFirstChild("AvisoPuesto")
	if viejo then
		viejo:Destroy()
	end

	local pantalla = Instance.new("ScreenGui")
	pantalla.Name = "AvisoPuesto"
	pantalla.ResetOnSpawn = false
	pantalla.Parent = pantallaJugador

	local mensaje = Instance.new("TextLabel")
	mensaje.Size = UDim2.fromScale(0.55, 0.09)
	mensaje.Position = UDim2.fromScale(0.5, 0.65)
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

local function monedasDe(jugador)
	local marcador = jugador:FindFirstChild("leaderstats")
	return marcador and marcador:FindFirstChild("Monedas")
end

-- La ficha de un mueble en la lista que publica el script Casas
local function fichaDeMueble(id)
	local catalogo = ReplicatedStorage:FindFirstChild("CatalogoMuebles")
	return catalogo and catalogo:FindFirstChild(id)
end

local function duenoDe(numeroDeCasa)
	for _, jugador in Players:GetPlayers() do
		if jugador:GetAttribute("CasaNumero") == numeroDeCasa then
			return jugador
		end
	end
	return nil
end

----------------------------------------------------------------------
-- 🛒 COMPRAR EN UN PUESTO
----------------------------------------------------------------------

local function comprar(numeroDeCasa, hueco, comprador)
	local vendedor = duenoDe(numeroDeCasa)
	if not vendedor then
		return
	end
	if vendedor == comprador then
		avisar(comprador, "Es tu puesto 😄 Los demás jugadores pueden comprarte esto", Color3.fromRGB(90, 90, 120))
		return
	end

	local id = vendedor:GetAttribute("Venta_" .. hueco .. "_id")
	local precio = vendedor:GetAttribute("Venta_" .. hueco .. "_precio")
	local ficha = type(id) == "string" and fichaDeMueble(id)
	if not ficha or type(precio) ~= "number" then
		return
	end
	local atributo = "Casa_" .. id

	-- Comprobamos TODO antes de mover nada
	if (vendedor:GetAttribute(atributo) or 0) < 1 then
		avisar(comprador, "Ya no le queda ese mueble 😕", Color3.fromRGB(200, 60, 60))
		return
	end
	if not comprador:GetAttribute("CasaNumero") then
		avisar(comprador, "Necesitas una casa para guardar el mueble 🏠", Color3.fromRGB(200, 60, 60))
		return
	end
	if (comprador:GetAttribute(atributo) or 0) >= ficha:GetAttribute("Maximo") then
		avisar(comprador, "¡Tu casa ya está completa de " .. ficha:GetAttribute("Nombre") .. "!", Color3.fromRGB(90, 90, 120))
		return
	end
	local monedasComprador = monedasDe(comprador)
	local monedasVendedor = monedasDe(vendedor)
	if not monedasComprador or not monedasVendedor then
		return
	end
	if monedasComprador.Value < precio then
		avisar(comprador, "Te faltan " .. (precio - monedasComprador.Value) .. " 🪙", Color3.fromRGB(200, 60, 60))
		return
	end

	-- ¡Trato hecho! (todo seguido, sin esperas, para que no pueda salir mal)
	monedasComprador.Value -= precio
	monedasVendedor.Value += precio
	vendedor:SetAttribute(atributo, (vendedor:GetAttribute(atributo) or 0) - 1)
	comprador:SetAttribute(atributo, (comprador:GetAttribute(atributo) or 0) + 1)
	if (vendedor:GetAttribute(atributo) or 0) < 1 then
		vendedor:SetAttribute("Venta_" .. hueco .. "_id", nil) -- se ha acabado: lo quitamos del puesto
		vendedor:SetAttribute("Venta_" .. hueco .. "_precio", nil)
	end
	vendedor:SetAttribute("Estad_ventas", (vendedor:GetAttribute("Estad_ventas") or 0) + 1)
	comprador:SetAttribute("Estad_muebles", (comprador:GetAttribute("Estad_muebles") or 0) + 1) -- para el reto semanal

	avisar(comprador, "🛍️ ¡Has comprado " .. ficha:GetAttribute("Nombre") .. " por " .. precio .. " 🪙!", Color3.fromRGB(40, 160, 80))
	avisar(vendedor, "💰 " .. comprador.DisplayName .. " te ha comprado " .. ficha:GetAttribute("Nombre") .. " por " .. precio .. " 🪙", Color3.fromRGB(190, 130, 0))
end

----------------------------------------------------------------------
-- 🔨 CONSTRUIR EL PUESTO DE UNA CASA
----------------------------------------------------------------------

local function construirPuesto(origen)
	local numero = origen:GetAttribute("Indice")
	if not numero or puestos[numero] then
		return
	end
	local carpeta = Instance.new("Folder")
	carpeta.Name = "Puesto"
	carpeta.Parent = origen.Parent

	local function parte(nombre, tamano, x, y, z, color, material)
		local pieza = Instance.new("Part")
		pieza.Name = nombre
		pieza.Size = tamano
		pieza.CFrame = origen.CFrame * CFrame.new(x, y, z)
		pieza.Color = color
		pieza.Material = material or Enum.Material.SmoothPlastic
		pieza.Anchored = true
		pieza.CastShadow = false
		pieza.Parent = carpeta
		return pieza
	end

	local madera = Color3.fromRGB(150, 100, 60)
	-- La mesa (con cuatro patas) y el toldo de rayas rojas y blancas
	parte("Mesa", Vector3.new(4.8, 0.25, 2.4), -7, 1.4, -20, Color3.fromRGB(190, 140, 90), Enum.Material.Wood)
	for _, dx in { -2.2, 2.2 } do
		for _, dz in { -1, 1 } do
			parte("Pata", Vector3.new(0.25, 1.3, 0.25), -7 + dx, 0.65, -20 + dz, madera, Enum.Material.Wood)
		end
	end
	for _, dx in { -2.4, 2.4 } do
		parte("Palo", Vector3.new(0.2, 3.6, 0.2), -7 + dx, 1.8, -21.1, madera, Enum.Material.Wood)
	end
	local toldo = parte("Toldo", Vector3.new(2.7, 0.2, 3.4), -8.35, 3.7, -20.2, Color3.fromRGB(220, 60, 60))
	parte("Toldo", Vector3.new(2.7, 0.2, 3.4), -5.65, 3.7, -20.2, Color3.fromRGB(250, 250, 250))

	-- El cartel del puesto
	local cartelGui = Instance.new("BillboardGui")
	cartelGui.Size = UDim2.fromOffset(260, 46)
	cartelGui.StudsOffset = Vector3.new(0, 2.2, 0)
	cartelGui.MaxDistance = 80
	cartelGui.Parent = toldo
	local cartel = Instance.new("TextLabel")
	cartel.Size = UDim2.fromScale(1, 1)
	cartel.BackgroundTransparency = 1
	cartel.Text = "🛍️ Puesto libre"
	cartel.TextScaled = true
	cartel.Font = Enum.Font.FredokaOne
	cartel.TextColor3 = Color3.fromRGB(255, 255, 255)
	cartel.TextStrokeTransparency = 0
	cartel.Parent = cartelGui

	-- Los tres huecos de la mesa: un cubito de color por cada mueble en venta
	local huecos = {}
	for k = 1, AJUSTES.huecos do
		local x = -7 + (k - 2) * 1.5
		local cubo = parte("Venta_" .. k, Vector3.new(0.9, 0.9, 0.9), x, 1.975, -20, Color3.fromRGB(200, 200, 200))
		cubo.Transparency = 1
		cubo.CanCollide = false

		local boton = Instance.new("ProximityPrompt")
		boton.ActionText = "Comprar"
		boton.ObjectText = "🛍️ Puesto"
		boton.HoldDuration = 0.4
		boton.MaxActivationDistance = 9
		boton.RequiresLineOfSight = false
		boton.Enabled = false
		boton.Parent = cubo
		boton.Triggered:Connect(function(jugador)
			comprar(numero, k, jugador)
		end)

		local gui = Instance.new("BillboardGui")
		gui.Size = UDim2.fromOffset(190, 46)
		gui.StudsOffset = Vector3.new(0, 1.3, 0)
		gui.MaxDistance = 40
		gui.Enabled = false
		gui.Parent = cubo
		local etiqueta = Instance.new("TextLabel")
		etiqueta.Size = UDim2.fromScale(1, 1)
		etiqueta.BackgroundTransparency = 1
		etiqueta.TextScaled = true
		etiqueta.Font = Enum.Font.FredokaOne
		etiqueta.TextColor3 = Color3.fromRGB(255, 255, 255)
		etiqueta.TextStrokeTransparency = 0
		etiqueta.Parent = gui

		huecos[k] = { cubo = cubo, boton = boton, gui = gui, etiqueta = etiqueta }
	end

	puestos[numero] = { cartel = cartel, huecos = huecos }
end

-- Pone al día lo que se ve en un puesto (quién lo lleva y qué vende)
local function refrescarPuesto(numero)
	local puesto = puestos[numero]
	if not puesto then
		return
	end
	local dueno = duenoDe(numero)
	puesto.cartel.Text = if dueno then "🛍️ Tienda de " .. dueno.DisplayName else "🛍️ Puesto libre"

	for k, hueco in puesto.huecos do
		local id = dueno and dueno:GetAttribute("Venta_" .. k .. "_id")
		local precio = dueno and dueno:GetAttribute("Venta_" .. k .. "_precio")
		local ficha = type(id) == "string" and fichaDeMueble(id)
		if dueno and ficha and type(precio) == "number" then
			local agotado = (dueno:GetAttribute("Casa_" .. id) or 0) < 1
			hueco.cubo.Transparency = 0
			hueco.cubo.Color = Color3.fromHSV(((ficha:GetAttribute("Orden") or 1) * 0.071) % 1, 0.55, 0.95)
			hueco.etiqueta.Text = ficha:GetAttribute("Nombre") .. " · " .. precio .. " 🪙" .. (if agotado then " (agotado)" else "")
			hueco.gui.Enabled = true
			hueco.boton.ObjectText = ficha:GetAttribute("Nombre") .. " (" .. precio .. " monedas)"
			hueco.boton.Enabled = not agotado
		else
			hueco.cubo.Transparency = 1
			hueco.gui.Enabled = false
			hueco.boton.Enabled = false
		end
	end
end

for _, origen in CollectionService:GetTagged("CasaOrigen") do
	construirPuesto(origen)
end
CollectionService:GetInstanceAddedSignal("CasaOrigen"):Connect(construirPuesto)

-- Cada segundo ponemos al día todos los puestos (son pocos y es muy barato)
task.spawn(function()
	while true do
		for numero in puestos do
			refrescarPuesto(numero)
		end
		task.wait(1)
	end
end)

----------------------------------------------------------------------
-- 🖱️ EL DUEÑO ELIGE QUÉ VENDER Y A QUÉ PRECIO (lo pide la pantalla)
----------------------------------------------------------------------

local ultimoPedido = {}
Players.PlayerRemoving:Connect(function(jugador)
	ultimoPedido[jugador] = nil
end)

evento.OnServerEvent:Connect(function(jugador, accion, id, valor)
	-- Comprobamos que lo que nos manda tiene sentido (¡nunca nos fiamos de la pantalla!)
	if type(accion) ~= "string" then
		return
	end
	local ahora = os.clock()
	if ahora - (ultimoPedido[jugador] or -100) < 0.3 then
		return
	end
	ultimoPedido[jugador] = ahora
	if not jugador:GetAttribute("CasaNumero") then
		avisar(jugador, "Necesitas una casa para tener un puesto 🏠", Color3.fromRGB(200, 60, 60))
		return
	end

	if accion == "vender" and type(id) == "string" and type(valor) == "number" and valor == valor then
		local ficha = fichaDeMueble(id)
		if not ficha then
			return
		end
		if (jugador:GetAttribute("Casa_" .. id) or 0) < 1 then
			avisar(jugador, "No tienes ese mueble para vender 😕", Color3.fromRGB(200, 60, 60))
			return
		end
		local precio = math.floor(math.clamp(valor, AJUSTES.precioMinimo, AJUSTES.precioMaximo))

		-- ¿Ya lo vendías? Cambiamos el precio. Si no, buscamos un hueco libre.
		local elegido = nil
		for k = 1, AJUSTES.huecos do
			if jugador:GetAttribute("Venta_" .. k .. "_id") == id then
				elegido = k
				break
			end
		end
		if not elegido then
			for k = 1, AJUSTES.huecos do
				if jugador:GetAttribute("Venta_" .. k .. "_id") == nil then
					elegido = k
					break
				end
			end
		end
		if not elegido then
			avisar(jugador, "Tu puesto está lleno (" .. AJUSTES.huecos .. " cosas). ¡Quita alguna!", Color3.fromRGB(200, 60, 60))
			return
		end
		jugador:SetAttribute("Venta_" .. elegido .. "_id", id)
		jugador:SetAttribute("Venta_" .. elegido .. "_precio", precio)
		avisar(jugador, "🛍️ " .. ficha:GetAttribute("Nombre") .. " en venta por " .. precio .. " 🪙", Color3.fromRGB(40, 160, 80))
	elseif accion == "quitar" and type(valor) == "number" then
		local k = math.floor(valor)
		if k >= 1 and k <= AJUSTES.huecos then
			jugador:SetAttribute("Venta_" .. k .. "_id", nil)
			jugador:SetAttribute("Venta_" .. k .. "_precio", nil)
		end
	end
end)

print("🛍️ Puestecitos listos.")
