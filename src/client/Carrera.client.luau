--[[
	🏁 BOTÓN "CARRERA" Y CARTEL
	  - El botón de la izquierda te apunta a la carrera (o te saca).
	  - Arriba en el centro sale un cartel con lo que pasa: quién falta, la cuenta atrás, el tiempo...

	Lo organiza el script "Carrera" del servidor.

	📋 DÓNDE VA: en Roblox Studio, dentro de StarterPlayer > StarterPlayerScripts,
	como "LocalScript".
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local jugador = Players.LocalPlayer
local evento = ReplicatedStorage:WaitForChild("Carrera")

local pantalla = Instance.new("ScreenGui")
pantalla.Name = "Carrera"
pantalla.ResetOnSpawn = false
pantalla.Parent = jugador:WaitForChild("PlayerGui")

local function redondear(objeto, radio)
	local esquinas = Instance.new("UICorner")
	esquinas.CornerRadius = UDim.new(0, radio)
	esquinas.Parent = objeto
end

-- El botón
local boton = Instance.new("TextButton")
boton.Size = UDim2.fromOffset(200, 46)
boton.Position = UDim2.new(0, 12, 0.3, 108)
boton.BackgroundColor3 = Color3.fromRGB(40, 150, 90)
boton.TextColor3 = Color3.fromRGB(255, 255, 255)
boton.TextScaled = true
boton.Font = Enum.Font.FredokaOne
boton.Parent = pantalla
redondear(boton, 10)

-- El cartel de arriba
local cartel = Instance.new("TextLabel")
cartel.Size = UDim2.fromOffset(420, 40)
cartel.Position = UDim2.new(0.5, -210, 0, 126)
cartel.BackgroundColor3 = Color3.fromRGB(40, 110, 70)
cartel.BackgroundTransparency = 0.15
cartel.TextColor3 = Color3.fromRGB(255, 255, 255)
cartel.TextScaled = true
cartel.Font = Enum.Font.FredokaOne
cartel.Visible = false
cartel.Parent = pantalla
redondear(cartel, 12)

local function actualizar()
	local texto = workspace:GetAttribute("CarreraTexto") or ""
	cartel.Visible = texto ~= ""
	cartel.Text = texto

	if jugador:GetAttribute("EnCarrera") then
		boton.Text = "🏁 Salir de la carrera"
		boton.BackgroundColor3 = Color3.fromRGB(170, 80, 60)
	else
		boton.Text = "🏁 Carrera"
		boton.BackgroundColor3 = Color3.fromRGB(40, 150, 90)
	end
end

boton.Activated:Connect(function()
	if jugador:GetAttribute("EnCarrera") then
		evento:FireServer("salir")
	else
		evento:FireServer("unirse")
	end
end)

workspace:GetAttributeChangedSignal("CarreraTexto"):Connect(actualizar)
jugador:GetAttributeChangedSignal("EnCarrera"):Connect(actualizar)
actualizar()
