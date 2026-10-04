-- // Сервисы
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local Camera = Workspace.CurrentCamera

local LocalPlayer = Players.LocalPlayer

-- // Загрузка интерфейса Rayfield Library
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- // Создание окна меню
local Window = Rayfield:CreateWindow({
    Name = "@set9p | Rooms / Survival ESP",
    LoadingTitle = "Загрузка скрипта...",
    LoadingSubtitle = "by @set9p",
    ConfigurationSaving = { Enabled = false },
    KeySystem = false,
})

-- // Вкладки
local MainTab = Window:CreateTab("ESP & Функции", 4483362458)
local TeleportTab = Window:CreateTab("Телепорт", 4483362458)
local SettingsTab = Window:CreateTab("Настройки", 4483362458)

-- // Настройки конфигурации и цветов
local Settings = {
    -- Включение ESP
    ESP_Monster = false,
    ESP_Key = false,
    ESP_CodeNote = false,
    ESP_Spawns = false,
    ESP_Stairs = false,
    ESP_Players = false,
    
    -- Общие параметры ESP
    ShowName = true,
    ShowDistance = true,
    
    -- Цвета ESP
    Color_Monster = Color3.fromRGB(255, 0, 0),
    Color_Key = Color3.fromRGB(255, 255, 0),
    Color_CodeNote = Color3.fromRGB(0, 255, 255),
    Color_Spawns = Color3.fromRGB(138, 43, 225),
    Color_Stairs = Color3.fromRGB(0, 255, 127),
    Color_Players = Color3.fromRGB(0, 150, 255),
    
    -- Функции игрока
    SpeedEnabled = false,
    WalkSpeedValue = 20,
    NoClipEnabled = false,
    FovEnabled = false,
    FovValue = 70,
    
    TeleportSide = "Спереди"
}

local Highlights = {}

-- // Универсальная функция создания ESP (Highlight + BillboardGui с текстом и дистанцией)
local function addESP(object, settingKey, colorKey, customLabelName)
    if not object or Highlights[object] then return end
    
    local targetPart = object:IsA("BasePart") and object or object:FindFirstChildWhichIsA("BasePart")
    if not targetPart and object:IsA("Model") then
        targetPart = object.PrimaryPart or object:FindFirstChildWhichIsA("BasePart", true)
    end
    
    if not targetPart then return end

    local highlight = Instance.new("Highlight")
    highlight.Adornee = object
    highlight.FillColor = Settings[colorKey]
    highlight.FillTransparency = 0.5
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.OutlineTransparency = 0
    highlight.Parent = Workspace
    
    local bill = Instance.new("BillboardGui")
    bill.Name = "CustomESP_Bill"
    bill.Size = UDim2.new(0, 120, 0, 50)
    bill.StudsOffset = Vector3.new(0, 2.5, 0)
    bill.AlwaysOnTop = true

    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.TextColor3 = Settings[colorKey]
    textLabel.TextScaled = true
    textLabel.Font = Enum.Font.SourceSansBold
    textLabel.TextStrokeTransparency = 0
    textLabel.Parent = bill

    bill.Adornee = targetPart
    bill.Parent = targetPart
    
    Highlights[object] = {
        Highlight = highlight,
        Billboard = bill,
        Text = textLabel,
        Key = settingKey,
        ColorKey = colorKey,
        LabelName = customLabelName or object.Name
    }
end

-- // Цикл обновления ESP
RunService.RenderStepped:Connect(function()
    local character = LocalPlayer.Character
    local rootPart = character and character:FindFirstChild("HumanoidRootPart")
    
    for obj, data in pairs(Highlights) do
        if not obj or not obj.Parent or not Settings[data.Key] then
            if data.Highlight then data.Highlight:Destroy() end
            if data.Billboard then data.Billboard:Destroy() end
            Highlights[obj] = nil
        else
            data.Highlight.Enabled = Settings[data.Key]
            data.Highlight.FillColor = Settings[data.ColorKey]
            data.Text.TextColor3 = Settings[data.ColorKey]
            data.Billboard.Enabled = Settings[data.Key]
            
            local part = obj:IsA("BasePart") and obj or obj:FindFirstChildWhichIsA("BasePart", true)
            if part and rootPart then
                local dist = math.floor((rootPart.Position - part.Position).Magnitude)
                local str = ""
                
                if Settings.ShowName then
                    str = "[" .. data.LabelName .. "]"
                end
                if Settings.ShowDistance then
                    if str ~= "" then str = str .. "\n" end
                    str = str .. dist .. "m"
                end
                
                data.Text.Text = str
            end
        end
    end
end)

-- // Сканирование окружения
local function scanEnvironment()
    for _, obj in ipairs(Workspace:GetDescendants()) do
        local name = obj.Name:lower()
        
        if name == "codenote" then
            addESP(obj, "ESP_CodeNote", "Color_CodeNote", "CodeNote")
        elseif name == "ver" or name == "placeholdermonster" then
            if obj:IsA("Model") then
                addESP(obj, "ESP_Monster", "Color_Monster", "Monster")
            end
        elseif name:find("key") or name == "hiddenkey3" or name == "keyprompt" then
            addESP(obj, "ESP_Key", "Color_Key", "Key")
        end

        if name:find("monsterclosetguards") or name:find("guard") or name:find("spawn") then
            if obj:IsA("BasePart") or obj:IsA("Model") then
                addESP(obj, "ESP_Spawns", "Color_Spawns", "Spawn")
            end
        elseif name:find("stair") or name:find("step") or name:find("ladder") then
            if obj:IsA("BasePart") or obj:IsA("Model") then
                addESP(obj, "ESP_Stairs", "Color_Stairs", "Stair")
            end
        end
    end
end

-- // Динамическое отслеживание
Workspace.DescendantAdded:Connect(function(obj)
    local name = obj.Name:lower()
    task.wait(0.1)
    if name == "codenote" then
        addESP(obj, "ESP_CodeNote", "Color_CodeNote", "CodeNote")
    elseif name:find("key") or name == "hiddenkey3" or name == "keyprompt" then
        addESP(obj, "ESP_Key", "Color_Key", "Key")
    end
end)

Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function(char)
        task.wait(1)
        addESP(char, "ESP_Players", "Color_Players", player.Name)
    end)
end)

for _, player in ipairs(Players:GetPlayers()) do
    if player ~= LocalPlayer and player.Character then
        addESP(player.Character, "ESP_Players", "Color_Players", player.Name)
    end
end

scanEnvironment()
task.spawn(function()
    while task.wait(0.8) do
        pcall(scanEnvironment)
    end
end)

-- // Функционал игрока
RunService.RenderStepped:Connect(function(dt)
    local character = LocalPlayer.Character
    if character then
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        
        if Settings.SpeedEnabled and humanoid and rootPart then
            if humanoid.MoveDirection.Magnitude > 0 then
                rootPart.CFrame = rootPart.CFrame + (humanoid.MoveDirection * Settings.WalkSpeedValue * dt)
            end
        end
        
        if Settings.NoClipEnabled then
            for _, part in ipairs(character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end
    
    if Settings.FovEnabled then
        Camera.FieldOfView = Settings.FovValue
    end
end)

-- // Функции Телепорта (без спавнов)
local function teleportToNearest(queryType, nameTag)
    local character = LocalPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    
    local rootPart = character.HumanoidRootPart
    local nearestPart = nil
    local shortestDistance = math.huge
    
    for _, obj in ipairs(Workspace:GetDescendants()) do
        local name = obj.Name:lower()
        local match = false
        
        if queryType == "key" and (name:find("key") or name == "hiddenkey3") then match = true end
        if queryType == "codenote" and name == "codenote" then match = true end
        if queryType == "stair" and (name:find("stair") or name:find("step") or name:find("ladder")) then match = true end
        
        if match then
            local part = obj:IsA("Model") and (obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart", true)) or (obj:IsA("BasePart") and obj)
            if part then
                local dist = (rootPart.Position - part.Position).Magnitude
                if dist < shortestDistance then
                    shortestDistance = dist
                    nearestPart = part
                end
            end
        end
    end
    
    if nearestPart then
        local targetCFrame = nearestPart.CFrame
        local offset = Vector3.new(0, 0, 0)
        
        if queryType == "key" then
            if Settings.TeleportSide == "Спереди" then offset = targetCFrame.LookVector * -3 + Vector3.new(0, 2, 0)
            elseif Settings.TeleportSide == "Сзади" then offset = targetCFrame.LookVector * 3 + Vector3.new(0, 2, 0)
            elseif Settings.TeleportSide == "Слева" then offset = targetCFrame.RightVector * -3 + Vector3.new(0, 2, 0)
            elseif Settings.TeleportSide == "Справа" then offset = targetCFrame.RightVector * 3 + Vector3.new(0, 2, 0) end
            character:SetPrimaryPartCFrame(CFrame.new(nearestPart.Position + offset, nearestPart.Position))
        else
            character:SetPrimaryPartCFrame(nearestPart.CFrame + Vector3.new(0, 3, 0))
        end
        
        Rayfield:Notify({Title = "Телепорт", Content = "Успешный телепорт к " .. nameTag .. "!", Duration = 3})
    else
        Rayfield:Notify({Title = "Телепорт", Content = nameTag .. " не найдены!", Duration = 3})
    end
end

-- // ИНТЕРФЕЙС RAYFIELD

MainTab:CreateToggle({ Name = "ESP Монстр", CurrentValue = false, Callback = function(Value) Settings.ESP_Monster = Value end })
MainTab:CreateColorPicker({ Name = "Цвет: Монстр", Color = Settings.Color_Monster, Callback = function(Value) Settings.Color_Monster = Value end })

MainTab:CreateToggle({ Name = "ESP Ключи", CurrentValue = false, Callback = function(Value) Settings.ESP_Key = Value end })
MainTab:CreateColorPicker({ Name = "Цвет: Ключи", Color = Settings.Color_Key, Callback = function(Value) Settings.Color_Key = Value end })

MainTab:CreateToggle({ Name = "ESP CodeNote (Записки)", CurrentValue = false, Callback = function(Value) Settings.ESP_CodeNote = Value end })
MainTab:CreateColorPicker({ Name = "Цвет: CodeNote", Color = Settings.Color_CodeNote, Callback = function(Value) Settings.Color_CodeNote = Value end })

MainTab:CreateToggle({ Name = "ESP Спавны", CurrentValue = false, Callback = function(Value) Settings.ESP_Spawns = Value end })
MainTab:CreateColorPicker({ Name = "Цвет: Спавны", Color = Settings.Color_Spawns, Callback = function(Value) Settings.Color_Spawns = Value end })

MainTab:CreateToggle({ Name = "ESP Лестницы", CurrentValue = false, Callback = function(Value) Settings.ESP_Stairs = Value end })
MainTab:CreateColorPicker({ Name = "Цвет: Лестницы", Color = Settings.Color_Stairs, Callback = function(Value) Settings.Color_Stairs = Value end })

MainTab:CreateToggle({ Name = "ESP Игроки", CurrentValue = false, Callback = function(Value) Settings.ESP_Players = Value end })
MainTab:CreateColorPicker({ Name = "Цвет: Игроки", Color = Settings.Color_Players, Callback = function(Value) Settings.Color_Players = Value end })

MainTab:CreateDivider()

MainTab:CreateToggle({ Name = "Показывать название в ESP", CurrentValue = true, Callback = function(Value) Settings.ShowName = Value end })
MainTab:CreateToggle({ Name = "Показывать дистанцию (метры)", CurrentValue = true, Callback = function(Value) Settings.ShowDistance = Value end })

TeleportTab:CreateDropdown({
    Name = "Сторона телепорта к ключу",
    Options = {"Спереди", "Сзади", "Слева", "Справа"},
    CurrentOption = "Спереди",
    Callback = function(Option) Settings.TeleportSide = Option[1] end,
})

TeleportTab:CreateButton({ Name = "ТП к ближайшему ключу", Callback = function() teleportToNearest("key", "ключу") end })
TeleportTab:CreateButton({ Name = "ТП к записке", Callback = function() teleportToNearest("codenote", "CodeNote") end })
TeleportTab:CreateButton({ Name = "ТП к лестнице", Callback = function() teleportToNearest("stair", "лестнице") end })

SettingsTab:CreateToggle({ Name = "Включить кастомную скорость", CurrentValue = false, Callback = function(Value) Settings.SpeedEnabled = Value end })
SettingsTab:CreateSlider({ Name = "Скорость движения", Range = {10, 500}, Increment = 5, Suffix = "скт", CurrentValue = 20, Callback = function(Value) Settings.WalkSpeedValue = Value end })
SettingsTab:CreateToggle({ Name = "Ноклип (Хождение сквозь стены)", CurrentValue = false, Callback = function(Value) Settings.NoClipEnabled = Value end })

SettingsTab:CreateDivider()

SettingsTab:CreateToggle({ Name = "Включить изменение FOV", CurrentValue = false, Callback = function(Value) Settings.FovEnabled = Value end })
SettingsTab:CreateSlider({ Name = "Значение FOV (Обзор)", Range = {30, 120}, Increment = 1, Suffix = "FOV", CurrentValue = 70, Callback = function(Value) Settings.FovValue = Value end })

Rayfield:LoadConfiguration()