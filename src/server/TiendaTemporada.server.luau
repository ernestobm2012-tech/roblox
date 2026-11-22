--[[
	🎁 TIENDA DE TEMPORADA
	Cada semana hay UN mueble especial de jardín que SOLO se puede comprar esa semana
	(⛄ muñeco de nieve, 🎃 calabaza gigante, 🏖️ castillo de arena, 🌻 girasol gigante,
	 🎄 arbolito de luces, 🪁 cometa). Si no lo compras esa semana, ¡tendrás que esperar
	a que vuelva a tocar (cada 6 semanas)! Lo que compras se queda para siempre y se guarda.

	Los muebles de temporada salen en una franja de césped al lado del jardín de tu casa.
	La tienda se ve en el botón "🏠 Mi casa", en la sección "🎁 Tienda de temporada".
	Cambia los jueves a las 00:00 (hora UTC), igual que el reto semanal.

	📋 DÓNDE VA: en Roblox Studio, dentro de ServerScriptService, como "Script".
	(Usa la marca "CasaOrigen" del script Casas, el marcador de monedas de MiMundo y
	el atributo "Temporada_<id>" del jugador, que guarda el script Guardado.)
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")

-- ⚙️ AJUSTES: ¡cambia estos valores y mira qué pasa!
local AJUSTES = {
	precio = 60, -- monedas que cuesta el mueble de la semana
}

local SEMANA = 604800
local COLUMNA_X = 14 -- la franja de césped (al lado de la valla), medida desde el centro de tu casa

local ultimaCompra = {}
local redibujoPendiente = {}

----------------------------------------------------------------------
-- 🧰 DIBUJAR LOS MUEBLES
----------------------------------------------------------------------

local function parte(carpeta, tamano, base, x, y, z, color, material, forma)
	local pieza = Instance.new("Part")
	pieza.Name = "Pieza"
	pieza.Size = tamano
	pieza.CFrame = base * CFrame.new(x, y, z)
	pieza.Color = color
	pieza.Material = material or Enum.Material.SmoothPlastic
	pieza.Shape = forma or Enum.PartType.Block
	pieza.Anchored = true
	pieza.CanCollide = false
	pieza.CastShadow = false
	pieza.Parent = carpeta
	return pieza
end

local BOLA = Enum.PartType.Ball

-- Cada mueble cabe en 1.8 x 1.8 studs, así que seis caben seguidos en la franja
local MUEBLES = {
	{
		id = "muneco", nombre = "Muñeco de nieve", icono = "⛄",
		construir = function(c, b)
			local blanco = Color3.fromRGB(250, 250, 255)
			parte(c, Vector3.new(1.7, 1.7, 1.7), b, 0, 0.85, 0, blanco, Enum.Material.Snow, BOLA)
			parte(c, Vector3.new(1.2, 1.2, 1.2), b, 0, 2.2, 0, blanco, Enum.Material.Snow, BOLA)
			parte(c, Vector3.new(0.8, 0.8, 0.8), b, 0, 3.1, 0, blanco, Enum.Material.Snow, BOLA)
			parte(c, Vector3.new(0.18, 0.18, 0.7), b, 0, 3.1, -0.5, Color3.fromRGB(255, 130, 30)) -- la zanahoria
			parte(c, Vector3.new(1, 0.15, 1), b, 0, 3.6, 0, Color3.fromRGB(35, 35, 40), Enum.Material.Fabric)
			parte(c, Vector3.new(0.6, 0.6, 0.6), b, 0, 3.9, 0, Color3.fromRGB(35, 35, 40), Enum.Material.Fabric)
		end,
	},
	{
		id = "calabaza", nombre = "Calabaza gigante", icono = "🎃",
		construir = function(c, b)
			parte(c, Vector3.new(1.8, 1.5, 1.8), b, 0, 0.75, 0, Color3.fromRGB(255, 130, 20), Enum.Material.SmoothPlastic, BOLA)
			parte(c, Vector3.new(0.25, 0.4, 0.25), b, 0, 1.65, 0, Color3.fromRGB(70, 130, 50))
			local luz = parte(c, Vector3.new(0.3, 0.3, 0.1), b, -0.4, 0.95, -0.85, Color3.fromRGB(255, 230, 80), Enum.Material.Neon)
			parte(c, Vector3.new(0.3, 0.3, 0.1), b, 0.4, 0.95, -0.85, Color3.fromRGB(255, 230, 80), Enum.Material.Neon)
			parte(c, Vector3.new(0.9, 0.2, 0.1), b, 0, 0.45, -0.88, Color3.fromRGB(255, 230, 80), Enum.Material.Neon)
			local punto = Instance.new("PointLight")
			punto.Color = Color3.fromRGB(255, 190, 90)
			punto.Range = 12
			punto.Brightness = 1.2
			punto.Shadows = false
			punto.Parent = luz
			CollectionService:AddTag(punto, "FarolaLuz") -- se enciende de noche
		end,
	},
	{
		id = "castillo", nombre = "Castillo de arena", icono = "🏖️",
		construir = function(c, b)
			local arena = Color3.fromRGB(235, 205, 135)
			parte(c, Vector3.new(1.8, 0.8, 1.8), b, 0, 0.4, 0, arena, Enum.Material.Sand)
			parte(c, Vector3.new(0.7, 1.2, 0.7), b, 0, 1.4, 0, arena, Enum.Material.Sand)
			for _, dx in { -0.6, 0.6 } do
				parte(c, Vector3.new(0.5, 1, 0.5), b, dx, 1.3, 0.6, arena, Enum.Material.Sand)
				parte(c, Vector3.new(0.5, 1, 0.5), b, dx, 1.3, -0.6, arena, Enum.Material.Sand)
			end
			parte(c, Vector3.new(0.06, 0.8, 0.06), b, 0, 2.4, 0, Color3.fromRGB(120, 90, 60))
			parte(c, Vector3.new(0.5, 0.3, 0.05), b, 0.25, 2.65, 0, Color3.fromRGB(230, 60, 60))
		end,
	},
	{
		id = "girasol", nombre = "Girasol gigante", icono = "🌻",
		construir = function(c, b)
			parte(c, Vector3.new(0.25, 3.6, 0.25), b, 0, 1.8, 0, Color3.fromRGB(70, 150, 60))
			parte(c, Vector3.new(0.6, 0.15, 0.9), b, 0.5, 1.2, 0, Color3.fromRGB(70, 150, 60))
			for i = 0, 7 do
				local angulo = math.rad(i * 45)
				parte(c, Vector3.new(0.35, 0.8, 0.12), b, math.cos(angulo) * 0.85, 3.8 + math.sin(angulo) * 0.85, -0.1, Color3.fromRGB(255, 215, 30))
			end
			parte(c, Vector3.new(1, 1, 0.3), b, 0, 3.8, 0, Color3.fromRGB(110, 70, 30), Enum.Material.SmoothPlastic, BOLA)
		end,
	},
	{
		id = "arbolito", nombre = "Arbolito de luces", icono = "🎄",
		construir = function(c, b)
			parte(c, Vector3.new(0.4, 0.8, 0.4), b, 0, 0.4, 0, Color3.fromRGB(110, 75, 40), Enum.Material.Wood)
			local verde = Color3.fromRGB(35, 125, 60)
			parte(c, Vector3.new(1.8, 1, 1.8), b, 0, 1.3, 0, verde)
			parte(c, Vector3.new(1.4, 1, 1.4), b, 0, 2.2, 0, verde)
			parte(c, Vector3.new(0.9, 1, 0.9), b, 0, 3.0, 0, verde)
			parte(c, Vector3.new(0.5, 0.5, 0.5), b, 0, 3.7, 0, Color3.fromRGB(255, 230, 80), Enum.Material.Neon, BOLA)
			local colores = { Color3.fromRGB(255, 80, 80), Color3.fromRGB(90, 160, 255), Color3.fromRGB(255, 220, 80), Color3.fromRGB(120, 255, 140) }
			for i, color in colores do
				local angulo = math.rad(i * 90)
				parte(c, Vector3.new(0.25, 0.25, 0.25), b, math.cos(angulo) * 0.7, 1.2 + i * 0.5, math.sin(angulo) * 0.7, color, Enum.Material.Neon, BOLA)
			end
		end,
	},
	{
		id = "cometa", nombre = "Cometa", icono = "🪁",
		construir = function(c, b)
			parte(c, Vector3.new(0.12, 3.4, 0.12), b, 0, 1.7, 0, Color3.fromRGB(150, 110, 70), Enum.Material.Wood)
			local rombo = parte(c, Vector3.new(1.3, 1.3, 0.1), b, 0, 3.7, 0, Color3.fromRGB(235, 70, 110))
			rombo.CFrame = rombo.CFrame * CFrame.Angles(0, 0, math.rad(45))
			parte(c, Vector3.new(0.5, 0.5, 0.11), b, 0, 3.7, 0, Color3.fromRGB(255, 220, 60)).CFrame = rombo.CFrame
			for i = 1, 3 do
				parte(c, Vector3.new(0.3, 0.3, 0.05), b, 0.15 * (-1) ^ i, 2.7 - i * 0.35, 0, Color3.fromRGB(90, 190, 255))
			end
		end,
	},
}

----------------------------------------------------------------------
-- 📋 LO QUE VE LA PANTALLA
----------------------------------------------------------------------

local catalogo = Instance.new("Folder")
catalogo.Name = "CatalogoTemporada"
for orden, mueble in MUEBLES do
	local ficha = Instance.new("Folder")
	ficha.Name = mueble.id
	ficha:SetAttribute("Id", mueble.id)
	ficha:SetAttribute("Nombre", mueble.nombre)
	ficha:SetAttribute("Icono", mueble.icono)
	ficha:SetAttribute("Precio", AJUSTES.precio)
	ficha:SetAttribute("Orden", orden)
	ficha.Parent = catalogo
end
catalogo.Parent = ReplicatedStorage

local evento = Instance.new("RemoteEvent")
evento.Name = "TemporadaAccion"
evento.Parent = ReplicatedStorage

local function muebleDeLaSemana()
	return MUEBLES[(os.time() // SEMANA + 3) % #MUEBLES + 1]
end

local function publicar()
	local mueble = muebleDeLaSemana()
	workspace:SetAttribute("TemporadaMueble", mueble.id)
end
publicar()

task.spawn(function()
	while true do
		task.wait(30)
		publicar() -- si empieza una semana nueva con el juego abierto
	end
end)

----------------------------------------------------------------------
-- 🛒 COMPRAR
----------------------------------------------------------------------

local function avisar(jugador, texto, color)
	local pantallaJugador = jugador:FindFirstChild("PlayerGui")
	if not pantallaJugador then
		return
	end
	local viejo = pantallaJugador:FindFirstChild("AvisoTemporada")
	if viejo then
		viejo:Destroy()
	end
	local pantalla = Instance.new("ScreenGui")
	pantalla.Name = "AvisoTemporada"
	pantalla.ResetOnSpawn = false
	pantalla.Parent = pantallaJugador
	local mensaje = Instance.new("TextLabel")
	mensaje.Size = UDim2.fromScale(0.6, 0.09)
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
	task.delay(4, function()
		pantalla:Destroy()
	end)
end

evento.OnServerEvent:Connect(function(jugador, accion, id)
	-- Comprobamos todo lo que manda la pantalla: nunca nos fiamos
	if accion ~= "comprar" or type(id) ~= "string" then
		return
	end
	local ahora = os.clock()
	if ultimaCompra[jugador] and ahora - ultimaCompra[jugador] < 1 then
		return
	end
	ultimaCompra[jugador] = ahora

	local mueble = muebleDeLaSemana()
	if id ~= mueble.id then
		avisar(jugador, "Ese mueble ya no está a la venta esta semana 😢", Color3.fromRGB(200, 60, 60))
		return
	end
	if jugador:GetAttribute("Temporada_" .. id) == true then
		return
	end
	if not jugador:GetAttribute("CasaNumero") then
		avisar(jugador, "Necesitas una casa para ponerlo en el jardín 🏠", Color3.fromRGB(200, 60, 60))
		return
	end
	local marcador = jugador:FindFirstChild("leaderstats")
	local monedas = marcador and marcador:FindFirstChild("Monedas")
	if not monedas or monedas.Value < AJUSTES.precio then
		avisar(jugador, "Te faltan monedas 🪙 (cuesta " .. AJUSTES.precio .. ")", Color3.fromRGB(200, 60, 60))
		return
	end

	monedas.Value -= AJUSTES.precio
	jugador:SetAttribute("Temporada_" .. id, true)
	avisar(jugador, mueble.icono .. " ¡Tuyo para siempre! Mira el césped al lado de tu jardín", Color3.fromRGB(60, 150, 90))
end)

----------------------------------------------------------------------
-- 🏡 LOS MUEBLES EN EL JARDÍN DE CADA CASA
----------------------------------------------------------------------

local function buscarOrigen(indice)
	for _, marca in CollectionService:GetTagged("CasaOrigen") do
		if marca:GetAttribute("Indice") == indice then
			return marca
		end
	end
	return nil
end

local function ponerMuebles(jugador)
	local origen
	for _ = 1, 40 do
		local numero = jugador:GetAttribute("CasaNumero")
		origen = numero and buscarOrigen(numero)
		if origen or not jugador.Parent then
			break
		end
		task.wait(0.5)
	end
	if not origen then
		return
	end
	local carpeta = origen.Parent:FindFirstChild("Temporada")
	if not carpeta then
		carpeta = Instance.new("Folder")
		carpeta.Name = "Temporada"
		carpeta.Parent = origen.Parent
	end
	carpeta:ClearAllChildren()
	for i, mueble in MUEBLES do
		if jugador:GetAttribute("Temporada_" .. mueble.id) == true then
			-- uno detrás de otro a lo largo de la franja de césped
			mueble.construir(carpeta, origen.CFrame * CFrame.new(COLUMNA_X, 0.1, -12.8 - (i - 1) * 2))
		end
	end
end

local function programar(jugador)
	if redibujoPendiente[jugador] then
		return
	end
	redibujoPendiente[jugador] = true
	task.delay(1.5, function()
		redibujoPendiente[jugador] = nil
		if jugador.Parent then
			ponerMuebles(jugador)
		end
	end)
end

local function vigilar(jugador)
	jugador.AttributeChanged:Connect(function(nombre)
		if nombre == "CasaNumero" or string.sub(nombre, 1, 10) == "Temporada_" then
			programar(jugador)
		end
	end)
	if jugador:GetAttribute("CasaNumero") then
		programar(jugador)
	end
end

Players.PlayerAdded:Connect(vigilar)
for _, jugador in Players:GetPlayers() do
	vigilar(jugador)
end
Players.PlayerRemoving:Connect(function(jugador)
	ultimaCompra[jugador] = nil
	redibujoPendiente[jugador] = nil
	local numero = jugador:GetAttribute("CasaNumero")
	local origen = numero and buscarOrigen(numero)
	local carpeta = origen and origen.Parent:FindFirstChild("Temporada")
	if carpeta then
		carpeta:ClearAllChildren()
	end
end)

print("🎁 Tienda de temporada lista.")
