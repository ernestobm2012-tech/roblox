--[[
	🌙 NOCHE Y FAROLAS
	El juego empieza por la tarde y se va haciendo de noche; después amanece (¡con niebla!) y el día se repite.
	Cuando oscurece, las farolas se encienden solas 💡 y, de vez en cuando, pasa una
	ESTRELLA FUGAZ por el cielo ⭐ (pide un deseo).

	Las farolas las construye el script Niveles. Este script solo enciende y apaga sus luces
	(las reconoce porque tienen la etiqueta "FarolaLuz").

	📋 DÓNDE VA: en Roblox Studio, dentro de ServerScriptService, como "Script".
]]

local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local Debris = game:GetService("Debris")

-- ⚙️ AJUSTES: ¡cambia estos valores y mira qué pasa!
local AJUSTES = {
	horaInicial = 15, -- hora a la que empieza el juego (15 = las 3 de la tarde)
	brilloDeNoche = 0.8, -- cuánta luz hay de noche (el normal de Roblox es 2)
	brilloDeDia = 1.4, -- cuánta luz hay de día (más bajo = menos brillo)
	exposicion = -0.35, -- negativo = todo un poco más oscuro y suave
	segundosPorDia = 360, -- lo que dura un día entero (6 minutos): tarde, noche y mañana
	horaDeEncender = 18, -- las farolas se encienden a esta hora (18 = las 6 de la tarde)
	colorAmbienteExterior = Color3.fromRGB(70, 75, 120), -- el color del aire de noche (azulado)
	colorAmbiente = Color3.fromRGB(40, 40, 80),
	segundosEntreEstrellas = { 12, 25 }, -- cada cuántos segundos pasa una estrella fugaz (mínimo, máximo)
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

-- 🌅 → 🌙 → 🌅 Un día entero que se repite: atardecer, noche, MAÑANA con niebla, mediodía...
local COLOR_DIA = Color3.fromRGB(105, 112, 122)
local COLOR_DIA_AIRE = Color3.fromRGB(115, 122, 132)
Lighting.ExposureCompensation = AJUSTES.exposicion

task.spawn(function()
	local horasPorSegundo = 24 / AJUSTES.segundosPorDia
	while true do
		local hora = (Lighting.ClockTime + horasPorSegundo * 0.2) % 24
		Lighting.ClockTime = hora
		-- 0 = noche cerrada, 1 = pleno día (sube desde las 6 y baja hasta las 18)
		local dia = math.clamp(math.sin((hora - 6) / 12 * math.pi) * 1.6, 0, 1)
		Lighting.Ambient = AJUSTES.colorAmbiente:Lerp(COLOR_DIA, dia)
		Lighting.OutdoorAmbient = AJUSTES.colorAmbienteExterior:Lerp(COLOR_DIA_AIRE, dia)
		Lighting.Brightness = AJUSTES.brilloDeNoche + (AJUSTES.brilloDeDia - AJUSTES.brilloDeNoche) * dia
		task.wait(0.2)
	end
end)

-- ⭐ Estrellas fugaces: de noche, de vez en cuando, cruza una por el cielo delante de un jugador
local function lanzarEstrella()
	local jugadores = Players:GetPlayers()
	if #jugadores == 0 then
		return
	end
	local jugador = jugadores[math.random(1, #jugadores)]
	local raiz = jugador.Character and jugador.Character:FindFirstChild("HumanoidRootPart")
	if not raiz then
		return
	end

	local azar = Random.new()
	local inicio = raiz.Position + Vector3.new(azar:NextNumber(-250, 250), azar:NextNumber(220, 320), azar:NextNumber(150, 350))
	local fin = inicio + Vector3.new(azar:NextNumber(-300, 300), -azar:NextNumber(120, 200), azar:NextNumber(-100, 100))

	local estrella = Instance.new("Part")
	estrella.Name = "EstrellaFugaz"
	estrella.Shape = Enum.PartType.Ball
	estrella.Size = Vector3.new(4, 4, 4)
	estrella.Color = Color3.fromRGB(255, 255, 255)
	estrella.Material = Enum.Material.Neon
	estrella.Anchored = true
	estrella.CanCollide = false
	estrella.CanTouch = false
	estrella.CanQuery = false
	estrella.CastShadow = false
	estrella.Position = inicio

	local arriba = Instance.new("Attachment")
	arriba.Position = Vector3.new(0, 1.6, 0)
	arriba.Parent = estrella
	local abajo = Instance.new("Attachment")
	abajo.Position = Vector3.new(0, -1.6, 0)
	abajo.Parent = estrella
	local estela = Instance.new("Trail")
	estela.Attachment0 = arriba
	estela.Attachment1 = abajo
	estela.Lifetime = 1.4
	estela.LightEmission = 1
	estela.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255), Color3.fromRGB(120, 170, 255))
	estela.Transparency = NumberSequence.new(0, 1)
	estela.Parent = estrella

	estrella.Parent = workspace
	TweenService:Create(estrella, TweenInfo.new(2.5, Enum.EasingStyle.Linear), { Position = fin }):Play()
	Debris:AddItem(estrella, 3.5)
end

task.spawn(function()
	local azarEspera = Random.new()
	while true do
		task.wait(azarEspera:NextNumber(AJUSTES.segundosEntreEstrellas[1], AJUSTES.segundosEntreEstrellas[2]))
		if esDeNoche() then
			lanzarEstrella()
		end
	end
end)

print("🌙 Se va haciendo de noche...")
