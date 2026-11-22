--[[
	🏅 INSIGNIAS POR LOGROS
	Cuando consigues algo especial, ¡ganas una insignia (y monedas de premio)! Por ejemplo:
	  🎁 abrir tu primer cofre · 🥇 llegar al nivel 100 · 🏎️ ganar 10 carreras · 🐾 subir una mascota...
	Las insignias se guardan (con el script Guardado) y además aparecen como TROFEOS en tu casita
	(script Casas). Las ves todas en el botón "🏅 Logros" de la pantalla (script Logros del cliente).

	📋 DÓNDE VA: en Roblox Studio, dentro de ServerScriptService, como "Script".
	(Lee contadores que ponen otros scripts en atributos del jugador: Estad_cofres, Estad_monedas,
	Estad_carrerasGanadas, Nivel, MascotaMaxNivel... y el marcador de Victorias.)
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

-- 🧺 LOS LOGROS (¡son 12, uno por cada hueco de la estantería de trofeos de la casa!)
-- "cumple" dice cuándo se consigue. "premio" son las monedas que te dan.
local function numero(jugador, nombre)
	return jugador:GetAttribute(nombre) or 0
end

local function victorias(jugador)
	local marcador = jugador:FindFirstChild("leaderstats")
	local valor = marcador and marcador:FindFirstChild("Victorias")
	return valor and valor.Value or 0
end

local function tieneMascota(jugador)
	for nombre, valor in jugador:GetAttributes() do
		if string.sub(nombre, 1, 15) == "Estilo_mascota_" and valor == true then
			return true
		end
	end
	return false
end

local LOGROS = {
	{ id = "primerCofre", icono = "🎁", nombre = "Primer cofre", descripcion = "Abre tu primer cofre sorpresa", premio = 10,
		cumple = function(j) return numero(j, "Estad_cofres") >= 1 end },
	{ id = "diezCofres", icono = "🗝️", nombre = "Cazatesoros", descripcion = "Abre 10 cofres sorpresa", premio = 50,
		cumple = function(j) return numero(j, "Estad_cofres") >= 10 end },
	{ id = "nivel10", icono = "🥉", nombre = "Nivel 10", descripcion = "Llega al nivel 10", premio = 10,
		cumple = function(j) return numero(j, "Nivel") >= 10 end },
	{ id = "nivel50", icono = "🥈", nombre = "Nivel 50", descripcion = "Llega al nivel 50", premio = 30,
		cumple = function(j) return numero(j, "Nivel") >= 50 end },
	{ id = "nivel100", icono = "🥇", nombre = "Nivel 100", descripcion = "Llega al nivel 100", premio = 60,
		cumple = function(j) return numero(j, "Nivel") >= 100 end },
	{ id = "nivel250", icono = "💎", nombre = "Nivel 250", descripcion = "Llega al nivel 250", premio = 150,
		cumple = function(j) return numero(j, "Nivel") >= 250 end },
	{ id = "meta", icono = "🏆", nombre = "¡Campeón!", descripcion = "Llega a la meta del nivel 500", premio = 300,
		cumple = function(j) return victorias(j) >= 1 end },
	{ id = "primeraCarrera", icono = "🏁", nombre = "Primera victoria", descripcion = "Gana una carrera", premio = 25,
		cumple = function(j) return numero(j, "Estad_carrerasGanadas") >= 1 end },
	{ id = "diezCarreras", icono = "🏎️", nombre = "Piloto", descripcion = "Gana 10 carreras", premio = 100,
		cumple = function(j) return numero(j, "Estad_carrerasGanadas") >= 10 end },
	{ id = "monedas1000", icono = "💰", nombre = "Millonario", descripcion = "Recoge 1000 monedas", premio = 50,
		cumple = function(j) return numero(j, "Estad_monedas") >= 1000 end },
	{ id = "primeraMascota", icono = "🐾", nombre = "Amigo fiel", descripcion = "Consigue tu primera mascota", premio = 15,
		cumple = function(j) return tieneMascota(j) end },
	{ id = "mascotaNivel10", icono = "⭐", nombre = "Gran entrenador", descripcion = "Sube una mascota al nivel 10", premio = 80,
		cumple = function(j) return numero(j, "MascotaMaxNivel") >= 10 end },
}

----------------------------------------------------------------------
-- 📋 LA LISTA PARA LA PANTALLA Y PARA LAS CASAS
----------------------------------------------------------------------

local catalogo = Instance.new("Folder")
catalogo.Name = "CatalogoLogros"
for orden, logro in LOGROS do
	local ficha = Instance.new("Folder")
	ficha.Name = logro.id
	ficha:SetAttribute("Id", logro.id)
	ficha:SetAttribute("Icono", logro.icono)
	ficha:SetAttribute("Nombre", logro.nombre)
	ficha:SetAttribute("Descripcion", logro.descripcion)
	ficha:SetAttribute("Premio", logro.premio)
	ficha:SetAttribute("Orden", orden)
	ficha.Parent = catalogo
end
catalogo.Parent = ReplicatedStorage

----------------------------------------------------------------------
-- 🧰 HERRAMIENTAS
----------------------------------------------------------------------

local entrada = {} -- entrada[jugador] = cuándo entró

-- ¿Ya se ha cargado lo guardado? (si no se carga nunca, esperamos 20 segundos y seguimos)
local function listo(jugador)
	return jugador:GetAttribute("DatosCargados") == true or os.clock() - (entrada[jugador] or os.clock()) > 20
end

local function avisar(jugador, texto, color)
	local pantallaJugador = jugador:FindFirstChild("PlayerGui")
	if not pantallaJugador then
		return
	end
	local viejo = pantallaJugador:FindFirstChild("AvisoLogro")
	if viejo then
		viejo:Destroy()
	end

	local pantalla = Instance.new("ScreenGui")
	pantalla.Name = "AvisoLogro"
	pantalla.ResetOnSpawn = false
	pantalla.Parent = pantallaJugador

	local mensaje = Instance.new("TextLabel")
	mensaje.Size = UDim2.fromScale(0.6, 0.1)
	mensaje.Position = UDim2.fromScale(0.5, 0.36)
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

	task.delay(5, function()
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

----------------------------------------------------------------------
-- 🏅 CONSEGUIR LOGROS
----------------------------------------------------------------------

-- Mira todos los logros y da los que ya se han cumplido (y no tenías)
local function comprobar(jugador)
	if not listo(jugador) then
		return
	end
	for _, logro in LOGROS do
		local atributo = "Logro_" .. logro.id -- el script Guardado se acuerda
		if not jugador:GetAttribute(atributo) and logro.cumple(jugador) then
			jugador:SetAttribute(atributo, true)
			sumarMonedas(jugador, logro.premio)
			avisar(jugador, "🏅 ¡Logro: " .. logro.icono .. " " .. logro.nombre .. "!  +" .. logro.premio .. " 🪙", Color3.fromRGB(190, 130, 0))
		end
	end
end

local function prepararJugador(jugador)
	entrada[jugador] = os.clock()

	-- Miramos los logros cuando cambia algo que los puede cumplir
	jugador.AttributeChanged:Connect(function(nombre)
		if nombre == "DatosCargados" or nombre == "Nivel" or nombre == "MascotaMaxNivel" or string.sub(nombre, 1, 6) == "Estad_" or string.sub(nombre, 1, 15) == "Estilo_mascota_" then
			comprobar(jugador)
		end
	end)

	-- Las victorias están en el marcador
	task.spawn(function()
		local marcador = jugador:WaitForChild("leaderstats", 30)
		local victoriasValor = marcador and marcador:WaitForChild("Victorias", 30)
		if victoriasValor then
			victoriasValor:GetPropertyChangedSignal("Value"):Connect(function()
				comprobar(jugador)
			end)
		end
	end)

	-- Y una vez cuando ya se ha cargado lo guardado (o pasados 20 segundos)
	task.spawn(function()
		task.wait(21)
		if jugador.Parent then
			comprobar(jugador)
		end
	end)
	comprobar(jugador)
end

Players.PlayerAdded:Connect(prepararJugador)
for _, jugador in Players:GetPlayers() do
	prepararJugador(jugador)
end
Players.PlayerRemoving:Connect(function(jugador)
	entrada[jugador] = nil
end)

print("🏅 Logros listos.")
