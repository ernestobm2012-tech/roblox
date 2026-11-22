--[[
	👋 BIENVENIDA
	Enseña un mensaje en la pantalla de cada jugador cuando entra al juego,
	y después de unos segundos lo hace desaparecer poco a poco.

	📋 DÓNDE VA: en Roblox Studio, dentro de StarterPlayer > StarterPlayerScripts,
	como "LocalScript".
]]

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local jugador = Players.LocalPlayer

local pantalla = Instance.new("ScreenGui")
pantalla.Name = "Bienvenida"
pantalla.ResetOnSpawn = false
pantalla.Parent = jugador:WaitForChild("PlayerGui")

local mensaje = Instance.new("TextLabel")
mensaje.Size = UDim2.fromScale(0.6, 0.12)
mensaje.Position = UDim2.fromScale(0.5, 0.2)
mensaje.AnchorPoint = Vector2.new(0.5, 0.5)
mensaje.BackgroundColor3 = Color3.fromRGB(40, 40, 90)
mensaje.BackgroundTransparency = 0.2
mensaje.TextColor3 = Color3.fromRGB(255, 255, 255)
mensaje.TextScaled = true
mensaje.Font = Enum.Font.FredokaOne
mensaje.Text = "¡Hola, " .. jugador.DisplayName .. "! Llega a la 🏆 sin tocar la lava"
mensaje.Parent = pantalla

-- Esquinas redondeadas
local esquinas = Instance.new("UICorner")
esquinas.CornerRadius = UDim.new(0, 16)
esquinas.Parent = mensaje

-- Esperamos 6 segundos y lo hacemos desaparecer en 1 segundo
task.wait(6)
local desaparecer = TweenService:Create(mensaje, TweenInfo.new(1), {
	TextTransparency = 1,
	BackgroundTransparency = 1,
})
desaparecer:Play()
desaparecer.Completed:Wait()
pantalla:Destroy()
