--[[
	💾 AVISO DE GUARDADO
	Una etiqueta pequeña abajo a la izquierda que te dice si tus monedas y compras se están guardando:
	  - "💾 Guardado ✔  (🪙 123)"  → todo bien, tus monedas están a salvo para mañana
	  - "⚠️ NO se guarda" → algo falta: hay que PUBLICAR el mundo (Archivo → Publicar en Roblox) y activar
	    "Habilitar acceso de Studio a servicios de API" (Configuración del juego → Seguridad).

	Lo escribe el script Guardado en atributos del jugador ("GuardadoEstado" y "GuardadoMonedas").

	📋 DÓNDE VA: en Roblox Studio, dentro de StarterPlayer > StarterPlayerScripts,
	como "LocalScript".
]]

local Players = game:GetService("Players")

local jugador = Players.LocalPlayer

local pantalla = Instance.new("ScreenGui")
pantalla.Name = "EstadoGuardado"
pantalla.ResetOnSpawn = false
pantalla.Parent = jugador:WaitForChild("PlayerGui")

local etiqueta = Instance.new("TextLabel")
etiqueta.Size = UDim2.fromOffset(330, 26)
etiqueta.Position = UDim2.new(0, 10, 1, -34)
etiqueta.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
etiqueta.BackgroundTransparency = 0.4
etiqueta.TextColor3 = Color3.fromRGB(255, 255, 255)
etiqueta.TextScaled = true
etiqueta.Font = Enum.Font.GothamMedium
etiqueta.TextXAlignment = Enum.TextXAlignment.Left
etiqueta.Text = "💾 Cargando tus cosas..."
etiqueta.Parent = pantalla
Instance.new("UICorner", etiqueta).CornerRadius = UDim.new(0, 8)

local function actualizar()
	local estado = jugador:GetAttribute("GuardadoEstado")
	if estado == "ok" then
		local monedas = jugador:GetAttribute("GuardadoMonedas")
		etiqueta.Text = if monedas then "💾 Guardado ✔  (🪙 " .. monedas .. " a salvo)" else "💾 Listo para guardar ✔"
		etiqueta.TextColor3 = Color3.fromRGB(150, 255, 170)
	elseif estado == "error" then
		etiqueta.Text = "⚠️ NO se guarda: publica el mundo y activa la API"
		etiqueta.TextColor3 = Color3.fromRGB(255, 160, 140)
	else
		etiqueta.Text = "💾 Cargando tus cosas..."
		etiqueta.TextColor3 = Color3.fromRGB(255, 255, 255)
	end
end

jugador:GetAttributeChangedSignal("GuardadoEstado"):Connect(actualizar)
jugador:GetAttributeChangedSignal("GuardadoMonedas"):Connect(actualizar)
actualizar()
