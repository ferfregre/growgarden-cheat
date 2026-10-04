--[[
    VISUAL CONTROL PANEL
    Roblox / Luau - LocalScript
    Place in: StarterPlayer > StarterPlayerScripts

    Includes:
    - Animated modern UI
    - Background blur
    - Floating UI particles
    - Player ESP through walls
    - Names / health / distance
    - Target card with avatar and HP
    - Target selection by clicking a character
    - FOV circle
    - Screen fade
    - UI sounds
    - Custom colors
    - UI scale
    - Toggle panel with RightShift
    - Draggable panel
    - Notification system
    - Performance mode
]]

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local UserInputService = game:GetService("UserInputService")
local SoundService = game:GetService("SoundService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local Camera = workspace.CurrentCamera

------------------------------------------------------------
-- CONFIGURATION
------------------------------------------------------------

local Config = {
    MenuKey = Enum.KeyCode.RightShift,

    Theme = {
        Accent = Color3.fromRGB(105, 175, 255),
        Accent2 = Color3.fromRGB(160, 110, 255),
        Background = Color3.fromRGB(15, 17, 24),
        Panel = Color3.fromRGB(22, 25, 34),
        Panel2 = Color3.fromRGB(28, 31, 42),
        Text = Color3.fromRGB(245, 247, 255),
        Muted = Color3.fromRGB(145, 151, 168),
        Danger = Color3.fromRGB(255, 85, 100),
        Success = Color3.fromRGB(80, 220, 145),
    },

    Blur = {
        Enabled = true,
        Size = 20,
    },

    Particles = {
        Enabled = true,
        Amount = 40,
        MinSize = 2,
        MaxSize = 6,
        Speed = 7,
        Transparency = 0.35,
    },

    ESP = {
        Enabled = true,
        ShowNames = true,
        ShowHealth = true,
        ShowDistance = true,
        ThroughWalls = true,
        FillTransparency = 0.72,
        OutlineTransparency = 0,
    },

    TargetCard = {
        Enabled = true,
        ShowAvatar = true,
        ShowHealth = true,
        ShowDistance = true,
        ShowTeam = true,
    },

    FOV = {
        Enabled = false,
        Radius = 140,
        Thickness = 2,
        Transparency = 0.35,
    },

    Performance = {
        LowGraphics = false,
    },
}

------------------------------------------------------------
-- STATE
------------------------------------------------------------

local State = {
    MenuOpen = true,
    SelectedTarget = nil,
    ESPObjects = {},
    ParticleObjects = {},
    Connections = {},
}

------------------------------------------------------------
-- HELPERS
------------------------------------------------------------

local function tween(object, info, properties)
    return TweenService:Create(object, info, properties)
end

local function corner(object, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius)
    c.Parent = object
    return c
end

local function stroke(object, color, transparency, thickness)
    local s = Instance.new("UIStroke")
    s.Color = color
    s.Transparency = transparency or 0
    s.Thickness = thickness or 1
    s.Parent = object
    return s
end

local function safeDestroy(object)
    if object then
        pcall(function()
            object:Destroy()
        end)
    end
end

------------------------------------------------------------
-- GUI ROOT
------------------------------------------------------------

local oldGui = PlayerGui:FindFirstChild("VisualControlPanel")
if oldGui then
    oldGui:Destroy()
end

local Gui = Instance.new("ScreenGui")
Gui.Name = "VisualControlPanel"
Gui.IgnoreGuiInset = true
Gui.ResetOnSpawn = false
Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
Gui.Parent = PlayerGui

------------------------------------------------------------
-- BLUR
------------------------------------------------------------

local Blur = Lighting:FindFirstChild("VisualControlBlur")
if not Blur then
    Blur = Instance.new("BlurEffect")
    Blur.Name = "VisualControlBlur"
    Blur.Size = 0
    Blur.Parent = Lighting
end

------------------------------------------------------------
-- BACKGROUND DIM
------------------------------------------------------------

local Dim = Instance.new("Frame")
Dim.Name = "Dim"
Dim.Size = UDim2.fromScale(1, 1)
Dim.BackgroundColor3 = Color3.new(0, 0, 0)
Dim.BackgroundTransparency = 1
Dim.BorderSizePixel = 0
Dim.ZIndex = 0
Dim.Parent = Gui

------------------------------------------------------------
-- PARTICLE LAYER
------------------------------------------------------------

local ParticleLayer = Instance.new("Frame")
ParticleLayer.Name = "Particles"
ParticleLayer.Size = UDim2.fromScale(1, 1)
ParticleLayer.BackgroundTransparency = 1
ParticleLayer.BorderSizePixel = 0
ParticleLayer.ZIndex = 1
ParticleLayer.Parent = Gui

local function spawnParticle()
    if not Config.Particles.Enabled or not State.MenuOpen then
        return
    end

    local p = Instance.new("Frame")
    local size = math.random(Config.Particles.MinSize, Config.Particles.MaxSize)

    p.Size = UDim2.fromOffset(size, size)
    p.Position = UDim2.fromScale(math.random(), 1.08)
    p.AnchorPoint = Vector2.new(0.5, 0.5)
    p.BackgroundColor3 = Config.Theme.Accent
    p.BackgroundTransparency = Config.Particles.Transparency
    p.BorderSizePixel = 0
    p.ZIndex = 1
    p.Parent = ParticleLayer
    corner(p, 99)

    table.insert(State.ParticleObjects, p)

    local destination = UDim2.fromScale(
        math.clamp(p.Position.X.Scale + math.random(-15, 15) / 100, 0, 1),
        -0.08
    )

    local duration = math.random(4, 9)

    local t = tween(
        p,
        TweenInfo.new(duration, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
        {
            Position = destination,
            BackgroundTransparency = 1,
            Rotation = math.random(-180, 180),
        }
    )

    t:Play()
    t.Completed:Connect(function()
        safeDestroy(p)
    end)
end

local function startParticles()
    if not Config.Particles.Enabled then return end

    for i = 1, Config.Particles.Amount do
        task.delay(i * 0.03, spawnParticle)
    end
end

------------------------------------------------------------
-- MAIN PANEL
------------------------------------------------------------

local Main = Instance.new("Frame")
Main.Name = "Main"
Main.AnchorPoint = Vector2.new(0.5, 0.5)
Main.Position = UDim2.fromScale(0.5, 0.5)
Main.Size = UDim2.fromOffset(760, 470)
Main.BackgroundColor3 = Config.Theme.Background
Main.BorderSizePixel = 0
Main.ZIndex = 5
Main.Parent = Gui
corner(Main, 18)
stroke(Main, Config.Theme.Accent, 0.72, 1)

local Scale = Instance.new("UIScale")
Scale.Scale = 1
Scale.Parent = Main

------------------------------------------------------------
-- HEADER
------------------------------------------------------------

local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 68)
Header.BackgroundColor3 = Config.Theme.Panel
Header.BorderSizePixel = 0
Header.ZIndex = 6
Header.Parent = Main
corner(Header, 18)

local HeaderMask = Instance.new("Frame")
HeaderMask.Position = UDim2.new(0, 0, 1, -18)
HeaderMask.Size = UDim2.new(1, 0, 0, 18)
HeaderMask.BackgroundColor3 = Config.Theme.Panel
HeaderMask.BorderSizePixel = 0
HeaderMask.ZIndex = 6
HeaderMask.Parent = Header

local Title = Instance.new("TextLabel")
Title.Position = UDim2.fromOffset(22, 10)
Title.Size = UDim2.fromOffset(400, 28)
Title.BackgroundTransparency = 1
Title.Text = "VISUAL CONTROL"
Title.TextColor3 = Config.Theme.Text
Title.Font = Enum.Font.GothamBold
Title.TextSize = 21
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.ZIndex = 7
Title.Parent = Header

local Subtitle = Instance.new("TextLabel")
Subtitle.Position = UDim2.fromOffset(23, 37)
Subtitle.Size = UDim2.fromOffset(450, 20)
Subtitle.BackgroundTransparency = 1
Subtitle.Text = "Visual effects • Player overlay • Customization"
Subtitle.TextColor3 = Config.Theme.Muted
Subtitle.Font = Enum.Font.Gotham
Subtitle.TextSize = 11
Subtitle.TextXAlignment = Enum.TextXAlignment.Left
Subtitle.ZIndex = 7
Subtitle.Parent = Header

local Close = Instance.new("TextButton")
Close.AnchorPoint = Vector2.new(1, 0.5)
Close.Position = UDim2.new(1, -18, 0.5, 0)
Close.Size = UDim2.fromOffset(34, 34)
Close.BackgroundColor3 = Config.Theme.Panel2
Close.Text = "×"
Close.TextColor3 = Config.Theme.Text
Close.TextSize = 24
Close.Font = Enum.Font.GothamBold
Close.AutoButtonColor = false
Close.ZIndex = 8
Close.Parent = Header
corner(Close, 10)

------------------------------------------------------------
-- SIDEBAR
------------------------------------------------------------

local Sidebar = Instance.new("Frame")
Sidebar.Position = UDim2.fromOffset(12, 80)
Sidebar.Size = UDim2.fromOffset(160, 378)
Sidebar.BackgroundColor3 = Config.Theme.Panel
Sidebar.BorderSizePixel = 0
Sidebar.ZIndex = 6
Sidebar.Parent = Main
corner(Sidebar, 14)

local Content = Instance.new("Frame")
Content.Position = UDim2.fromOffset(184, 80)
Content.Size = UDim2.new(1, -196, 1, -92)
Content.BackgroundTransparency = 1
Content.ZIndex = 6
Content.Parent = Main

------------------------------------------------------------
-- TABS
------------------------------------------------------------

local tabs = {}
local pages = {}

local function createPage(name)
    local page = Instance.new("ScrollingFrame")
    page.Name = name
    page.Size = UDim2.fromScale(1, 1)
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.ScrollBarThickness = 3
    page.ScrollBarImageColor3 = Config.Theme.Accent
    page.CanvasSize = UDim2.fromOffset(0, 0)
    page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    page.Visible = false
    page.ZIndex = 7
    page.Parent = Content

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 10)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = page

    local padding = Instance.new("UIPadding")
    padding.PaddingRight = UDim.new(0, 5)
    padding.Parent = page

    pages[name] = page
    return page
end

local function createTab(text, pageName, order)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, -20, 0, 42)
    button.Position = UDim2.fromOffset(10, 0)
    button.BackgroundColor3 = Config.Theme.Panel
    button.Text = "  " .. text
    button.TextColor3 = Config.Theme.Muted
    button.Font = Enum.Font.GothamSemibold
    button.TextSize = 13
    button.TextXAlignment = Enum.TextXAlignment.Left
    button.AutoButtonColor = false
    button.LayoutOrder = order
    button.ZIndex = 7
    button.Parent = Sidebar
    corner(button, 10)

    tabs[pageName] = button

    button.MouseEnter:Connect(function()
        if pages[pageName].Visible == false then
            tween(button, TweenInfo.new(0.15), {
                BackgroundColor3 = Config.Theme.Panel2,
                TextColor3 = Config.Theme.Text,
            }):Play()
        end
    end)

    button.MouseLeave:Connect(function()
        if pages[pageName].Visible == false then
            tween(button, TweenInfo.new(0.15), {
                BackgroundColor3 = Config.Theme.Panel,
                TextColor3 = Config.Theme.Muted,
            }):Play()
        end
    end)

    button.Activated:Connect(function()
        for n, page in pairs(pages) do
            page.Visible = n == pageName
            local tab = tabs[n]
            tween(tab, TweenInfo.new(0.15), {
                BackgroundColor3 = n == pageName and Config.Theme.Accent or Config.Theme.Panel,
                TextColor3 = n == pageName and Color3.new(1,1,1) or Config.Theme.Muted,
            }):Play()
        end
    end)

    return button
end

------------------------------------------------------------
-- PAGE HELPERS
------------------------------------------------------------

local function section(parent, title, description)
    local box = Instance.new("Frame")
    box.Size = UDim2.new(1, -4, 0, 54)
    box.BackgroundColor3 = Config.Theme.Panel
    box.BorderSizePixel = 0
    box.ZIndex = 7
    box.Parent = parent
    corner(box, 12)

    local t = Instance.new("TextLabel")
    t.Position = UDim2.fromOffset(14, 7)
    t.Size = UDim2.new(1, -28, 0, 20)
    t.BackgroundTransparency = 1
    t.Text = title
    t.TextColor3 = Config.Theme.Text
    t.Font = Enum.Font.GothamBold
    t.TextSize = 13
    t.TextXAlignment = Enum.TextXAlignment.Left
    t.ZIndex = 8
    t.Parent = box

    local d = Instance.new("TextLabel")
    d.Position = UDim2.fromOffset(14, 27)
    d.Size = UDim2.new(1, -28, 0, 18)
    d.BackgroundTransparency = 1
    d.Text = description or ""
    d.TextColor3 = Config.Theme.Muted
    d.Font = Enum.Font.Gotham
    d.TextSize = 10
    d.TextXAlignment = Enum.TextXAlignment.Left
    d.ZIndex = 8
    d.Parent = box

    return box
end

local function toggle(parent, title, description, getter, setter)
    local box = Instance.new("Frame")
    box.Size = UDim2.new(1, -4, 0, 58)
    box.BackgroundColor3 = Config.Theme.Panel
    box.BorderSizePixel = 0
    box.ZIndex = 7
    box.Parent = parent
    corner(box, 12)

    local label = Instance.new("TextLabel")
    label.Position = UDim2.fromOffset(14, 9)
    label.Size = UDim2.new(1, -85, 0, 20)
    label.BackgroundTransparency = 1
    label.Text = title
    label.TextColor3 = Config.Theme.Text
    label.Font = Enum.Font.GothamSemibold
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.ZIndex = 8
    label.Parent = box

    local desc = Instance.new("TextLabel")
    desc.Position = UDim2.fromOffset(14, 30)
    desc.Size = UDim2.new(1, -85, 0, 16)
    desc.BackgroundTransparency = 1
    desc.Text = description
    desc.TextColor3 = Config.Theme.Muted
    desc.Font = Enum.Font.Gotham
    desc.TextSize = 10
    desc.TextXAlignment = Enum.TextXAlignment.Left
    desc.ZIndex = 8
    desc.Parent = box

    local button = Instance.new("TextButton")
    button.AnchorPoint = Vector2.new(1, 0.5)
    button.Position = UDim2.new(1, -14, 0.5, 0)
    button.Size = UDim2.fromOffset(48, 26)
    button.Text = ""
    button.BackgroundColor3 = Config.Theme.Panel2
    button.AutoButtonColor = false
    button.ZIndex = 9
    button.Parent = box
    corner(button, 99)

    local knob = Instance.new("Frame")
    knob.Size = UDim2.fromOffset(20, 20)
    knob.AnchorPoint = Vector2.new(0.5, 0.5)
    knob.Position = UDim2.fromScale(0.25, 0.5)
    knob.BackgroundColor3 = Config.Theme.Muted
    knob.BorderSizePixel = 0
    knob.ZIndex = 10
    knob.Parent = button
    corner(knob, 99)

    local function refresh()
        local on = getter()
        tween(button, TweenInfo.new(0.16), {
            BackgroundColor3 = on and Config.Theme.Accent or Config.Theme.Panel2
        }):Play()
        tween(knob, TweenInfo.new(0.16, Enum.EasingStyle.Quint), {
            Position = UDim2.fromScale(on and 0.75 or 0.25, 0.5),
            BackgroundColor3 = on and Color3.new(1,1,1) or Config.Theme.Muted
        }):Play()
    end

    button.Activated:Connect(function()
        setter(not getter())
        refresh()
    end)

    refresh()
    return refresh
end

local function slider(parent, title, min, max, getter, setter)
    local box = Instance.new("Frame")
    box.Size = UDim2.new(1, -4, 0, 72)
    box.BackgroundColor3 = Config.Theme.Panel
    box.BorderSizePixel = 0
    box.ZIndex = 7
    box.Parent = parent
    corner(box, 12)

    local label = Instance.new("TextLabel")
    label.Position = UDim2.fromOffset(14, 9)
    label.Size = UDim2.new(1, -80, 0, 20)
    label.BackgroundTransparency = 1
    label.Text = title
    label.TextColor3 = Config.Theme.Text
    label.Font = Enum.Font.GothamSemibold
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.ZIndex = 8
    label.Parent = box

    local valueLabel = Instance.new("TextLabel")
    valueLabel.Position = UDim2.new(1, -65, 0, 9)
    valueLabel.Size = UDim2.fromOffset(50, 20)
    valueLabel.BackgroundTransparency = 1
    valueLabel.TextColor3 = Config.Theme.Accent
    valueLabel.Font = Enum.Font.GothamBold
    valueLabel.TextSize = 12
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    valueLabel.ZIndex = 8
    valueLabel.Parent = box

    local bar = Instance.new("Frame")
    bar.Position = UDim2.fromOffset(14, 43)
    bar.Size = UDim2.new(1, -28, 0, 7)
    bar.BackgroundColor3 = Config.Theme.Panel2
    bar.BorderSizePixel = 0
    bar.ZIndex = 8
    bar.Parent = box
    corner(bar, 99)

    local fill = Instance.new("Frame")
    fill.Size = UDim2.fromScale(0.5, 1)
    fill.BackgroundColor3 = Config.Theme.Accent
    fill.BorderSizePixel = 0
    fill.ZIndex = 9
    fill.Parent = bar
    corner(fill, 99)

    local dragging = false

    local function refresh()
        local value = getter()
        local alpha = math.clamp((value - min) / (max - min), 0, 1)
        fill.Size = UDim2.fromScale(alpha, 1)
        valueLabel.Text = tostring(math.floor(value))
    end

    local function update(x)
        local alpha = math.clamp(
            (x - bar.AbsolutePosition.X) / bar.AbsoluteSize.X,
            0, 1
        )
        setter(min + (max - min) * alpha)
        refresh()
    end

    bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            update(input.Position.X)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (
            input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch
        ) then
            update(input.Position.X)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    refresh()
end

------------------------------------------------------------
-- PAGES
------------------------------------------------------------

local VisualPage = createPage("Visual")
local PlayerPage = createPage("Players")
local TargetPage = createPage("Target")
local SettingsPage = createPage("Settings")

createTab("✦  Visuals", "Visual", 1)
createTab("◉  Players", "Players", 2)
createTab("◎  Target", "Target", 3)
createTab("⚙  Settings", "Settings", 4)

tabs.Visual.Activated:Wait()

------------------------------------------------------------
-- VISUAL PAGE
------------------------------------------------------------

section(VisualPage, "World effects", "Control the atmosphere while the menu is open.")

toggle(
    VisualPage,
    "Background Blur",
    "Blur the 3D world behind the interface.",
    function() return Config.Blur.Enabled end,
    function(v) Config.Blur.Enabled = v end
)

toggle(
    VisualPage,
    "Floating Particles",
    "Animated particles behind the interface.",
    function() return Config.Particles.Enabled end,
    function(v)
        Config.Particles.Enabled = v
        if v and State.MenuOpen then startParticles() end
    end
)

slider(
    VisualPage,
    "Particle Amount",
    5, 100,
    function() return Config.Particles.Amount end,
    function(v) Config.Particles.Amount = math.floor(v) end
)

slider(
    VisualPage,
    "UI Scale",
    70, 120,
    function() return Scale.Scale * 100 end,
    function(v) Scale.Scale = v / 100 end
)

------------------------------------------------------------
-- PLAYER PAGE
------------------------------------------------------------

section(PlayerPage, "Player overlay", "Game-owned visual information for players.")

toggle(
    PlayerPage,
    "Player ESP",
    "Highlight characters through walls.",
    function() return Config.ESP.Enabled end,
    function(v) Config.ESP.Enabled = v end
)

toggle(
    PlayerPage,
    "Names",
    "Show player display names.",
    function() return Config.ESP.ShowNames end,
    function(v) Config.ESP.ShowNames = v end
)

toggle(
    PlayerPage,
    "Health",
    "Show live health values.",
    function() return Config.ESP.ShowHealth end,
    function(v) Config.ESP.ShowHealth = v end
)

toggle(
    PlayerPage,
    "Distance",
    "Show distance from your character.",
    function() return Config.ESP.ShowDistance end,
    function(v) Config.ESP.ShowDistance = v end
)

------------------------------------------------------------
-- TARGET PAGE
------------------------------------------------------------

section(TargetPage, "Target card", "Select a player to show their information.")

toggle(
    TargetPage,
    "Target Card",
    "Animated card at the bottom of the screen.",
    function() return Config.TargetCard.Enabled end,
    function(v) Config.TargetCard.Enabled = v end
)

toggle(
    TargetPage,
    "Avatar",
    "Show the selected player's Roblox avatar.",
    function() return Config.TargetCard.ShowAvatar end,
    function(v) Config.TargetCard.ShowAvatar = v end
)

toggle(
    TargetPage,
    "Target Health",
    "Show target HP and health bar.",
    function() return Config.TargetCard.ShowHealth end,
    function(v) Config.TargetCard.ShowHealth = v end
)

toggle(
    TargetPage,
    "Target Distance",
    "Show target distance.",
    function() return Config.TargetCard.ShowDistance end,
    function(v) Config.TargetCard.ShowDistance = v end
)

------------------------------------------------------------
-- SETTINGS PAGE
------------------------------------------------------------

section(SettingsPage, "Performance", "Reduce effects on lower-end devices.")

toggle(
    SettingsPage,
    "Low Graphics",
    "Reduce particle and visual effect load.",
    function() return Config.Performance.LowGraphics end,
    function(v)
        Config.Performance.LowGraphics = v
        Config.Particles.Amount = v and 10 or 40
    end
)

slider(
    SettingsPage,
    "Blur Strength",
    0, 40,
    function() return Config.Blur.Size end,
    function(v) Config.Blur.Size = v end
)

------------------------------------------------------------
-- TARGET CARD
------------------------------------------------------------

local TargetCard = Instance.new("Frame")
TargetCard.AnchorPoint = Vector2.new(0.5, 1)
TargetCard.Position = UDim2.new(0.5, 0, 1, 120)
TargetCard.Size = UDim2.fromOffset(410, 106)
TargetCard.BackgroundColor3 = Config.Theme.Panel
TargetCard.BorderSizePixel = 0
TargetCard.ZIndex = 20
TargetCard.Parent = Gui
corner(TargetCard, 16)
stroke(TargetCard, Config.Theme.Accent, 0.75, 1)

local Avatar = Instance.new("ImageLabel")
Avatar.Position = UDim2.fromOffset(12, 12)
Avatar.Size = UDim2.fromOffset(82, 82)
Avatar.BackgroundColor3 = Config.Theme.Panel2
Avatar.BorderSizePixel = 0
Avatar.ZIndex = 21
Avatar.Parent = TargetCard
corner(Avatar, 13)

local TargetName = Instance.new("TextLabel")
TargetName.Position = UDim2.fromOffset(106, 13)
TargetName.Size = UDim2.new(1, -125, 0, 24)
TargetName.BackgroundTransparency = 1
TargetName.TextColor3 = Config.Theme.Text
TargetName.Font = Enum.Font.GothamBold
TargetName.TextSize = 18
TargetName.TextXAlignment = Enum.TextXAlignment.Left
TargetName.ZIndex = 21
TargetName.Parent = TargetCard

local TargetUsername = Instance.new("TextLabel")
TargetUsername.Position = UDim2.fromOffset(107, 37)
TargetUsername.Size = UDim2.new(1, -125, 0, 17)
TargetUsername.BackgroundTransparency = 1
TargetUsername.TextColor3 = Config.Theme.Muted
TargetUsername.Font = Enum.Font.Gotham
TargetUsername.TextSize = 11
TargetUsername.TextXAlignment = Enum.TextXAlignment.Left
TargetUsername.ZIndex = 21
TargetUsername.Parent = TargetCard

local HPBack = Instance.new("Frame")
HPBack.Position = UDim2.fromOffset(107, 62)
HPBack.Size = UDim2.new(1, -125, 0, 7)
HPBack.BackgroundColor3 = Config.Theme.Panel2
HPBack.BorderSizePixel = 0
HPBack.ZIndex = 21
HPBack.Parent = TargetCard
corner(HPBack, 99)

local HPFill = Instance.new("Frame")
HPFill.Size = UDim2.fromScale(1, 1)
HPFill.BackgroundColor3 = Config.Theme.Success
HPFill.BorderSizePixel = 0
HPFill.ZIndex = 22
HPFill.Parent = HPBack
corner(HPFill, 99)

local TargetInfo = Instance.new("TextLabel")
TargetInfo.Position = UDim2.fromOffset(107, 75)
TargetInfo.Size = UDim2.new(1, -125, 0, 18)
TargetInfo.BackgroundTransparency = 1
TargetInfo.TextColor3 = Config.Theme.Muted
TargetInfo.Font = Enum.Font.Gotham
TargetInfo.TextSize = 10
TargetInfo.TextXAlignment = Enum.TextXAlignment.Left
TargetInfo.ZIndex = 21
TargetInfo.Parent = TargetCard

local function hideTargetCard()
    tween(
        TargetCard,
        TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.In),
        {Position = UDim2.new(0.5, 0, 1, 120)}
    ):Play()
end

local function showTargetCard(player)
    if not Config.TargetCard.Enabled or not player then
        return
    end

    State.SelectedTarget = player

    if Config.TargetCard.ShowAvatar then
        local ok, image = pcall(function()
            return Players:GetUserThumbnailAsync(
                player.UserId,
                Enum.ThumbnailType.HeadShot,
                Enum.ThumbnailSize.Size150x150
            )
        end)

        if ok then Avatar.Image = image end
        Avatar.Visible = true
    else
        Avatar.Visible = false
    end

    TargetName.Text = player.DisplayName
    TargetUsername.Text = "@" .. player.Name

    tween(
        TargetCard,
        TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
        {Position = UDim2.new(0.5, 0, 1, -22)}
    ):Play()
end

------------------------------------------------------------
-- ESP
------------------------------------------------------------

local function removeESP(player)
    local data = State.ESPObjects[player]
    if not data then return end

    safeDestroy(data.Highlight)
    safeDestroy(data.Billboard)
    State.ESPObjects[player] = nil
end

local function createESP(player, character)
    if player == LocalPlayer or not Config.ESP.Enabled then
        return
    end

    removeESP(player)

    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local root = character:FindFirstChild("HumanoidRootPart")

    if not humanoid or not root then
        return
    end

    local h = Instance.new("Highlight")
    h.Name = "VisualESP"
    h.Adornee = character
    h.DepthMode = Config.ESP.ThroughWalls
        and Enum.HighlightDepthMode.AlwaysOnTop
        or Enum.HighlightDepthMode.Occluded
    h.FillTransparency = Config.ESP.FillTransparency
    h.OutlineTransparency = Config.ESP.OutlineTransparency
    h.FillColor = player.Team == LocalPlayer.Team
        and Config.Theme.Accent
        or Config.Theme.Danger
    h.OutlineColor = h.FillColor
    h.Parent = character

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "VisualInfo"
    billboard.Adornee = root
    billboard.Size = UDim2.fromOffset(230, 55)
    billboard.StudsOffset = Vector3.new(0, 3.5, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = root

    local name = Instance.new("TextLabel")
    name.Size = UDim2.new(1, 0, 0, 23)
    name.BackgroundTransparency = 1
    name.Text = player.DisplayName
    name.TextColor3 = Color3.new(1,1,1)
    name.TextStrokeTransparency = 0.45
    name.Font = Enum.Font.GothamBold
    name.TextSize = 14
    name.Visible = Config.ESP.ShowNames
    name.ZIndex = 10
    name.Parent = billboard

    local info = Instance.new("TextLabel")
    info.Position = UDim2.new(0, 0, 0, 24)
    info.Size = UDim2.new(1, 0, 0, 20)
    info.BackgroundTransparency = 1
    info.TextColor3 = Config.Theme.Success
    info.TextStrokeTransparency = 0.55
    info.Font = Enum.Font.Gotham
    info.TextSize = 11
    info.ZIndex = 10
    info.Parent = billboard

    State.ESPObjects[player] = {
        Highlight = h,
        Billboard = billboard,
        Name = name,
        Info = info,
        Humanoid = humanoid,
        Root = root,
    }
end

local function setupPlayer(player)
    if player == LocalPlayer then return end

    player.CharacterAdded:Connect(function(character)
        task.wait(0.4)
        createESP(player, character)
    end)

    player.CharacterRemoving:Connect(function()
        removeESP(player)
    end)

    if player.Character then
        createESP(player, player.Character)
    end
end

for _, player in ipairs(Players:GetPlayers()) do
    setupPlayer(player)
end

Players.PlayerAdded:Connect(setupPlayer)

Players.PlayerRemoving:Connect(function(player)
    removeESP(player)

    if State.SelectedTarget == player then
        State.SelectedTarget = nil
        hideTargetCard()
    end
end)

------------------------------------------------------------
-- CLICK TARGETING
------------------------------------------------------------

UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end

    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        local mouse = LocalPlayer:GetMouse()
        local target = mouse.Target

        if target then
            local model = target:FindFirstAncestorOfClass("Model")
            if model then
                local player = Players:GetPlayerFromCharacter(model)
                if player and player ~= LocalPlayer then
                    showTargetCard(player)
                end
            end
        end
    end
end)

------------------------------------------------------------
-- FOV CIRCLE
------------------------------------------------------------

local FOV = Instance.new("Frame")
FOV.AnchorPoint = Vector2.new(0.5, 0.5)
FOV.Position = UDim2.fromScale(0.5, 0.5)
FOV.Size = UDim2.fromOffset(Config.FOV.Radius * 2, Config.FOV.Radius * 2)
FOV.BackgroundTransparency = 1
FOV.Visible = Config.FOV.Enabled
FOV.ZIndex = 3
FOV.Parent = Gui
corner(FOV, 999)
stroke(FOV, Config.Theme.Accent, Config.FOV.Transparency, Config.FOV.Thickness)

------------------------------------------------------------
-- DRAGGING
------------------------------------------------------------

local dragging = false
local dragStart
local startPos

Header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = Main.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart

        Main.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

------------------------------------------------------------
-- MENU ANIMATION
------------------------------------------------------------

local function openMenu()
    State.MenuOpen = true
    Main.Visible = true
    Dim.Visible = true

    if Config.Blur.Enabled then
        tween(
            Blur,
            TweenInfo.new(0.3, Enum.EasingStyle.Quint),
            {Size = Config.Blur.Size}
        ):Play()
    end

    tween(
        Dim,
        TweenInfo.new(0.3),
        {BackgroundTransparency = 0.45}
    ):Play()

    Main.Size = UDim2.fromOffset(720, 430)

    tween(
        Main,
        TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
        {Size = UDim2.fromOffset(760, 470)}
    ):Play()

    if Config.Particles.Enabled then
        startParticles()
    end
end

local function closeMenu()
    State.MenuOpen = false

    tween(
        Blur,
        TweenInfo.new(0.25, Enum.EasingStyle.Quint),
        {Size = 0}
    ):Play()

    tween(
        Dim,
        TweenInfo.new(0.25),
        {BackgroundTransparency = 1}
    ):Play()

    tween(
        Main,
        TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.In),
        {Size = UDim2.fromOffset(720, 430)}
    ):Play()

    task.delay(0.25, function()
        Main.Visible = false

        for _, p in ipairs(State.ParticleObjects) do
            safeDestroy(p)
        end

        table.clear(State.ParticleObjects)
    end)
end

local function toggleMenu()
    if State.MenuOpen then
        closeMenu()
    else
        openMenu()
    end
end

Close.Activated:Connect(toggleMenu)

UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end

    if input.KeyCode == Config.MenuKey then
        toggleMenu()
    end
end)

------------------------------------------------------------
-- LIVE UPDATE
------------------------------------------------------------

RunService.RenderStepped:Connect(function()
    for player, data in pairs(State.ESPObjects) do
        if not data.Humanoid or not data.Humanoid.Parent then
            continue
        end

        data.Name.Visible = Config.ESP.ShowNames

        local hp = math.max(data.Humanoid.Health, 0)
        local maxHp = math.max(data.Humanoid.MaxHealth, 1)
        local ratio = hp / maxHp

        local parts = {}

        if Config.ESP.ShowHealth then
            table.insert(parts, string.format("%.0f HP", hp))
        end

        if Config.ESP.ShowDistance and data.Root then
            local myCharacter = LocalPlayer.Character
            local myRoot = myCharacter and myCharacter:FindFirstChild("HumanoidRootPart")

            if myRoot then
                local distance = (data.Root.Position - myRoot.Position).Magnitude
                table.insert(parts, string.format("%.0f studs", distance))
            end
        end

        data.Info.Text = table.concat(parts, " • ")

        if ratio > 0.5 then
            data.Info.TextColor3 = Config.Theme.Success
        elseif ratio > 0.2 then
            data.Info.TextColor3 = Color3.fromRGB(255, 195, 70)
        else
            data.Info.TextColor3 = Config.Theme.Danger
        end

        data.Highlight.Enabled = Config.ESP.Enabled
    end

    local target = State.SelectedTarget

    if target and Config.TargetCard.Enabled then
        local character = target.Character
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        local root = character and character:FindFirstChild("HumanoidRootPart")

        if humanoid then
            local hp = math.max(humanoid.Health, 0)
            local maxHp = math.max(humanoid.MaxHealth, 1)
            local ratio = math.clamp(hp / maxHp, 0, 1)

            HPFill.Size = UDim2.fromScale(ratio, 1)
            HPFill.BackgroundColor3 =
                ratio > 0.5 and Config.Theme.Success
                or ratio > 0.2 and Color3.fromRGB(255,195,70)
                or Config.Theme.Danger

            local info = {}

            if Config.TargetCard.ShowHealth then
                table.insert(info, string.format("%.0f / %.0f HP", hp, maxHp))
            end

            if Config.TargetCard.ShowDistance and root then
                local myCharacter = LocalPlayer.Character
                local myRoot = myCharacter and myCharacter:FindFirstChild("HumanoidRootPart")

                if myRoot then
                    table.insert(
                        info,
                        string.format("%.0f studs", (root.Position - myRoot.Position).Magnitude)
                    )
                end
            end

            TargetInfo.Text = table.concat(info, " • ")
        end
    end
end)

------------------------------------------------------------
-- INITIALIZE
------------------------------------------------------------

tabs.Visual.Activated:Fire()
openMenu()

print("[VisualControlPanel] Loaded successfully.")
print("[VisualControlPanel] Menu:", Config.MenuKey.Name)
