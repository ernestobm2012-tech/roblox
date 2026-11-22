--[[
	🎨 BOTÓN "ESTILO"
	Un botón a la izquierda de la pantalla. Al pulsarlo se abre una ventana con los COLORES y las
	ESTELAS que se compran con monedas. Pulsa una para comprarla (si no la tienes) o para ponértela
	(si ya la tienes). Pulsa "Quitar" para quitarte lo que llevas.

	La compra la hace el script "Estilo" del servidor.

	📋 DÓNDE VA: en Roblox Studio, dentro de StarterPlayer > StarterPlayerScripts,
	como "LocalScript".
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local jugador = Players.LocalPlayer
local evento = ReplicatedStorage:WaitForChild("EstiloAccion")
local catalogo = ReplicatedStorage:WaitForChild("CatalogoEstilo")

local pantalla = Instance.new("ScreenGui")
pantalla.Name = "Estilo"
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

local abrir = crearBoton("🎨 Estilo", UDim2.fromOffset(200, 46), UDim2.new(0, 12, 0.3, 54), Color3.fromRGB(150, 70, 230), pantalla)

local panel = Instance.new("Frame")
panel.Size = UDim2.fromOffset(420, 460)
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
titulo.Text = "🎨 Tu estilo"
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

	-- Ordenamos la lista de cosas
	local fichas = catalogo:GetChildren()
	table.sort(fichas, function(a, b)
		return a:GetAttribute("Orden") < b:GetAttribute("Orden")
	end)

	local orden = 0
	local function crearFila(texto)
		orden += 1
		local etiqueta = Instance.new("TextLabel")
		etiqueta.Size = UDim2.new(1, -10, 0, 30)
		etiqueta.BackgroundTransparency = 1
		etiqueta.Text = texto
		etiqueta.TextColor3 = Color3.fromRGB(255, 220, 120)
		etiqueta.TextScaled = true
		etiqueta.Font = Enum.Font.FredokaOne
		etiqueta.TextXAlignment = Enum.TextXAlignment.Left
		etiqueta.LayoutOrder = orden
		etiqueta.Parent = lista
	end

	for _, tipo in { { "color", "🎨 Colores (🪙 " }, { "estela", "🌈 Estelas (🪙 " } } do
		crearFila(tipo[2] .. monedas .. " monedas)")
		local puesto = jugador:GetAttribute("Equipo_" .. tipo[1])

		-- Botón para quitarse lo puesto
		orden += 1
		local quitar = crearBoton("Quitar", UDim2.new(1, -10, 0, 34), UDim2.new(), Color3.fromRGB(90, 90, 130), lista)
		quitar.LayoutOrder = orden
		quitar.Activated:Connect(function()
			evento:FireServer("equipar", tipo[1], "")
		end)

		for _, ficha in fichas do
			if ficha:GetAttribute("Tipo") == tipo[1] then
				local id = ficha:GetAttribute("Id")
				local loTiene = jugador:GetAttribute("Estilo_" .. tipo[1] .. "_" .. id) == true
				local texto
				if puesto == id then
					texto = ficha:GetAttribute("Nombre") .. "  ✅ puesto"
				elseif loTiene then
					texto = ficha:GetAttribute("Nombre") .. "  (tuyo: ponértelo)"
				else
					texto = ficha:GetAttribute("Nombre") .. "  —  " .. ficha:GetAttribute("Precio") .. " 🪙"
				end

				orden += 1
				local boton = crearBoton(texto, UDim2.new(1, -10, 0, 40), UDim2.new(), ficha:GetAttribute("Color"), lista)
				boton.LayoutOrder = orden
				-- Letras con borde para que se lean sobre cualquier color
				boton.TextStrokeTransparency = 0.3
				boton.Activated:Connect(function()
					if loTiene then
						evento:FireServer("equipar", tipo[1], id)
					else
						evento:FireServer("comprar", tipo[1], id)
					end
				end)
			end
		end
	end
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

-- Si cambia algo mientras está abierta (compras, te pones algo...), la ponemos al día
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
