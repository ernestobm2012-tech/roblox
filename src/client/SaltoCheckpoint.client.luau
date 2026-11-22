--[[
	🚀 BOTÓN "SALTAR A CHECKPOINT"
	Un botón a la izquierda de la pantalla. Al pulsarlo se abre una ventanita donde eliges
	a qué nivel quieres volver (solo niveles que ya has alcanzado) y te dice lo que cuesta.
	Roblox te pedirá confirmar la compra antes de cobrar nada.

	El pago y el salto los hace el script "SaltoCheckpoint" del servidor.

	📋 DÓNDE VA: en Roblox Studio, dentro de StarterPlayer > StarterPlayerScripts,
	como "LocalScript".
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local jugador = Players.LocalPlayer
local evento = ReplicatedStorage:WaitForChild("SaltarCheckpoint")

local pantalla = Instance.new("ScreenGui")
pantalla.Name = "SaltoCheckpoint"
pantalla.ResetOnSpawn = false
pantalla.Parent = jugador:WaitForChild("PlayerGui")

----------------------------------------------------------------------
-- 🧰 HERRAMIENTAS PARA DIBUJAR
----------------------------------------------------------------------

local function redondear(objeto, radio)
	local esquinas = Instance.new("UICorner")
	esquinas.CornerRadius = UDim.new(0, radio)
	esquinas.Parent = objeto
end

local function crearBoton(texto, tamano, posicion, color, padre)
	local boton = Instance.new("TextButton")
	boton.Size = tamano
	boton.Position = posicion
	boton.BackgroundColor3 = color
	boton.TextColor3 = Color3.fromRGB(255, 255, 255)
	boton.TextScaled = true
	boton.Font = Enum.Font.FredokaOne
	boton.Text = texto
	boton.AutoButtonColor = true
	boton.Parent = padre
	redondear(boton, 10)
	return boton
end

local function crearTexto(texto, tamano, posicion, padre)
	local etiqueta = Instance.new("TextLabel")
	etiqueta.Size = tamano
	etiqueta.Position = posicion
	etiqueta.BackgroundTransparency = 1
	etiqueta.TextColor3 = Color3.fromRGB(255, 255, 255)
	etiqueta.TextScaled = true
	etiqueta.TextWrapped = true
	etiqueta.Font = Enum.Font.FredokaOne
	etiqueta.Text = texto
	etiqueta.Parent = padre
	return etiqueta
end

----------------------------------------------------------------------
-- 🖼️ LA PANTALLA
----------------------------------------------------------------------

local abrir = crearBoton("🚀 Saltar a checkpoint", UDim2.fromOffset(200, 48), UDim2.new(0, 12, 0.3, 0), Color3.fromRGB(60, 100, 200), pantalla)

local panel = Instance.new("Frame")
panel.Size = UDim2.fromOffset(330, 340)
panel.Position = UDim2.fromScale(0.5, 0.5)
panel.AnchorPoint = Vector2.new(0.5, 0.5)
panel.BackgroundColor3 = Color3.fromRGB(35, 35, 70)
panel.Visible = false
panel.Parent = pantalla
redondear(panel, 16)

crearTexto("🚀 Saltar a un checkpoint", UDim2.new(1, -60, 0, 36), UDim2.fromOffset(12, 8), panel)
local cerrar = crearBoton("✖", UDim2.fromOffset(34, 34), UDim2.new(1, -44, 0, 8), Color3.fromRGB(200, 60, 60), panel)
local info = crearTexto("", UDim2.new(1, -24, 0, 26), UDim2.fromOffset(12, 50), panel)
info.TextColor3 = Color3.fromRGB(200, 210, 255)

local caja = Instance.new("TextBox")
caja.Size = UDim2.new(1, -24, 0, 44)
caja.Position = UDim2.fromOffset(12, 86)
caja.BackgroundColor3 = Color3.fromRGB(20, 20, 45)
caja.TextColor3 = Color3.fromRGB(255, 255, 255)
caja.TextScaled = true
caja.Font = Enum.Font.FredokaOne
caja.ClearTextOnFocus = false
caja.PlaceholderText = "Número de nivel"
caja.Parent = panel
redondear(caja, 10)

local cambios = { { "−10", -10 }, { "−1", -1 }, { "+1", 1 }, { "+10", 10 } }
local botonesCambio = {}
for i, cambio in cambios do
	local boton = crearBoton(cambio[1], UDim2.fromOffset(70, 40), UDim2.fromOffset(12 + (i - 1) * 78, 138), Color3.fromRGB(80, 80, 140), panel)
	botonesCambio[i] = boton
end

local precio = crearTexto("", UDim2.new(1, -24, 0, 60), UDim2.fromOffset(12, 186), panel)
precio.TextColor3 = Color3.fromRGB(255, 225, 150)
local saltar = crearBoton("", UDim2.new(1, -24, 0, 56), UDim2.fromOffset(12, 266), Color3.fromRGB(40, 160, 80), panel)

----------------------------------------------------------------------
-- 🧠 LO QUE HACE
----------------------------------------------------------------------

local elegido = 1

local function maximo()
	return jugador:GetAttribute("Nivel") or 1
end

local function actualizar()
	elegido = math.clamp(math.floor(elegido), 1, maximo())
	caja.Text = tostring(elegido)
	info.Text = "Puedes ir a los niveles del 1 al " .. maximo()

	local creditos = jugador:GetAttribute("CreditosSalto") or 0
	local precioRobux = workspace:GetAttribute("PrecioSalto")
	if creditos > 0 then
		precio.Text = "Tienes " .. creditos .. " salto(s) pagado(s). ¡Este va gratis!"
		saltar.Text = "Saltar al nivel " .. elegido .. " (gratis)"
	elseif workspace:GetAttribute("SaltoModoPrueba") then
		precio.Text = "🧪 Modo prueba: gratis en Roblox Studio. En el juego real cuesta " .. tostring(precioRobux) .. " Robux."
		saltar.Text = "Saltar al nivel " .. elegido .. " (prueba)"
	elseif precioRobux then
		precio.Text = "Cada salto cuesta " .. precioRobux .. " Robux. Roblox te pedirá confirmar la compra."
		saltar.Text = "Saltar al nivel " .. elegido .. " — " .. precioRobux .. " Robux"
	else
		precio.Text = "Todavía no está activada la compra."
		saltar.Text = "Saltar al nivel " .. elegido
	end
end

abrir.Activated:Connect(function()
	panel.Visible = not panel.Visible
	if panel.Visible then
		elegido = maximo()
		actualizar()
	end
end)

cerrar.Activated:Connect(function()
	panel.Visible = false
end)

for i, boton in botonesCambio do
	boton.Activated:Connect(function()
		elegido += cambios[i][2]
		actualizar()
	end)
end

caja.FocusLost:Connect(function()
	local numero = tonumber(caja.Text)
	if numero then
		elegido = numero
	end
	actualizar()
end)

saltar.Activated:Connect(function()
	local numero = tonumber(caja.Text)
	if numero then
		elegido = numero
	end
	actualizar()
	evento:FireServer(elegido)
	panel.Visible = false
end)

-- Si cambia algo mientras está abierto (tu nivel, tus saltos, el precio), lo ponemos al día
local function siEstaAbierto()
	if panel.Visible then
		actualizar()
	end
end
jugador:GetAttributeChangedSignal("Nivel"):Connect(siEstaAbierto)
jugador:GetAttributeChangedSignal("CreditosSalto"):Connect(siEstaAbierto)
workspace:GetAttributeChangedSignal("PrecioSalto"):Connect(siEstaAbierto)
workspace:GetAttributeChangedSignal("SaltoModoPrueba"):Connect(siEstaAbierto)
