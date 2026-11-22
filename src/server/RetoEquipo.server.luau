--[[
	🤝 RETO EN EQUIPO
	Te juntas con UN AMIGO de Roblox que esté jugando y tenéis que llegar LOS DOS al nivel 100.
	  - Uno invita y el otro acepta (solo se puede con amigos de Roblox).
	  - Mientras sois pareja, cada uno ve en la pantalla en qué nivel va el otro.
	  - Cuando los dos llegáis a la meta (nivel 100), ¡los dos ganáis monedas! 🪙
	  - Después viene la siguiente meta: 200, 300... hasta el nivel 500.
	Si uno sale del juego o pulsa "Dejar el equipo", se acaba el equipo.

	Se maneja desde el botón "🏆 Reto semanal" (sección "🤝 Reto en equipo").

	📋 DÓNDE VA: en Roblox Studio, dentro de ServerScriptService, como "Script".
	(Habla con la pantalla con el RemoteEvent "EquipoAccion" y con atributos del jugador:
	"Pareja", "ParejaNombre", "ParejaMeta" y "EquipoInvita". Lee "Nivel" y suma al marcador de Monedas.)
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

-- ⚙️ AJUSTES: ¡cambia estos valores y mira qué pasa!
local AJUSTES = {
	nivelesPorMeta = 100, -- cada meta del equipo está 100 niveles más arriba
	nivelMaximo = 500,
	monedasPorMeta = 200, -- monedas para CADA uno al cumplir una meta
	segundosParaAceptar = 60,
	segundosEntreInvitaciones = 3,
}

local evento = Instance.new("RemoteEvent")
evento.Name = "EquipoAccion"
evento.Parent = ReplicatedStorage

local invitaciones = {} -- invitaciones[invitado] = { de = jugador, hasta = tiempo }
local ultimaInvitacion = {}
local premiando = {}

local function avisar(jugador, texto, color)
	local pantallaJugador = jugador:FindFirstChild("PlayerGui")
	if not pantallaJugador then
		return
	end
	local viejo = pantallaJugador:FindFirstChild("AvisoEquipo")
	if viejo then
		viejo:Destroy()
	end
	local pantalla = Instance.new("ScreenGui")
	pantalla.Name = "AvisoEquipo"
	pantalla.ResetOnSpawn = false
	pantalla.Parent = pantallaJugador
	local mensaje = Instance.new("TextLabel")
	mensaje.Size = UDim2.fromScale(0.65, 0.1)
	mensaje.Position = UDim2.fromScale(0.5, 0.25)
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
			TweenService:Create(mensaje, TweenInfo.new(0.5), { TextTransparency = 1, BackgroundTransparency = 1 }):Play()
			task.wait(0.6)
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

local function nivelDe(jugador)
	return jugador:GetAttribute("Nivel") or 1
end

-- La siguiente meta: el siguiente "ciento" por encima de los dos
local function calcularMeta(a, b)
	local mayor = math.max(nivelDe(a), nivelDe(b))
	return (mayor // AJUSTES.nivelesPorMeta + 1) * AJUSTES.nivelesPorMeta
end

local function parejaDe(jugador)
	local id = jugador:GetAttribute("Pareja")
	return id and Players:GetPlayerByUserId(id)
end

local function limpiar(jugador)
	jugador:SetAttribute("Pareja", nil)
	jugador:SetAttribute("ParejaNombre", nil)
	jugador:SetAttribute("ParejaMeta", nil)
end

local function disolver(jugador, motivo)
	local otro = parejaDe(jugador)
	limpiar(jugador)
	if otro then
		limpiar(otro)
		avisar(otro, motivo, Color3.fromRGB(180, 100, 60))
	end
end

local function formarEquipo(a, b)
	local meta = calcularMeta(a, b)
	if meta > AJUSTES.nivelMaximo then
		avisar(a, "¡Los dos ya estáis en la cima! No quedan metas 🏔️", Color3.fromRGB(60, 100, 180))
		avisar(b, "¡Los dos ya estáis en la cima! No quedan metas 🏔️", Color3.fromRGB(60, 100, 180))
		return
	end
	a:SetAttribute("Pareja", b.UserId)
	a:SetAttribute("ParejaNombre", b.DisplayName)
	a:SetAttribute("ParejaMeta", meta)
	b:SetAttribute("Pareja", a.UserId)
	b:SetAttribute("ParejaNombre", a.DisplayName)
	b:SetAttribute("ParejaMeta", meta)
	avisar(a, "🤝 ¡Equipo con " .. b.DisplayName .. "! Meta: nivel " .. meta, Color3.fromRGB(60, 140, 90))
	avisar(b, "🤝 ¡Equipo con " .. a.DisplayName .. "! Meta: nivel " .. meta, Color3.fromRGB(60, 140, 90))
end

-- ¿Han llegado los dos a la meta?
local function comprobar(jugador)
	local otro = parejaDe(jugador)
	local meta = jugador:GetAttribute("ParejaMeta")
	if not otro or not meta or premiando[jugador] or premiando[otro] then
		return
	end
	if nivelDe(jugador) >= meta and nivelDe(otro) >= meta then
		premiando[jugador] = true
		premiando[otro] = true
		for _, quien in { jugador, otro } do
			sumarMonedas(quien, AJUSTES.monedasPorMeta)
			quien:SetAttribute("Estad_retosEquipo", (quien:GetAttribute("Estad_retosEquipo") or 0) + 1)
			avisar(quien, "🏆 ¡LOS DOS HABÉIS LLEGADO AL NIVEL " .. meta .. "! +" .. AJUSTES.monedasPorMeta .. " 🪙", Color3.fromRGB(190, 130, 0))
		end
		local siguiente = meta + AJUSTES.nivelesPorMeta
		if siguiente > AJUSTES.nivelMaximo then
			limpiar(jugador)
			limpiar(otro)
		else
			jugador:SetAttribute("ParejaMeta", siguiente)
			otro:SetAttribute("ParejaMeta", siguiente)
		end
		premiando[jugador] = nil
		premiando[otro] = nil
	end
end

local function vigilar(jugador)
	jugador.AttributeChanged:Connect(function(nombre)
		if nombre == "Nivel" or nombre == "ParejaMeta" then
			comprobar(jugador)
		end
	end)
end
Players.PlayerAdded:Connect(vigilar)
for _, jugador in Players:GetPlayers() do
	vigilar(jugador)
end

Players.PlayerRemoving:Connect(function(jugador)
	disolver(jugador, "Tu compañero se fue del juego 👋 El equipo se ha acabado")
	invitaciones[jugador] = nil
	ultimaInvitacion[jugador] = nil
	premiando[jugador] = nil
	for invitado, datos in invitaciones do
		if datos.de == jugador then
			invitaciones[invitado] = nil
			invitado:SetAttribute("EquipoInvita", nil)
			invitado:SetAttribute("EquipoInvitaNombre", nil)
		end
	end
end)

evento.OnServerEvent:Connect(function(jugador, accion, valor)
	if type(accion) ~= "string" then
		return
	end

	if accion == "invitar" and type(valor) == "number" then
		local ahora = os.clock()
		if ultimaInvitacion[jugador] and ahora - ultimaInvitacion[jugador] < AJUSTES.segundosEntreInvitaciones then
			return
		end
		ultimaInvitacion[jugador] = ahora
		local otro = Players:GetPlayerByUserId(valor)
		if not otro or otro == jugador or jugador:GetAttribute("Pareja") or otro:GetAttribute("Pareja") then
			avisar(jugador, "Ahora no se puede invitar a esa persona", Color3.fromRGB(200, 60, 60))
			return
		end
		-- Solo amigos de Roblox
		local bien, esAmigo = pcall(function()
			return jugador:IsFriendsWith(otro.UserId)
		end)
		if not bien or not esAmigo then
			avisar(jugador, "Solo puedes hacer equipo con tus amigos de Roblox 👫", Color3.fromRGB(200, 60, 60))
			return
		end
		invitaciones[otro] = { de = jugador, hasta = os.clock() + AJUSTES.segundosParaAceptar }
		otro:SetAttribute("EquipoInvita", jugador.UserId)
		otro:SetAttribute("EquipoInvitaNombre", jugador.DisplayName)
		avisar(jugador, "📨 Invitación enviada a " .. otro.DisplayName, Color3.fromRGB(60, 100, 180))
		avisar(otro, "🤝 " .. jugador.DisplayName .. " quiere hacer equipo contigo (mira 🏆 Reto semanal)", Color3.fromRGB(60, 100, 180))
		task.delay(AJUSTES.segundosParaAceptar, function()
			local datos = invitaciones[otro]
			if datos and datos.de == jugador and os.clock() >= datos.hasta then
				invitaciones[otro] = nil
				if otro.Parent then
					otro:SetAttribute("EquipoInvita", nil)
					otro:SetAttribute("EquipoInvitaNombre", nil)
				end
			end
		end)

	elseif accion == "aceptar" then
		local datos = invitaciones[jugador]
		if not datos or os.clock() > datos.hasta or not datos.de.Parent then
			return
		end
		local otro = datos.de
		invitaciones[jugador] = nil
		jugador:SetAttribute("EquipoInvita", nil)
		jugador:SetAttribute("EquipoInvitaNombre", nil)
		if jugador:GetAttribute("Pareja") or otro:GetAttribute("Pareja") then
			return
		end
		formarEquipo(otro, jugador)

	elseif accion == "rechazar" then
		invitaciones[jugador] = nil
		jugador:SetAttribute("EquipoInvita", nil)
		jugador:SetAttribute("EquipoInvitaNombre", nil)

	elseif accion == "salir" then
		if jugador:GetAttribute("Pareja") then
			disolver(jugador, jugador.DisplayName .. " ha dejado el equipo")
			avisar(jugador, "Has dejado el equipo", Color3.fromRGB(120, 120, 130))
		end
	end
end)

print("🤝 Reto en equipo listo.")
