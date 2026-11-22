--[[
	🐾 MASCOTAS
	Se compran con 🪙 monedas (unas 30), te SIGUEN a todas partes y te hacen CORRER MÁS RÁPIDO.
	Puedes tener todas las que quieras, pero solo una puesta a la vez. Se eligen en el botón
	"🐾 Mascotas" de la pantalla (script Mascotas del cliente). Lo que compras se guarda
	(con el script Guardado).

	📋 DÓNDE VA: en Roblox Studio, dentro de ServerScriptService, como "Script".
	(Usa las Monedas del marcador que crea el script MiMundo. Dice cuánta velocidad extra te dan con
	el atributo "BonusMascota", que suma el script Tienda. Habla con la pantalla con un RemoteEvent
	y con una carpeta en ReplicatedStorage.)
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

-- 🧺 LAS MASCOTAS
-- "bonus" = velocidad extra al correr (sin mascota corres a 16).
-- "extras" son las piezas que les dan forma: { tamaño, posición, color } (la posición es respecto al cuerpo).
local ORELLAS = Color3.fromRGB(130, 85, 45)
local MASCOTAS = {
	{
		id = "perrito", nombre = "🐶 Perrito", precio = 30, bonus = 2, color = Color3.fromRGB(200, 140, 80),
		extras = {
			{ Vector3.new(0.5, 1.1, 0.5), Vector3.new(-1.05, 0.7, 0), ORELLAS },
			{ Vector3.new(0.5, 1.1, 0.5), Vector3.new(1.05, 0.7, 0), ORELLAS },
			{ Vector3.new(0.5, 0.4, 0.5), Vector3.new(0, -0.1, -1.25), Color3.fromRGB(40, 30, 30) }, -- la nariz
		},
	},
	{
		id = "gatito", nombre = "🐱 Gatito", precio = 30, bonus = 2, color = Color3.fromRGB(150, 150, 165),
		extras = {
			{ Vector3.new(0.6, 0.9, 0.4), Vector3.new(-0.75, 1.15, 0), Color3.fromRGB(120, 120, 135) },
			{ Vector3.new(0.6, 0.9, 0.4), Vector3.new(0.75, 1.15, 0), Color3.fromRGB(120, 120, 135) },
			{ Vector3.new(0.25, 0.25, 1.6), Vector3.new(0, -0.4, 1.6), Color3.fromRGB(120, 120, 135) }, -- la cola
		},
	},
	{
		id = "pollito", nombre = "🐥 Pollito", precio = 30, bonus = 2, color = Color3.fromRGB(255, 225, 70),
		extras = {
			{ Vector3.new(0.6, 0.4, 0.7), Vector3.new(0, -0.15, -1.3), Color3.fromRGB(255, 140, 30) }, -- el pico
		},
	},
	{
		id = "conejito", nombre = "🐰 Conejito", precio = 40, bonus = 3, color = Color3.fromRGB(245, 245, 250),
		extras = {
			{ Vector3.new(0.4, 1.8, 0.3), Vector3.new(-0.5, 1.9, 0), Color3.fromRGB(255, 200, 215) },
			{ Vector3.new(0.4, 1.8, 0.3), Vector3.new(0.5, 1.9, 0), Color3.fromRGB(255, 200, 215) },
		},
	},
	{
		id = "dragoncito", nombre = "🐲 Dragoncito", precio = 60, bonus = 5, color = Color3.fromRGB(70, 190, 90),
		extras = {
			{ Vector3.new(0.3, 0.8, 0.3), Vector3.new(-0.5, 1.4, -0.2), Color3.fromRGB(255, 150, 40) },
			{ Vector3.new(0.3, 0.8, 0.3), Vector3.new(0.5, 1.4, -0.2), Color3.fromRGB(255, 150, 40) },
			{ Vector3.new(0.6, 0.6, 1.8), Vector3.new(0, -0.4, 1.7), Color3.fromRGB(50, 150, 70) }, -- la cola
		},
	},
	{
		id = "robot", nombre = "🤖 Robot", precio = 80, bonus = 6, color = Color3.fromRGB(170, 175, 190), cuadrado = true,
		extras = {
			{ Vector3.new(0.15, 1, 0.15), Vector3.new(0, 1.7, 0), Color3.fromRGB(90, 90, 100) }, -- la antena
			{ Vector3.new(0.4, 0.4, 0.4), Vector3.new(0, 2.3, 0), Color3.fromRGB(255, 80, 80) },
		},
	},
}

local mascotas = {} -- mascotas[jugador] = { modelo = ..., cframe = ..., fase = ... }

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

-- Construye el muñequito de una mascota (cuerpo + ojos + sus piezas)
local function crearModelo(datos)
	local modelo = Instance.new("Model")
	modelo.Name = "Mascota"

	local function crearParte(nombre, tamano, posicion, color, forma, material)
		local parte = Instance.new("Part")
		parte.Name = nombre
		parte.Size = tamano
		parte.Position = posicion
		parte.Color = color
		parte.Shape = forma
		parte.Material = material or Enum.Material.SmoothPlastic
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

	local cuerpo = crearParte("Cuerpo", Vector3.new(2.4, 2.4, 2.4), Vector3.zero, datos.color, if datos.cuadrado then Enum.PartType.Block else Enum.PartType.Ball)
	modelo.PrimaryPart = cuerpo

	-- Los ojos miran hacia delante (que es hacia -Z)
	local negro = Color3.fromRGB(20, 20, 25)
	crearParte("OjoIzquierdo", Vector3.new(0.45, 0.45, 0.45), Vector3.new(-0.5, 0.3, -1.05), negro, Enum.PartType.Ball)
	crearParte("OjoDerecho", Vector3.new(0.45, 0.45, 0.45), Vector3.new(0.5, 0.3, -1.05), negro, Enum.PartType.Ball)

	for _, extra in datos.extras do
		crearParte("Pieza", extra[1], extra[2], extra[3], Enum.PartType.Block)
	end
	return modelo
end

----------------------------------------------------------------------
-- 🐾 PONERSE LA MASCOTA
----------------------------------------------------------------------

local function quitarMascota(jugador)
	local actual = mascotas[jugador]
	if actual then
		actual.modelo:Destroy()
		mascotas[jugador] = nil
	end
end

local function ponerMascota(jugador)
	quitarMascota(jugador)
	local datos = buscar(jugador:GetAttribute("Equipo_mascota"))
	jugador:SetAttribute("BonusMascota", if datos then datos.bonus else 0) -- el script Tienda lo suma a tu velocidad
	if not datos then
		return
	end

	local modelo = crearModelo(datos)
	local raiz = jugador.Character and jugador.Character:FindFirstChild("HumanoidRootPart")
	local inicio = if raiz then raiz.CFrame * CFrame.new(3.2, 0.2, 3.2) else CFrame.new(0, 5, 0)
	modelo:PivotTo(inicio)
	modelo.Parent = carpeta
	mascotas[jugador] = { modelo = modelo, cframe = inicio, fase = math.random() * 6 }
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
	-- Cuando cambias de mascota (o se carga la guardada)
	jugador:GetAttributeChangedSignal("Equipo_mascota"):Connect(function()
		ponerMascota(jugador)
	end)
	ponerMascota(jugador)
end

Players.PlayerAdded:Connect(prepararJugador)
for _, jugador in Players:GetPlayers() do
	prepararJugador(jugador)
end
Players.PlayerRemoving:Connect(function(jugador)
	quitarMascota(jugador)
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
