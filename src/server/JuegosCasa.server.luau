--[[
	🎮 JUEGOS DE LA CASA
	Pone en marcha los muebles con juego que se compran en "🏠 Mi casa":
	  - 🎯 DIANA: pulsa E delante y lanzas un dardo. Cuanto más cerca del centro, ¡más puntos (hasta 50)!
	    En un cartel sale el récord de la diana.
	  - ⚽ PELOTA QUE BOTA: una pelota de verdad. Empújala corriendo o chocando contra ella y bota por la
	    casa. Si se escapa o se cae, vuelve sola a su sitio.
	  - 🍳 COCINA: pulsa E y cocinas (tarda 3 segundos). Sale comida de ADORNO sobre la cocina:
	    pizza, tarta, hamburguesa, donut, tortitas y galletas. ¡No se come, pero queda monísima!
	Pueden jugar el dueño y las visitas.

	📋 DÓNDE VA: en Roblox Studio, dentro de ServerScriptService, como "Script".
	(El script Casas construye los muebles y les pone una etiqueta: "JuegoDiana", "JuegoPelota" y
	"JuegoCocina". Este script busca esas etiquetas.)
]]

local Players = game:GetService("Players")
local CollectionService = game:GetService("CollectionService")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

-- ⚙️ AJUSTES: ¡cambia estos valores y mira qué pasa!
local AJUSTES = {
	esperaEntreDardos = 2, -- segundos entre un dardo y el siguiente
	segundosDeCocinar = 3, -- lo que tarda en hacerse la comida
	comidasEnLaCocina = 3, -- cuántas comidas caben a la vez sobre la cocina
	distanciaMaximaPelota = 16, -- si la pelota se aleja tanto de su sitio, vuelve
}

----------------------------------------------------------------------
-- 🧰 HERRAMIENTAS
----------------------------------------------------------------------

-- Enseña un mensajito en la pantalla de un jugador
local function avisar(jugador, texto, color)
	local pantallaJugador = jugador:FindFirstChild("PlayerGui")
	if not pantallaJugador then
		return
	end
	local viejo = pantallaJugador:FindFirstChild("AvisoJuego")
	if viejo then
		viejo:Destroy()
	end

	local pantalla = Instance.new("ScreenGui")
	pantalla.Name = "AvisoJuego"
	pantalla.ResetOnSpawn = false
	pantalla.Parent = pantallaJugador

	local mensaje = Instance.new("TextLabel")
	mensaje.Size = UDim2.fromScale(0.5, 0.09)
	mensaje.Position = UDim2.fromScale(0.5, 0.7)
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

	task.delay(2.5, function()
		if pantalla.Parent then
			local desaparecer = TweenService:Create(mensaje, TweenInfo.new(0.6), {
				TextTransparency = 1,
				BackgroundTransparency = 1,
			})
			desaparecer:Play()
			desaparecer.Completed:Wait()
			pantalla:Destroy()
		end
	end)
end

local function contar(jugador, nombre)
	jugador:SetAttribute(nombre, (jugador:GetAttribute(nombre) or 0) + 1)
end

local function crearBotonE(parte, accion, objeto, espera, distancia)
	local boton = Instance.new("ProximityPrompt")
	boton.ActionText = accion
	boton.ObjectText = objeto
	boton.HoldDuration = espera
	boton.MaxActivationDistance = distancia
	boton.RequiresLineOfSight = false
	boton.Parent = parte
	return boton
end

----------------------------------------------------------------------
-- 🎯 LA DIANA
----------------------------------------------------------------------

local RADIO_DIANA = 1.4 -- la diana mide 2.8 de ancho

local function prepararDiana(tablero)
	if tablero:FindFirstChildOfClass("ProximityPrompt") then
		return
	end
	local boton = crearBotonE(tablero, "Lanzar dardo", "🎯 Diana", 0, 14)

	-- El cartel con el récord, encima de la diana
	local cartel = Instance.new("BillboardGui")
	cartel.Size = UDim2.fromOffset(220, 46)
	cartel.StudsOffset = Vector3.new(0, 2.4, 0)
	cartel.MaxDistance = 60
	cartel.Parent = tablero
	local etiqueta = Instance.new("TextLabel")
	etiqueta.Size = UDim2.fromScale(1, 1)
	etiqueta.BackgroundTransparency = 1
	etiqueta.Text = "🎯 Récord: 0"
	etiqueta.TextScaled = true
	etiqueta.Font = Enum.Font.FredokaOne
	etiqueta.TextColor3 = Color3.fromRGB(255, 255, 255)
	etiqueta.TextStrokeTransparency = 0
	etiqueta.Parent = cartel

	local dardos = {} -- los dardos que están clavados ahora
	local record = 0
	local ultimoLanzamiento = {}
	local colores = { Color3.fromRGB(255, 80, 80), Color3.fromRGB(80, 200, 255), Color3.fromRGB(255, 220, 60), Color3.fromRGB(120, 255, 120) }

	boton.Triggered:Connect(function(jugador)
		local ahora = os.clock()
		if ahora - (ultimoLanzamiento[jugador] or -100) < AJUSTES.esperaEntreDardos then
			return
		end
		ultimoLanzamiento[jugador] = ahora
		local raiz = jugador.Character and jugador.Character:FindFirstChild("HumanoidRootPart")
		if not raiz then
			return
		end

		-- ¿Dónde cae el dardo? Más cerca del centro = más puntos (hasta 50)
		local distancia = (math.random() ^ 1.2) * RADIO_DIANA
		local angulo = math.random() * math.pi * 2
		local puntos = math.floor(50 * (1 - distancia / RADIO_DIANA) + 0.5)
		local impacto = (tablero.CFrame * CFrame.new(0.25, distancia * math.sin(angulo), distancia * math.cos(angulo))).Position

		-- El dardo vuela hasta la diana y se queda clavado un rato
		local inicio = raiz.Position + Vector3.new(0, 1, 0)
		local direccion = (impacto - inicio).Unit
		local dardo = Instance.new("Part")
		dardo.Name = "Dardo"
		dardo.Size = Vector3.new(0.12, 0.12, 1.2)
		dardo.Color = colores[math.random(#colores)]
		dardo.Material = Enum.Material.Neon
		dardo.Anchored = true
		dardo.CanCollide = false
		dardo.CanTouch = false
		dardo.CanQuery = false
		dardo.CFrame = CFrame.lookAt(inicio, impacto)
		dardo.Parent = tablero.Parent
		TweenService:Create(dardo, TweenInfo.new(0.35, Enum.EasingStyle.Linear), { CFrame = CFrame.lookAt(impacto - direccion * 0.6, impacto) }):Play()
		table.insert(dardos, dardo)
		if #dardos > 6 then
			table.remove(dardos, 1):Destroy()
		end
		Debris:AddItem(dardo, 8)

		contar(jugador, "Estad_dardos")
		task.delay(0.35, function()
			if puntos >= 45 then
				avisar(jugador, "🎯 ¡¡DIANA!! " .. puntos .. " puntos", Color3.fromRGB(190, 130, 0))
			else
				avisar(jugador, "🎯 " .. puntos .. " puntos", Color3.fromRGB(70, 100, 170))
			end
			if puntos > record then
				record = puntos
				etiqueta.Text = "🎯 Récord: " .. record .. " (" .. jugador.DisplayName .. ")"
			end
		end)
	end)
end

----------------------------------------------------------------------
-- ⚽ LA PELOTA QUE BOTA
----------------------------------------------------------------------

local pelotas = {} -- { parte, origen }

local function prepararPelota(parte)
	-- La simula el servidor (así no hay trampas ni cosas raras)
	pcall(function()
		parte:SetNetworkOwner(nil)
	end)
	table.insert(pelotas, { parte = parte, origen = parte.Position })
end

task.spawn(function()
	while true do
		task.wait(1)
		for i = #pelotas, 1, -1 do
			local pelota = pelotas[i]
			if not pelota.parte.Parent then
				table.remove(pelotas, i)
			else
				local lejos = (pelota.parte.Position - pelota.origen).Magnitude > AJUSTES.distanciaMaximaPelota
				if lejos or pelota.parte.Position.Y < pelota.origen.Y - 10 then
					pelota.parte.AssemblyLinearVelocity = Vector3.zero
					pelota.parte.AssemblyAngularVelocity = Vector3.zero
					pelota.parte.CFrame = CFrame.new(pelota.origen) -- ¡vuelve a su sitio!
				end
			end
		end
	end
end)

----------------------------------------------------------------------
-- 🍳 LA COCINA (comida de adorno)
----------------------------------------------------------------------

-- Un disco plano (el cilindro está "de pie" y lo tumbamos). "y" es la altura desde la base.
local function disco(modelo, base, grosor, diametro, y, color, x, z)
	local parte = Instance.new("Part")
	parte.Size = Vector3.new(grosor, diametro, diametro)
	parte.Shape = Enum.PartType.Cylinder
	parte.CFrame = base * CFrame.new(x or 0, y, z or 0) * CFrame.Angles(0, 0, math.rad(90))
	parte.Color = color
	parte.Anchored = true
	parte.CanCollide = false
	parte.CanTouch = false
	parte.CanQuery = false
	parte.CastShadow = false
	parte.Parent = modelo
	return parte
end

local function bola(modelo, base, tamano, y, color, x, z)
	local parte = Instance.new("Part")
	parte.Size = tamano
	parte.Shape = Enum.PartType.Ball
	parte.CFrame = base * CFrame.new(x or 0, y, z or 0)
	parte.Color = color
	parte.Anchored = true
	parte.CanCollide = false
	parte.CanTouch = false
	parte.CanQuery = false
	parte.CastShadow = false
	parte.Parent = modelo
	return parte
end

local RECETAS = {
	{
		nombre = "🍕 Pizza",
		construir = function(modelo, base)
			disco(modelo, base, 0.15, 1.2, 0.08, Color3.fromRGB(235, 190, 110))
			disco(modelo, base, 0.05, 1.0, 0.17, Color3.fromRGB(225, 70, 50))
			for _, sitio in { { -0.25, -0.2 }, { 0.25, -0.15 }, { 0, 0.3 }, { 0.3, 0.25 } } do
				bola(modelo, base, Vector3.new(0.22, 0.12, 0.22), 0.22, Color3.fromRGB(170, 40, 40), sitio[1], sitio[2])
			end
		end,
	},
	{
		nombre = "🍰 Tarta",
		construir = function(modelo, base)
			disco(modelo, base, 0.6, 1.1, 0.3, Color3.fromRGB(200, 140, 90))
			disco(modelo, base, 0.14, 1.05, 0.65, Color3.fromRGB(255, 240, 245))
			bola(modelo, base, Vector3.new(0.28, 0.28, 0.28), 0.85, Color3.fromRGB(210, 30, 50))
		end,
	},
	{
		nombre = "🍔 Hamburguesa",
		construir = function(modelo, base)
			disco(modelo, base, 0.18, 0.9, 0.1, Color3.fromRGB(215, 160, 90))
			disco(modelo, base, 0.16, 0.85, 0.26, Color3.fromRGB(90, 55, 35))
			disco(modelo, base, 0.06, 0.95, 0.37, Color3.fromRGB(90, 190, 80))
			bola(modelo, base, Vector3.new(0.9, 0.55, 0.9), 0.65, Color3.fromRGB(215, 160, 90))
		end,
	},
	{
		nombre = "🍩 Donut",
		construir = function(modelo, base)
			disco(modelo, base, 0.28, 0.9, 0.14, Color3.fromRGB(250, 150, 200))
			disco(modelo, base, 0.3, 0.3, 0.14, Color3.fromRGB(45, 45, 50))
			for _, sitio in { { -0.3, 0.1, Color3.fromRGB(255, 255, 80) }, { 0.2, -0.3, Color3.fromRGB(80, 200, 255) }, { 0.3, 0.2, Color3.fromRGB(255, 255, 255) } } do
				bola(modelo, base, Vector3.new(0.1, 0.1, 0.1), 0.3, sitio[3], sitio[1], sitio[2])
			end
		end,
	},
	{
		nombre = "🥞 Tortitas",
		construir = function(modelo, base)
			for piso = 0, 2 do
				disco(modelo, base, 0.15, 1.0, 0.1 + piso * 0.16, Color3.fromRGB(240, 200, 110))
			end
			disco(modelo, base, 0.05, 0.7, 0.5, Color3.fromRGB(120, 70, 30))
			bola(modelo, base, Vector3.new(0.3, 0.14, 0.3), 0.58, Color3.fromRGB(255, 235, 120))
		end,
	},
	{
		nombre = "🍪 Galletas",
		construir = function(modelo, base)
			for _, sitio in { { -0.3, -0.2 }, { 0.3, -0.2 }, { 0, 0.3 } } do
				disco(modelo, base, 0.12, 0.55, 0.07, Color3.fromRGB(200, 140, 80), sitio[1], sitio[2])
				bola(modelo, base, Vector3.new(0.1, 0.06, 0.1), 0.14, Color3.fromRGB(70, 40, 25), sitio[1] + 0.08, sitio[2])
				bola(modelo, base, Vector3.new(0.1, 0.06, 0.1), 0.14, Color3.fromRGB(70, 40, 25), sitio[1] - 0.1, sitio[2] + 0.08)
			end
		end,
	},
}

local function prepararCocina(estufa)
	if estufa:FindFirstChildOfClass("ProximityPrompt") then
		return
	end
	local boton = crearBotonE(estufa, "Cocinar", "🍳 Cocina", 0.2, 10)
	local humo = Instance.new("ParticleEmitter")
	humo.Enabled = false
	humo.Rate = 20
	humo.Lifetime = NumberRange.new(1, 1.6)
	humo.Speed = NumberRange.new(3, 5)
	humo.EmissionDirection = Enum.NormalId.Top
	humo.Size = NumberSequence.new(0.5, 1.4)
	humo.Transparency = NumberSequence.new(0.5, 1)
	humo.Color = ColorSequence.new(Color3.fromRGB(230, 230, 230))
	humo.Parent = estufa

	local comidas = {} -- comidas[hueco] = el modelo de comida que hay sobre la cocina
	local siguienteHueco = 1
	local siguienteReceta = math.random(#RECETAS)
	local zHueco = { -0.85, 0, 0.85 }

	boton.Triggered:Connect(function(jugador)
		if not boton.Enabled then
			return
		end
		boton.Enabled = false
		humo.Enabled = true
		avisar(jugador, "👨‍🍳 Cocinando...", Color3.fromRGB(180, 110, 40))
		task.wait(AJUSTES.segundosDeCocinar)
		humo.Enabled = false
		if not estufa.Parent then
			return -- han quitado la cocina mientras tanto
		end

		-- Quitamos la comida que había en ese hueco y ponemos la nueva
		local hueco = siguienteHueco
		siguienteHueco = siguienteHueco % math.min(AJUSTES.comidasEnLaCocina, #zHueco) + 1
		if comidas[hueco] then
			comidas[hueco]:Destroy()
		end
		local receta = RECETAS[siguienteReceta]
		siguienteReceta = siguienteReceta % #RECETAS + 1
		local modelo = Instance.new("Model")
		modelo.Name = "Comida"
		receta.construir(modelo, estufa.CFrame * CFrame.new(0, 1.2, zHueco[hueco]))
		modelo.Parent = estufa.Parent
		comidas[hueco] = modelo

		contar(jugador, "Estad_comidas")
		avisar(jugador, "✅ ¡Listo! " .. receta.nombre, Color3.fromRGB(40, 160, 80))
		boton.Enabled = true
	end)
end

----------------------------------------------------------------------
-- 🔌 BUSCAR LOS MUEBLES CON JUEGO
----------------------------------------------------------------------

local function conectar(etiqueta, funcion)
	for _, parte in CollectionService:GetTagged(etiqueta) do
		task.spawn(funcion, parte)
	end
	CollectionService:GetInstanceAddedSignal(etiqueta):Connect(function(parte)
		task.spawn(funcion, parte)
	end)
end

conectar("JuegoDiana", prepararDiana)
conectar("JuegoPelota", prepararPelota)
conectar("JuegoCocina", prepararCocina)

print("🎮 Juegos de la casa listos.")
