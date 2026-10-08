--[[
    SoloScriptHub — By set33p
    Features: FPS & Ping trackers, Dynamic Theme Color, Language Switcher, 3 Open Modes, Resizer, Smooth Animations.
]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")

local LocalPlayer = Players.LocalPlayer

-- UI Setup
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SoloScriptHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

if syn and syn.protect_gui then
    syn.protect_gui(ScreenGui)
    ScreenGui.Parent = game:GetService("CoreGui")
elseif gethui then
    ScreenGui.Parent = gethui()
else
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

-- Основные настройки темы
local currentAccentColor = Color3.fromRGB(138, 43, 226) -- Фиолетовый по умолчанию
local currentLang = "RU"
local currentMode = "Вотермарк"

-- Main Window Frame
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 580, 0, 380)
MainFrame.Position = UDim2.new(0.5, -290, 0.5, -190)
MainFrame.BackgroundColor3 = Color3.fromRGB(14, 14, 20)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner", MainFrame)
MainCorner.CornerRadius = UDim.new(0, 10)

local MainStroke = Instance.new("UIStroke", MainFrame)
MainStroke.Color = currentAccentColor
MainStroke.Transparency = 0.4
MainStroke.Thickness = 1.5

-- Top Bar
local TopBar = Instance.new("Frame", MainFrame)
TopBar.Size = UDim2.new(1, 0, 0, 45)
TopBar.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
TopBar.BorderSizePixel = 0

local TopCorner = Instance.new("UICorner", TopBar)
TopCorner.CornerRadius = UDim.new(0, 10)

local TopFill = Instance.new("Frame", TopBar)
TopFill.Size = UDim2.new(1, 0, 0, 10)
TopFill.Position = UDim2.new(0, 0, 1, -10)
TopFill.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
TopFill.BorderSizePixel = 0

-- Заголовок и брэндинг SoloScriptHub
local Title = Instance.new("TextLabel", TopBar)
Title.Size = UDim2.new(0, 200, 0, 20)
Title.Position = UDim2.new(0, 15, 0, 6)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.GothamBold
Title.Text = "SoloScriptHub"
Title.TextColor3 = Color3.fromRGB(240, 240, 255)
Title.TextSize = 13
Title.TextXAlignment = Enum.TextXAlignment.Left

local Subtitle = Instance.new("TextLabel", TopBar)
Subtitle.Size = UDim2.new(0, 200, 0, 15)
Subtitle.Position = UDim2.new(0, 15, 0, 24)
Subtitle.BackgroundTransparency = 1
Subtitle.Font = Enum.Font.Gotham
Subtitle.Text = "By set33p • Violence District"
Subtitle.TextColor3 = Color3.fromRGB(150, 150, 180)
Subtitle.TextSize = 10
Subtitle.TextXAlignment = Enum.TextXAlignment.Left

-- FPS & Ping Counter в шапке
local StatsHolder = Instance.new("Frame", TopBar)
StatsHolder.Size = UDim2.new(0, 130, 0, 26)
StatsHolder.Position = UDim2.new(1, -250, 0.5, -13)
StatsHolder.BackgroundTransparency = 1

local StatsLayout = Instance.new("UIListLayout", StatsHolder)
StatsLayout.FillDirection = Enum.FillDirection.Horizontal
StatsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
StatsLayout.SortOrder = Enum.SortOrder.LayoutOrder
StatsLayout.Padding = UDim.new(0, 8)

local function createStatPill(text)
    local pill = Instance.new("TextLabel", StatsHolder)
    pill.Size = UDim2.new(0, 58, 1, 0)
    pill.BackgroundColor3 = Color3.fromRGB(26, 26, 36)
    pill.Text = text
    pill.TextColor3 = Color3.fromRGB(200, 200, 220)
    pill.TextSize = 11
    pill.Font = Enum.Font.GothamSemibold
    Instance.new("UICorner", pill).CornerRadius = UDim.new(0, 6)
    return pill
end

local FpsPill = createStatPill("FPS: --")
local PingPill = createStatPill("Ping: --")

-- Обновление FPS и Ping в реальном времени
local lastUpdate = 0
RunService.RenderStepped:Connect(function(dt)
    if tick() - lastUpdate > 0.5 then
        lastUpdate = tick()
        local fps = math.floor(1 / dt)
        local ping = 0
        pcall(function()
            ping = math.floor(LocalPlayer.GetNetworkPing(LocalPlayer) * 1000)
        end)
        FpsPill.Text = "FPS: " .. fps
        PingPill.Text = "Ms: " .. ping
    end
end)

-- Кнопки управления окном
local ButtonHolder = Instance.new("Frame", TopBar)
ButtonHolder.Size = UDim2.new(0, 110, 0, 30)
ButtonHolder.Position = UDim2.new(1, -115, 0.5, -15)
ButtonHolder.BackgroundTransparency = 1

local ButtonLayout = Instance.new("UIListLayout", ButtonHolder)
ButtonLayout.FillDirection = Enum.FillDirection.Horizontal
ButtonLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
ButtonLayout.SortOrder = Enum.SortOrder.LayoutOrder
ButtonLayout.Padding = UDim.new(0, 6)

local function createWindowIconBtn(svgPath, colorHover, callback)
    local btn = Instance.new("TextButton", ButtonHolder)
    btn.Size = UDim2.new(0, 28, 0, 28)
    btn.BackgroundColor3 = Color3.fromRGB(28, 28, 38)
    btn.Text = ""
    btn.BorderSizePixel = 0
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

    local icon = Instance.new("ImageLabel", btn)
    icon.Size = UDim2.new(0, 12, 0, 12)
    icon.Position = UDim2.new(0.5, -6, 0.5, -6)
    icon.BackgroundTransparency = 1
    icon.Image = svgPath
    icon.ImageColor3 = Color3.fromRGB(180, 180, 200)

    btn.MouseEnter:Connect(function()
        TweenService:Create(icon, TweenInfo.new(0.2), {ImageColor3 = colorHover}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(icon, TweenInfo.new(0.2), {ImageColor3 = Color3.fromRGB(180, 180, 200)}):Play()
    end)

    btn.MouseButton1Click:Connect(callback)
    return btn
end

local iconMinimize = "rbxassetid://6035047409"
local iconMaximize = "rbxassetid://6035047894"
local iconClose = "rbxassetid://6035047082"

local isMinimized = false
local isMaximized = false
local normalSize = MainFrame.Size
local normalPos = MainFrame.Position

createWindowIconBtn(iconMinimize, Color3.fromRGB(255, 255, 255), function()
    isMinimized = not isMinimized
    local targetSize = isMinimized and UDim2.new(0, MainFrame.AbsoluteSize.X, 0, 45) or normalSize
    TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = targetSize}):Play()
end)

createWindowIconBtn(iconMaximize, Color3.fromRGB(120, 220, 140), function()
    isMaximized = not isMaximized
    if isMaximized then
        normalSize = MainFrame.Size
        normalPos = MainFrame.Position
        TweenService:Create(MainFrame, TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 800, 0, 520),
            Position = UDim2.new(0.5, -400, 0.5, -260)
        }):Play()
    else
        TweenService:Create(MainFrame, TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
            Size = normalSize,
            Position = normalPos
        }):Play()
    end
end)

createWindowIconBtn(iconClose, Color3.fromRGB(255, 90, 90), function()
    local tw = TweenService:Create(MainFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {Size = UDim2.new(0, 0, 0, 0)})
    tw:Play()
    tw.Completed:Connect(function()
        ScreenGui:Destroy()
    end)
end)

-- Боковое меню (Sidebar)
local Sidebar = Instance.new("ScrollingFrame", MainFrame)
Sidebar.Size = UDim2.new(0, 165, 1, -55)
Sidebar.Position = UDim2.new(0, 10, 0, 50)
Sidebar.BackgroundTransparency = 1
Sidebar.BorderSizePixel = 0
Sidebar.CanvasSize = UDim2.new(0, 0, 1.3, 0)
Sidebar.ScrollBarThickness = 2

local SideLayout = Instance.new("UIListLayout", Sidebar)
SideLayout.SortOrder = Enum.SortOrder.LayoutOrder
SideLayout.Padding = UDim.new(0, 6)

-- Поиск
local SearchBox = Instance.new("TextBox", Sidebar)
SearchBox.Size = UDim2.new(1, -5, 0, 36)
SearchBox.BackgroundColor3 = Color3.fromRGB(22, 22, 32)
SearchBox.BorderSizePixel = 0
SearchBox.PlaceholderText = "🔍 Поиск функций..."
SearchBox.Text = ""
SearchBox.TextColor3 = Color3.fromRGB(240, 240, 250)
SearchBox.PlaceholderColor3 = Color3.fromRGB(120, 120, 150)
SearchBox.TextSize = 12
SearchBox.Font = Enum.Font.Gotham
SearchBox.TextXAlignment = Enum.TextXAlignment.Left
Instance.new("UICorner", SearchBox).CornerRadius = UDim.new(0, 8)

-- Контейнер страниц
local PagesContainer = Instance.new("Folder", MainFrame)
PagesContainer.Name = "PagesContainer"

local function createPageContent()
    local container = Instance.new("ScrollingFrame", MainFrame)
    container.Size = UDim2.new(1, -190, 1, -55)
    container.Position = UDim2.new(0, 180, 0, 50)
    container.BackgroundTransparency = 1
    container.BorderSizePixel = 0
    container.CanvasSize = UDim2.new(0, 0, 2, 0)
    container.ScrollBarThickness = 3
    container.ScrollBarImageColor3 = currentAccentColor
    container.Visible = false
    container.Parent = PagesContainer

    local layout = Instance.new("UIListLayout", container)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 10)
    return container
end

local pagePlayer = createPageContent()
local pageESP = createPageContent()
local pageCombat = createPageContent()
local pageVisual = createPageContent()
local pageSettings = createPageContent()
pagePlayer.Visible = true

local tabs = {}
local function createTabButton(name, icon, pageTarget)
    local btn = Instance.new("TextButton", Sidebar)
    btn.Size = UDim2.new(1, -5, 0, 36)
    btn.BackgroundColor3 = Color3.fromRGB(22, 22, 32)
    btn.BorderSizePixel = 0
    btn.Text = "   " .. icon .. "   " .. name
    btn.TextColor3 = Color3.fromRGB(170, 170, 190)
    btn.TextSize = 12
    btn.Font = Enum.Font.GothamSemibold
    btn.TextXAlignment = Enum.TextXAlignment.Left
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)

    btn.MouseButton1Click:Connect(function()
        for _, p in pairs(PagesContainer:GetChildren()) do p.Visible = false end
        for _, t in pairs(tabs) do 
            TweenService:Create(t, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {BackgroundColor3 = Color3.fromRGB(22, 22, 32), TextColor3 = Color3.fromRGB(170, 170, 190)}):Play()
        end
        pageTarget.Visible = true
        TweenService:Create(btn, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {BackgroundColor3 = currentAccentColor, TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
    end)
    table.insert(tabs, btn)
    return btn
end

local function createSectionHeader(parent, title)
    local header = Instance.new("TextLabel", parent)
    header.Size = UDim2.new(1, 0, 0, 25)
    header.BackgroundTransparency = 1
    header.Font = Enum.Font.GothamBold
    header.Text = "  ⚡ " .. title
    header.TextColor3 = Color3.fromRGB(180, 130, 255)
    header.TextSize = 13
    header.TextXAlignment = Enum.TextXAlignment.Left
end

local function createToggle(parent, title, desc, callback)
    local frame = Instance.new("Frame", parent)
    frame.Size = UDim2.new(1, -10, 0, 50)
    frame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    frame.BorderSizePixel = 0
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)

    local lbl = Instance.new("TextLabel", frame)
    lbl.Size = UDim2.new(1, -75, 0, 20)
    lbl.Position = UDim2.new(0, 14, 0, 7)
    lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.GothamBold
    lbl.Text = title
    lbl.TextColor3 = Color3.fromRGB(235, 235, 245)
    lbl.TextSize = 12
    lbl.TextXAlignment = Enum.TextXAlignment.Left

    local descLbl = Instance.new("TextLabel", frame)
    descLbl.Size = UDim2.new(1, -75, 0, 16)
    descLbl.Position = UDim2.new(0, 14, 0, 26)
    descLbl.BackgroundTransparency = 1
    descLbl.Font = Enum.Font.Gotham
    descLbl.Text = desc
    descLbl.TextColor3 = Color3.fromRGB(130, 130, 155)
    descLbl.TextSize = 10
    descLbl.TextXAlignment = Enum.TextXAlignment.Left

    local toggleBtn = Instance.new("TextButton", frame)
    toggleBtn.Size = UDim2.new(0, 46, 0, 24)
    toggleBtn.Position = UDim2.new(1, -56, 0.5, -12)
    toggleBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
    toggleBtn.Text = ""
    toggleBtn.BorderSizePixel = 0
    Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(1, 0)

    local circle = Instance.new("Frame", toggleBtn)
    circle.Size = UDim2.new(0, 18, 0, 18)
    circle.Position = UDim2.new(0, 3, 0.5, -9)
    circle.BackgroundColor3 = Color3.fromRGB(200, 200, 220)
    Instance.new("UICorner", circle).CornerRadius = UDim.new(1, 0)

    local state = false
    toggleBtn.MouseButton1Click:Connect(function()
        state = not state
        local goalColor = state and currentAccentColor or Color3.fromRGB(35, 35, 50)
        local goalPos = state and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)
        
        TweenService:Create(toggleBtn, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {BackgroundColor3 = goalColor}):Play()
        TweenService:Create(circle, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {Position = goalPos}):Play()
        
        pcall(callback, state)
    end)
end

-- Вкладки
createTabButton("Player", "👤", pagePlayer)
createTabButton("ESP", "👁", pageESP)
createTabButton("Combat", "⚔", pageCombat)
createTabButton("Visual", "✨", pageVisual)
createTabButton("Settings", "⚙", pageSettings)

-- Элементы функционала
createSectionHeader(pagePlayer, "Movements & Physics")
createToggle(pagePlayer, "Walk Speed", "Enable custom speed modification", function(state)
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = state and 32 or 16
    end
end)

createSectionHeader(pageESP, "Visual Overlays")
createToggle(pageESP, "Player ESP", "Highlights all enemies through walls", function(state)
    print("ESP Status: ", state)
end)

createSectionHeader(pageCombat, "Aim & Accuracy")
createToggle(pageCombat, "Silent Aim", "Redirects shots to target automatically", function(state)
    print("Silent Aim: ", state)
end)

-- НАСТРОЙКИ (Settings Tab): Цвет, Язык, Способ открытия
createSectionHeader(pageSettings, "Theme Customization")

-- Выбор цвета темы
local function createColorOption(name, col)
    local btn = Instance.new("TextButton", pageSettings)
    btn.Size = UDim2.new(1, -10, 0, 40)
    btn.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    btn.Text = "   🎨 Theme Accent: " .. name
    btn.TextColor3 = Color3.fromRGB(235, 235, 245)
    btn.TextSize = 12
    btn.Font = Enum.Font.GothamBold
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.BorderSizePixel = 0
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)

    local indicator = Instance.new("Frame", btn)
    indicator.Size = UDim2.new(0, 24, 0, 24)
    indicator.Position = UDim2.new(1, -34, 0.5, -12)
    indicator.BackgroundColor3 = col
    Instance.new("UICorner", indicator).CornerRadius = UDim.new(1, 0)

    btn.MouseButton1Click:Connect(function()
        currentAccentColor = col
        MainStroke.Color = currentAccentColor
        for _, p in pairs(PagesContainer:GetChildren()) do
            p.ScrollBarImageColor3 = currentAccentColor
        end
    end)
end

createColorOption("Purple (Default)", Color3.fromRGB(138, 43, 226))
createColorOption("Neon Blue", Color3.fromRGB(0, 150, 255))
createColorOption("Emerald Green", Color3.fromRGB(40, 200, 100))
createSectionHeader(pageSettings, "Localization & Interface")

-- Изменение языка
local langBtn = Instance.new("TextButton", pageSettings)
langBtn.Size = UDim2.new(1, -10, 0, 40)
langBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
langBtn.Text = "   🌐 Language: Русский (RU)"
langBtn.TextColor3 = Color3.fromRGB(235, 235, 245)
langBtn.TextSize = 12
langBtn.Font = Enum.Font.GothamBold
langBtn.TextXAlignment = Enum.TextXAlignment.Left
langBtn.BorderSizePixel = 0
Instance.new("UICorner", langBtn).CornerRadius = UDim.new(0, 8)

langBtn.MouseButton1Click:Connect(function()
    if currentLang == "RU" then
        currentLang = "EN"
        langBtn.Text = "   🌐 Language: English (EN)"
        SearchBox.PlaceholderText = "🔍 Search features..."
    else
        currentLang = "RU"
        langBtn.Text = "   🌐 Language: Русский (RU)"
        SearchBox.PlaceholderText = "🔍 Поиск функций..."
    end
end)

-- Элементы для 3 способов открытия меню
local bottomBarIndicator = Instance.new("Frame", ScreenGui)
bottomBarIndicator.Size = UDim2.new(0, 180, 0, 5)
bottomBarIndicator.Position = UDim2.new(0.5, -90, 1, -10)
bottomBarIndicator.BackgroundColor3 = currentAccentColor
bottomBarIndicator.Visible = false
Instance.new("UICorner", bottomBarIndicator).CornerRadius = UDim.new(1, 0)

local circleOpenBtn = Instance.new("TextButton", ScreenGui)
circleOpenBtn.Size = UDim2.new(0, 45, 0, 45)
circleOpenBtn.Position = UDim2.new(0, 20, 0.5, -22)
circleOpenBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
circleOpenBtn.Text = "⚙"
circleOpenBtn.TextColor3 = Color3.fromRGB(240, 240, 255)
circleOpenBtn.TextSize = 20
circleOpenBtn.Visible = false
Instance.new("UICorner", circleOpenBtn).CornerRadius = UDim.new(1, 0)
local circleStroke = Instance.new("UIStroke", circleOpenBtn)
circleStroke.Color = currentAccentColor
circleStroke.Thickness = 1.5

local watermarkLbl = Instance.new("TextLabel", ScreenGui)
watermarkLbl.Size = UDim2.new(0, 160, 0, 30)
watermarkLbl.Position = UDim2.new(0, 15, 0, 15)
watermarkLbl.BackgroundColor3 = Color3.fromRGB(15, 15, 22)
watermarkLbl.Text = "  SoloScriptHub | 60 FPS"
watermarkLbl.TextColor3 = Color3.fromRGB(200, 200, 220)
watermarkLbl.TextSize = 11
watermarkLbl.Font = Enum.Font.GothamBold
watermarkLbl.TextXAlignment = Enum.TextXAlignment.Left
watermarkLbl.Visible = true
Instance.new("UICorner", watermarkLbl).CornerRadius = UDim.new(0, 6)
local wmStroke = Instance.new("UIStroke", watermarkLbl)
wmStroke.Color = currentAccentColor
wmStroke.Thickness = 1

local modeBtn = Instance.new("TextButton", pageSettings)
modeBtn.Size = UDim2.new(1, -10, 0, 40)
modeBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
modeBtn.Text = "   👁 Open Mode: Вотермарк"
modeBtn.TextColor3 = Color3.fromRGB(235, 235, 245)
modeBtn.TextSize = 12
modeBtn.Font = Enum.Font.GothamBold
modeBtn.TextXAlignment = Enum.TextXAlignment.Left
modeBtn.BorderSizePixel = 0
Instance.new("UICorner", modeBtn).CornerRadius = UDim.new(0, 8)

local function updateOpenModes()
    bottomBarIndicator.Visible = (currentMode == "1 полоска снизу")
    circleOpenBtn.Visible = (currentMode == "круг open menu")
    watermarkLbl.Visible = (currentMode == "вотер марк")
end

modeBtn.MouseButton1Click:Connect(function()
    if currentMode == "вотер марк" then
        currentMode = "1 полоска снизу"
        modeBtn.Text = "   👁 Open Mode: 1 полоска снизу"
    elseif currentMode == "1 полоска снизу" then
        currentMode = "круг open menu"
        modeBtn.Text = "   👁 Open Mode: круг open menu"
    else
        currentMode = "вотер марк"
        modeBtn.Text = "   👁 Open Mode: вотер марк"
    end
    updateOpenModes()
end)

-- Поиск
SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
    local query = SearchBox.Text:lower()
    for _, page in pairs(PagesContainer:GetChildren()) do
        for _, child in pairs(page:GetChildren()) do
            if child:IsA("Frame") then
                local titleText = child:FindFirstChildOfClass("TextLabel")
                if titleText then
                    if query == "" or string.find(titleText.Text:lower(), query) then
                        child.Visible = true
                    else
                        child.Visible = false
                    end
                end
            end
        end
    end
end)

-- Изменение размера мышкой
local resizeGrip = Instance.new("TextButton", MainFrame)
resizeGrip.Size = UDim2.new(0, 20, 0, 20)
resizeGrip.Position = UDim2.new(1, -20, 1, -20)
resizeGrip.BackgroundTransparency = 1
resizeGrip.Text = "◢"
resizeGrip.TextColor3 = Color3.fromRGB(150, 150, 180)
resizeGrip.TextSize = 12
resizeGrip.ZIndex = 10

local resizing = false
resizeGrip.MouseButton1Down:Connect(function() resizing = true end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        resizing = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if resizing and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local mousePos = UserInputService:GetMouseLocation()
        local newX = math.clamp(mousePos.X - MainFrame.AbsolutePosition.X, 480, 1000)
        local newY = math.clamp(mousePos.Y - MainFrame.AbsolutePosition.Y, 300, 700)
        MainFrame.Size = UDim2.new(0, newX, 0, newY)
        normalSize = MainFrame.Size
    end
end)

-- Открытие/Закрытие меню (RightShift + клик по круглой кнопке)
local menuVisible = true
local function toggleMenuState()
    menuVisible = not menuVisible
    if menuVisible then
        MainFrame.Visible = true
        MainFrame.Size = UDim2.new(0, 0, 0, 0)
        TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = normalSize}):Play()
    else
        local tw = TweenService:Create(MainFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {Size = UDim2.new(0, 0, 0, 0)})
        tw:Play()
        tw.Completed:Connect(function()
            if not menuVisible then MainFrame.Visible = false end
        end)
    end
end

circleOpenBtn.MouseButton1Click:Connect(toggleMenuState)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.RightShift then
        toggleMenuState()
    end
end)

print("SoloScriptHub by set33p loaded successfully!")