--[[
	💎 COSAS QUE SE COMPRAN CON ROBUX (Pases)
	Aquí están las cosas especiales que se pagan con Robux, como el 🚀 JETPACK.
	Cada una es un "Pase de juego" de Roblox: se paga UNA vez y es tuyo para siempre.
	El precio se pone en la web de Roblox (no aquí): mira el README.

	Cómo funciona:
	  1. El jugador pulsa el botón de comprar en la pantalla (script Jetpack).
	  2. Roblox le enseña su ventana de compra y le deja confirmar o cancelar.
	  3. Si compra, el pase queda apuntado en su cuenta de Roblox (no se puede perder).

	⚠️ MIENTRAS EL "id" DE UN PASE SEA 0 NO SE COBRA NADA:
	   - En Roblox Studio es GRATIS (modo prueba) para poder probarlo.
	   - En el juego publicado el botón dice que la compra aún no está activada.

	Para añadir otra cosa de pago, se añade a la lista "pases" de AJUSTES (pídeselo a Claude).

	📋 DÓNDE VA: en Roblox Studio, dentro de ServerScriptService, como "Script".
	(Habla con la pantalla con un RemoteEvent y con atributos del jugador: "Pase_jetpack".)
]]

local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

-- ⚙️ AJUSTES
local AJUSTES = {
	-- Las cosas que se compran con Robux. "id" es el número (ID) del Pase de juego, que se crea
	-- en la web de Roblox. ⚠️ Mientras sea 0, no se cobra nada.
	pases = {
		jetpack = { id = 0, nombre = "🚀 Jetpack" },
	},
	segundosEntrePedidos = 2, -- para que nadie pulse mil veces seguidas
}

local modoPrueba = RunService:IsStudio()
local ultimoPedido = {}

-- El botón de la pantalla nos avisa con este "mensajero"
local evento = Instance.new("RemoteEvent")
evento.Name = "ComprarPase"
evento.Parent = ReplicatedStorage

----------------------------------------------------------------------
-- 🧰 HERRAMIENTAS
----------------------------------------------------------------------

-- Enseña un mensajito en la pantalla de un jugador
local function avisar(jugador, texto, color)
	local pantallaJugador = jugador:FindFirstChild("PlayerGui")
	if not pantallaJugador then
		return
	end
	local viejo = pantallaJugador:FindFirstChild("AvisoPase")
	if viejo then
		viejo:Destroy()
	end

	local pantalla = Instance.new("ScreenGui")
	pantalla.Name = "AvisoPase"
	pantalla.ResetOnSpawn = false
	pantalla.Parent = pantallaJugador

	local mensaje = Instance.new("TextLabel")
	mensaje.Size = UDim2.fromScale(0.55, 0.09)
	mensaje.Position = UDim2.fromScale(0.5, 0.52)
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

local function tiene(jugador, clave)
	return jugador:GetAttribute("Pase_" .. clave) == true
end

----------------------------------------------------------------------
-- 🔎 PRECIOS Y PASES QUE YA TIENE CADA JUGADOR
----------------------------------------------------------------------

-- Que la pantalla enseñe el precio real de cada pase
for clave, pase in AJUSTES.pases do
	if pase.id ~= 0 then
		task.spawn(function()
			local funciono, info = pcall(function()
				return MarketplaceService:GetProductInfo(pase.id, Enum.InfoType.GamePass)
			end)
			if funciono and info and info.PriceInRobux then
				workspace:SetAttribute("PrecioPase_" .. clave, info.PriceInRobux)
			else
				warn("💎 No encuentro el pase " .. pase.id .. " (" .. clave .. "). ¿Está bien el número (ID)?")
			end
		end)
	elseif modoPrueba then
		workspace:SetAttribute("PaseModoPrueba", true)
	else
		warn("💎 Falta el ID del pase '" .. clave .. "'. No está activado.")
	end
end

-- Comprobamos qué pases ya ha comprado un jugador (en esta o en otra partida)
local function comprobarPases(jugador)
	for clave, pase in AJUSTES.pases do
		if pase.id ~= 0 then
			local funciono, loTiene = pcall(function()
				return MarketplaceService:UserOwnsGamePassAsync(jugador.UserId, pase.id)
			end)
			if funciono and loTiene and jugador.Parent then
				jugador:SetAttribute("Pase_" .. clave, true)
			end
		end
	end
end

Players.PlayerAdded:Connect(function(jugador)
	task.spawn(comprobarPases, jugador)
end)
for _, jugador in Players:GetPlayers() do
	task.spawn(comprobarPases, jugador)
end

Players.PlayerRemoving:Connect(function(jugador)
	ultimoPedido[jugador] = nil
end)

----------------------------------------------------------------------
-- 🧾 EL PAGO (Roblox nos avisa cuando termina la compra)
----------------------------------------------------------------------

MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(jugador, idPase, comprado)
	if not comprado then
		return
	end
	for clave, pase in AJUSTES.pases do
		if pase.id == idPase then
			jugador:SetAttribute("Pase_" .. clave, true)
			avisar(jugador, "🎉 ¡Has comprado " .. pase.nombre .. "!", Color3.fromRGB(40, 160, 80))
		end
	end
end)

----------------------------------------------------------------------
-- 🖱️ EL JUGADOR PULSA EL BOTÓN DE COMPRAR
----------------------------------------------------------------------

evento.OnServerEvent:Connect(function(jugador, clave)
	local ahora = os.clock()
	if ahora - (ultimoPedido[jugador] or -100) < AJUSTES.segundosEntrePedidos then
		return
	end
	ultimoPedido[jugador] = ahora

	-- Comprobamos que lo que nos manda tiene sentido (¡nunca nos fiamos de la pantalla!)
	if type(clave) ~= "string" then
		return
	end
	local pase = AJUSTES.pases[clave]
	if not pase then
		return
	end

	if tiene(jugador, clave) then
		avisar(jugador, "Ya tienes " .. pase.nombre .. " 😄", Color3.fromRGB(90, 90, 120))
		return
	end

	if pase.id == 0 then
		if modoPrueba then
			jugador:SetAttribute("Pase_" .. clave, true) -- solo mientras dura esta partida de prueba
			avisar(jugador, "🧪 Modo prueba: ¡tienes " .. pase.nombre .. "! (gratis en Studio)", Color3.fromRGB(90, 90, 160))
		else
			avisar(jugador, "Todavía no está activada la compra. ¡Pídeselo a un adulto!", Color3.fromRGB(200, 60, 60))
		end
		return
	end

	MarketplaceService:PromptGamePassPurchase(jugador, pase.id) -- ventana de compra de Roblox
end)

print("💎 Pases de Robux listos.")
