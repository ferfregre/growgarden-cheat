-- Dev Menu v2 (mobile + PC) — для тестирования СОБСТВЕННОЙ игры
-- Тип скрипта: LocalScript
-- Место: StarterPlayer -> StarterPlayerScripts
-- Открыть/закрыть: кнопка ✦ слева или RightShift (ПК)

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer

-- Доступ: только Studio или перечисленные UserId (впишите свой)
local DEV_IDS = {}
if not (RunService:IsStudio() or table.find(DEV_IDS, player.UserId)) then
	return
end

local IS_TOUCH = UIS.TouchEnabled
local ROW_H = IS_TOUCH and 52 or 44

local C = {
	bg = Color3.fromRGB(16, 14, 28),
	panel = Color3.fromRGB(30, 27, 50),
	panel2 = Color3.fromRGB(45, 41, 72),
	text = Color3.fromRGB(245, 243, 255),
	sub = Color3.fromRGB(150, 145, 190),
	pink = Color3.fromRGB(255, 70, 160),
	violet = Color3.fromRGB(125, 90, 255),
	cyan = Color3.fromRGB(0, 220, 255),
	green = Color3.fromRGB(70, 220, 130),
}

-- ========== Хелперы ==========
local function new(class, props, parent)
	local inst = Instance.new(class)
	for k, v in props do
		inst[k] = v
	end
	inst.Parent = parent
	return inst
end

local function corner(parent, r)
	return new("UICorner", {CornerRadius = UDim.new(0, r)}, parent)
end

local function tween(inst, t, props, style, dir)
	local tw = TweenService:Create(inst, TweenInfo.new(
		t, style or Enum.EasingStyle.Quint, dir or Enum.EasingDirection.Out
	), props)
	tw:Play()
	return tw
end

local function isPress(input)
	return input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch
end

local function gradient(parent, a, b, rot)
	return new("UIGradient", {
		Color = ColorSequence.new(a, b),
		Rotation = rot or 0,
	}, parent)
end

-- ========== Состояние ==========
local settings = {
	WalkSpeed = 16,
	JumpPower = 50,
	Gravity = workspace.Gravity,
	FOV = workspace.CurrentCamera.FieldOfView,
	FlySpeed = 60,
}

local function getHumanoid()
	local char = player.Character
	return char and char:FindFirstChildOfClass("Humanoid")
end

local function applyCharacterSettings()
	local hum = getHumanoid()
	if hum then
		hum.WalkSpeed = settings.WalkSpeed
		hum.UseJumpPower = true
		hum.JumpPower = settings.JumpPower
	end
end

-- ========== Корневой GUI ==========
local gui = new("ScreenGui", {
	Name = "DevMenu",
	ResetOnSpawn = false,
	DisplayOrder = 100,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
}, player:WaitForChild("PlayerGui"))

-- Окно (CanvasGroup — чтобы плавно гасить всё содержимое разом)
local window = new("CanvasGroup", {
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.fromScale(0.5, 0.5),
	Size = UDim2.fromScale(0.9, 0.78),
	BackgroundColor3 = C.bg,
	BorderSizePixel = 0,
	GroupTransparency = 1,
	Visible = false,
}, gui)
corner(window, 18)
new("UISizeConstraint", {
	MinSize = Vector2.new(260, 300),
	MaxSize = Vector2.new(400, 540),
}, window)
local winScale = new("UIScale", {Scale = 0.9}, window)

local stroke = new("UIStroke", {
	Thickness = 2.5,
	ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
	Color = Color3.new(1, 1, 1),
}, window)
local strokeGrad = new("UIGradient", {
	Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, C.pink),
		ColorSequenceKeypoint.new(0.5, C.violet),
		ColorSequenceKeypoint.new(1, C.cyan),
	}),
}, stroke)

-- Заголовок
local header = new("Frame", {
	Size = UDim2.new(1, 0, 0, 52),
	BackgroundColor3 = C.panel,
	BorderSizePixel = 0,
}, window)

local title = new("TextLabel", {
	Position = UDim2.fromOffset(16, 0),
	Size = UDim2.new(1, -70, 1, 0),
	BackgroundTransparency = 1,
	Text = "✦ DEV MENU",
	Font = Enum.Font.GothamBlack,
	TextSize = 20,
	TextXAlignment = Enum.TextXAlignment.Left,
	TextColor3 = C.text,
}, header)

local closeBtn = new("TextButton", {
	AnchorPoint = Vector2.new(1, 0.5),
	Position = UDim2.new(1, -10, 0.5, 0),
	Size = UDim2.fromOffset(34, 34),
	BackgroundColor3 = C.panel2,
	AutoButtonColor = false,
	Text = "✕",
	Font = Enum.Font.GothamBold,
	TextSize = 16,
	TextColor3 = C.text,
}, header)
corner(closeBtn, 17)

-- Вкладки
local tabBar = new("Frame", {
	Position = UDim2.fromOffset(0, 52),
	Size = UDim2.new(1, 0, 0, 44),
	BackgroundTransparency = 1,
}, window)

local TAB_NAMES = {"Игрок", "Мир", "Тест"}
local indicator = new("Frame", {
	AnchorPoint = Vector2.new(0, 1),
	Position = UDim2.fromScale(0, 1),
	Size = UDim2.new(1 / #TAB_NAMES, 0, 0, 3),
	BackgroundColor3 = Color3.new(1, 1, 1),
	BorderSizePixel = 0,
}, tabBar)
gradient(indicator, C.pink, C.cyan)

local pageHolder = new("Frame", {
	Position = UDim2.fromOffset(10, 102),
	Size = UDim2.new(1, -20, 1, -112),
	BackgroundTransparency = 1,
	ClipsDescendants = true,
}, window)

local pages, tabButtons = {}, {}

local function createPage()
	local page = new("ScrollingFrame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 3,
		ScrollBarImageColor3 = C.violet,
		CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollingDirection = Enum.ScrollingDirection.Y,
		Visible = false,
	}, pageHolder)
	new("UIListLayout", {Padding = UDim.new(0, 10), SortOrder = Enum.SortOrder.LayoutOrder}, page)
	new("UIPadding", {PaddingTop = UDim.new(0, 6), PaddingBottom = UDim.new(0, 12), PaddingRight = UDim.new(0, 6)}, page)
	table.insert(pages, page)
	return page
end

local currentTab = 0
local function selectTab(i)
	if i == currentTab then return end
	currentTab = i
	tween(indicator, 0.35, {Position = UDim2.new((i - 1) / #TAB_NAMES, 0, 1, 0)}, Enum.EasingStyle.Back)
	for idx, btn in tabButtons do
		tween(btn, 0.2, {TextColor3 = idx == i and C.text or C.sub})
	end
	for idx, page in pages do
		page.Visible = idx == i
		if idx == i then
			page.Position = UDim2.fromOffset(30, 0)
			tween(page, 0.35, {Position = UDim2.fromOffset(0, 0)})
		end
	end
end

for i, name in TAB_NAMES do
	local b = new("TextButton", {
		Position = UDim2.new((i - 1) / #TAB_NAMES, 0, 0, 0),
		Size = UDim2.new(1 / #TAB_NAMES, 0, 1, -3),
		BackgroundTransparency = 1,
		Text = name,
		Font = Enum.Font.GothamBold,
		TextSize = 15,
		TextColor3 = C.sub,
	}, tabBar)
	b.Activated:Connect(function() selectTab(i) end)
	tabButtons[i] = b
	createPage()
end

-- ========== Уведомления ==========
local toastLabel = new("TextLabel", {
	AnchorPoint = Vector2.new(0.5, 0),
	Position = UDim2.new(0.5, 0, 0, -70),
	Size = UDim2.fromOffset(280, 44),
	BackgroundColor3 = C.panel,
	Text = "",
	Font = Enum.Font.GothamBold,
	TextSize = 15,
	TextColor3 = C.text,
	ZIndex = 50,
}, gui)
corner(toastLabel, 12)
local toastStroke = new("UIStroke", {Thickness = 2, Color = C.cyan}, toastLabel)
local toastToken = 0

local function toast(text, color)
	toastToken += 1
	local my = toastToken
	toastLabel.Text = text
	toastStroke.Color = color or C.cyan
	tween(toastLabel, 0.45, {Position = UDim2.new(0.5, 0, 0, 14)}, Enum.EasingStyle.Back)
	task.delay(2, function()
		if my == toastToken then
			tween(toastLabel, 0.3, {Position = UDim2.new(0.5, 0, 0, -70)}, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
		end
	end)
end

-- ========== Компоненты ==========
local function addSection(page, text)
	new("TextLabel", {
		Size = UDim2.new(1, 0, 0, 22),
		BackgroundTransparency = 1,
		Text = string.upper(text),
		Font = Enum.Font.GothamBold,
		TextSize = 12,
		TextColor3 = C.sub,
		TextXAlignment = Enum.TextXAlignment.Left,
	}, page)
end

local function addToggle(page, text, default, callback)
	local state = default
	local row = new("TextButton", {
		Size = UDim2.new(1, 0, 0, ROW_H),
		BackgroundColor3 = C.panel,
		AutoButtonColor = false,
		Text = "",
		BorderSizePixel = 0,
	}, page)
	corner(row, 12)

	new("TextLabel", {
		Position = UDim2.fromOffset(14, 0),
		Size = UDim2.new(1, -84, 1, 0),
		BackgroundTransparency = 1,
		Text = text,
		Font = Enum.Font.GothamBold,
		TextSize = 15,
		TextColor3 = C.text,
		TextXAlignment = Enum.TextXAlignment.Left,
	}, row)

	local track = new("Frame", {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -14, 0.5, 0),
		Size = UDim2.fromOffset(52, 28),
		BackgroundColor3 = C.panel2,
	}, row)
	corner(track, 14)

	local knob = new("Frame", {
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 3, 0.5, 0),
		Size = UDim2.fromOffset(22, 22),
		BackgroundColor3 = Color3.new(1, 1, 1),
	}, track)
	corner(knob, 11)

	local function render(animate)
		local props = {BackgroundColor3 = state and C.green or C.panel2}
		local kProps = {Position = state and UDim2.new(1, -25, 0.5, 0) or UDim2.new(0, 3, 0.5, 0)}
		if animate then
			tween(track, 0.25, props)
			tween(knob, 0.35, kProps, Enum.EasingStyle.Back)
		else
			track.BackgroundColor3 = props.BackgroundColor3
			knob.Position = kProps.Position
		end
	end
	render(false)

	row.Activated:Connect(function()
		state = not state
		render(true)
		callback(state)
	end)

	-- setter для программного переключения (например, при респавне)
	return function(v, silent)
		state = v
		render(true)
		if not silent then callback(v) end
	end
end

local function addButton(page, text, callback)
	local btn = new("TextButton", {
		Size = UDim2.new(1, 0, 0, ROW_H),
		BackgroundTransparency = 1,
		Text = "",
		ClipsDescendants = true,
	}, page)
	local bg = new("Frame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = Color3.new(1, 1, 1),
		BorderSizePixel = 0,
		ZIndex = 1,
	}, btn)
	corner(bg, 12)
	local grad = gradient(bg, C.pink, C.violet)
	local label = new("TextLabel", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		Text = text,
		Font = Enum.Font.GothamBlack,
		TextSize = 16,
		TextColor3 = Color3.new(1, 1, 1),
		ZIndex = 3,
	}, btn)
	local flash = new("Frame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = Color3.new(1, 1, 1),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ZIndex = 2,
	}, btn)
	corner(flash, 12)
	local sc = new("UIScale", {}, btn)

	btn.MouseEnter:Connect(function()
		tween(grad, 0.4, {Offset = Vector2.new(0.25, 0)})
	end)
	btn.MouseLeave:Connect(function()
		tween(grad, 0.4, {Offset = Vector2.new(0, 0)})
	end)
	btn.InputBegan:Connect(function(input)
		if isPress(input) then
			tween(sc, 0.12, {Scale = 0.96})
		end
	end)
	btn.InputEnded:Connect(function(input)
		if isPress(input) then
			tween(sc, 0.3, {Scale = 1}, Enum.EasingStyle.Back)
		end
	end)
	btn.Activated:Connect(function()
		flash.BackgroundTransparency = 0.6
		tween(flash, 0.4, {BackgroundTransparency = 1})
		callback(label)
	end)
	return btn
end

local function addSlider(page, text, min, max, default, callback, suffix)
	suffix = suffix or ""
	local row = new("Frame", {
		Size = UDim2.new(1, 0, 0, 68),
		BackgroundColor3 = C.panel,
		BorderSizePixel = 0,
	}, page)
	corner(row, 12)

	new("TextLabel", {
		Position = UDim2.fromOffset(14, 6),
		Size = UDim2.new(1, -100, 0, 24),
		BackgroundTransparency = 1,
		Text = text,
		Font = Enum.Font.GothamBold,
		TextSize = 15,
		TextColor3 = C.text,
		TextXAlignment = Enum.TextXAlignment.Left,
	}, row)

	local valueLabel = new("TextLabel", {
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -14, 0, 6),
		Size = UDim2.fromOffset(80, 24),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamBlack,
		TextSize = 15,
		TextColor3 = C.cyan,
		TextXAlignment = Enum.TextXAlignment.Right,
	}, row)

	-- увеличенная зона касания
	local hit = new("TextButton", {
		Position = UDim2.fromOffset(14, 34),
		Size = UDim2.new(1, -28, 0, 28),
		BackgroundTransparency = 1,
		Text = "",
	}, row)

	local bar = new("Frame", {
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.fromScale(0, 0.5),
		Size = UDim2.new(1, 0, 0, 8),
		BackgroundColor3 = C.panel2,
		BorderSizePixel = 0,
	}, hit)
	corner(bar, 4)

	local fill = new("Frame", {
		Size = UDim2.fromScale(0, 1),
		BackgroundColor3 = Color3.new(1, 1, 1),
		BorderSizePixel = 0,
	}, bar)
	corner(fill, 4)
	gradient(fill, C.pink, C.cyan)

	local knob = new("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0, 0.5),
		Size = UDim2.fromOffset(20, 20),
		BackgroundColor3 = Color3.new(1, 1, 1),
		ZIndex = 2,
	}, bar)
	corner(knob, 10)
	new("UIStroke", {Thickness = 3, Color = C.violet}, knob)

	local value
	local function setValue(v, silent)
		v = math.clamp(math.round(v), min, max)
		local a = (v - min) / (max - min)
		tween(fill, 0.08, {Size = UDim2.fromScale(a, 1)}, Enum.EasingStyle.Linear)
		tween(knob, 0.08, {Position = UDim2.fromScale(a, 0.5)}, Enum.EasingStyle.Linear)
		valueLabel.Text = tostring(v) .. suffix
		if v ~= value then
			value = v
			if not silent then callback(v) end
		end
	end

	local active
	local function updateFromX(x)
		local a = math.clamp((x - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
		setValue(min + a * (max - min))
	end

	hit.InputBegan:Connect(function(input)
		if isPress(input) and not active then
			active = input
			page.ScrollingEnabled = false -- не даём списку прокручиваться
			tween(knob, 0.2, {Size = UDim2.fromOffset(28, 28)}, Enum.EasingStyle.Back)
			updateFromX(input.Position.X)
		end
	end)
	UIS.InputChanged:Connect(function(input)
		if active and (input == active or input.UserInputType == Enum.UserInputType.MouseMovement) then
			updateFromX(input.Position.X)
		end
	end)
	UIS.InputEnded:Connect(function(input)
		if input == active then
			active = nil
			page.ScrollingEnabled = true
			tween(knob, 0.25, {Size = UDim2.fromOffset(20, 20)}, Enum.EasingStyle.Back)
		end
	end)

	setValue(default, true)
	return setValue
end

-- ========== Полёт ==========
local flyObjects, flyConn = {}, nil
local holdUp, holdDown = false, false

local flyPad = new("Frame", {
	AnchorPoint = Vector2.new(1, 0.5),
	Position = UDim2.new(1, -16, 0.5, 0),
	Size = UDim2.fromOffset(64, 140),
	BackgroundTransparency = 1,
	Visible = false,
}, gui)
new("UIListLayout", {
	Padding = UDim.new(0, 12),
	HorizontalAlignment = Enum.HorizontalAlignment.Center,
}, flyPad)

local function padButton(glyph, setter)
	local b = new("TextButton", {
		Size = UDim2.fromOffset(64, 64),
		BackgroundColor3 = C.panel,
		BackgroundTransparency = 0.15,
		AutoButtonColor = false,
		Text = glyph,
		Font = Enum.Font.GothamBlack,
		TextSize = 24,
		TextColor3 = C.text,
	}, flyPad)
	corner(b, 32)
	new("UIStroke", {Thickness = 2, Color = C.violet}, b)
	b.InputBegan:Connect(function(i)
		if isPress(i) then
			setter(true)
			tween(b, 0.1, {BackgroundColor3 = C.violet})
		end
	end)
	b.InputEnded:Connect(function(i)
		if isPress(i) then
			setter(false)
			tween(b, 0.2, {BackgroundColor3 = C.panel})
		end
	end)
end
padButton("▲", function(v) holdUp = v end)
padButton("▼", function(v) holdDown = v end)

local function stopFly()
	if flyConn then flyConn:Disconnect() flyConn = nil end
	for _, o in flyObjects do o:Destroy() end
	table.clear(flyObjects)
	flyPad.Visible = false
	holdUp, holdDown = false, false
	local hum = getHumanoid()
	if hum then hum.PlatformStand = false end
end

local function startFly()
	stopFly()
	local char = player.Character
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	local hum = getHumanoid()
	if not (hrp and hum) then return false end

	local att = new("Attachment", {}, hrp)
	local lv = new("LinearVelocity", {
		Attachment0 = att,
		MaxForce = math.huge,
		RelativeTo = Enum.ActuatorRelativeTo.World,
		VectorVelocity = Vector3.zero,
	}, hrp)
	flyObjects = {att, lv}
	hum.PlatformStand = true
	flyPad.Visible = IS_TOUCH

	flyConn = RunService.RenderStepped:Connect(function()
		-- MoveDirection работает и с WASD, и с мобильным джойстиком
		local dir = hum.MoveDirection
		local vert = (holdUp and 1 or 0) - (holdDown and 1 or 0)
		if UIS:IsKeyDown(Enum.KeyCode.Space) then vert += 1 end
		if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then vert -= 1 end
		local v = dir + Vector3.yAxis * math.clamp(vert, -1, 1)
		lv.VectorVelocity = v.Magnitude > 0 and v.Unit * settings.FlySpeed or Vector3.zero
	end)
	return true
end

-- ========== Вкладка 1: Игрок ==========
local p1, p2, p3 = pages[1], pages[2], pages[3]

addSection(p1, "Персонаж")
addSlider(p1, "WalkSpeed", 8, 200, settings.WalkSpeed, function(v)
	settings.WalkSpeed = v
	applyCharacterSettings()
end)
addSlider(p1, "JumpPower", 20, 300, settings.JumpPower, function(v)
	settings.JumpPower = v
	applyCharacterSettings()
end)

addSection(p1, "Полёт")
local setFly
setFly = addToggle(p1, "Fly" .. (IS_TOUCH and " (джойстик + ▲▼)" or " (WASD / Space / Shift)"), false, function(on)
	if on then
		if startFly() then
			toast("Полёт включён", C.green)
		else
			toast("Персонаж не найден", C.pink)
			setFly(false, true)
		end
	else
		stopFly()
		toast("Полёт выключен", C.sub)
	end
end)
addSlider(p1, "Fly Speed", 10, 200, settings.FlySpeed, function(v)
	settings.FlySpeed = v
end)

-- ========== Вкладка 2: Мир ==========
addSection(p2, "Окружение")
addSlider(p2, "Gravity", 20, 400, math.round(settings.Gravity), function(v)
	settings.Gravity = v
	workspace.Gravity = v
end)
addSlider(p2, "FOV", 40, 120, math.round(settings.FOV), function(v)
	settings.FOV = v
	workspace.CurrentCamera.FieldOfView = v
end, "°")
addButton(p2, "Сбросить значения", function()
	settings.WalkSpeed, settings.JumpPower = 16, 50
	workspace.Gravity = 196.2
	workspace.CurrentCamera.FieldOfView = 70
	applyCharacterSettings()
	toast("Значения сброшены (перезапустите меню для слайдеров)", C.violet)
end)

-- ========== Вкладка 3: Тест ==========
addSection(p3, "Тест компонентов")

local clicks = 0
addButton(p3, "Тест кнопка", function(label)
	clicks += 1
	label.Text = "Тест кнопка  ×" .. clicks
	toast("Кнопка нажата: " .. clicks, C.pink)
end)

local preview = new("Frame", {
	Size = UDim2.new(1, 0, 0, 70),
	BackgroundColor3 = C.panel,
	BorderSizePixel = 0,
}, p3)
corner(preview, 12)
local swatch = new("Frame", {
	AnchorPoint = Vector2.new(0, 0.5),
	Position = UDim2.new(0, 14, 0.5, 0),
	Size = UDim2.fromOffset(40, 40),
	BackgroundColor3 = Color3.fromHSV(0, 0.8, 1),
}, preview)
corner(swatch, 10)
local previewBar = new("Frame", {
	AnchorPoint = Vector2.new(0, 0.5),
	Position = UDim2.new(0, 68, 0.5, 0),
	Size = UDim2.new(0, 0, 0, 12),
	BackgroundColor3 = Color3.fromHSV(0, 0.8, 1),
	BorderSizePixel = 0,
}, preview)
corner(previewBar, 6)

addSlider(p3, "Тест слайдер", 0, 100, 0, function(v)
	local color = Color3.fromHSV(v / 100, 0.8, 1)
	tween(swatch, 0.15, {
		BackgroundColor3 = color,
		Size = UDim2.fromOffset(30 + v * 0.3, 30 + v * 0.3),
	})
	-- превью-полоса занимает долю от доступной ширины
	local w = preview.AbsoluteSize.X - 68 - 14
	tween(previewBar, 0.15, {
		BackgroundColor3 = color,
		Size = UDim2.fromOffset(math.max(w * v / 100, 0), 12),
	})
end, "%")

addToggle(p3, "Тест переключатель", false, function(on)
	toast(on and "Переключатель: ON" or "Переключатель: OFF", on and C.green or C.sub)
end)

-- ========== Открытие / закрытие ==========
local isOpen = false
local function setOpen(v)
	isOpen = v
	if v then
		window.Visible = true
		tween(winScale, 0.45, {Scale = 1}, Enum.EasingStyle.Back)
		tween(window, 0.3, {GroupTransparency = 0})
	else
		tween(winScale, 0.2, {Scale = 0.9}, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
		local tw = tween(window, 0.2, {GroupTransparency = 1})
		tw.Completed:Once(function()
			if not isOpen then window.Visible = false end
		end)
	end
end

closeBtn.Activated:Connect(function() setOpen(false) end)

-- Плавающая кнопка
local fab = new("TextButton", {
	AnchorPoint = Vector2.new(0, 0.5),
	Position = UDim2.new(0, 14, 0.4, 0),
	Size = UDim2.fromOffset(IS_TOUCH and 58 or 50, IS_TOUCH and 58 or 50),
	BackgroundTransparency = 1,
	Text = "",
}, gui)
local fabBg = new("Frame", {
	Size = UDim2.fromScale(1, 1),
	BackgroundColor3 = Color3.new(1, 1, 1),
	BorderSizePixel = 0,
}, fab)
corner(fabBg, 100)
gradient(fabBg, C.pink, C.violet, 45)
local fabStroke = new("UIStroke", {Thickness = 3, Color = C.cyan, Transparency = 0.2}, fabBg)
new("TextLabel", {
	Size = UDim2.fromScale(1, 1),
	BackgroundTransparency = 1,
	Text = "✦",
	Font = Enum.Font.GothamBlack,
	TextSize = 26,
	TextColor3 = Color3.new(1, 1, 1),
	ZIndex = 2,
}, fab)
local fabScale = new("UIScale", {}, fab)

-- пульсация рамки кнопки
TweenService:Create(fabStroke, TweenInfo.new(1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {
	Thickness = 6,
	Transparency = 0.7,
}):Play()

fab.InputBegan:Connect(function(i)
	if isPress(i) then tween(fabScale, 0.12, {Scale = 0.88}) end
end)
fab.InputEnded:Connect(function(i)
	if isPress(i) then tween(fabScale, 0.35, {Scale = 1}, Enum.EasingStyle.Back) end
end)
fab.Activated:Connect(function() setOpen(not isOpen) end)

UIS.InputBegan:Connect(function(input, processed)
	if not processed and input.KeyCode == Enum.KeyCode.RightShift then
		setOpen(not isOpen)
	end
end)

-- ========== Перетаскивание окна за заголовок ==========
do
	local drag, startInput, startPos
	header.InputBegan:Connect(function(input)
		if isPress(input) and not drag then
			drag, startInput, startPos = input, input.Position, window.Position
		end
	end)
	UIS.InputChanged:Connect(function(input)
		if drag and (input == drag or input.UserInputType == Enum.UserInputType.MouseMovement) then
			local d = input.Position - startInput
			window.Position = UDim2.new(
				startPos.X.Scale, startPos.X.Offset + d.X,
				startPos.Y.Scale, startPos.Y.Offset + d.Y
			)
		end
	end)
	UIS.InputEnded:Connect(function(input)
		if input == drag then drag = nil end
	end)
end

-- ========== Фоновые анимации ==========
RunService.RenderStepped:Connect(function()
	if not window.Visible then return end
	local t = os.clock()
	strokeGrad.Rotation = (t * 60) % 360
	title.TextColor3 = Color3.fromHSV((t * 0.15) % 1, 0.55, 1)
end)

-- ========== Респавн ==========
player.CharacterAdded:Connect(function(char)
	char:WaitForChild("Humanoid")
	stopFly()
	setFly(false, true)
	applyCharacterSettings()
end)

selectTab(1)
