--[[
    NOVA PURPLE ULTIMATE
    Single-file Roblox UI library / demo
    Install as a LocalScript in StarterPlayer > StarterPlayerScripts.
    This is a functional recreation inspired by the concept mockup, not a pixel-perfect screenshot.
]]

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local NOVA = {}
NOVA.__index = NOVA

local C = {
    bg = Color3.fromRGB(8, 13, 31),
    panel = Color3.fromRGB(11, 18, 40),
    sidebar = Color3.fromRGB(7, 14, 32),
    card = Color3.fromRGB(13, 22, 47),
    card2 = Color3.fromRGB(18, 25, 55),
    accent = Color3.fromRGB(139, 61, 255),
    accent2 = Color3.fromRGB(177, 93, 255),
    text = Color3.fromRGB(244, 240, 255),
    muted = Color3.fromRGB(158, 166, 210),
    border = Color3.fromRGB(44, 52, 105),
    green = Color3.fromRGB(43, 221, 153),
}

local function create(class, props, parent)
    local obj = Instance.new(class)
    for k, v in pairs(props or {}) do
        obj[k] = v
    end
    obj.Parent = parent
    return obj
end

local function corner(parent, radius)
    return create("UICorner", {CornerRadius = UDim.new(0, radius or 10)}, parent)
end

local function stroke(parent, color, thickness, transparency)
    return create("UIStroke", {
        Color = color or C.border,
        Thickness = thickness or 1,
        Transparency = transparency or 0,
    }, parent)
end

local function pad(parent, l, r, t, b)
    return create("UIPadding", {
        PaddingLeft = UDim.new(0, l or 0),
        PaddingRight = UDim.new(0, r or 0),
        PaddingTop = UDim.new(0, t or 0),
        PaddingBottom = UDim.new(0, b or 0),
    }, parent)
end

local function tween(obj, props, duration, style)
    local tw = TweenService:Create(obj, TweenInfo.new(
        duration or 0.22,
        style or Enum.EasingStyle.Quint,
        Enum.EasingDirection.Out
    ), props)
    tw:Play()
    return tw
end

local function label(parent, text, size, color, font, props)
    local p = {
        BackgroundTransparency = 1,
        Text = text or "",
        TextSize = size or 13,
        TextColor3 = color or C.text,
        Font = font or Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
        BorderSizePixel = 0,
    }
    for k, v in pairs(props or {}) do p[k] = v end
    return create("TextLabel", p, parent)
end

local function button(parent, text, props)
    local p = {
        Text = text or "",
        TextSize = 12,
        TextColor3 = C.text,
        Font = Enum.Font.GothamMedium,
        BackgroundColor3 = C.card2,
        BorderSizePixel = 0,
        AutoButtonColor = false,
    }
    for k, v in pairs(props or {}) do p[k] = v end
    return create("TextButton", p, parent)
end

local screen = create("ScreenGui", {
    Name = "NovaPurpleUltimate",
    ResetOnSpawn = false,
    IgnoreGuiInset = true,
    DisplayOrder = 50,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
}, playerGui)

local root = create("Frame", {
    Name = "Window",
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.fromScale(0.5, 0.5),
    Size = UDim2.fromOffset(1160, 690),
    BackgroundColor3 = C.bg,
    BorderSizePixel = 0,
    ClipsDescendants = true,
}, screen)
corner(root, 16)
stroke(root, C.accent, 1.4, 0.12)

local rootScale = create("UIScale", {Scale = 1}, root)
local function updateScale()
    local cam = workspace.CurrentCamera
    if not cam then return end
    local v = cam.ViewportSize
    rootScale.Scale = math.clamp(math.min((v.X - 20) / 1160, (v.Y - 24) / 690), 0.38, 1)
end
updateScale()
if workspace.CurrentCamera then
    workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(updateScale)
end

-- Header
local header = create("Frame", {
    Size = UDim2.new(1, 0, 0, 96),
    BackgroundColor3 = C.panel,
    BorderSizePixel = 0,
}, root)
local headerGrad = create("UIGradient", {
    Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(17, 21, 50)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(8, 14, 32)),
    }),
    Rotation = 0,
}, header)

local logo = label(header, "N", 43, C.accent2, Enum.Font.GothamBlack, {
    Position = UDim2.fromOffset(23, 15),
    Size = UDim2.fromOffset(70, 65),
    TextXAlignment = Enum.TextXAlignment.Center,
})
local title = label(header, "NOVA PURPLE", 29, C.text, Enum.Font.GothamBlack, {
    Position = UDim2.fromOffset(105, 18),
    Size = UDim2.fromOffset(300, 35),
})
local purpleTitle = label(header, "PURPLE", 29, C.accent2, Enum.Font.GothamBlack, {
    Position = UDim2.fromOffset(251, 18),
    Size = UDim2.fromOffset(150, 35),
})
local subtitle = label(header, "Ultimate UI Library", 16, C.muted, Enum.Font.Gotham, {
    Position = UDim2.fromOffset(106, 53),
    Size = UDim2.fromOffset(260, 24),
})
local pill = create("Frame", {
    AnchorPoint = Vector2.new(1, 0.5),
    Position = UDim2.new(1, -54, 0.5, 0),
    Size = UDim2.fromOffset(270, 42),
    BackgroundColor3 = Color3.fromRGB(25, 26, 75),
    BorderSizePixel = 0,
}, header)
corner(pill, 22)
stroke(pill, C.border, 1, 0.2)
label(pill, "✦  Невероятная библиотека UI для Roblox", 11, C.muted, Enum.Font.GothamMedium, {
    Position = UDim2.fromOffset(13, 0),
    Size = UDim2.new(1, -20, 1, 0),
    TextXAlignment = Enum.TextXAlignment.Center,
})
local minimize = button(header, "−", {
    Position = UDim2.new(1, -90, 0, 4),
    Size = UDim2.fromOffset(28, 25),
    BackgroundTransparency = 1,
    TextSize = 23,
    TextColor3 = C.accent2,
})
local close = button(header, "×", {
    Position = UDim2.new(1, -54, 0, 4),
    Size = UDim2.fromOffset(28, 25),
    BackgroundTransparency = 1,
    TextSize = 23,
    TextColor3 = C.accent2,
})
create("Frame", {
    Position = UDim2.new(0, 0, 1, -1),
    Size = UDim2.new(1, 0, 0, 1),
    BackgroundColor3 = C.accent,
    BackgroundTransparency = 0.45,
    BorderSizePixel = 0,
}, header)

-- Main columns
local body = create("Frame", {
    Position = UDim2.fromOffset(0, 96),
    Size = UDim2.new(1, 0, 1, -96),
    BackgroundTransparency = 1,
}, root)

local sidebar = create("Frame", {
    Size = UDim2.new(0, 230, 1, 0),
    BackgroundColor3 = C.sidebar,
    BorderSizePixel = 0,
}, body)
create("Frame", {
    Position = UDim2.new(1, -1, 0, 0),
    Size = UDim2.new(0, 1, 1, 0),
    BackgroundColor3 = C.border,
    BorderSizePixel = 0,
}, sidebar)

local sideScroll = create("ScrollingFrame", {
    Position = UDim2.fromOffset(10, 12),
    Size = UDim2.new(1, -20, 1, -185),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    ScrollBarThickness = 2,
    ScrollBarImageColor3 = C.accent,
    CanvasSize = UDim2.new(),
    AutomaticCanvasSize = Enum.AutomaticSize.Y,
}, sidebar)
local sideLayout = create("UIListLayout", {
    Padding = UDim.new(0, 8),
    SortOrder = Enum.SortOrder.LayoutOrder,
}, sideScroll)

local brandCard = create("Frame", {
    AnchorPoint = Vector2.new(0.5, 1),
    Position = UDim2.new(0.5, 0, 1, -48),
    Size = UDim2.new(1, -36, 0, 145),
    BackgroundColor3 = Color3.fromRGB(18, 19, 63),
    BorderSizePixel = 0,
    ClipsDescendants = true,
}, sidebar)
corner(brandCard, 13)
stroke(brandCard, C.border, 1, 0.25)
create("UIGradient", {
    Color = ColorSequence.new(Color3.fromRGB(24, 19, 91), Color3.fromRGB(9, 14, 38)),
    Rotation = 35,
}, brandCard)
label(brandCard, "♛", 34, C.accent, Enum.Font.GothamBlack, {
    Position = UDim2.fromOffset(0, 10),
    Size = UDim2.new(1, 0, 0, 43),
    TextXAlignment = Enum.TextXAlignment.Center,
})
label(brandCard, "NOVA PURPLE", 16, C.accent2, Enum.Font.GothamBold, {
    Position = UDim2.fromOffset(0, 55),
    Size = UDim2.new(1, 0, 0, 24),
    TextXAlignment = Enum.TextXAlignment.Center,
})
label(brandCard, "Создано для твоего\nудовольствия", 12, C.text, Enum.Font.Gotham, {
    Position = UDim2.fromOffset(8, 82),
    Size = UDim2.new(1, -16, 0, 42),
    TextXAlignment = Enum.TextXAlignment.Center,
    TextWrapped = true,
})
label(sidebar, "v1.0.0", 11, C.muted, Enum.Font.Gotham, {
    Position = UDim2.new(0, 16, 1, -30),
    Size = UDim2.fromOffset(60, 20),
})
local statusDot = create("Frame", {
    Position = UDim2.new(0, 103, 1, -24),
    Size = UDim2.fromOffset(10, 10),
    BackgroundColor3 = C.accent,
    BorderSizePixel = 0,
}, sidebar)
corner(statusDot, 10)
label(sidebar, "Статус: Работает", 11, C.muted, Enum.Font.Gotham, {
    Position = UDim2.new(0, 120, 1, -30),
    Size = UDim2.fromOffset(100, 20),
})

local center = create("Frame", {
    Position = UDim2.fromOffset(230, 0),
    Size = UDim2.new(1, -230, 1, 0),
    BackgroundTransparency = 1,
}, body)

local contentScroll = create("ScrollingFrame", {
    Position = UDim2.fromOffset(14, 14),
    Size = UDim2.new(1, -28, 1, -28),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    ScrollBarThickness = 3,
    ScrollBarImageColor3 = C.accent,
    CanvasSize = UDim2.new(),
    AutomaticCanvasSize = Enum.AutomaticSize.Y,
}, center)

local contentGrid = create("UIGridLayout", {
    CellSize = UDim2.new(0.5, -9, 0, 470),
    CellPadding = UDim2.fromOffset(14, 14),
    SortOrder = Enum.SortOrder.LayoutOrder,
}, contentScroll)

local leftCol = create("Frame", {
    BackgroundTransparency = 1,
    Size = UDim2.new(1, 0, 0, 850),
    LayoutOrder = 1,
}, contentScroll)
local rightCol = create("Frame", {
    BackgroundTransparency = 1,
    Size = UDim2.new(1, 0, 0, 850),
    LayoutOrder = 2,
}, contentScroll)

local function makeCard(parent, titleText, descText, height)
    local card = create("Frame", {
        Size = UDim2.new(1, 0, 0, height),
        BackgroundColor3 = C.card,
        BorderSizePixel = 0,
        ClipsDescendants = true,
    }, parent)
    corner(card, 13)
    stroke(card, C.border, 1, 0.32)
    local icon = label(card, "✦", 23, C.accent2, Enum.Font.GothamBold, {
        Position = UDim2.fromOffset(14, 9),
        Size = UDim2.fromOffset(32, 32),
        TextXAlignment = Enum.TextXAlignment.Center,
    })
    local titleLbl = label(card, titleText, 15, C.text, Enum.Font.GothamBold, {
        Position = UDim2.fromOffset(54, 9),
        Size = UDim2.new(1, -65, 0, 24),
    })
    local desc = label(card, descText or "", 11, C.muted, Enum.Font.Gotham, {
        Position = UDim2.fromOffset(54, 31),
        Size = UDim2.new(1, -65, 0, 20),
    })
    return card
end

local function makeRow(parent, y, height, name, desc)
    local row = create("Frame", {
        Position = UDim2.fromOffset(12, y),
        Size = UDim2.new(1, -24, 0, height),
        BackgroundTransparency = 1,
    }, parent)
    label(row, name, 12, C.text, Enum.Font.GothamBold, {
        Position = UDim2.fromOffset(0, 2),
        Size = UDim2.new(1, -8, 0, 20),
    })
    if desc then
        label(row, desc, 11, C.muted, Enum.Font.Gotham, {
            Position = UDim2.fromOffset(0, 21),
            Size = UDim2.new(1, -8, 0, 18),
        })
    end
    return row
end

-- Welcome card and example components
local welcome = makeCard(leftCol, "Главная", "Добро пожаловать в NOVA PURPLE!", 66)
welcome.Position = UDim2.fromOffset(0, 0)
local elements = makeCard(leftCol, "Пример элементов", "Здесь показаны основные элементы интерфейса", 370)
elements.Position = UDim2.fromOffset(0, 78)

local toggleRow = makeRow(elements, 65, 47, "Переключатель", "Включи или выключи")
local toggleTrack = button(toggleRow, "", {
    AnchorPoint = Vector2.new(1, 0.5),
    Position = UDim2.new(1, 0, 0.5, 0),
    Size = UDim2.fromOffset(48, 27),
    BackgroundColor3 = C.accent,
})
corner(toggleTrack, 18)
local toggleKnob = create("Frame", {
    Position = UDim2.new(1, -23, 0, 4),
    Size = UDim2.fromOffset(19, 19),
    BackgroundColor3 = Color3.new(1, 1, 1),
    BorderSizePixel = 0,
}, toggleTrack)
corner(toggleKnob, 12)
local toggleState = true
toggleTrack.MouseButton1Click:Connect(function()
    toggleState = not toggleState
    tween(toggleTrack, {BackgroundColor3 = toggleState and C.accent or C.border}, 0.18)
    tween(toggleKnob, {Position = toggleState and UDim2.new(1, -23, 0, 4) or UDim2.fromOffset(4, 4)}, 0.18)
end)

local sliderRow = makeRow(elements, 116, 48, "Слайдер", "Настрой значение")
local sliderValue = label(sliderRow, "75%", 12, C.text, Enum.Font.GothamBold, {
    AnchorPoint = Vector2.new(1, 0.5),
    Position = UDim2.new(1, 0, 0.5, 0),
    Size = UDim2.fromOffset(34, 20),
    TextXAlignment = Enum.TextXAlignment.Right,
})
local sliderTrack = create("Frame", {
    AnchorPoint = Vector2.new(1, 0.5),
    Position = UDim2.new(1, -43, 0.5, 0),
    Size = UDim2.new(0.53, 0, 0, 7),
    BackgroundColor3 = C.border,
    BorderSizePixel = 0,
}, sliderRow)
corner(sliderTrack, 8)
local sliderFill = create("Frame", {
    Size = UDim2.new(0.75, 0, 1, 0),
    BackgroundColor3 = C.accent,
    BorderSizePixel = 0,
}, sliderTrack)
corner(sliderFill, 8)
local sliderDot = create("Frame", {
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.new(0.75, 0, 0.5, 0),
    Size = UDim2.fromOffset(14, 14),
    BackgroundColor3 = Color3.new(1, 1, 1),
    BorderSizePixel = 0,
}, sliderTrack)
corner(sliderDot, 8)
stroke(sliderDot, C.accent, 2)
local sliderDragging = false
local function setSlider(x)
    local alpha = math.clamp((x - sliderTrack.AbsolutePosition.X) / math.max(sliderTrack.AbsoluteSize.X, 1), 0, 1)
    tween(sliderFill, {Size = UDim2.new(alpha, 0, 1, 0)}, 0.06)
    tween(sliderDot, {Position = UDim2.new(alpha, 0, 0.5, 0)}, 0.06)
    sliderValue.Text = tostring(math.floor(alpha * 100 + 0.5)) .. "%"
end
sliderTrack.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        sliderDragging = true
        setSlider(input.Position.X)
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if sliderDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        setSlider(input.Position.X)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        sliderDragging = false
    end
end)

local dropdownRow = makeRow(elements, 169, 48, "Выпадающий список", "Выбери вариант")
local drop = button(dropdownRow, "Purple   ⌄", {
    AnchorPoint = Vector2.new(1, 0.5),
    Position = UDim2.new(1, 0, 0.5, 0),
    Size = UDim2.new(0.52, 0, 0, 35),
    BackgroundColor3 = C.panel,
    TextXAlignment = Enum.TextXAlignment.Left,
    TextColor3 = C.text,
})
corner(drop, 8)
stroke(drop, C.border, 1)
local dropdownOpen = false
local dropOptions = create("Frame", {
    Position = UDim2.new(0, 0, 1, 4),
    Size = UDim2.new(1, 0, 0, 0),
    BackgroundColor3 = C.panel,
    Visible = false,
    ClipsDescendants = true,
    ZIndex = 20,
}, drop)
corner(dropOptions, 8)
local dropLayout = create("UIListLayout", {Padding = UDim.new(0, 2)}, dropOptions)
for _, opt in ipairs({"Purple", "Blue", "Pink", "Green"}) do
    local b = button(dropOptions, opt, {
        Size = UDim2.new(1, -8, 0, 27),
        BackgroundColor3 = C.card2,
        BackgroundTransparency = 1,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 21,
    })
    b.MouseButton1Click:Connect(function()
        drop.Text = opt .. "   ⌄"
        dropdownOpen = false
        tween(dropOptions, {Size = UDim2.new(1, 0, 0, 0)}, 0.16)
        task.delay(0.16, function() if dropOptions.Parent then dropOptions.Visible = false end end)
    end)
end
drop.MouseButton1Click:Connect(function()
    dropdownOpen = not dropdownOpen
    dropOptions.Visible = dropdownOpen
    tween(dropOptions, {Size = UDim2.new(1, 0, 0, dropdownOpen and 118 or 0)}, 0.18)
end)

local textboxRow = makeRow(elements, 222, 48, "Текстовое поле", "Введи что-нибудь")
local textbox = create("TextBox", {
    AnchorPoint = Vector2.new(1, 0.5),
    Position = UDim2.new(1, 0, 0.5, 0),
    Size = UDim2.new(0.52, 0, 0, 35),
    BackgroundColor3 = C.panel,
    Text = "",
    PlaceholderText = "Например: Hello...",
    PlaceholderColor3 = C.muted,
    TextColor3 = C.text,
    TextSize = 11,
    Font = Enum.Font.Gotham,
    ClearTextOnFocus = false,
    TextXAlignment = Enum.TextXAlignment.Left,
}, textboxRow)
pad(textbox, 10, 8, 0, 0)
corner(textbox, 8)
stroke(textbox, C.border, 1)

local actionRow = makeRow(elements, 277, 65, "Кнопка", "Нажми меня")
local actionButton = button(actionRow, "Нажать", {
    AnchorPoint = Vector2.new(1, 0.5),
    Position = UDim2.new(1, 0, 0.5, 0),
    Size = UDim2.new(0.58, 0, 0, 42),
    BackgroundColor3 = C.accent,
    TextSize = 13,
})
corner(actionButton, 9)
create("UIGradient", {
    Color = ColorSequence.new(C.accent2, C.accent),
    Rotation = 0,
}, actionButton)

-- Extra functions card
local extras = makeCard(leftCol, "Дополнительные функции", "Полезные функции библиотеки", 260)
extras.Position = UDim2.fromOffset(0, 460)

local function extraRow(y, iconText, name, desc, callback)
    local r = button(extras, "", {
        Position = UDim2.fromOffset(12, y),
        Size = UDim2.new(1, -24, 0, 60),
        BackgroundColor3 = C.panel,
        BackgroundTransparency = 0.05,
        Text = "",
    })
    corner(r, 10)
    stroke(r, C.border, 1, 0.2)
    label(r, iconText, 20, C.accent2, Enum.Font.GothamBold, {
        Position = UDim2.fromOffset(10, 9),
        Size = UDim2.fromOffset(34, 40),
        TextXAlignment = Enum.TextXAlignment.Center,
    })
    label(r, name, 12, C.text, Enum.Font.GothamBold, {
        Position = UDim2.fromOffset(54, 8),
        Size = UDim2.new(1, -80, 0, 21),
    })
    label(r, desc, 10, C.muted, Enum.Font.Gotham, {
        Position = UDim2.fromOffset(54, 30),
        Size = UDim2.new(1, -80, 0, 20),
    })
    label(r, "›", 25, C.accent2, Enum.Font.Gotham, {
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -12, 0.5, 0),
        Size = UDim2.fromOffset(18, 30),
        TextXAlignment = Enum.TextXAlignment.Center,
    })
    r.MouseEnter:Connect(function() tween(r, {BackgroundColor3 = C.card2}, 0.15) end)
    r.MouseLeave:Connect(function() tween(r, {BackgroundColor3 = C.panel}, 0.15) end)
    r.MouseButton1Click:Connect(function() if callback then callback() end end)
end

-- Right column: palette, notifications, info
local palette = makeCard(rightCol, "Цветовая палитра", "Выбери свой любимый цвет", 310)
palette.Position = UDim2.fromOffset(0, 0)
local swatches = {
    Color3.fromRGB(139, 61, 255),
    Color3.fromRGB(219, 49, 211),
    Color3.fromRGB(53, 126, 255),
    Color3.fromRGB(0, 183, 214),
    Color3.fromRGB(39, 186, 126),
    Color3.fromRGB(255, 170, 28),
    Color3.fromRGB(255, 35, 79),
}
local selectedSwatch
local function applyAccent(color)
    C.accent = color
    C.accent2 = color:Lerp(Color3.new(1, 1, 1), 0.22)
    tween(root:FindFirstChildOfClass("UIStroke"), {Color = color}, 0.2)
    tween(logo, {TextColor3 = C.accent2}, 0.2)
    tween(purpleTitle, {TextColor3 = C.accent2}, 0.2)
    tween(statusDot, {BackgroundColor3 = color}, 0.2)
    tween(sliderFill, {BackgroundColor3 = color}, 0.2)
    tween(sliderDot:FindFirstChildOfClass("UIStroke"), {Color = color}, 0.2)
    tween(actionButton, {BackgroundColor3 = color}, 0.2)
    tween(drop, {TextColor3 = C.accent2}, 0.2)
    for _, obj in ipairs(screen:GetDescendants()) do
        if obj:IsA("UIStroke") and obj.Color ~= C.border then
            obj.Color = color
        elseif obj:IsA("Frame") and obj.Name == "AccentBar" then
            obj.BackgroundColor3 = color
        end
    end
end

for i, color in ipairs(swatches) do
    local sw = button(palette, "", {
        Position = UDim2.fromOffset(18 + (i - 1) * 48, 75),
        Size = UDim2.fromOffset(31, 31),
        BackgroundColor3 = color,
        Text = "",
    })
    corner(sw, 20)
    if i == 1 then
        selectedSwatch = stroke(sw, Color3.new(1, 1, 1), 2, 0)
    end
    sw.MouseButton1Click:Connect(function()
        if selectedSwatch then selectedSwatch:Destroy() end
        selectedSwatch = stroke(sw, Color3.new(1, 1, 1), 2, 0)
        applyAccent(color)
    end)
end

local colorPreview = create("Frame", {
    Position = UDim2.fromOffset(18, 126),
    Size = UDim2.new(1, -36, 0, 135),
    BackgroundColor3 = C.accent,
    BorderSizePixel = 0,
}, palette)
corner(colorPreview, 9)
create("UIGradient", {
    Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(236, 207, 255)),
        ColorSequenceKeypoint.new(0.45, C.accent),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(6, 9, 25)),
    }),
    Rotation = 90,
}, colorPreview)
local hueStrip = create("Frame", {
    AnchorPoint = Vector2.new(1, 0),
    Position = UDim2.new(1, -18, 0, 126),
    Size = UDim2.fromOffset(18, 135),
    BackgroundColor3 = Color3.new(1, 1, 1),
    BorderSizePixel = 0,
}, palette)
corner(hueStrip, 6)
create("UIGradient", {
    Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
        ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 255, 0)),
        ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
        ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 0, 255)),
        ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 0, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0)),
    }),
    Rotation = 90,
}, hueStrip)
local hexBox = create("TextBox", {
    Position = UDim2.fromOffset(18, 260),
    Size = UDim2.new(1, -36, 0, 34),
    BackgroundColor3 = C.panel,
    Text = "#8B3DFF",
    TextColor3 = C.text,
    PlaceholderText = "#RRGGBB",
    TextSize = 12,
    Font = Enum.Font.Gotham,
    ClearTextOnFocus = false,
}, palette)
pad(hexBox, 10, 8, 0, 0)
corner(hexBox, 8)
stroke(hexBox, C.border, 1)
hexBox.FocusLost:Connect(function()
    local raw = hexBox.Text:gsub("#", "")
    if #raw == 6 then
        local r, g, b = raw:sub(1,2), raw:sub(3,4), raw:sub(5,6)
        local ok, color = pcall(function()
            return Color3.fromRGB(tonumber(r, 16), tonumber(g, 16), tonumber(b, 16))
        end)
        if ok and color then
            applyAccent(color)
            colorPreview.BackgroundColor3 = color
        end
    end
end)

local notices = makeCard(rightCol, "Уведомления", "Красивые уведомления", 190)
notices.Position = UDim2.fromOffset(0, 325)
local toast = create("Frame", {
    Position = UDim2.fromOffset(14, 65),
    Size = UDim2.new(1, -28, 0, 62),
    BackgroundColor3 = Color3.fromRGB(34, 31, 91),
    BorderSizePixel = 0,
}, notices)
corner(toast, 10)
stroke(toast, C.accent, 1.2, 0)
label(toast, "✓", 21, C.accent2, Enum.Font.GothamBold, {
    Position = UDim2.fromOffset(10, 10),
    Size = UDim2.fromOffset(30, 40),
    TextXAlignment = Enum.TextXAlignment.Center,
})
label(toast, "Успешно!", 11, C.text, Enum.Font.GothamBold, {
    Position = UDim2.fromOffset(48, 8),
    Size = UDim2.new(1, -60, 0, 20),
})
label(toast, "Это пример уведомления.", 10, C.muted, Enum.Font.Gotham, {
    Position = UDim2.fromOffset(48, 28),
    Size = UDim2.new(1, -60, 0, 20),
})
local dismiss = button(toast, "×", {
    AnchorPoint = Vector2.new(1, 0),
    Position = UDim2.new(1, -8, 0, 5),
    Size = UDim2.fromOffset(18, 18),
    BackgroundTransparency = 1,
    TextColor3 = C.accent2,
    TextSize = 18,
})
dismiss.MouseButton1Click:Connect(function()
    tween(toast, {BackgroundTransparency = 1}, 0.2)
    task.delay(0.22, function() if toast.Parent then toast.Visible = false end end)
end)

local showNotice = button(notices, "♧   Показать уведомление", {
    Position = UDim2.fromOffset(14, 137),
    Size = UDim2.new(1, -28, 0, 35),
    BackgroundColor3 = C.panel,
    TextColor3 = C.accent2,
})
corner(showNotice, 8)
stroke(showNotice, C.accent, 1)
showNotice.MouseButton1Click:Connect(function()
    toast.Visible = true
    toast.BackgroundTransparency = 1
    tween(toast, {BackgroundTransparency = 0}, 0.2)
end)

local info = makeCard(rightCol, "Информация", "Полезная информация", 250)
info.Position = UDim2.fromOffset(0, 530)
local infoRows = {
    {"♧", "Название:", "NOVA PURPLE"},
    {"♙", "Версия:", "1.0.0"},
    {"♟", "Автор:", "NOVA TEAM"},
    {"✿", "Статус:", "● Работает"},
}
for i, row in ipairs(infoRows) do
    local y = 65 + (i - 1) * 31
    local line = create("Frame", {
        Position = UDim2.fromOffset(14, y),
        Size = UDim2.new(1, -28, 0, 29),
        BackgroundColor3 = C.panel,
        BackgroundTransparency = 0.25,
        BorderSizePixel = 0,
    }, info)
    corner(line, 5)
    label(line, row[1], 13, C.accent2, Enum.Font.GothamBold, {
        Position = UDim2.fromOffset(8, 0),
        Size = UDim2.fromOffset(20, 29),
        TextXAlignment = Enum.TextXAlignment.Center,
    })
    label(line, row[2], 11, C.muted, Enum.Font.Gotham, {
        Position = UDim2.fromOffset(34, 0),
        Size = UDim2.new(0.48, 0, 1, 0),
    })
    label(line, row[3], 10, i == 4 and C.green or C.text, Enum.Font.GothamMedium, {
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, -8, 0, 0),
        Size = UDim2.new(0.48, -8, 1, 0),
        TextXAlignment = Enum.TextXAlignment.Right,
    })
end
local bottomBanner = create("Frame", {
    Position = UDim2.fromOffset(14, 195),
    Size = UDim2.new(1, -28, 0, 43),
    BackgroundColor3 = Color3.fromRGB(38, 18, 105),
    BorderSizePixel = 0,
}, info)
corner(bottomBanner, 9)
create("UIGradient", {
    Color = ColorSequence.new(Color3.fromRGB(65, 30, 155), Color3.fromRGB(18, 19, 66)),
    Rotation = 0,
}, bottomBanner)
label(bottomBanner, "♛", 22, C.accent2, Enum.Font.GothamBold, {
    Position = UDim2.fromOffset(10, 0),
    Size = UDim2.fromOffset(32, 43),
    TextXAlignment = Enum.TextXAlignment.Center,
})
label(bottomBanner, "NOVA PURPLE", 11, C.text, Enum.Font.GothamBold, {
    Position = UDim2.fromOffset(49, 4),
    Size = UDim2.new(1, -58, 0, 17),
})
label(bottomBanner, "Лучший выбор для твоего скрипта!", 9, C.muted, Enum.Font.Gotham, {
    Position = UDim2.fromOffset(49, 21),
    Size = UDim2.new(1, -58, 0, 15),
})

-- Sidebar navigation items
local navItems = {
    {"⌂", "Главная"},
    {"♙", "Игрок"},
    {"◎", "Визуалы"},
    {"♧", "Телепорты"},
    {"⚙", "Настройки"},
    {"ⓘ", "Информация"},
}
local navButtons = {}
local currentNav = "Главная"

local function selectNav(name, b, indicator, iconLbl, textLbl)
    currentNav = name
    for _, item in ipairs(navButtons) do
        local active = item.name == name
        tween(item.button, {
            BackgroundColor3 = active and Color3.fromRGB(46, 25, 126) or C.sidebar,
            BackgroundTransparency = active and 0 or 1,
        }, 0.18)
        tween(item.indicator, {BackgroundTransparency = active and 0 or 1}, 0.18)
        tween(item.icon, {TextColor3 = active and C.accent2 or C.muted}, 0.18)
        tween(item.text, {TextColor3 = active and C.text or C.muted}, 0.18)
    end
    if name ~= "Главная" then
        -- Navigation is a demo: the central showcase remains visible.
        -- Update the header labels so each tab feels interactive.
        welcome:FindFirstChildWhichIsA("TextLabel").Text = name
        ContentTitle = nil
    end
end

for i, item in ipairs(navItems) do
    local nav = button(sideScroll, "", {
        Size = UDim2.new(1, 0, 0, 46),
        BackgroundColor3 = C.sidebar,
        BackgroundTransparency = 1,
        LayoutOrder = i,
        Text = "",
    })
    corner(nav, 22)
    local indicator = create("Frame", {
        Position = UDim2.fromOffset(0, 8),
        Size = UDim2.fromOffset(3, 30),
        BackgroundColor3 = C.accent2,
        BackgroundTransparency = i == 1 and 0 or 1,
        BorderSizePixel = 0,
    }, nav)
    corner(indicator, 4)
    local iconLbl = label(nav, item[1], 22, i == 1 and C.accent2 or C.muted, Enum.Font.GothamBold, {
        Position = UDim2.fromOffset(12, 0),
        Size = UDim2.fromOffset(32, 46),
        TextXAlignment = Enum.TextXAlignment.Center,
    })
    local textLbl = label(nav, item[2], 14, i == 1 and C.text or C.muted, Enum.Font.GothamMedium, {
        Position = UDim2.fromOffset(55, 0),
        Size = UDim2.new(1, -60, 1, 0),
    })
    local entry = {name = item[2], button = nav, indicator = indicator, icon = iconLbl, text = textLbl}
    table.insert(navButtons, entry)
    nav.MouseEnter:Connect(function()
        if currentNav ~= item[2] then tween(nav, {BackgroundTransparency = 0.65, BackgroundColor3 = C.card2}, 0.14) end
    end)
    nav.MouseLeave:Connect(function()
        if currentNav ~= item[2] then tween(nav, {BackgroundTransparency = 1}, 0.14) end
    end)
    nav.MouseButton1Click:Connect(function()
        selectNav(item[2])
        if item[2] == "Настройки" then
            -- Quick interaction: cycle accent color on settings selection.
            applyAccent(C.accent)
        elseif item[2] == "Информация" then
            -- Keep info panel in view on narrower layouts.
            contentScroll.CanvasPosition = Vector2.new(0, 380)
        elseif item[2] == "Главная" then
            contentScroll.CanvasPosition = Vector2.zero
        end
    end)
end

extraRow(65, "✦", "Сменить тему", "Выбери другую тему оформления", function()
    local idx = 1
    for i, color in ipairs(swatches) do
        if color == C.accent then idx = i end
    end
    idx = idx % #swatches + 1
    applyAccent(swatches[idx])
    colorPreview.BackgroundColor3 = swatches[idx]
end)
extraRow(135, "↶", "Сбросить настройки", "Вернуть значения по умолчанию", function()
    applyAccent(swatches[1])
    colorPreview.BackgroundColor3 = swatches[1]
    hexBox.Text = "#8B3DFF"
    toggleState = true
    tween(toggleTrack, {BackgroundColor3 = C.accent}, 0.18)
    tween(toggleKnob, {Position = UDim2.new(1, -23, 0, 4)}, 0.18)
    setSlider(sliderTrack.AbsolutePosition.X + sliderTrack.AbsoluteSize.X * 0.75)
end)
extraRow(205, "×", "Закрыть меню", "Скрыть интерфейс", function()
    root.Visible = false
end)

-- Drag window from header
local dragging, dragStart, startPos = false, nil, nil
header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = root.Position
    end
end)
header.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        root.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

local minimized = false
minimize.MouseButton1Click:Connect(function()
    minimized = not minimized
    body.Visible = not minimized
    tween(root, {Size = minimized and UDim2.fromOffset(1160, 96) or UDim2.fromOffset(1160, 690)}, 0.24)
    minimize.Text = minimized and "+" or "−"
end)
close.MouseButton1Click:Connect(function()
    tween(rootScale, {Scale = rootScale.Scale * 0.92}, 0.18)
    task.delay(0.19, function()
        if screen.Parent then screen:Destroy() end
    end)
end)
actionButton.MouseEnter:Connect(function()
    tween(actionButton, {BackgroundColor3 = C.accent2}, 0.15)
end)
actionButton.MouseLeave:Connect(function()
    tween(actionButton, {BackgroundColor3 = C.accent}, 0.15)
end)
actionButton.MouseButton1Click:Connect(function()
    local old = actionButton.Text
    actionButton.Text = "Готово!"
    task.delay(1, function()
        if actionButton.Parent then actionButton.Text = old end
    end)
end)

-- Keep initial geometry and scrollable columns tidy.
local function refreshCanvas()
    contentScroll.CanvasSize = UDim2.fromOffset(0, 880)
end
refreshCanvas()

-- Small entrance animation
rootScale.Scale = rootScale.Scale * 0.94
root.Position = UDim2.fromScale(0.5, 0.52)
tween(rootScale, {Scale = math.min(1, rootScale.Scale / 0.94)}, 0.4, Enum.EasingStyle.Back)
tween(root, {Position = UDim2.fromScale(0.5, 0.5)}, 0.4)

print("NOVA PURPLE ULTIMATE loaded.")
