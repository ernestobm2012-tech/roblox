--[[
	🗺️ EL MAPA DEL PARKOUR
	Un botón "🗺️ Mapa" abre un mapa en la pantalla con:
	  - 🟡 TU nivel (la flecha amarilla)
	  - 📍 Los checkpoints (un puntito cada 10 niveles: verde = ya pasaste, gris = te faltan)
	  - 🧑‍🤝‍🧑 Hasta dónde han llegado TUS AMIGOS de Roblox que están jugando ahora (círculos de colores con su nombre)
	  - 🏁 La meta, arriba del todo

	Sale de lo que ya existe: el atributo "Nivel" de cada jugador y los "Checkpoint_<n>" del mundo.
	Ojo: solo salen los amigos que están en este mismo mundo ahora mismo.

	📋 DÓNDE VA: en Roblox Studio, dentro de StarterPlayer > StarterPlayerScripts,
	como "LocalScript".
]]

local Players = game:GetService("Players")

local jugador = Players.LocalPlayer

-- ⚙️ AJUSTES: ¡cambia estos valores y mira qué pasa!
local AJUSTES = {
	nivelesPorPunto = 10, -- un punto de checkpoint cada tantos niveles
	nivelesPorNumero = 50, -- un número escrito cada tantos niveles
	segundosEntreActualizaciones = 1,
	alturaDelMapa = 340, -- píxeles de alto del camino
	colorTu = Color3.fromRGB(255, 215, 40),
	coloresAmigos = {
		Color3.fromRGB(80, 200, 255), Color3.fromRGB(255, 120, 190), Color3.fromRGB(120, 230, 120),
		Color3.fromRGB(255, 150, 60), Color3.fromRGB(190, 140, 255), Color3.fromRGB(255, 100, 100),
	},
}

local pantalla = Instance.new("ScreenGui")
pantalla.Name = "MapaParkour"
pantalla.ResetOnSpawn = false
pantalla.Parent = jugador:WaitForChild("PlayerGui")

local boton = Instance.new("TextButton")
boton.Size = UDim2.fromOffset(150, 48)
boton.Position = UDim2.new(0, 12, 0.3, 432)
boton.BackgroundColor3 = Color3.fromRGB(40, 120, 90)
boton.TextColor3 = Color3.fromRGB(255, 255, 255)
boton.TextScaled = true
boton.Font = Enum.Font.FredokaOne
boton.Text = "🗺️ Mapa"
boton.Parent = pantalla
Instance.new("UICorner", boton).CornerRadius = UDim.new(0, 12)

local panel = Instance.new("Frame")
panel.Size = UDim2.fromOffset(330, 470)
panel.Position = UDim2.fromScale(0.5, 0.5)
panel.AnchorPoint = Vector2.new(0.5, 0.5)
panel.BackgroundColor3 = Color3.fromRGB(25, 45, 40)
panel.BackgroundTransparency = 0.05
panel.Visible = false
panel.Parent = pantalla
Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 16)

local titulo = Instance.new("TextLabel")
titulo.Size = UDim2.new(1, -60, 0, 36)
titulo.Position = UDim2.fromOffset(12, 6)
titulo.BackgroundTransparency = 1
titulo.TextColor3 = Color3.fromRGB(255, 255, 255)
titulo.TextScaled = true
titulo.Font = Enum.Font.FredokaOne
titulo.TextXAlignment = Enum.TextXAlignment.Left
titulo.Text = "🗺️ Mapa del parkour"
titulo.Parent = panel

local cerrar = Instance.new("TextButton")
cerrar.Size = UDim2.fromOffset(36, 36)
cerrar.Position = UDim2.new(1, -44, 0, 6)
cerrar.BackgroundColor3 = Color3.fromRGB(180, 60, 60)
cerrar.TextColor3 = Color3.fromRGB(255, 255, 255)
cerrar.TextScaled = true
cerrar.Font = Enum.Font.FredokaOne
cerrar.Text = "X"
cerrar.Parent = panel
Instance.new("UICorner", cerrar).CornerRadius = UDim.new(0, 10)

local camino = Instance.new("Frame")
camino.Size = UDim2.fromOffset(110, AJUSTES.alturaDelMapa)
camino.Position = UDim2.fromOffset(110, 60)
camino.BackgroundTransparency = 1
camino.Parent = panel

local linea = Instance.new("Frame")
linea.Size = UDim2.new(0, 6, 1, 0)
linea.Position = UDim2.fromScale(0.5, 0)
linea.AnchorPoint = Vector2.new(0.5, 0)
linea.BackgroundColor3 = Color3.fromRGB(110, 90, 60)
linea.BorderSizePixel = 0
linea.Parent = camino

local pie = Instance.new("TextLabel")
pie.Size = UDim2.new(1, -24, 0, 50)
pie.Position = UDim2.new(0, 12, 1, -56)
pie.BackgroundTransparency = 1
pie.TextColor3 = Color3.fromRGB(215, 235, 225)
pie.TextScaled = true
pie.Font = Enum.Font.GothamMedium
pie.Text = ""
pie.Parent = panel

local puntos = {} -- puntos[nivel] = el puntito
local totalNiveles = 0
local marcadores = {} -- marcadores[jugador] = { punto, texto }
local sonAmigos = {} -- sonAmigos[idDeUsuario] = true/false

-- El número de niveles lo sacamos de los Checkpoint_<n> que existan
local function contarNiveles()
	local mundo = workspace:FindFirstChild("MiMundo")
	local maximo = 0
	if mundo then
		for _, hijo in mundo:GetChildren() do
			local numero = tonumber(string.match(hijo.Name, "^Checkpoint_(%d+)$"))
			if numero and numero > maximo then
				maximo = numero
			end
		end
	end
	return maximo
end

-- Altura (0 = abajo, 1 = arriba) de un nivel en el camino
local function alturaDe(nivel)
	if totalNiveles <= 1 then
		return 0
	end
	return math.clamp((nivel - 1) / (totalNiveles - 1), 0, 1)
end

local function yDe(nivel)
	return (1 - alturaDe(nivel)) * (AJUSTES.alturaDelMapa - 14)
end

local function dibujarCamino()
	for _, p in puntos do
		p:Destroy()
	end
	puntos = {}
	for _, hijo in camino:GetChildren() do
		if hijo:IsA("TextLabel") then
			hijo:Destroy()
		end
	end
	for nivel = 1, totalNiveles, AJUSTES.nivelesPorPunto do
		local punto = Instance.new("Frame")
		punto.Size = UDim2.fromOffset(10, 10)
		punto.Position = UDim2.new(0.5, 0, 0, yDe(nivel))
		punto.AnchorPoint = Vector2.new(0.5, 0)
		punto.BackgroundColor3 = Color3.fromRGB(120, 120, 120)
		punto.BorderSizePixel = 0
		punto.Parent = camino
		Instance.new("UICorner", punto).CornerRadius = UDim.new(1, 0)
		puntos[nivel] = punto
	end
	for nivel = AJUSTES.nivelesPorNumero, totalNiveles, AJUSTES.nivelesPorNumero do
		local numero = Instance.new("TextLabel")
		numero.Size = UDim2.fromOffset(40, 14)
		numero.Position = UDim2.new(0.5, 10, 0, yDe(nivel) - 2)
		numero.BackgroundTransparency = 1
		numero.TextColor3 = Color3.fromRGB(200, 215, 210)
		numero.TextScaled = true
		numero.Font = Enum.Font.GothamBold
		numero.TextXAlignment = Enum.TextXAlignment.Left
		numero.Text = tostring(nivel)
		numero.Parent = camino
	end
	local meta = Instance.new("TextLabel")
	meta.Size = UDim2.fromOffset(70, 18)
	meta.Position = UDim2.new(0.5, 10, 0, -22)
	meta.BackgroundTransparency = 1
	meta.TextColor3 = Color3.fromRGB(255, 230, 120)
	meta.TextScaled = true
	meta.Font = Enum.Font.FredokaOne
	meta.TextXAlignment = Enum.TextXAlignment.Left
	meta.Text = "🏁 Meta"
	meta.Parent = camino
end

-- ¿Es amigo? Se pregunta una vez a Roblox y se recuerda
local function esAmigo(otro)
	if otro == jugador then
		return false
	end
	local guardado = sonAmigos[otro.UserId]
	if guardado == nil then
		sonAmigos[otro.UserId] = false
		task.spawn(function()
			local bien, respuesta = pcall(function()
				return jugador:IsFriendsWith(otro.UserId)
			end)
			sonAmigos[otro.UserId] = bien and respuesta == true
		end)
		return false
	end
	return guardado
end

local function quitarMarcador(otro)
	local m = marcadores[otro]
	if m then
		m.punto:Destroy()
		m.texto:Destroy()
		marcadores[otro] = nil
	end
end

local function ponerMarcador(otro, nivel, color, lado, etiqueta)
	local m = marcadores[otro]
	if not m then
		local punto = Instance.new("Frame")
		punto.Size = UDim2.fromOffset(18, 18)
		punto.AnchorPoint = Vector2.new(0.5, 0)
		punto.BorderSizePixel = 0
		punto.ZIndex = 3
		punto.Parent = camino
		Instance.new("UICorner", punto).CornerRadius = UDim.new(1, 0)
		local texto = Instance.new("TextLabel")
		texto.Size = UDim2.fromOffset(105, 16)
		texto.BackgroundTransparency = 1
		texto.TextScaled = true
		texto.Font = Enum.Font.GothamBold
		texto.ZIndex = 3
		texto.Parent = camino
		m = { punto = punto, texto = texto }
		marcadores[otro] = m
	end
	local y = yDe(nivel)
	m.punto.Position = UDim2.new(0.5, 0, 0, y - 2)
	m.punto.BackgroundColor3 = color
	m.texto.TextColor3 = color
	m.texto.Text = etiqueta
	if lado < 0 then
		m.texto.TextXAlignment = Enum.TextXAlignment.Right
		m.texto.Position = UDim2.new(0.5, -126, 0, y - 1)
	else
		m.texto.TextXAlignment = Enum.TextXAlignment.Left
		m.texto.Position = UDim2.new(0.5, 24, 0, y - 1)
	end
end

local function actualizar()
	local nuevo = contarNiveles()
	if nuevo > 0 and nuevo ~= totalNiveles then
		totalNiveles = nuevo
		dibujarCamino()
	end
	if totalNiveles == 0 then
		pie.Text = "Cargando el mundo..."
		return
	end

	local miNivel = jugador:GetAttribute("Nivel") or 1
	for nivel, punto in puntos do
		punto.BackgroundColor3 = nivel <= miNivel and Color3.fromRGB(90, 220, 110) or Color3.fromRGB(120, 120, 120)
	end

	-- Tú, a la izquierda del camino
	ponerMarcador(jugador, miNivel, AJUSTES.colorTu, -1, "Tú · " .. miNivel)

	-- Los amigos que juegan ahora, a la derecha (o a la izquierda si ya hay uno cerca)
	local cuantos = 0
	local visto = { [jugador] = true }
	for _, otro in Players:GetPlayers() do
		if esAmigo(otro) then
			visto[otro] = true
			cuantos += 1
			local color = AJUSTES.coloresAmigos[(cuantos - 1) % #AJUSTES.coloresAmigos + 1]
			local nivel = otro:GetAttribute("Nivel") or 1
			-- cada amigo en un lado distinto para que los nombres no se pisen
			ponerMarcador(otro, nivel, color, cuantos % 2 == 0 and -1 or 1, otro.DisplayName .. " · " .. nivel)
		end
	end
	for otro in marcadores do
		if not visto[otro] then
			quitarMarcador(otro)
		end
	end

	if cuantos == 0 then
		pie.Text = "Niveles: " .. totalNiveles .. ". Aquí salen tus amigos de Roblox cuando juegan contigo 👋"
	else
		pie.Text = "Niveles: " .. totalNiveles .. " · Amigos jugando: " .. cuantos
	end
end

local function alternar(abierto)
	panel.Visible = abierto
	if abierto then
		actualizar()
	end
end

boton.Activated:Connect(function()
	alternar(not panel.Visible)
end)
cerrar.Activated:Connect(function()
	alternar(false)
end)

Players.PlayerRemoving:Connect(function(otro)
	quitarMarcador(otro)
end)

-- Mientras está abierto, se actualiza solo
task.spawn(function()
	while true do
		task.wait(AJUSTES.segundosEntreActualizaciones)
		if panel.Visible then
			actualizar()
		end
	end
end)
