--[[
	🚀 JETPACK
	Si tienes el Pase del Jetpack (se compra con Robux), puedes VOLAR un ratito:
	  - Mantén pulsada la tecla ESPACIO en el aire (o el botón 🚀 de la pantalla, que sirve
	    también en el móvil) y subes echando fuego.
	  - Tienes combustible para unos segundos. Se recarga cuando pisas el suelo.
	Si no lo tienes, sale un botón para comprarlo.

	El pago lo hace el script "PasesRobux" del servidor.

	📋 DÓNDE VA: en Roblox Studio, dentro de StarterPlayer > StarterPlayerScripts,
	como "LocalScript".
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local jugador = Players.LocalPlayer
local evento = ReplicatedStorage:WaitForChild("ComprarPase")

-- ⚙️ AJUSTES: ¡cambia estos valores y mira qué pasa!
local COMBUSTIBLE_MAXIMO = 3 -- segundos de vuelo que caben en el depósito
local RECARGA = 1.5 -- cuánto se recarga por segundo cuando pisas el suelo
local EMPUJE = 320 -- la fuerza hacia arriba (la gravedad es 196)
local VELOCIDAD_MAXIMA = 50 -- lo rápido que puedes subir

local pantalla = Instance.new("ScreenGui")
pantalla.Name = "Jetpack"
pantalla.ResetOnSpawn = false
pantalla.Parent = jugador:WaitForChild("PlayerGui")

local function redondear(objeto, radio)
	local esquinas = Instance.new("UICorner")
	esquinas.CornerRadius = UDim.new(0, radio)
	esquinas.Parent = objeto
end

----------------------------------------------------------------------
-- 🖼️ LA PANTALLA
----------------------------------------------------------------------

-- Botón para comprar (solo si no lo tienes)
local comprar = Instance.new("TextButton")
comprar.Size = UDim2.fromOffset(200, 46)
comprar.Position = UDim2.new(0, 12, 0.3, 162)
comprar.BackgroundColor3 = Color3.fromRGB(200, 90, 40)
comprar.TextColor3 = Color3.fromRGB(255, 255, 255)
comprar.TextScaled = true
comprar.Font = Enum.Font.FredokaOne
comprar.Parent = pantalla
redondear(comprar, 10)

-- Botón para volar (solo si lo tienes). Se mantiene pulsado.
local volar = Instance.new("TextButton")
volar.Size = UDim2.fromOffset(84, 84)
volar.Position = UDim2.new(1, -110, 1, -270)
volar.BackgroundColor3 = Color3.fromRGB(230, 120, 40)
volar.TextColor3 = Color3.fromRGB(255, 255, 255)
volar.TextScaled = true
volar.Font = Enum.Font.FredokaOne
volar.Text = "🚀"
volar.Visible = false
volar.Parent = pantalla
redondear(volar, 42)

-- Barra de combustible
local fondoBarra = Instance.new("Frame")
fondoBarra.Size = UDim2.fromOffset(220, 18)
fondoBarra.Position = UDim2.new(0.5, -110, 1, -64)
fondoBarra.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
fondoBarra.BackgroundTransparency = 0.2
fondoBarra.Visible = false
fondoBarra.Parent = pantalla
redondear(fondoBarra, 9)

local relleno = Instance.new("Frame")
relleno.Size = UDim2.fromScale(1, 1)
relleno.BackgroundColor3 = Color3.fromRGB(255, 140, 40)
relleno.Parent = fondoBarra
redondear(relleno, 9)

----------------------------------------------------------------------
-- 🧠 LO QUE HACE
----------------------------------------------------------------------

local combustible = COMBUSTIBLE_MAXIMO
local botonPulsado = false

local function tieneJetpack()
	return jugador:GetAttribute("Pase_jetpack") == true
end

local function actualizarPantalla()
	local loTiene = tieneJetpack()
	comprar.Visible = not loTiene
	volar.Visible = loTiene
	fondoBarra.Visible = loTiene

	local precio = workspace:GetAttribute("PrecioPase_jetpack")
	if workspace:GetAttribute("PaseModoPrueba") then
		comprar.Text = "🚀 Jetpack (prueba gratis)"
	elseif precio then
		comprar.Text = "🚀 Jetpack — " .. precio .. " Robux"
	else
		comprar.Text = "🚀 Jetpack (no activado)"
	end
end

comprar.Activated:Connect(function()
	evento:FireServer("jetpack")
end)

volar.InputBegan:Connect(function(entrada)
	if entrada.UserInputType == Enum.UserInputType.MouseButton1 or entrada.UserInputType == Enum.UserInputType.Touch then
		botonPulsado = true
	end
end)
volar.InputEnded:Connect(function(entrada)
	if entrada.UserInputType == Enum.UserInputType.MouseButton1 or entrada.UserInputType == Enum.UserInputType.Touch then
		botonPulsado = false
	end
end)

jugador:GetAttributeChangedSignal("Pase_jetpack"):Connect(actualizarPantalla)
workspace:GetAttributeChangedSignal("PrecioPase_jetpack"):Connect(actualizarPantalla)
workspace:GetAttributeChangedSignal("PaseModoPrueba"):Connect(actualizarPantalla)
actualizarPantalla()

-- La llama que sale por abajo (solo la ves tú)
local function obtenerLlama(raiz)
	local llama = raiz:FindFirstChild("LlamaJetpack")
	if not llama then
		llama = Instance.new("ParticleEmitter")
		llama.Name = "LlamaJetpack"
		llama.Enabled = false
		llama.Rate = 120
		llama.Lifetime = NumberRange.new(0.3, 0.5)
		llama.Speed = NumberRange.new(15, 25)
		llama.EmissionDirection = Enum.NormalId.Bottom
		llama.LightEmission = 1
		llama.Size = NumberSequence.new(1.2, 0)
		llama.Color = ColorSequence.new(Color3.fromRGB(255, 200, 60), Color3.fromRGB(255, 60, 0))
		llama.Parent = raiz
	end
	return llama
end

RunService.Heartbeat:Connect(function(dt)
	if not tieneJetpack() then
		return
	end
	local personaje = jugador.Character
	local humanoide = personaje and personaje:FindFirstChildOfClass("Humanoid")
	local raiz = personaje and personaje:FindFirstChild("HumanoidRootPart")
	if not humanoide or not raiz or humanoide.Health <= 0 then
		return
	end

	local llama = obtenerLlama(raiz)
	local enSuelo = humanoide.FloorMaterial ~= Enum.Material.Air
	local teclaPulsada = UserInputService:IsKeyDown(Enum.KeyCode.Space)
	-- Con la tecla hay que estar en el aire (si no, solo saltas). Con el botón 🚀 vale siempre.
	local quiereVolar = botonPulsado or (teclaPulsada and not enSuelo)

	if quiereVolar and combustible > 0 then
		combustible -= dt
		local velocidad = raiz.AssemblyLinearVelocity
		raiz.AssemblyLinearVelocity = Vector3.new(velocidad.X, math.min(velocidad.Y + EMPUJE * dt, VELOCIDAD_MAXIMA), velocidad.Z)
		llama.Enabled = true
	else
		llama.Enabled = false
		if enSuelo then
			combustible = math.min(combustible + RECARGA * dt, COMBUSTIBLE_MAXIMO)
		end
	end
	relleno.Size = UDim2.fromScale(math.clamp(combustible / COMBUSTIBLE_MAXIMO, 0, 1), 1)
end)
