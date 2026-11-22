--[[
	🏆 BOTÓN "RETO SEMANAL"
	Un botón a la izquierda de la pantalla. Al pulsarlo ves:
	  - El RETO DE ESTA SEMANA (por ejemplo "Llega 80 niveles más arriba sin morir") y cuánto llevas
	  - Las monedas y el premio especial para tu casa si lo cumples
	  - Si es el reto de "sin morir" y te caes: el botón "🔁 Nuevo intento"
	  - La TEMPORADA (cada 4 semanas) y todos los premios de jardín: los que ya tienes y los que te faltan

	Lo hace todo el script "Retos" del servidor.

	📋 DÓNDE VA: en Roblox Studio, dentro de StarterPlayer > StarterPlayerScripts,
	como "LocalScript".
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local jugador = Players.LocalPlayer
local evento = ReplicatedStorage:WaitForChild("RetoAccion", 30)
local catalogo = ReplicatedStorage:WaitForChild("CatalogoPremios", 30)
if not evento or not catalogo then
	return
end

-- Lo que dice cada tipo de reto (el {n} se cambia por el número)
local TEXTOS = {
	sinMorir = "💪 Sube {n} niveles SIN MORIR",
	monedas = "🪙 Recoge {n} monedas",
	carreras = "🏁 Corre {n} carreras",
	visitas = "🏠 Recibe {n} visitas en tu casa",
	muebles = "🛋️ Compra {n} muebles",
	dardos = "🎯 Lanza {n} dardos en tu diana",
	comidas = "🍳 Cocina {n} platos en tu cocina",
	fotos = "📸 Haz {n} fotos con tu cámara",
	nivel = "🗼 Sube {n} niveles",
}

local pantalla = Instance.new("ScreenGui")
pantalla.Name = "Retos"
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

local abrir = crearBoton("🏆 Reto semanal", UDim2.fromOffset(200, 46), UDim2.new(0, 12, 0.3, 378), Color3.fromRGB(190, 130, 20), pantalla)

local panel = Instance.new("Frame")
panel.Size = UDim2.fromOffset(440, 500)
panel.Position = UDim2.fromScale(0.5, 0.5)
panel.AnchorPoint = Vector2.new(0.5, 0.5)
panel.BackgroundColor3 = Color3.fromRGB(45, 35, 70)
panel.Visible = false
panel.Parent = pantalla
redondear(panel, 16)

local titulo = Instance.new("TextLabel")
titulo.Size = UDim2.new(1, -70, 0, 36)
titulo.Position = UDim2.fromOffset(14, 8)
titulo.BackgroundTransparency = 1
titulo.Text = "🏆 Reto de la semana"
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

local function dibujar()
	for _, hijo in lista:GetChildren() do
		if hijo:IsA("GuiObject") then
			hijo:Destroy()
		end
	end

	local orden = 0
	local function texto(contenido, alto, color)
		orden += 1
		local etiqueta = Instance.new("TextLabel")
		etiqueta.Size = UDim2.new(1, -10, 0, alto)
		etiqueta.BackgroundTransparency = 1
		etiqueta.Text = contenido
		etiqueta.TextColor3 = color or Color3.fromRGB(255, 255, 255)
		etiqueta.TextScaled = true
		etiqueta.TextWrapped = true
		etiqueta.Font = Enum.Font.FredokaOne
		etiqueta.TextXAlignment = Enum.TextXAlignment.Left
		etiqueta.LayoutOrder = orden
		etiqueta.Parent = lista
		return etiqueta
	end

	local tipo = workspace:GetAttribute("RetoTipo")
	local semana = workspace:GetAttribute("RetoSemana")
	if not tipo then
		texto("Cargando el reto...", 30)
		return
	end
	local objetivo = workspace:GetAttribute("RetoObjetivo") or 1
	local monedasPremio = workspace:GetAttribute("RetoMonedas") or 0
	local idPremio = workspace:GetAttribute("RetoPremio")
	local hecho = jugador:GetAttribute("Reto_hecho") == true
	local progreso = jugador:GetAttribute("Reto_progreso") or 0
	local meta = jugador:GetAttribute("Reto_objetivo") or objetivo
	-- En "sin morir" el progreso va de 0 a "objetivo" niveles (la meta guardada es el nivel final)
	local total = if tipo == "sinMorir" then objetivo else meta

	texto(
		"🌟 Temporada " .. (workspace:GetAttribute("RetoTemporada") or 1) .. " · Semana " .. (workspace:GetAttribute("RetoSemanaDeTemporada") or 1) .. " de 4",
		26,
		Color3.fromRGB(255, 220, 120)
	)
	texto(string.gsub(TEXTOS[tipo] or "Reto nuevo", "{n}", tostring(objetivo)), 44)

	-- Barra de progreso
	orden += 1
	local fondo = Instance.new("Frame")
	fondo.Size = UDim2.new(1, -10, 0, 26)
	fondo.BackgroundColor3 = Color3.fromRGB(25, 20, 45)
	fondo.LayoutOrder = orden
	fondo.Parent = lista
	redondear(fondo, 8)
	local relleno = Instance.new("Frame")
	relleno.Size = UDim2.fromScale(math.clamp(progreso / math.max(total, 1), 0, 1), 1)
	relleno.BackgroundColor3 = if hecho then Color3.fromRGB(255, 200, 40) else Color3.fromRGB(80, 200, 110)
	relleno.BorderSizePixel = 0
	relleno.Parent = fondo
	redondear(relleno, 8)
	local numeros = Instance.new("TextLabel")
	numeros.Size = UDim2.fromScale(1, 1)
	numeros.BackgroundTransparency = 1
	numeros.Text = progreso .. " / " .. total
	numeros.TextColor3 = Color3.fromRGB(255, 255, 255)
	numeros.TextScaled = true
	numeros.Font = Enum.Font.FredokaOne
	numeros.TextStrokeTransparency = 0.5
	numeros.Parent = fondo

	local nombrePremio = ""
	local iconoPremio = ""
	local ficha = idPremio and catalogo:FindFirstChild(idPremio)
	if ficha then
		nombrePremio = ficha:GetAttribute("Nombre")
		iconoPremio = ficha:GetAttribute("Icono")
	end
	texto("🎁 Premio: " .. monedasPremio .. " 🪙 y " .. iconoPremio .. " " .. nombrePremio .. " para el jardín de tu casa", 44, Color3.fromRGB(200, 230, 255))

	if hecho then
		texto("✅ ¡Reto cumplido! Vuelve la semana que viene.", 30, Color3.fromRGB(255, 220, 120))
	elseif tipo == "sinMorir" then
		if jugador:GetAttribute("Reto_vivo") == 1 then
			texto("💪 ¡Vas bien! Si te caes, se rompe el reto.", 30)
		else
			texto("💀 Te caíste. ¡Puedes intentarlo otra vez!", 30, Color3.fromRGB(255, 150, 150))
			orden += 1
			local nuevo = crearBoton("🔁 Nuevo intento", UDim2.new(1, -10, 0, 44), UDim2.new(), Color3.fromRGB(70, 130, 220), lista)
			nuevo.LayoutOrder = orden
			nuevo.Activated:Connect(function()
				evento:FireServer("nuevoIntento")
			end)
		end
	end

	texto("🏡 Premios para tu jardín", 30, Color3.fromRGB(255, 220, 120))
	local fichas = catalogo:GetChildren()
	table.sort(fichas, function(a, b)
		return a:GetAttribute("Orden") < b:GetAttribute("Orden")
	end)
	for _, premio in fichas do
		local lo_tiene = jugador:GetAttribute("Premio_" .. premio:GetAttribute("Id")) == true
		local estado = if lo_tiene then "  ✅ en tu jardín" else "  🔒 aún no"
		texto(
			premio:GetAttribute("Icono") .. " " .. premio:GetAttribute("Nombre") .. estado,
			28,
			if lo_tiene then Color3.fromRGB(150, 240, 160) else Color3.fromRGB(200, 200, 220)
		)
	end
	if semana then
		texto("(El reto cambia cada semana. ¡Vuelve a ver cuál toca!)", 26, Color3.fromRGB(190, 200, 255))
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

local function siEstaAbierto()
	if panel.Visible then
		dibujar()
	end
end

jugador.AttributeChanged:Connect(function(nombre)
	if string.sub(nombre, 1, 5) == "Reto_" or string.sub(nombre, 1, 7) == "Premio_" then
		siEstaAbierto()
	end
end)
workspace.AttributeChanged:Connect(function(nombre)
	if string.sub(nombre, 1, 4) == "Reto" then
		siEstaAbierto()
	end
end)
