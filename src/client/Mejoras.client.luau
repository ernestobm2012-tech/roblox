--[[
	📊 PANEL DE MEJORAS
	Un panelito a la izquierda de la pantalla que enseña el nivel de tus mejoras de la tienda
	(salto, correr y brillo) y cuánto cuesta la siguiente.

	Los datos los pone el script "Tienda" (en atributos del jugador).

	📋 DÓNDE VA: en Roblox Studio, dentro de StarterPlayer > StarterPlayerScripts,
	como "LocalScript".
]]

local Players = game:GetService("Players")

local jugador = Players.LocalPlayer

-- Las mejoras que enseñamos: { id (como en la tienda), nombre }
local MEJORAS = {
	{ "salto", "🦘 Salto" },
	{ "velocidad", "👟 Correr" },
	{ "brillo", "✨ Brillo" },
}

local pantalla = Instance.new("ScreenGui")
pantalla.Name = "Mejoras"
pantalla.ResetOnSpawn = false
pantalla.Parent = jugador:WaitForChild("PlayerGui")

local caja = Instance.new("Frame")
caja.Size = UDim2.fromOffset(250, 92)
caja.Position = UDim2.new(0, 12, 0.62, 0)
caja.BackgroundColor3 = Color3.fromRGB(30, 30, 60)
caja.BackgroundTransparency = 0.3
caja.Parent = pantalla

local esquinas = Instance.new("UICorner")
esquinas.CornerRadius = UDim.new(0, 12)
esquinas.Parent = caja

local etiquetas = {}
for i, mejora in MEJORAS do
	local etiqueta = Instance.new("TextLabel")
	etiqueta.Size = UDim2.new(1, -16, 0, 26)
	etiqueta.Position = UDim2.fromOffset(8, 5 + (i - 1) * 28)
	etiqueta.BackgroundTransparency = 1
	etiqueta.TextColor3 = Color3.fromRGB(255, 255, 255)
	etiqueta.TextXAlignment = Enum.TextXAlignment.Left
	etiqueta.TextScaled = true
	etiqueta.Font = Enum.Font.FredokaOne
	etiqueta.Parent = caja
	etiquetas[i] = etiqueta
end

local function actualizar()
	for i, mejora in MEJORAS do
		local id, nombre = mejora[1], mejora[2]
		local nivel = jugador:GetAttribute("Mejora_" .. id) or 0
		local precio = jugador:GetAttribute("Precio_" .. id)
		local texto = nombre .. " " .. nivel
		if precio == 0 then
			texto ..= "  (¡MÁXIMO!)"
		elseif precio then
			texto ..= "  ·  siguiente: " .. precio .. " 🪙"
		end
		etiquetas[i].Text = texto
	end
end

jugador.AttributeChanged:Connect(actualizar)
actualizar()
