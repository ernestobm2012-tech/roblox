--[[
	🛒 TIENDA DE MEJORAS
	Construye una tienda junto a la salida con 3 puestos. Cada puesto vende una mejora que
	se puede comprar UNA VEZ TRAS OTRA, subiendo de nivel con cada compra:
	  - 🦘 Súper salto: saltas un poco más alto con cada nivel (hasta el nivel 600)
	  - 👟 Correr: corres un poco más rápido con cada nivel (hasta el nivel 600)
	  - ✨ Brillo en la espalda: te brilla la espalda cada vez más (hasta el nivel 100)
	Se compra con las 🪙 Monedas. Acércate a un puesto y mantén pulsada la tecla E
	(o toca el botón en el móvil). Cada compra sube la mejora UN nivel y el siguiente
	cuesta un poquito más.
	Tus mejoras se quedan aunque caigas en la lava (y, con el script Guardado, también
	para la próxima vez que juegues). En la pantalla (script Mejoras) ves tus niveles.

	📋 DÓNDE VA: en Roblox Studio, dentro de ServerScriptService, como "Script".
	(Usa las Monedas del marcador que crea el script MiMundo.)
]]

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

-- ⚙️ AJUSTES: ¡cambia estos valores y mira qué pasa!
local AJUSTES = {
	posicion = Vector3.new(24, 0, 6), -- dónde está la tienda (X, Y, Z)
	velocidadNormal = 16, velocidadPorNivel = 0.05, -- correr: velocidad = normal + nivel x esto
	saltoNormal = 50, saltoPorNivel = 0.15, -- saltar: fuerza = normal + nivel x esto
	brilloAlcanceBase = 8, brilloAlcancePorNivel = 0.3, -- lo lejos que llega la luz de tu espalda
}

-- 🧺 LO QUE SE VENDE
-- Precio de la siguiente mejora = precioBase + (tu nivel actual dividido entre cadaNiveles)
local MEJORAS = {
	{
		id = "salto",
		nombre = "🦘 Súper salto",
		maximo = 600,
		precioBase = 2,
		cadaNiveles = 20,
		color = Color3.fromRGB(80, 200, 255),
		aplicar = function(humanoide, _raiz, _personaje, nivel)
			humanoide.UseJumpPower = true
			humanoide.JumpPower = AJUSTES.saltoNormal + nivel * AJUSTES.saltoPorNivel
		end,
	},
	{
		id = "velocidad",
		nombre = "👟 Correr",
		maximo = 600,
		precioBase = 2,
		cadaNiveles = 20,
		color = Color3.fromRGB(255, 170, 40),
		aplicar = function(humanoide, _raiz, _personaje, nivel)
			humanoide.WalkSpeed = AJUSTES.velocidadNormal + nivel * AJUSTES.velocidadPorNivel
		end,
	},
	{
		id = "brillo",
		nombre = "✨ Brillo en la espalda",
		maximo = 100,
		precioBase = 2,
		cadaNiveles = 10,
		color = Color3.fromRGB(255, 120, 220),
		aplicar = function(_humanoide, _raiz, personaje, nivel)
			local torso = personaje:FindFirstChild("UpperTorso") or personaje:FindFirstChild("Torso")
			if not torso then
				return
			end
			local brillo = personaje:FindFirstChild("BrilloEspalda")
			if not brillo then
				brillo = Instance.new("Part")
				brillo.Name = "BrilloEspalda"
				brillo.Size = Vector3.new(2, 2, 0.3)
				brillo.Material = Enum.Material.Neon
				brillo.CanCollide = false
				brillo.CanTouch = false
				brillo.Massless = true
				brillo.CastShadow = false
				brillo.CFrame = torso.CFrame * CFrame.new(0, 0, torso.Size.Z / 2 + 0.2) -- la espalda
				local soldadura = Instance.new("WeldConstraint")
				soldadura.Part0 = torso
				soldadura.Part1 = brillo
				soldadura.Parent = brillo
				local luz = Instance.new("PointLight")
				luz.Name = "Luz"
				luz.Shadows = false
				luz.Parent = brillo
				brillo.Parent = personaje
			end
			-- Cuanto más nivel, más fuerte y de otro color
			local color = Color3.fromHSV((nivel * 0.01) % 1, 0.6, 1)
			brillo.Color = color
			local luz = brillo:FindFirstChild("Luz")
			if luz then
				luz.Color = color
				luz.Range = math.min(AJUSTES.brilloAlcanceBase + nivel * AJUSTES.brilloAlcancePorNivel, 40)
				luz.Brightness = math.min(1 + nivel * 0.03, 4)
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
-- 🎒 LAS MEJORAS DE CADA JUGADOR
----------------------------------------------------------------------

-- Cuánto cuesta la siguiente mejora (0 si ya está al máximo)
local function precioSiguiente(mejora, nivel)
	if nivel >= mejora.maximo then
		return 0
	end
	return mejora.precioBase + math.floor(nivel / mejora.cadaNiveles)
end

-- La pantalla (script Mejoras) lee estos atributos para enseñar tu nivel y el precio
local function actualizarPrecios(jugador)
	for _, mejora in MEJORAS do
		local nivel = jugador:GetAttribute("Mejora_" .. mejora.id) or 0
		jugador:SetAttribute("Precio_" .. mejora.id, precioSiguiente(mejora, nivel))
	end
end

-- Cada nivel de mejora se apunta como un "atributo" del jugador: Mejora_salto, Mejora_velocidad...
-- (así el script Guardado sabe qué ha comprado, sin necesitar nada más)
local function aplicarMejoras(jugador, personaje)
	local humanoide = personaje:WaitForChild("Humanoid", 10)
	local raiz = personaje:WaitForChild("HumanoidRootPart", 10)
	if not humanoide or not raiz then
		return
	end
	for _, mejora in MEJORAS do
		local nivel = jugador:GetAttribute("Mejora_" .. mejora.id) or 0
		if nivel > 0 then
			mejora.aplicar(humanoide, raiz, personaje, nivel)
		end
	end
end

local function prepararJugador(jugador)
	jugador.CharacterAdded:Connect(function(personaje)
		aplicarMejoras(jugador, personaje)
	end)
	-- Cuando cambia una mejora (la has comprado ahora o se ha cargado de un guardado)
	jugador.AttributeChanged:Connect(function(nombre)
		if string.sub(nombre, 1, 7) == "Mejora_" then
			actualizarPrecios(jugador)
			if jugador.Character then
				task.spawn(aplicarMejoras, jugador, jugador.Character)
			end
		end
	end)
	actualizarPrecios(jugador)
	if jugador.Character then
		task.spawn(aplicarMejoras, jugador, jugador.Character)
	end
end

Players.PlayerAdded:Connect(prepararJugador)
for _, jugador in Players:GetPlayers() do
	prepararJugador(jugador)
end

----------------------------------------------------------------------
-- 🛒 COMPRAR
----------------------------------------------------------------------

local function comprar(jugador, mejora)
	local atributo = "Mejora_" .. mejora.id
	local nivel = jugador:GetAttribute(atributo) or 0

	if nivel >= mejora.maximo then
		avisar(jugador, "¡" .. mejora.nombre .. " ya está al máximo! (nivel " .. mejora.maximo .. ")", Color3.fromRGB(90, 90, 120))
		return
	end

	local marcador = jugador:FindFirstChild("leaderstats")
	local monedas = marcador and marcador:FindFirstChild("Monedas")
	if not monedas then
		avisar(jugador, "Todavía no tienes monedas 🪙", Color3.fromRGB(200, 60, 60))
		return
	end

	local precio = precioSiguiente(mejora, nivel)
	if monedas.Value < precio then
		avisar(jugador, "Te faltan " .. (precio - monedas.Value) .. " 🪙 para " .. mejora.nombre .. " nivel " .. (nivel + 1), Color3.fromRGB(200, 60, 60))
		return
	end

	-- ¡Compra hecha!
	monedas.Value -= precio
	jugador:SetAttribute(atributo, nivel + 1) -- esto también activa el efecto
	local siguiente = precioSiguiente(mejora, nivel + 1)
	local textoSiguiente = if siguiente > 0 then "Siguiente: " .. siguiente .. " 🪙" else "¡Máximo!"
	avisar(jugador, mejora.nombre .. " nivel " .. (nivel + 1) .. " 🎉 " .. textoSiguiente, Color3.fromRGB(40, 160, 80))
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

-- Un puesto por cada mejora
local separacion = 7
local primero = -(#MEJORAS - 1) / 2 * separacion

for i, mejora in MEJORAS do
	local x = primero + (i - 1) * separacion

	local pedestal = crearBloque(
		"Puesto_" .. mejora.id,
		Vector3.new(4, 3, 3),
		orientacion * CFrame.new(x, 2.1, 0),
		mejora.color,
		Enum.Material.SmoothPlastic
	)

	-- Bolita brillante encima del puesto
	local muestra = crearBloque("Muestra_" .. mejora.id, Vector3.new(1.6, 1.6, 1.6), orientacion * CFrame.new(x, 4.6, 0), mejora.color, Enum.Material.Neon)
	muestra.Shape = Enum.PartType.Ball

	crearCartel(pedestal, mejora.nombre .. "\n¡Mejora tras mejora!", 90, Vector3.new(0, 4.5, 0))

	-- El botón de comprar (aparece al acercarte). Cada vez que lo usas, subes UN nivel.
	local boton = Instance.new("ProximityPrompt")
	boton.ActionText = "Mejorar"
	boton.ObjectText = mejora.nombre
	boton.HoldDuration = 0.25
	boton.MaxActivationDistance = 10
	boton.RequiresLineOfSight = false
	boton.Parent = pedestal

	boton.Triggered:Connect(function(jugador)
		comprar(jugador, mejora)
	end)
end

print("🛒 ¡Tienda abierta!")
