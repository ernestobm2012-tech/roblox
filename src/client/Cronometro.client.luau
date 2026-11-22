--[[
	⏱️ CRONÓMETRO (parte de la pantalla)
	Dibuja el reloj arriba, en el centro de la pantalla:
	  - Esperando: te dice que salgas de la salida para empezar.
	  - Sin reloj: sigues en un nivel guardado (el tiempo se mide desde el nivel 1).
	  - Corriendo: los segundos van subiendo.
	  - En la meta: se para y te enseña tu tiempo (y si es récord).

	Los datos los manda el script "Cronometro" del servidor.

	📋 DÓNDE VA: en Roblox Studio, dentro de StarterPlayer > StarterPlayerScripts,
	como "LocalScript".
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local jugador = Players.LocalPlayer

local pantalla = Instance.new("ScreenGui")
pantalla.Name = "Cronometro"
pantalla.ResetOnSpawn = false
pantalla.Parent = jugador:WaitForChild("PlayerGui")

local caja = Instance.new("Frame")
caja.Size = UDim2.fromOffset(280, 78)
caja.Position = UDim2.new(0.5, 0, 0, 12)
caja.AnchorPoint = Vector2.new(0.5, 0)
caja.BackgroundColor3 = Color3.fromRGB(30, 30, 60)
caja.BackgroundTransparency = 0.25
caja.Parent = pantalla

local esquinas = Instance.new("UICorner")
esquinas.CornerRadius = UDim.new(0, 16)
esquinas.Parent = caja

local tiempo = Instance.new("TextLabel")
tiempo.Size = UDim2.fromScale(1, 0.62)
tiempo.BackgroundTransparency = 1
tiempo.TextScaled = true
tiempo.Font = Enum.Font.FredokaOne
tiempo.TextColor3 = Color3.fromRGB(255, 255, 255)
tiempo.Parent = caja

local nota = Instance.new("TextLabel")
nota.Size = UDim2.fromScale(1, 0.34)
nota.Position = UDim2.fromScale(0, 0.62)
nota.BackgroundTransparency = 1
nota.TextScaled = true
nota.Font = Enum.Font.FredokaOne
nota.TextColor3 = Color3.fromRGB(200, 210, 255)
nota.Parent = caja

RunService.RenderStepped:Connect(function()
	local estado = jugador:GetAttribute("CronoEstado")
	local mejor = jugador:GetAttribute("MejorTiempo")

	local textoRecord = "Aún no tienes récord"
	if type(mejor) == "number" and mejor > 0 then
		textoRecord = string.format("Récord: %.2f s", mejor)
	end

	if estado == "corriendo" then
		local segundos = workspace:GetServerTimeNow() - (jugador:GetAttribute("CronoInicio") or 0)
		tiempo.Text = string.format("⏱️ %.2f", math.max(segundos, 0))
		tiempo.TextColor3 = Color3.fromRGB(255, 255, 255)
		nota.Text = textoRecord
	elseif estado == "terminado" then
		tiempo.Text = string.format("🏆 %.2f s", jugador:GetAttribute("CronoFinal") or 0)
		tiempo.TextColor3 = Color3.fromRGB(255, 220, 80)
		if jugador:GetAttribute("CronoRecord") then
			nota.Text = "¡NUEVO RÉCORD! 🎉"
		else
			nota.Text = textoRecord
		end
	elseif estado == "sinreloj" then
		tiempo.Text = "⏱️ --"
		tiempo.TextColor3 = Color3.fromRGB(255, 255, 255)
		nota.Text = "Vuelve a la salida para medir tu tiempo"
	else
		tiempo.Text = "⏱️ 0.00"
		tiempo.TextColor3 = Color3.fromRGB(255, 255, 255)
		nota.Text = "¡Sal de la salida para empezar!"
	end
end)
