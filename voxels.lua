local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera

local LocalPlayer = Players.LocalPlayer
if not LocalPlayer then return end

local Settings = {
    EspEnabled = false,
    HealthEspEnabled = false,
    MaxDistance = 500,
    KillauraEnabled = false,
    KillauraRange = 100,
    TargetPlayerName = "None",
    CustomZoomEnabled = false,
    MaxZoomDistance = 400,
    CustomFOV = 70,
}

local espObjects = {}
local targetDropdown = nil
local lastPlayerListSignature = ""

local function clearEsp()
    for _, obj in pairs(espObjects) do
        if obj then obj:Destroy() end
    end
    espObjects = {}
end

-- Функция обычного ESP
local function drawEspForPlayer(player, character, rootPart)
    local localCharacter = LocalPlayer.Character
    local localRoot = localCharacter and localCharacter:FindFirstChild("HumanoidRootPart")
    
    if localRoot then
        local distance = (localRoot.Position - rootPart.Position).Magnitude
        if distance > Settings.MaxDistance then return end
    end

    local highlight = Instance.new("Highlight")
    highlight.Name = "Set9p_Highlight"
    highlight.Adornee = character
    highlight.FillColor = Color3.fromRGB(255, 50, 50)
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.FillTransparency = 0.4
    highlight.OutlineTransparency = 0
    highlight.Parent = character
    table.insert(espObjects, highlight)
end

-- Функция Health ESP (цвет зависит от здоровья)
local function drawHealthEspForPlayer(player, character, rootPart, humanoid)
    local localCharacter = LocalPlayer.Character
    local localRoot = localCharacter and localCharacter:FindFirstChild("HumanoidRootPart")
    
    if localRoot then
        local distance = (localRoot.Position - rootPart.Position).Magnitude
        if distance > Settings.MaxDistance then return end
    end

    local healthPercent = math.clamp(humanoid.Health / humanoid.MaxHealth, 0, 1)
    local healthColor
    if healthPercent > 0.6 then
        healthColor = Color3.fromRGB(0, 255, 0)
    elseif healthPercent > 0.3 then
        healthColor = Color3.fromRGB(255, 165, 0)
    else
        healthColor = Color3.fromRGB(255, 0, 0)
    end

    local highlight = Instance.new("Highlight")
    highlight.Name = "Set9p_HealthHighlight"
    highlight.Adornee = character
    highlight.FillColor = healthColor
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.FillTransparency = 0.4
    highlight.OutlineTransparency = 0
    highlight.Parent = character
    table.insert(espObjects, highlight)
end

-- Функция обновления списка игроков в радиусе для Dropdown
local function updateNearbyPlayersDropdown()
    if not targetDropdown then return end

    local localCharacter = LocalPlayer.Character
    local localRoot = localCharacter and localCharacter:FindFirstChild("HumanoidRootPart")
    
    local availableNames = {"None"}
    
    if localRoot then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local targetChar = player.Character
                local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
                local humanoid = targetChar:FindFirstChildOfClass("Humanoid")

                if targetRoot and humanoid and humanoid.Health > 0 then
                    local distance = (localRoot.Position - targetRoot.Position).Magnitude
                    if distance <= Settings.KillauraRange then
                        table.insert(availableNames, player.Name)
                    end
                end
            end
        end
    end

    local signature = table.concat(availableNames, ",")
    if signature ~= lastPlayerListSignature then
        lastPlayerListSignature = signature
        targetDropdown:Refresh(availableNames)
        
        local found = false
        for _, name in ipairs(availableNames) do
            if name == Settings.TargetPlayerName then
                found = true
                break
            end
        end
        if not found and Settings.TargetPlayerName ~= "None" then
            Settings.TargetPlayerName = "None"
            targetDropdown:Set("None")
        end
    end
end

-- Основной игровой цикл
RunService.RenderStepped:Connect(function()
    clearEsp()

    -- Логика принудительного отдаления камеры (Zoom & FOV)
    if Settings.CustomZoomEnabled then
        LocalPlayer.CameraMaxZoomDistance = Settings.MaxZoomDistance
        LocalPlayer.CameraMinZoomDistance = 0.5
        Camera.FieldOfView = Settings.CustomFOV
    end

    -- Динамически обновляем список игроков в радиусе
    updateNearbyPlayersDropdown()

    -- Логика Киллауры
    if Settings.KillauraEnabled and Settings.TargetPlayerName ~= "None" then
        local localCharacter = LocalPlayer.Character
        local localRoot = localCharacter and localCharacter:FindFirstChild("HumanoidRootPart")
        
        if localRoot then
            local targetPlayer = Players:FindFirstChild(Settings.TargetPlayerName)
            if targetPlayer and targetPlayer.Character then
                local targetChar = targetPlayer.Character
                local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
                local humanoid = targetChar:FindFirstChildOfClass("Humanoid")

                if targetRoot and humanoid and humanoid.Health > 0 then
                    local distance = (localRoot.Position - targetRoot.Position).Magnitude
                    if distance <= Settings.KillauraRange then
                        -- 1. Моментальный snap камеры
                        local targetPosition = targetRoot.Position + Vector3.new(0, 1, 0)
                        Camera.CFrame = CFrame.new(Camera.CFrame.Position, targetPosition)

                        -- 2. Орбитальное движение вокруг цели
                        local timeTick = tick() * 12
                        local radius = 5
                        local offsetX = math.cos(timeTick) * radius
                        local offsetZ = math.sin(timeTick) * radius

                        local desiredPos = targetRoot.Position + Vector3.new(offsetX, 0, offsetZ)
                        localRoot.CFrame = CFrame.new(desiredPos, targetRoot.Position)
                    end
                end
            end
        end
    end

    -- Логика ESP
    if not Settings.EspEnabled and not Settings.HealthEspEnabled then return end

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local character = player.Character
            local rootPart = character:FindFirstChild("HumanoidRootPart")
            local humanoid = character:FindFirstChildOfClass("Humanoid")

            if rootPart and humanoid and humanoid.Health > 0 then
                if Settings.HealthEspEnabled then
                    drawHealthEspForPlayer(player, character, rootPart, humanoid)
                elseif Settings.EspEnabled then
                    drawEspForPlayer(player, character, rootPart)
                end
            end
        end
    end
end)

-- Загрузка интерфейса Rayfield
local success, Rayfield = pcall(function()
    return loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
end)

if not success or not Rayfield then return end

local Window = Rayfield:CreateWindow({
    Name = "@set9p | Menu",
    LoadingTitle = "Loading...",
    LoadingSubtitle = "by @set9p",
    ConfigurationSaving = { Enabled = false },
    Discord = { Enabled = false },
    KeySystem = false
})

-- Вкладка Визуализации
local VisualsTab = Window:CreateTab("Visuals", 4483362458)

VisualsTab:CreateToggle({
    Name = "Player ESP",
    CurrentValue = false,
    Flag = "EspToggle",
    Callback = function(value)
        Settings.EspEnabled = value
        if not value and not Settings.HealthEspEnabled then
            clearEsp()
        end
    end
})

VisualsTab:CreateToggle({
    Name = "Health ESP (Color HP)",
    CurrentValue = false,
    Flag = "HealthEspToggle",
    Callback = function(value)
        Settings.HealthEspEnabled = value
        if not value and not Settings.EspEnabled then
            clearEsp()
        end
    end
})

VisualsTab:CreateSlider({
    Name = "Max Distance",
    Range = {50, 1000},
    Increment = 10,
    CurrentValue = 500,
    Flag = "DistanceSlider",
    Callback = function(value)
        Settings.MaxDistance = value
    end
})

VisualsTab:CreateSection("Camera Customizer")

VisualsTab:CreateToggle({
    Name = "Enable Custom Zoom & FOV",
    CurrentValue = false,
    Flag = "CustomZoomToggle",
    Callback = function(value)
        Settings.CustomZoomEnabled = value
        if not value then
            LocalPlayer.CameraMaxZoomDistance = 400
            Camera.FieldOfView = 70
        end
    end
})

VisualsTab:CreateSlider({
    Name = "Max Zoom Distance",
    Range = {50, 2000},
    Increment = 25,
    CurrentValue = 400,
    Flag = "ZoomSlider",
    Callback = function(value)
        Settings.MaxZoomDistance = value
    end
})

VisualsTab:CreateSlider({
    Name = "Field of View (FOV)",
    Range = {50, 120},
    Increment = 1,
    CurrentValue = 70,
    Flag = "FovSlider",
    Callback = function(value)
        Settings.CustomFOV = value
    end
})

-- Вкладка Боевая (Combat)
local CombatTab = Window:CreateTab("Combat", 4483362458)

CombatTab:CreateSection("Target Selection (By Range)")

targetDropdown = CombatTab:CreateDropdown({
    Name = "Players in Range",
    Options = {"None"},
    CurrentOption = "None",
    Flag = "KillauraTargetDropdown",
    Callback = function(option)
        local chosenName = type(option) == "table" and option[1] or option
        Settings.TargetPlayerName = chosenName
    end
})

CombatTab:CreateToggle({
    Name = "Killaura (Lock Target & Orbit)",
    CurrentValue = false,
    Flag = "KillauraToggle",
    Callback = function(value)
        Settings.KillauraEnabled = value
        Rayfield:Notify({
            Title = "Killaura",
            Content = value and ("Locked Target: " .. Settings.TargetPlayerName) or "Deactivated.",
            Duration = 2,
            Image = 4483362458,
        })
    end
})

CombatTab:CreateSlider({
    Name = "Killaura Range",
    Range = {20, 200},
    Increment = 5,
    CurrentValue = 100,
    Flag = "KillauraRangeSlider",
    Callback = function(value)
        Settings.KillauraRange = value
    end
})

-- Вкладка Телепортации по игрокам
local PlayersTab = Window:CreateTab("Players", 4483362458)

PlayersTab:CreateSection("Server Players (Click to Teleport)")

local function teleportToPlayer(targetPlayer)
    local localCharacter = LocalPlayer.Character
    local targetCharacter = targetPlayer.Character
    
    if localCharacter and targetCharacter then
        local localRoot = localCharacter:FindFirstChild("HumanoidRootPart")
        local targetRoot = targetCharacter:FindFirstChild("HumanoidRootPart")
        
        if localRoot and targetRoot then
            -- Безопасный телепорт с обнулением физической скорости (чтобы не проваливаться сквозь текстуры)
            localRoot.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
            localRoot.CFrame = targetRoot.CFrame + Vector3.new(0, 3, 0)
            
            Rayfield:Notify({
                Title = "Teleport",
                Content = "Teleported to " .. targetPlayer.Name,
                Duration = 2,
                Image = 4483362458,
            })
        else
            Rayfield:Notify({
                Title = "Error",
                Content = "Target player is not spawned!",
                Duration = 2,
                Image = 4483362458,
            })
        end
    end
end

local playerButtons = {}

local function updatePlayerList()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            if not playerButtons[player] then
                playerButtons[player] = PlayersTab:CreateButton({
                    Name = player.Name,
                    Callback = function()
                        teleportToPlayer(player)
                    end
                })
            end
        end
    end
end

updatePlayerList()

Players.PlayerAdded:Connect(function(player)
    task.wait(1)
    updatePlayerList()
end)

Players.PlayerRemoving:Connect(function(player)
    playerButtons[player] = nil
end)

Rayfield:Notify({
    Title = "@set9p",
    Content = "Successfully loaded!",
    Duration = 2,
    Image = 4483362458,
})