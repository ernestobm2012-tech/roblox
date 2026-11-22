--[[
	🏅 BOTÓN "LOGROS"
	Un botón a la izquierda de la pantalla. Al pulsarlo se abre una ventana con TODAS las insignias:
	las que ya has conseguido (con su premio) y las que te faltan (con lo que hay que hacer).

	Los logros los organiza el script "Logros" del servidor.

	📋 DÓNDE VA: en Roblox Studio, dentro de StarterPlayer > StarterPlayerScripts,
	como "LocalScript".
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local jugador = Players.LocalPlayer
local catalogo = ReplicatedStorage:WaitForChild("CatalogoLogros")

local pantalla = Instance.new("ScreenGui")
pantalla.Name = "Logros"
pantalla.ResetOnSpawn = false
pantalla.Parent = jugador:WaitForChild("PlayerGui")

local function redondear(objeto, radio)
	local esquinas = Instance.new("UICorner")
	esquinas.CornerRadius = UDim.new(0, radio)
	esquinas.Parent = objeto
end

local abrir = Instance.new("TextButton")
abrir.Size = UDim2.fromOffset(200, 46)
abrir.Position = UDim2.new(0, 12, 0.3, 270)
abrir.BackgroundColor3 = Color3.fromRGB(190, 140, 30)
abrir.TextColor3 = Color3.fromRGB(255, 255, 255)
abrir.TextScaled = true
abrir.Font = Enum.Font.FredokaOne
abrir.Text = "🏅 Logros"
abrir.Parent = pantalla
redondear(abrir, 10)

local panel = Instance.new("Frame")
panel.Size = UDim2.fromOffset(440, 460)
panel.Position = UDim2.fromScale(0.5, 0.5)
panel.AnchorPoint = Vector2.new(0.5, 0.5)
panel.BackgroundColor3 = Color3.fromRGB(35, 35, 70)
panel.Visible = false
panel.Parent = pantalla
redondear(panel, 16)

local titulo = Instance.new("TextLabel")
titulo.Size = UDim2.new(1, -70, 0, 36)
titulo.Position = UDim2.fromOffset(14, 8)
titulo.BackgroundTransparency = 1
titulo.TextColor3 = Color3.fromRGB(255, 255, 255)
titulo.TextScaled = true
titulo.Font = Enum.Font.FredokaOne
titulo.TextXAlignment = Enum.TextXAlignment.Left
titulo.Parent = panel

local cerrar = Instance.new("TextButton")
cerrar.Size = UDim2.fromOffset(34, 34)
cerrar.Position = UDim2.new(1, -46, 0, 8)
cerrar.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
cerrar.TextColor3 = Color3.fromRGB(255, 255, 255)
cerrar.TextScaled = true
cerrar.Font = Enum.Font.FredokaOne
cerrar.Text = "✖"
cerrar.Parent = panel
redondear(cerrar, 10)

local lista = Instance.new("ScrollingFrame")
lista.Size = UDim2.new(1, -24, 1, -60)
lista.Position = UDim2.fromOffset(12, 50)
lista.BackgroundTransparency = 1
lista.BorderSizePixel = 0
lista.ScrollBarThickness = 8
lista.CanvasSize = UDim2.new()
lista.AutomaticCanvasSize = Enum.AutomaticSize.Y
lista.Parent = panel

local distribucion = Instance.new("UIListLayout")
distribucion.Padding = UDim.new(0, 8)
distribucion.SortOrder = Enum.SortOrder.LayoutOrder
distribucion.Parent = lista

----------------------------------------------------------------------
-- 🧠 LO QUE HACE
----------------------------------------------------------------------

local function dibujar()
	for _, hijo in lista:GetChildren() do
		if hijo:IsA("GuiObject") then
			hijo:Destroy()
		end
	end

	local fichas = catalogo:GetChildren()
	table.sort(fichas, function(a, b)
		return a:GetAttribute("Orden") < b:GetAttribute("Orden")
	end)

	local conseguidos = 0
	for orden, ficha in fichas do
		local conseguido = jugador:GetAttribute("Logro_" .. ficha:GetAttribute("Id")) == true
		if conseguido then
			conseguidos += 1
		end

		local fila = Instance.new("Frame")
		fila.Size = UDim2.new(1, -10, 0, 54)
		fila.BackgroundColor3 = if conseguido then Color3.fromRGB(150, 110, 20) else Color3.fromRGB(55, 55, 95)
		fila.LayoutOrder = orden
		fila.Parent = lista
		redondear(fila, 10)

		local icono = Instance.new("TextLabel")
		icono.Size = UDim2.fromOffset(50, 50)
		icono.Position = UDim2.fromOffset(4, 2)
		icono.BackgroundTransparency = 1
		icono.Text = if conseguido then ficha:GetAttribute("Icono") else "🔒"
		icono.TextScaled = true
		icono.Parent = fila

		local nombre = Instance.new("TextLabel")
		nombre.Size = UDim2.new(1, -66, 0, 26)
		nombre.Position = UDim2.fromOffset(60, 3)
		nombre.BackgroundTransparency = 1
		nombre.Text = ficha:GetAttribute("Nombre") .. (if conseguido then "  ✅" else "")
		nombre.TextColor3 = Color3.fromRGB(255, 255, 255)
		nombre.TextScaled = true
		nombre.Font = Enum.Font.FredokaOne
		nombre.TextXAlignment = Enum.TextXAlignment.Left
		nombre.Parent = fila

		local detalle = Instance.new("TextLabel")
		detalle.Size = UDim2.new(1, -66, 0, 20)
		detalle.Position = UDim2.fromOffset(60, 30)
		detalle.BackgroundTransparency = 1
		detalle.Text = ficha:GetAttribute("Descripcion") .. "  ·  premio: " .. ficha:GetAttribute("Premio") .. " 🪙"
		detalle.TextColor3 = Color3.fromRGB(255, 225, 150)
		detalle.TextScaled = true
		detalle.Font = Enum.Font.FredokaOne
		detalle.TextXAlignment = Enum.TextXAlignment.Left
		detalle.Parent = fila
	end

	titulo.Text = "🏅 Logros  " .. conseguidos .. " de " .. #fichas
end

abrir.Activated:Connect(function()
	panel.Visible = not panel.Visible
	if panel.Visible then
		dibujar()
	end
end)
cerrar.Activated:Connect(function()
	panel.Visible = false
end)

-- Si consigues uno nuevo mientras está abierta, la ponemos al día
jugador.AttributeChanged:Connect(function(nombre)
	if panel.Visible and string.sub(nombre, 1, 6) == "Logro_" then
		dibujar()
	end
end)
