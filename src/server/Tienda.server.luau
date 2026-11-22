--[[
	🛒 TIENDA
	Construye una tienda junto a la salida con 3 puestos.
	Acércate a un puesto y mantén pulsada la tecla E (o toca el botón en el móvil)
	para comprarlo con tus 🪙 Monedas.
	  - 👟 Botas veloces: corres más rápido
	  - 🦘 Súper salto: saltas mucho más alto
	  - ✨ Brillos: te rodean brillitos
	Lo que compras se queda aunque caigas en la lava.

	📋 DÓNDE VA: en Roblox Studio, dentro de ServerScriptService, como "Script".
	(Usa las Monedas del marcador que crea el script MiMundo.)
]]

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

-- ⚙️ AJUSTES: ¡cambia estos valores y mira qué pasa!
local AJUSTES = {
	posicion = Vector3.new(24, 0, 6), -- dónde está la tienda (X, Y, Z)
	velocidadNormal = 16, -- así corres sin comprar nada
	velocidadConBotas = 30, -- así corres con las botas veloces
	saltoNormal = 50, -- así saltas sin comprar nada
	saltoConSuperSalto = 100, -- así saltas con el súper salto
}

-- 🧺 LO QUE SE VENDE (precio = monedas que cuesta)
local OBJETOS = {
	{
		id = "botas",
		nombre = "👟 Botas veloces",
		precio = 5,
		color = Color3.fromRGB(255, 170, 40),
		aplicar = function(humanoide, _raiz)
			humanoide.WalkSpeed = AJUSTES.velocidadConBotas
		end,
	},
	{
		id = "salto",
		nombre = "🦘 Súper salto",
		precio = 5,
		color = Color3.fromRGB(80, 200, 255),
		aplicar = function(humanoide, _raiz)
			humanoide.UseJumpPower = true
			humanoide.JumpPower = AJUSTES.saltoConSuperSalto
		end,
	},
	{
		id = "brillos",
		nombre = "✨ Brillos",
		precio = 3,
		color = Color3.fromRGB(255, 120, 220),
		aplicar = function(_humanoide, raiz)
			if not raiz:FindFirstChild("BrillosTienda") then
				local brillos = Instance.new("Sparkles")
				brillos.Name = "BrillosTienda"
				brillos.Parent = raiz
			end
		end,
	},
}

local carpeta = Instance.new("Folder")
carpeta.Name = "Tienda"
carpeta.Parent = workspace

----------------------------------------------------------------------
-- 🧰 HERRAMIENTAS
----------------------------------------------------------------------

local function crearBloque(nombre, tamano, cframe, color, material)
	local bloque = Instance.new("Part")
	bloque.Name = nombre
	bloque.Size = tamano
	bloque.CFrame = cframe
	bloque.Color = color
	bloque.Material = material or Enum.Material.SmoothPlastic
	bloque.Anchored = true
	bloque.TopSurface = Enum.SurfaceType.Smooth
	bloque.BottomSurface = Enum.SurfaceType.Smooth
	bloque.Parent = carpeta
	return bloque
end

-- Pone un cartel flotante encima de una parte
local function crearCartel(parte, texto, alto, desplazamiento)
	local cartel = Instance.new("BillboardGui")
	cartel.Size = UDim2.fromOffset(220, alto)
	cartel.StudsOffset = desplazamiento
	cartel.AlwaysOnTop = true
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

	local viejo = pantallaJugador:FindFirstChild("AvisoTienda")
	if viejo then
		viejo:Destroy()
	end

	local pantalla = Instance.new("ScreenGui")
	pantalla.Name = "AvisoTienda"
	pantalla.ResetOnSpawn = false
	pantalla.Parent = pantallaJugador

	local mensaje = Instance.new("TextLabel")
	mensaje.Size = UDim2.fromScale(0.5, 0.09)
	mensaje.Position = UDim2.fromScale(0.5, 0.82)
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
-- 🎒 LO QUE HA COMPRADO CADA JUGADOR
----------------------------------------------------------------------

local compras = {} -- compras[jugador] = { botas = true, ... }

local function aplicarCompras(jugador, personaje)
	local lista = compras[jugador]
	if not lista then
		return
	end
	local humanoide = personaje:WaitForChild("Humanoid", 10)
	local raiz = personaje:WaitForChild("HumanoidRootPart", 10)
	if not humanoide or not raiz then
		return
	end
	for _, objeto in OBJETOS do
		if lista[objeto.id] then
			objeto.aplicar(humanoide, raiz)
		end
	end
end

local function prepararJugador(jugador)
	compras[jugador] = compras[jugador] or {}
	jugador.CharacterAdded:Connect(function(personaje)
		aplicarCompras(jugador, personaje)
	end)
	if jugador.Character then
		task.spawn(aplicarCompras, jugador, jugador.Character)
	end
end

Players.PlayerAdded:Connect(prepararJugador)
for _, jugador in Players:GetPlayers() do
	prepararJugador(jugador)
end
Players.PlayerRemoving:Connect(function(jugador)
	compras[jugador] = nil
end)

----------------------------------------------------------------------
-- 🛒 COMPRAR
----------------------------------------------------------------------

local function comprar(jugador, objeto)
	local lista = compras[jugador]
	if not lista then
		return
	end

	if lista[objeto.id] then
		avisar(jugador, "Ya tienes " .. objeto.nombre, Color3.fromRGB(90, 90, 120))
		return
	end

	local marcador = jugador:FindFirstChild("leaderstats")
	local monedas = marcador and marcador:FindFirstChild("Monedas")
	if not monedas then
		avisar(jugador, "Todavía no tienes monedas 🪙", Color3.fromRGB(200, 60, 60))
		return
	end

	if monedas.Value < objeto.precio then
		local faltan = objeto.precio - monedas.Value
		avisar(jugador, "Te faltan " .. faltan .. " 🪙 para " .. objeto.nombre, Color3.fromRGB(200, 60, 60))
		return
	end

	-- ¡Compra hecha!
	monedas.Value -= objeto.precio
	lista[objeto.id] = true
	if jugador.Character then
		aplicarCompras(jugador, jugador.Character)
	end
	avisar(jugador, "¡Has comprado " .. objeto.nombre .. "! 🎉", Color3.fromRGB(40, 160, 80))
end

----------------------------------------------------------------------
-- 🔨 CONSTRUIMOS LA TIENDA
----------------------------------------------------------------------

-- La tienda mira hacia la salida (el centro del mapa)
local orientacion = CFrame.lookAt(AJUSTES.posicion, Vector3.new(0, AJUSTES.posicion.Y, 0))
local madera = Color3.fromRGB(150, 100, 60)

-- Suelo de la tienda
crearBloque("Suelo", Vector3.new(24, 0.6, 10), orientacion * CFrame.new(0, 0.3, 0), Color3.fromRGB(230, 220, 190))

-- Pared del fondo y techo
crearBloque("Pared", Vector3.new(24, 9, 1), orientacion * CFrame.new(0, 5, 4.5), madera, Enum.Material.Wood)
local techo = crearBloque("Techo", Vector3.new(26, 1, 11), orientacion * CFrame.new(0, 10.5, 0), Color3.fromRGB(200, 50, 50))
crearBloque("PosteIzquierdo", Vector3.new(1, 10, 1), orientacion * CFrame.new(-12, 5, -4.5), madera, Enum.Material.Wood)
crearBloque("PosteDerecho", Vector3.new(1, 10, 1), orientacion * CFrame.new(12, 5, -4.5), madera, Enum.Material.Wood)

crearCartel(techo, "🛒 TIENDA", 70, Vector3.new(0, 4, 0))

-- Un puesto por cada objeto
local separacion = 7
local primero = -(#OBJETOS - 1) / 2 * separacion

for i, objeto in OBJETOS do
	local x = primero + (i - 1) * separacion

	local pedestal = crearBloque(
		"Puesto_" .. objeto.id,
		Vector3.new(4, 3, 3),
		orientacion * CFrame.new(x, 2.1, 0),
		objeto.color,
		Enum.Material.SmoothPlastic
	)

	-- Bolita brillante encima del puesto
	local muestra = crearBloque("Muestra_" .. objeto.id, Vector3.new(1.6, 1.6, 1.6), orientacion * CFrame.new(x, 4.6, 0), objeto.color, Enum.Material.Neon)
	muestra.Shape = Enum.PartType.Ball

	crearCartel(pedestal, objeto.nombre .. "\n" .. objeto.precio .. " 🪙", 90, Vector3.new(0, 4.5, 0))

	-- El botón de comprar (aparece al acercarte)
	local boton = Instance.new("ProximityPrompt")
	boton.ActionText = "Comprar"
	boton.ObjectText = objeto.nombre .. " (" .. objeto.precio .. " monedas)"
	boton.HoldDuration = 0.3
	boton.MaxActivationDistance = 10
	boton.RequiresLineOfSight = false
	boton.Parent = pedestal

	boton.Triggered:Connect(function(jugador)
		comprar(jugador, objeto)
	end)
end

print("🛒 ¡Tienda abierta!")
