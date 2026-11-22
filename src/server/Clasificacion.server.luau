--[[
	🏆 TABLA DE LOS MEJORES JUGADORES
	Un tablero grande, detrás de la salida, con los 10 jugadores que han llegado a un nivel más alto
	(de todos los que han jugado a este mundo, ¡aunque ahora no estén conectados!).
	Se actualiza solo cada minuto.

	⚠️ Como el guardado, necesita el mundo publicado y "Habilitar acceso de Studio a servicios de API".
	   Si no, el tablero avisa de que falta activarlo.

	📋 DÓNDE VA: en Roblox Studio, dentro de ServerScriptService, como "Script".
	(Lee el nivel de cada jugador del atributo "Nivel", que pone el script Niveles.)
]]

local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")

-- ⚙️ AJUSTES
local AJUSTES = {
	nombreDelGuardado = "MiMundoClasificacion_v1", -- si lo cambias, la tabla empieza de cero
	cuantos = 10, -- cuántos jugadores salen en la tabla
	segundosEntreActualizaciones = 60,
	posicion = Vector3.new(0, 0, -30), -- dónde está el tablero (X, Y, Z)
}

local almacen = DataStoreService:GetOrderedDataStore(AJUSTES.nombreDelGuardado)
local enviado = {} -- enviado[jugador] = último nivel que hemos mandado
local nombres = {} -- nombres de jugadores que ya hemos buscado

----------------------------------------------------------------------
-- 🔨 CONSTRUIMOS EL TABLERO
----------------------------------------------------------------------

local carpeta = Instance.new("Folder")
carpeta.Name = "Clasificacion"
carpeta.Parent = workspace

local centro = Vector3.new(AJUSTES.posicion.X, AJUSTES.posicion.Y + 13, AJUSTES.posicion.Z)
local base = CFrame.lookAt(centro, Vector3.new(0, centro.Y, 0)) -- mira hacia la salida

local function crearParte(nombre, tamano, cframe, color, material)
	local parte = Instance.new("Part")
	parte.Name = nombre
	parte.Size = tamano
	parte.CFrame = cframe
	parte.Color = color
	parte.Material = material
	parte.Anchored = true
	parte.Parent = carpeta
	return parte
end

local metal = Color3.fromRGB(60, 60, 70)
crearParte("PosteIzquierdo", Vector3.new(1.4, 12, 1.4), base * CFrame.new(-11, -7, 0.8), metal, Enum.Material.Metal)
crearParte("PosteDerecho", Vector3.new(1.4, 12, 1.4), base * CFrame.new(11, -7, 0.8), metal, Enum.Material.Metal)
local tablero = crearParte("Tablero", Vector3.new(26, 16, 1), base, Color3.fromRGB(25, 25, 55), Enum.Material.SmoothPlastic)

local pantalla = Instance.new("SurfaceGui")
pantalla.Face = Enum.NormalId.Front
pantalla.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
pantalla.PixelsPerStud = 40 -- el tablero mide 1040 x 640 "pixeles"
pantalla.Parent = tablero

local function crearTexto(texto, alto, y, tamanoLetra, color, alineacion)
	local etiqueta = Instance.new("TextLabel")
	etiqueta.Size = UDim2.new(1, -80, 0, alto)
	etiqueta.Position = UDim2.fromOffset(40, y)
	etiqueta.BackgroundTransparency = 1
	etiqueta.Text = texto
	etiqueta.TextColor3 = color
	etiqueta.TextSize = tamanoLetra
	etiqueta.TextXAlignment = alineacion
	etiqueta.Font = Enum.Font.FredokaOne
	etiqueta.Parent = pantalla
	return etiqueta
end

crearTexto("🏆 MEJORES JUGADORES", 80, 10, 54, Color3.fromRGB(255, 220, 80), Enum.TextXAlignment.Center)
local filas = {}
for i = 1, AJUSTES.cuantos do
	filas[i] = crearTexto(i .. ". ---", 48, 96 + (i - 1) * 50, 36, Color3.fromRGB(255, 255, 255), Enum.TextXAlignment.Left)
end

----------------------------------------------------------------------
-- 📤 MANDAR EL NIVEL DE CADA JUGADOR
----------------------------------------------------------------------

local function enviarNivel(jugador)
	local nivel = jugador:GetAttribute("Nivel")
	if type(nivel) ~= "number" or nivel <= (enviado[jugador] or 0) then
		return
	end
	local funciono = pcall(function()
		almacen:UpdateAsync(tostring(jugador.UserId), function(viejo)
			if viejo and viejo >= nivel then
				return nil -- ya tenía un nivel igual o mejor
			end
			return nivel
		end)
	end)
	if funciono then
		enviado[jugador] = nivel
	end
end

----------------------------------------------------------------------
-- 📥 ACTUALIZAR EL TABLERO
----------------------------------------------------------------------

local function nombreDe(userId)
	if not nombres[userId] then
		local funciono, nombre = pcall(function()
			return Players:GetNameFromUserIdAsync(userId)
		end)
		nombres[userId] = if funciono then nombre else "Jugador"
	end
	return nombres[userId]
end

local MEDALLAS = { "🥇", "🥈", "🥉" }

local function actualizarTablero()
	local funciono, paginas = pcall(function()
		return almacen:GetSortedAsync(false, AJUSTES.cuantos)
	end)
	if not funciono then
		filas[1].Text = "⚠️ Activa el guardado para ver la tabla"
		warn("🏆 No puedo leer la tabla: " .. tostring(paginas))
		return
	end

	local entradas = paginas:GetCurrentPage()
	for i = 1, AJUSTES.cuantos do
		local entrada = entradas[i]
		if entrada then
			local puesto = MEDALLAS[i] or (i .. ".")
			filas[i].Text = puesto .. " " .. nombreDe(tonumber(entrada.key)) .. " — nivel " .. entrada.value
		else
			filas[i].Text = i .. ". ---"
		end
	end
end

Players.PlayerRemoving:Connect(function(jugador)
	enviarNivel(jugador)
	enviado[jugador] = nil
end)

task.spawn(function()
	task.wait(5)
	while true do
		for _, jugador in Players:GetPlayers() do
			enviarNivel(jugador)
		end
		actualizarTablero()
		task.wait(AJUSTES.segundosEntreActualizaciones)
	end
end)

print("🏆 Tabla de mejores jugadores lista.")
