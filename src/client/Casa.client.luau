--[[
	🏠 BOTÓN "MI CASA"
	Un botón a la izquierda de la pantalla. Al pulsarlo se abre una ventana donde puedes:
	  - 🏠 Ir a tu casita (o 🚪 salir de ella y volver a tu nivel)
	  - 🛋️ Comprar camas y muebles con monedas. Se colocan solos dentro de tu casa.

	Todo lo hace el script "Casas" del servidor.

	📋 DÓNDE VA: en Roblox Studio, dentro de StarterPlayer > StarterPlayerScripts,
	como "LocalScript".
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local jugador = Players.LocalPlayer
local evento = ReplicatedStorage:WaitForChild("CasaAccion")
local catalogo = ReplicatedStorage:WaitForChild("CatalogoMuebles")

local pantalla = Instance.new("ScreenGui")
pantalla.Name = "Casa"
pantalla.ResetOnSpawn = false
pantalla.Parent = jugador:WaitForChild("PlayerGui")

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
	boton.Parent = padre
	redondear(boton, 10)
	return boton
end

----------------------------------------------------------------------
-- 🖼️ LA PANTALLA
----------------------------------------------------------------------

local abrir = crearBoton("🏠 Mi casa", UDim2.fromOffset(200, 46), UDim2.new(0, 12, 0.3, 324), Color3.fromRGB(60, 150, 110), pantalla)

local panel = Instance.new("Frame")
panel.Size = UDim2.fromOffset(440, 480)
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
titulo.Text = "🏠 Mi casa"
titulo.TextColor3 = Color3.fromRGB(255, 255, 255)
titulo.TextScaled = true
titulo.Font = Enum.Font.FredokaOne
titulo.TextXAlignment = Enum.TextXAlignment.Left
titulo.Parent = panel

local cerrar = crearBoton("✖", UDim2.fromOffset(34, 34), UDim2.new(1, -46, 0, 8), Color3.fromRGB(200, 60, 60), panel)

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

	local monedas = 0
	local marcador = jugador:FindFirstChild("leaderstats")
	local valor = marcador and marcador:FindFirstChild("Monedas")
	if valor then
		monedas = valor.Value
	end

	local orden = 1
	local tieneCasa = jugador:GetAttribute("CasaNumero") ~= nil
	local enCasa = jugador:GetAttribute("EnCasa") == true

	-- El botón de ir a casa o salir de ella
	local texto
	if not tieneCasa then
		texto = "Todavía no tienes casa (no quedan libres)"
	elseif enCasa then
		texto = "🚪 Salir de casa"
	else
		texto = "🏠 Ir a mi casa"
	end
	local ir = crearBoton(texto, UDim2.new(1, -10, 0, 44), UDim2.new(), Color3.fromRGB(60, 150, 110), lista)
	ir.LayoutOrder = orden
	ir.Activated:Connect(function()
		evento:FireServer(if enCasa then "salir" else "ir")
		panel.Visible = false
	end)

	orden += 1
	local etiqueta = Instance.new("TextLabel")
	etiqueta.Size = UDim2.new(1, -10, 0, 30)
	etiqueta.BackgroundTransparency = 1
	etiqueta.Text = "🛋️ Muebles (tienes 🪙 " .. monedas .. ")"
	etiqueta.TextColor3 = Color3.fromRGB(255, 220, 120)
	etiqueta.TextScaled = true
	etiqueta.Font = Enum.Font.FredokaOne
	etiqueta.TextXAlignment = Enum.TextXAlignment.Left
	etiqueta.LayoutOrder = orden
	etiqueta.Parent = lista

	local fichas = catalogo:GetChildren()
	table.sort(fichas, function(a, b)
		return a:GetAttribute("Orden") < b:GetAttribute("Orden")
	end)

	for _, ficha in fichas do
		local id = ficha:GetAttribute("Id")
		local maximo = ficha:GetAttribute("Maximo")
		local cantidad = jugador:GetAttribute("Casa_" .. id) or 0
		local completo = cantidad >= maximo
		local textoMueble = ficha:GetAttribute("Nombre") .. "  (" .. cantidad .. "/" .. maximo .. ")  "
		textoMueble ..= if completo then "¡completo!" else ficha:GetAttribute("Precio") .. " 🪙"

		orden += 1
		local boton = crearBoton(textoMueble, UDim2.new(1, -10, 0, 40), UDim2.new(), if completo then Color3.fromRGB(80, 80, 110) else Color3.fromRGB(150, 100, 60), lista)
		boton.LayoutOrder = orden
		boton.TextStrokeTransparency = 0.4
		boton.Activated:Connect(function()
			evento:FireServer("comprar", id)
		end)
	end

	orden += 1
	local nota = Instance.new("TextLabel")
	nota.Size = UDim2.new(1, -10, 0, 40)
	nota.BackgroundTransparency = 1
	nota.Text = "🏆 Tus trofeos salen en la estantería de tu casa cuando consigues logros."
	nota.TextColor3 = Color3.fromRGB(200, 210, 255)
	nota.TextScaled = true
	nota.TextWrapped = true
	nota.Font = Enum.Font.FredokaOne
	nota.LayoutOrder = orden
	nota.Parent = lista
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

-- Si cambia algo mientras está abierta (compras, entras en casa...), la ponemos al día
local function siEstaAbierto()
	if panel.Visible then
		dibujar()
	end
end
jugador.AttributeChanged:Connect(siEstaAbierto)
task.spawn(function()
	local marcador = jugador:WaitForChild("leaderstats", 30)
	local monedas = marcador and marcador:WaitForChild("Monedas", 30)
	if monedas then
		monedas:GetPropertyChangedSignal("Value"):Connect(siEstaAbierto)
	end
end)
