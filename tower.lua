local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
if not LocalPlayer then return end

local Settings = {
    GodmodeEnabled = false,
    JumpPowerEnabled = false,
    JumpPowerValue = 50,
    InfJumpEnabled = false,
    WalkSpeedEnabled = false,
    WalkSpeedValue = 16,
    GravityEnabled = false,
    GravityValue = 196.2,
    EspPlayers = false,
}

local espHighlights = {}

-- 1. Бессмертие (Godmode)
local function applyGodmode()
    task.spawn(function()
        while true do
            task.wait(1)
            if Settings.GodmodeEnabled then
                pcall(function()
                    for _, obj in ipairs(Workspace:GetDescendants()) do
                        if obj:IsA("BasePart") then
                            if obj.Name == "Kill" or obj.Name == "KillBrick" or obj.Name == "Hazard" then
                                obj.CanTouch = false
                                obj.CanQuery = false
                            end
                            for _, child in ipairs(obj:GetChildren()) do
                                if child:IsA("Script") or child:IsA("LocalScript") then
                                    local scriptName = child.Name:lower()
                                    if scriptName:find("kill") or scriptName:find("touch") or scriptName:find("damage") or scriptName:find("script") then
                                        child:Destroy()
                                    end
                                end
                            end
                        end
                    end
                end)
            end
        end
    end)
end
applyGodmode()

LocalPlayer.CharacterAdded:Connect(function(character)
    local humanoid = character:WaitForChild("Humanoid", 5)
    if humanoid then
        humanoid.HealthChanged:Connect(function(health)
            if Settings.GodmodeEnabled and health < humanoid.MaxHealth then
                humanoid.Health = humanoid.MaxHealth
            end
        end)
    end
end)

if LocalPlayer.Character then
    local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid.HealthChanged:Connect(function(health)
            if Settings.GodmodeEnabled and health < humanoid.MaxHealth then
                humanoid.Health = humanoid.MaxHealth
            end
        end)
    end
end

-- 2. Параметры персонажа
RunService.RenderStepped:Connect(function()
    local character = LocalPlayer.Character
    if not character then return end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    
    if humanoid then
        if Settings.JumpPowerEnabled then
            humanoid.UseJumpPower = true
            humanoid.JumpPower = Settings.JumpPowerValue
        else
            humanoid.JumpPower = 50
        end
        
        if Settings.WalkSpeedEnabled then
            humanoid.WalkSpeed = Settings.WalkSpeedValue
        else
            humanoid.WalkSpeed = 16
        end
    end
    
    if Settings.GravityEnabled then
        Workspace.Gravity = Settings.GravityValue
    else
        Workspace.Gravity = 196.2
    end
end)

UserInputService.JumpRequest:Connect(function()
    if Settings.InfJumpEnabled then
        local character = LocalPlayer.Character
        if character then
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
    end
end)

-- 3. Исправленный телепорт на финиш
local function teleportToFinish()
    local character = LocalPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    
    local rootPart = character.HumanoidRootPart
    local targetPart = nil
    local maxHeight = -math.huge
    
    -- Ищем финиш по названию или самую верхнюю крупную деталь
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") and not obj:IsDescendantOf(character) then
            -- Tower of Hell обычно имеет финишную зону (часто это куб/платформа на самом верху или деталь с именем Finish)
            if obj.Name:lower():find("finish") or obj.Name:lower():find("win") or obj.Name:lower():find("top") then
                targetPart = obj
                break
            end
            
            if obj.Position.Y > maxHeight and obj.Size.Y > 0.5 then
                maxHeight = obj.Position.Y
                targetPart = obj
            end
        end
    end
    
    if targetPart then
        rootPart.CFrame = targetPart.CFrame + Vector3.new(0, 5, 0)
    end
end

-- 4. ESP игроков
RunService.RenderStepped:Connect(function()
    for _, h in ipairs(espHighlights) do
        if h then h:Destroy() end
    end
    espHighlights = {}
    
    if Settings.EspPlayers then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local char = player.Character
                if not char:FindFirstChild("Set9pHighlight") then
                    local highlight = Instance.new("Highlight")
                    highlight.Name = "Set9pHighlight"
                    highlight.Adornee = char
                    highlight.FillColor = Color3.fromRGB(0, 170, 255)
                    highlight.OutlineColor = Color3.new(1, 1, 1)
                    highlight.FillTransparency = 0.5
                    highlight.Parent = char
                    table.insert(espHighlights, highlight)
                end
            end
        end
    end
end)

-- 5. Сканер магазина
local shopItemsTable = {}
local shopItemsInstances = {}
local shopItemsIcons = {}

local function scanShopItems()
    shopItemsTable = {}
    shopItemsInstances = {}
    shopItemsIcons = {}
    
    local searchLocations = {ReplicatedStorage, Workspace}
    
    for _, folder in ipairs(searchLocations) do
        for _, descendant in ipairs(folder:GetDescendants()) do
            if descendant:IsA("Tool") then
                if not shopItemsInstances[descendant.Name] then
                    shopItemsInstances[descendant.Name] = descendant
                    table.insert(shopItemsTable, descendant.Name)
                    
                    local iconId = 4483362458
                    if descendant:FindFirstChild("TextureId") and descendant.TextureId ~= "" then
                        iconId = descendant.TextureId
                    elseif descendant:FindFirstChild("Texture") and descendant.Texture ~= "" then
                        iconId = descendant.Texture
                    end
                    shopItemsIcons[descendant.Name] = iconId
                end
            end
        end
    end
    
    if #shopItemsTable == 0 then
        table.insert(shopItemsTable, "No items found")
        shopItemsIcons["No items found"] = 4483362458
    end
    
    return shopItemsTable
end

scanShopItems()

-- Загрузка Rayfield
local success, Rayfield = pcall(function()
    return loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
end)

if not success or not Rayfield then return end

local Window = Rayfield:CreateWindow({
    Name = "@set9p | Tower of Hell",
    LoadingTitle = "Loading Tower of Hell...",
    LoadingSubtitle = "by @set9p",
    ConfigurationSaving = { Enabled = false },
    Discord = { Enabled = false },
    KeySystem = false
})

local MainTab = Window:CreateTab("Main", 4483362458)
local VisualsTab = Window:CreateTab("Visuals", 4483362458)
local ShopTab = Window:CreateTab("Shop Giver", 4483362458)

-- Вкладка Главная
MainTab:CreateSection("Character Cheats")

MainTab:CreateToggle({
    Name = "Godmode",
    CurrentValue = false,
    Flag = "GodmodeToggle",
    Callback = function(value)
        Settings.GodmodeEnabled = value
        Rayfield:Notify({ Title = "Godmode", Content = value and "Enabled!" or "Disabled.", Duration = 2, Image = 4483362458 })
    end
})

MainTab:CreateToggle({
    Name = "Infinite Jump",
    CurrentValue = false,
    Flag = "InfJumpToggle",
    Callback = function(value)
        Settings.InfJumpEnabled = value
    end
})

MainTab:CreateToggle({
    Name = "Custom Jump Power",
    CurrentValue = false,
    Flag = "JumpPowerToggle",
    Callback = function(value)
        Settings.JumpPowerEnabled = value
    end
})

MainTab:CreateSlider({
    Name = "Jump Height Value",
    Range = {50, 200},
    Increment = 5,
    CurrentValue = 50,
    Flag = "JumpPowerSlider",
    Callback = function(value)
        Settings.JumpPowerValue = value
    end
})

MainTab:CreateToggle({
    Name = "Custom WalkSpeed",
    CurrentValue = false,
    Flag = "WalkSpeedToggle",
    Callback = function(value)
        Settings.WalkSpeedEnabled = value
    end
})

MainTab:CreateSlider({
    Name = "WalkSpeed Value",
    Range = {16, 150},
    Increment = 5,
    CurrentValue = 16,
    Flag = "WalkSpeedSlider",
    Callback = function(value)
        Settings.WalkSpeedValue = value
    end
})

MainTab:CreateToggle({
    Name = "Custom Gravity",
    CurrentValue = false,
    Flag = "GravityToggle",
    Callback = function(value)
        Settings.GravityEnabled = value
    end
})

MainTab:CreateSlider({
    Name = "Gravity Value",
    Range = {0, 196.2},
    Increment = 5,
    CurrentValue = 196.2,
    Flag = "GravitySlider",
    Callback = function(value)
        Settings.GravityValue = value
    end
})

MainTab:CreateSection("Teleports")

MainTab:CreateButton({
    Name = "Teleport to Finish",
    Callback = function()
        teleportToFinish()
        Rayfield:Notify({ Title = "Teleport", Content = "Teleported to the top!", Duration = 2, Image = 4483362458 })
    end
})

-- Вкладка Визуалов
VisualsTab:CreateSection("ESP Settings")

VisualsTab:CreateToggle({
    Name = "Players ESP",
    CurrentValue = false,
    Flag = "EspPlayersToggle",
    Callback = function(value)
        Settings.EspPlayers = value
    end
})

-- Вкладка Магазина
ShopTab:CreateSection("Shop Items Loader")

local selectedItemToGive = ""

local itemDropdown = ShopTab:CreateDropdown({
    Name = "Select Shop Item",
    Options = shopItemsTable,
    CurrentOption = shopItemsTable[1] or "",
    Flag = "ShopItemDropdown",
    Callback = function(option)
        if type(option) == "table" then
            selectedItemToGive = option[1]
        else
            selectedItemToGive = option
        end
    end,
})

ShopTab:CreateButton({
    Name = "Refresh Items List",
    Callback = function()
        local updatedList = scanShopItems()
        itemDropdown:Refresh(updatedList)
        Rayfield:Notify({ Title = "Shop Scanner", Content = "Items list refreshed!", Duration = 2, Image = 4483362458 })
    end
})

ShopTab:CreateButton({
    Name = "Give Selected Item to Inventory",
    Callback = function()
        if selectedItemToGive and shopItemsInstances[selectedItemToGive] then
            local itemClone = shopItemsInstances[selectedItemToGive]:Clone()
            local backpack = LocalPlayer:FindFirstChild("Backpack")
            local itemIcon = shopItemsIcons[selectedItemToGive] or 4483362458
            
            if backpack then
                itemClone.Parent = backpack
                Rayfield:Notify({ Title = "Item Received", Content = "Added " .. selectedItemToGive .. " to inventory!", Duration = 2, Image = itemIcon })
            end
        else
            Rayfield:Notify({ Title = "Error", Content = "Please select a valid item first!", Duration = 2, Image = 4483362458 })
        end
    end
})

Rayfield:Notify({
    Title = "@set9p",
    Content = "Menu successfully loaded!",
    Duration = 3,
    Image = 4483362458,
})