--[[
  ╔══════════════════════════════════════════╗
  ║   NEON HUB — меню для Roblox Studio      ║
  ╚══════════════════════════════════════════╝
  Куда вставить: StarterPlayer > StarterPlayerScripts > LocalScript

  • ПК: RightShift открывает/закрывает меню (меняется в Настройках)
  • Телефон: плавающая кнопка "N" (тап = открыть, зажать и тянуть = переместить)
  • Окно перетаскивается за верхнюю панель
  • Все цвета/скругления/шрифты/прозрачность меняются на лету во вкладке "Настройки"
  • Конфиг: экспорт/импорт в JSON (копируется из поля)
]]

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local oldGui = playerGui:FindFirstChild("NeonHub")
if oldGui then oldGui:Destroy() end

--------------------------------------------------------------------
-- НАСТРОЙКИ
--------------------------------------------------------------------
local TITLE = "NEON HUB"
local VERSION = "v0.1"
local WIN_W, WIN_H = 640, 400
local SIDEBAR_W = 164

local function rgb(r, g, b) return Color3.fromRGB(r, g, b) end

local Presets = {
	Midnight = {Accent = rgb(130,110,255), Background = rgb(16,16,22), Surface = rgb(23,23,31), Element = rgb(32,32,43), Text = rgb(236,236,248), SubText = rgb(146,146,170)},
	Ocean    = {Accent = rgb(56,189,248),  Background = rgb(10,18,28), Surface = rgb(15,26,40), Element = rgb(22,37,55),  Text = rgb(232,244,255), SubText = rgb(130,160,185)},
	Rose     = {Accent = rgb(251,95,150),  Background = rgb(22,14,20), Surface = rgb(31,20,28), Element = rgb(43,28,39),  Text = rgb(255,238,245), SubText = rgb(178,140,158)},
	Emerald  = {Accent = rgb(52,211,153),  Background = rgb(12,20,17), Surface = rgb(18,29,25), Element = rgb(26,41,35),  Text = rgb(232,252,244), SubText = rgb(130,170,152)},
	Snow     = {Accent = rgb(99,102,241),  Background = rgb(244,245,250), Surface = rgb(233,235,244), Element = rgb(255,255,255), Text = rgb(28,30,45), SubText = rgb(110,115,140)},
	AMOLED   = {Accent = rgb(0,229,255),   Background = rgb(0,0,0), Surface = rgb(9,9,11), Element = rgb(19,19,23), Text = rgb(255,255,255), SubText = rgb(140,140,150)},
}
local PresetOrder = {"Midnight", "Ocean", "Rose", "Emerald", "Snow", "AMOLED"}

local Fonts = {
	Gotham    = {Enum.Font.GothamMedium, Enum.Font.GothamBold},
	Ubuntu    = {Enum.Font.Ubuntu, Enum.Font.Ubuntu},
	Nunito    = {Enum.Font.Nunito, Enum.Font.Nunito},
	Code      = {Enum.Font.Code, Enum.Font.Code},
	Fredoka   = {Enum.Font.FredokaOne, Enum.Font.FredokaOne},
	SourceSans= {Enum.Font.SourceSans, Enum.Font.SourceSansBold},
}
local FontOrder = {"Gotham", "Ubuntu", "Nunito", "Code", "Fredoka", "SourceSans"}

local Theme = {Transparency = 0.04, Corner = 10, Scale = 1, AnimSpeed = 1, FontName = "Gotham", AnimatedStroke = true}
for k, v in pairs(Presets.Midnight) do Theme[k] = v end

local Menu = {Open = false, Notifications = true}
local Flags, Keybinds, conns = {}, {}, {}
local listening = nil

local function connect(signal, fn)
	local c = signal:Connect(fn)
	table.insert(conns, c)
	return c
end

local function fire(cb, ...)
	if cb then task.spawn(cb, ...) end
end

--------------------------------------------------------------------
-- БАЗОВЫЕ УТИЛИТЫ
--------------------------------------------------------------------
local function new(class, props)
	local o = Instance.new(class)
	for k, v in pairs(props) do
		if k ~= "Parent" then o[k] = v end
	end
	if props.Parent then o.Parent = props.Parent end
	return o
end

local function tween(inst, props, time, style, dir)
	local t = TweenService:Create(inst, TweenInfo.new((time or 0.25) / math.max(Theme.AnimSpeed, 0.25), style or Enum.EasingStyle.Quint, dir or Enum.EasingDirection.Out), props)
	t:Play()
	return t
end

local gui = new("ScreenGui", {Name = "NeonHub", ResetOnSpawn = false, ZIndexBehavior = Enum.ZIndexBehavior.Sibling, DisplayOrder = 999, Parent = playerGui})

local function viewport()
	local s = gui.AbsoluteSize
	if s.X < 10 then s = workspace.CurrentCamera.ViewportSize end
	return s
end

-- Привязка свойств к теме (меняются плавно при смене темы)
local bindings, lookup = {}, setmetatable({}, {__mode = "k"})
local TWEENABLE = {number = true, Color3 = true, UDim = true, UDim2 = true, Vector2 = true}

local function bind(inst, prop, getter)
	local m = lookup[inst]
	if not m then m = {}; lookup[inst] = m end
	local e = m[prop]
	if e then
		e.get = getter
	else
		e = {inst = inst, prop = prop, get = getter}
		m[prop] = e
		table.insert(bindings, e)
	end
	inst[prop] = getter()
end

local function applyTheme(instant)
	for i = #bindings, 1, -1 do
		local b = bindings[i]
		if not b.inst:IsDescendantOf(gui) then
			table.remove(bindings, i)
		else
			local v = b.get()
			if instant or not TWEENABLE[typeof(v)] then
				b.inst[b.prop] = v
			else
				tween(b.inst, {[b.prop] = v}, 0.35)
			end
		end
	end
end

local function font(bold)
	local f = Fonts[Theme.FontName] or Fonts.Gotham
	return bold and f[2] or f[1]
end

local function accent() return Theme.Accent end
local function accent2()
	local h, s, v = Theme.Accent:ToHSV()
	return Color3.fromHSV((h + 0.12) % 1, s, v)
end

local function text(parent, str, size, colorKey, bold, props)
	local l = new("TextLabel", {Parent = parent, BackgroundTransparency = 1, Text = str, TextSize = size, TextXAlignment = Enum.TextXAlignment.Left, BorderSizePixel = 0})
	bind(l, "TextColor3", function() return Theme[colorKey] end)
	bind(l, "Font", function() return font(bold) end)
	if props then for k, v in pairs(props) do l[k] = v end end
	return l
end

local function corner(parent, factor)
	local c = new("UICorner", {Parent = parent})
	bind(c, "CornerRadius", function() return UDim.new(0, math.floor(Theme.Corner * (factor or 1) + 0.5)) end)
	return c
end

local function pill(parent)
	return new("UICorner", {Parent = parent, CornerRadius = UDim.new(1, 0)})
end

--------------------------------------------------------------------
-- ПЕРЕТАСКИВАНИЕ (мышь + тач)
--------------------------------------------------------------------
local function isPointer(input)
	return input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch
end

-- Для слайдеров/пикера: вызывает fn(позиция) пока палец/мышь зажаты
local function dragArea(area, scroller, fn)
	area.InputBegan:Connect(function(input)
		if not isPointer(input) then return end
		if scroller then scroller.ScrollingEnabled = false end
		fn(input.Position)
		local move = UIS.InputChanged:Connect(function(i)
			if i == input or i.UserInputType == Enum.UserInputType.MouseMovement then
				fn(i.Position)
			end
		end)
		local ended
		ended = input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				move:Disconnect()
				ended:Disconnect()
				if scroller then scroller.ScrollingEnabled = true end
			end
		end)
	end)
end

-- Для перемещения окон/кнопок. onTap — если это был короткий тап без движения
local function makeDraggable(handle, target, onTap)
	handle.InputBegan:Connect(function(input)
		if not isPointer(input) then return end
		local startPos, startUDim, moved = input.Position, target.Position, false
		local move = UIS.InputChanged:Connect(function(i)
			if i == input or i.UserInputType == Enum.UserInputType.MouseMovement then
				local d = i.Position - startPos
				if not moved and d.Magnitude > 6 then moved = true end
				if moved or not onTap then
					local vp = viewport()
					target.Position = UDim2.fromScale(
						math.clamp(startUDim.X.Scale + d.X / vp.X, 0.02, 0.98),
						math.clamp(startUDim.Y.Scale + d.Y / vp.Y, 0.02, 0.98)
					)
				end
			end
		end)
		local ended
		ended = input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				move:Disconnect()
				ended:Disconnect()
				if onTap and not moved then onTap() end
			end
		end)
	end)
end

--------------------------------------------------------------------
-- ОКНО
--------------------------------------------------------------------
local window = new("Frame", {Name = "Window", Parent = gui, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(WIN_W, WIN_H), BackgroundTransparency = 1, Active = true, Visible = false})
local uiScale = new("UIScale", {Parent = window})
corner(window, 1.4)

local stroke = new("UIStroke", {Parent = window, Thickness = 1.6, Transparency = 1})
local grad = new("UIGradient", {Parent = stroke})
bind(grad, "Color", function()
	if Theme.AnimatedStroke then
		return ColorSequence.new({ColorSequenceKeypoint.new(0, Theme.Accent), ColorSequenceKeypoint.new(0.5, accent2()), ColorSequenceKeypoint.new(1, Theme.Accent)})
	end
	return ColorSequence.new(Theme.Accent)
end)

local canvas = new("CanvasGroup", {Name = "Canvas", Parent = window, Size = UDim2.fromScale(1, 1), BorderSizePixel = 0, GroupTransparency = 1})
bind(canvas, "BackgroundColor3", function() return Theme.Background end)
bind(canvas, "BackgroundTransparency", function() return Theme.Transparency end)
corner(canvas, 1.4)

-- Верхняя панель
local top = new("Frame", {Name = "Top", Parent = canvas, Size = UDim2.new(1, 0, 0, 46), BackgroundTransparency = 1, Active = true})
text(top, TITLE, 17, "Accent", true, {Position = UDim2.fromOffset(18, 5), Size = UDim2.new(1, -80, 0, 22)})
text(top, VERSION .. "  •  " .. player.DisplayName, 11, "SubText", false, {Position = UDim2.fromOffset(18, 26), Size = UDim2.new(1, -80, 0, 14)})
makeDraggable(top, window, nil)

local closeBtn = new("TextButton", {Parent = top, AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -12, 0.5, 0), Size = UDim2.fromOffset(30, 30), Text = "✕", TextSize = 14, AutoButtonColor = false, BorderSizePixel = 0, ZIndex = 3})
bind(closeBtn, "BackgroundColor3", function() return Theme.Element end)
bind(closeBtn, "TextColor3", function() return Theme.SubText end)
bind(closeBtn, "Font", function() return font(true) end)
corner(closeBtn, 0.7)
closeBtn.MouseEnter:Connect(function()
	tween(closeBtn, {BackgroundColor3 = rgb(232, 80, 90), TextColor3 = rgb(255, 255, 255)}, 0.15)
end)
closeBtn.MouseLeave:Connect(function()
	tween(closeBtn, {BackgroundColor3 = Theme.Element, TextColor3 = Theme.SubText}, 0.2)
end)

local sep = new("Frame", {Parent = canvas, Position = UDim2.fromOffset(0, 46), Size = UDim2.new(1, 0, 0, 1), BorderSizePixel = 0, BackgroundTransparency = 0.93})
bind(sep, "BackgroundColor3", function() return Theme.Text end)

-- Сайдбар
local sidebar = new("Frame", {Name = "Sidebar", Parent = canvas, Position = UDim2.fromOffset(0, 47), Size = UDim2.new(0, SIDEBAR_W, 1, -47), BorderSizePixel = 0})
bind(sidebar, "BackgroundColor3", function() return Theme.Surface end)
bind(sidebar, "BackgroundTransparency", function() return Theme.Transparency end)

local highlight = new("Frame", {Parent = sidebar, Position = UDim2.new(0, 10, 0, 12), Size = UDim2.new(1, -20, 0, 36), BorderSizePixel = 0, BackgroundTransparency = 0.85})
bind(highlight, "BackgroundColor3", accent)
corner(highlight, 0.8)
local indicator = new("Frame", {Parent = highlight, AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.fromScale(0, 0.5), Size = UDim2.fromOffset(3, 18), BorderSizePixel = 0})
bind(indicator, "BackgroundColor3", accent)
pill(indicator)

-- Карточка профиля
local profile = new("Frame", {Parent = sidebar, Position = UDim2.new(0, 10, 1, -58), Size = UDim2.new(1, -20, 0, 48), BorderSizePixel = 0})
bind(profile, "BackgroundColor3", function() return Theme.Element end)
corner(profile, 0.9)
local avatar = new("ImageLabel", {Parent = profile, Position = UDim2.fromOffset(8, 8), Size = UDim2.fromOffset(32, 32), BorderSizePixel = 0, Image = "rbxthumb://type=AvatarHeadShot&id=" .. player.UserId .. "&w=150&h=150"})
bind(avatar, "BackgroundColor3", function() return Theme.Surface end)
pill(avatar)
text(profile, player.DisplayName, 13, "Text", true, {Position = UDim2.fromOffset(48, 7), Size = UDim2.new(1, -54, 0, 18), TextTruncate = Enum.TextTruncate.AtEnd})
text(profile, "@" .. player.Name, 11, "SubText", false, {Position = UDim2.fromOffset(48, 24), Size = UDim2.new(1, -54, 0, 16), TextTruncate = Enum.TextTruncate.AtEnd})

-- Область контента
local content = new("Frame", {Name = "Content", Parent = canvas, Position = UDim2.fromOffset(SIDEBAR_W, 47), Size = UDim2.new(1, -SIDEBAR_W, 1, -47), BackgroundTransparency = 1, ClipsDescendants = true})

--------------------------------------------------------------------
-- ОТКРЫТИЕ / ЗАКРЫТИЕ / МАСШТАБ
--------------------------------------------------------------------
local function autoScale()
	local vp = viewport()
	return math.clamp(math.min((vp.X - 24) / WIN_W, (vp.Y - 24) / WIN_H), 0.4, 1)
end

local function targetScale() return autoScale() * Theme.Scale end

local function refreshScale(animate)
	if not Menu.Open then return end
	if animate then tween(uiScale, {Scale = targetScale()}, 0.3) else uiScale.Scale = targetScale() end
end

local function setOpen(open)
	if Menu.Open == open then return end
	Menu.Open = open
	local target = targetScale()
	if open then
		window.Visible = true
		uiScale.Scale = target * 0.88
		canvas.GroupTransparency = 1
		stroke.Transparency = 1
		tween(uiScale, {Scale = target}, 0.5, Enum.EasingStyle.Back)
		tween(canvas, {GroupTransparency = 0}, 0.3)
		tween(stroke, {Transparency = 0.35}, 0.35)
	else
		tween(uiScale, {Scale = target * 0.92}, 0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
		tween(canvas, {GroupTransparency = 1}, 0.2)
		local t = tween(stroke, {Transparency = 1}, 0.2)
		t.Completed:Connect(function()
			if not Menu.Open then window.Visible = false end
		end)
	end
end

closeBtn.Activated:Connect(function() setOpen(false) end)

connect(gui:GetPropertyChangedSignal("AbsoluteSize"), function()
	if Menu.Open then uiScale.Scale = targetScale() end
end)

--------------------------------------------------------------------
-- УВЕДОМЛЕНИЯ
--------------------------------------------------------------------
local notifHolder = new("Frame", {Name = "Notifications", Parent = gui, AnchorPoint = Vector2.new(1, 1), Position = UDim2.new(1, -16, 1, -16), Size = UDim2.fromOffset(280, 400), BackgroundTransparency = 1})
new("UIListLayout", {Parent = notifHolder, Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder, VerticalAlignment = Enum.VerticalAlignment.Bottom, HorizontalAlignment = Enum.HorizontalAlignment.Right})
local notifCount = 0

local function Notify(title, body, duration, color)
	if not Menu.Notifications then return end
	duration = duration or 3.5
	notifCount += 1
	local slot = new("Frame", {Parent = notifHolder, Size = UDim2.new(1, 0, 0, 0), BackgroundTransparency = 1, LayoutOrder = notifCount})
	local card = new("Frame", {Parent = slot, Position = UDim2.new(1.15, 0, 0, 0), Size = UDim2.new(1, 0, 0, 64), BorderSizePixel = 0})
	bind(card, "BackgroundColor3", function() return Theme.Element end)
	corner(card, 1)
	local st = new("UIStroke", {Parent = card, Thickness = 1, Transparency = 0.55})
	if color then st.Color = color else bind(st, "Color", accent) end
	text(card, title, 14, "Text", true, {Position = UDim2.fromOffset(14, 8), Size = UDim2.new(1, -28, 0, 18)})
	text(card, body or "", 12, "SubText", false, {Position = UDim2.fromOffset(14, 27), Size = UDim2.new(1, -28, 0, 28), TextWrapped = true, TextYAlignment = Enum.TextYAlignment.Top})
	local bar = new("Frame", {Parent = card, Position = UDim2.new(0, 14, 1, -6), Size = UDim2.new(1, -28, 0, 2), BorderSizePixel = 0})
	if color then bar.BackgroundColor3 = color else bind(bar, "BackgroundColor3", accent) end
	pill(bar)

	tween(slot, {Size = UDim2.new(1, 0, 0, 64)}, 0.3)
	tween(card, {Position = UDim2.new(0, 0, 0, 0)}, 0.5, Enum.EasingStyle.Back)
	TweenService:Create(bar, TweenInfo.new(duration, Enum.EasingStyle.Linear), {Size = UDim2.new(0, 0, 0, 2)}):Play()

	task.delay(duration, function()
		if not slot.Parent then return end
		local t = tween(card, {Position = UDim2.new(1.15, 0, 0, 0)}, 0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
		t.Completed:Wait()
		local t2 = tween(slot, {Size = UDim2.new(1, 0, 0, 0)}, 0.2)
		t2.Completed:Wait()
		slot:Destroy()
	end)
end

--------------------------------------------------------------------
-- ПЛАВАЮЩАЯ КНОПКА (для телефонов)
--------------------------------------------------------------------
local fab = new("TextButton", {Name = "Fab", Parent = gui, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.07, 0.4), Size = UDim2.fromOffset(48, 48), Text = "N", TextSize = 20, AutoButtonColor = false, BorderSizePixel = 0, Visible = UIS.TouchEnabled, ZIndex = 10})
bind(fab, "BackgroundColor3", function() return Theme.Element end)
bind(fab, "TextColor3", accent)
bind(fab, "Font", function() return font(true) end)
pill(fab)
local fabStroke = new("UIStroke", {Parent = fab, Thickness = 2})
bind(fabStroke, "Color", accent)
makeDraggable(fab, fab, function() setOpen(not Menu.Open) end)

--------------------------------------------------------------------
-- КОМПОНЕНТЫ
--------------------------------------------------------------------
local UI = {}

local function row(page, height)
	page.Order += 1
	local f = new("Frame", {Parent = page.Frame, Size = UDim2.new(1, 0, 0, height), LayoutOrder = page.Order, BorderSizePixel = 0, ClipsDescendants = true})
	bind(f, "BackgroundColor3", function() return Theme.Element end)
	corner(f, 0.8)
	local s = new("UIStroke", {Parent = f, Thickness = 1, Transparency = 0.9})
	bind(s, "Color", function() return Theme.Text end)
	return f
end

local function clickable(f, h, onClick)
	local overlay = new("Frame", {Parent = f, Name = "Hover", Size = UDim2.new(1, 0, 0, h), BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = 0})
	bind(overlay, "BackgroundColor3", function() return Theme.Text end)
	corner(overlay, 0.8)
	local hit = new("TextButton", {Parent = f, Name = "Hit", Size = UDim2.new(1, 0, 0, h), BackgroundTransparency = 1, Text = "", AutoButtonColor = false, ZIndex = 5})
	hit.MouseEnter:Connect(function() tween(overlay, {BackgroundTransparency = 0.94}, 0.15) end)
	hit.MouseLeave:Connect(function() tween(overlay, {BackgroundTransparency = 1}, 0.2) end)
	hit.MouseButton1Down:Connect(function() tween(overlay, {BackgroundTransparency = 0.88}, 0.08) end)
	hit.MouseButton1Up:Connect(function() tween(overlay, {BackgroundTransparency = 0.94}, 0.12) end)
	if onClick then hit.Activated:Connect(onClick) end
	return hit
end

local function expander(f, h, full, arrow)
	local open = false
	return function(force)
		if force ~= nil then open = force else open = not open end
		tween(f, {Size = UDim2.new(1, 0, 0, open and full or h)}, 0.35)
		if arrow then tween(arrow, {Rotation = open and 180 or 0}, 0.35) end
	end
end

local function flag(key, obj)
	Flags[key] = obj
	return obj
end

function UI.Section(page, name)
	page.Order += 1
	local f = new("Frame", {Parent = page.Frame, Size = UDim2.new(1, 0, 0, 24), BackgroundTransparency = 1, LayoutOrder = page.Order})
	local bar = new("Frame", {Parent = f, AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.fromScale(0, 0.5), Size = UDim2.fromOffset(3, 12), BorderSizePixel = 0})
	bind(bar, "BackgroundColor3", accent)
	pill(bar)
	text(f, name, 12, "SubText", true, {Position = UDim2.fromOffset(10, 0), Size = UDim2.new(1, -10, 1, 0)})
end

function UI.Label(page, str)
	page.Order += 1
	text(page.Frame, str, 12, "SubText", false, {Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, TextWrapped = true, TextYAlignment = Enum.TextYAlignment.Top, LayoutOrder = page.Order})
end

function UI.Button(page, name, callback)
	local H = 42
	local f = row(page, H)
	clickable(f, H, function() fire(callback) end)
	text(f, name, 14, "Text", false, {Position = UDim2.fromOffset(14, 0), Size = UDim2.new(1, -50, 0, H)})
	text(f, "→", 16, "Accent", true, {AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -14, 0, 0), Size = UDim2.fromOffset(24, H), TextXAlignment = Enum.TextXAlignment.Right})
end

function UI.Toggle(page, name, default, callback)
	local H = 42
	local f = row(page, H)
	local state = default and true or false
	local obj = {Kind = "toggle"}
	local hit = clickable(f, H, function() obj.Set(not state) end)
	text(f, name, 14, "Text", false, {Position = UDim2.fromOffset(14, 0), Size = UDim2.new(1, -80, 0, H)})

	local sw = new("Frame", {Parent = f, AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -14, 0, H / 2), Size = UDim2.fromOffset(40, 22), BorderSizePixel = 0, ZIndex = 2})
	bind(sw, "BackgroundColor3", function() return state and Theme.Accent or Theme.Surface end)
	pill(sw)
	local knob = new("Frame", {Parent = sw, AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, state and 21 or 3, 0.5, 0), Size = UDim2.fromOffset(16, 16), BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0})
	pill(knob)

	function obj.Set(v, silent)
		state = v and true or false
		tween(sw, {BackgroundColor3 = state and Theme.Accent or Theme.Surface}, 0.25)
		tween(knob, {Position = UDim2.new(0, state and 21 or 3, 0.5, 0)}, 0.35, Enum.EasingStyle.Back)
		if not silent then fire(callback, state) end
	end
	function obj.Get() return state end
	return obj
end

function UI.Slider(page, name, o, callback)
	local min, max, step = o.Min, o.Max, o.Step or 1
	local dec, s = 0, step
	while s < 0.999 and dec < 4 do s = s * 10; dec += 1 end
	local fmt = "%." .. dec .. "f"

	local f = row(page, 56)
	text(f, name, 14, "Text", false, {Position = UDim2.fromOffset(14, 6), Size = UDim2.new(1, -110, 0, 20)})
	local valLbl = text(f, "", 13, "Accent", true, {AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -14, 0, 6), Size = UDim2.fromOffset(90, 20), TextXAlignment = Enum.TextXAlignment.Right})

	local track = new("Frame", {Parent = f, Position = UDim2.new(0, 14, 0, 38), Size = UDim2.new(1, -28, 0, 6), BorderSizePixel = 0})
	bind(track, "BackgroundColor3", function() return Theme.Surface end)
	pill(track)
	local fill = new("Frame", {Parent = track, Size = UDim2.fromScale(0, 1), BorderSizePixel = 0})
	bind(fill, "BackgroundColor3", accent)
	pill(fill)
	local knob = new("Frame", {Parent = fill, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(1, 0.5), Size = UDim2.fromOffset(14, 14), BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0, ZIndex = 2})
	pill(knob)
	local ks = new("UIStroke", {Parent = knob, Thickness = 2})
	bind(ks, "Color", accent)

	local value = o.Default
	local obj = {Kind = "slider"}
	local function render(v, animate)
		local a = (v - min) / (max - min)
		valLbl.Text = string.format(fmt, v) .. (o.Suffix or "")
		if animate then
			tween(fill, {Size = UDim2.fromScale(a, 1)}, 0.12, Enum.EasingStyle.Quad)
		else
			fill.Size = UDim2.fromScale(a, 1)
		end
	end
	function obj.Set(v, silent)
		v = math.clamp(math.floor((v - min) / step + 0.5) * step + min, min, max)
		value = v
		render(v, true)
		if not silent then fire(callback, v) end
	end
	function obj.Get() return value end
	render(value, false)

	local area = new("Frame", {Parent = f, Position = UDim2.fromOffset(0, 28), Size = UDim2.new(1, 0, 1, -28), BackgroundTransparency = 1, Active = true, ZIndex = 4})
	dragArea(area, page.Frame, function(p)
		local a = math.clamp((p.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
		obj.Set(min + a * (max - min))
	end)
	return obj
end

function UI.Dropdown(page, name, options, default, callback)
	local H = 42
	local full = H + 8 + #options * 32
	local f = row(page, H)
	local toggle
	clickable(f, H, function() toggle() end)
	text(f, name, 14, "Text", false, {Position = UDim2.fromOffset(14, 0), Size = UDim2.new(1, -150, 0, H)})
	local valueLbl = text(f, default, 13, "Accent", true, {AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -38, 0, 0), Size = UDim2.fromOffset(130, H), TextXAlignment = Enum.TextXAlignment.Right})
	local arrow = text(f, "▼", 10, "SubText", false, {AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(1, -20, 0, H / 2), Size = UDim2.fromOffset(16, 16), TextXAlignment = Enum.TextXAlignment.Center})
	toggle = expander(f, H, full, arrow)

	local list = new("Frame", {Parent = f, Position = UDim2.fromOffset(8, H + 4), Size = UDim2.new(1, -16, 0, #options * 32), BackgroundTransparency = 1})
	new("UIListLayout", {Parent = list, Padding = UDim.new(0, 2), SortOrder = Enum.SortOrder.LayoutOrder})

	local current = default
	local labels = {}
	local obj = {Kind = "dropdown"}
	function obj.Set(v, silent)
		current = v
		valueLbl.Text = tostring(v)
		for opt, l in pairs(labels) do
			tween(l, {TextColor3 = (opt == v) and Theme.Accent or Theme.Text}, 0.2)
		end
		if not silent then fire(callback, v) end
	end
	function obj.Get() return current end

	for i, opt in ipairs(options) do
		local b = new("TextButton", {Parent = list, Size = UDim2.new(1, 0, 0, 30), Text = "", AutoButtonColor = false, BorderSizePixel = 0, LayoutOrder = i})
		bind(b, "BackgroundColor3", function() return Theme.Surface end)
		corner(b, 0.6)
		local l = text(b, opt, 13, "Text", false, {Position = UDim2.fromOffset(12, 0), Size = UDim2.new(1, -12, 1, 0)})
		bind(l, "TextColor3", function() return current == opt and Theme.Accent or Theme.Text end)
		labels[opt] = l
		b.Activated:Connect(function()
			obj.Set(opt)
			toggle(false)
		end)
	end
	return obj
end

function UI.ColorPicker(page, name, default, callback)
	local H = 42
	local full = H + 8 + 110 + 14
	local f = row(page, H)
	local toggle
	clickable(f, H, function() toggle() end)
	text(f, name, 14, "Text", false, {Position = UDim2.fromOffset(14, 0), Size = UDim2.new(1, -110, 0, H)})
	local swatch = new("Frame", {Parent = f, AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -40, 0, H / 2), Size = UDim2.fromOffset(30, 18), BorderSizePixel = 0, ZIndex = 2})
	new("UICorner", {Parent = swatch, CornerRadius = UDim.new(0, 6)})
	local arrow = text(f, "▼", 10, "SubText", false, {AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(1, -20, 0, H / 2), Size = UDim2.fromOffset(16, 16), TextXAlignment = Enum.TextXAlignment.Center})
	toggle = expander(f, H, full, arrow)

	-- Квадрат насыщенность/яркость
	local sv = new("Frame", {Parent = f, Position = UDim2.fromOffset(14, H + 8), Size = UDim2.new(1, -62, 0, 110), BorderSizePixel = 0, Active = true})
	new("UICorner", {Parent = sv, CornerRadius = UDim.new(0, 6)})
	local white = new("Frame", {Parent = sv, Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0})
	new("UICorner", {Parent = white, CornerRadius = UDim.new(0, 6)})
	new("UIGradient", {Parent = white, Transparency = NumberSequence.new(0, 1)})
	local black = new("Frame", {Parent = sv, Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.new(0, 0, 0), BorderSizePixel = 0})
	new("UICorner", {Parent = black, CornerRadius = UDim.new(0, 6)})
	new("UIGradient", {Parent = black, Rotation = 90, Transparency = NumberSequence.new(1, 0)})
	local cur = new("Frame", {Parent = sv, AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.fromOffset(12, 12), BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0, ZIndex = 3})
	pill(cur)
	new("UIStroke", {Parent = cur, Thickness = 1.5, Color = Color3.new(0, 0, 0), Transparency = 0.3})

	-- Полоса оттенка
	local hue = new("Frame", {Parent = f, Position = UDim2.new(1, -34, 0, H + 8), Size = UDim2.fromOffset(20, 110), BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0, Active = true})
	new("UICorner", {Parent = hue, CornerRadius = UDim.new(0, 6)})
	local kps = {}
	for i = 0, 6 do
		table.insert(kps, ColorSequenceKeypoint.new(i / 6, Color3.fromHSV((i % 6) / 6, 1, 1)))
	end
	new("UIGradient", {Parent = hue, Rotation = 90, Color = ColorSequence.new(kps)})
	local hmark = new("Frame", {Parent = hue, AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.new(1, 6, 0, 5), BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0, ZIndex = 3})
	new("UICorner", {Parent = hmark, CornerRadius = UDim.new(0, 3)})
	new("UIStroke", {Parent = hmark, Thickness = 1.2, Color = Color3.new(0, 0, 0), Transparency = 0.3})

	local h, s, v = default:ToHSV()
	local obj = {Kind = "color"}
	local function visual()
		local c = Color3.fromHSV(h, s, v)
		sv.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
		swatch.BackgroundColor3 = c
		cur.Position = UDim2.fromScale(s, 1 - v)
		hmark.Position = UDim2.fromScale(0.5, h)
		return c
	end
	visual()
	function obj.Set(c, silent)
		h, s, v = c:ToHSV()
		local col = visual()
		if not silent then fire(callback, col) end
	end
	function obj.Get() return Color3.fromHSV(h, s, v) end

	dragArea(sv, page.Frame, function(p)
		s = math.clamp((p.X - sv.AbsolutePosition.X) / sv.AbsoluteSize.X, 0, 1)
		v = 1 - math.clamp((p.Y - sv.AbsolutePosition.Y) / sv.AbsoluteSize.Y, 0, 1)
		fire(callback, visual())
	end)
	dragArea(hue, page.Frame, function(p)
		h = math.clamp((p.Y - hue.AbsolutePosition.Y) / hue.AbsoluteSize.Y, 0, 0.999)
		fire(callback, visual())
	end)
	return obj
end

function UI.Keybind(page, name, defaultKey, onPress)
	local H = 42
	local f = row(page, H)
	text(f, name, 14, "Text", false, {Position = UDim2.fromOffset(14, 0), Size = UDim2.new(1, -130, 0, H)})
	local btn = new("TextButton", {Parent = f, AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -12, 0, H / 2), Size = UDim2.fromOffset(100, 28), Text = "", AutoButtonColor = false, BorderSizePixel = 0, ZIndex = 5})
	bind(btn, "BackgroundColor3", function() return Theme.Surface end)
	corner(btn, 0.6)
	local lbl = text(btn, "", 12, "Accent", true, {Size = UDim2.fromScale(1, 1), TextXAlignment = Enum.TextXAlignment.Center})

	local obj = {Kind = "keybind", Key = defaultKey, OnPress = onPress}
	function obj.Refresh() lbl.Text = obj.Key and obj.Key.Name or "None" end
	function obj.SetKey(k) obj.Key = k; obj.Refresh() end
	function obj.Set(n)
		local ok, k = pcall(function() return Enum.KeyCode[n] end)
		if ok and k then obj.SetKey(k) end
	end
	function obj.Get() return obj.Key and obj.Key.Name or "Unknown" end
	btn.Activated:Connect(function()
		listening = obj
		lbl.Text = "..."
	end)
	obj.Refresh()
	table.insert(Keybinds, obj)
	return obj
end

function UI.TextBox(page, name, placeholder, callback)
	local H = 42
	local f = row(page, H)
	text(f, name, 14, "Text", false, {Position = UDim2.fromOffset(14, 0), Size = UDim2.new(1, -180, 0, H)})
	local box = new("TextBox", {Parent = f, AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -12, 0, H / 2), Size = UDim2.fromOffset(150, 28), Text = "", PlaceholderText = placeholder or "", ClearTextOnFocus = false, TextSize = 13, BorderSizePixel = 0, ZIndex = 5})
	bind(box, "BackgroundColor3", function() return Theme.Surface end)
	bind(box, "TextColor3", function() return Theme.Text end)
	bind(box, "PlaceholderColor3", function() return Theme.SubText end)
	bind(box, "Font", function() return font(false) end)
	corner(box, 0.6)
	local st = new("UIStroke", {Parent = box, Thickness = 1.2, Transparency = 1})
	bind(st, "Color", accent)
	box.Focused:Connect(function() tween(st, {Transparency = 0.2}, 0.2) end)
	box.FocusLost:Connect(function(enter)
		tween(st, {Transparency = 1}, 0.2)
		fire(callback, box.Text, enter)
	end)
	local obj = {Kind = "textbox"}
	function obj.Set(v, silent) box.Text = tostring(v); if not silent then fire(callback, box.Text, false) end end
	function obj.Get() return box.Text end
	return obj
end

function UI.ConfigBox(page)
	local f = row(page, 96)
	local box = new("TextBox", {Parent = f, Position = UDim2.fromOffset(12, 10), Size = UDim2.new(1, -24, 1, -20), BackgroundTransparency = 1, ClearTextOnFocus = false, MultiLine = true, TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top, TextSize = 12, Text = "", PlaceholderText = "Здесь появится конфиг (JSON). Вставь свой и нажми «Импорт».", ZIndex = 2})
	bind(box, "TextColor3", function() return Theme.Text end)
	bind(box, "PlaceholderColor3", function() return Theme.SubText end)
	bind(box, "Font", function() return font(false) end)
	return box
end

--------------------------------------------------------------------
-- ВКЛАДКИ
--------------------------------------------------------------------
local tabs, current = {}, nil

local function selectTab(i)
	if current == i then return end
	local prev, tab = tabs[current], tabs[i]
	current = i
	if prev then
		prev.wrap.Visible = false
		prev.active = false
		tween(prev.label, {TextColor3 = Theme.SubText}, 0.2)
		tween(prev.icon, {TextColor3 = Theme.SubText}, 0.2)
	end
	tab.active = true
	tween(tab.label, {TextColor3 = Theme.Text}, 0.2)
	tween(tab.icon, {TextColor3 = Theme.Accent}, 0.2)
	tween(highlight, {Position = UDim2.new(0, 10, 0, 12 + (i - 1) * 40)}, 0.4)
	tab.wrap.Visible = true
	tab.wrap.GroupTransparency = 1
	tab.wrap.Position = UDim2.fromOffset(0, 16)
	tween(tab.wrap, {GroupTransparency = 0, Position = UDim2.fromOffset(0, 0)}, 0.45)
end

local function createPage(name, iconText)
	local idx = #tabs + 1
	local btn = new("TextButton", {Parent = sidebar, Position = UDim2.new(0, 10, 0, 12 + (idx - 1) * 40), Size = UDim2.new(1, -20, 0, 36), BackgroundTransparency = 1, Text = "", AutoButtonColor = false, ZIndex = 2})
	local tab = {active = false}
	tab.icon = text(btn, iconText, 15, "SubText", false, {Position = UDim2.fromOffset(14, 0), Size = UDim2.fromOffset(24, 36), TextXAlignment = Enum.TextXAlignment.Center})
	tab.label = text(btn, name, 14, "SubText", true, {Position = UDim2.fromOffset(44, 0), Size = UDim2.new(1, -48, 1, 0)})
	bind(tab.label, "TextColor3", function() return tab.active and Theme.Text or Theme.SubText end)
	bind(tab.icon, "TextColor3", function() return tab.active and Theme.Accent or Theme.SubText end)
	btn.MouseEnter:Connect(function() if not tab.active then tween(tab.label, {TextColor3 = Theme.Text}, 0.15) end end)
	btn.MouseLeave:Connect(function() if not tab.active then tween(tab.label, {TextColor3 = Theme.SubText}, 0.2) end end)
	btn.Activated:Connect(function() selectTab(idx) end)

	tab.wrap = new("CanvasGroup", {Parent = content, BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), Visible = false, GroupTransparency = 1})
	local scroller = new("ScrollingFrame", {Parent = tab.wrap, BackgroundTransparency = 1, BorderSizePixel = 0, Size = UDim2.fromScale(1, 1), CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y, ScrollBarThickness = 3, ScrollingDirection = Enum.ScrollingDirection.Y})
	bind(scroller, "ScrollBarImageColor3", accent)
	new("UIPadding", {Parent = scroller, PaddingTop = UDim.new(0, 14), PaddingBottom = UDim.new(0, 14), PaddingLeft = UDim.new(0, 14), PaddingRight = UDim.new(0, 14)})
	new("UIListLayout", {Parent = scroller, Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder})
	tabs[idx] = tab
	return {Frame = scroller, Order = 0}
end

--------------------------------------------------------------------
-- ЛОГИКА ДЕМО-ФУНКЦИЙ (тут потом добавишь свои)
--------------------------------------------------------------------
local State = {Speed = false, SpeedValue = 32, Jump = false, JumpValue = 70, InfJump = false}

local function getHumanoid()
	local c = player.Character
	return c and c:FindFirstChildOfClass("Humanoid")
end

local function applyStats()
	local h = getHumanoid()
	if not h then return end
	h.WalkSpeed = State.Speed and State.SpeedValue or 16
	h.UseJumpPower = true
	h.JumpPower = State.Jump and State.JumpValue or 50
end

connect(player.CharacterAdded, function()
	task.wait(0.5)
	applyStats()
end)
connect(UIS.JumpRequest, function()
	if State.InfJump then
		local h = getHumanoid()
		if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
	end
end)

--------------------------------------------------------------------
-- ВКЛАДКА: ГЛАВНАЯ
--------------------------------------------------------------------
local pMain = createPage("Главная", "🏠")
UI.Section(pMain, "Игрок")
flag("speed", UI.Toggle(pMain, "Скорость", false, function(v) State.Speed = v; applyStats() end))
flag("speedValue", UI.Slider(pMain, "Значение скорости", {Min = 16, Max = 150, Default = 32, Step = 1}, function(v) State.SpeedValue = v; applyStats() end))
flag("jump", UI.Toggle(pMain, "Сила прыжка", false, function(v) State.Jump = v; applyStats() end))
flag("jumpValue", UI.Slider(pMain, "Значение прыжка", {Min = 50, Max = 250, Default = 70, Step = 1}, function(v) State.JumpValue = v; applyStats() end))
flag("infJump", UI.Toggle(pMain, "Бесконечный прыжок", false, function(v) State.InfJump = v end))
UI.Section(pMain, "Камера")
flag("fov", UI.Slider(pMain, "Поле зрения (FOV)", {Min = 40, Max = 120, Default = 70, Step = 1}, function(v) workspace.CurrentCamera.FieldOfView = v end))
UI.Section(pMain, "Прочее")
UI.Button(pMain, "Тестовое уведомление", function() Notify("Привет!", "Уведомления работают плавно 🙂", 3) end)

--------------------------------------------------------------------
-- ВКЛАДКА: ВИЗУАЛ (шаблон под твои функции)
--------------------------------------------------------------------
local pVis = createPage("Визуал", "👁")
UI.Section(pVis, "Шаблон ESP (заглушка)")
flag("esp", UI.Toggle(pVis, "Включить подсветку", false, function(v)
	-- TODO: сюда свою логику
	Notify("Подсветка", v and "Включено" or "Выключено", 2)
end))
flag("espDist", UI.Slider(pVis, "Дистанция", {Min = 50, Max = 2000, Default = 500, Step = 10, Suffix = " st"}))
flag("espTarget", UI.Dropdown(pVis, "Часть тела", {"Голова", "Торс", "Ноги", "Всё тело"}, "Голова"))
flag("espColor", UI.ColorPicker(pVis, "Цвет подсветки", Color3.fromRGB(255, 80, 120)))
flag("espKey", UI.Keybind(pVis, "Горячая клавиша", Enum.KeyCode.E, function()
	if Flags.esp then Flags.esp.Set(not Flags.esp.Get()) end
end))
UI.Section(pVis, "Прочие компоненты")
flag("profileName", UI.TextBox(pVis, "Имя профиля", "введи имя..."))
UI.Label(pVis, "Это демонстрация всех компонентов: переключатели, слайдеры, выпадающие списки, выбор цвета, бинды и поля ввода. Копируй строки и вставляй свои функции в callback.")

--------------------------------------------------------------------
-- ВКЛАДКА: НАСТРОЙКИ
--------------------------------------------------------------------
local pSet = createPage("Настройки", "⚙️")
local refreshers = {}
local function refreshThemeControls() for _, fn in ipairs(refreshers) do fn() end end

local presetDD, fontDD, accentPick, transSl, cornerSl, scaleSl, speedSl, strokeTg

local function applyPreset(name)
	for k, v in pairs(Presets[name]) do Theme[k] = v end
	applyTheme(false)
	refreshThemeControls()
end

UI.Section(pSet, "Тема")
presetDD = UI.Dropdown(pSet, "Пресет", PresetOrder, "Midnight", function(v) applyPreset(v) end)
accentPick = UI.ColorPicker(pSet, "Акцентный цвет", Theme.Accent, function(c) Theme.Accent = c; applyTheme(true) end)
fontDD = UI.Dropdown(pSet, "Шрифт", FontOrder, Theme.FontName, function(v) Theme.FontName = v; applyTheme(true) end)

UI.Section(pSet, "Окно")
transSl = UI.Slider(pSet, "Прозрачность окна", {Min = 0, Max = 0.6, Default = Theme.Transparency, Step = 0.01}, function(v) Theme.Transparency = v; applyTheme(true) end)
cornerSl = UI.Slider(pSet, "Скругление углов", {Min = 0, Max = 24, Default = Theme.Corner, Step = 1, Suffix = " px"}, function(v) Theme.Corner = v; applyTheme(true) end)
scaleSl = UI.Slider(pSet, "Масштаб интерфейса", {Min = 0.6, Max = 1.4, Default = Theme.Scale, Step = 0.05, Suffix = "x"}, function(v) Theme.Scale = v; refreshScale(true) end)
speedSl = UI.Slider(pSet, "Скорость анимаций", {Min = 0.5, Max = 2.5, Default = Theme.AnimSpeed, Step = 0.1, Suffix = "x"}, function(v) Theme.AnimSpeed = v end)
strokeTg = UI.Toggle(pSet, "Анимированная обводка", Theme.AnimatedStroke, function(v)
	Theme.AnimatedStroke = v
	if not v then grad.Rotation = 0 end
	applyTheme(true)
end)

table.insert(refreshers, function()
	accentPick.Set(Theme.Accent, true)
	fontDD.Set(Theme.FontName, true)
	transSl.Set(Theme.Transparency, true)
	cornerSl.Set(Theme.Corner, true)
	scaleSl.Set(Theme.Scale, true)
	speedSl.Set(Theme.AnimSpeed, true)
	strokeTg.Set(Theme.AnimatedStroke, true)
end)

UI.Section(pSet, "Управление")
UI.Toggle(pSet, "Уведомления", true, function(v) Menu.Notifications = v end)
UI.Toggle(pSet, "Плавающая кнопка (телефон)", UIS.TouchEnabled, function(v) fab.Visible = v end)
flag("menuKey", UI.Keybind(pSet, "Открыть / закрыть меню", Enum.KeyCode.RightShift, function() setOpen(not Menu.Open) end))

UI.Section(pSet, "Конфиг")
local cfgBox = UI.ConfigBox(pSet)

local THEME_COLORS = {"Accent", "Background", "Surface", "Element", "Text", "SubText"}
local THEME_VALUES = {"Transparency", "Corner", "Scale", "AnimSpeed", "FontName", "AnimatedStroke"}

local function packColor(c)
	return {math.floor(c.R * 255 + 0.5), math.floor(c.G * 255 + 0.5), math.floor(c.B * 255 + 0.5)}
end

local function exportConfig()
	local data = {flags = {}, theme = {}}
	for k, obj in pairs(Flags) do
		local v = obj.Get()
		if typeof(v) == "Color3" then v = packColor(v) end
		data.flags[k] = v
	end
	for _, k in ipairs(THEME_COLORS) do data.theme[k] = packColor(Theme[k]) end
	for _, k in ipairs(THEME_VALUES) do data.theme[k] = Theme[k] end
	return HttpService:JSONEncode(data)
end

local function importConfig(str)
	local ok, data = pcall(HttpService.JSONDecode, HttpService, str)
	if not ok or type(data) ~= "table" then
		Notify("Конфиг", "Не удалось прочитать JSON", 3, rgb(255, 90, 90))
		return
	end
	if type(data.theme) == "table" then
		for k, v in pairs(data.theme) do
			if typeof(Theme[k]) == "Color3" and type(v) == "table" and #v == 3 then
				Theme[k] = rgb(v[1], v[2], v[3])
			elseif Theme[k] ~= nil and type(Theme[k]) == type(v) then
				Theme[k] = v
			end
		end
		applyTheme(false)
		refreshThemeControls()
		refreshScale(true)
	end
	if type(data.flags) == "table" then
		for k, v in pairs(data.flags) do
			local obj = Flags[k]
			if obj then
				if type(v) == "table" and #v == 3 then v = rgb(v[1], v[2], v[3]) end
				pcall(obj.Set, v)
			end
		end
	end
	Notify("Конфиг", "Импорт выполнен", 2.5)
end

UI.Button(pSet, "Экспорт конфига → в поле", function()
	cfgBox.Text = exportConfig()
	Notify("Конфиг", "Скопируй текст из поля", 2.5)
end)
UI.Button(pSet, "Импорт из поля", function() importConfig(cfgBox.Text) end)
UI.Button(pSet, "Сбросить тему", function()
	Theme.Transparency, Theme.Corner, Theme.Scale, Theme.AnimSpeed = 0.04, 10, 1, 1
	Theme.FontName, Theme.AnimatedStroke = "Gotham", true
	presetDD.Set("Midnight", true)
	applyPreset("Midnight")
	refreshScale(true)
end)
UI.Button(pSet, "Выгрузить меню", function()
	for _, c in ipairs(conns) do c:Disconnect() end
	gui:Destroy()
end)

--------------------------------------------------------------------
-- ВВОД (бинды) И АНИМАЦИЯ ОБВОДКИ
--------------------------------------------------------------------
connect(UIS.InputBegan, function(input, gp)
	if listening then
		if input.UserInputType == Enum.UserInputType.Keyboard then
			local kb = listening
			listening = nil
			if input.KeyCode ~= Enum.KeyCode.Escape then kb.SetKey(input.KeyCode) else kb.Refresh() end
		end
		return
	end
	if gp or input.UserInputType ~= Enum.UserInputType.Keyboard then return end
	for _, kb in ipairs(Keybinds) do
		if kb.Key == input.KeyCode and kb.OnPress then task.spawn(kb.OnPress) end
	end
end)

connect(RunService.RenderStepped, function()
	if Menu.Open and Theme.AnimatedStroke then
		grad.Rotation = (os.clock() * 45) % 360
	end
end)

--------------------------------------------------------------------
-- СТАРТ
--------------------------------------------------------------------
selectTab(1)
task.defer(function()
	setOpen(true)
	task.wait(0.4)
	Notify(TITLE, UIS.TouchEnabled and "Кнопка «N» открывает меню" or "RightShift — открыть/закрыть меню", 4)
end)
