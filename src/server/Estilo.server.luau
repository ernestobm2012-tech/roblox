--[[
	🎨 ESTILO: COLORES Y ESTELAS
	Se compran con 🪙 monedas y se llevan puestos:
	  - 🎨 COLORES: tu personaje se pone de ese color (rojo, azul, dorado...)
	  - 🌈 ESTELAS: te sale una estela detrás cuando corres (fuego, hielo, arcoíris...)
	Se eligen en el botón "🎨 Estilo" de la pantalla (script Estilo del cliente).
	Lo que compras se guarda (con el script Guardado) y puedes cambiar de uno a otro
	cuando quieras sin pagar otra vez.

	📋 DÓNDE VA: en Roblox Studio, dentro de ServerScriptService, como "Script".
	(Usa las Monedas del marcador que crea el script MiMundo. Habla con la pantalla con
	un RemoteEvent y con una carpeta en ReplicatedStorage donde deja la lista de cosas.)
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

-- 🧺 LO QUE SE VENDE (precio en monedas)
local COLORES = {
	{ id = "rojo", nombre = "Rojo", precio = 15, color = Color3.fromRGB(230, 50, 50) },
	{ id = "naranja", nombre = "Naranja", precio = 15, color = Color3.fromRGB(255, 140, 30) },
	{ id = "amarillo", nombre = "Amarillo", precio = 15, color = Color3.fromRGB(255, 220, 50) },
	{ id = "verde", nombre = "Verde", precio = 15, color = Color3.fromRGB(60, 200, 80) },
	{ id = "azul", nombre = "Azul", precio = 15, color = Color3.fromRGB(50, 110, 240) },
	{ id = "morado", nombre = "Morado", precio = 15, color = Color3.fromRGB(150, 70, 230) },
	{ id = "rosa", nombre = "Rosa", precio = 15, color = Color3.fromRGB(255, 130, 200) },
	{ id = "negro", nombre = "Negro", precio = 25, color = Color3.fromRGB(30, 30, 35) },
	{ id = "blanco", nombre = "Blanco", precio = 25, color = Color3.fromRGB(245, 245, 250) },
	{ id = "dorado", nombre = "Dorado", precio = 60, color = Color3.fromRGB(255, 195, 40) },
}

-- "color" y "color2" son el principio y el final de la estela. "arcoiris" = todos los colores.
local ESTELAS = {
	{ id = "fuego", nombre = "🔥 Fuego", precio = 40, color = Color3.fromRGB(255, 220, 60), color2 = Color3.fromRGB(255, 50, 0) },
	{ id = "hielo", nombre = "🧊 Hielo", precio = 40, color = Color3.fromRGB(220, 250, 255), color2 = Color3.fromRGB(60, 160, 255) },
	{ id = "veneno", nombre = "☠️ Veneno", precio = 40, color = Color3.fromRGB(190, 255, 80), color2 = Color3.fromRGB(40, 140, 40) },
	{ id = "estrellas", nombre = "⭐ Estrellas", precio = 40, color = Color3.fromRGB(255, 255, 200), color2 = Color3.fromRGB(255, 200, 50) },
	{ id = "rosa", nombre = "💖 Corazón", precio = 40, color = Color3.fromRGB(255, 180, 220), color2 = Color3.fromRGB(230, 40, 130) },
	{ id = "fantasma", nombre = "👻 Fantasma", precio = 40, color = Color3.fromRGB(255, 255, 255), color2 = Color3.fromRGB(150, 150, 190) },
	{ id = "arcoiris", nombre = "🌈 Arcoíris", precio = 80, color = Color3.fromRGB(255, 80, 80), color2 = Color3.fromRGB(80, 80, 255), arcoiris = true },
}

local CATALOGOS = { color = COLORES, estela = ESTELAS }

-- Los colores originales de cada personaje, para poder quitarse el color
local originales = setmetatable({}, { __mode = "k" })

----------------------------------------------------------------------
-- 🧰 HERRAMIENTAS
----------------------------------------------------------------------

local function buscar(lista, id)
	for _, elemento in lista do
		if elemento.id == id then
			return elemento
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
	local viejo = pantallaJugador:FindFirstChild("AvisoEstilo")
	if viejo then
		viejo:Destroy()
	end

	local pantalla = Instance.new("ScreenGui")
	pantalla.Name = "AvisoEstilo"
	pantalla.ResetOnSpawn = false
	pantalla.Parent = pantallaJugador

	local mensaje = Instance.new("TextLabel")
	mensaje.Size = UDim2.fromScale(0.5, 0.09)
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

----------------------------------------------------------------------
-- 📋 LA LISTA PARA LA PANTALLA (una carpeta con un hijo por cada cosa)
----------------------------------------------------------------------

local carpetaCatalogo = Instance.new("Folder")
carpetaCatalogo.Name = "CatalogoEstilo"

local orden = 0
for tipo, lista in CATALOGOS do
	for _, elemento in lista do
		orden += 1
		local ficha = Instance.new("Folder")
		ficha.Name = tipo .. "_" .. elemento.id
		ficha:SetAttribute("Tipo", tipo)
		ficha:SetAttribute("Id", elemento.id)
		ficha:SetAttribute("Nombre", elemento.nombre)
		ficha:SetAttribute("Precio", elemento.precio)
		ficha:SetAttribute("Color", elemento.color)
		ficha:SetAttribute("Orden", orden)
		ficha.Parent = carpetaCatalogo
	end
end

local evento = Instance.new("RemoteEvent")
evento.Name = "EstiloAccion"
evento.Parent = ReplicatedStorage
carpetaCatalogo.Parent = ReplicatedStorage -- al final, cuando ya está todo listo

----------------------------------------------------------------------
-- 👕 PONERSE EL ESTILO
----------------------------------------------------------------------

local function ponerColor(jugador, personaje)
	local colores = personaje:FindFirstChildOfClass("BodyColors")
	if not colores then
		colores = Instance.new("BodyColors")
		colores.Parent = personaje
	end
	if not originales[personaje] then
		originales[personaje] = {
			colores.HeadColor3, colores.TorsoColor3, colores.LeftArmColor3,
			colores.RightArmColor3, colores.LeftLegColor3, colores.RightLegColor3,
		}
	end

	local elegido = buscar(COLORES, jugador:GetAttribute("Equipo_color"))
	if elegido then
		colores.HeadColor3 = elegido.color
		colores.TorsoColor3 = elegido.color
		colores.LeftArmColor3 = elegido.color
		colores.RightArmColor3 = elegido.color
		colores.LeftLegColor3 = elegido.color
		colores.RightLegColor3 = elegido.color
	else
		local antes = originales[personaje]
		colores.HeadColor3 = antes[1]
		colores.TorsoColor3 = antes[2]
		colores.LeftArmColor3 = antes[3]
		colores.RightArmColor3 = antes[4]
		colores.LeftLegColor3 = antes[5]
		colores.RightLegColor3 = antes[6]
	end
end

local function ponerEstela(jugador, personaje)
	local raiz = personaje:FindFirstChild("HumanoidRootPart")
	if not raiz then
		return
	end
	-- Quitamos la estela de antes
	for _, nombre in { "EstelaEstilo", "EstelaA0", "EstelaA1" } do
		local viejo = raiz:FindFirstChild(nombre)
		if viejo then
			viejo:Destroy()
		end
	end

	local elegida = buscar(ESTELAS, jugador:GetAttribute("Equipo_estela"))
	if not elegida then
		return
	end

	local arriba = Instance.new("Attachment")
	arriba.Name = "EstelaA0"
	arriba.Position = Vector3.new(0, 1.2, 0)
	arriba.Parent = raiz
	local abajo = Instance.new("Attachment")
	abajo.Name = "EstelaA1"
	abajo.Position = Vector3.new(0, -1.2, 0)
	abajo.Parent = raiz

	local estela = Instance.new("Trail")
	estela.Name = "EstelaEstilo"
	estela.Attachment0 = arriba
	estela.Attachment1 = abajo
	estela.Lifetime = 0.8
	estela.LightEmission = 0.6
	estela.Transparency = NumberSequence.new(0.1, 1)
	if elegida.arcoiris then
		estela.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 70, 70)),
			ColorSequenceKeypoint.new(0.25, Color3.fromRGB(255, 220, 60)),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(80, 220, 100)),
			ColorSequenceKeypoint.new(0.75, Color3.fromRGB(70, 150, 255)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(180, 80, 255)),
		})
	else
		estela.Color = ColorSequence.new(elegida.color, elegida.color2)
	end
	estela.Parent = raiz
end

local function ponerEstilo(jugador, personaje)
	personaje:WaitForChild("HumanoidRootPart", 10)
	ponerColor(jugador, personaje)
	ponerEstela(jugador, personaje)
end

local function prepararJugador(jugador)
	jugador.CharacterAdded:Connect(function(personaje)
		ponerEstilo(jugador, personaje)
	end)
	-- Cuando cambias de color o de estela (o se carga lo guardado)
	jugador.AttributeChanged:Connect(function(nombre)
		if string.sub(nombre, 1, 7) == "Equipo_" and jugador.Character then
			task.spawn(ponerEstilo, jugador, jugador.Character)
		end
	end)
	if jugador.Character then
		task.spawn(ponerEstilo, jugador, jugador.Character)
	end
end

Players.PlayerAdded:Connect(prepararJugador)
for _, jugador in Players:GetPlayers() do
	prepararJugador(jugador)
end

----------------------------------------------------------------------
-- 🖱️ COMPRAR Y PONERSE COSAS (lo pide la pantalla)
----------------------------------------------------------------------

local ultimoPedido = {}
Players.PlayerRemoving:Connect(function(jugador)
	ultimoPedido[jugador] = nil
end)

evento.OnServerEvent:Connect(function(jugador, accion, tipo, id)
	-- Comprobamos que lo que nos manda tiene sentido (¡nunca nos fiamos de la pantalla!)
	if type(accion) ~= "string" or type(tipo) ~= "string" or type(id) ~= "string" then
		return
	end
	local lista = CATALOGOS[tipo]
	if not lista then
		return
	end
	local ahora = os.clock()
	if ahora - (ultimoPedido[jugador] or -100) < 0.3 then
		return
	end
	ultimoPedido[jugador] = ahora

	local atributoEquipo = "Equipo_" .. tipo

	-- Quitarse lo que llevas puesto
	if accion == "equipar" and id == "" then
		jugador:SetAttribute(atributoEquipo, "")
		return
	end

	local elemento = buscar(lista, id)
	if not elemento then
		return
	end
	local atributoCompra = "Estilo_" .. tipo .. "_" .. id

	if accion == "equipar" then
		if jugador:GetAttribute(atributoCompra) then
			jugador:SetAttribute(atributoEquipo, id)
		end
	elseif accion == "comprar" then
		if jugador:GetAttribute(atributoCompra) then
			jugador:SetAttribute(atributoEquipo, id) -- ya lo tienes: te lo pones
			return
		end
		local marcador = jugador:FindFirstChild("leaderstats")
		local monedas = marcador and marcador:FindFirstChild("Monedas")
		if not monedas then
			avisar(jugador, "Todavía no tienes monedas 🪙", Color3.fromRGB(200, 60, 60))
			return
		end
		if monedas.Value < elemento.precio then
			avisar(jugador, "Te faltan " .. (elemento.precio - monedas.Value) .. " 🪙 para " .. elemento.nombre, Color3.fromRGB(200, 60, 60))
			return
		end
		monedas.Value -= elemento.precio
		jugador:SetAttribute(atributoCompra, true) -- el script Guardado se acuerda
		jugador:SetAttribute(atributoEquipo, id) -- y te lo pones
		avisar(jugador, "¡Has comprado " .. elemento.nombre .. "! 🎉", Color3.fromRGB(40, 160, 80))
	end
end)

print("🎨 Tienda de estilo lista.")
