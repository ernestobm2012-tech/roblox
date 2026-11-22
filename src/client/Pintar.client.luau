--[[
	🎨 PINTAR UN CUADRO
	Una ventana con una cuadrícula de 10 x 10 cuadraditos y 12 colores. Pintas tu dibujo
	pulsando los cuadraditos (también puedes arrastrar con el dedo o el ratón).
	Cuando te guste, elige un nombre y pulsa "Colgar en mi casa": el cuadro aparece en la pared
	de tu casa, junto a tus fotos (el álbum tiene 6 huecos; el siguiente cuadro borra el más antiguo).

	Se abre desde el botón "🏠 Mi casa" → "📸 Álbum" → "🎨 Pintar un cuadro".
	El cuadro lo cuelga el script Album del servidor.

	📋 DÓNDE VA: en Roblox Studio, dentro de StarterPlayer > StarterPlayerScripts,
	como "LocalScript".
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local jugador = Players.LocalPlayer

-- ⚙️ AJUSTES
local LADO = 10 -- cuadraditos por lado (tiene que ser igual que en el script Album)
local TAMANO = 30 -- píxeles de cada cuadradito en pantalla
-- Los colores: la letra de cada uno es lo que se manda al servidor (la misma lista que en el script Album)
local COLORES = {
	{ "0", Color3.fromRGB(255, 255, 255) }, { "1", Color3.fromRGB(30, 30, 35) }, { "2", Color3.fromRGB(235, 60, 60) },
	{ "3", Color3.fromRGB(255, 150, 50) }, { "4", Color3.fromRGB(255, 225, 60) }, { "5", Color3.fromRGB(80, 200, 100) },
	{ "6", Color3.fromRGB(60, 140, 255) }, { "7", Color3.fromRGB(150, 90, 230) }, { "8", Color3.fromRGB(255, 130, 190) },
	{ "9", Color3.fromRGB(140, 90, 50) }, { "a", Color3.fromRGB(150, 150, 155) }, { "b", Color3.fromRGB(120, 220, 230) },
}
local TITULOS = { "Mi dibujo", "Un monstruo", "Mi mascota", "Mi casa", "El parkour", "Un paisaje" }

local colorDeLetra = {}
for _, par in COLORES do
	colorDeLetra[par[1]] = par[2]
end

local pantalla = Instance.new("ScreenGui")
pantalla.Name = "Pintar"
pantalla.ResetOnSpawn = false
pantalla.DisplayOrder = 5
pantalla.Parent = jugador:WaitForChild("PlayerGui")

local function redondear(objeto, radio)
	local esquinas = Instance.new("UICorner")
	esquinas.CornerRadius = UDim.new(0, radio)
	esquinas.Parent = objeto
end

local panel = Instance.new("Frame")
panel.Size = UDim2.fromOffset(340, 560)
panel.Position = UDim2.fromScale(0.5, 0.5)
panel.AnchorPoint = Vector2.new(0.5, 0.5)
panel.BackgroundColor3 = Color3.fromRGB(50, 40, 75)
panel.Visible = false
panel.Parent = pantalla
redondear(panel, 16)

local function boton(texto, tamano, posicion, color)
	local b = Instance.new("TextButton")
	b.Size = tamano
	b.Position = posicion
	b.BackgroundColor3 = color
	b.TextColor3 = Color3.fromRGB(255, 255, 255)
	b.TextScaled = true
	b.Font = Enum.Font.FredokaOne
	b.Text = texto
	b.Parent = panel
	redondear(b, 10)
	return b
end

local titulo = Instance.new("TextLabel")
titulo.Size = UDim2.new(1, -60, 0, 34)
titulo.Position = UDim2.fromOffset(12, 8)
titulo.BackgroundTransparency = 1
titulo.Text = "🎨 Pinta tu cuadro"
titulo.TextColor3 = Color3.fromRGB(255, 255, 255)
titulo.TextScaled = true
titulo.Font = Enum.Font.FredokaOne
titulo.TextXAlignment = Enum.TextXAlignment.Left
titulo.Parent = panel

local cerrar = boton("✖", UDim2.fromOffset(34, 34), UDim2.new(1, -46, 0, 8), Color3.fromRGB(200, 60, 60))

-- La cuadrícula
local rejilla = Instance.new("Frame")
rejilla.Size = UDim2.fromOffset(LADO * TAMANO, LADO * TAMANO)
rejilla.Position = UDim2.new(0.5, -LADO * TAMANO / 2, 0, 52)
rejilla.BackgroundColor3 = Color3.fromRGB(20, 15, 35)
rejilla.BorderSizePixel = 0
rejilla.Parent = panel

local celdas = {} -- celdas[número] = el cuadradito
local letras = {} -- letras[número] = la letra del color puesto
local elegida = "2" -- el color con el que pintas
local pintando = false

local function pintar(numero)
	letras[numero] = elegida
	celdas[numero].BackgroundColor3 = colorDeLetra[elegida]
end

for numero = 1, LADO * LADO do
	local fila = (numero - 1) // LADO
	local columna = (numero - 1) % LADO
	local celda = Instance.new("TextButton")
	celda.Size = UDim2.fromOffset(TAMANO - 2, TAMANO - 2)
	celda.Position = UDim2.fromOffset(columna * TAMANO + 1, fila * TAMANO + 1)
	celda.BackgroundColor3 = colorDeLetra["0"]
	celda.BorderSizePixel = 0
	celda.Text = ""
	celda.AutoButtonColor = false
	celda.Parent = rejilla
	celdas[numero] = celda
	letras[numero] = "0"
	celda.MouseButton1Down:Connect(function()
		pintando = true
		pintar(numero)
	end)
	-- Arrastrar: al pasar por encima con el botón apretado, también pinta
	celda.MouseEnter:Connect(function()
		if pintando then
			pintar(numero)
		end
	end)
	celda.TouchTap:Connect(function()
		pintar(numero)
	end)
end

UserInputService.InputEnded:Connect(function(entrada)
	if entrada.UserInputType == Enum.UserInputType.MouseButton1 or entrada.UserInputType == Enum.UserInputType.Touch then
		pintando = false
	end
end)

-- Los colores
local marcas = {}
local function elegirColor(letra)
	elegida = letra
	for otra, marca in marcas do
		marca.Visible = otra == letra
	end
end
local fondoColores = 52 + LADO * TAMANO + 10
for i, par in COLORES do
	local columna = (i - 1) % 6
	local fila = (i - 1) // 6
	local c = boton("", UDim2.fromOffset(42, 36), UDim2.fromOffset(14 + columna * 53, fondoColores + fila * 44), par[2])
	local marca = Instance.new("TextLabel")
	marca.Size = UDim2.fromScale(1, 1)
	marca.BackgroundTransparency = 1
	marca.Text = "✔"
	marca.TextScaled = true
	marca.TextColor3 = if par[1] == "1" or par[1] == "9" then Color3.fromRGB(255, 255, 255) else Color3.fromRGB(30, 30, 35)
	marca.Visible = false
	marca.Parent = c
	marcas[par[1]] = marca
	c.Activated:Connect(function()
		elegirColor(par[1])
	end)
end
elegirColor("2")

-- Nombre del cuadro, borrar y colgar
local numeroTitulo = 1
local yBotones = fondoColores + 2 * 44 + 4
local botonTitulo = boton("Nombre: " .. TITULOS[1], UDim2.new(1, -28, 0, 34), UDim2.fromOffset(14, yBotones), Color3.fromRGB(90, 90, 140))
botonTitulo.Activated:Connect(function()
	numeroTitulo = numeroTitulo % #TITULOS + 1
	botonTitulo.Text = "Nombre: " .. TITULOS[numeroTitulo]
end)

local limpiar = boton("🧽 Borrar todo", UDim2.new(0.42, -14, 0, 38), UDim2.fromOffset(14, yBotones + 42), Color3.fromRGB(140, 90, 90))
limpiar.Activated:Connect(function()
	for numero = 1, LADO * LADO do
		letras[numero] = "0"
		celdas[numero].BackgroundColor3 = colorDeLetra["0"]
	end
end)

local colgar = boton("🖼️ Colgar en mi casa", UDim2.new(0.58, -14, 0, 38), UDim2.new(0.42, 2, 0, yBotones + 42), Color3.fromRGB(70, 150, 90))
colgar.Activated:Connect(function()
	local album = ReplicatedStorage:FindFirstChild("AlbumAccion")
	if not album then
		return
	end
	album:FireServer("cuadro", table.concat(letras), numeroTitulo)
	panel.Visible = false
end)

cerrar.Activated:Connect(function()
	panel.Visible = false
end)

-- Se abre cuando el botón "🎨 Pintar un cuadro" de Mi casa cambia este aviso
jugador:GetAttributeChangedSignal("AbrirPintura"):Connect(function()
	if jugador:GetAttribute("AbrirPintura") then
		panel.Visible = true
	end
end)
