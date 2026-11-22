--[[
	🐾 BOTÓN "MASCOTAS"
	Un botón a la izquierda de la pantalla. Al pulsarlo se abre una ventana con las mascotas.
	Pulsa una para comprarla (si no la tienes) o para ponértela (si ya la tienes).
	Pulsa "Quitar" para quedarte sin mascota. Cada mascota te hace correr más rápido, ¡y sube de
	nivel mientras juegas! Aquí ves el nivel de cada una y lo que le falta para el siguiente.

	La compra y los niveles los hace el script "Mascotas" del servidor.

	📋 DÓNDE VA: en Roblox Studio, dentro de StarterPlayer > StarterPlayerScripts,
	como "LocalScript".
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local jugador = Players.LocalPlayer
local evento = ReplicatedStorage:WaitForChild("MascotaAccion")
local catalogo = ReplicatedStorage:WaitForChild("CatalogoMascotas")

local pantalla = Instance.new("ScreenGui")
pantalla.Name = "Mascotas"
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

local abrir = crearBoton("🐾 Mascotas", UDim2.fromOffset(200, 46), UDim2.new(0, 12, 0.3, 216), Color3.fromRGB(200, 120, 60), pantalla)

local panel = Instance.new("Frame")
panel.Size = UDim2.fromOffset(440, 440)
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
titulo.Text = "🐾 Tus mascotas"
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

-- El nivel que corresponde a una cantidad de XP (igual que en el servidor)
local function nivelDeXP(xp)
	local divisor = workspace:GetAttribute("MascotaDivisor") or 8
	local maximo = workspace:GetAttribute("MascotaNivelMaximo") or 30
	return math.min(maximo, 1 + math.floor(math.sqrt(xp / divisor)))
end

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
	local etiqueta = Instance.new("TextLabel")
	etiqueta.Size = UDim2.new(1, -10, 0, 30)
	etiqueta.BackgroundTransparency = 1
	etiqueta.Text = "Tienes 🪙 " .. monedas .. " monedas"
	etiqueta.TextColor3 = Color3.fromRGB(255, 220, 120)
	etiqueta.TextScaled = true
	etiqueta.Font = Enum.Font.FredokaOne
	etiqueta.TextXAlignment = Enum.TextXAlignment.Left
	etiqueta.LayoutOrder = orden
	etiqueta.Parent = lista

	orden += 1
	local quitar = crearBoton("Quitar mascota", UDim2.new(1, -10, 0, 34), UDim2.new(), Color3.fromRGB(90, 90, 130), lista)
	quitar.LayoutOrder = orden
	quitar.Activated:Connect(function()
		evento:FireServer("equipar", "")
	end)

	local fichas = catalogo:GetChildren()
	table.sort(fichas, function(a, b)
		return a:GetAttribute("Orden") < b:GetAttribute("Orden")
	end)

	local puesta = jugador:GetAttribute("Equipo_mascota")
	local maximo = workspace:GetAttribute("MascotaNivelMaximo") or 30
	local divisor = workspace:GetAttribute("MascotaDivisor") or 8
	for _, ficha in fichas do
		local id = ficha:GetAttribute("Id")
		local laTiene = jugador:GetAttribute("Estilo_mascota_" .. id) == true
		local xp = jugador:GetAttribute("Mascota_xp_" .. id) or 0
		local nivel = nivelDeXP(xp)
		local texto
		if puesta == id then
			local progreso = "¡nivel máximo!"
			if nivel < maximo then
				progreso = "XP " .. math.floor(xp - divisor * (nivel - 1) ^ 2) .. "/" .. math.floor(divisor * nivel ^ 2 - divisor * (nivel - 1) ^ 2)
			end
			texto = ficha:GetAttribute("Nombre") .. "  Nv " .. nivel .. "  ✅ puesta  (" .. progreso .. ")"
		elseif laTiene then
			texto = ficha:GetAttribute("Nombre") .. "  Nv " .. nivel .. "  (tuya: ponértela)"
		else
			texto = ficha:GetAttribute("Nombre") .. "  —  " .. ficha:GetAttribute("Precio") .. " 🪙  (+" .. ficha:GetAttribute("Bonus") .. " velocidad)"
		end

		orden += 1
		local boton = crearBoton(texto, UDim2.new(1, -10, 0, 44), UDim2.new(), ficha:GetAttribute("Color"), lista)
		boton.LayoutOrder = orden
		boton.TextStrokeTransparency = 0.3 -- letras con borde para que se lean sobre cualquier color
		boton.Activated:Connect(function()
			if laTiene then
				evento:FireServer("equipar", id)
			else
				evento:FireServer("comprar", id)
			end
		end)
	end

	orden += 1
	local nota = Instance.new("TextLabel")
	nota.Size = UDim2.new(1, -10, 0, 40)
	nota.BackgroundTransparency = 1
	nota.Text = "⭐ Tu mascota sube de nivel mientras juegas, recoges monedas y subes de nivel. ¡Cada nivel corres más!"
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

-- Si cambia algo mientras está abierta (compras, XP, te pones otra...), la ponemos al día
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
