--[[
	⛈️ TORMENTAS (de adorno)
	En los niveles con tormenta (los pone el script Niveles: 50, 100, 150... y se ven en el cartel del
	checkpoint) empieza a LLOVER, el cielo se oscurece y de vez en cuando cae un RAYO con un
	destello y un temblor de trueno. Es solo un adorno: no hace daño ni cambia los saltos.

	Todo se ve solo en tu pantalla (así no pesa nada y cada jugador ve su tormenta).

	📋 DÓNDE VA: en Roblox Studio, dentro de StarterPlayer > StarterPlayerScripts,
	como "LocalScript".
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local Debris = game:GetService("Debris")

local jugador = Players.LocalPlayer

-- ⚙️ AJUSTES: ¡cambia estos valores y mira qué pasa!
local AJUSTES = {
	gotasPorSegundo = 500, -- cuánta lluvia cae
	oscuridad = -0.18, -- lo oscuro que se pone el cielo en la tormenta (0 = nada)
	segundosEntreRayos = { 3, 8 }, -- cada cuánto cae un rayo (mínimo, máximo)
}

local camara = workspace.CurrentCamera
local tormentaActiva = false

----------------------------------------------------------------------
-- 🌧️ LA LLUVIA Y EL CIELO OSCURO
----------------------------------------------------------------------

-- Un efecto de color para oscurecer y para los destellos de los rayos (solo en tu pantalla)
local efecto = Instance.new("ColorCorrectionEffect")
efecto.Name = "TormentaEfecto"
efecto.Parent = Lighting

-- La lluvia sale de una "nube" invisible que va encima de tu cámara
local nube = Instance.new("Part")
nube.Name = "NubeDeLluvia"
nube.Size = Vector3.new(90, 1, 90)
nube.Transparency = 1
nube.Anchored = true
nube.CanCollide = false
nube.CanTouch = false
nube.CanQuery = false
nube.Parent = workspace

local gotas = Instance.new("ParticleEmitter")
gotas.Enabled = false
gotas.Rate = AJUSTES.gotasPorSegundo
gotas.Lifetime = NumberRange.new(1.2, 1.6)
gotas.Speed = NumberRange.new(70, 90)
gotas.EmissionDirection = Enum.NormalId.Bottom
gotas.Acceleration = Vector3.new(0, -40, 0)
gotas.Orientation = Enum.ParticleOrientation.VelocityParallel
gotas.Size = NumberSequence.new(0.3)
gotas.Transparency = NumberSequence.new(0.3, 0.8)
gotas.LightEmission = 0.3
gotas.Color = ColorSequence.new(Color3.fromRGB(170, 200, 255))
gotas.Parent = nube

RunService.RenderStepped:Connect(function()
	nube.Position = camara.CFrame.Position + Vector3.new(0, 35, 0)
end)

local function actualizar()
	local hayTormenta = jugador:GetAttribute("Clima") == "tormenta"
	if hayTormenta == tormentaActiva then
		return
	end
	tormentaActiva = hayTormenta
	gotas.Enabled = hayTormenta
	TweenService:Create(efecto, TweenInfo.new(2), {
		Brightness = if hayTormenta then AJUSTES.oscuridad else 0,
		Saturation = if hayTormenta then -0.35 else 0,
	}):Play()
end

jugador:GetAttributeChangedSignal("Clima"):Connect(actualizar)
actualizar()

----------------------------------------------------------------------
-- ⚡ LOS RAYOS
----------------------------------------------------------------------

local function lanzarRayo(azar)
	local origen = camara.CFrame.Position

	-- Un sitio delante de ti, un poco hacia un lado
	local adelante = Vector3.new(camara.CFrame.LookVector.X, 0, camara.CFrame.LookVector.Z)
	if adelante.Magnitude < 0.1 then
		adelante = Vector3.new(0, 0, 1)
	end
	local direccion = CFrame.Angles(0, math.rad(azar:NextNumber(-55, 55)), 0):VectorToWorldSpace(adelante.Unit)
	local distancia = azar:NextNumber(120, 260)
	local abajo = origen + direccion * distancia - Vector3.new(0, 40, 0)
	local arriba = abajo + Vector3.new(0, 300, 0)

	-- El rayo: un zigzag de palitos brillantes de arriba a abajo
	local lado = direccion:Cross(Vector3.yAxis).Unit
	local puntos = { arriba }
	local trozos = 8
	for i = 1, trozos - 1 do
		local punto = arriba:Lerp(abajo, i / trozos) + lado * azar:NextNumber(-14, 14)
		table.insert(puntos, punto)
	end
	table.insert(puntos, abajo)

	for i = 1, #puntos - 1 do
		local desde, hasta = puntos[i], puntos[i + 1]
		local largo = (hasta - desde).Magnitude
		local palito = Instance.new("Part")
		palito.Name = "Rayo"
		palito.Size = Vector3.new(2.5, 2.5, largo)
		palito.CFrame = CFrame.lookAt(desde, hasta) * CFrame.new(0, 0, -largo / 2)
		palito.Color = Color3.fromRGB(235, 240, 255)
		palito.Material = Enum.Material.Neon
		palito.Anchored = true
		palito.CanCollide = false
		palito.CanTouch = false
		palito.CanQuery = false
		palito.CastShadow = false
		palito.Parent = workspace
		Debris:AddItem(palito, 0.25)
	end

	-- El destello: la pantalla se ilumina un momento
	efecto.Brightness = 0.45
	TweenService:Create(efecto, TweenInfo.new(0.35), { Brightness = AJUSTES.oscuridad }):Play()

	-- El trueno llega un poco después: la cámara tiembla
	task.delay(distancia / 250, function()
		local personaje = jugador.Character
		local humanoide = personaje and personaje:FindFirstChildOfClass("Humanoid")
		if not humanoide then
			return
		end
		for _ = 1, 8 do
			humanoide.CameraOffset = Vector3.new(azar:NextNumber(-0.2, 0.2), azar:NextNumber(-0.2, 0.2), 0)
			task.wait(0.04)
		end
		humanoide.CameraOffset = Vector3.zero
	end)
end

task.spawn(function()
	local azar = Random.new()
	while true do
		task.wait(azar:NextNumber(AJUSTES.segundosEntreRayos[1], AJUSTES.segundosEntreRayos[2]))
		if tormentaActiva then
			lanzarRayo(azar)
		end
	end
end)
