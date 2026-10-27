--[[
NOVA PURPLE UI LIBRARY v2
Roblox Studio ModuleScript.
1. Create a ModuleScript named "NovaPurple" inside ReplicatedStorage and paste this file.
2. From a LocalScript, call:
   local Nova = require(game:GetService("ReplicatedStorage"):WaitForChild("NovaPurple"))
   local Window = Nova:CreateWindow({Name = "NOVA PURPLE", Subtitle = "My UI"})
   local Tab = Window:CreateTab({Name = "Main", Icon = "⌂"})
   Tab:CreateButton({Name = "Click me", Callback = function() print("Clicked") end})
   Tab:CreateToggle({Name = "Enabled", Default = false, Callback = function(v) print(v) end})
   Tab:CreateSlider({Name = "Power", Min = 0, Max = 100, Default = 50, Callback = function(v) print(v) end})
   Tab:CreateDropdown({Name = "Mode", Options = {"A", "B"}, Default = "A", Callback = function(v) print(v) end})
   Tab:CreateColorPicker({Name = "Accent", Default = Color3.fromRGB(147,72,255), Callback = function(c) print(c) end})

This is a UI library for your own Roblox experiences. It does not load or execute remote code.
]]

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local Nova = {}
Nova.__index = Nova

local DEFAULT_THEME = {
    Background = Color3.fromRGB(10, 12, 27),
    Panel = Color3.fromRGB(15, 18, 39),
    Card = Color3.fromRGB(23, 26, 53),
    CardHover = Color3.fromRGB(32, 35, 69),
    Text = Color3.fromRGB(245, 242, 255),
    Muted = Color3.fromRGB(164, 166, 202),
    Accent = Color3.fromRGB(147, 72, 255),
    Accent2 = Color3.fromRGB(190, 105, 255),
    Border = Color3.fromRGB(61, 55, 105),
    Success = Color3.fromRGB(64, 220, 159),
}

local function make(className, props, parent)
    local obj = Instance.new(className)
    for key, value in pairs(props or {}) do
        obj[key] = value
    end
    obj.Parent = parent
    return obj
end

local function corner(parent, radius)
    return make("UICorner", {CornerRadius = UDim.new(0, radius)}, parent)
end

local function stroke(parent, color, thickness, transparency)
    return make("UIStroke", {
        Color = color, Thickness = thickness or 1,
        Transparency = transparency or 0,
    }, parent)
end

local function padding(parent, left, right, top, bottom)
    return make("UIPadding", {
        PaddingLeft = UDim.new(0, left or 0),
        PaddingRight = UDim.new(0, right or 0),
        PaddingTop = UDim.new(0, top or 0),
        PaddingBottom = UDim.new(0, bottom or 0),
    }, parent)
end

local function tween(object, props, duration, style)
    local ok, tw = pcall(function()
        return TweenService:Create(object, TweenInfo.new(
            math.max(0.01, duration or 0.18),
            style or Enum.EasingStyle.Quint,
            Enum.EasingDirection.Out
        ), props)
    end)
    if ok then tw:Play(); return tw end
end

local function label(parent, text, size, color, font, props)
    local p = {
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Text = text or "",
        TextSize = size or 13,
        TextColor3 = color or DEFAULT_THEME.Text,
        Font = font or Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
    }
    for k, v in pairs(props or {}) do p[k] = v end
    return make("TextLabel", p, parent)
end

local function button(parent, text, bg, textColor, size)
    return make("TextButton", {
        AutoButtonColor = false,
        Text = text or "",
        TextSize = size or 13,
        Font = Enum.Font.GothamMedium,
        TextColor3 = textColor or DEFAULT_THEME.Text,
        BackgroundColor3 = bg or DEFAULT_THEME.Card,
        BorderSizePixel = 0,
    }, parent)
end

local function resolvePlayerGui()
    local player = Players.LocalPlayer
    if not player then error("NovaPurple must be required from a LocalScript.") end
    local playerGui = player:WaitForChild("PlayerGui")
    return playerGui
end

local Window = {}
Window.__index = Window

local Tab = {}
Tab.__index = Tab

function Nova:CreateWindow(config)
    config = config or {}
    local selfWindow = setmetatable({}, Window)
    selfWindow.Name = config.Name or "NOVA PURPLE"
    selfWindow.Subtitle = config.Subtitle or "Ultimate UI Library"
    selfWindow.Theme = {}
    for k, v in pairs(DEFAULT_THEME) do selfWindow.Theme[k] = v end
    for k, v in pairs(config.Theme or {}) do
        if selfWindow.Theme[k] ~= nil and typeof(v) == "Color3" then selfWindow.Theme[k] = v end
    end
    selfWindow.Settings = {
        AnimationDuration = config.AnimationDuration or 0.2,
        CornerRadius = config.CornerRadius or 12,
        Glow = config.Glow ~= false,
    }
    selfWindow.Tabs = {}
    selfWindow.SelectedTab = nil
    selfWindow._connections = {}
    selfWindow._destroyed = false

    local pg = resolvePlayerGui()
    local old = pg:FindFirstChild("NovaPurpleUI")
    if old then old:Destroy() end

    local screen = make("ScreenGui", {
        Name = "NovaPurpleUI", ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        IgnoreGuiInset = true,
    }, pg)
    selfWindow.ScreenGui = screen

    local main = make("Frame", {
        Name = "Main", AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = config.Size or UDim2.fromOffset(720, 470),
        BackgroundColor3 = selfWindow.Theme.Background,
        BorderSizePixel = 0, ClipsDescendants = false,
    }, screen)
    selfWindow.Main = main
    local mainCorner = corner(main, selfWindow.Settings.CornerRadius)
    selfWindow._mainCorner = mainCorner
    local mainStroke = stroke(main, selfWindow.Theme.Border, 1.2, 0.12)
    selfWindow._mainStroke = mainStroke

    local glow = make("Frame", {
        Name = "Glow", Position = UDim2.new(0, -7, 0, -7),
        Size = UDim2.new(1, 14, 1, 14), BackgroundColor3 = selfWindow.Theme.Accent,
        BackgroundTransparency = selfWindow.Settings.Glow and 0.84 or 1,
        BorderSizePixel = 0, ZIndex = 0,
    }, main)
    corner(glow, selfWindow.Settings.CornerRadius + 6)
    main.ZIndex = 1
    selfWindow.GlowFrame = glow

    local top = make("Frame", {
        Name = "Topbar", Size = UDim2.new(1, 0, 0, 62),
        BackgroundColor3 = selfWindow.Theme.Panel, BorderSizePixel = 0,
        ZIndex = 2,
    }, main)
    corner(top, selfWindow.Settings.CornerRadius)
    local topMask = make("Frame", {
        Position = UDim2.new(0, 0, 1, -15), Size = UDim2.new(1, 0, 0, 15),
        BackgroundColor3 = selfWindow.Theme.Panel, BorderSizePixel = 0, ZIndex = 2,
    }, top)
    label(top, selfWindow.Name, 17, selfWindow.Theme.Text, Enum.Font.GothamBold, {
        Position = UDim2.fromOffset(20, 9), Size = UDim2.new(1, -150, 0, 24), ZIndex = 3,
    })
    label(top, selfWindow.Subtitle, 11, selfWindow.Theme.Muted, Enum.Font.Gotham, {
        Position = UDim2.fromOffset(21, 33), Size = UDim2.new(1, -150, 0, 17), ZIndex = 3,
    })
    local close = button(top, "×", selfWindow.Theme.Card, selfWindow.Theme.Text, 22)
    close.Name = "Close"
    close.Size = UDim2.fromOffset(36, 34)
    close.Position = UDim2.new(1, -48, 0, 14)
    close.ZIndex = 4
    corner(close, 9)
    close.Activated:Connect(function() selfWindow:Destroy() end)

    local sidebar = make("Frame", {
        Name = "Sidebar", Position = UDim2.fromOffset(12, 75),
        Size = UDim2.new(0, 164, 1, -88),
        BackgroundColor3 = selfWindow.Theme.Panel, BorderSizePixel = 0, ZIndex = 2,
    }, main)
    corner(sidebar, selfWindow.Settings.CornerRadius)
    padding(sidebar, 8, 8, 8, 8)
    local tabList = make("ScrollingFrame", {
        Name = "TabList", Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1, BorderSizePixel = 0,
        ScrollBarThickness = 3, ScrollBarImageColor3 = selfWindow.Theme.Accent,
        CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y,
    }, sidebar)
    local tabLayout = make("UIListLayout", {
        Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder,
    }, tabList)
    selfWindow.TabList = tabList

    local content = make("Frame", {
        Name = "Content", Position = UDim2.new(0, 188, 0, 75),
        Size = UDim2.new(1, -200, 1, -88),
        BackgroundColor3 = selfWindow.Theme.Panel, BorderSizePixel = 0, ZIndex = 2,
    }, main)
    corner(content, selfWindow.Settings.CornerRadius)
    selfWindow.Content = content

    -- Dragging is bound only to the topbar and uses InputChanged safely.
    local dragging, dragInput, dragStart, startPosition
    top.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPosition = main.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    top.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
    end)
    table.insert(selfWindow._connections, UserInputService.InputChanged:Connect(function(input)
        if dragging and (input == dragInput or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            main.Position = UDim2.new(startPosition.X.Scale, startPosition.X.Offset + delta.X, startPosition.Y.Scale, startPosition.Y.Offset + delta.Y)
        end
    end))

    -- Resizer handle in the bottom-right corner.
    local resize = button(main, "◢", selfWindow.Theme.Accent, selfWindow.Theme.Text, 13)
    resize.Name = "ResizeHandle"
    resize.Size = UDim2.fromOffset(22, 22)
    resize.Position = UDim2.new(1, -22, 1, -22)
    resize.ZIndex = 20
    corner(resize, 6)
    local resizing, resizeStart, sizeStart
    resize.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            resizing = true; resizeStart = input.Position; sizeStart = main.AbsoluteSize
        end
    end)
    table.insert(selfWindow._connections, UserInputService.InputChanged:Connect(function(input)
        if resizing and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local d = input.Position - resizeStart
            local w = math.clamp(sizeStart.X + d.X, 520, 1100)
            local h = math.clamp(sizeStart.Y + d.Y, 340, 850)
            main.Size = UDim2.fromOffset(w, h)
        end
    end))
    table.insert(selfWindow._connections, UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then resizing = false end
    end))

    selfWindow._tabList = tabList
    selfWindow._tabLayout = tabLayout
    selfWindow._mainCorner = mainCorner
    selfWindow._topbar = top
    selfWindow._sidebar = sidebar
    selfWindow._content = content
    selfWindow:_buildSettingsTab()
    return selfWindow
end

function Window:_selectTab(tab)
    if self._destroyed then return end
    self.SelectedTab = tab
    for _, item in ipairs(self.Tabs) do
        local active = item == tab
        item.Page.Visible = active
        tween(item.Button, {
            BackgroundColor3 = active and self.Theme.Accent or self.Theme.Card,
            TextColor3 = active and Color3.new(1, 1, 1) or self.Theme.Muted,
        }, self.Settings.AnimationDuration)
        item.Button:SetAttribute("Selected", active)
    end
end

function Window:CreateTab(config)
    config = config or {}
    local tab = setmetatable({}, Tab)
    tab.Window = self
    tab.Name = config.Name or ("Tab " .. tostring(#self.Tabs + 1))
    tab._order = #self.Tabs + 1
    tab.Button = button(self._tabList, (config.Icon and (config.Icon .. "  ") or "") .. tab.Name, self.Theme.Card, self.Theme.Muted, 12)
    tab.Button.Name = "Tab_" .. tab.Name
    tab.Button.Size = UDim2.new(1, 0, 0, 36)
    tab.Button.TextXAlignment = Enum.TextXAlignment.Left
    tab.Button.LayoutOrder = tab._order
    padding(tab.Button, 10, 6, 0, 0)
    corner(tab.Button, self.Settings.CornerRadius)
    tab.Page = make("ScrollingFrame", {
        Name = "Page_" .. tab.Name, Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1, BorderSizePixel = 0, Visible = false,
        ScrollBarThickness = 4, ScrollBarImageColor3 = self.Theme.Accent,
        CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y,
    }, self._content)
    padding(tab.Page, 14, 14, 14, 14)
    tab.Layout = make("UIListLayout", {
        Padding = UDim.new(0, 9), SortOrder = Enum.SortOrder.LayoutOrder,
    }, tab.Page)
    tab.Button.Activated:Connect(function() self:_selectTab(tab) end)
    table.insert(self.Tabs, tab)
    self:_selectTab(tab)
    return tab
end

function Tab:_card(height, title, description)
    local win = self.Window
    local card = make("Frame", {
        Size = UDim2.new(1, -2, 0, height), BackgroundColor3 = win.Theme.Card,
        BorderSizePixel = 0,
    }, self.Page)
    corner(card, win.Settings.CornerRadius)
    stroke(card, win.Theme.Border, 1, 0.55)
    if title then
        label(card, title, 13, win.Theme.Text, Enum.Font.GothamSemibold, {
            Position = UDim2.fromOffset(13, 8), Size = UDim2.new(1, -26, 0, 20),
        })
    end
    if description then
        label(card, description, 11, win.Theme.Muted, Enum.Font.Gotham, {
            Position = UDim2.fromOffset(13, 28), Size = UDim2.new(1, -26, 0, 18),
        })
    end
    return card
end

function Tab:CreateSection(config)
    config = config or {}
    local t = label(self.Page, config.Name or "SECTION", 11, self.Window.Theme.Accent2, Enum.Font.GothamBold, {
        Size = UDim2.new(1, -4, 0, 23),
    })
    return t
end

function Tab:CreateLabel(config)
    config = config or {}
    local card = self:_card(38)
    label(card, config.Text or config.Name or "Label", 12, self.Window.Theme.Text, Enum.Font.Gotham, {
        Position = UDim2.fromOffset(12, 0), Size = UDim2.new(1, -24, 1, 0),
    })
    return card
end

function Tab:CreateParagraph(config)
    config = config or {}
    local card = self:_card(config.Height or 78, config.Title or config.Name or "Information", config.Content or config.Text or "")
    local desc = card:FindFirstChildWhichIsA("TextLabel")
    if desc then
        desc.TextWrapped = true
        desc.TextYAlignment = Enum.TextYAlignment.Top
        desc.Size = UDim2.new(1, -26, 1, -35)
    end
    return card
end

function Tab:CreateButton(config)
    config = config or {}
    local win = self.Window
    local card = self:_card(48)
    local b = button(card, config.Name or "Button", win.Theme.CardHover, win.Theme.Text, 12)
    b.Size = UDim2.new(1, -18, 0, 30)
    b.Position = UDim2.fromOffset(9, 9)
    corner(b, win.Settings.CornerRadius)
    b.Activated:Connect(function()
        tween(b, {BackgroundColor3 = win.Theme.Accent}, win.Settings.AnimationDuration)
        task.delay(win.Settings.AnimationDuration, function()
            if b.Parent then tween(b, {BackgroundColor3 = win.Theme.CardHover}, win.Settings.AnimationDuration) end
        end)
        if typeof(config.Callback) == "function" then task.spawn(config.Callback) end
    end)
    return card
end

function Tab:CreateToggle(config)
    config = config or {}
    local win = self.Window
    local value = config.Default == true
    local card = self:_card(48, config.Name or "Toggle", config.Description)
    local track = make("Frame", {
        Size = UDim2.fromOffset(42, 22), Position = UDim2.new(1, -54, 0, 13),
        BackgroundColor3 = value and win.Theme.Accent or win.Theme.Border, BorderSizePixel = 0,
    }, card)
    corner(track, 11)
    local knob = make("Frame", {
        Size = UDim2.fromOffset(16, 16), Position = value and UDim2.new(1, -19, 0, 3) or UDim2.fromOffset(3, 3),
        BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0,
    }, track)
    corner(knob, 8)
    local hit = button(card, "", Color3.new(1, 1, 1), Color3.new(1, 1, 1), 1)
    hit.BackgroundTransparency = 1
    hit.Size = UDim2.new(1, 0, 1, 0)
    hit.ZIndex = 5
    hit.Activated:Connect(function()
        value = not value
        tween(track, {BackgroundColor3 = value and win.Theme.Accent or win.Theme.Border}, win.Settings.AnimationDuration)
        tween(knob, {Position = value and UDim2.new(1, -19, 0, 3) or UDim2.fromOffset(3, 3)}, win.Settings.AnimationDuration)
        if typeof(config.Callback) == "function" then task.spawn(config.Callback, value) end
    end)
    local api = {}
    function api:Set(v, silent)
        value = v == true
        track.BackgroundColor3 = value and win.Theme.Accent or win.Theme.Border
        knob.Position = value and UDim2.new(1, -19, 0, 3) or UDim2.fromOffset(3, 3)
        if not silent and typeof(config.Callback) == "function" then config.Callback(value) end
    end
    function api:Get() return value end
    return api
end

function Tab:CreateSlider(config)
    config = config or {}
    local win = self.Window
    local min, max = config.Min or 0, config.Max or 100
    if max <= min then max = min + 1 end
    local value = math.clamp(config.Default or min, min, max)
    local card = self:_card(66, config.Name or "Slider", tostring(value))
    local valueLabel = card:FindFirstChildWhichIsA("TextLabel")
    if valueLabel then valueLabel.TextXAlignment = Enum.TextXAlignment.Right end
    local bar = make("Frame", {
        Position = UDim2.new(0, 13, 0, 43), Size = UDim2.new(1, -26, 0, 7),
        BackgroundColor3 = win.Theme.Border, BorderSizePixel = 0,
    }, card)
    corner(bar, 4)
    local fill = make("Frame", {
        Size = UDim2.new((value-min)/(max-min), 0, 1, 0),
        BackgroundColor3 = win.Theme.Accent, BorderSizePixel = 0,
    }, bar)
    corner(fill, 4)
    local knob = make("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new((value-min)/(max-min), 0, 0.5, 0),
        Size = UDim2.fromOffset(13, 13), BackgroundColor3 = win.Theme.Text, BorderSizePixel = 0,
    }, bar)
    corner(knob, 7)
    local dragging = false
    local function setFromX(x)
        local alpha = math.clamp((x - bar.AbsolutePosition.X) / math.max(1, bar.AbsoluteSize.X), 0, 1)
        value = min + (max - min) * alpha
        if config.Decimals == 0 then value = math.floor(value + 0.5)
        else value = math.floor(value * 100 + 0.5) / 100 end
        local a = (value - min) / (max - min)
        fill.Size = UDim2.new(a, 0, 1, 0); knob.Position = UDim2.new(a, 0, 0.5, 0)
        if valueLabel then valueLabel.Text = tostring(value) end
        if typeof(config.Callback) == "function" then task.spawn(config.Callback, value) end
    end
    bar.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = true; setFromX(i.Position.X) end
    end)
    local moveConn = UserInputService.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then setFromX(i.Position.X) end
    end)
    local endConn = UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = false end
    end)
    table.insert(win._connections, moveConn); table.insert(win._connections, endConn)
    return {
        Get = function() return value end,
        Set = function(_, v, silent)
            value = math.clamp(tonumber(v) or min, min, max)
            local a = (value-min)/(max-min)
            fill.Size = UDim2.new(a,0,1,0); knob.Position = UDim2.new(a,0,0.5,0)
            if valueLabel then valueLabel.Text = tostring(value) end
            if not silent and typeof(config.Callback) == "function" then config.Callback(value) end
        end,
    }
end

function Tab:CreateDropdown(config)
    config = config or {}
    local win = self.Window
    local options = config.Options or {}
    local selected = config.Default or options[1] or "Select..."
    local expanded = false
    local card = self:_card(48, config.Name or "Dropdown")
    local selectButton = button(card, tostring(selected) .. "  ▾", win.Theme.CardHover, win.Theme.Text, 11)
    selectButton.Size = UDim2.new(0.48, 0, 0, 28)
    selectButton.Position = UDim2.new(0.5, -2, 0, 10)
    corner(selectButton, win.Settings.CornerRadius)
    local optionBox = make("Frame", {
        Visible = false, Position = UDim2.new(0.5, -2, 1, 3), Size = UDim2.new(0.5, -10, 0, 0),
        BackgroundColor3 = win.Theme.Panel, BorderSizePixel = 0, ZIndex = 15,
    }, card)
    corner(optionBox, win.Settings.CornerRadius); stroke(optionBox, win.Theme.Border, 1)
    local optionLayout = make("UIListLayout", {Padding = UDim.new(0, 3)}, optionBox)
    local function rebuild()
        for _, c in ipairs(optionBox:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end
        for _, option in ipairs(options) do
            local ob = button(optionBox, tostring(option), win.Theme.Card, win.Theme.Text, 11)
            ob.Size = UDim2.new(1, -8, 0, 25); ob.Position = UDim2.fromOffset(4, 0); ob.ZIndex = 16
            corner(ob, 6)
            ob.Activated:Connect(function()
                selected = option; selectButton.Text = tostring(selected) .. "  ▾"
                expanded = false; optionBox.Visible = false
                if typeof(config.Callback) == "function" then task.spawn(config.Callback, selected) end
            end)
        end
        optionBox.Size = UDim2.new(0.5, -10, 0, math.min(#options * 28 + 6, 140))
    end
    rebuild()
    selectButton.Activated:Connect(function()
        expanded = not expanded; optionBox.Visible = expanded
        if expanded then optionBox.ZIndex = 15 end
    end)
    return {
        Get = function() return selected end,
        Set = function(_, v, silent)
            if table.find(options, v) then
                selected = v; selectButton.Text = tostring(v) .. "  ▾"
                if not silent and typeof(config.Callback) == "function" then config.Callback(v) end
            end
        end,
        Refresh = function(_, newOptions)
            options = newOptions or {}; rebuild()
            if not table.find(options, selected) then selected = options[1] or "Select..."; selectButton.Text = tostring(selected) .. "  ▾" end
        end,
    }
end

function Tab:CreateInput(config)
    config = config or {}
    local win = self.Window
    local card = self:_card(48, config.Name or "Input", config.Description)
    local box = make("TextBox", {
        Size = UDim2.new(0.5, -12, 0, 28), Position = UDim2.new(0.5, 0, 0, 10),
        BackgroundColor3 = win.Theme.CardHover, BorderSizePixel = 0,
        Text = config.Default or "", PlaceholderText = config.Placeholder or "Enter text...",
        PlaceholderColor3 = win.Theme.Muted, TextColor3 = win.Theme.Text, TextSize = 11,
        Font = Enum.Font.Gotham, ClearTextOnFocus = false,
    }, card)
    corner(box, win.Settings.CornerRadius); padding(box, 8, 8, 0, 0)
    box.FocusLost:Connect(function(enterPressed)
        if typeof(config.Callback) == "function" then task.spawn(config.Callback, box.Text, enterPressed) end
    end)
    return {Get = function() return box.Text end, Set = function(_, v) box.Text = tostring(v) end}
end

function Tab:CreateColorPicker(config)
    config = config or {}
    local win = self.Window
    local color = config.Default or win.Theme.Accent
    local card = self:_card(48, config.Name or "Color picker", "Click the swatch to open the color palette")
    local swatch = button(card, "", color, Color3.new(1,1,1), 12)
    swatch.Size = UDim2.fromOffset(56, 28); swatch.Position = UDim2.new(1, -68, 0, 10)
    corner(swatch, win.Settings.CornerRadius)
    local palette = make("Frame", {
        Visible = false, Position = UDim2.new(1, -220, 1, 4), Size = UDim2.fromOffset(208, 158),
        BackgroundColor3 = win.Theme.Panel, BorderSizePixel = 0, ZIndex = 30,
    }, card)
    corner(palette, win.Settings.CornerRadius); stroke(palette, win.Theme.Border, 1)
    local hue = 0
    local h,s,v = color:ToHSV(); hue = h
    local preview = make("Frame", {
        Position = UDim2.fromOffset(10, 10), Size = UDim2.new(1, -20, 0, 22),
        BackgroundColor3 = color, BorderSizePixel = 0, ZIndex = 31,
    }, palette)
    corner(preview, 5)
    local rainbow = make("Frame", {
        Position = UDim2.fromOffset(10, 42), Size = UDim2.new(1, -20, 0, 18),
        BackgroundColor3 = Color3.new(1,1,1), BorderSizePixel = 0, ZIndex = 31,
    }, palette)
    corner(rainbow, 5)
    local gradient = make("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255,0,0)),
            ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255,255,0)),
            ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0,255,0)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0,255,255)),
            ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0,0,255)),
            ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255,0,255)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(255,0,0)),
        }),
    }, rainbow)
    local shade = make("Frame", {
        Position = UDim2.fromOffset(10, 68), Size = UDim2.new(1, -20, 0, 18),
        BackgroundColor3 = Color3.new(1,1,1), BorderSizePixel = 0, ZIndex = 31,
    }, palette)
    corner(shade, 5)
    local shadeGrad = make("UIGradient", {
        Color = ColorSequence.new(Color3.new(1,1,1), Color3.new(0,0,0)),
    }, shade)
    local function updateColor()
        color = Color3.fromHSV(hue, s, v)
        swatch.BackgroundColor3 = color; preview.BackgroundColor3 = color
        shade.BackgroundColor3 = Color3.fromHSV(hue, 1, 1)
        if typeof(config.Callback) == "function" then task.spawn(config.Callback, color) end
    end
    local hueButton = button(rainbow, "", Color3.new(1,1,1), Color3.new(1,1,1), 1)
    hueButton.BackgroundTransparency = 1; hueButton.Size = UDim2.fromScale(1,1); hueButton.ZIndex = 32
    local shadeButton = button(shade, "", Color3.new(1,1,1), Color3.new(1,1,1), 1)
    shadeButton.BackgroundTransparency = 1; shadeButton.Size = UDim2.fromScale(1,1); shadeButton.ZIndex = 32
    local function bindDrag(target, callback)
        local active = false
        target.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then active = true; callback(i.Position.X) end
        end)
        local move = UserInputService.InputChanged:Connect(function(i)
            if active and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then callback(i.Position.X) end
        end)
        local finish = UserInputService.InputEnded:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then active = false end
        end)
        table.insert(win._connections, move); table.insert(win._connections, finish)
    end
    bindDrag(hueButton, function(x)
        hue = math.clamp((x-rainbow.AbsolutePosition.X)/math.max(1,rainbow.AbsoluteSize.X),0,1); updateColor()
    end)
    bindDrag(shadeButton, function(x)
        local a = math.clamp((x-shade.AbsolutePosition.X)/math.max(1,shade.AbsoluteSize.X),0,1)
        s = 1-a; v = 1; updateColor()
    end)
    local hex = make("TextBox", {
        Position = UDim2.fromOffset(10, 98), Size = UDim2.new(1, -20, 0, 25),
        BackgroundColor3 = win.Theme.Card, BorderSizePixel = 0, Text = "#9372FF",
        PlaceholderText = "#RRGGBB", TextColor3 = win.Theme.Text, TextSize = 11,
        Font = Enum.Font.Gotham, ClearTextOnFocus = false, ZIndex = 31,
    }, palette)
    corner(hex, 5)
    hex.FocusLost:Connect(function()
        local raw = hex.Text:gsub("#", "")
        if #raw == 6 then
            local r,g,b = tonumber(raw:sub(1,2),16), tonumber(raw:sub(3,4),16), tonumber(raw:sub(5,6),16)
            if r and g and b then
                color = Color3.fromRGB(r,g,b); hue,s,v = color:ToHSV(); updateColor()
            end
        end
    end)
    local done = button(palette, "Done", win.Theme.Accent, win.Theme.Text, 11)
    done.Position = UDim2.new(0, 10, 1, -28); done.Size = UDim2.new(1, -20, 0, 20); done.ZIndex = 31
    corner(done, 5)
    done.Activated:Connect(function() palette.Visible = false end)
    swatch.Activated:Connect(function() palette.Visible = not palette.Visible end)
    return {
        Get = function() return color end,
        Set = function(_, c, silent)
            if typeof(c) == "Color3" then
                color = c; hue,s,v = c:ToHSV()
                swatch.BackgroundColor3 = c; preview.BackgroundColor3 = c; shade.BackgroundColor3 = Color3.fromHSV(hue,1,1)
                if not silent and typeof(config.Callback) == "function" then config.Callback(c) end
            end
        end,
    }
end

function Window:_buildSettingsTab()
    local tab = self:CreateTab({Name = "Настройки", Icon = "⚙"})
    tab:CreateSection({Name = "ВНЕШНИЙ ВИД"})
    tab:CreateSlider({
        Name = "Закругления", Min = 0, Max = 24, Default = self.Settings.CornerRadius, Decimals = 0,
        Callback = function(v) self:SetCornerRadius(v) end,
    })
    tab:CreateSlider({
        Name = "Длительность анимации", Min = 0, Max = 0.8, Default = self.Settings.AnimationDuration, Decimals = 2,
        Callback = function(v) self:SetAnimationDuration(v) end,
    })
    tab:CreateToggle({
        Name = "Свечение", Default = self.Settings.Glow,
        Callback = function(v) self:SetGlow(v) end,
    })
    tab:CreateColorPicker({
        Name = "Акцентный цвет", Default = self.Theme.Accent,
        Callback = function(c) self:SetTheme({Accent = c, Accent2 = c}) end,
    })
    tab:CreateSection({Name = "РАЗМЕР ОКНА"})
    tab:CreateSlider({
        Name = "Ширина", Min = 520, Max = 1100, Default = self.Main.AbsoluteSize.X, Decimals = 0,
        Callback = function(v) self:SetSize(v, self.Main.AbsoluteSize.Y) end,
    })
    tab:CreateSlider({
        Name = "Высота", Min = 340, Max = 850, Default = self.Main.AbsoluteSize.Y, Decimals = 0,
        Callback = function(v) self:SetSize(self.Main.AbsoluteSize.X, v) end,
    })
end

function Window:SetSize(width, height)
    if self.Main and self.Main.Parent then
        self.Main.Size = UDim2.fromOffset(math.clamp(width or 720, 520, 1100), math.clamp(height or 470, 340, 850))
    end
end

function Window:SetCornerRadius(radius)
    radius = math.clamp(tonumber(radius) or 12, 0, 24)
    self.Settings.CornerRadius = radius
    if self._mainCorner then self._mainCorner.CornerRadius = UDim.new(0, radius) end
    if self.GlowFrame then
        local c = self.GlowFrame:FindFirstChildWhichIsA("UICorner")
        if c then c.CornerRadius = UDim.new(0, radius + 6) end
    end
    for _, obj in ipairs(self.ScreenGui:GetDescendants()) do
        if obj:IsA("UICorner") and obj.Parent ~= self.GlowFrame then
            obj.CornerRadius = UDim.new(0, radius)
        end
    end
end

function Window:SetAnimationDuration(duration)
    self.Settings.AnimationDuration = math.clamp(tonumber(duration) or 0.2, 0, 0.8)
end

function Window:SetGlow(enabled)
    self.Settings.Glow = enabled == true
    if self.GlowFrame then
        tween(self.GlowFrame, {
            BackgroundTransparency = self.Settings.Glow and 0.84 or 1,
            BackgroundColor3 = self.Theme.Accent,
        }, self.Settings.AnimationDuration)
    end
end

function Window:SetTheme(theme)
    theme = theme or {}
    for key, value in pairs(theme) do
        if self.Theme[key] ~= nil and typeof(value) == "Color3" then self.Theme[key] = value end
    end
    local t = self.Theme
    if self.Main then self.Main.BackgroundColor3 = t.Background end
    if self._topbar then self._topbar.BackgroundColor3 = t.Panel end
    if self._sidebar then self._sidebar.BackgroundColor3 = t.Panel end
    if self._content then self._content.BackgroundColor3 = t.Panel end
    if self.GlowFrame then self.GlowFrame.BackgroundColor3 = t.Accent end
    if self._mainStroke then self._mainStroke.Color = t.Border end
    for _, obj in ipairs(self.ScreenGui:GetDescendants()) do
        if obj:IsA("UIStroke") then obj.Color = t.Border end
        if obj:IsA("TextButton") and obj.Name:match("^Tab_") then
            local active = obj:GetAttribute("Selected") == true
            obj.BackgroundColor3 = active and t.Accent or t.Card
            obj.TextColor3 = active and Color3.new(1,1,1) or t.Muted
        end
    end
end

function Window:Toggle()
    if self.Main then self.Main.Visible = not self.Main.Visible end
end

function Window:Destroy()
    if self._destroyed then return end
    self._destroyed = true
    for _, connection in ipairs(self._connections) do
        pcall(function() connection:Disconnect() end)
    end
    if self.ScreenGui then self.ScreenGui:Destroy() end
end

function Nova:GetTheme()
    local copy = {}
    for k, v in pairs(DEFAULT_THEME) do copy[k] = v end
    return copy
end

return setmetatable(Nova, Nova)
