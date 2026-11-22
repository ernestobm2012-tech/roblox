--[[
	🪙 MONEDAS QUE GIRAN
	Hace girar las monedas de los niveles, pero solo las que tienes cerca (así el juego va ligero
	aunque haya miles de monedas). Cada jugador ve girar las suyas en su pantalla.

	📋 DÓNDE VA: en Roblox Studio, dentro de StarterPlayer > StarterPlayerScripts,
	como "LocalScript".
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")

local jugador = Players.LocalPlayer

-- ⚙️ AJUSTES
local ETIQUETA = "MonedaGiratoria" -- las monedas del script Niveles llevan esta etiqueta
local DISTANCIA = 150 -- solo giran las monedas que están a menos de esta distancia
local VELOCIDAD = 2 -- cuánto gira

local todas = {} -- todas las monedas que conocemos
local cercanas = {} -- las que tenemos cerca ahora mismo

for _, moneda in CollectionService:GetTagged(ETIQUETA) do
	todas[moneda] = true
end
CollectionService:GetInstanceAddedSignal(ETIQUETA):Connect(function(moneda)
	todas[moneda] = true
end)
CollectionService:GetInstanceRemovedSignal(ETIQUETA):Connect(function(moneda)
	todas[moneda] = nil
end)

-- Cada cuarto de segundo miramos qué monedas tenemos cerca
task.spawn(function()
	while true do
		local personaje = jugador.Character
		local raiz = personaje and personaje:FindFirstChild("HumanoidRootPart")
		if raiz then
			local posicion = raiz.Position
			local lista = {}
			for moneda in todas do
				if moneda.Parent and (moneda.Position - posicion).Magnitude < DISTANCIA then
					table.insert(lista, moneda)
				end
			end
			cercanas = lista
		end
		task.wait(0.25)
	end
end)

-- Y hacemos girar las cercanas
RunService.RenderStepped:Connect(function()
	local giro = os.clock() * VELOCIDAD
	for _, moneda in cercanas do
		moneda.CFrame = CFrame.new(moneda.Position) * CFrame.Angles(0, giro, 0)
	end
end)
