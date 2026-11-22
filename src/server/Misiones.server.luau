--[[
	📅 MISIONES DEL DÍA
	Cada día cada jugador tiene 3 misiones nuevas, por ejemplo:
	  - 🪙 Recoge 50 monedas
	  - 🗼 Llega al nivel 30
	  - 🎁 Abre un cofre
	  - 🛒 Compra una mejora en la tienda
	  - 🏁 Corre una carrera
	Al cumplir una misión te dan un PREMIO de monedas, ¡y si cumples las 3 hay un premio extra!
	El progreso se guarda (con el script Guardado). Las misiones nuevas salen a medianoche (hora UTC).
	Las ves en el botón "📅 Misiones" de la pantalla (script Misiones del cliente).

	📋 DÓNDE VA: en Roblox Studio, dentro de ServerScriptService, como "Script".
	(Otros scripts le cuentan lo que pasa sumando 1 a atributos del jugador que empiezan por "Estad_":
	Estad_monedas, Estad_cofres, Estad_mejoras, Estad_carreras.)
]]

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

-- ⚙️ AJUSTES: ¡cambia estos valores y mira qué pasa!
local AJUSTES = {
	cuantas = 3, -- misiones por día
	premioExtraSiCumplesTodas = 30, -- monedas extra si cumples las 3
	segundosEntreRevisiones = 60, -- cada cuánto mira si ya es otro día
}

-- 🧺 LAS MISIONES POSIBLES. "tipo" dice qué hay que hacer. "objetivos" y "premios" van de la mano:
-- si sale el objetivo 50, el premio es el que está en el mismo sitio de la lista.
local MISIONES = {
	{ tipo = "monedas", objetivos = { 30, 50, 80 }, premios = { 10, 20, 35 } },
	{ tipo = "cofre", objetivos = { 1 }, premios = { 25 } },
	{ tipo = "mejora", objetivos = { 1, 2 }, premios = { 10, 25 } },
	{ tipo = "carrera", objetivos = { 1 }, premios = { 25 } },
	{ tipo = "nivel", premioNivel = 30 }, -- el objetivo depende de tu nivel
}

-- Qué contador de "Estad_" sirve para cada tipo de misión
local CONTADORES = {
	Estad_monedas = "monedas",
	Estad_cofres = "cofre",
	Estad_mejoras = "mejora",
	Estad_carreras = "carrera",
}

local ultimoValor = {} -- ultimoValor[jugador][contador] = lo último que vimos

----------------------------------------------------------------------
-- 🧰 HERRAMIENTAS
----------------------------------------------------------------------

-- Enseña un mensajito en la pantalla de un jugador
local function avisar(jugador, texto, color)
	local pantallaJugador = jugador:FindFirstChild("PlayerGui")
	if not pantallaJugador then
		return
	end
	local viejo = pantallaJugador:FindFirstChild("AvisoMision")
	if viejo then
		viejo:Destroy()
	end

	local pantalla = Instance.new("ScreenGui")
	pantalla.Name = "AvisoMision"
	pantalla.ResetOnSpawn = false
	pantalla.Parent = pantallaJugador

	local mensaje = Instance.new("TextLabel")
	mensaje.Size = UDim2.fromScale(0.6, 0.09)
	mensaje.Position = UDim2.fromScale(0.5, 0.42)
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

local function sumarMonedas(jugador, cantidad)
	local marcador = jugador:FindFirstChild("leaderstats")
	local monedas = marcador and marcador:FindFirstChild("Monedas")
	if monedas then
		monedas.Value += cantidad
	end
end

local function textoDeMision(tipo, objetivo)
	if tipo == "monedas" then
		return "Recoge " .. objetivo .. " monedas"
	elseif tipo == "nivel" then
		return "Llega al nivel " .. objetivo
	elseif tipo == "cofre" then
		return "Abre " .. objetivo .. " cofre"
	elseif tipo == "mejora" then
		return "Compra " .. objetivo .. " mejora en la tienda"
	elseif tipo == "carrera" then
		return "Corre " .. objetivo .. " carrera"
	end
	return tipo
end

----------------------------------------------------------------------
-- 🏅 CUMPLIR MISIONES
----------------------------------------------------------------------

local function completarMision(jugador, numero)
	jugador:SetAttribute("Mision_" .. numero .. "_hecha", true)
	local premio = jugador:GetAttribute("Mision_" .. numero .. "_premio") or 0
	sumarMonedas(jugador, premio)
	local texto = textoDeMision(jugador:GetAttribute("Mision_" .. numero .. "_tipo"), jugador:GetAttribute("Mision_" .. numero .. "_objetivo"))
	avisar(jugador, "✅ ¡Misión cumplida! " .. texto .. "  +" .. premio .. " 🪙", Color3.fromRGB(40, 160, 80))

	-- ¿Las has cumplido todas?
	if jugador:GetAttribute("Mision_bonus") then
		return
	end
	for i = 1, AJUSTES.cuantas do
		if not jugador:GetAttribute("Mision_" .. i .. "_hecha") then
			return
		end
	end
	jugador:SetAttribute("Mision_bonus", true)
	sumarMonedas(jugador, AJUSTES.premioExtraSiCumplesTodas)
	task.delay(2, function()
		avisar(jugador, "🌟 ¡Has cumplido TODAS las misiones de hoy! +" .. AJUSTES.premioExtraSiCumplesTodas .. " 🪙", Color3.fromRGB(190, 130, 0))
	end)
end

-- Suma progreso a las misiones de un tipo (monedas, cofre...)
local function sumarProgreso(jugador, tipo, cantidad)
	for i = 1, AJUSTES.cuantas do
		if jugador:GetAttribute("Mision_" .. i .. "_tipo") == tipo and not jugador:GetAttribute("Mision_" .. i .. "_hecha") then
			local objetivo = jugador:GetAttribute("Mision_" .. i .. "_objetivo") or 1
			local progreso = math.min((jugador:GetAttribute("Mision_" .. i .. "_progreso") or 0) + cantidad, objetivo)
			jugador:SetAttribute("Mision_" .. i .. "_progreso", progreso)
			if progreso >= objetivo then
				completarMision(jugador, i)
			end
		end
	end
end

-- Las misiones de "llegar al nivel": miran tu nivel
local function comprobarNivel(jugador)
	local nivel = jugador:GetAttribute("Nivel") or 1
	for i = 1, AJUSTES.cuantas do
		if jugador:GetAttribute("Mision_" .. i .. "_tipo") == "nivel" and not jugador:GetAttribute("Mision_" .. i .. "_hecha") then
			local objetivo = jugador:GetAttribute("Mision_" .. i .. "_objetivo") or 1
			jugador:SetAttribute("Mision_" .. i .. "_progreso", math.min(nivel, objetivo))
			if nivel >= objetivo then
				completarMision(jugador, i)
			end
		end
	end
end

----------------------------------------------------------------------
-- 🌅 MISIONES NUEVAS CADA DÍA
----------------------------------------------------------------------

local function diaDeHoy()
	return os.time() // 86400 -- el número de día (cambia a medianoche, hora UTC)
end

local function generarMisiones(jugador, dia)
	-- Borramos las de ayer
	for nombre in jugador:GetAttributes() do
		if string.sub(nombre, 1, 7) == "Mision_" then
			jugador:SetAttribute(nombre, nil)
		end
	end

	local azar = Random.new(dia * 7919 + jugador.UserId)
	local nivel = jugador:GetAttribute("Nivel") or 1
	local total = workspace:GetAttribute("TotalNiveles") or 500

	-- Barajamos las misiones posibles y cogemos las primeras
	local candidatas = {}
	for _, definicion in MISIONES do
		if definicion.tipo ~= "nivel" or nivel < total then
			table.insert(candidatas, definicion)
		end
	end
	for i = #candidatas, 2, -1 do
		local j = azar:NextInteger(1, i)
		candidatas[i], candidatas[j] = candidatas[j], candidatas[i]
	end

	for i = 1, math.min(AJUSTES.cuantas, #candidatas) do
		local definicion = candidatas[i]
		local objetivo, premio
		if definicion.tipo == "nivel" then
			-- El siguiente "redondo" (10, 20, 30...) por delante de ti, o el de después
			objetivo = math.min((nivel // 10 + azar:NextInteger(1, 2)) * 10, total)
			premio = definicion.premioNivel
		else
			local k = azar:NextInteger(1, #definicion.objetivos)
			objetivo = definicion.objetivos[k]
			premio = definicion.premios[k]
		end
		jugador:SetAttribute("Mision_" .. i .. "_tipo", definicion.tipo)
		jugador:SetAttribute("Mision_" .. i .. "_objetivo", objetivo)
		jugador:SetAttribute("Mision_" .. i .. "_premio", premio)
		jugador:SetAttribute("Mision_" .. i .. "_progreso", 0)
	end
	jugador:SetAttribute("Mision_dia", dia)
end

local function comprobarDia(jugador)
	local dia = diaDeHoy()
	if jugador:GetAttribute("Mision_dia") ~= dia then
		generarMisiones(jugador, dia)
		avisar(jugador, "📅 ¡Tienes misiones nuevas hoy!", Color3.fromRGB(60, 100, 200))
	end
	comprobarNivel(jugador)
end

----------------------------------------------------------------------
-- 👤 CADA JUGADOR
----------------------------------------------------------------------

local function prepararJugador(jugador)
	ultimoValor[jugador] = {}

	-- Los demás scripts nos cuentan lo que pasa sumando a los contadores "Estad_..."
	jugador.AttributeChanged:Connect(function(nombre)
		local tipo = CONTADORES[nombre]
		if tipo then
			local nuevo = jugador:GetAttribute(nombre) or 0
			local viejo = ultimoValor[jugador][nombre] or 0
			ultimoValor[jugador][nombre] = nuevo
			if nuevo > viejo then
				sumarProgreso(jugador, tipo, nuevo - viejo)
			end
		elseif nombre == "Nivel" then
			comprobarNivel(jugador)
		end
	end)

	-- Esperamos a que el script Guardado haya cargado lo de otras veces (si no, hasta 20 segundos)
	task.spawn(function()
		local espera = 0
		while jugador.Parent and not jugador:GetAttribute("DatosCargados") and espera < 20 do
			task.wait(0.5)
			espera += 0.5
		end
		if jugador.Parent then
			comprobarDia(jugador)
		end
	end)
end

Players.PlayerAdded:Connect(prepararJugador)
for _, jugador in Players:GetPlayers() do
	prepararJugador(jugador)
end
Players.PlayerRemoving:Connect(function(jugador)
	ultimoValor[jugador] = nil
end)

-- Si pasa la medianoche con el juego abierto, salen misiones nuevas
task.spawn(function()
	while true do
		task.wait(AJUSTES.segundosEntreRevisiones)
		for _, jugador in Players:GetPlayers() do
			if jugador:GetAttribute("Mision_dia") ~= nil then
				comprobarDia(jugador)
			end
		end
	end
end)

print("📅 Misiones del día listas.")
