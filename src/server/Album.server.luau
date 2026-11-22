--[[
	📸 ÁLBUM DE FOTOS
	Con la 📷 cámara de fotos (se compra en "🏠 Mi casa") haces FOTOS de tu personaje y se cuelgan
	como cuadros en las paredes de tu casa (caben 6; si haces más, la nueva sustituye a la más vieja).
	  - 📸 A mano: en "🏠 Mi casa" pulsa "Hacer una foto".
	  - 🏅 Solas: cuando consigues un LOGRO nuevo, y cada 50 niveles del parkour (50, 100, 150...),
	    ¡la cámara hace una foto sola de tu mejor momento!
	Cada foto lleva un texto y la fecha. Se guardan (con el script Guardado). Los cuadros enseñan a tu
	personaje tal y como va vestido AHORA (se vuelve a dibujar al entrar en el juego).

	📋 DÓNDE VA: en Roblox Studio, dentro de ServerScriptService, como "Script".
	(Usa la marca "CasaOrigen" que pone el script Casas y la cámara "Casa_camara". Habla con la pantalla
	con un RemoteEvent. Las fotos son atributos "Foto_1_pie", "Foto_1_fecha"...)
	🎨 También puedes PINTAR cuadros de 10 x 10 cuadraditos (ventana del script Pintar) y se cuelgan igual.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local TweenService = game:GetService("TweenService")

-- ⚙️ AJUSTES
local AJUSTES = {
	maximoDeFotos = 6,
	esperaEntreFotos = 8, -- segundos entre una foto y otra
	cadaCuantosNiveles = 50, -- cada tantos niveles, foto automática
}

-- Dónde cuelgan los cuadros: { x, z, lado } dentro de la casa. "lado" 1 = pared izquierda (mira a +X), -1 = derecha.
local HUECOS = {
	{ -9.3, -5, 1 }, { -9.3, 0, 1 }, { -9.3, 5, 1 },
	{ 9.3, -5, -1 }, { 9.3, 0, -1 }, { 9.3, 5, -1 },
}
local ALTURA = 9.5 -- a qué altura (desde el suelo del mundo)

local FONDOS = {
	Color3.fromRGB(150, 205, 255), Color3.fromRGB(190, 235, 170), Color3.fromRGB(255, 215, 160),
	Color3.fromRGB(235, 190, 235), Color3.fromRGB(255, 200, 200), Color3.fromRGB(200, 225, 235),
}

local MADERA = Color3.fromRGB(150, 100, 60)

-- 🎨 Los cuadros que pintas: una cuadrícula de 10 x 10 cuadraditos. Cada cuadradito es una letra/cifra de esta lista
-- (la pantalla de pintar tiene la MISMA lista de colores).
local LADO_CUADRO = 10
local PALETA = {
	["0"] = Color3.fromRGB(255, 255, 255), ["1"] = Color3.fromRGB(30, 30, 35), ["2"] = Color3.fromRGB(235, 60, 60),
	["3"] = Color3.fromRGB(255, 150, 50), ["4"] = Color3.fromRGB(255, 225, 60), ["5"] = Color3.fromRGB(80, 200, 100),
	["6"] = Color3.fromRGB(60, 140, 255), ["7"] = Color3.fromRGB(150, 90, 230), ["8"] = Color3.fromRGB(255, 130, 190),
	["9"] = Color3.fromRGB(140, 90, 50), ["a"] = Color3.fromRGB(150, 150, 155), ["b"] = Color3.fromRGB(120, 220, 230),
}
local TITULOS_DE_CUADROS = { "Mi dibujo", "Un monstruo", "Mi mascota", "Mi casa", "El parkour", "Un paisaje" }

local evento = Instance.new("RemoteEvent")
evento.Name = "AlbumAccion"
evento.Parent = ReplicatedStorage

local ultimaFoto = {} -- ultimaFoto[jugador] = cuándo hizo la última
local redibujoPendiente = {}
local entrada = {} -- cuándo entró cada jugador

----------------------------------------------------------------------
-- 🧰 HERRAMIENTAS
----------------------------------------------------------------------

local function avisar(jugador, texto, color)
	local pantallaJugador = jugador:FindFirstChild("PlayerGui")
	if not pantallaJugador then
		return
	end
	local viejo = pantallaJugador:FindFirstChild("AvisoAlbum")
	if viejo then
		viejo:Destroy()
	end

	local pantalla = Instance.new("ScreenGui")
	pantalla.Name = "AvisoAlbum"
	pantalla.ResetOnSpawn = false
	pantalla.Parent = pantallaJugador

	local mensaje = Instance.new("TextLabel")
	mensaje.Size = UDim2.fromScale(0.5, 0.09)
	mensaje.Position = UDim2.fromScale(0.5, 0.75)
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

	task.delay(3, function()
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

-- El "flash" blanco de la cámara
local function destello(jugador)
	local pantallaJugador = jugador:FindFirstChild("PlayerGui")
	if not pantallaJugador then
		return
	end
	local pantalla = Instance.new("ScreenGui")
	pantalla.Name = "FlashFoto"
	pantalla.IgnoreGuiInset = true
	pantalla.ResetOnSpawn = false
	pantalla.Parent = pantallaJugador
	local blanco = Instance.new("Frame")
	blanco.Size = UDim2.fromScale(1, 1)
	blanco.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	blanco.BorderSizePixel = 0
	blanco.Parent = pantalla
	local desaparecer = TweenService:Create(blanco, TweenInfo.new(0.5), { BackgroundTransparency = 1 })
	desaparecer:Play()
	desaparecer.Completed:Connect(function()
		pantalla:Destroy()
	end)
end

-- Busca la marca de una casa (por su número)
local function buscarOrigen(indice)
	for _, marca in CollectionService:GetTagged("CasaOrigen") do
		if marca:GetAttribute("Indice") == indice then
			return marca
		end
	end
	return nil
end

-- Espera (un rato) a que exista la casa del jugador
local function esperarOrigen(jugador)
	for _ = 1, 40 do
		local numero = jugador:GetAttribute("CasaNumero")
		local origen = numero and buscarOrigen(numero)
		if origen then
			return origen
		end
		task.wait(0.5)
	end
	return nil
end

local function carpetaDeFotos(origen)
	local carpeta = origen.Parent:FindFirstChild("Fotos")
	if not carpeta then
		carpeta = Instance.new("Folder")
		carpeta.Name = "Fotos"
		carpeta.Parent = origen.Parent
	end
	return carpeta
end

-- Hace una copia del personaje para ponerla en el cuadro (sin scripts ni sonidos)
local function copiaDelPersonaje(jugador)
	local personaje = jugador.Character
	if not personaje then
		return nil
	end
	for _, objeto in personaje:GetDescendants() do
		pcall(function()
			objeto.Archivable = true
		end)
	end
	pcall(function()
		personaje.Archivable = true
	end)
	local funciono, copia = pcall(function()
		return personaje:Clone()
	end)
	if not funciono or not copia then
		return nil
	end
	for _, objeto in copia:GetDescendants() do
		if objeto:IsA("Script") or objeto:IsA("LocalScript") or objeto:IsA("Sound") or objeto:IsA("ForceField") then
			objeto:Destroy()
		elseif objeto:IsA("BasePart") then
			objeto.Anchored = true
		end
	end
	local humanoide = copia:FindFirstChildOfClass("Humanoid")
	if humanoide then
		humanoide.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
	end
	return copia
end

----------------------------------------------------------------------
-- 🖼️ DIBUJAR LOS CUADROS
----------------------------------------------------------------------

local function dibujarFoto(jugador, origen, numero)
	local carpeta = carpetaDeFotos(origen)
	local viejo = carpeta:FindFirstChild("Foto_" .. numero)
	if viejo then
		viejo:Destroy()
	end
	local pie = jugador:GetAttribute("Foto_" .. numero .. "_pie")
	if not pie then
		return
	end

	local hueco = HUECOS[numero]
	local marco = Instance.new("Part")
	marco.Name = "Foto_" .. numero
	marco.Size = Vector3.new(0.2, 1.7, 2.3)
	marco.CFrame = origen.CFrame * CFrame.new(hueco[1], ALTURA, hueco[2])
	marco.Color = MADERA
	marco.Material = Enum.Material.Wood
	marco.Anchored = true
	marco.CanCollide = false
	marco.CastShadow = false
	marco.Parent = carpeta

	local pantalla = Instance.new("SurfaceGui")
	pantalla.Face = if hueco[3] == 1 then Enum.NormalId.Right else Enum.NormalId.Left
	pantalla.SizingMode = Enum.SurfaceGuiSizingMode.FixedSize
	pantalla.CanvasSize = Vector2.new(460, 340)
	pantalla.LightInfluence = 0
	pantalla.Parent = marco

	-- ¿Es un cuadro pintado (3 trocitos de texto con los colores) o una foto del personaje?
	local dibujo = (jugador:GetAttribute("Foto_" .. numero .. "_d1") or "")
		.. (jugador:GetAttribute("Foto_" .. numero .. "_d2") or "")
		.. (jugador:GetAttribute("Foto_" .. numero .. "_d3") or "")
	local esCuadro = #dibujo == LADO_CUADRO * LADO_CUADRO

	local visor
	if esCuadro then
		local lienzo = Instance.new("Frame")
		lienzo.Size = UDim2.fromOffset(250, 250)
		lienzo.Position = UDim2.new(0.5, -125, 0, 8)
		lienzo.BackgroundColor3 = PALETA["0"]
		lienzo.BorderSizePixel = 0
		lienzo.Parent = pantalla
		local celda = 250 / LADO_CUADRO
		for fila = 0, LADO_CUADRO - 1 do
			-- juntamos los cuadraditos seguidos del mismo color en uno solo (así pesa menos)
			local columna = 0
			while columna < LADO_CUADRO do
				local letra = string.sub(dibujo, fila * LADO_CUADRO + columna + 1, fila * LADO_CUADRO + columna + 1)
				local largo = 1
				while columna + largo < LADO_CUADRO and string.sub(dibujo, fila * LADO_CUADRO + columna + largo + 1, fila * LADO_CUADRO + columna + largo + 1) == letra do
					largo += 1
				end
				if letra ~= "0" and PALETA[letra] then
					local trozo = Instance.new("Frame")
					trozo.Size = UDim2.fromOffset(celda * largo, celda)
					trozo.Position = UDim2.fromOffset(columna * celda, fila * celda)
					trozo.BackgroundColor3 = PALETA[letra]
					trozo.BorderSizePixel = 0
					trozo.Parent = lienzo
				end
				columna += largo
			end
		end
	else
		visor = Instance.new("ViewportFrame")
		visor.Size = UDim2.new(1, -16, 0.78, -8)
		visor.Position = UDim2.fromOffset(8, 8)
		visor.BackgroundColor3 = FONDOS[(numero - 1) % #FONDOS + 1]
		visor.Ambient = Color3.fromRGB(200, 200, 200)
		visor.LightColor = Color3.fromRGB(255, 255, 255)
		visor.Parent = pantalla

		local copia = copiaDelPersonaje(jugador)
		if copia then
			copia:PivotTo(CFrame.new(0, 0, 0) * CFrame.Angles(0, math.rad(20), 0))
			copia.Parent = visor
			local camara = Instance.new("Camera")
			camara.FieldOfView = 40
			camara.CFrame = CFrame.lookAt(Vector3.new(0, 0.3, -9), Vector3.new(0, 0.2, 0))
			camara.Parent = visor
			visor.CurrentCamera = camara
		end
	end

	-- El texto de debajo: lo que pasó y cuándo
	local texto = Instance.new("TextLabel")
	texto.Size = UDim2.new(1, -16, 0.22, -6)
	texto.Position = UDim2.new(0, 8, 0.78, 6)
	texto.BackgroundTransparency = 1
	texto.Text = pie .. "  ·  " .. (jugador:GetAttribute("Foto_" .. numero .. "_fecha") or "")
	texto.TextColor3 = Color3.fromRGB(255, 255, 255)
	texto.TextScaled = true
	texto.Font = Enum.Font.FredokaOne
	texto.Parent = pantalla
	local fondoTexto = Instance.new("Frame")
	fondoTexto.Size = UDim2.fromScale(1, 1)
	fondoTexto.BackgroundColor3 = Color3.fromRGB(40, 30, 25)
	fondoTexto.BorderSizePixel = 0
	fondoTexto.ZIndex = 0
	fondoTexto.Parent = pantalla
end

local function reconstruirTodo(jugador)
	local origen = esperarOrigen(jugador)
	if not origen or not jugador.Parent then
		return
	end
	for numero = 1, AJUSTES.maximoDeFotos do
		dibujarFoto(jugador, origen, numero)
	end
end

-- Junta varios cambios seguidos (al cargar lo guardado llegan muchos) y dibuja una sola vez
local function programarRedibujo(jugador)
	if redibujoPendiente[jugador] then
		return
	end
	redibujoPendiente[jugador] = true
	task.delay(1.5, function()
		redibujoPendiente[jugador] = nil
		if jugador.Parent then
			reconstruirTodo(jugador)
		end
	end)
end

----------------------------------------------------------------------
-- 📸 HACER FOTOS
----------------------------------------------------------------------

local function tieneCamara(jugador)
	return (jugador:GetAttribute("Casa_camara") or 0) >= 1
end

local function tomarFoto(jugador, pie, avisarSiNo)
	if not jugador:GetAttribute("CasaNumero") then
		if avisarSiNo then
			avisar(jugador, "Necesitas una casa para colgar las fotos 🏠", Color3.fromRGB(200, 60, 60))
		end
		return
	end
	if not tieneCamara(jugador) then
		if avisarSiNo then
			avisar(jugador, "Necesitas la 📷 cámara de fotos (cómprala en Mi casa → Muebles)", Color3.fromRGB(200, 60, 60))
		end
		return
	end
	local ahora = os.clock()
	if ahora - (ultimaFoto[jugador] or -100) < AJUSTES.esperaEntreFotos then
		if avisarSiNo then
			avisar(jugador, "¡Espera un poquito para la siguiente foto! 📸", Color3.fromRGB(90, 90, 120))
		end
		return
	end
	ultimaFoto[jugador] = ahora

	-- El texto no puede ser muy largo (y cuidado con cortar un emoji por la mitad)
	local corte = utf8.offset(pie, 37)
	if corte then
		pie = string.sub(pie, 1, corte - 1)
	end

	local numero = (jugador:GetAttribute("Foto_siguiente") or 0) % AJUSTES.maximoDeFotos + 1
	jugador:SetAttribute("Foto_siguiente", numero)
	jugador:SetAttribute("Foto_" .. numero .. "_pie", pie)
	jugador:SetAttribute("Foto_" .. numero .. "_fecha", os.date("!%d/%m/%Y"))
	jugador:SetAttribute("Foto_" .. numero .. "_nivel", jugador:GetAttribute("Nivel") or 1)
	for k = 1, 3 do
		jugador:SetAttribute("Foto_" .. numero .. "_d" .. k, nil) -- si había un cuadro pintado en ese hueco, se quita
	end

	jugador:SetAttribute("Estad_fotos", (jugador:GetAttribute("Estad_fotos") or 0) + 1) -- para el reto semanal
	destello(jugador)
	avisar(jugador, "📸 ¡Foto! Ya cuelga en tu casa", Color3.fromRGB(60, 100, 180))
	local origen = esperarOrigen(jugador)
	if origen then
		dibujarFoto(jugador, origen, numero)
	end
end

----------------------------------------------------------------------
-- 🎨 PINTAR CUADROS
----------------------------------------------------------------------

-- "codigo" son 100 letras/cifras (una por cuadradito); "titulo" es el número del nombre de la lista
local function colgarCuadro(jugador, codigo, titulo)
	if not jugador:GetAttribute("CasaNumero") then
		avisar(jugador, "Necesitas una casa para colgar el cuadro 🏠", Color3.fromRGB(200, 60, 60))
		return
	end
	-- La pantalla puede mandar cualquier cosa: comprobamos que son justo 100 letras de la paleta
	if type(codigo) ~= "string" or #codigo ~= LADO_CUADRO * LADO_CUADRO or string.find(codigo, "[^0-9ab]") then
		return
	end
	if type(titulo) ~= "number" or titulo ~= titulo then
		return
	end
	titulo = math.clamp(math.floor(titulo), 1, #TITULOS_DE_CUADROS)

	local ahora = os.clock()
	if ahora - (ultimaFoto[jugador] or -100) < AJUSTES.esperaEntreFotos then
		avisar(jugador, "¡Espera un poquito para colgar otro! 🎨", Color3.fromRGB(90, 90, 120))
		return
	end
	ultimaFoto[jugador] = ahora

	local numero = (jugador:GetAttribute("Foto_siguiente") or 0) % AJUSTES.maximoDeFotos + 1
	jugador:SetAttribute("Foto_siguiente", numero)
	-- Los textos guardados pueden tener hasta 40 letras: el dibujo va en 3 trozos (40 + 40 + 20)
	jugador:SetAttribute("Foto_" .. numero .. "_d1", string.sub(codigo, 1, 40))
	jugador:SetAttribute("Foto_" .. numero .. "_d2", string.sub(codigo, 41, 80))
	jugador:SetAttribute("Foto_" .. numero .. "_d3", string.sub(codigo, 81, 100))
	jugador:SetAttribute("Foto_" .. numero .. "_pie", "🎨 " .. TITULOS_DE_CUADROS[titulo])
	jugador:SetAttribute("Foto_" .. numero .. "_fecha", os.date("!%d/%m/%Y"))
	jugador:SetAttribute("Foto_" .. numero .. "_nivel", jugador:GetAttribute("Nivel") or 1)
	jugador:SetAttribute("Estad_cuadros", (jugador:GetAttribute("Estad_cuadros") or 0) + 1)

	avisar(jugador, "🎨 ¡Qué bonito! Tu cuadro ya cuelga en tu casa", Color3.fromRGB(150, 70, 190))
	local origen = esperarOrigen(jugador)
	if origen then
		dibujarFoto(jugador, origen, numero)
	end
end

local function nombreDelLogro(id)
	local catalogo = ReplicatedStorage:FindFirstChild("CatalogoLogros")
	local ficha = catalogo and catalogo:FindFirstChild(id)
	if ficha then
		return (ficha:GetAttribute("Icono") or "🏅") .. " " .. (ficha:GetAttribute("Nombre") or id)
	end
	return "🏅 Un logro"
end

local function prepararJugador(jugador)
	entrada[jugador] = os.clock()
	local ultimoNivel = jugador:GetAttribute("Nivel") or 1

	local function cargado()
		return jugador:GetAttribute("DatosCargados") == true or os.clock() - entrada[jugador] > 20
	end

	jugador.AttributeChanged:Connect(function(nombre)
		if nombre == "CasaNumero" or string.sub(nombre, 1, 5) == "Foto_" then
			programarRedibujo(jugador)
		elseif string.sub(nombre, 1, 6) == "Logro_" and jugador:GetAttribute(nombre) == true and cargado() then
			-- ¡Un logro nuevo! Foto automática
			tomarFoto(jugador, nombreDelLogro(string.sub(nombre, 7)), false)
		elseif nombre == "Nivel" then
			local nivel = jugador:GetAttribute("Nivel") or 1
			if nivel > ultimoNivel and nivel % AJUSTES.cadaCuantosNiveles == 0 and cargado() then
				tomarFoto(jugador, "🗼 ¡Nivel " .. nivel .. "!", false)
			end
			ultimoNivel = nivel
		end
	end)

	-- Cuando aparece el personaje (ya vestido), volvemos a dibujar los cuadros con su ropa de ahora
	jugador.CharacterAdded:Connect(function()
		for _ = 1, 20 do
			if jugador:HasAppearanceLoaded() then
				break
			end
			task.wait(0.5)
		end
		programarRedibujo(jugador)
	end)
	if jugador:GetAttribute("CasaNumero") then
		programarRedibujo(jugador)
	end
end

Players.PlayerAdded:Connect(prepararJugador)
for _, jugador in Players:GetPlayers() do
	prepararJugador(jugador)
end
Players.PlayerRemoving:Connect(function(jugador)
	-- Se va el dueño: se quitan sus cuadros de la casa
	local numero = jugador:GetAttribute("CasaNumero")
	local origen = numero and buscarOrigen(numero)
	local carpeta = origen and origen.Parent:FindFirstChild("Fotos")
	if carpeta then
		carpeta:ClearAllChildren()
	end
	ultimaFoto[jugador] = nil
	redibujoPendiente[jugador] = nil
	entrada[jugador] = nil
end)

evento.OnServerEvent:Connect(function(jugador, accion, valor, extra)
	-- Comprobamos que lo que nos manda tiene sentido (¡nunca nos fiamos de la pantalla!)
	if type(accion) ~= "string" then
		return
	end
	if accion == "foto" then
		tomarFoto(jugador, "📸 Nivel " .. (jugador:GetAttribute("Nivel") or 1), true)
	elseif accion == "cuadro" then
		colgarCuadro(jugador, valor, extra)
	elseif accion == "borrar" and type(valor) == "number" then
		local numero = math.floor(valor)
		if numero >= 1 and numero <= AJUSTES.maximoDeFotos then
			jugador:SetAttribute("Foto_" .. numero .. "_pie", nil)
			jugador:SetAttribute("Foto_" .. numero .. "_fecha", nil)
			jugador:SetAttribute("Foto_" .. numero .. "_nivel", nil)
			for k = 1, 3 do
				jugador:SetAttribute("Foto_" .. numero .. "_d" .. k, nil)
			end
		end
	end
end)

print("📸 Álbum de fotos listo.")
