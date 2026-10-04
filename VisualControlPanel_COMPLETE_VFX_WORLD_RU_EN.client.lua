--[[
    Visual Control Panel — FULL EDITION
    Для собственной Roblox-игры / debug-admin визуального интерфейса.
    Поместить как LocalScript в StarterPlayer > StarterPlayerScripts.

    Возможности:
    • Player ESP: Highlight / Box / Name / HP / Distance / Team / Tracer
    • NPC ESP и Item ESP по настройке папок
    • Target Card с аватаром, HP, дистанцией, командой
    • Выбор цели кликом
    • FOV circle
    • Blur / Bloom / ColorCorrection / Atmosphere
    • UI particles
    • Notifications
    • Themes
    • UI scale
    • Performance presets
    • Русский / English
    • RightShift + кнопка ✕ / ≡
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local UserInputService = game:GetService("UserInputService")
local CollectionService = game:GetService("CollectionService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local Config = {
    MenuKey = Enum.KeyCode.RightShift,

    Language = "ru", -- "ru" or "en"

    Theme = {
        Accent = Color3.fromRGB(88, 166, 255),
        Accent2 = Color3.fromRGB(126, 87, 255),
        Background = Color3.fromRGB(10, 13, 19),
        Panel = Color3.fromRGB(20, 24, 33),
        Panel2 = Color3.fromRGB(27, 32, 43),
        Text = Color3.fromRGB(242, 245, 250),
        Muted = Color3.fromRGB(145, 154, 170),
        Danger = Color3.fromRGB(255, 85, 100),
        Success = Color3.fromRGB(76, 220, 145),
        Warning = Color3.fromRGB(255, 190, 70),
    },

    Blur = {
        Enabled = true,
        Size = 12,
    },

    Effects = {
        Bloom = false,
        BloomIntensity = 0.35,
        ColorCorrection = false,
        Saturation = 0.05,
        Contrast = 0.05,
        Atmosphere = false,
    },



    FX = {
        Enabled = true,
        MasterIntensity = 1,
        BloomEnabled = true,
        BloomIntensity = 0.35,
        BloomSize = 24,
        BloomThreshold = 1.1,
        ColorEnabled = true,
        ColorSaturation = 0.08,
        ColorContrast = 0.05,
        ColorBrightness = 0.02,
        DOFEnabled = false,
        DOFDistance = 35,
        DOFRadius = 18,
        VignetteEnabled = false,
        VignetteIntensity = 0.3,
        ScanlinesEnabled = false,
        ScanlineSpeed = 1,
        FilmGrainEnabled = false,
        FilmGrainIntensity = 0.08,
        PixelationEnabled = false,
        PixelSize = 4,
        CameraFOV = 70,
        CameraTilt = 0,
        CameraShake = 0,
        LetterboxEnabled = false,
        LetterboxHeight = 0.08,
    },

    World = {
        Enabled = true,

        SkyTint = Color3.fromRGB(180, 205, 255),
        AtmosphereColor = Color3.fromRGB(190, 215, 255),
        AtmosphereDecay = Color3.fromRGB(100, 125, 165),

        FogEnabled = false,
        FogColor = Color3.fromRGB(150, 175, 205),
        FogStart = 80,
        FogEnd = 700,
        FogDensity = 0.15,

        WorldBlur = false,
        WorldBlurSize = 4,

        WorldSaturation = 0.08,
        WorldContrast = 0.05,
        WorldBrightness = 0.02,

        Ambient = Color3.fromRGB(120, 125, 140),
        OutdoorAmbient = Color3.fromRGB(145, 150, 165),

        WorldParticles = true,
        ParticleType = "Dust",
        ParticleAmount = 35,
        ParticleRate = 10,
        ParticleLifetime = 2.5,
        ParticleSpeed = 2,

        JumpEffect = true,
        LandingEffect = true,
        JumpBurst = 14,
        LandingBurst = 24,
        EffectSize = 1,
    },

    Particles = {
        Enabled = true,
        Amount = 18,
        Speed = 0.35,
        Size = 4,
    },

    ESP = {
        Players = true,
        NPCs = false,
        Items = false,

        Highlight = true,
        Box = true,
        Names = true,
        Health = true,
        Distance = true,
        Team = true,
        Tracer = false,

        ThroughWalls = true,
        FillTransparency = 0.82,
        OutlineTransparency = 0.05,
        MaxDistance = 1500,
    },

    Target = {
        Enabled = true,
        ShowAvatar = true,
        ShowHealth = true,
        ShowDistance = true,
        ShowTeam = true,
    },

    FOV = {
        Enabled = false,
        Radius = 150,
        Thickness = 2,
    },

    Performance = {
        LowGraphics = false,
        UpdateRate = 0.08,
    },

    LanguageOptions = {"ru", "en"},
}

local State = {
    NotificationsEnabled = true,
    MenuOpen = true,
    SelectedTarget = nil,
    ESPObjects = {},
    ParticleObjects = {},
    Notifications = {},
    CurrentTab = "Visual",
    ThemeName = "Blue",
    Destroyed = false,
}

local L = {
    ru = {
        title = "Visual Control Panel",
        subtitle = "Визуальные эффекты • Player Overlay • Настройка",
        visual = "Визуал",
        players = "Игроки",
        target = "Цель",
        objects = "Объекты",
        effects = "Эффекты",
        world = "Мир",

        fxLab = "FX Lab",
        presets = "Пресеты",
        resetFX = "Сбросить FX",
        bloom = "Bloom",
        dof = "Depth of Field",
        vignette = "Vignette",
        cameraFOV = "FOV камеры",
        demoEffects = "Демонстрация эффектов",
        sparks = "Искры",
        smoke = "Дым",
        dust = "Пыль",
        magic = "Магические частицы",
        fire = "Огонь",
        electricity = "Электричество",
        bubbles = "Пузырьки",
        leaves = "Листья",
        snow = "Снег",
        trail = "След",
        explosion = "Взрыв",
        heal = "Лечение",
        impact = "Удар",
        shockwave = "Ударная волна",
        portal = "Портал",
        forcefield = "Энергетический щит",
        hologram = "Голограмма",
        worldEffects = "Эффекты мира",
        sky = "Цвет неба",
        atmosphereColor = "Цвет атмосферы",
        atmosphereDecay = "Дальняя дымка",
        fog = "Туман",
        fogColor = "Цвет тумана",
        fogStart = "Начало тумана",
        fogEnd = "Дальность тумана",
        fogDensity = "Плотность тумана",
        worldBlur = "Blur мира",
        worldBlurSize = "Сила Blur мира",
        worldColor = "Цветокоррекция мира",
        saturation = "Насыщенность",
        contrast = "Контраст",
        brightness = "Яркость",
        ambient = "Освещение мира",
        outdoorAmbient = "Наружное освещение",
        worldParticles = "Частицы в мире",
        particleType = "Тип частиц",
        particleRate = "Плотность частиц",
        particleLifetime = "Время жизни",
        particleSpeed = "Скорость частиц",
        jumpEffect = "Эффект прыжка",
        landingEffect = "Эффект приземления",
        jumpBurst = "Сила прыжка",
        landingBurst = "Сила приземления",
        effectSize = "Размер эффекта",
        settings = "Настройки",
        appearance = "Оформление",
        language = "Язык",
        russian = "Русский",
        english = "English",
        on = "ВКЛ",
        off = "ВЫКЛ",
        blur = "Размытие фона",
        particles = "Плавающие частицы",
        particleAmount = "Количество частиц",
        uiScale = "Размер интерфейса",
        bloom = "Bloom",
        colorCorrection = "Color Correction",
        atmosphere = "Atmosphere",
        playerESP = "ESP игроков",
        npcESP = "ESP NPC",
        itemESP = "ESP предметов",
        highlight = "Highlight",
        box = "Box",
        names = "Имена",
        health = "Здоровье",
        distance = "Дистанция",
        team = "Команда",
        tracer = "Tracer",
        throughWalls = "Через стены",
        maxDistance = "Макс. дистанция",
        targetCard = "Карточка цели",
        avatar = "Аватар",
        targetHealth = "HP цели",
        targetDistance = "Дистанция цели",
        targetTeam = "Команда цели",
        clickTarget = "Выбор цели кликом",
        fov = "FOV круг",
        fovRadius = "Радиус FOV",
        performance = "Производительность",
        lowGraphics = "Low Graphics",
        notifications = "Уведомления",
        theme = "Тема",
        blue = "Синяя",
        purple = "Фиолетовая",
        green = "Зелёная",
        red = "Красная",
        default = "По умолчанию",
        playerInfo = "Информация об игроке",
        noTarget = "Цель не выбрана",
        selected = "Выбрано",
        username = "Пользователь",
        teamNone = "Без команды",
        close = "Закрыть",
        open = "Открыть",
        resetTarget = "Сбросить цель",
        resetSettings = "Сбросить настройки",
        enabled = "Включено",
        disabled = "Выключено",
        npcFolder = "Папка NPC: workspace.NPCs",
        itemFolder = "Папка предметов: workspace.Items",
        ready = "Интерфейс готов",
        targetSet = "Цель выбрана",
        targetCleared = "Цель сброшена",
        languageChanged = "Язык изменён",
        performanceOn = "Включён режим производительности",
        performanceOff = "Режим производительности выключен",
    },

    en = {
        title = "Visual Control Panel",
        subtitle = "Visual effects • Player Overlay • Customization",
        visual = "Visual",
        players = "Players",
        target = "Target",
        objects = "Objects",
        effects = "Effects",
        world = "World",

        fxLab = "FX Lab",
        presets = "Presets",
        resetFX = "Reset FX",
        bloom = "Bloom",
        dof = "Depth of Field",
        vignette = "Vignette",
        cameraFOV = "Camera FOV",
        demoEffects = "Effect Showcase",
        sparks = "Sparks",
        smoke = "Smoke",
        dust = "Dust",
        magic = "Magic Motes",
        fire = "Fire",
        electricity = "Electricity",
        bubbles = "Bubbles",
        leaves = "Leaves",
        snow = "Snow",
        trail = "Trail",
        explosion = "Explosion",
        heal = "Heal",
        impact = "Impact",
        shockwave = "Shockwave",
        portal = "Portal",
        forcefield = "Force Field",
        hologram = "Hologram",
        worldEffects = "World Effects",
        sky = "Sky Tint",
        atmosphereColor = "Atmosphere Color",
        atmosphereDecay = "Atmosphere Decay",
        fog = "Fog",
        fogColor = "Fog Color",
        fogStart = "Fog Start",
        fogEnd = "Fog Distance",
        fogDensity = "Fog Density",
        worldBlur = "World Blur",
        worldBlurSize = "World Blur Strength",
        worldColor = "World Color Correction",
        saturation = "Saturation",
        contrast = "Contrast",
        brightness = "Brightness",
        ambient = "World Lighting",
        outdoorAmbient = "Outdoor Ambient",
        worldParticles = "World Particles",
        particleType = "Particle Type",
        particleRate = "Particle Rate",
        particleLifetime = "Particle Lifetime",
        particleSpeed = "Particle Speed",
        jumpEffect = "Jump Effect",
        landingEffect = "Landing Effect",
        jumpBurst = "Jump Burst",
        landingBurst = "Landing Burst",
        effectSize = "Effect Size",
        settings = "Settings",
        appearance = "Appearance",
        language = "Language",
        russian = "Русский",
        english = "English",
        on = "ON",
        off = "OFF",
        blur = "Background Blur",
        particles = "Floating Particles",
        particleAmount = "Particle Amount",
        uiScale = "UI Scale",
        bloom = "Bloom",
        colorCorrection = "Color Correction",
        atmosphere = "Atmosphere",
        playerESP = "Player ESP",
        npcESP = "NPC ESP",
        itemESP = "Item ESP",
        highlight = "Highlight",
        box = "Box",
        names = "Names",
        health = "Health",
        distance = "Distance",
        team = "Team",
        tracer = "Tracer",
        throughWalls = "Through Walls",
        maxDistance = "Max Distance",
        targetCard = "Target Card",
        avatar = "Avatar",
        targetHealth = "Target HP",
        targetDistance = "Target Distance",
        targetTeam = "Target Team",
        clickTarget = "Click Target",
        fov = "FOV Circle",
        fovRadius = "FOV Radius",
        performance = "Performance",
        lowGraphics = "Low Graphics",
        notifications = "Notifications",
        theme = "Theme",
        blue = "Blue",
        purple = "Purple",
        green = "Green",
        red = "Red",
        default = "Default",
        playerInfo = "Player Information",
        noTarget = "No target selected",
        selected = "Selected",
        username = "Username",
        teamNone = "No team",
        close = "Close",
        open = "Open",
        resetTarget = "Reset Target",
        resetSettings = "Reset Settings",
        enabled = "Enabled",
        disabled = "Disabled",
        npcFolder = "NPC folder: workspace.NPCs",
        itemFolder = "Item folder: workspace.Items",
        ready = "Interface ready",
        targetSet = "Target selected",
        targetCleared = "Target cleared",
        languageChanged = "Language changed",
        performanceOn = "Performance mode enabled",
        performanceOff = "Performance mode disabled",
    }
}

local function T(key)
    local lang = L[Config.Language] or L.en
    return lang[key] or L.en[key] or key
end

local function tween(obj, info, props)
    return TweenService:Create(obj, info, props)
end

local function corner(obj, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 10)
    c.Parent = obj
    return c
end

local function stroke(obj, color, transparency, thickness)
    local s = Instance.new("UIStroke")
    s.Color = color
    s.Transparency = transparency or 0
    s.Thickness = thickness or 1
    s.Parent = obj
    return s
end

local function safeDestroy(obj)
    if obj then
        pcall(function() obj:Destroy() end)
    end
end

local function getCharacter(player)
    return player and player.Character
end

local function getHumanoid(character)
    return character and character:FindFirstChildOfClass("Humanoid")
end

local function getRoot(character)
    return character and (character:FindFirstChild("HumanoidRootPart") or character.PrimaryPart)
end

local function getHealthText(humanoid)
    if not humanoid then return "—" end
    return string.format("%d / %d", math.floor(humanoid.Health + 0.5), math.floor(humanoid.MaxHealth + 0.5))
end

local function getDistance(character)
    local root = getRoot(character)
    local myRoot = getRoot(LocalPlayer.Character)
    if not root or not myRoot then return nil end
    return (root.Position - myRoot.Position).Magnitude
end

local Gui = Instance.new("ScreenGui")
Gui.Name = "VisualControlPanel"
Gui.ResetOnSpawn = false
Gui.IgnoreGuiInset = false
Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
Gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local Scale = Instance.new("UIScale")
Scale.Scale = 0.92
Scale.Parent = Gui

local Dim = Instance.new("Frame")
Dim.Name = "Dim"
Dim.Size = UDim2.fromScale(1, 1)
Dim.BackgroundColor3 = Color3.new(0, 0, 0)
Dim.BackgroundTransparency = 0.55
Dim.BorderSizePixel = 0
Dim.ZIndex = 1
Dim.Parent = Gui

local ParticleLayer = Instance.new("Frame")
ParticleLayer.Name = "Particles"
ParticleLayer.Size = UDim2.fromScale(1, 1)
ParticleLayer.BackgroundTransparency = 1
ParticleLayer.ClipsDescendants = true
ParticleLayer.ZIndex = 2
ParticleLayer.Parent = Gui

local Main = Instance.new("Frame")
Main.Name = "Main"
Main.AnchorPoint = Vector2.new(0.5, 0.5)
Main.Position = UDim2.fromScale(0.5, 0.52)
Main.Size = UDim2.fromOffset(640, 400)
Main.BackgroundColor3 = Config.Theme.Background
Main.BorderSizePixel = 0
Main.ZIndex = 5
Main.Parent = Gui
corner(Main, 16)
stroke(Main, Config.Theme.Accent, 0.65, 1)

local MainConstraint = Instance.new("UISizeConstraint")
MainConstraint.MinSize = Vector2.new(520, 340)
MainConstraint.MaxSize = Vector2.new(680, 420)
MainConstraint.Parent = Main

local Header = Instance.new("Frame")
Header.Name = "Header"
Header.Size = UDim2.new(1, 0, 0, 58)
Header.BackgroundColor3 = Config.Theme.Panel
Header.BorderSizePixel = 0
Header.Parent = Main
corner(Header, 16)

local HeaderFill = Instance.new("Frame")
HeaderFill.Size = UDim2.new(1, 0, 0, 25)
HeaderFill.Position = UDim2.new(0, 0, 1, -25)
HeaderFill.BackgroundColor3 = Config.Theme.Panel
HeaderFill.BorderSizePixel = 0
Header.Parent = Header

local Title = Instance.new("TextLabel")
Title.BackgroundTransparency = 1
Title.Position = UDim2.fromOffset(18, 6)
Title.Size = UDim2.new(1, -120, 0, 25)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.TextColor3 = Config.Theme.Text
Title.Text = T("title")
Title.Parent = Header

local Subtitle = Instance.new("TextLabel")
Subtitle.BackgroundTransparency = 1
Subtitle.Position = UDim2.fromOffset(19, 32)
Subtitle.Size = UDim2.new(1, -120, 0, 18)
Subtitle.Font = Enum.Font.Gotham
Subtitle.TextSize = 10
Subtitle.TextXAlignment = Enum.TextXAlignment.Left
Subtitle.TextColor3 = Config.Theme.Muted
Subtitle.Text = T("subtitle")
Subtitle.Parent = Header

local Close = Instance.new("TextButton")
Close.Name = "Close"
Close.AnchorPoint = Vector2.new(1, 0.5)
Close.Position = UDim2.new(1, -12, 0.5, 0)
Close.Size = UDim2.fromOffset(38, 38)
Close.BackgroundColor3 = Config.Theme.Background
Close.Text = "✕"
Close.TextColor3 = Config.Theme.Text
Close.TextSize = 18
Close.Font = Enum.Font.GothamBold
Close.AutoButtonColor = false
Close.Parent = Header
corner(Close, 11)

local Reopen = Instance.new("TextButton")
Reopen.Name = "Reopen"
Reopen.AnchorPoint = Vector2.new(1, 0)
Reopen.Position = UDim2.new(1, -18, 0, 18)
Reopen.Size = UDim2.fromOffset(44, 44)
Reopen.BackgroundColor3 = Config.Theme.Panel
Reopen.Text = "≡"
Reopen.TextColor3 = Config.Theme.Text
Reopen.TextSize = 22
Reopen.Font = Enum.Font.GothamBold
Reopen.AutoButtonColor = false
Reopen.Visible = false
Reopen.ZIndex = 20
Reopen.Parent = Gui
corner(Reopen, 12)
stroke(Reopen, Config.Theme.Accent, 0.45, 1)

local Sidebar = Instance.new("Frame")
Sidebar.Name = "Sidebar"
Sidebar.Position = UDim2.fromOffset(10, 68)
Sidebar.Size = UDim2.fromOffset(140, 322)
Sidebar.BackgroundColor3 = Config.Theme.Panel
Sidebar.BorderSizePixel = 0
Sidebar.Parent = Main
corner(Sidebar, 12)

local SideLayout = Instance.new("UIListLayout")
SideLayout.Padding = UDim.new(0, 6)
SideLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
SideLayout.VerticalAlignment = Enum.VerticalAlignment.Top
SideLayout.Parent = Sidebar

local SidePadding = Instance.new("UIPadding")
SidePadding.PaddingTop = UDim.new(0, 10)
SidePadding.PaddingLeft = UDim.new(0, 8)
SidePadding.PaddingRight = UDim.new(0, 8)
SidePadding.Parent = Sidebar

local Content = Instance.new("Frame")
Content.Name = "Content"
Content.Position = UDim2.fromOffset(162, 68)
Content.Size = UDim2.new(1, -172, 1, -78)
Content.BackgroundTransparency = 1
Content.Parent = Main

local Tabs = {}
local Pages = {}

local tabOrder = {
    {"Visual", "◈"},
    {"Players", "◎"},
    {"Target", "⌖"},
    {"Objects", "◇"},
    {"Effects", "✦"},
    {"World", "◉"},
    {"FX Lab", "✦"},
    {"Settings", "⚙"},
}

local function createTab(name, icon)
    local b = Instance.new("TextButton")
    b.Name = name
    b.Size = UDim2.new(1, 0, 0, 39)
    b.BackgroundColor3 = Config.Theme.Panel
    b.TextColor3 = Config.Theme.Muted
    b.TextSize = 12
    b.Font = Enum.Font.GothamSemibold
    b.TextXAlignment = Enum.TextXAlignment.Left
    b.Text = "  " .. icon .. "   " .. T(string.lower(name))
    b.AutoButtonColor = false
    b.Parent = Sidebar
    corner(b, 9)
    Tabs[name] = b
    return b
end

local tabKeyMap = {
    Visual = "visual",
    Players = "players",
    Target = "target",
    Objects = "objects",
    Effects = "effects",
    World = "world",
    ["FX Lab"] = "fxLab",
    Settings = "settings",
}

for _, item in ipairs(tabOrder) do
    createTab(item[1], item[2])
end

local function createPage(name)
    local p = Instance.new("ScrollingFrame")
    p.Name = name
    p.Size = UDim2.fromScale(1, 1)
    p.BackgroundTransparency = 1
    p.BorderSizePixel = 0
    p.ScrollBarThickness = 3
    p.ScrollBarImageColor3 = Config.Theme.Accent
    p.CanvasSize = UDim2.fromOffset(0, 0)
    p.Visible = false
    p.Parent = Content

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 8)
    layout.Parent = p

    local pad = Instance.new("UIPadding")
    pad.PaddingRight = UDim.new(0, 5)
    pad.PaddingBottom = UDim.new(0, 8)
    pad.Parent = p

    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        p.CanvasSize = UDim2.fromOffset(0, layout.AbsoluteContentSize.Y + 12)
    end)

    Pages[name] = p
    return p
end

for _, item in ipairs(tabOrder) do
    createPage(item[1])
end

local function section(parent, textValue)
    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(1, -4, 0, 22)
    label.Font = Enum.Font.GothamBold
    label.TextSize = 11
    label.TextColor3 = Config.Theme.Accent
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Text = textValue
    label.Parent = parent
    return label
end

local function toggle(parent, key, default, callback)
    Config[key] = default

    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, -4, 0, 42)
    row.BackgroundColor3 = Config.Theme.Panel
    row.BorderSizePixel = 0
    row.Parent = parent
    corner(row, 9)

    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.Position = UDim2.fromOffset(12, 0)
    label.Size = UDim2.new(1, -78, 1, 0)
    label.Font = Enum.Font.GothamMedium
    label.TextSize = 11
    label.TextColor3 = Config.Theme.Text
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Text = key
    label.Parent = row

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.fromOffset(52, 25)
    btn.Position = UDim2.new(1, -62, 0.5, -12)
    btn.BackgroundColor3 = default and Config.Theme.Accent or Config.Theme.Panel2
    btn.TextColor3 = default and Color3.new(1,1,1) or Config.Theme.Muted
    btn.TextSize = 9
    btn.Font = Enum.Font.GothamBold
    btn.AutoButtonColor = false
    btn.Text = default and T("on") or T("off")
    btn.Parent = row
    corner(btn, 8)

    local value = default

    local function set(v)
        value = v
        btn.BackgroundColor3 = v and Config.Theme.Accent or Config.Theme.Panel2
        btn.TextColor3 = v and Color3.new(1,1,1) or Config.Theme.Muted
        btn.Text = v and T("on") or T("off")
        if callback then callback(v) end
    end

    btn.Activated:Connect(function()
        set(not value)
    end)

    row:SetAttribute("ToggleKey", key)
    row:SetAttribute("ToggleValue", value)

    return row, set, function() return value end
end

local function slider(parent, labelText, min, max, default, callback)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, -4, 0, 54)
    row.BackgroundColor3 = Config.Theme.Panel
    row.BorderSizePixel = 0
    row.Parent = parent
    corner(row, 9)

    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.Position = UDim2.fromOffset(12, 4)
    label.Size = UDim2.new(1, -80, 0, 18)
    label.Font = Enum.Font.GothamMedium
    label.TextSize = 10
    label.TextColor3 = Config.Theme.Text
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Text = labelText
    label.Parent = row

    local valueLabel = Instance.new("TextLabel")
    valueLabel.BackgroundTransparency = 1
    valueLabel.AnchorPoint = Vector2.new(1, 0)
    valueLabel.Position = UDim2.new(1, -12, 0, 4)
    valueLabel.Size = UDim2.fromOffset(50, 18)
    valueLabel.Font = Enum.Font.GothamBold
    valueLabel.TextSize = 10
    valueLabel.TextColor3 = Config.Theme.Accent
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    valueLabel.Text = tostring(default)
    valueLabel.Parent = row

    local bar = Instance.new("Frame")
    bar.Position = UDim2.fromOffset(12, 31)
    bar.Size = UDim2.new(1, -24, 0, 7)
    bar.BackgroundColor3 = Config.Theme.Panel2
    bar.BorderSizePixel = 0
    bar.Parent = row
    corner(bar, 4)

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((default-min)/(max-min), 0, 1, 0)
    fill.BackgroundColor3 = Config.Theme.Accent
    fill.BorderSizePixel = 0
    fill.Parent = bar
    corner(fill, 4)

    local value = default

    local function set(v)
        value = math.clamp(v, min, max)
        local alpha = (value-min)/(max-min)
        fill.Size = UDim2.new(alpha, 0, 1, 0)
        valueLabel.Text = tostring(math.floor(value))
        if callback then callback(value) end
    end

    local dragging = false

    bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            local alpha = math.clamp((input.Position.X - bar.AbsolutePosition.X)/bar.AbsoluteSize.X, 0, 1)
            set(min + (max-min)*alpha)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local alpha = math.clamp((input.Position.X - bar.AbsolutePosition.X)/bar.AbsoluteSize.X, 0, 1)
            set(min + (max-min)*alpha)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    return row, set, function() return value end
end

local function button(parent, textValue, callback, danger)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, -4, 0, 38)
    b.BackgroundColor3 = danger and Config.Theme.Danger or Config.Theme.Panel
    b.TextColor3 = Color3.new(1,1,1)
    b.TextSize = 10
    b.Font = Enum.Font.GothamBold
    b.Text = textValue
    b.AutoButtonColor = false
    b.Parent = parent
    corner(b, 9)
    b.Activated:Connect(callback)
    return b
end

-- Effects
local Blur = Lighting:FindFirstChild("VCP_Blur") or Instance.new("BlurEffect")
Blur.Name = "VCP_Blur"
Blur.Size = Config.Blur.Enabled and Config.Blur.Size or 0
Blur.Parent = Lighting

local Bloom = Lighting:FindFirstChild("VCP_Bloom") or Instance.new("BloomEffect")
Bloom.Name = "VCP_Bloom"
Bloom.Intensity = Config.Effects.Bloom and Config.Effects.BloomIntensity or 0
Bloom.Size = 24
Bloom.Threshold = 1
Bloom.Parent = Lighting

local ColorCorrection = Lighting:FindFirstChild("VCP_ColorCorrection") or Instance.new("ColorCorrectionEffect")
ColorCorrection.Name = "VCP_ColorCorrection"
ColorCorrection.Saturation = Config.Effects.ColorCorrection and Config.Effects.Saturation or 0
ColorCorrection.Contrast = Config.Effects.ColorCorrection and Config.Effects.Contrast or 0
ColorCorrection.Parent = Lighting

local Atmosphere = Lighting:FindFirstChild("VCP_Atmosphere")
if not Atmosphere then
    Atmosphere = Instance.new("Atmosphere")
    Atmosphere.Name = "VCP_Atmosphere"
    Atmosphere.Density = 0.15
    Atmosphere.Haze = 0.4
    Atmosphere.Parent = Lighting
end
Atmosphere.Density = Config.Effects.Atmosphere and 0.15 or 0


-- World customization runtime
local WorldBlur = Lighting:FindFirstChild("VCP_WorldBlur") or Instance.new("BlurEffect")
WorldBlur.Name = "VCP_WorldBlur"
WorldBlur.Size = 0
WorldBlur.Parent = Lighting

local WorldColor = Lighting:FindFirstChild("VCP_WorldColor") or Instance.new("ColorCorrectionEffect")
WorldColor.Name = "VCP_WorldColor"
WorldColor.Parent = Lighting

local function applyWorldLighting()
    if not Config.World.Enabled then
        WorldColor.Enabled = false
        WorldBlur.Size = 0
        Lighting.FogEnd = 100000
        Lighting.FogStart = 0
        return
    end

    WorldColor.Enabled = true
    WorldColor.TintColor = Config.World.SkyTint
    WorldColor.Saturation = Config.World.WorldSaturation
    WorldColor.Contrast = Config.World.WorldContrast
    WorldColor.Brightness = Config.World.WorldBrightness

    Lighting.Ambient = Config.World.Ambient
    Lighting.OutdoorAmbient = Config.World.OutdoorAmbient

    WorldBlur.Size = Config.World.WorldBlur and Config.World.WorldBlurSize or 0

    Lighting.FogColor = Config.World.FogColor
    Lighting.FogStart = Config.World.FogEnabled and Config.World.FogStart or 0
    Lighting.FogEnd = Config.World.FogEnabled and Config.World.FogEnd or 100000
    Lighting.FogColor = Config.World.FogColor

    Atmosphere.Color = Config.World.AtmosphereColor
    Atmosphere.Decay = Config.World.AtmosphereDecay
    Atmosphere.Density = Config.Effects.Atmosphere and 0.15 or 0
    Atmosphere.Haze = Config.World.FogEnabled and Config.World.FogDensity * 3 or 0.2
end

applyWorldLighting()

-- World particle field around the local player.
local WorldParticlePart = Instance.new("Part")
WorldParticlePart.Name = "VCP_WorldParticleEmitter"
WorldParticlePart.Anchored = true
WorldParticlePart.CanCollide = false
WorldParticlePart.CanTouch = false
WorldParticlePart.CanQuery = false
WorldParticlePart.Transparency = 1
WorldParticlePart.Size = Vector3.new(1,1,1)
WorldParticlePart.Parent = workspace

local WorldAttachment = Instance.new("Attachment")
WorldAttachment.Parent = WorldParticlePart

local WorldEmitter = Instance.new("ParticleEmitter")
WorldEmitter.Name = "WorldParticles"
WorldEmitter.Enabled = Config.World.WorldParticles
WorldEmitter.Rate = Config.World.ParticleRate
WorldEmitter.Lifetime = NumberRange.new(
    math.max(0.2, Config.World.ParticleLifetime * 0.75),
    math.max(0.3, Config.World.ParticleLifetime * 1.25)
)
WorldEmitter.Speed = NumberRange.new(0.5, Config.World.ParticleSpeed)
WorldEmitter.SpreadAngle = Vector2.new(180, 180)
WorldEmitter.Acceleration = Vector3.new(0, 1.5, 0)
WorldEmitter.Drag = 0.5
WorldEmitter.LightEmission = 0.15
WorldEmitter.Size = NumberSequence.new({
    NumberSequenceKeypoint.new(0, 0.06),
    NumberSequenceKeypoint.new(0.5, 0.12),
    NumberSequenceKeypoint.new(1, 0),
})
WorldEmitter.Transparency = NumberSequence.new({
    NumberSequenceKeypoint.new(0, 0.75),
    NumberSequenceKeypoint.new(0.7, 0.55),
    NumberSequenceKeypoint.new(1, 1),
})
WorldEmitter.Color = ColorSequence.new(Color3.fromRGB(210, 220, 235))
WorldEmitter.Parent = WorldAttachment

local function updateWorldParticles()
    WorldEmitter.Enabled = Config.World.Enabled and Config.World.WorldParticles
    WorldEmitter.Rate = Config.World.ParticleRate
    WorldEmitter.Speed = NumberRange.new(0.5, math.max(0.5, Config.World.ParticleSpeed))
    WorldEmitter.Lifetime = NumberRange.new(
        math.max(0.2, Config.World.ParticleLifetime * 0.75),
        math.max(0.3, Config.World.ParticleLifetime * 1.25)
    )

    local character = LocalPlayer.Character
    local root = getRoot(character)
    if root then
        WorldParticlePart.CFrame = root.CFrame * CFrame.new(0, 8, 0)
    end
end

local function createBurst(position, color, count, scale)
    if not Config.World.Enabled then return end

    local part = Instance.new("Part")
    part.Name = "VCP_Burst"
    part.Anchored = true
    part.CanCollide = false
    part.CanTouch = false
    part.CanQuery = false
    part.Transparency = 1
    part.Size = Vector3.new(0.2,0.2,0.2)
    part.CFrame = CFrame.new(position)
    part.Parent = workspace

    local attachment = Instance.new("Attachment")
    attachment.Parent = part

    local emitter = Instance.new("ParticleEmitter")
    emitter.Rate = 0
    emitter.Lifetime = NumberRange.new(0.25, 0.55)
    emitter.Speed = NumberRange.new(7 * scale, 14 * scale)
    emitter.SpreadAngle = Vector2.new(360, 360)
    emitter.Drag = 4
    emitter.LightEmission = 0.35
    emitter.Size = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.1 * scale),
        NumberSequenceKeypoint.new(0.25, 0.22 * scale),
        NumberSequenceKeypoint.new(1, 0),
    })
    emitter.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.15),
        NumberSequenceKeypoint.new(0.7, 0.45),
        NumberSequenceKeypoint.new(1, 1),
    })
    emitter.Color = ColorSequence.new(color)
    emitter.Parent = attachment

    emitter:Emit(math.clamp(count, 1, 100))

    task.delay(0.8, function()
        safeDestroy(part)
    end)
end

local function jumpEffect(character)
    if not Config.World.JumpEffect then return end
    local root = getRoot(character)
    if root then
        createBurst(root.Position - Vector3.new(0, 2.5, 0), Config.Theme.Accent, Config.World.JumpBurst, Config.World.EffectSize)
    end
end

local function landingEffect(character)
    if not Config.World.LandingEffect then return end
    local root = getRoot(character)
    if root then
        createBurst(root.Position - Vector3.new(0, 2.5, 0), Color3.fromRGB(205, 215, 225), Config.World.LandingBurst, Config.World.EffectSize)
    end
end

local function bindMovementEffects(character)
    local humanoid = getHumanoid(character)
    if not humanoid then return end

    local wasAirborne = false
    local connection
    connection = humanoid.StateChanged:Connect(function(_, newState)
        if newState == Enum.HumanoidStateType.Jumping or newState == Enum.HumanoidStateType.Freefall then
            if not wasAirborne then
                wasAirborne = true
                if newState == Enum.HumanoidStateType.Jumping then
                    jumpEffect(character)
                end
            end
        elseif wasAirborne and (
            newState == Enum.HumanoidStateType.Landed
            or newState == Enum.HumanoidStateType.Running
            or newState == Enum.HumanoidStateType.RunningNoPhysics
        ) then
            wasAirborne = false
            landingEffect(character)
        end
    end)

    character.AncestryChanged:Connect(function(_, parent)
        if not parent then
            connection:Disconnect()
        end
    end)
end

if LocalPlayer.Character then
    task.spawn(bindMovementEffects, LocalPlayer.Character)
end

LocalPlayer.CharacterAdded:Connect(function(character)
    task.wait(0.3)
    bindMovementEffects(character)
end)


-- ============================================================
-- COMPLETE VFX API
-- Local visual/debug effects for your own Roblox experience.
-- Some engine effects without direct Roblox APIs are simulated
-- with supported Roblox instances/UI.
-- ============================================================

local VisualFX = {}
local EffectStates = {}
local EffectCounter = 0

local function fxId(prefix)
    EffectCounter += 1
    return string.format("%s_%d", prefix or "FX", EffectCounter)
end

local function fxPart(position, name)
    local p = Instance.new("Part")
    p.Name = name or "VCP_FX"
    p.Anchored = true
    p.CanCollide = false
    p.CanTouch = false
    p.CanQuery = false
    p.Transparency = 1
    p.Size = Vector3.new(0.2, 0.2, 0.2)
    p.CFrame = CFrame.new(position)
    p.Parent = workspace
    local a = Instance.new("Attachment")
    a.Parent = p
    return p, a
end

local function fxEmitter(parent, props)
    local e = Instance.new("ParticleEmitter")
    for k, v in pairs(props or {}) do
        pcall(function() e[k] = v end)
    end
    e.Parent = parent
    return e
end

local function fxRegister(id, object, duration)
    EffectStates[id] = {
        Object = object,
        State = "Playing",
        Duration = duration,
        Speed = 1,
        Intensity = 1,
    }
end

function VisualFX.GetEffectState(effectID)
    local s = EffectStates[effectID]
    if not s then return "Stopped" end
    if s.Paused then return "Paused" end
    return s.State or "Playing"
end

function VisualFX.StopEffect(effectID, fadeOut)
    local s = EffectStates[effectID]
    if not s then return false end
    s.State = "Stopping"
    if s.Object then
        if fadeOut and s.Object:IsA("ParticleEmitter") then
            s.Object.Enabled = false
            task.delay(1, function() safeDestroy(s.Object) end)
        else
            safeDestroy(s.Object)
        end
    end
    EffectStates[effectID] = nil
    return true
end

function VisualFX.StopAllEffects(instant)
    for id, s in pairs(EffectStates) do
        if s.Object then
            if instant then
                safeDestroy(s.Object)
            elseif s.Object:IsA("ParticleEmitter") then
                s.Object.Enabled = false
                task.delay(1, function() safeDestroy(s.Object) end)
            else
                safeDestroy(s.Object)
            end
        end
        EffectStates[id] = nil
    end
end

function VisualFX.PauseEffect(effectID, pause)
    local s = EffectStates[effectID]
    if not s then return false end
    s.Paused = pause ~= false
    if s.Object and s.Object:IsA("ParticleEmitter") then
        s.Object.Enabled = not s.Paused
    end
    return true
end

function VisualFX.ResumeEffect(effectID)
    return VisualFX.PauseEffect(effectID, false)
end

function VisualFX.SetEffectIntensity(effectID, multiplier)
    local s = EffectStates[effectID]
    if not s then return false end
    s.Intensity = multiplier or 1
    return true
end

function VisualFX.SetEffectDuration(effectID, newDuration)
    local s = EffectStates[effectID]
    if not s then return false end
    s.Duration = newDuration
    return true
end

function VisualFX.SetEffectSpeed(effectID, speedMultiplier)
    local s = EffectStates[effectID]
    if not s then return false end
    s.Speed = speedMultiplier or 1
    return true
end

function VisualFX.SetEffectColor(effectID, newColor)
    local s = EffectStates[effectID]
    if not s then return false end
    s.Color = newColor
    if s.Object and s.Object:IsA("ParticleEmitter") then
        s.Object.Color = ColorSequence.new(newColor)
    end
    return true
end

function VisualFX.AttachEffectToObject(effectID, target, offset)
    local s = EffectStates[effectID]
    if not s or not target then return false end
    s.Target = target
    s.Offset = offset or Vector3.zero
    return true
end

function VisualFX.DetachEffect(effectID)
    local s = EffectStates[effectID]
    if not s then return false end
    s.Target = nil
    return true
end

function VisualFX.SetEffectLayer(effectID, layer)
    local s = EffectStates[effectID]
    if not s then return false end
    s.Layer = layer
    if s.Object and s.Object:IsA("GuiObject") then
        s.Object.ZIndex = layer
    end
    return true
end

function VisualFX.BlendEffect(effectA, effectB, blendFactor)
    local a, b = EffectStates[effectA], EffectStates[effectB]
    if not a or not b then return false end
    a.Blend = math.clamp(blendFactor or 0.5, 0, 1)
    b.Blend = 1 - a.Blend
    return true
end

function VisualFX.SetEffectPriority(effectID, priority)
    local s = EffectStates[effectID]
    if not s then return false end
    s.Priority = priority
    return true
end

local function burst(position, color, count, speed, size)
    local p, a = fxPart(position, "VCP_Burst")
    local e = fxEmitter(a, {
        Rate = 0,
        Lifetime = NumberRange.new(0.2, 0.55),
        Speed = NumberRange.new(speed * 0.6, speed),
        SpreadAngle = Vector2.new(360, 360),
        Drag = 4,
        LightEmission = 0.5,
        Color = ColorSequence.new(color),
        Size = NumberSequence.new({
            NumberSequenceKeypoint.new(0, size),
            NumberSequenceKeypoint.new(0.35, size * 1.5),
            NumberSequenceKeypoint.new(1, 0),
        }),
        Transparency = NumberSequence.new(0.05, 1),
    })
    e:Emit(math.clamp(count, 1, 100))
    task.delay(0.8, function() safeDestroy(p) end)
    return p
end

function VisualFX.PlaySparks(position, count, color, speed)
    local id = fxId("Sparks")
    local p = burst(position, color or Config.Theme.Accent, count or 18, speed or 12, 0.08)
    fxRegister(id, p, 0.8)
    task.delay(0.85, function() EffectStates[id] = nil end)
    return id
end

function VisualFX.PlaySmoke(position, density, riseSpeed, lifetime)
    local id = fxId("Smoke")
    local p, a = fxPart(position, "VCP_Smoke")
    local e = fxEmitter(a, {
        Rate = density or 12,
        Lifetime = NumberRange.new((lifetime or 3) * 0.65, lifetime or 3),
        Speed = NumberRange.new(riseSpeed or 2, (riseSpeed or 2) * 1.4),
        SpreadAngle = Vector2.new(30, 30),
        Acceleration = Vector3.new(0, 2, 0),
        Drag = 2,
        Size = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0.3),
            NumberSequenceKeypoint.new(0.6, 1.4),
            NumberSequenceKeypoint.new(1, 2),
        }),
        Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0.55),
            NumberSequenceKeypoint.new(0.75, 0.78),
            NumberSequenceKeypoint.new(1, 1),
        }),
        Color = ColorSequence.new(Color3.fromRGB(105,105,112)),
    })
    fxRegister(id, p, lifetime or 3)
    task.delay(lifetime or 3, function() VisualFX.StopEffect(id, true) end)
    return id
end

function VisualFX.PlayDust(position, scale, color, spread)
    local id = fxId("Dust")
    local s = scale or 1
    local p = burst(position, color or Color3.fromRGB(185,175,160), math.floor(18*s), 6*s, 0.08*s)
    fxRegister(id, p, 0.9)
    task.delay(1, function() EffectStates[id] = nil end)
    return id
end

function VisualFX.PlayBloodSplatter(position, direction, force, color)
    -- Stylized non-graphic hit particles for game effects.
    local id = fxId("HitParticles")
    local p = burst(position, color or Config.Theme.Danger, 12, force or 8, 0.07)
    fxRegister(id, p, 0.7)
    task.delay(0.75, function() EffectStates[id] = nil end)
    return id
end

function VisualFX.PlayMagicMotes(target, orbitRadius, speed, glowColor)
    local id = fxId("MagicMotes")
    local root = target and (target:IsA("BasePart") and target or target:FindFirstChild("HumanoidRootPart") or target.PrimaryPart)
    if not root then return id end

    local p = Instance.new("Part")
    p.Name = "VCP_MagicMotes"
    p.Anchored = true
    p.CanCollide = false
    p.CanTouch = false
    p.CanQuery = false
    p.Transparency = 1
    p.Size = Vector3.new(0.2,0.2,0.2)
    p.Parent = workspace

    local a = Instance.new("Attachment")
    a.Parent = p
    local e = fxEmitter(a, {
        Rate = 14,
        Lifetime = NumberRange.new(1,2),
        Speed = NumberRange.new(0.2,0.8),
        LightEmission = 1,
        Color = ColorSequence.new(glowColor or Color3.fromRGB(160,220,255)),
        Size = NumberSequence.new(0.12,0),
        Transparency = NumberSequence.new(0.1,1),
    })
    fxRegister(id, p, nil)
    task.spawn(function()
        local t = 0
        while EffectStates[id] and root.Parent do
            t += RunService.RenderStepped:Wait() * (speed or 2)
            p.Position = root.Position + Vector3.new(
                math.cos(t) * (orbitRadius or 4),
                1.5 + math.sin(t * 1.4),
                math.sin(t) * (orbitRadius or 4)
            )
        end
        safeDestroy(p)
        EffectStates[id] = nil
    end)
    return id
end

function VisualFX.PlayFire(position, intensity, flickerSpeed, innerColor)
    local id = fxId("Fire")
    local power = intensity or 1
    local p, a = fxPart(position, "VCP_Fire")
    local e = fxEmitter(a, {
        Rate = 18 * power,
        Lifetime = NumberRange.new(0.25,0.65),
        Speed = NumberRange.new(2,5) * power,
        SpreadAngle = Vector2.new(35,35),
        Acceleration = Vector3.new(0,5,0),
        LightEmission = 0.9,
        Color = ColorSequence.new(innerColor or Color3.fromRGB(255,150,50)),
        Size = NumberSequence.new({
            NumberSequenceKeypoint.new(0,0.2),
            NumberSequenceKeypoint.new(0.45,0.8*power),
            NumberSequenceKeypoint.new(1,0),
        }),
        Transparency = NumberSequence.new(0.05,1),
    })
    local light = Instance.new("PointLight")
    light.Color = innerColor or Color3.fromRGB(255,150,50)
    light.Brightness = 2 * power
    light.Range = 8 * power
    light.Parent = p
    fxRegister(id, p, nil)
    task.spawn(function()
        while EffectStates[id] do
            light.Brightness = (1.5 + math.random() * 1.5) * power
            task.wait(1 / math.max(1, flickerSpeed or 8))
        end
    end)
    return id
end

function VisualFX.PlayElectricity(startPos, endPos, thickness, segments)
    local id = fxId("Electricity")
    local folder = Instance.new("Folder")
    folder.Name = "VCP_Electricity"
    folder.Parent = workspace
    local last = startPos
    local count = math.max(2, segments or 8)

    for i = 1, count do
        local alpha = i / count
        local nextPos = startPos:Lerp(endPos, alpha)
        if i < count then
            nextPos += Vector3.new((math.random()-0.5)*2, (math.random()-0.5)*2, (math.random()-0.5)*2)
        end
        local mid = (last + nextPos) / 2
        local seg = Instance.new("Part")
        seg.Anchored = true
        seg.CanCollide = false
        seg.CanTouch = false
        seg.CanQuery = false
        seg.Material = Enum.Material.Neon
        seg.Color = Color3.fromRGB(130,210,255)
        seg.Size = Vector3.new(thickness or 0.08, thickness or 0.08, (last-nextPos).Magnitude)
        seg.CFrame = CFrame.lookAt(mid, nextPos)
        seg.Parent = folder
        last = nextPos
    end

    fxRegister(id, folder, 0.2)
    task.delay(0.22, function() VisualFX.StopEffect(id, false) end)
    return id
end

function VisualFX.PlayBubbles(position, floatSpeed, sizeVariance)
    local id = fxId("Bubbles")
    local p, a = fxPart(position, "VCP_Bubbles")
    local v = floatSpeed or 3
    local s = sizeVariance or 1
    local e = fxEmitter(a, {
        Rate = 12,
        Lifetime = NumberRange.new(1.5,3),
        Speed = NumberRange.new(v*0.5,v),
        Acceleration = Vector3.new(0,1,0),
        SpreadAngle = Vector2.new(35,35),
        Size = NumberSequence.new(0.08,0.18*s),
        Transparency = NumberSequence.new(0.2,1),
        Color = ColorSequence.new(Color3.fromRGB(185,225,255)),
    })
    fxRegister(id, p, nil)
    return id
end

function VisualFX.PlayLeaves(position, windForce, rotationSpeed)
    local id = fxId("Leaves")
    local p, a = fxPart(position, "VCP_Leaves")
    local e = fxEmitter(a, {
        Rate = 12,
        Lifetime = NumberRange.new(2,4),
        Speed = NumberRange.new(1,3),
        Acceleration = Vector3.new(windForce or 2,-2,0),
        Rotation = NumberRange.new(0,360),
        RotSpeed = NumberRange.new(-(rotationSpeed or 90), rotationSpeed or 90),
        SpreadAngle = Vector2.new(180,180),
        Size = NumberSequence.new(0.12,0.3),
        Transparency = NumberSequence.new(0.05,1),
        Color = ColorSequence.new(Color3.fromRGB(210,145,70)),
    })
    fxRegister(id, p, nil)
    return id
end

function VisualFX.PlaySnow(position, fallSpeed, drift, size)
    local id = fxId("Snow")
    local p, a = fxPart(position, "VCP_Snow")
    local e = fxEmitter(a, {
        Rate = 25,
        Lifetime = NumberRange.new(3,5),
        Speed = NumberRange.new(fallSpeed or 3, (fallSpeed or 3)+1),
        Acceleration = Vector3.new(drift or 1,-1,0),
        SpreadAngle = Vector2.new(180,180),
        Size = NumberSequence.new(size or 0.12),
        Transparency = NumberSequence.new(0.1,0.9),
        Color = ColorSequence.new(Color3.new(1,1,1)),
    })
    fxRegister(id, p, nil)
    return id
end

function VisualFX.PlayTrail(target, duration, startColor, endColor)
    local id = fxId("Trail")
    local root = target and (target:IsA("BasePart") and target or target:FindFirstChild("HumanoidRootPart") or target.PrimaryPart)
    if not root then return id end

    local a0 = Instance.new("Attachment")
    local a1 = Instance.new("Attachment")
    a0.Position = Vector3.new(0, 1, 0)
    a1.Position = Vector3.new(0, -1, 0)
    a0.Parent = root
    a1.Parent = root

    local trail = Instance.new("Trail")
    trail.Attachment0 = a0
    trail.Attachment1 = a1
    trail.Lifetime = duration or 0.35
    trail.Color = ColorSequence.new(startColor or Config.Theme.Accent, endColor or Config.Theme.Accent2)
    trail.Transparency = NumberSequence.new(0.1,1)
    trail.Parent = root

    fxRegister(id, trail, duration)
    task.delay(duration or 0.35, function() VisualFX.StopEffect(id, false) safeDestroy(a0) safeDestroy(a1) end)
    return id
end

function VisualFX.PlayExplosion(position, radius, force, damage)
    local id = fxId("Explosion")
    local r = radius or 8
    VisualFX.PlaySparks(position, 30, Color3.fromRGB(255,180,70), force or 18)
    VisualFX.PlaySmoke(position, 18, 3, 3.5)
    burst(position, Color3.fromRGB(255,120,50), 25, force or 18, math.max(0.12, r/40))

    local p = Instance.new("Part")
    p.Anchored = true
    p.CanCollide = false
    p.CanTouch = false
    p.CanQuery = false
    p.Transparency = 1
    p.Size = Vector3.new(0.2,0.2,0.2)
    p.Position = position
    p.Parent = workspace
    local light = Instance.new("PointLight")
    light.Color = Color3.fromRGB(255,150,70)
    light.Brightness = 8
    light.Range = r * 2
    light.Parent = p
    fxRegister(id, p, 0.4)
    task.delay(0.4, function() VisualFX.StopEffect(id, false) end)
    return id
end

function VisualFX.PlayHeal(target, color, riseSpeed, particleCount)
    local root = target and (target:IsA("BasePart") and target or target:FindFirstChild("HumanoidRootPart") or target.PrimaryPart)
    if not root then return nil end
    local id = fxId("Heal")
    local p, a = fxPart(root.Position, "VCP_Heal")
    local e = fxEmitter(a, {
        Rate = 0,
        Lifetime = NumberRange.new(0.8,1.4),
        Speed = NumberRange.new(riseSpeed or 2, (riseSpeed or 2)+1),
        Acceleration = Vector3.new(0,2,0),
        SpreadAngle = Vector2.new(45,45),
        Size = NumberSequence.new(0.1,0),
        Transparency = NumberSequence.new(0.1,1),
        LightEmission = 0.7,
        Color = ColorSequence.new(color or Config.Theme.Success),
    })
    e:Emit(math.clamp(particleCount or 20, 1, 100))
    fxRegister(id, p, 1.5)
    task.delay(1.6, function() VisualFX.StopEffect(id, false) end)
    return id
end

function VisualFX.PlayImpact(position, normal, scale)
    local id = fxId("Impact")
    local p = burst(position, Config.Theme.Accent, math.floor(14*(scale or 1)), 9*(scale or 1), 0.08*(scale or 1))
    fxRegister(id, p, 0.7)
    task.delay(0.75, function() EffectStates[id] = nil end)
    return id
end

function VisualFX.TriggerShockwave(position, radius, speed, thickness)
    local id = fxId("Shockwave")
    local p = Instance.new("Part")
    p.Anchored = true
    p.CanCollide = false
    p.CanTouch = false
    p.CanQuery = false
    p.Material = Enum.Material.Neon
    p.Color = Config.Theme.Accent
    p.Transparency = 0.35
    p.Shape = Enum.PartType.Cylinder
    p.Size = Vector3.new(thickness or 0.25, 1, 1)
    p.CFrame = CFrame.new(position) * CFrame.Angles(0,0,math.rad(90))
    p.Parent = workspace
    fxRegister(id, p, 1)
    local goal = {Size = Vector3.new(thickness or 0.25, radius or 15, radius or 15), Transparency = 1}
    local tw = TweenService:Create(p, TweenInfo.new((radius or 15)/math.max(1,speed or 25), Enum.EasingStyle.Quad, Enum.EasingDirection.Out), goal)
    tw:Play()
    tw.Completed:Connect(function() VisualFX.StopEffect(id, false) end)
    return id
end

-- Post-processing
local VFXBloom = Lighting:FindFirstChild("VCP_VFXBloom") or Instance.new("BloomEffect")
VFXBloom.Name = "VCP_VFXBloom"
VFXBloom.Parent = Lighting

local VFXColor = Lighting:FindFirstChild("VCP_VFXColor") or Instance.new("ColorCorrectionEffect")
VFXColor.Name = "VCP_VFXColor"
VFXColor.Parent = Lighting

local VFXDOF = Lighting:FindFirstChild("VCP_VFXDOF") or Instance.new("DepthOfFieldEffect")
VFXDOF.Name = "VCP_VFXDOF"
VFXDOF.Parent = Lighting

function VisualFX.SetBloom(threshold, intensity, tint)
    VFXBloom.Threshold = threshold or 1.1
    VFXBloom.Intensity = intensity or 0.35
    VFXBloom.Size = 24
    VFXBloom.Enabled = Config.FX.Enabled and Config.FX.BloomEnabled
    VFXBloom.Color = tint or Color3.new(1,1,1)
end

function VisualFX.SetChromaticAberration(intensity, offset, blur)
    -- Roblox has no native chromatic-aberration instance; simulate with subtle screen tint/blur.
    Config.FX.LensIntensity = intensity or 0
    Config.FX.LensOffset = offset or Vector2.zero
    if blur then
        local b = Lighting:FindFirstChild("VCP_ChromaticSim") or Instance.new("BlurEffect")
        b.Name = "VCP_ChromaticSim"
        b.Size = math.clamp(blur,0,12)
        b.Enabled = Config.FX.Enabled and Config.FX.ScreenEffects
        b.Parent = Lighting
    end
end

function VisualFX.SetVignette(intensity, smoothness, color, center)
    Config.FX.VignetteEnabled = intensity and intensity > 0
    Config.FX.VignetteIntensity = intensity or 0
    Config.FX.VignetteColor = color or Color3.new(0,0,0)
    Config.FX.VignetteCenter = center or Vector2.new(0.5,0.5)
end

function VisualFX.SetColorGrading(saturation, contrast, temperature, tint)
    VFXColor.Enabled = Config.FX.Enabled and Config.FX.ScreenEffects
    VFXColor.Saturation = saturation or 0
    VFXColor.Contrast = contrast or 0
    VFXColor.Brightness = 0
    VFXColor.TintColor = tint or Color3.new(1,1,1)
    Config.FX.ColorSaturation = saturation or 0
    Config.FX.ColorContrast = contrast or 0
end

function VisualFX.SetDepthOfField(focusDistance, aperture, focalLength)
    VFXDOF.FocusDistance = focusDistance or 35
    VFXDOF.InFocusRadius = aperture or 18
    VFXDOF.NearIntensity = 0.05
    VFXDOF.FarIntensity = math.clamp((focalLength or 50) / 100, 0, 1)
    VFXDOF.Enabled = Config.FX.Enabled and Config.FX.DOFEnabled
end

function VisualFX.SetMotionBlur(blurAmount, samples, velocityScale)
    Config.FX.MotionBlur = blurAmount or 0
    Config.FX.MotionBlurSamples = samples or 8
    Config.FX.MotionBlurVelocity = velocityScale or 1
end

function VisualFX.SetFilmGrain(intensity, responseSpeed)
    Config.FX.FilmGrainEnabled = (intensity or 0) > 0
    Config.FX.FilmGrainIntensity = intensity or 0
    Config.FX.FilmGrainSpeed = responseSpeed or 8
end

function VisualFX.SetPixelation(pixelSize, applyToUI)
    Config.FX.PixelationEnabled = (pixelSize or 0) > 0
    Config.FX.PixelSize = pixelSize or 1
    Config.FX.PixelationUI = applyToUI == true
end

function VisualFX.SetScanlines(lineWidth, lineColor, speed)
    Config.FX.ScanlinesEnabled = (lineWidth or 0) > 0
    Config.FX.ScanlineWidth = lineWidth or 2
    Config.FX.ScanlineColor = lineColor or Color3.new(0,0,0)
    Config.FX.ScanlineSpeed = speed or 1
end

function VisualFX.SetLensDistortion(intensity, centerX, centerY)
    Config.FX.LensEnabled = (intensity or 0) > 0
    Config.FX.LensIntensity = intensity or 0
    Config.FX.LensCenter = Vector2.new(centerX or 0.5, centerY or 0.5)
end

function VisualFX.SetWhiteBalance(temperature, tint)
    local t = math.clamp((temperature or 0) / 100, -1, 1)
    local warm = math.max(t, 0)
    local cool = math.max(-t, 0)
    VFXColor.TintColor = Color3.new(1 + warm*0.08, 1 - cool*0.05, 1 - warm*0.08 + cool*0.08)
    Config.FX.WhiteBalanceTint = tint or 0
end

function VisualFX.SetExposure(exposureValue, adaptationSpeed)
    VFXColor.Brightness = math.clamp(exposureValue or 0, -1, 1)
    Config.FX.ExposureSpeed = adaptationSpeed or 1
end

function VisualFX.SetFog(fogColor, density, startDistance, endDistance)
    Lighting.FogColor = fogColor or Color3.fromRGB(150,175,205)
    Lighting.FogStart = startDistance or 0
    Lighting.FogEnd = endDistance or 1000
    Config.World.FogDensity = density or 0.15
    Config.World.FogEnabled = true
    applyWorldLighting()
end

function VisualFX.SetAmbientOcclusion(intensity, radius, power)
    -- Roblox has no direct global SSAO API; approximate with Atmosphere + contrast.
    Config.FX.AOIntensity = intensity or 0
    Config.FX.AORadius = radius or 8
    Config.FX.AOPower = power or 1
    VFXColor.Contrast = math.clamp((Config.FX.ColorContrast or 0) + (intensity or 0)*0.08, -1, 1)
end

function VisualFX.SetReflection(reflectivity, blur, useCubemap)
    Config.FX.Reflection = reflectivity or 0
    Config.FX.ReflectionBlur = blur or 0
    Config.FX.UseCubemap = useCubemap == true
end

-- Object effects
function VisualFX.SetOutline(object, color, thickness, pulse)
    if not object then return nil end
    local id = fxId("Outline")
    local h = Instance.new("Highlight")
    h.Name = "VCP_Outline"
    h.Adornee = object
    h.FillTransparency = 1
    h.OutlineColor = color or Config.Theme.Accent
    h.OutlineTransparency = 0
    h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    h.Parent = object
    fxRegister(id, h, nil)

    if pulse then
        task.spawn(function()
            while EffectStates[id] do
                local a = 0.05 + math.abs(math.sin(os.clock()*5))*0.35
                h.OutlineTransparency = a
                RunService.RenderStepped:Wait()
            end
        end)
    end
    return id
end

function VisualFX.SetHologram(object, transparency, flickerSpeed, glowColor)
    if not object then return nil end
    local id = fxId("Hologram")
    local h = Instance.new("Highlight")
    h.Name = "VCP_Hologram"
    h.Adornee = object
    h.FillColor = glowColor or Config.Theme.Accent
    h.OutlineColor = glowColor or Config.Theme.Accent2
    h.FillTransparency = transparency or 0.55
    h.OutlineTransparency = 0.15
    h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    h.Parent = object
    fxRegister(id, h, nil)
    task.spawn(function()
        while EffectStates[id] do
            h.FillTransparency = (transparency or 0.55) + math.sin(os.clock()*(flickerSpeed or 6))*0.08
            RunService.RenderStepped:Wait()
        end
    end)
    return id
end

function VisualFX.SetDissolve(object, dissolveAmount, edgeColor, noiseTex)
    if not object then return nil end
    local id = fxId("Dissolve")
    local h = Instance.new("Highlight")
    h.Name = "VCP_Dissolve"
    h.Adornee = object
    h.FillColor = edgeColor or Config.Theme.Accent
    h.OutlineColor = edgeColor or Config.Theme.Accent
    h.FillTransparency = math.clamp(dissolveAmount or 0,0,1)
    h.OutlineTransparency = math.clamp((dissolveAmount or 0)*0.8,0,1)
    h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    h.Parent = object
    fxRegister(id, h, nil)
    return id
end

function VisualFX.SetForceField(object, color, pulseSpeed, hitIntensity)
    if not object then return nil end
    local id = fxId("ForceField")
    local h = Instance.new("Highlight")
    h.Name = "VCP_ForceField"
    h.Adornee = object
    h.FillColor = color or Color3.fromRGB(80,180,255)
    h.OutlineColor = color or Color3.fromRGB(80,180,255)
    h.FillTransparency = 0.65
    h.OutlineTransparency = 0.05
    h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    h.Parent = object
    fxRegister(id, h, nil)
    task.spawn(function()
        while EffectStates[id] do
            local pulse = 0.55 + math.abs(math.sin(os.clock()*(pulseSpeed or 4)))*0.3
            h.FillTransparency = pulse
            RunService.RenderStepped:Wait()
        end
    end)
    return id
end

function VisualFX.SetFresnel(object, color, power, intensity)
    if not object then return nil end
    return VisualFX.SetOutline(object, color or Config.Theme.Accent, intensity or 1, true)
end

function VisualFX.SetPortal(position, rotationSpeed, colorA, colorB, distortion)
    local id = fxId("Portal")
    local p = Instance.new("Part")
    p.Name = "VCP_Portal"
    p.Anchored = true
    p.CanCollide = false
    p.CanTouch = false
    p.CanQuery = false
    p.Transparency = 1
    p.Size = Vector3.new(0.2,0.2,0.2)
    p.Position = position
    p.Parent = workspace

    local light = Instance.new("PointLight")
    light.Color = colorA or Config.Theme.Accent
    light.Range = 12 + (distortion or 0)*10
    light.Brightness = 2
    light.Parent = p

    local e = fxEmitter(Instance.new("Attachment", p), {
        Rate = 18,
        Lifetime = NumberRange.new(0.8,1.5),
        Speed = NumberRange.new(1,3),
        LightEmission = 1,
        Color = ColorSequence.new(colorA or Config.Theme.Accent, colorB or Config.Theme.Accent2),
        Size = NumberSequence.new(0.12,0),
        Transparency = NumberSequence.new(0.1,1),
        Rotation = NumberRange.new(0,360),
        RotSpeed = NumberRange.new(-90,90),
    })
    fxRegister(id, p, nil)
    task.spawn(function()
        while EffectStates[id] do
            p.Orientation += Vector3.new(0, rotationSpeed or 30, 0) * RunService.RenderStepped:Wait()
        end
    end)
    return id
end

function VisualFX.SetCloak(object, transparency, distortionStrength)
    if not object then return nil end
    local id = fxId("Cloak")
    local h = Instance.new("Highlight")
    h.Name = "VCP_Cloak"
    h.Adornee = object
    h.FillTransparency = math.clamp(transparency or 0.75,0,1)
    h.OutlineTransparency = 1
    h.DepthMode = Enum.HighlightDepthMode.Occluded
    h.Parent = object
    fxRegister(id, h, nil)
    Config.FX.CloakDistortion = distortionStrength or 0
    return id
end

function VisualFX.SetUVScroll(object, speed, direction, pingPong)
    local id = fxId("UVScroll")
    EffectStates[id] = {
        Object = object,
        State = "Playing",
        UVSpeed = speed or Vector2.new(1,0),
        Direction = direction or Vector2.new(1,0),
        PingPong = pingPong == true,
    }
    return id
end

function VisualFX.SetMasking(object, mask, softness)
    local id = fxId("Masking")
    if object then
        local h = Instance.new("Highlight")
        h.Name = "VCP_Masking"
        h.Adornee = object
        h.FillTransparency = math.clamp(softness or 0.5,0,1)
        h.OutlineTransparency = 1
        h.Parent = object
        fxRegister(id, h, nil)
    end
    return id
end

-- Camera / screen
local VFXGui = Instance.new("ScreenGui")
VFXGui.Name = "VCP_FXOverlay"
VFXGui.ResetOnSpawn = false
VFXGui.IgnoreGuiInset = true
VFXGui.DisplayOrder = 1000
VFXGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local Flash = Instance.new("Frame")
Flash.BackgroundColor3 = Color3.new(1,1,1)
Flash.BackgroundTransparency = 1
Flash.BorderSizePixel = 0
Flash.Size = UDim2.fromScale(1,1)
Flash.Parent = VFXGui

local TopBar = Instance.new("Frame")
TopBar.BackgroundColor3 = Color3.new(0,0,0)
TopBar.BorderSizePixel = 0
TopBar.Visible = false
TopBar.Size = UDim2.new(1,0,0,0)
TopBar.Parent = VFXGui

local BottomBar = TopBar:Clone()
BottomBar.AnchorPoint = Vector2.new(0,1)
BottomBar.Position = UDim2.fromScale(0,1)
BottomBar.Parent = VFXGui

local Vignette = Instance.new("Frame")
Vignette.BackgroundColor3 = Color3.new(0,0,0)
Vignette.BackgroundTransparency = 1
Vignette.BorderSizePixel = 0
Vignette.Size = UDim2.fromScale(1,1)
Vignette.Parent = VFXGui

local VignetteGradient = Instance.new("UIGradient")
VignetteGradient.Transparency = NumberSequence.new({
    NumberSequenceKeypoint.new(0,0.15),
    NumberSequenceKeypoint.new(0.5,1),
    NumberSequenceKeypoint.new(1,0.15),
})
VignetteGradient.Parent = Vignette

function VisualFX.ShakeCamera(intensity, duration, decay, usePerlinNoise)
    local cam = workspace.CurrentCamera
    if not cam then return end
    local original = cam.CFrame
    local power = intensity or 1
    local total = duration or 0.25
    task.spawn(function()
        local elapsed = 0
        while elapsed < total do
            local dt = RunService.RenderStepped:Wait()
            elapsed += dt
            local fade = 1 - math.clamp(elapsed/total,0,1)
            local x, y, z
            if usePerlinNoise then
                x = math.noise(elapsed*18,0,0)*power*fade
                y = math.noise(0,elapsed*18,0)*power*fade
                z = math.noise(0,0,elapsed*18)*power*fade
            else
                x = (math.random()-0.5)*2*power*fade
                y = (math.random()-0.5)*2*power*fade
                z = (math.random()-0.5)*2*power*fade
            end
            cam.CFrame = cam.CFrame * CFrame.new(x,y,z)
        end
        if cam then cam.CFrame = original end
    end)
end

function VisualFX.ZoomCamera(targetFOV, duration, curve)
    local cam = workspace.CurrentCamera
    if not cam then return end
    local start = cam.FieldOfView
    local info = TweenInfo.new(duration or 0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    TweenService:Create(cam, info, {FieldOfView = targetFOV or 55}):Play()
    return start
end

function VisualFX.RotateCamera(angle, duration, relative)
    local cam = workspace.CurrentCamera
    if not cam then return end
    local base = cam.CFrame
    local goal = base * CFrame.Angles(0,0,math.rad(angle or 5))
    if not relative then
        goal = CFrame.new(base.Position) * CFrame.Angles(0,0,math.rad(angle or 5)) * CFrame.lookAt(Vector3.zero, base.LookVector).Rotation
    end
    TweenService:Create(cam, TweenInfo.new(duration or 0.3, Enum.EasingStyle.Quad), {CFrame = goal}):Play()
end

function VisualFX.PanCamera(targetPos, duration, smoothStep)
    local cam = workspace.CurrentCamera
    if not cam then return end
    TweenService:Create(cam, TweenInfo.new(duration or 0.5, smoothStep and Enum.EasingStyle.Sine or Enum.EasingStyle.Quad), {
        CFrame = CFrame.new(targetPos, targetPos + cam.CFrame.LookVector)
    }):Play()
end

function VisualFX.SetCameraTilt(angle, duration)
    local cam = workspace.CurrentCamera
    if not cam then return end
    Config.FX.CameraTilt = angle or 0
    local base = cam.CFrame
    TweenService:Create(cam, TweenInfo.new(duration or 0.25), {
        CFrame = base * CFrame.Angles(0,0,math.rad(angle or 0))
    }):Play()
end

function VisualFX.SetCameraFOV(fov, duration)
    Config.FX.CameraFOV = fov or 70
    local cam = workspace.CurrentCamera
    if cam then
        TweenService:Create(cam, TweenInfo.new(duration or 0.25), {FieldOfView = Config.FX.CameraFOV}):Play()
    end
end

function VisualFX.FlashScreen(color, duration, fadeSpeed)
    Flash.BackgroundColor3 = color or Color3.new(1,1,1)
    Flash.BackgroundTransparency = 0
    local d = duration or 0.1
    task.delay(d, function()
        TweenService:Create(Flash, TweenInfo.new(fadeSpeed or 0.25), {BackgroundTransparency = 1}):Play()
    end)
end

function VisualFX.FadeToBlack(duration, fadeIn, fadeColor)
    Flash.BackgroundColor3 = fadeColor or Color3.new(0,0,0)
    Flash.BackgroundTransparency = fadeIn and 1 or 0
    TweenService:Create(Flash, TweenInfo.new(duration or 0.5), {
        BackgroundTransparency = fadeIn and 0 or 1
    }):Play()
end

function VisualFX.SetLetterbox(height, duration)
    local h = height or 0.08
    TopBar.Visible = true
    BottomBar.Visible = true
    TweenService:Create(TopBar, TweenInfo.new(duration or 0.3), {Size = UDim2.new(1,0,h,0)}):Play()
    TweenService:Create(BottomBar, TweenInfo.new(duration or 0.3), {Size = UDim2.new(1,0,h,0)}):Play()
end

function VisualFX.SetTimeScale(scale, duration, smooth)
    -- Roblox has no safe client-wide physics timescale.
    -- State.TimeScale is exposed for your own game systems.
    State.TimeScale = math.clamp(scale or 1, 0.05, 3)
    if duration and duration > 0 then
        task.delay(duration, function() State.TimeScale = 1 end)
    end
    return State.TimeScale
end

function VisualFX.SetCameraNoise(intensity, speed, noiseColor)
    Config.FX.CameraNoise = intensity or 0
    Config.FX.CameraNoiseSpeed = speed or 8
    Config.FX.CameraNoiseColor = noiseColor or Color3.new(1,1,1)
end

function VisualFX.TriggerRipple(center, amplitude, frequency, decay)
    local ring = Instance.new("Frame")
    ring.AnchorPoint = Vector2.new(0.5,0.5)
    ring.Position = UDim2.fromScale(center and center.X or 0.5, center and center.Y or 0.5)
    ring.Size = UDim2.fromOffset(10,10)
    ring.BackgroundTransparency = 1
    ring.Parent = VFXGui
    corner(ring, 999)
    local s = stroke(ring, Config.Theme.Accent, 0.15, 2)
    TweenService:Create(ring, TweenInfo.new(decay or 0.6, Enum.EasingStyle.Quad), {
        Size = UDim2.fromOffset((amplitude or 120)*2, (amplitude or 120)*2),
        BackgroundTransparency = 1
    }):Play()
    task.delay(decay or 0.6, function() safeDestroy(ring) end)
end

function VisualFX.SetGlitch(intensity, blockSize, colorShift, duration)
    -- Lightweight UI glitch simulation.
    local amount = math.clamp(intensity or 0.3,0,1)
    local d = duration or 0.3
    local start = os.clock()
    task.spawn(function()
        while os.clock() - start < d do
            Flash.BackgroundColor3 = Color3.fromRGB(
                math.random(180,255),
                math.random(180,255),
                math.random(180,255)
            )
            Flash.BackgroundTransparency = 1 - amount*0.12
            task.wait(0.04)
        end
        Flash.BackgroundTransparency = 1
    end)
end

function VisualFX.SetWaterRefraction(refractionIndex, waveSpeed, normalMap)
    Config.FX.WaterRefraction = refractionIndex or 1.33
    Config.FX.WaterWaveSpeed = waveSpeed or 1
    Config.FX.WaterNormalMap = normalMap
end

function VisualFX.SetHeatHaze(intensity, speed, noiseScale)
    Config.FX.HeatHaze = intensity or 0
    Config.FX.HeatSpeed = speed or 1
    Config.FX.HeatNoiseScale = noiseScale or 1
end

function VisualFX.SetGodRays(lightPos, density, weight, color)
    local id = fxId("GodRays")
    local p = Instance.new("Part")
    p.Anchored = true
    p.CanCollide = false
    p.CanTouch = false
    p.CanQuery = false
    p.Transparency = 1
    p.Position = lightPos
    p.Size = Vector3.new(1,1,1)
    p.Parent = workspace
    local l = Instance.new("PointLight")
    l.Brightness = (density or 0.5) * 4
    l.Range = (weight or 0.5) * 80
    l.Color = color or Color3.new(1,0.9,0.7)
    l.Parent = p
    fxRegister(id,p,nil)
    return id
end

function VisualFX.SetPortal(position, rotationSpeed, colorA, colorB, distortion)
    local id = fxId("Portal")
    local p,a = fxPart(position,"VCP_Portal")
    local e = fxEmitter(a,{
        Rate=20,
        Lifetime=NumberRange.new(0.8,1.5),
        Speed=NumberRange.new(1,3),
        LightEmission=1,
        Color=ColorSequence.new(colorA or Config.Theme.Accent,colorB or Config.Theme.Accent2),
        Size=NumberSequence.new(0.14,0),
        Transparency=NumberSequence.new(0.05,1),
        Rotation=NumberRange.new(0,360),
        RotSpeed=NumberRange.new(-120,120),
    })
    fxRegister(id,p,nil)
    task.spawn(function()
        while EffectStates[id] do
            p.Orientation += Vector3.new(0,rotationSpeed or 30,0) * RunService.RenderStepped:Wait()
        end
    end)
    return id
end

function VisualFX.SetForceField(object, color, pulseSpeed, hitIntensity)
    if not object then return nil end
    local id = fxId("ForceField")
    local h = Instance.new("Highlight")
    h.Adornee = object
    h.FillColor = color or Color3.fromRGB(80,180,255)
    h.OutlineColor = color or Color3.fromRGB(80,180,255)
    h.FillTransparency = 0.65
    h.OutlineTransparency = 0.05
    h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    h.Parent = object
    fxRegister(id,h,nil)
    task.spawn(function()
        while EffectStates[id] do
            h.FillTransparency = 0.55 + math.abs(math.sin(os.clock()*(pulseSpeed or 4)))*0.3
            RunService.RenderStepped:Wait()
        end
    end)
    return id
end

function VisualFX.SetCloak(object, transparency, distortionStrength)
    if not object then return nil end
    local id = fxId("Cloak")
    local h = Instance.new("Highlight")
    h.Adornee = object
    h.FillTransparency = math.clamp(transparency or 0.75,0,1)
    h.OutlineTransparency = 1
    h.DepthMode = Enum.HighlightDepthMode.Occluded
    h.Parent = object
    fxRegister(id,h,nil)
    return id
end

function VisualFX.SetFresnel(object, color, power, intensity)
    return VisualFX.SetOutline(object, color or Config.Theme.Accent, intensity or 1, true)
end

function VisualFX.SetOutline(object, color, thickness, pulse)
    if not object then return nil end
    local id = fxId("Outline")
    local h = Instance.new("Highlight")
    h.Adornee = object
    h.FillTransparency = 1
    h.OutlineColor = color or Config.Theme.Accent
    h.OutlineTransparency = 0
    h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    h.Parent = object
    fxRegister(id,h,nil)
    if pulse then
        task.spawn(function()
            while EffectStates[id] do
                h.OutlineTransparency = 0.05 + math.abs(math.sin(os.clock()*5))*0.35
                RunService.RenderStepped:Wait()
            end
        end)
    end
    return id
end

function VisualFX.SetHologram(object, transparency, flickerSpeed, glowColor)
    if not object then return nil end
    local id = fxId("Hologram")
    local h = Instance.new("Highlight")
    h.Adornee = object
    h.FillColor = glowColor or Config.Theme.Accent
    h.OutlineColor = glowColor or Config.Theme.Accent2
    h.FillTransparency = transparency or 0.55
    h.OutlineTransparency = 0.15
    h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    h.Parent = object
    fxRegister(id,h,nil)
    task.spawn(function()
        while EffectStates[id] do
            h.FillTransparency = math.clamp((transparency or 0.55) + math.sin(os.clock()*(flickerSpeed or 6))*0.08,0,1)
            RunService.RenderStepped:Wait()
        end
    end)
    return id
end

function VisualFX.SetDissolve(object, dissolveAmount, edgeColor, noiseTex)
    if not object then return nil end
    local id = fxId("Dissolve")
    local h = Instance.new("Highlight")
    h.Adornee = object
    h.FillColor = edgeColor or Config.Theme.Accent
    h.OutlineColor = edgeColor or Config.Theme.Accent
    h.FillTransparency = math.clamp(dissolveAmount or 0,0,1)
    h.OutlineTransparency = math.clamp((dissolveAmount or 0)*0.8,0,1)
    h.Parent = object
    fxRegister(id,h,nil)
    return id
end

function VisualFX.SetUVScroll(object, speed, direction, pingPong)
    local id = fxId("UVScroll")
    fxRegister(id, object, nil)
    EffectStates[id].UVSpeed = speed or Vector2.new(1,0)
    EffectStates[id].Direction = direction or Vector2.new(1,0)
    EffectStates[id].PingPong = pingPong == true
    return id
end

function VisualFX.SetMasking(object, mask, softness)
    return VisualFX.SetDissolve(object, softness or 0.5, Config.Theme.Accent, mask)
end

function VisualFX.PlaySequence(effects, delayBetween, loop)
    local id = fxId("Sequence")
    fxRegister(id,nil,nil)
    task.spawn(function()
        repeat
            for _, fn in ipairs(effects or {}) do
                if not EffectStates[id] then return end
                if typeof(fn) == "function" then pcall(fn) end
                task.wait(delayBetween or 0.2)
            end
        until not loop or not EffectStates[id]
        EffectStates[id] = nil
    end)
    return id
end

function VisualFX.SetEffectState(effectID, state)
    if state == "Paused" then return VisualFX.PauseEffect(effectID,true) end
    if state == "Playing" then return VisualFX.ResumeEffect(effectID) end
    if state == "Stopped" then return VisualFX.StopEffect(effectID,true) end
    return false
end

-- Aliases / convenience names matching the requested API.
VisualFX.TriggerRipple = VisualFX.TriggerRipple
VisualFX.TriggerShockwave = VisualFX.TriggerShockwave

_G.VisualControlFX = VisualFX
_G.VisualFX = VisualFX

VisualFX.SetBloom(nil, Config.FX.BloomIntensity, Color3.new(1,1,1))
VisualFX.SetColorGrading(Config.FX.ColorSaturation, Config.FX.ColorContrast, 0, Color3.new(1,1,1))
VisualFX.SetDepthOfField(Config.FX.DOFDistance, Config.FX.DOFRadius, 50)
VFXBloom.Enabled = Config.FX.BloomEnabled
VFXColor.Enabled = Config.FX.ColorEnabled
VFXDOF.Enabled = Config.FX.DOFEnabled

-- Notification system
local NotificationHolder = Instance.new("Frame")
NotificationHolder.Name = "Notifications"
NotificationHolder.AnchorPoint = Vector2.new(1, 0)
NotificationHolder.Position = UDim2.new(1, -18, 0, 70)
NotificationHolder.Size = UDim2.fromOffset(300, 300)
NotificationHolder.BackgroundTransparency = 1
NotificationHolder.ZIndex = 30
NotificationHolder.Parent = Gui

local NotificationLayout = Instance.new("UIListLayout")
NotificationLayout.Padding = UDim.new(0, 7)
NotificationLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
NotificationLayout.Parent = NotificationHolder

local function notify(textValue, duration)
    if State.NotificationsEnabled == false then return end
    duration = duration or 2.5

    local n = Instance.new("Frame")
    n.Size = UDim2.fromOffset(285, 48)
    n.BackgroundColor3 = Config.Theme.Panel
    n.BackgroundTransparency = 0.04
    n.BorderSizePixel = 0
    n.ZIndex = 31
    n.Parent = NotificationHolder
    corner(n, 11)
    stroke(n, Config.Theme.Accent, 0.55, 1)

    local dot = Instance.new("Frame")
    dot.Position = UDim2.fromOffset(10, 17)
    dot.Size = UDim2.fromOffset(12, 12)
    dot.BackgroundColor3 = Config.Theme.Accent
    dot.BorderSizePixel = 0
    dot.ZIndex = 32
    dot.Parent = n
    corner(dot, 6)

    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.Position = UDim2.fromOffset(31, 0)
    label.Size = UDim2.new(1, -40, 1, 0)
    label.Font = Enum.Font.GothamMedium
    label.TextSize = 10
    label.TextColor3 = Config.Theme.Text
    label.TextWrapped = true
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Text = textValue
    label.ZIndex = 32
    label.Parent = n

    n.Position = UDim2.new(1, 40, 0, 0)
    tween(n, TweenInfo.new(0.25, Enum.EasingStyle.Quart), {
        Position = UDim2.new(0, 0, 0, 0)
    }):Play()

    task.delay(duration, function()
        if n.Parent then
            local t = tween(n, TweenInfo.new(0.2), {
                Position = UDim2.new(1, 40, 0, 0),
                BackgroundTransparency = 1
            })
            t:Play()
            t.Completed:Wait()
            n:Destroy()
        end
    end)
end

-- Particle background
local function spawnParticle()
    if not Config.Particles.Enabled then return end

    local p = Instance.new("Frame")
    local s = math.random(2, Config.Particles.Size)
    p.Size = UDim2.fromOffset(s, s)
    p.Position = UDim2.fromScale(math.random(), math.random())
    p.BackgroundColor3 = Config.Theme.Accent
    p.BackgroundTransparency = math.random(55, 82) / 100
    p.BorderSizePixel = 0
    p.ZIndex = 2
    p.Parent = ParticleLayer
    corner(p, s)

    table.insert(State.ParticleObjects, p)

    local endX = math.clamp(p.Position.X.Scale + (math.random(-20,20)/100), 0, 1)
    local endY = -0.08

    local tw = tween(p, TweenInfo.new(math.random(10,20) / 10, Enum.EasingStyle.Sine), {
        Position = UDim2.fromScale(endX, endY),
        BackgroundTransparency = 1
    })
    tw:Play()
    tw.Completed:Connect(function()
        safeDestroy(p)
        for i, obj in ipairs(State.ParticleObjects) do
            if obj == p then
                table.remove(State.ParticleObjects, i)
                break
            end
        end
    end)
end

task.spawn(function()
    while not State.Destroyed do
        if Config.Particles.Enabled then
            local current = #State.ParticleObjects
            if current < Config.Particles.Amount then
                spawnParticle()
            end
        end
        task.wait(math.max(0.05, 0.8 / math.max(Config.Particles.Amount, 1)))
    end
end)

-- ESP
local function clearESP(model)
    local data = State.ESPObjects[model]
    if not data then return end

    for _, obj in pairs(data) do
        if typeof(obj) == "Instance" then
            safeDestroy(obj)
        end
    end

    State.ESPObjects[model] = nil
end

local function createBox(parent)
    local box = Instance.new("BillboardGui")
    box.Name = "VCP_Box"
    box.AlwaysOnTop = true
    box.Size = UDim2.fromOffset(70, 100)
    box.StudsOffset = Vector3.new(0, 1, 0)
    box.MaxDistance = Config.ESP.MaxDistance
    box.Parent = parent

    local frame = Instance.new("Frame")
    frame.Size = UDim2.fromScale(1,1)
    frame.BackgroundTransparency = 1
    frame.Parent = box
    stroke(frame, Config.Theme.Accent, Config.ESP.OutlineTransparency, 1.5)

    return box
end

local function createESP(model, player, kind)
    if not model or not model:IsA("Model") then return end
    if State.ESPObjects[model] then return end

    local root = getRoot(model)
    if not root then return end

    local data = {}
    State.ESPObjects[model] = data

    if Config.ESP.Highlight then
        local h = Instance.new("Highlight")
        h.Name = "VCP_Highlight"
        h.Adornee = model
        h.DepthMode = Config.ESP.ThroughWalls and Enum.HighlightDepthMode.AlwaysOnTop or Enum.HighlightDepthMode.Occluded
        h.FillColor = player and Config.Theme.Accent or Config.Theme.Warning
        h.OutlineColor = Config.Theme.Text
        h.FillTransparency = Config.ESP.FillTransparency
        h.OutlineTransparency = Config.ESP.OutlineTransparency
        h.Parent = model
        data.Highlight = h
    end

    if Config.ESP.Box then
        data.Box = createBox(root)
    end

    if Config.ESP.Names or Config.ESP.Health or Config.ESP.Distance or Config.ESP.Team then
        local bb = Instance.new("BillboardGui")
        bb.Name = "VCP_Info"
        bb.AlwaysOnTop = true
        bb.Size = UDim2.fromOffset(220, 65)
        bb.StudsOffset = Vector3.new(0, 3.4, 0)
        bb.MaxDistance = Config.ESP.MaxDistance
        bb.Parent = root

        local info = Instance.new("TextLabel")
        info.Name = "Info"
        info.Size = UDim2.fromScale(1,1)
        info.BackgroundTransparency = 1
        info.TextColor3 = Config.Theme.Text
        info.TextStrokeTransparency = 0.5
        info.Font = Enum.Font.GothamBold
        info.TextSize = 11
        info.TextYAlignment = Enum.TextYAlignment.Bottom
        info.Parent = bb

        data.Info = bb
        data.Label = info
    end

    if Config.ESP.Tracer then
        local tracer = Instance.new("Beam")
        tracer.Name = "VCP_Tracer"
        tracer.FaceCamera = true
        tracer.Width0 = 0.025
        tracer.Width1 = 0.025
        tracer.Color = ColorSequence.new(Config.Theme.Accent)
        tracer.Transparency = NumberSequence.new(0.2)

        local a0 = Instance.new("Attachment")
        a0.Name = "VCP_TracerA0"
        a0.Parent = root

        local cameraPart = Instance.new("Part")
        cameraPart.Name = "VCP_TracerOrigin"
        cameraPart.Anchored = true
        cameraPart.CanCollide = false
        cameraPart.CanQuery = false
        cameraPart.CanTouch = false
        cameraPart.Transparency = 1
        cameraPart.Size = Vector3.new(0.1,0.1,0.1)
        cameraPart.Parent = workspace

        local a1 = Instance.new("Attachment")
        a1.Parent = cameraPart

        tracer.Attachment0 = a0
        tracer.Attachment1 = a1
        tracer.Parent = root

        data.Tracer = tracer
        data.TracerPart = cameraPart
        data.TracerAttachment = a1
    end

    data.Kind = kind
    data.Player = player
end

local function updateESP(model, data)
    local root = getRoot(model)
    if not root then return end

    local myRoot = getRoot(LocalPlayer.Character)
    local distance = myRoot and (root.Position - myRoot.Position).Magnitude or 0
    local visible = distance <= Config.ESP.MaxDistance

    if data.Highlight then
        data.Highlight.Enabled = visible
        data.Highlight.DepthMode = Config.ESP.ThroughWalls and Enum.HighlightDepthMode.AlwaysOnTop or Enum.HighlightDepthMode.Occluded
        data.Highlight.FillTransparency = Config.ESP.FillTransparency
    end

    if data.Box then
        data.Box.Enabled = visible and Config.ESP.Box
        data.Box.MaxDistance = Config.ESP.MaxDistance
    end

    local humanoid = getHumanoid(model)
    if data.Label then
        local lines = {}

        local displayName = model.Name
        if data.Player then
            displayName = data.Player.DisplayName
            if Config.ESP.Names then
                table.insert(lines, displayName .. "  @" .. data.Player.Name)
            end
        else
            if Config.ESP.Names then
                table.insert(lines, displayName)
            end
        end

        if Config.ESP.Health and humanoid then
            table.insert(lines, "HP: " .. getHealthText(humanoid))
        end

        if Config.ESP.Distance then
            table.insert(lines, string.format("%dm", math.floor(distance)))
        end

        if Config.ESP.Team and data.Player then
            table.insert(lines, data.Player.Team and data.Player.Team.Name or T("teamNone"))
        end

        data.Label.Text = table.concat(lines, "  •  ")
        data.Info.Enabled = visible and #lines > 0
    end

    if data.Tracer and data.TracerPart then
        data.Tracer.Enabled = visible and Config.ESP.Tracer
        data.TracerPart.CFrame = Camera.CFrame * CFrame.new(0, -0.45, -2)
    end
end

local function setupPlayer(player)
    if player == LocalPlayer then return end

    local function characterAdded(character)
        task.wait(0.35)
        if Config.ESP.Players then
            createESP(character, player, "Player")
        end
    end

    player.CharacterAdded:Connect(characterAdded)

    if player.Character then
        characterAdded(player.Character)
    end
end

for _, player in ipairs(Players:GetPlayers()) do
    setupPlayer(player)
end

Players.PlayerAdded:Connect(setupPlayer)
Players.PlayerRemoving:Connect(function(player)
    if player.Character then
        clearESP(player.Character)
    end
end)

local function scanNPCs()
    if not Config.ESP.NPCs then return end
    local folder = workspace:FindFirstChild("NPCs")
    if not folder then return end

    for _, model in ipairs(folder:GetChildren()) do
        if model:IsA("Model") and getRoot(model) then
            createESP(model, nil, "NPC")
        end
    end
end

local function scanItems()
    if not Config.ESP.Items then return end
    local folder = workspace:FindFirstChild("Items")
    if not folder then return end

    for _, item in ipairs(folder:GetChildren()) do
        if item:IsA("Model") and getRoot(item) then
            createESP(item, nil, "Item")
        end
    end
end

-- Target card
local TargetCard = Instance.new("Frame")
TargetCard.Name = "TargetCard"
TargetCard.AnchorPoint = Vector2.new(0.5, 1)
TargetCard.Position = UDim2.new(0.5, 0, 1, 120)
TargetCard.Size = UDim2.fromOffset(420, 92)
TargetCard.BackgroundColor3 = Config.Theme.Panel
TargetCard.BorderSizePixel = 0
TargetCard.ZIndex = 20
TargetCard.Visible = false
TargetCard.Parent = Gui
corner(TargetCard, 14)
stroke(TargetCard, Config.Theme.Accent, 0.45, 1)

local TargetAvatar = Instance.new("ImageLabel")
TargetAvatar.Position = UDim2.fromOffset(12, 12)
TargetAvatar.Size = UDim2.fromOffset(68, 68)
TargetAvatar.BackgroundColor3 = Config.Theme.Panel2
TargetAvatar.BorderSizePixel = 0
TargetAvatar.Image = ""
TargetAvatar.Parent = TargetCard
corner(TargetAvatar, 12)

local TargetName = Instance.new("TextLabel")
TargetName.Position = UDim2.fromOffset(92, 10)
TargetName.Size = UDim2.new(1, -105, 0, 22)
TargetName.BackgroundTransparency = 1
TargetName.TextColor3 = Config.Theme.Text
TargetName.TextSize = 14
TargetName.Font = Enum.Font.GothamBold
TargetName.TextXAlignment = Enum.TextXAlignment.Left
TargetName.Parent = TargetCard

local TargetUser = Instance.new("TextLabel")
TargetUser.Position = UDim2.fromOffset(92, 32)
TargetUser.Size = UDim2.new(1, -105, 0, 17)
TargetUser.BackgroundTransparency = 1
TargetUser.TextColor3 = Config.Theme.Muted
TargetUser.TextSize = 9
TargetUser.Font = Enum.Font.Gotham
TargetUser.TextXAlignment = Enum.TextXAlignment.Left
TargetUser.Parent = TargetCard

local TargetInfo = Instance.new("TextLabel")
TargetInfo.Position = UDim2.fromOffset(92, 50)
TargetInfo.Size = UDim2.new(1, -105, 0, 17)
TargetInfo.BackgroundTransparency = 1
TargetInfo.TextColor3 = Config.Theme.Muted
TargetInfo.TextSize = 9
TargetInfo.Font = Enum.Font.GothamMedium
TargetInfo.TextXAlignment = Enum.TextXAlignment.Left
TargetInfo.Parent = TargetCard

local HPBack = Instance.new("Frame")
HPBack.Position = UDim2.fromOffset(92, 73)
HPBack.Size = UDim2.new(1, -108, 0, 7)
HPBack.BackgroundColor3 = Config.Theme.Panel2
HPBack.BorderSizePixel = 0
HPBack.Parent = TargetCard
corner(HPBack, 4)

local HPFill = Instance.new("Frame")
HPFill.Size = UDim2.fromScale(1,1)
HPFill.BackgroundColor3 = Config.Theme.Success
HPFill.BorderSizePixel = 0
HPFill.Parent = HPBack
corner(HPFill, 4)

local function showTargetCard(player)
    if not player or not Config.Target.Enabled then return end

    State.SelectedTarget = player
    TargetCard.Visible = true

    if Config.Target.ShowAvatar then
        local ok, image = pcall(function()
            return Players:GetUserThumbnailAsync(player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
        end)
        if ok then TargetAvatar.Image = image end
        TargetAvatar.Visible = true
    else
        TargetAvatar.Visible = false
    end

    TargetName.Text = player.DisplayName
    TargetUser.Text = T("username") .. ": @" .. player.Name

    local character = player.Character
    local humanoid = getHumanoid(character)
    local distance = getDistance(character)

    local info = {}

    if Config.Target.ShowHealth and humanoid then
        table.insert(info, "HP " .. getHealthText(humanoid))
    end

    if Config.Target.ShowDistance and distance then
        table.insert(info, string.format("%dm", math.floor(distance)))
    end

    if Config.Target.ShowTeam then
        table.insert(info, player.Team and player.Team.Name or T("teamNone"))
    end

    TargetInfo.Text = table.concat(info, "  •  ")

    if humanoid then
        HPFill.Size = UDim2.fromScale(math.clamp(humanoid.Health / math.max(humanoid.MaxHealth,1), 0, 1), 1)
    else
        HPFill.Size = UDim2.fromScale(0,1)
    end

    TargetCard.Position = UDim2.new(0.5, 0, 1, 110)
    tween(TargetCard, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {
        Position = UDim2.new(0.5, 0, 1, -16)
    }):Play()
end

local function clearTarget()
    State.SelectedTarget = nil
    tween(TargetCard, TweenInfo.new(0.2, Enum.EasingStyle.Quart), {
        Position = UDim2.new(0.5, 0, 1, 110)
    }):Play()
    task.delay(0.22, function()
        if not State.SelectedTarget then
            TargetCard.Visible = false
        end
    end)
end

-- Click target
local mouse = LocalPlayer:GetMouse()

mouse.Button1Down:Connect(function()
    if not Config.Target.Enabled then return end
    if not State.MenuOpen then return end

    local targetPart = mouse.Target
    if not targetPart then return end

    local character = targetPart:FindFirstAncestorOfClass("Model")
    if not character then return end

    local player = Players:GetPlayerFromCharacter(character)
    if player and player ~= LocalPlayer then
        showTargetCard(player)
        notify(T("targetSet") .. ": " .. player.DisplayName)
    end
end)

-- FOV
local FOVCircle = Instance.new("Frame")
FOVCircle.Name = "FOVCircle"
FOVCircle.AnchorPoint = Vector2.new(0.5, 0.5)
FOVCircle.Position = UDim2.fromScale(0.5, 0.5)
FOVCircle.Size = UDim2.fromOffset(Config.FOV.Radius*2, Config.FOV.Radius*2)
FOVCircle.BackgroundTransparency = 1
FOVCircle.Visible = Config.FOV.Enabled
FOVCircle.ZIndex = 3
FOVCircle.Parent = Gui
corner(FOVCircle, Config.FOV.Radius)

local FOVStroke = stroke(FOVCircle, Config.Theme.Accent, 0.25, Config.FOV.Thickness)
local FOVCorner = FOVCircle:FindFirstChildOfClass("UICorner")

-- Pages
local VisualPage = Pages.Visual
section(VisualPage, T("appearance"))
toggle(VisualPage, T("blur"), Config.Blur.Enabled, function(v)
    Config.Blur.Enabled = v
    Blur.Size = v and Config.Blur.Size or 0
end)
toggle(VisualPage, T("particles"), Config.Particles.Enabled, function(v)
    Config.Particles.Enabled = v
end)
slider(VisualPage, T("particleAmount"), 0, 40, Config.Particles.Amount, function(v)
    Config.Particles.Amount = v
end)
slider(VisualPage, T("uiScale"), 70, 110, 92, function(v)
    Scale.Scale = v / 100
end)

section(VisualPage, T("effects"))
toggle(VisualPage, T("bloom"), Config.Effects.Bloom, function(v)
    Config.Effects.Bloom = v
    Bloom.Intensity = v and Config.Effects.BloomIntensity or 0
end)
toggle(VisualPage, T("colorCorrection"), Config.Effects.ColorCorrection, function(v)
    Config.Effects.ColorCorrection = v
    ColorCorrection.Saturation = v and Config.Effects.Saturation or 0
    ColorCorrection.Contrast = v and Config.Effects.Contrast or 0
end)
toggle(VisualPage, T("atmosphere"), Config.Effects.Atmosphere, function(v)
    Config.Effects.Atmosphere = v
    Atmosphere.Density = v and 0.15 or 0
end)

local PlayersPage = Pages.Players
section(PlayersPage, T("playerInfo"))
toggle(PlayersPage, T("playerESP"), Config.ESP.Players, function(v)
    Config.ESP.Players = v
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            if v then createESP(player.Character, player, "Player") else clearESP(player.Character) end
        end
    end
end)
toggle(PlayersPage, T("highlight"), Config.ESP.Highlight, function(v) Config.ESP.Highlight = v end)
toggle(PlayersPage, T("box"), Config.ESP.Box, function(v) Config.ESP.Box = v end)
toggle(PlayersPage, T("names"), Config.ESP.Names, function(v) Config.ESP.Names = v end)
toggle(PlayersPage, T("health"), Config.ESP.Health, function(v) Config.ESP.Health = v end)
toggle(PlayersPage, T("distance"), Config.ESP.Distance, function(v) Config.ESP.Distance = v end)
toggle(PlayersPage, T("team"), Config.ESP.Team, function(v) Config.ESP.Team = v end)
toggle(PlayersPage, T("tracer"), Config.ESP.Tracer, function(v) Config.ESP.Tracer = v end)
toggle(PlayersPage, T("throughWalls"), Config.ESP.ThroughWalls, function(v) Config.ESP.ThroughWalls = v end)
slider(PlayersPage, T("maxDistance"), 100, 2000, Config.ESP.MaxDistance, function(v) Config.ESP.MaxDistance = v end)

local TargetPage = Pages.Target
section(TargetPage, T("target"))
toggle(TargetPage, T("targetCard"), Config.Target.Enabled, function(v)
    Config.Target.Enabled = v
    if not v then clearTarget() end
end)
toggle(TargetPage, T("avatar"), Config.Target.ShowAvatar, function(v) Config.Target.ShowAvatar = v end)
toggle(TargetPage, T("targetHealth"), Config.Target.ShowHealth, function(v) Config.Target.ShowHealth = v end)
toggle(TargetPage, T("targetDistance"), Config.Target.ShowDistance, function(v) Config.Target.ShowDistance = v end)
toggle(TargetPage, T("targetTeam"), Config.Target.ShowTeam, function(v) Config.Target.ShowTeam = v end)
button(TargetPage, T("resetTarget"), function()
    clearTarget()
    notify(T("targetCleared"))
end)
section(TargetPage, T("fov"))
toggle(TargetPage, T("fov"), Config.FOV.Enabled, function(v)
    Config.FOV.Enabled = v
    FOVCircle.Visible = v
end)
slider(TargetPage, T("fovRadius"), 50, 350, Config.FOV.Radius, function(v)
    Config.FOV.Radius = v
    FOVCircle.Size = UDim2.fromOffset(v*2, v*2)
    local fovCorner = FOVCircle:FindFirstChildOfClass("UICorner")
    if fovCorner then
        fovCorner.CornerRadius = UDim.new(0, v)
    end
end)

local ObjectsPage = Pages.Objects
section(ObjectsPage, T("objects"))
toggle(ObjectsPage, T("npcESP"), Config.ESP.NPCs, function(v)
    Config.ESP.NPCs = v
    if v then scanNPCs() end
end)
toggle(ObjectsPage, T("itemESP"), Config.ESP.Items, function(v)
    Config.ESP.Items = v
    if v then scanItems() end
end)

local npcInfo = Instance.new("TextLabel")
npcInfo.Size = UDim2.new(1,-4,0,34)
npcInfo.BackgroundColor3 = Config.Theme.Panel
npcInfo.TextColor3 = Config.Theme.Muted
npcInfo.TextSize = 9
npcInfo.Font = Enum.Font.Gotham
npcInfo.TextWrapped = true
npcInfo.Text = T("npcFolder")
npcInfo.Parent = ObjectsPage
corner(npcInfo, 9)

local itemInfo = npcInfo:Clone()
itemInfo.Text = T("itemFolder")
itemInfo.Parent = ObjectsPage

local WorldPage = Pages.World

local EffectsPage = Pages.Effects
section(EffectsPage, T("effects"))
slider(EffectsPage, "Blur Strength", 0, 30, Config.Blur.Size, function(v)
    Config.Blur.Size = v
    if Config.Blur.Enabled then Blur.Size = v end
end)
slider(EffectsPage, "Bloom Intensity", 0, 100, Config.Effects.BloomIntensity*100, function(v)
    Config.Effects.BloomIntensity = v/100
    if Config.Effects.Bloom then Bloom.Intensity = Config.Effects.BloomIntensity end
end)
slider(EffectsPage, "Color Saturation", -100, 100, Config.Effects.Saturation*100, function(v)
    Config.Effects.Saturation = v/100
    if Config.Effects.ColorCorrection then ColorCorrection.Saturation = Config.Effects.Saturation end
end)
slider(EffectsPage, "Contrast", -100, 100, Config.Effects.Contrast*100, function(v)
    Config.Effects.Contrast = v/100
    if Config.Effects.ColorCorrection then ColorCorrection.Contrast = Config.Effects.Contrast end
end)


-- World customization page
section(WorldPage, T("worldEffects"))

toggle(WorldPage, T("worldEffects"), Config.World.Enabled, function(v)
    Config.World.Enabled = v
    applyWorldLighting()
    updateWorldParticles()
end)

toggle(WorldPage, T("fog"), Config.World.FogEnabled, function(v)
    Config.World.FogEnabled = v
    applyWorldLighting()
end)

slider(WorldPage, T("fogStart"), 0, 500, Config.World.FogStart, function(v)
    Config.World.FogStart = v
    applyWorldLighting()
end)

slider(WorldPage, T("fogEnd"), 100, 3000, Config.World.FogEnd, function(v)
    Config.World.FogEnd = v
    applyWorldLighting()
end)

slider(WorldPage, T("fogDensity"), 0, 100, Config.World.FogDensity * 100, function(v)
    Config.World.FogDensity = v / 100
    applyWorldLighting()
end)

toggle(WorldPage, T("worldBlur"), Config.World.WorldBlur, function(v)
    Config.World.WorldBlur = v
    applyWorldLighting()
end)

slider(WorldPage, T("worldBlurSize"), 0, 20, Config.World.WorldBlurSize, function(v)
    Config.World.WorldBlurSize = v
    applyWorldLighting()
end)

section(WorldPage, T("worldColor"))

slider(WorldPage, T("saturation"), -100, 100, Config.World.WorldSaturation * 100, function(v)
    Config.World.WorldSaturation = v / 100
    applyWorldLighting()
end)

slider(WorldPage, T("contrast"), -100, 100, Config.World.WorldContrast * 100, function(v)
    Config.World.WorldContrast = v / 100
    applyWorldLighting()
end)

slider(WorldPage, T("brightness"), -100, 100, Config.World.WorldBrightness * 100, function(v)
    Config.World.WorldBrightness = v / 100
    applyWorldLighting()
end)

section(WorldPage, T("sky"))

button(WorldPage, "☀  Day", function()
    Config.World.SkyTint = Color3.fromRGB(205, 225, 255)
    Config.World.AtmosphereColor = Color3.fromRGB(190, 215, 255)
    Config.World.AtmosphereDecay = Color3.fromRGB(120, 145, 180)
    Config.World.FogColor = Color3.fromRGB(170, 195, 225)
    applyWorldLighting()
end)

button(WorldPage, "☾  Night", function()
    Config.World.SkyTint = Color3.fromRGB(105, 120, 175)
    Config.World.AtmosphereColor = Color3.fromRGB(90, 105, 150)
    Config.World.AtmosphereDecay = Color3.fromRGB(40, 45, 75)
    Config.World.FogColor = Color3.fromRGB(65, 75, 105)
    applyWorldLighting()
end)

button(WorldPage, "◉  Sunset", function()
    Config.World.SkyTint = Color3.fromRGB(255, 185, 135)
    Config.World.AtmosphereColor = Color3.fromRGB(255, 170, 120)
    Config.World.AtmosphereDecay = Color3.fromRGB(135, 80, 90)
    Config.World.FogColor = Color3.fromRGB(220, 145, 120)
    applyWorldLighting()
end)

button(WorldPage, "✦  Cold", function()
    Config.World.SkyTint = Color3.fromRGB(175, 205, 235)
    Config.World.AtmosphereColor = Color3.fromRGB(155, 190, 225)
    Config.World.AtmosphereDecay = Color3.fromRGB(80, 105, 145)
    Config.World.FogColor = Color3.fromRGB(145, 175, 205)
    applyWorldLighting()
end)


section(WorldPage, Config.Language == "ru" and "Палитры неба" or "Sky Palettes")

local skyPalettes = {
    {"Ocean", Color3.fromRGB(150, 205, 255), Color3.fromRGB(175, 215, 255), Color3.fromRGB(90, 120, 170)},
    {"Azure", Color3.fromRGB(110, 175, 255), Color3.fromRGB(150, 200, 255), Color3.fromRGB(70, 105, 165)},
    {"Purple", Color3.fromRGB(175, 145, 255), Color3.fromRGB(165, 145, 230), Color3.fromRGB(85, 65, 130)},
    {"Rose", Color3.fromRGB(255, 165, 185), Color3.fromRGB(245, 165, 180), Color3.fromRGB(130, 75, 100)},
    {"Golden", Color3.fromRGB(255, 205, 135), Color3.fromRGB(255, 185, 125), Color3.fromRGB(145, 95, 70)},
    {"Emerald", Color3.fromRGB(135, 225, 180), Color3.fromRGB(135, 205, 175), Color3.fromRGB(65, 115, 90)},
    {"Ice", Color3.fromRGB(190, 225, 255), Color3.fromRGB(175, 215, 240), Color3.fromRGB(100, 135, 165)},
    {"Dark", Color3.fromRGB(70, 80, 120), Color3.fromRGB(65, 75, 105), Color3.fromRGB(30, 35, 60)},
}

for _, paletteData in ipairs(skyPalettes) do
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, -4, 0, 34)
    b.BackgroundColor3 = paletteData[2]
    b.TextColor3 = Color3.new(1,1,1)
    b.TextStrokeTransparency = 0.65
    b.TextSize = 10
    b.Font = Enum.Font.GothamBold
    b.Text = "●  " .. paletteData[1]
    b.AutoButtonColor = false
    b.Parent = WorldPage
    corner(b, 9)

    b.Activated:Connect(function()
        Config.World.SkyTint = paletteData[2]
        Config.World.AtmosphereColor = paletteData[3]
        Config.World.AtmosphereDecay = paletteData[4]
        Config.World.FogColor = paletteData[4]
        applyWorldLighting()
    end)
end

section(WorldPage, T("worldParticles"))

toggle(WorldPage, T("worldParticles"), Config.World.WorldParticles, function(v)
    Config.World.WorldParticles = v
    updateWorldParticles()
end)

slider(WorldPage, T("particleRate"), 0, 60, Config.World.ParticleRate, function(v)
    Config.World.ParticleRate = v
    updateWorldParticles()
end)

slider(WorldPage, T("particleLifetime"), 1, 6, Config.World.ParticleLifetime, function(v)
    Config.World.ParticleLifetime = v
    updateWorldParticles()
end)

slider(WorldPage, T("particleSpeed"), 0, 12, Config.World.ParticleSpeed, function(v)
    Config.World.ParticleSpeed = v
    updateWorldParticles()
end)

section(WorldPage, Config.Language == "ru" and "Эффекты движения" or "Movement FX")

toggle(WorldPage, T("jumpEffect"), Config.World.JumpEffect, function(v)
    Config.World.JumpEffect = v
end)

toggle(WorldPage, T("landingEffect"), Config.World.LandingEffect, function(v)
    Config.World.LandingEffect = v
end)

slider(WorldPage, T("jumpBurst"), 1, 50, Config.World.JumpBurst, function(v)
    Config.World.JumpBurst = v
end)

slider(WorldPage, T("landingBurst"), 1, 70, Config.World.LandingBurst, function(v)
    Config.World.LandingBurst = v
end)

slider(WorldPage, T("effectSize"), 50, 200, Config.World.EffectSize * 100, function(v)
    Config.World.EffectSize = v / 100
end)



-- FX Lab page
local function fxDemoPosition()
    local root = getRoot(LocalPlayer.Character)
    return root and (root.Position + Vector3.new(0, 1, -4)) or Vector3.new(0,5,0)
end

section(Pages["FX Lab"], Config.Language == "ru" and "Готовые пресеты" or "Presets")

button(Pages["FX Lab"], "✦  Cinematic", function()
    Config.FX.BloomEnabled = true
    Config.FX.ColorEnabled = true
    Config.FX.ColorSaturation = -0.05
    Config.FX.ColorContrast = 0.12
    Config.FX.DOFEnabled = true
    Config.FX.DOFDistance = 35
    Config.FX.DOFRadius = 12
    VisualFX.SetBloom(1.0, 0.5, Color3.fromRGB(255,245,225))
    VisualFX.SetColorGrading(-0.05,0.12,0,Color3.fromRGB(255,245,235))
    VisualFX.SetDepthOfField(35,12,55)
end)

button(Pages["FX Lab"], "⚡  Arcade", function()
    Config.FX.BloomEnabled = true
    Config.FX.DOFEnabled = false
    VisualFX.SetBloom(0.8,0.75,Color3.fromRGB(180,220,255))
    VisualFX.SetColorGrading(0.15,0.15,0,Color3.fromRGB(235,245,255))
    VisualFX.FlashScreen(Config.Theme.Accent,0.04,0.18)
end)

button(Pages["FX Lab"], "☾  Dreamy", function()
    Config.FX.BloomEnabled = true
    Config.FX.DOFEnabled = true
    VisualFX.SetBloom(0.7,0.9,Color3.fromRGB(220,190,255))
    VisualFX.SetColorGrading(0.08,-0.02,0,Color3.fromRGB(240,225,255))
    VisualFX.SetDepthOfField(45,20,45)
end)

button(Pages["FX Lab"], "■  Dark", function()
    Config.FX.BloomEnabled = false
    Config.FX.DOFEnabled = true
    VisualFX.SetColorGrading(-0.15,0.25,0,Color3.fromRGB(180,190,220))
    VisualFX.SetDepthOfField(30,10,60)
end)

button(Pages["FX Lab"], T("resetFX"), function()
    Config.FX.BloomEnabled = true
    Config.FX.ColorEnabled = true
    Config.FX.DOFEnabled = false
    VisualFX.SetBloom(1.1,0.35,Color3.new(1,1,1))
    VisualFX.SetColorGrading(0.08,0.05,0,Color3.new(1,1,1))
    VisualFX.SetDepthOfField(35,18,50)
    VisualFX.SetCameraFOV(70,0.2)
    VisualFX.SetLetterbox(0,0.2)
end)

section(Pages["FX Lab"], Config.Language == "ru" and "Экран" or "Screen")

toggle(Pages["FX Lab"], Config.Language == "ru" and "Экранные FX" or "Screen FX", Config.FX.Enabled, function(v)
    Config.FX.Enabled = v
    VFXBloom.Enabled = v and Config.FX.BloomEnabled
    VFXColor.Enabled = v and Config.FX.ColorEnabled
    VFXDOF.Enabled = v and Config.FX.DOFEnabled
end)

toggle(Pages["FX Lab"], T("bloom"), Config.FX.BloomEnabled, function(v)
    Config.FX.BloomEnabled = v
    VFXBloom.Enabled = Config.FX.Enabled and v
end)

toggle(Pages["FX Lab"], T("dof"), Config.FX.DOFEnabled, function(v)
    Config.FX.DOFEnabled = v
    VFXDOF.Enabled = Config.FX.Enabled and v
end)

toggle(Pages["FX Lab"], T("vignette"), Config.FX.VignetteEnabled, function(v)
    Config.FX.VignetteEnabled = v
    Vignette.BackgroundTransparency = v and (1-Config.FX.VignetteIntensity) or 1
end)

slider(Pages["FX Lab"], "Bloom", 0, 100, Config.FX.BloomIntensity*100, function(v)
    Config.FX.BloomIntensity = v/100
    VisualFX.SetBloom(1.1,Config.FX.BloomIntensity,Color3.new(1,1,1))
end)

slider(Pages["FX Lab"], T("cameraFOV"), 40, 110, Config.FX.CameraFOV, function(v)
    VisualFX.SetCameraFOV(v,0.15)
end)

section(Pages["FX Lab"], T("demoEffects"))

button(Pages["FX Lab"], "✦  "..T("sparks"), function() VisualFX.PlaySparks(fxDemoPosition(),24,Config.Theme.Accent,14) end)
button(Pages["FX Lab"], "☁  "..T("smoke"), function() VisualFX.PlaySmoke(fxDemoPosition(),14,2.5,3) end)
button(Pages["FX Lab"], "•  "..T("dust"), function() VisualFX.PlayDust(fxDemoPosition(),1,Color3.fromRGB(185,175,160),80) end)
button(Pages["FX Lab"], "✧  "..T("magic"), function() VisualFX.PlayMagicMotes(LocalPlayer.Character,4,2,Config.Theme.Accent) end)
button(Pages["FX Lab"], "🔥  "..T("fire"), function() VisualFX.PlayFire(fxDemoPosition(),1,8,Color3.fromRGB(255,145,45)) end)
button(Pages["FX Lab"], "⚡  "..T("electricity"), function()
    local p = fxDemoPosition()
    VisualFX.PlayElectricity(p,p+Vector3.new(0,5,-2),0.1,10)
end)
button(Pages["FX Lab"], "○  "..T("bubbles"), function() VisualFX.PlayBubbles(fxDemoPosition(),3,1) end)
button(Pages["FX Lab"], "❄  "..T("snow"), function() VisualFX.PlaySnow(fxDemoPosition()+Vector3.new(0,7,0),3,1,0.12) end)
button(Pages["FX Lab"], "🍂  "..T("leaves"), function() VisualFX.PlayLeaves(fxDemoPosition()+Vector3.new(0,5,0),2,90) end)
button(Pages["FX Lab"], "↝  "..T("trail"), function() VisualFX.PlayTrail(LocalPlayer.Character,0.45,Config.Theme.Accent,Config.Theme.Accent2) end)
button(Pages["FX Lab"], "✹  "..T("explosion"), function()
    local p = fxDemoPosition()
    VisualFX.PlayExplosion(p,8,18,0)
    VisualFX.ShakeCamera(0.7,0.25,0.8,true)
end)
button(Pages["FX Lab"], "＋  "..T("heal"), function() VisualFX.PlayHeal(LocalPlayer.Character,Config.Theme.Success,2,24) end)
button(Pages["FX Lab"], "◆  "..T("impact"), function() VisualFX.PlayImpact(fxDemoPosition(),Vector3.new(0,1,0),1) end)
button(Pages["FX Lab"], "◉  "..T("shockwave"), function() VisualFX.TriggerShockwave(fxDemoPosition(),12,25,0.25) end)
button(Pages["FX Lab"], "◎  "..T("portal"), function() VisualFX.SetPortal(fxDemoPosition(),35,Config.Theme.Accent,Config.Theme.Accent2,1) end)
button(Pages["FX Lab"], "◇  "..T("forcefield"), function() VisualFX.SetForceField(LocalPlayer.Character,Config.Theme.Accent,5,1) end)
button(Pages["FX Lab"], "▣  "..T("hologram"), function() VisualFX.SetHologram(LocalPlayer.Character,0.55,7,Config.Theme.Accent) end)

section(Pages["FX Lab"], Config.Language == "ru" and "Управление" or "Management")

button(Pages["FX Lab"], Config.Language == "ru" and "Остановить все FX" or "Stop all FX", function()
    VisualFX.StopAllEffects(false)
end)

button(Pages["FX Lab"], Config.Language == "ru" and "Вспышка экрана" or "Screen Flash", function()
    VisualFX.FlashScreen(Config.Theme.Accent,0.08,0.25)
end)

button(Pages["FX Lab"], Config.Language == "ru" and "Удар камеры" or "Camera Shake", function()
    VisualFX.ShakeCamera(0.8,0.35,0.9,true)
end)

button(Pages["FX Lab"], Config.Language == "ru" and "Ударная волна экрана" or "Screen Ripple", function()
    VisualFX.TriggerRipple(Vector2.new(0.5,0.5),150,4,0.65)
end)


local SettingsPage = Pages.Settings
section(SettingsPage, T("language"))

local languageButton = Instance.new("TextButton")
languageButton.Size = UDim2.new(1,-4,0,42)
languageButton.BackgroundColor3 = Config.Theme.Panel
languageButton.TextColor3 = Config.Theme.Text
languageButton.TextSize = 11
languageButton.Font = Enum.Font.GothamBold
languageButton.Text = "Русский  /  English"
languageButton.AutoButtonColor = false
languageButton.Parent = SettingsPage
corner(languageButton, 9)

local function refreshLanguage()
    Title.Text = T("title")
    Subtitle.Text = T("subtitle")
    Close.Text = "✕"

    local icons = {
        Visual = "◈", Players = "◎", Target = "⌖",
        Objects = "◇", Effects = "✦", Settings = "⚙"
    }

    for name, tab in pairs(Tabs) do
        tab.Text = "  " .. icons[name] .. "   " .. T(tabKeyMap[name])
    end

    -- Переводит все уже созданные элементы интерфейса без пересоздания меню.
    local translations = {}
    for key, ruText in pairs(L.ru) do
        local enText = L.en[key]
        if ruText then translations[ruText] = (Config.Language == "ru" and ruText or enText) end
        if enText then translations[enText] = (Config.Language == "ru" and ruText or enText) end
    end

    for _, obj in ipairs(Gui:GetDescendants()) do
        if obj:IsA("TextLabel") or obj:IsA("TextButton") then
            local current = obj.Text
            local translated = translations[current]
            if translated then
                obj.Text = translated
            end
        end
    end

    languageButton.Text = T("language") .. ": " .. (Config.Language == "ru" and T("russian") or T("english"))
end

languageButton.Activated:Connect(function()
    Config.Language = Config.Language == "ru" and "en" or "ru"
    refreshLanguage()
    notify(T("languageChanged"))
end)

section(SettingsPage, T("performance"))
toggle(SettingsPage, T("lowGraphics"), Config.Performance.LowGraphics, function(v)
    Config.Performance.LowGraphics = v
    Config.Performance.UpdateRate = v and 0.18 or 0.08
    if v then
        Config.Particles.Amount = math.min(Config.Particles.Amount, 8)
        notify(T("performanceOn"))
    else
        notify(T("performanceOff"))
    end
end)

toggle(SettingsPage, T("notifications"), true, function(v)
    State.NotificationsEnabled = v
end)

section(SettingsPage, T("theme"))

local function themeButton(textValue, color, themeName)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1,-4,0,34)
    b.BackgroundColor3 = color
    b.TextColor3 = Color3.new(1,1,1)
    b.TextSize = 10
    b.Font = Enum.Font.GothamBold
    b.Text = textValue
    b.AutoButtonColor = false
    b.Parent = SettingsPage
    corner(b, 9)

    b.Activated:Connect(function()
        Config.Theme.Accent = color
        Config.ThemeName = themeName
        FOVStroke.Color = color
        notify(textValue)
    end)
end

themeButton(T("blue"), Color3.fromRGB(88,166,255), "Blue")
themeButton(T("purple"), Color3.fromRGB(150,95,255), "Purple")
themeButton(T("green"), Color3.fromRGB(60,210,135), "Green")
themeButton(T("red"), Color3.fromRGB(255,85,100), "Red")

button(SettingsPage, T("resetSettings"), function()
    Config.Blur.Enabled = true
    Config.Particles.Enabled = true
    Config.ESP.Players = true
    Config.ESP.Highlight = true
    Config.ESP.Box = true
    Config.ESP.Names = true
    Config.ESP.Health = true
    Config.ESP.Distance = true
    Config.ESP.ThroughWalls = true
    Config.Target.Enabled = true
    Config.FOV.Enabled = false

    Config.World.Enabled = true
    Config.World.FogEnabled = false
    Config.World.WorldBlur = false
    Config.World.WorldParticles = true
    Config.World.SkyTint = Color3.fromRGB(180, 205, 255)
    Config.World.AtmosphereColor = Color3.fromRGB(190, 215, 255)
    Config.World.AtmosphereDecay = Color3.fromRGB(100, 125, 165)
    Config.World.FogColor = Color3.fromRGB(150, 175, 205)
    Config.World.WorldSaturation = 0.08
    Config.World.WorldContrast = 0.05
    Config.World.WorldBrightness = 0.02

    Blur.Size = Config.Blur.Size
    FOVCircle.Visible = false
    applyWorldLighting()
    updateWorldParticles()

    for model, data in pairs(State.ESPObjects) do
        clearESP(model)
    end

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            createESP(player.Character, player, "Player")
        end
    end

    notify(T("default"))
end)

-- Tab navigation
local function selectTab(name)
    State.CurrentTab = name

    for tabName, page in pairs(Pages) do
        page.Visible = tabName == name
    end

    for tabName, tab in pairs(Tabs) do
        local selected = tabName == name
        tab.BackgroundColor3 = selected and Config.Theme.Accent or Config.Theme.Panel
        tab.TextColor3 = selected and Color3.new(1,1,1) or Config.Theme.Muted
    end
end

for name, tab in pairs(Tabs) do
    tab.Activated:Connect(function()
        selectTab(name)
    end)
end

selectTab("Visual")

-- Dragging
do
    local dragging = false
    local dragStart
    local startPos

    Header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = Main.Position
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            Main.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

local function openMenu()
    State.MenuOpen = true
    Main.Visible = true
    Reopen.Visible = false
    Dim.Visible = true

    if Config.Blur.Enabled then
        Blur.Size = Config.Blur.Size
    end

    tween(Main, TweenInfo.new(0.22, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
        Position = UDim2.fromScale(0.5, 0.5)
    }):Play()
end

local function closeMenu()
    State.MenuOpen = false
    Dim.Visible = false

    tween(Main, TweenInfo.new(0.18, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
        Position = UDim2.fromScale(0.5, 0.56)
    }):Play()

    task.delay(0.19, function()
        if not State.MenuOpen then
            Main.Visible = false
            Reopen.Visible = true
        end
    end)
end

local function toggleMenu()
    if State.MenuOpen then closeMenu() else openMenu() end
end

Close.Activated:Connect(toggleMenu)
Reopen.Activated:Connect(openMenu)

Close.MouseEnter:Connect(function()
    tween(Close, TweenInfo.new(0.12), {BackgroundColor3 = Config.Theme.Danger}):Play()
end)
Close.MouseLeave:Connect(function()
    tween(Close, TweenInfo.new(0.12), {BackgroundColor3 = Config.Theme.Background}):Play()
end)

UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Config.MenuKey then
        toggleMenu()
    end
end)

-- Update loop
local accumulator = 0

RunService.RenderStepped:Connect(function(dt)
    if State.Destroyed then return end

    updateWorldParticles()

    if Config.FX.Enabled then
        if Config.FX.VignetteEnabled then
            Vignette.BackgroundTransparency = 1 - math.clamp(Config.FX.VignetteIntensity,0,1)
        else
            Vignette.BackgroundTransparency = 1
        end

        if Config.FX.CameraNoise and Config.FX.CameraNoise > 0 then
            local cam = workspace.CurrentCamera
            if cam then
                local n = Config.FX.CameraNoise
                local t = os.clock() * (Config.FX.CameraNoiseSpeed or 8)
                cam.CFrame = cam.CFrame * CFrame.new(
                    math.noise(t,0,0)*n*0.01,
                    math.noise(0,t,0)*n*0.01,
                    0
                )
            end
        end
    end

    accumulator += dt
    if accumulator < Config.Performance.UpdateRate then return end
    accumulator = 0

    for model, data in pairs(State.ESPObjects) do
        if model and model.Parent then
            updateESP(model, data)
        else
            State.ESPObjects[model] = nil
        end
    end

    local target = State.SelectedTarget
    if target and Config.Target.Enabled then
        local character = target.Character
        local humanoid = getHumanoid(character)
        local distance = getDistance(character)

        if not character or not humanoid or humanoid.Health <= 0 then
            clearTarget()
        else
            local info = {}

            if Config.Target.ShowHealth then
                table.insert(info, "HP " .. getHealthText(humanoid))
            end
            if Config.Target.ShowDistance and distance then
                table.insert(info, string.format("%dm", math.floor(distance)))
            end
            if Config.Target.ShowTeam then
                table.insert(info, target.Team and target.Team.Name or T("teamNone"))
            end

            TargetInfo.Text = table.concat(info, "  •  ")
            HPFill.Size = UDim2.fromScale(math.clamp(humanoid.Health / math.max(humanoid.MaxHealth, 1), 0, 1), 1)
        end
    end
end)

-- Refresh NPC/item scans periodically.
task.spawn(function()
    while not State.Destroyed do
        scanNPCs()
        scanItems()
        task.wait(2)
    end
end)

refreshLanguage()
selectTab("Visual")
notify(T("ready"), 2)
