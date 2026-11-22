--[[
	🏠 BOTÓN "MI CASA"
	Un botón a la izquierda de la pantalla. Al pulsarlo se abre una ventana donde puedes:
	  - 🏠 Ir a tu casita (o 🚪 salir de ella y volver a tu nivel)
	  - 👋 VISITAS: abrir tu casa a tus amigos de Roblox (🔓) o invitar a jugadores concretos
	  - 🎉 Poner una FIESTA con luces de colores
	  - 🎨 Pintar las paredes del color que quieras (con monedas)
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
local catalogoParedes = ReplicatedStorage:WaitForChild("CatalogoParedes")

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
panel.Size = UDim2.fromOffset(460, 520)
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

local function ordenar(fichas)
	table.sort(fichas, function(a, b)
		return a:GetAttribute("Orden") < b:GetAttribute("Orden")
	end)
	return fichas
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

	local orden = 0
	local function titular(texto)
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
	local function boton(texto, color, alAlto, accion)
		orden += 1
		local nuevo = crearBoton(texto, UDim2.new(1, -10, 0, alAlto or 40), UDim2.new(), color, lista)
		nuevo.LayoutOrder = orden
		nuevo.TextStrokeTransparency = 0.4 -- letras con borde para que se lean sobre cualquier color
		nuevo.Activated:Connect(accion)
		return nuevo
	end

	local tieneCasa = jugador:GetAttribute("CasaNumero") ~= nil
	local enCasa = jugador:GetAttribute("EnCasa") == true

	-- Ir a casa o salir de ella (también vale si estás de visita)
	local texto
	if enCasa then
		texto = "🚪 Salir de la casa"
	elseif tieneCasa then
		texto = "🏠 Ir a mi casa"
	else
		texto = "Todavía no tienes casa (no quedan libres)"
	end
	boton(texto, Color3.fromRGB(60, 150, 110), 44, function()
		evento:FireServer(if enCasa then "salir" else "ir")
		panel.Visible = false
	end)

	if tieneCasa then
		-- 👋 Visitas
		titular("👋 Visitas")
		local abierta = jugador:GetAttribute("Casa_abierta") == 1
		boton(
			if abierta then "🔓 Abierta a mis amigos (pulsa para cerrar)" else "🔒 Cerrada (pulsa para abrir a mis amigos)",
			if abierta then Color3.fromRGB(60, 140, 90) else Color3.fromRGB(120, 80, 80),
			40,
			function()
				evento:FireServer("abrir", if abierta then "no" else "si")
			end
		)

		local fiesta = jugador:GetAttribute("FiestaManual") == 1
		boton(
			if fiesta then "🎉 Fiesta puesta (pulsa para pararla)" else "🎉 Poner una fiesta (luces de colores)",
			if fiesta then Color3.fromRGB(150, 70, 220) else Color3.fromRGB(90, 70, 130),
			40,
			function()
				evento:FireServer("fiesta", if fiesta then "no" else "si")
			end
		)
		titular("(La fiesta también empieza sola cuando hay visitas)")

		local hayOtros = false
		for _, otro in Players:GetPlayers() do
			if otro ~= jugador then
				hayOtros = true
				local invitado = otro:GetAttribute("Invitado_" .. jugador.UserId) == true
				boton(
					if invitado then "✅ Invitado: " .. otro.DisplayName .. " (quitar)" else "👋 Invitar a " .. otro.DisplayName,
					if invitado then Color3.fromRGB(60, 140, 90) else Color3.fromRGB(70, 90, 150),
					36,
					function()
						evento:FireServer("invitar", tostring(otro.UserId))
					end
				)
			end
		end
		if not hayOtros then
			titular("(Ahora no hay nadie más a quien invitar)")
		end

		-- 🎨 Paredes
		titular("🎨 Paredes (tienes 🪙 " .. monedas .. ")")
		local puesta = jugador:GetAttribute("Casa_pared")
		boton("Color de siempre", Color3.fromRGB(90, 90, 130), 34, function()
			evento:FireServer("pared", "")
		end)
		for _, ficha in ordenar(catalogoParedes:GetChildren()) do
			local id = ficha:GetAttribute("Id")
			local loTiene = jugador:GetAttribute("Casa_pared_" .. id) == true
			local textoPared = ficha:GetAttribute("Nombre")
			if puesta == id then
				textoPared ..= "  ✅ puesta"
			elseif loTiene then
				textoPared ..= "  (tuyo: ponértelo)"
			else
				textoPared ..= "  —  " .. ficha:GetAttribute("Precio") .. " 🪙"
			end
			local colorPared = ficha:GetAttribute("Color")
			boton(textoPared, colorPared, 36, function()
				evento:FireServer("pared", id)
			end).TextColor3 = Color3.fromRGB(30, 30, 40) -- las letras oscuras se leen mejor sobre colores claros
		end

		-- 🛋️ Muebles
		titular("🛋️ Muebles (tienes 🪙 " .. monedas .. ")")
		for _, ficha in ordenar(catalogo:GetChildren()) do
			local id = ficha:GetAttribute("Id")
			local maximo = ficha:GetAttribute("Maximo")
			local cantidad = jugador:GetAttribute("Casa_" .. id) or 0
			local completo = cantidad >= maximo
			local textoMueble = ficha:GetAttribute("Nombre") .. "  (" .. cantidad .. "/" .. maximo .. ")  "
			textoMueble ..= if completo then "¡completo!" else ficha:GetAttribute("Precio") .. " 🪙"
			boton(textoMueble, if completo then Color3.fromRGB(80, 80, 110) else Color3.fromRGB(150, 100, 60), 40, function()
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

-- Si cambia algo mientras está abierta (compras, invitaciones, gente que entra o sale...), la ponemos al día
local function siEstaAbierto()
	if panel.Visible then
		dibujar()
	end
end

local function vigilar(otro)
	otro.AttributeChanged:Connect(function(nombre)
		if otro == jugador or string.sub(nombre, 1, 9) == "Invitado_" then
			siEstaAbierto()
		end
	end)
end
for _, otro in Players:GetPlayers() do
	vigilar(otro)
end
Players.PlayerAdded:Connect(function(otro)
	vigilar(otro)
	siEstaAbierto()
end)
Players.PlayerRemoving:Connect(function()
	task.defer(siEstaAbierto)
end)

task.spawn(function()
	local marcadorMonedas = jugador:WaitForChild("leaderstats", 30)
	local monedas = marcadorMonedas and marcadorMonedas:WaitForChild("Monedas", 30)
	if monedas then
		monedas:GetPropertyChangedSignal("Value"):Connect(siEstaAbierto)
	end
end)
