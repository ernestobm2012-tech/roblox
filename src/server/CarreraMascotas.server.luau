--[[
	🐾🏁 CARRERA DE MASCOTAS EN EL JARDÍN
	Al lado del jardín de tu casa hay una pista con dos carriles. En cada carril corre una de TUS DOS
	mascotas (la de la derecha y la de la izquierda). Cuanto más NIVEL tiene una mascota, más rápido corre...
	¡pero también tiene suerte y a veces se despista!
	  - Acércate a una de las dos banderitas del principio y pulsa E para ANIMAR a esa mascota.
	  - Si gana la que animas, ¡ganas monedas! 🪙 (y si no, otra vez será)
	  - Solo el dueño de la casa puede empezar la carrera; las visitas la miran.
	Si solo llevas una mascota (o ninguna), el otro carril lo corre una mascota de la casa.

	📋 DÓNDE VA: en Roblox Studio, dentro de ServerScriptService, como "Script".
	(Usa la marca "CasaOrigen" del script Casas, los atributos "Equipo_mascota", "Equipo_mascota2"
	y "Mascota_xp_<id>" del script Mascotas, y el catálogo "CatalogoMascotas".)
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")

-- ⚙️ AJUSTES: ¡cambia estos valores y mira qué pasa!
local AJUSTES = {
	monedasSiGanaLaQueAnimas = 5,
	segundosEntreCarreras = 20,
	largoDeLaPista = 10.5, -- studs que hay que correr
	velocidadBase = 1.1, -- lo rápida que es una mascota de nivel 1
	velocidadPorNivel = 0.03, -- lo que corre más por cada nivel de la mascota
	divisorNivel = 8, -- igual que en el script Mascotas
	nivelMaximo = 30,
}

-- Dónde está la pista (medido desde el centro de tu casa, en la franja de césped de al lado)
local CARRILES_X = { -13.7, -16.3 }
local Z_SALIDA = -12.4

local carrerasEnMarcha = {} -- carrerasEnMarcha[indiceDeCasa] = true
local ultimaCarrera = {}

----------------------------------------------------------------------
-- 🧰 HERRAMIENTAS
----------------------------------------------------------------------

local function parte(carpeta, nombre, tamano, cf, color, material, forma)
	local pieza = Instance.new("Part")
	pieza.Name = nombre
	pieza.Size = tamano
	pieza.CFrame = cf
	pieza.Color = color
	pieza.Material = material or Enum.Material.SmoothPlastic
	pieza.Shape = forma or Enum.PartType.Block
	pieza.Anchored = true
	pieza.CanCollide = false
	pieza.CanQuery = false
	pieza.CastShadow = false
	pieza.Parent = carpeta
	return pieza
end

local function etiqueta(padre, texto, alto, color, desplazamiento)
	local cartel = Instance.new("BillboardGui")
	cartel.Size = UDim2.fromOffset(190, alto)
	cartel.StudsOffset = desplazamiento
	cartel.MaxDistance = 60
	cartel.AlwaysOnTop = true
	cartel.Parent = padre
	local texto_ = Instance.new("TextLabel")
	texto_.Size = UDim2.fromScale(1, 1)
	texto_.BackgroundTransparency = 1
	texto_.Text = texto
	texto_.TextScaled = true
	texto_.Font = Enum.Font.FredokaOne
	texto_.TextColor3 = color
	texto_.TextStrokeTransparency = 0
	texto_.Parent = cartel
	return texto_
end

local function nivelDeXP(xp)
	return math.min(AJUSTES.nivelMaximo, 1 + math.floor(math.sqrt(xp / AJUSTES.divisorNivel)))
end

local function buscarOrigen(indice)
	for _, marca in CollectionService:GetTagged("CasaOrigen") do
		if marca:GetAttribute("Indice") == indice then
			return marca
		end
	end
	return nil
end

local function duenoDe(indice)
	for _, jugador in Players:GetPlayers() do
		if jugador:GetAttribute("CasaNumero") == indice then
			return jugador
		end
	end
	return nil
end

local function avisar(jugador, texto, color)
	local pantallaJugador = jugador:FindFirstChild("PlayerGui")
	if not pantallaJugador then
		return
	end
	local viejo = pantallaJugador:FindFirstChild("AvisoCarreraMascotas")
	if viejo then
		viejo:Destroy()
	end
	local pantalla = Instance.new("ScreenGui")
	pantalla.Name = "AvisoCarreraMascotas"
	pantalla.ResetOnSpawn = false
	pantalla.Parent = pantallaJugador
	local mensaje = Instance.new("TextLabel")
	mensaje.Size = UDim2.fromScale(0.6, 0.09)
	mensaje.Position = UDim2.fromScale(0.5, 0.25)
	mensaje.AnchorPoint = Vector2.new(0.5, 0.5)
	mensaje.BackgroundColor3 = color
	mensaje.BackgroundTransparency = 0.1
	mensaje.TextColor3 = Color3.fromRGB(255, 255, 255)
	mensaje.TextScaled = true
	mensaje.Font = Enum.Font.FredokaOne
	mensaje.Text = texto
	mensaje.Parent = pantalla
	local esquinas = Instance.new("UICorner")
	esquinas.CornerRadius = UDim.new(0, 14)
	esquinas.Parent = mensaje
	task.delay(4, function()
		pantalla:Destroy()
	end)
end

----------------------------------------------------------------------
-- 🐾 EL CORREDOR (un animalito sencillo del color de tu mascota)
----------------------------------------------------------------------

-- Devuelve: nombre, color, nivel de la mascota que va en ese hueco ("Equipo_mascota" o "Equipo_mascota2")
local function datosDeLaMascota(dueno, atributo, porDefecto)
	local id = dueno and dueno:GetAttribute(atributo)
	if type(id) == "string" and id ~= "" then
		local catalogo = ReplicatedStorage:FindFirstChild("CatalogoMascotas")
		local ficha = catalogo and catalogo:FindFirstChild(id)
		if ficha then
			local nivel = nivelDeXP(dueno:GetAttribute("Mascota_xp_" .. id) or 0)
			return ficha:GetAttribute("Nombre"), ficha:GetAttribute("Color"), nivel
		end
	end
	return porDefecto, Color3.fromRGB(160, 150, 140), 1
end

local function crearCorredor(carpeta, cf, nombre, color, nivel)
	local modelo = Instance.new("Model")
	modelo.Name = "Corredor"
	local cuerpo = parte(modelo, "Cuerpo", Vector3.new(1.4, 1.2, 1.7), cf * CFrame.new(0, 0.9, 0), color, Enum.Material.SmoothPlastic, Enum.PartType.Ball)
	parte(modelo, "Cabeza", Vector3.new(0.95, 0.95, 0.95), cf * CFrame.new(0, 1.35, -0.85), color, Enum.Material.SmoothPlastic, Enum.PartType.Ball)
	parte(modelo, "Oreja", Vector3.new(0.3, 0.55, 0.2), cf * CFrame.new(-0.3, 1.95, -0.8), color)
	parte(modelo, "Oreja", Vector3.new(0.3, 0.55, 0.2), cf * CFrame.new(0.3, 1.95, -0.8), color)
	parte(modelo, "Ojo", Vector3.new(0.18, 0.18, 0.1), cf * CFrame.new(-0.22, 1.45, -1.3), Color3.fromRGB(20, 20, 20))
	parte(modelo, "Ojo", Vector3.new(0.18, 0.18, 0.1), cf * CFrame.new(0.22, 1.45, -1.3), Color3.fromRGB(20, 20, 20))
	parte(modelo, "Cola", Vector3.new(0.4, 0.4, 0.4), cf * CFrame.new(0, 1, 1), Color3.fromRGB(255, 255, 255), Enum.Material.SmoothPlastic, Enum.PartType.Ball)
	modelo.PrimaryPart = cuerpo
	modelo.Parent = carpeta
	etiqueta(cuerpo, nombre .. " (nivel " .. nivel .. ")", 26, Color3.fromRGB(255, 255, 255), Vector3.new(0, 2.6, 0))
	return modelo
end

----------------------------------------------------------------------
-- 🏁 LA CARRERA
----------------------------------------------------------------------

local function correr(indice, origen, carpeta, animadoPor, elegido)
	carrerasEnMarcha[indice] = true
	ultimaCarrera[indice] = os.clock()

	local dueno = duenoDe(indice)
	local nombres, colores, niveles = {}, {}, {}
	nombres[1], colores[1], niveles[1] = datosDeLaMascota(dueno, "Equipo_mascota", "Mascota de la casa")
	nombres[2], colores[2], niveles[2] = datosDeLaMascota(dueno, "Equipo_mascota2", "Mascota rival")

	local corredoresViejos = carpeta:FindFirstChild("Corredores")
	if corredoresViejos then
		corredoresViejos:Destroy()
	end
	local corredores = Instance.new("Folder")
	corredores.Name = "Corredores"
	corredores.Parent = carpeta

	local inicio = {}
	local modelos = {}
	local velocidad = {}
	local fase = {}
	local recorrido = { 0, 0 }
	local azar = Random.new()
	for i = 1, 2 do
		inicio[i] = origen.CFrame * CFrame.new(CARRILES_X[i], 0.2, Z_SALIDA - 0.8) * CFrame.Angles(0, 0, 0)
		modelos[i] = crearCorredor(corredores, inicio[i], nombres[i], colores[i], niveles[i])
		velocidad[i] = AJUSTES.velocidadBase + niveles[i] * AJUSTES.velocidadPorNivel
		fase[i] = azar:NextNumber(0, 6)
	end

	-- 3, 2, 1... ¡YA!
	local cartel = carpeta:FindFirstChild("MarcadorCarrera")
	local marcador = cartel and cartel:FindFirstChildOfClass("BillboardGui")
	local texto = marcador and marcador:FindFirstChildOfClass("TextLabel")
	if texto then
		for _, numero in { "3", "2", "1" } do
			texto.Text = numero
			task.wait(0.8)
		end
		texto.Text = "¡YA! 🏁"
	end

	local ganador
	local tiempo = 0
	local conexion
	conexion = RunService.Heartbeat:Connect(function(dt)
		tiempo += dt
		for i = 1, 2 do
			if not ganador then
				-- a veces corre más y a veces menos (¡los despistes pasan!)
				local empuje = 1 + 0.45 * math.sin(tiempo * 3.1 + fase[i]) + 0.25 * math.sin(tiempo * 7.3 + fase[i] * 2)
				recorrido[i] += velocidad[i] * math.max(empuje, 0.15) * dt
				local salto = math.abs(math.sin(tiempo * 9 + fase[i])) * 0.25
				modelos[i]:PivotTo(inicio[i] * CFrame.new(0, salto, -recorrido[i]))
				if recorrido[i] >= AJUSTES.largoDeLaPista then
					ganador = i
				end
			end
		end
	end)
	while not ganador and tiempo < 40 do
		task.wait(0.1)
	end
	conexion:Disconnect()
	ganador = ganador or 1

	if texto then
		texto.Text = "🏆 ¡Gana " .. nombres[ganador] .. "!"
	end
	if dueno then
		dueno:SetAttribute("Estad_carrerasMascotas", (dueno:GetAttribute("Estad_carrerasMascotas") or 0) + 1)
	end
	if animadoPor and animadoPor.Parent then
		if ganador == elegido then
			local marcadorMonedas = animadoPor:FindFirstChild("leaderstats")
			local monedas = marcadorMonedas and marcadorMonedas:FindFirstChild("Monedas")
			if monedas then
				monedas.Value += AJUSTES.monedasSiGanaLaQueAnimas
			end
			avisar(animadoPor, "🎉 ¡Ganó " .. nombres[ganador] .. "! +" .. AJUSTES.monedasSiGanaLaQueAnimas .. " 🪙", Color3.fromRGB(60, 150, 90))
		else
			avisar(animadoPor, "Ganó " .. nombres[ganador] .. ". ¡Otra vez será! 💪", Color3.fromRGB(100, 100, 150))
		end
	end

	task.wait(5)
	if corredores.Parent then
		corredores:Destroy()
	end
	if texto then
		texto.Text = "🐾 Carrera de mascotas"
	end
	carrerasEnMarcha[indice] = nil
end

----------------------------------------------------------------------
-- 🏗️ LA PISTA DE CADA CASA
----------------------------------------------------------------------

local function construirPista(origen)
	local indice = origen:GetAttribute("Indice")
	local carpeta = Instance.new("Folder")
	carpeta.Name = "PistaMascotas"
	carpeta.Parent = origen.Parent

	local base = origen.CFrame
	local largo = AJUSTES.largoDeLaPista + 1.6
	local centroZ = Z_SALIDA - largo / 2
	parte(carpeta, "Suelo", Vector3.new(6, 0.15, largo + 1), base * CFrame.new(-15, 0.1, centroZ), Color3.fromRGB(150, 110, 70), Enum.Material.Ground)
	for i = 1, 2 do
		parte(carpeta, "Carril", Vector3.new(2.2, 0.1, largo), base * CFrame.new(CARRILES_X[i], 0.22, centroZ), if i == 1 then Color3.fromRGB(235, 120, 90) else Color3.fromRGB(90, 150, 235))
	end
	-- La línea de meta de cuadros blancos y negros
	local zMeta = Z_SALIDA - 0.8 - AJUSTES.largoDeLaPista - 0.6
	for c = 0, 7 do
		parte(carpeta, "Cuadro", Vector3.new(0.7, 0.12, 0.7), base * CFrame.new(-12.9 - c * 0.5, 0.3, zMeta), if c % 2 == 0 then Color3.fromRGB(250, 250, 250) else Color3.fromRGB(30, 30, 30))
	end

	-- El marcador (números de la cuenta atrás y quién gana)
	local poste = parte(carpeta, "MarcadorCarrera", Vector3.new(0.4, 2.6, 0.4), base * CFrame.new(-18.5, 1.4, Z_SALIDA - 3), Color3.fromRGB(80, 60, 50), Enum.Material.Wood)
	etiqueta(poste, "🐾 Carrera de mascotas", 40, Color3.fromRGB(255, 230, 120), Vector3.new(2.5, 2.2, 0))

	-- Dos banderitas para animar a cada mascota (con la tecla E, solo el dueño)
	for i = 1, 2 do
		local bandera = parte(carpeta, "Bandera" .. i, Vector3.new(0.3, 2.2, 0.3), base * CFrame.new(CARRILES_X[i] + (if i == 1 then 1.5 else -1.5), 1.2, Z_SALIDA + 0.3), Color3.fromRGB(240, 240, 240), Enum.Material.Wood)
		parte(carpeta, "Tela", Vector3.new(0.1, 0.9, 1.2), base * CFrame.new(CARRILES_X[i] + (if i == 1 then 1.5 else -1.5), 2.0, Z_SALIDA + 0.9), if i == 1 then Color3.fromRGB(235, 120, 90) else Color3.fromRGB(90, 150, 235))
		local aviso = Instance.new("ProximityPrompt")
		aviso.ActionText = "Animar al carril " .. i
		aviso.ObjectText = "Carrera de mascotas"
		aviso.HoldDuration = 0
		aviso.MaxActivationDistance = 8
		aviso.RequiresLineOfSight = false
		aviso.Parent = bandera
		aviso.Triggered:Connect(function(jugador)
			if jugador:GetAttribute("CasaNumero") ~= indice then
				avisar(jugador, "Solo el dueño de la casa empieza la carrera 🏠", Color3.fromRGB(200, 60, 60))
				return
			end
			if carrerasEnMarcha[indice] then
				return
			end
			if ultimaCarrera[indice] and os.clock() - ultimaCarrera[indice] < AJUSTES.segundosEntreCarreras then
				avisar(jugador, "Las mascotas están descansando 😴 Espera un poquito", Color3.fromRGB(200, 120, 40))
				return
			end
			task.spawn(correr, indice, origen, carpeta, jugador, i)
		end)
	end
end

local function preparar(origen)
	if origen:GetAttribute("Indice") and not origen.Parent:FindFirstChild("PistaMascotas") then
		construirPista(origen)
	end
end

for _, origen in CollectionService:GetTagged("CasaOrigen") do
	preparar(origen)
end
CollectionService:GetInstanceAddedSignal("CasaOrigen"):Connect(function(origen)
	task.defer(preparar, origen)
end)

print("🐾 Carrera de mascotas lista.")
