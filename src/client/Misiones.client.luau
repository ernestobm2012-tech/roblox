--[[
	📅 BOTÓN "MISIONES"
	Un botón a la izquierda de la pantalla. Al pulsarlo se abre una ventana con tus 3 misiones del
	día, lo que llevas de cada una, el premio y cuánto falta para las misiones nuevas.

	Las misiones las organiza el script "Misiones" del servidor.

	📋 DÓNDE VA: en Roblox Studio, dentro de StarterPlayer > StarterPlayerScripts,
	como "LocalScript".
]]

local Players = game:GetService("Players")

local jugador = Players.LocalPlayer

local CUANTAS = 3 -- misiones por día (igual que en el script Misiones)

local pantalla = Instance.new("ScreenGui")
pantalla.Name = "Misiones"
pantalla.ResetOnSpawn = false
pantalla.Parent = jugador:WaitForChild("PlayerGui")

local function redondear(objeto, radio)
	local esquinas = Instance.new("UICorner")
	esquinas.CornerRadius = UDim.new(0, radio)
	esquinas.Parent = objeto
end

local function crearTexto(texto, tamano, posicion, color, padre)
	local etiqueta = Instance.new("TextLabel")
	etiqueta.Size = tamano
	etiqueta.Position = posicion
	etiqueta.BackgroundTransparency = 1
	etiqueta.Text = texto
	etiqueta.TextColor3 = color
	etiqueta.TextScaled = true
	etiqueta.TextWrapped = true
	etiqueta.Font = Enum.Font.FredokaOne
	etiqueta.TextXAlignment = Enum.TextXAlignment.Left
	etiqueta.Parent = padre
	return etiqueta
end

local abrir = Instance.new("TextButton")
abrir.Size = UDim2.fromOffset(200, 46)
abrir.Position = UDim2.new(0, 12, 0.3, 270)
abrir.BackgroundColor3 = Color3.fromRGB(60, 140, 200)
abrir.TextColor3 = Color3.fromRGB(255, 255, 255)
abrir.TextScaled = true
abrir.Font = Enum.Font.FredokaOne
abrir.Text = "📅 Misiones"
abrir.Parent = pantalla
redondear(abrir, 10)

local panel = Instance.new("Frame")
panel.Size = UDim2.fromOffset(420, 380)
panel.Position = UDim2.fromScale(0.5, 0.5)
panel.AnchorPoint = Vector2.new(0.5, 0.5)
panel.BackgroundColor3 = Color3.fromRGB(35, 35, 70)
panel.Visible = false
panel.Parent = pantalla
redondear(panel, 16)

crearTexto("📅 Misiones de hoy", UDim2.new(1, -70, 0, 36), UDim2.fromOffset(14, 8), Color3.fromRGB(255, 255, 255), panel)

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

-- Una fila por misión
local filas = {}
for i = 1, CUANTAS do
	local fila = Instance.new("Frame")
	fila.Size = UDim2.new(1, -24, 0, 70)
	fila.Position = UDim2.fromOffset(12, 54 + (i - 1) * 80)
	fila.BackgroundColor3 = Color3.fromRGB(55, 55, 100)
	fila.Parent = panel
	redondear(fila, 12)

	local texto = crearTexto("", UDim2.new(1, -20, 0, 30), UDim2.fromOffset(10, 5), Color3.fromRGB(255, 255, 255), fila)
	local detalle = crearTexto("", UDim2.new(1, -20, 0, 26), UDim2.fromOffset(10, 38), Color3.fromRGB(255, 220, 120), fila)
	filas[i] = { fila = fila, texto = texto, detalle = detalle }
end

local aviso = crearTexto("", UDim2.new(1, -24, 0, 30), UDim2.fromOffset(12, 54 + CUANTAS * 80), Color3.fromRGB(200, 210, 255), panel)

----------------------------------------------------------------------
-- 🧠 LO QUE HACE
----------------------------------------------------------------------

local function textoDeMision(tipo, objetivo)
	if tipo == "monedas" then
		return "🪙 Recoge " .. objetivo .. " monedas"
	elseif tipo == "nivel" then
		return "🗼 Llega al nivel " .. objetivo
	elseif tipo == "cofre" then
		return "🎁 Abre " .. objetivo .. " cofre"
	elseif tipo == "mejora" then
		return "🛒 Compra " .. objetivo .. " mejora en la tienda"
	elseif tipo == "carrera" then
		return "🏁 Corre " .. objetivo .. " carrera"
	end
	return tostring(tipo)
end

local function actualizar()
	for i = 1, CUANTAS do
		local fila = filas[i]
		local tipo = jugador:GetAttribute("Mision_" .. i .. "_tipo")
		if tipo then
			local objetivo = jugador:GetAttribute("Mision_" .. i .. "_objetivo") or 1
			local progreso = jugador:GetAttribute("Mision_" .. i .. "_progreso") or 0
			local premio = jugador:GetAttribute("Mision_" .. i .. "_premio") or 0
			fila.texto.Text = textoDeMision(tipo, objetivo)
			if jugador:GetAttribute("Mision_" .. i .. "_hecha") then
				fila.detalle.Text = "✅ ¡Hecha!  (+" .. premio .. " 🪙 ya cobradas)"
				fila.fila.BackgroundColor3 = Color3.fromRGB(40, 110, 70)
			else
				fila.detalle.Text = progreso .. " de " .. objetivo .. "  ·  premio: " .. premio .. " 🪙"
				fila.fila.BackgroundColor3 = Color3.fromRGB(55, 55, 100)
			end
		else
			fila.texto.Text = "..."
			fila.detalle.Text = ""
		end
	end

	-- ¿Cuánto falta para las misiones nuevas? (a medianoche, hora UTC)
	local falta = 86400 - os.time() % 86400
	aviso.Text = "Misiones nuevas en " .. (falta // 3600) .. " h " .. ((falta % 3600) // 60) .. " min"
end

abrir.Activated:Connect(function()
	panel.Visible = not panel.Visible
	if panel.Visible then
		actualizar()
	end
end)
cerrar.Activated:Connect(function()
	panel.Visible = false
end)

jugador.AttributeChanged:Connect(function()
	if panel.Visible then
		actualizar()
	end
end)

-- El tiempo que falta se pone al día cada medio minuto mientras está abierto
task.spawn(function()
	while true do
		task.wait(30)
		if panel.Visible then
			actualizar()
		end
	end
end)
