--[[
	⛵ BARCOS PARA NAVEGAR POR EL MAR
	En la orilla de la playa hay 3 barcos de vela esperándote. Para subir, métete en el agua y
	CAMÍNA HACIA EL ASIENTO del barco (¡te sientas solo!). Para navegar:
	  W / ↑ = avanzar · S / ↓ = frenar y marcha atrás · A / ← = girar a la izquierda · D / → = girar a la derecha
	Salta para bajar. Si dejas un barco solo un ratito, ¡vuelve él solo a la orilla!
	Los barcos no se pueden salir del mar y esquivan el barco pirata y la cueva.

	📋 DÓNDE VA: en Roblox Studio, dentro de ServerScriptService, como "Script".
	(Va con el script Playa: usa el mismo mar. No necesita nada más.)
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

-- ⚙️ AJUSTES: ¡cambia estos valores y mira qué pasa!
local AJUSTES = {
	velocidadMaxima = 30, -- studs por segundo hacia delante
	velocidadMarchaAtras = 10,
	giro = 1.2, -- lo rápido que gira el barco
	segundosParaVolver = 45, -- si nadie lo usa, vuelve a la orilla
	alturaDelAgua = 5.75, -- tiene que coincidir con el agua del script Playa (0.25 + 5.5)
}

-- Dónde se puede navegar (el mar del script Playa) y qué zonas hay que esquivar (x1, x2, z1, z2)
local MAR = { xMin = -138, xMax = 138, zMin = -342, zMax = -233 }
local ZONAS_PROHIBIDAS = {
	{ -99, -81, -284, -222 }, -- el barco pirata y su rampa
	{ 76, 119, -354, -314 }, -- la cueva submarina
}

local carpeta = Instance.new("Folder")
carpeta.Name = "Barcos"
carpeta.Parent = workspace

local function parte(padre, nombre, tamano, cf, color, material, forma)
	local p = Instance.new("Part")
	p.Name = nombre
	p.Size = tamano
	p.CFrame = cf
	p.Color = color
	p.Material = material or Enum.Material.SmoothPlastic
	p.Shape = forma or Enum.PartType.Block
	p.Anchored = true
	p.CanCollide = false
	p.CastShadow = false
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	p.Parent = padre
	return p
end

local MADERA = Color3.fromRGB(150, 100, 60)
local OSCURA = Color3.fromRGB(110, 70, 40)

-- Un barco de vela: mira hacia -Z (la proa). El asiento está en el medio.
local function construirBarco(colorVela)
	local m = Instance.new("Model")
	m.Name = "Barco"
	local ID = CFrame.new()
	local casco = parte(m, "Casco", Vector3.new(6, 1.2, 12), ID, MADERA, Enum.Material.Wood)
	parte(m, "Proa", Vector3.new(4.2, 1.2, 4.2), ID * CFrame.new(0, 0, -6.2) * CFrame.Angles(0, math.rad(45), 0), MADERA, Enum.Material.Wood)
	for _, lado in { -1, 1 } do
		parte(m, "Borda", Vector3.new(0.5, 1.6, 11), ID * CFrame.new(lado * 2.9, 1.2, 0.5), OSCURA, Enum.Material.Wood)
		parte(m, "BordaProa", Vector3.new(0.5, 1.6, 3.4), ID * CFrame.new(lado * 1.6, 1.2, -6.2) * CFrame.Angles(0, math.rad(-lado * 45), 0), OSCURA, Enum.Material.Wood)
	end
	parte(m, "Popa", Vector3.new(6, 1.6, 0.5), ID * CFrame.new(0, 1.2, 6.2), OSCURA, Enum.Material.Wood)
	parte(m, "Mastil", Vector3.new(0.45, 10, 0.45), ID * CFrame.new(0, 6, -2), OSCURA, Enum.Material.Wood)
	parte(m, "Vela", Vector3.new(0.2, 6.5, 5), ID * CFrame.new(0, 7, -0.2), colorVela, Enum.Material.Fabric)
	parte(m, "Bandera", Vector3.new(0.1, 1.2, 1.8), ID * CFrame.new(0, 11.4, -1), Color3.fromRGB(230, 60, 60), Enum.Material.Fabric)
	-- El asiento (un asiento de vehículo: lo mueve este script, no la física)
	local asiento = Instance.new("VehicleSeat")
	asiento.Name = "Timon"
	asiento.Size = Vector3.new(2.4, 1, 2.4)
	asiento.CFrame = ID * CFrame.new(0, 0.6, 2.6)
	asiento.Color = Color3.fromRGB(80, 60, 45)
	asiento.MaxSpeed = 0 -- la velocidad la ponemos nosotros
	asiento.Torque = 0
	asiento.Anchored = true
	asiento.CanCollide = true
	asiento.Parent = m
	m.PrimaryPart = casco
	return m, asiento
end

local barcos = {}
local COLORES_VELA = { Color3.fromRGB(250, 250, 250), Color3.fromRGB(255, 205, 70), Color3.fromRGB(120, 190, 255) }

for i = 1, 3 do
	local x = -40 + (i - 1) * 40
	local modelo, asiento = construirBarco(COLORES_VELA[i])
	local barco = {
		modelo = modelo, asiento = asiento, casa = Vector3.new(x, 0, -239), yaw = 0, pos = Vector3.new(x, 0, -239),
		velocidad = 0, t = i * 2, vacioDesde = nil,
	}
	modelo.Parent = carpeta
	table.insert(barcos, barco)
end

-- Un cartel en la orilla
local poste = parte(carpeta, "PosteBarcos", Vector3.new(0.5, 5, 0.5), CFrame.new(55, 2.5, -226), Color3.fromRGB(110, 80, 50), Enum.Material.Wood)
poste.CanCollide = true
local gui = Instance.new("BillboardGui")
gui.Size = UDim2.fromOffset(420, 70)
gui.StudsOffset = Vector3.new(0, 4, 0)
gui.AlwaysOnTop = true
gui.MaxDistance = 140
gui.Parent = poste
local etiqueta = Instance.new("TextLabel")
etiqueta.Size = UDim2.fromScale(1, 1)
etiqueta.BackgroundTransparency = 1
etiqueta.Text = "⛵ ¡Barcos! Camina hasta el asiento. W A S D para navegar"
etiqueta.TextScaled = true
etiqueta.Font = Enum.Font.FredokaOne
etiqueta.TextColor3 = Color3.fromRGB(255, 255, 255)
etiqueta.TextStrokeTransparency = 0
etiqueta.Parent = gui

local function colocar(barco)
	local bamboleo = CFrame.Angles(math.sin(barco.t * 1.1) * 0.02, 0, math.sin(barco.t * 0.9) * 0.03)
	barco.modelo:PivotTo(CFrame.new(barco.pos.X, AJUSTES.alturaDelAgua - 0.9 + math.sin(barco.t * 1.5) * 0.12, barco.pos.Z) * CFrame.Angles(0, barco.yaw, 0) * bamboleo)
end

for _, barco in barcos do
	colocar(barco)
end

local function enZonaProhibida(pos)
	for _, z in ZONAS_PROHIBIDAS do
		if pos.X > z[1] and pos.X < z[2] and pos.Z > z[3] and pos.Z < z[4] then
			return true
		end
	end
	return false
end

RunService.Heartbeat:Connect(function(dt)
	for _, barco in barcos do
		barco.t += dt
		local asiento = barco.asiento
		local ocupante = asiento.Occupant
		if ocupante then
			barco.vacioDesde = nil
			local acelerador = asiento.ThrottleFloat
			local giro = asiento.SteerFloat
			local objetivo = if acelerador >= 0 then acelerador * AJUSTES.velocidadMaxima else acelerador * AJUSTES.velocidadMarchaAtras
			barco.velocidad += (objetivo - barco.velocidad) * math.min(1, dt * 1.4)
			-- el barco gira más cuando va rápido (y a la derecha es un ángulo negativo)
			local fuerzaGiro = AJUSTES.giro * (0.3 + math.min(1, math.abs(barco.velocidad) / 20))
			barco.yaw -= giro * fuerzaGiro * dt * (if barco.velocidad >= -0.5 then 1 else -1)

			local adelante = CFrame.Angles(0, barco.yaw, 0).LookVector -- la proa mira a -Z
			local nueva = barco.pos + adelante * barco.velocidad * dt
			local dentro = math.clamp(nueva.X, MAR.xMin, MAR.xMax) == nueva.X and math.clamp(nueva.Z, MAR.zMin, MAR.zMax) == nueva.Z
			if dentro and not enZonaProhibida(nueva) then
				barco.pos = nueva
			else
				barco.velocidad *= 0.5 -- ¡toc! el barco choca suavemente y frena
			end
			colocar(barco)
		else
			-- sin nadie: se mece, y si lleva mucho rato solo, vuelve a la orilla
			barco.velocidad = 0
			barco.vacioDesde = barco.vacioDesde or os.clock()
			if os.clock() - barco.vacioDesde > AJUSTES.segundosParaVolver and (barco.pos - barco.casa).Magnitude > 1 then
				barco.pos = barco.casa
				barco.yaw = 0
			end
			colocar(barco)
		end
	end
end)

print("⛵ Barcos listos.")
