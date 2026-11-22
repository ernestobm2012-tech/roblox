--[[
	🚀 SALTO A CHECKPOINT (con Robux)
	Deja volver a un checkpoint que ya has alcanzado. Cada salto se paga con un
	"Producto de desarrollador" de Roblox que cuesta 5 Robux (el precio se pone en la web
	de Roblox, no aquí: mira el README).

	Cómo funciona:
	  1. El jugador pulsa el botón "🚀 Saltar a checkpoint" y elige un nivel (solo hasta el más alto
	     que haya alcanzado).
	  2. Roblox le enseña su ventana de compra y le deja confirmar o cancelar.
	  3. Si compra, recibe un "crédito de salto" que se GUARDA (así nunca se pierde lo pagado),
	     y se usa al momento para llevarlo a su checkpoint.

	⚠️ MIENTRAS "idDelProducto" SEA 0 NO SE COBRA NADA:
	   - En Roblox Studio el salto es GRATIS (modo prueba) para poder probarlo.
	   - En el juego publicado el botón dice que la compra aún no está activada.

	📋 DÓNDE VA: en Roblox Studio, dentro de ServerScriptService, como "Script".
	(Habla con el script Niveles con el atributo "SaltarANivel" y con la pantalla con un RemoteEvent.
	 Es el ÚNICO script que debe usar ProcessReceipt.)
]]

local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")
local DataStoreService = game:GetService("DataStoreService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

-- ⚙️ AJUSTES
local AJUSTES = {
	-- ⚠️ El número (ID) del Producto de desarrollador "Saltar checkpoint" de 5 Robux.
	-- Se crea en la web de Roblox (create.roblox.com). Mientras sea 0, no se cobra nada.
	idDelProducto = 0,
	precioDePrueba = 5, -- solo para enseñar el precio en el modo prueba de Studio
	nombreDelGuardado = "MiMundoSaltos_v1", -- donde se guardan los saltos pagados
	segundosEntreSaltos = 2, -- para que nadie pulse mil veces seguidas
	intentos = 3, -- cuántas veces lo intenta si Roblox falla
}

local hayProducto = AJUSTES.idDelProducto ~= 0
local modoPrueba = not hayProducto and RunService:IsStudio()

local almacen = DataStoreService:GetDataStore(AJUSTES.nombreDelGuardado)
local pedido = {} -- pedido[jugador] = nivel al que quiere ir
local ultimoPedido = {}

-- El botón de la pantalla nos avisa con este "mensajero"
local evento = Instance.new("RemoteEvent")
evento.Name = "SaltarCheckpoint"
evento.Parent = ReplicatedStorage

----------------------------------------------------------------------
-- 🧰 HERRAMIENTAS
----------------------------------------------------------------------

local function clave(userId)
	return "Jugador_" .. userId
end

-- Enseña un mensajito en la pantalla de un jugador
local function avisar(jugador, texto, color)
	local pantallaJugador = jugador:FindFirstChild("PlayerGui")
	if not pantallaJugador then
		return
	end
	local viejo = pantallaJugador:FindFirstChild("AvisoSalto")
	if viejo then
		viejo:Destroy()
	end

	local pantalla = Instance.new("ScreenGui")
	pantalla.Name = "AvisoSalto"
	pantalla.ResetOnSpawn = false
	pantalla.Parent = pantallaJugador

	local mensaje = Instance.new("TextLabel")
	mensaje.Size = UDim2.fromScale(0.55, 0.09)
	mensaje.Position = UDim2.fromScale(0.5, 0.62)
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

-- Le pide al script Niveles que lleve al jugador a su checkpoint
local function hacerSalto(jugador, nivel)
	jugador:SetAttribute("SaltarANivel", nivel)
end

----------------------------------------------------------------------
-- 💰 SALTOS PAGADOS (créditos guardados)
----------------------------------------------------------------------

local function leerCreditos(userId)
	for intento = 1, AJUSTES.intentos do
		local funciono, datos = pcall(function()
			return almacen:GetAsync(clave(userId))
		end)
		if funciono then
			return (datos and datos.creditos) or 0
		end
		warn("🚀 No pude leer los saltos pagados (intento " .. intento .. "): " .. tostring(datos))
		task.wait(2)
	end
	return nil
end

-- Gasta 1 salto pagado. Devuelve true si lo ha conseguido.
local function gastarCredito(jugador)
	for intento = 1, AJUSTES.intentos do
		local funciono, nuevo = pcall(function()
			return almacen:UpdateAsync(clave(jugador.UserId), function(datos)
				if not datos or (datos.creditos or 0) < 1 then
					return nil -- no hay saltos: no cambiamos nada
				end
				datos.creditos -= 1
				return datos
			end)
		end)
		if funciono then
			if nuevo then
				jugador:SetAttribute("CreditosSalto", nuevo.creditos)
				return true
			end
			return false
		end
		task.wait(1)
	end
	return false
end

-- Si el jugador estaba esperando para saltar y ya tiene un salto pagado, lo hacemos
local function completarPedido(jugador)
	local nivel = pedido[jugador]
	if not nivel then
		return
	end
	pedido[jugador] = nil
	if (jugador:GetAttribute("CreditosSalto") or 0) < 1 then
		return
	end
	if gastarCredito(jugador) then
		hacerSalto(jugador, nivel)
	else
		avisar(jugador, "No he podido usar tu salto. ¡Inténtalo otra vez!", Color3.fromRGB(200, 60, 60))
	end
end

Players.PlayerAdded:Connect(function(jugador)
	if not hayProducto then
		return
	end
	task.spawn(function()
		local creditos = leerCreditos(jugador.UserId)
		if creditos and jugador.Parent then
			jugador:SetAttribute("CreditosSalto", creditos)
		end
	end)
end)
for _, jugador in Players:GetPlayers() do
	if hayProducto then
		task.spawn(function()
			local creditos = leerCreditos(jugador.UserId)
			if creditos and jugador.Parent then
				jugador:SetAttribute("CreditosSalto", creditos)
			end
		end)
	end
end

Players.PlayerRemoving:Connect(function(jugador)
	pedido[jugador] = nil
	ultimoPedido[jugador] = nil
end)

----------------------------------------------------------------------
-- 🧾 EL PAGO (Roblox nos avisa cuando alguien compra)
----------------------------------------------------------------------

if hayProducto then
	-- Que la pantalla enseñe el precio real del producto
	task.spawn(function()
		local funciono, info = pcall(function()
			return MarketplaceService:GetProductInfo(AJUSTES.idDelProducto, Enum.InfoType.Product)
		end)
		if funciono and info then
			workspace:SetAttribute("PrecioSalto", info.PriceInRobux)
		else
			warn("🚀 No encuentro el producto " .. AJUSTES.idDelProducto .. ". ¿Está bien el número (ID)?")
		end
	end)

	-- Si cancela la compra, olvidamos lo que quería
	MarketplaceService.PromptProductPurchaseFinished:Connect(function(userId, _, comprado)
		if not comprado then
			local jugador = Players:GetPlayerByUserId(userId)
			if jugador then
				pedido[jugador] = nil
			end
		end
	end)

	MarketplaceService.ProcessReceipt = function(recibo)
		if recibo.ProductId ~= AJUSTES.idDelProducto then
			return Enum.ProductPurchaseDecision.NotProcessedYet
		end

		-- Apuntamos el salto pagado (y el número del recibo, para no contarlo dos veces)
		local funciono, resultado = pcall(function()
			return almacen:UpdateAsync(clave(recibo.PlayerId), function(datos)
				datos = datos or { creditos = 0, recibos = {} }
				datos.recibos = datos.recibos or {}
				if not table.find(datos.recibos, recibo.PurchaseId) then
					table.insert(datos.recibos, recibo.PurchaseId)
					datos.creditos = (datos.creditos or 0) + 1
					if #datos.recibos > 100 then
						table.remove(datos.recibos, 1)
					end
				end
				return datos
			end)
		end)
		if not funciono or not resultado then
			return Enum.ProductPurchaseDecision.NotProcessedYet -- Roblox lo volverá a intentar
		end

		local jugador = Players:GetPlayerByUserId(recibo.PlayerId)
		if jugador then
			jugador:SetAttribute("CreditosSalto", resultado.creditos)
			task.spawn(completarPedido, jugador)
		end
		return Enum.ProductPurchaseDecision.PurchaseGranted
	end
elseif modoPrueba then
	workspace:SetAttribute("PrecioSalto", AJUSTES.precioDePrueba)
	workspace:SetAttribute("SaltoModoPrueba", true)
	print("🚀 Salto a checkpoint en MODO PRUEBA (gratis en Studio). Falta poner el ID del producto.")
else
	warn("🚀 Falta el ID del producto de 5 Robux (idDelProducto). El salto no está activado.")
end

----------------------------------------------------------------------
-- 🖱️ EL JUGADOR PULSA EL BOTÓN
----------------------------------------------------------------------

evento.OnServerEvent:Connect(function(jugador, nivel)
	-- Un jugador no puede pedir cosas muy seguidas
	local ahora = os.clock()
	if ahora - (ultimoPedido[jugador] or -100) < AJUSTES.segundosEntreSaltos then
		return
	end
	ultimoPedido[jugador] = ahora

	-- Comprobamos que lo que nos manda tiene sentido (¡nunca nos fiamos de la pantalla!)
	if type(nivel) ~= "number" or nivel ~= nivel then
		return
	end
	nivel = math.floor(nivel)
	local maximo = jugador:GetAttribute("Nivel") or 1
	if nivel < 1 or nivel > maximo then
		avisar(jugador, "Solo puedes ir a niveles que ya has alcanzado (del 1 al " .. maximo .. ")", Color3.fromRGB(200, 60, 60))
		return
	end

	if modoPrueba then
		hacerSalto(jugador, nivel)
		avisar(jugador, "🧪 Modo prueba: salto gratis", Color3.fromRGB(90, 90, 160))
		return
	end
	if not hayProducto then
		avisar(jugador, "Todavía no está activada la compra. ¡Pídeselo a un adulto!", Color3.fromRGB(200, 60, 60))
		return
	end

	pedido[jugador] = nivel
	if (jugador:GetAttribute("CreditosSalto") or 0) >= 1 then
		completarPedido(jugador) -- ya tenía un salto pagado
	else
		MarketplaceService:PromptProductPurchase(jugador, AJUSTES.idDelProducto) -- ventana de compra de Roblox
	end
end)

print("🚀 Salto a checkpoint listo.")
