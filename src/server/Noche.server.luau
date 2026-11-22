--[[
	🌙 NOCHE Y FAROLAS
	El juego empieza por la tarde y, en unos segundos, se va haciendo de noche.
	Cuando oscurece, las farolas se encienden solas. 💡

	Las farolas las construye el script Niveles. Este script solo enciende y apaga sus luces
	(las reconoce porque tienen la etiqueta "FarolaLuz").

	📋 DÓNDE VA: en Roblox Studio, dentro de ServerScriptService, como "Script".
]]

local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local CollectionService = game:GetService("CollectionService")

-- ⚙️ AJUSTES: ¡cambia estos valores y mira qué pasa!
local AJUSTES = {
	horaInicial = 15, -- hora a la que empieza el juego (15 = las 3 de la tarde)
	horaFinal = 23.9, -- hora a la que termina de oscurecer (23.9 = casi medianoche)
	segundosHastaLaNoche = 45, -- lo que tarda en hacerse de noche
	horaDeEncender = 18, -- las farolas se encienden a esta hora (18 = las 6 de la tarde)
	colorAmbienteExterior = Color3.fromRGB(70, 75, 120), -- el color del aire de noche (azulado)
	colorAmbiente = Color3.fromRGB(40, 40, 80),
}

Lighting.ClockTime = AJUSTES.horaInicial

local function esDeNoche()
	local hora = Lighting.ClockTime
	return hora >= AJUSTES.horaDeEncender or hora < 6
end

-- Las farolas nuevas (que construye Niveles) se ponen como toque ahora mismo
local function ajustarFarola(luz)
	luz.Enabled = esDeNoche()
end

for _, luz in CollectionService:GetTagged("FarolaLuz") do
	ajustarFarola(luz)
end
CollectionService:GetInstanceAddedSignal("FarolaLuz"):Connect(ajustarFarola)

-- Cuando cambia de día a noche, encendemos todas de golpe
local encendidas = esDeNoche()
Lighting:GetPropertyChangedSignal("ClockTime"):Connect(function()
	local noche = esDeNoche()
	if noche ~= encendidas then
		encendidas = noche
		for _, luz in CollectionService:GetTagged("FarolaLuz") do
			luz.Enabled = noche
		end
	end
end)

-- 🌅 → 🌙 Oscurece poco a poco
local oscurecer = TweenService:Create(
	Lighting,
	TweenInfo.new(AJUSTES.segundosHastaLaNoche, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
	{
		ClockTime = AJUSTES.horaFinal,
		OutdoorAmbient = AJUSTES.colorAmbienteExterior,
		Ambient = AJUSTES.colorAmbiente,
		Brightness = 1,
	}
)
oscurecer:Play()

print("🌙 Se va haciendo de noche...")
