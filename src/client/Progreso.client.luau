--[[
	📈 BARRA DE PROGRESO
	Una barrita arriba, debajo del reloj, que enseña en qué nivel vas y cuánto te falta para la meta.

	Usa tu nivel (lo pone el script Niveles) y cuántos niveles hay en total.

	📋 DÓNDE VA: en Roblox Studio, dentro de StarterPlayer > StarterPlayerScripts,
	como "LocalScript".
]]

local Players = game:GetService("Players")

local jugador = Players.LocalPlayer

local pantalla = Instance.new("ScreenGui")
pantalla.Name = "Progreso"
pantalla.ResetOnSpawn = false
pantalla.Parent = jugador:WaitForChild("PlayerGui")

local fondo = Instance.new("Frame")
fondo.Size = UDim2.fromOffset(280, 26)
fondo.Position = UDim2.new(0.5, -140, 0, 96)
fondo.BackgroundColor3 = Color3.fromRGB(30, 30, 60)
fondo.BackgroundTransparency = 0.25
fondo.Parent = pantalla

local esquinasFondo = Instance.new("UICorner")
esquinasFondo.CornerRadius = UDim.new(0, 13)
esquinasFondo.Parent = fondo

local relleno = Instance.new("Frame")
relleno.Size = UDim2.fromScale(0, 1)
relleno.BackgroundColor3 = Color3.fromRGB(80, 200, 120)
relleno.Parent = fondo

local esquinasRelleno = Instance.new("UICorner")
esquinasRelleno.CornerRadius = UDim.new(0, 13)
esquinasRelleno.Parent = relleno

local texto = Instance.new("TextLabel")
texto.Size = UDim2.fromScale(1, 1)
texto.BackgroundTransparency = 1
texto.TextColor3 = Color3.fromRGB(255, 255, 255)
texto.TextScaled = true
texto.Font = Enum.Font.FredokaOne
texto.TextStrokeTransparency = 0.4
texto.Parent = fondo

local function actualizar()
	local nivel = jugador:GetAttribute("Nivel") or 1
	local total = workspace:GetAttribute("TotalNiveles") or 500
	texto.Text = "🗼 Nivel " .. nivel .. " de " .. total
	relleno.Size = UDim2.fromScale(math.clamp(nivel / total, 0.02, 1), 1)
end

jugador:GetAttributeChangedSignal("Nivel"):Connect(actualizar)
workspace:GetAttributeChangedSignal("TotalNiveles"):Connect(actualizar)
actualizar()
