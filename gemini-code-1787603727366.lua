-- ============================================
-- @set9p | SILENT AIM + AUTO TRIGGER + WALLCHECK + ESP (LinoriaLib)
-- ============================================

local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local SoundService = game:GetService("SoundService")
local Stats = game:GetService("Stats")
local Camera = workspace.CurrentCamera

local LocalPlayer = Players.LocalPlayer
if not LocalPlayer then return end

local CanHook = type(hookfunction) == "function" or hookfunction ~= nil

-- ============================
-- АНТИКИК (МЕТАМЕТОДЫ)
-- ============================
pcall(function()
    local oldIndex
    oldIndex = hookmetamethod(game, "__index", function(self, method)
        if self == LocalPlayer and typeof(method) == "string" and method:lower() == "kick" then
            return error("Expected ':' not '.' calling member function Kick", 2)
        end
        return oldIndex(self, method)
    end)

    local oldNamecall
    oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
        if self == LocalPlayer then
            local method = getnamecallmethod()
            if typeof(method) == "string" and method:lower() == "kick" then
                return
            end
        end
        return oldNamecall(self, ...)
    end)
end)

-- ============================
-- НАСТРОЙКИ
-- ============================
local Settings = {
    SilentAim = false,
    AimPart = "Head",
    AimFOV = 200,
    Aim360 = false,
    DrawFOV = false,
    
    AutoTrigger = false,
    VisibleCheck = true,
    WallCheck = true, -- Возвращенный WallCheck

    BulletTrailEnabled = false,
    BulletTrailColor = Color3.fromRGB(255, 0, 80),
    BulletTrailLifetime = 0.3,
    BulletTrailWidth = 0.2,
    BulletTrailCooldown = 0.3,

    TriggerSoundEnabled = false,
    TriggerSoundId = "140325083438865",
    TriggerSoundVolume = 1,
    TriggerSoundCooldown = 0.3,

    AntiAimDown = false,

    ESP = false,
    ESPBoxes = true,
    ESPNames = true,
    ESPDistance = true,
    ESPHealth = true,
    ESPLine = false,
    ESPLineOrigin = "Bottom",
    ESPFill = false,
    ESPFillTransparency = 0.5,
    ESPRGB = false,
    ESPRGBSpeed = 1
}

local espColor = Color3.fromRGB(255, 0, 80)
local target = nil
local shotFiredTime = 0
local lastSoundPlayTime = 0
local lastTrailPlayTime = 0
local ESPObjects = {}
local espHighlights = {}
local fovCircle = nil

-- HUD ИНФОРМЕР
local hudEnabled = false
local hudFPS = false
local hudSpeed = false
local hudPing = false
local cachedFPS = 0
local lastFPSTick = 0

local hudText = Drawing.new("Text")
hudText.Visible = false
hudText.Size = 16
hudText.Position = Vector2.new(15, 15)
hudText.Color = Color3.fromRGB(255, 255, 255)
hudText.Outline = true
hudText.Center = false

-- NIGHTMODE & WORLD COLOR
local nightModeEnabled = false
local nightBrightness = 0.5
local worldColorEnabled = false
local customWorldColor = Color3.fromRGB(150, 50, 255)
local activeAtmosphere = nil
local originalLightingProps = {
    Ambient = Lighting.Ambient,
    OutdoorAmbient = Lighting.OutdoorAmbient,
    ColorShift_Bottom = Lighting.ColorShift_Bottom,
    ColorShift_Top = Lighting.ColorShift_Top
}

-- MISC & BHOP & JUMP SPEED
local bhopEnabled = false
local spaceHeld = false
local jumpSpeedEnabled = true 
local TARGET_JUMP_SPEED = 25

local spinEnabled = false
local SPIN_SPEED = 25
local spinConnection = nil
local zoomEnabled = false
local DESIRED_ZOOM = 30
local zoomConnection = nil
local cameraFOV = 70

local wallCamEnabled = false
local targetPlayer = nil
local targetHumanoidDiedConnection = nil
local cameraRotationX = 0
local cameraRotationY = 0
local SKY_HEIGHT = 1000
local CAMERA_DISTANCE = 5
local MOUSE_SENSITIVITY = 0.5
local wallCamConnection = nil
local savedCFrame = nil

-- ============================
-- ВСПОМОГАТЕЛЬНЫЕ ФУНКЦИИ
-- ============================
local function playSound(id)
    local currentTime = tick()
    if currentTime - lastSoundPlayTime < Settings.TriggerSoundCooldown then
        return
    end
    lastSoundPlayTime = currentTime

    pcall(function()
        local sound = Instance.new("Sound")
        sound.SoundId = "rbxassetid://" .. tostring(id)
        sound.Volume = Settings.TriggerSoundVolume
        sound.Parent = SoundService
        sound:Play()
        sound.Ended:Connect(function()
            sound:Destroy()
        end)
    end)
end

local function playKillSound()
    pcall(function()
        local sound = Instance.new("Sound")
        sound.SoundId = "rbxassetid://6729922069"
        sound.Volume = 1
        sound.Parent = SoundService
        sound:Play()
        sound.Ended:Connect(function()
            sound:Destroy()
        end)
    end)
end

local function getRainbowColor()
    local hue = (tick() * Settings.ESPRGBSpeed) % 1
    return Color3.fromHSV(hue, 1, 1)
end

local function isVisible(targetPart)
    if not targetPart or typeof(targetPart) ~= "Instance" or targetPart.Parent == nil then return false end
    local cam = Workspace.CurrentCamera
    if not cam then return false end
    local char = LocalPlayer.Character
    if not char then return false end
    local origin = cam.CFrame

    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {char, targetPart.Parent}
    params.IgnoreWater = true

    if not targetPart:IsA("BasePart") then return false end

    local direction = (targetPart.Position - origin.Position)
    local result = Workspace:Raycast(origin.Position, direction, params)
    
    if not result then return true end
    
    local hitPart = result.Instance
    local model = hitPart:FindFirstAncestorOfClass("Model")
    if model and Players:GetPlayerFromCharacter(model) then
        return true
    end
    
    return false
end

local function isEnemy(player)
    if not player or player == LocalPlayer then return false end
    local Character = player.Character
    if not Character then return false end
    
    local hum = Character:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return false end

    if LocalPlayer.Team and player.Team then
        if player.Team == LocalPlayer.Team then
            return false
        end
    end
    return true
end

-- ============================
-- СОЗДАНИЕ ТРЕЙЛА ПУЛИ
-- ============================
local function createBulletTrail(originPos, hitPos)
    if not Settings.BulletTrailEnabled then return end
    
    local currentTime = tick()
    if currentTime - lastTrailPlayTime < Settings.BulletTrailCooldown then
        return
    end
    lastTrailPlayTime = currentTime

    pcall(function()
        local part = Instance.new("Part")
        part.Size = Vector3.new(0.1, 0.1, 0.1)
        part.Transparency = 1
        part.Anchored = true
        part.CanCollide = false
        part.CFrame = CFrame.new(originPos)
        part.Parent = Workspace

        local endPart = Instance.new("Part")
        endPart.Size = Vector3.new(0.1, 0.1, 0.1)
        endPart.Transparency = 1
        endPart.Anchored = true
        endPart.CanCollide = false
        endPart.CFrame = CFrame.new(hitPos)
        endPart.Parent = Workspace

        local att0 = Instance.new("Attachment", part)
        local att1 = Instance.new("Attachment", endPart)

        local beam = Instance.new("Beam")
        beam.Attachment0 = att0
        beam.Attachment1 = att1
        beam.Color = ColorSequence.new(Settings.BulletTrailColor)
        beam.Width0 = Settings.BulletTrailWidth
        beam.Width1 = Settings.BulletTrailWidth
        beam.Transparency = NumberSequence.new(0)
        beam.FaceCamera = true
        beam.Parent = part

        task.delay(Settings.BulletTrailLifetime, function()
            pcall(function()
                part:Destroy()
                endPart:Destroy()
            end)
        end)
    end)
end

-- ============================
-- SILENT AIM & AUTO TRIGGER
-- ============================
local function GetClosestPlayer()
    local closestDistance = math.huge
    local closest = nil
    local camera = Workspace.CurrentCamera
    local center = camera.ViewportSize / 2
    local plrs = Players:GetPlayers()
    local myChar = LocalPlayer.Character
    local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")

    for _, v in pairs(plrs) do
        if not isEnemy(v) then continue end
        local char = v.Character
        if not char then continue end
        
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp or not hrp:IsA("BasePart") then continue end

        local targetHitPart = nil
        if Settings.AimPart == "Head" then
            targetHitPart = char:FindFirstChild("Head") or hrp
        else
            targetHitPart = char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso") or hrp
        end

        if not targetHitPart or not targetHitPart:IsA("BasePart") then continue end

        if Settings.VisibleCheck and not isVisible(targetHitPart) then continue end

        -- Проверка прострела стен (WallCheck)
        if not Settings.WallCheck then
            -- Если WallCheck выключен, цель обязана быть видимой
            if not isVisible(targetHitPart) then continue end
        end

        if Settings.Aim360 then
            if myHRP then
                local worldDist = (hrp.Position - myHRP.Position).Magnitude
                if worldDist < closestDistance then
                    closestDistance = worldDist
                    closest = targetHitPart
                end
            end
        else
            local screenPos, onScreen = camera:WorldToViewportPoint(hrp.Position)
            if onScreen then
                local distance = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
                if distance <= Settings.AimFOV and distance < closestDistance then
                    closestDistance = distance
                    closest = targetHitPart
                end
            end
        end
    end
    return closest
end

local lockedTarget = nil
local isTriggerActive = false

RunService.RenderStepped:Connect(function()
    if not Settings.SilentAim and not Settings.AutoTrigger then
        target = nil
        lockedTarget = nil
        return
    end

    if lockedTarget and lockedTarget.Parent then
        local char = lockedTarget.Parent
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum or hum.Health <= 0 or (Settings.VisibleCheck and not isVisible(lockedTarget)) then
            lockedTarget = nil
        end
    else
        lockedTarget = nil
    end

    if not lockedTarget then
        lockedTarget = GetClosestPlayer()
    end

    target = lockedTarget

    if Settings.AutoTrigger and target and not isTriggerActive then
        isTriggerActive = true
        task.spawn(function()
            pcall(function()
                mouse1press()
                if Settings.TriggerSoundEnabled then
                    playSound(Settings.TriggerSoundId)
                end
                task.wait(0.03)
                mouse1release()
            end)
            task.wait(0.05)
            isTriggerActive = false
        end)
    end
end)

local old
if CanHook then
    pcall(function()
        old = hookfunction(Ray.new, newcclosure(function(origin, direction)
            local trace = debug.traceback()
            
            if trace:find("Client") and not trace:find("10420") and not trace:find("10595") then
                if Settings.SilentAim and target and target:IsA("BasePart") then
                    shotFiredTime = tick()
                    local realOrigin = origin
                    local targetPos = target.Position
                    direction = targetPos - realOrigin
                    createBulletTrail(realOrigin, targetPos)
                    if Settings.TriggerSoundEnabled then
                        playSound(Settings.TriggerSoundId)
                    end
                end
            end
            
            return old(origin, direction)
        end))
    end)
end

-- ============================
-- FOV КРУГ
-- ============================
local function createFOVCircle()
    if fovCircle then pcall(function() fovCircle:Remove() end) fovCircle = nil end
    if Drawing and Drawing.new then
        fovCircle = Drawing.new("Circle")
        fovCircle.Thickness = 2
        fovCircle.Filled = false
        fovCircle.Transparency = 1
        fovCircle.Visible = true
    end
end

RunService.RenderStepped:Connect(function()
    local activeColor = Settings.ESPRGB and getRainbowColor() or espColor
    if Settings.DrawFOV and not Settings.Aim360 then
        if not fovCircle then createFOVCircle() end
        if fovCircle then
            local center = Camera.ViewportSize / 2
            fovCircle.Position = Vector2.new(center.X, center.Y)
            fovCircle.Radius = Settings.AimFOV
            fovCircle.Color = activeColor
            fovCircle.Visible = true
        end
    elseif fovCircle then
        fovCircle.Visible = false
    end
end)

-- ============================
-- ОБРАБОТЧИК ПЕРСОНАЖА (СКОРОСТЬ ПРЫЖКА)
-- ============================
local function applyCharacterFeatures(character)
    local humanoid = character:WaitForChild("Humanoid", 5)
    local hrp = character:WaitForChild("HumanoidRootPart", 5)
    
    if humanoid and hrp then
        humanoid.StateChanged:Connect(function(oldState, newState)
            if jumpSpeedEnabled and newState == Enum.HumanoidStateType.Jumping then
                local currentVelocity = hrp.AssemblyLinearVelocity
                local moveDir = Vector3.new(currentVelocity.X, 0, currentVelocity.Z)
                
                if moveDir.Magnitude > 0 then
                    moveDir = moveDir.Unit * TARGET_JUMP_SPEED
                else
                    moveDir = hrp.CFrame.LookVector * TARGET_JUMP_SPEED
                end
                
                hrp.AssemblyLinearVelocity = Vector3.new(moveDir.X, currentVelocity.Y, moveDir.Z)
            end
        end)
    end
end

if LocalPlayer.Character then
    applyCharacterFeatures(LocalPlayer.Character)
end
LocalPlayer.CharacterAdded:Connect(applyCharacterFeatures)

-- ============================
-- ОБНОВЛЕНИЕ СПИНА (КРУТИЛКИ)
-- ============================
local function updateSpin()
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then return end

    if spinEnabled then
        hum.AutoRotate = false
        if not spinConnection then
            spinConnection = RunService.RenderStepped:Connect(function()
                local c = LocalPlayer.Character
                if not c then return end
                local root = c:FindFirstChild("HumanoidRootPart")
                local h = c:FindFirstChildOfClass("Humanoid")
                if root and h then
                    h.AutoRotate = false
                    root.CFrame = root.CFrame * CFrame.Angles(0, math.rad(SPIN_SPEED), 0)
                end
            end)
        end
    else
        if spinConnection then
            spinConnection:Disconnect()
            spinConnection = nil
        end
        hum.AutoRotate = true
    end
end

LocalPlayer.CharacterAdded:Connect(function(newChar)
    task.wait(0.5)
    if spinEnabled then updateSpin() end
end)

-- ============================
-- ОТСЛЕЖИВАНИЕ УБИЙСТВ
-- ============================
local function monitorPlayer(player)
    if player == LocalPlayer then return end
    local function setupChar(char)
        local hum = char:WaitForChild("Humanoid", 5)
        if hum then
            hum.Died:Connect(function()
                if tick() - shotFiredTime < 1.5 then
                    playKillSound()
                end
            end)
        end
    end
    player.CharacterAdded:Connect(setupChar)
    if player.Character then setupChar(player.Character) end
end
for _, p in ipairs(Players:GetPlayers()) do monitorPlayer(p) end
Players.PlayerAdded:Connect(monitorPlayer)

-- ============================
-- ESP СИСТЕМА
-- ============================
local function RemoveESP(player)
    local data = ESPObjects[player]
    if data then
        for _, v in pairs(data) do
            pcall(function() v:Remove() end)
        end
        ESPObjects[player] = nil
    end
    if espHighlights[player] then
        pcall(function() espHighlights[player]:Destroy() end)
        espHighlights[player] = nil
    end
end

local function CreateESP(player)
    if ESPObjects[player] then return end
    local box = Drawing.new("Square")
    box.Thickness = 1
    box.Filled = false
    box.Visible = false
    box.ZIndex = 2

    local outline = Drawing.new("Square")
    outline.Thickness = 2
    outline.Filled = false
    outline.Color = Color3.new(0, 0, 0)
    outline.Visible = false
    outline.ZIndex = 1

    local name = Drawing.new("Text")
    name.Size = 13
    name.Center = true
    name.Outline = true
    name.Color = Color3.fromRGB(255, 255, 255)
    name.Visible = false

    local dist = Drawing.new("Text")
    dist.Size = 12
    dist.Center = true
    dist.Outline = true
    dist.Color = Color3.fromRGB(200, 200, 200)
    dist.Visible = false

    local hbBg = Drawing.new("Square")
    hbBg.Thickness = 1
    hbBg.Filled = true
    hbBg.Color = Color3.fromRGB(0, 0, 0)
    hbBg.Transparency = 0.7
    hbBg.Visible = false

    local hb = Drawing.new("Square")
    hb.Thickness = 1
    hb.Filled = true
    hb.Visible = false

    local line = Drawing.new("Line")
    line.Thickness = 1
    line.Visible = false

    ESPObjects[player] = {Box = box, Outline = outline, Name = name, Dist = dist, HealthBarBg = hbBg, HealthBar = hb, Line = line}
end

local function UpdateESP()
    local activeColor = Settings.ESPRGB and getRainbowColor() or espColor
    local myChar = LocalPlayer.Character
    local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
    local viewportSize = Camera.ViewportSize

    for player, data in pairs(ESPObjects) do
        local char = player.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")

        if not Settings.ESP or not char or not isEnemy(player) or not hum or hum.Health <= 0 then
            data.Box.Visible = false
            data.Outline.Visible = false
            data.Name.Visible = false
            data.Dist.Visible = false
            data.HealthBarBg.Visible = false
            data.HealthBar.Visible = false
            data.Line.Visible = false
            if espHighlights[player] then espHighlights[player]:Destroy() espHighlights[player] = nil end
            continue
        end

        if Settings.ESPFill then
            if not espHighlights[player] or espHighlights[player].Parent ~= char then
                if espHighlights[player] then espHighlights[player]:Destroy() end
                local h = Instance.new("Highlight")
                h.Parent = char
                h.FillColor = activeColor
                h.OutlineColor = Color3.new(1, 1, 1)
                h.FillTransparency = Settings.ESPFillTransparency
                espHighlights[player] = h
            else
                espHighlights[player].FillColor = activeColor
                espHighlights[player].FillTransparency = Settings.ESPFillTransparency
            end
        else
            if espHighlights[player] then espHighlights[player]:Destroy() espHighlights[player] = nil end
        end

        local hrp = char:FindFirstChild("HumanoidRootPart")
        local head = char:FindFirstChild("Head")
        if not hrp or not head then continue end

        local vector, onScreen = Camera:WorldToViewportPoint(hrp.Position)
        if not onScreen then
            data.Box.Visible = false
            data.Outline.Visible = false
            data.Name.Visible = false
            data.Dist.Visible = false
            data.HealthBarBg.Visible = false
            data.HealthBar.Visible = false
            data.Line.Visible = false
            continue
        end

        local headPos = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
        local legPos = Camera:WorldToViewportPoint(hrp.Position - Vector3.new(0, 3, 0))

        local height = math.abs(headPos.Y - legPos.Y)
        local width = height / 2
        local boxPos = Vector2.new(vector.X - width / 2, headPos.Y)

        if Settings.ESPBoxes then
            data.Box.Size = Vector2.new(width, height)
            data.Box.Position = boxPos
            data.Box.Color = activeColor
            data.Box.Visible = true
            data.Outline.Size = data.Box.Size
            data.Outline.Position = data.Box.Position
            data.Outline.Visible = true
        else
            data.Box.Visible = false
            data.Outline.Visible = false
        end

        if Settings.ESPHealth then
            data.HealthBarBg.Visible = true
            data.HealthBarBg.Size = Vector2.new(3, height + 2)
            data.HealthBarBg.Position = Vector2.new(boxPos.X - 6, boxPos.Y - 1)

            local healthPercent = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
            local hbHeight = height * healthPercent
            data.HealthBar.Visible = true
            data.HealthBar.Size = Vector2.new(1, hbHeight)
            data.HealthBar.Position = Vector2.new(boxPos.X - 5, boxPos.Y + (height - hbHeight))
            data.HealthBar.Color = Color3.fromHSV(healthPercent * 0.3, 1, 1)
        else
            data.HealthBarBg.Visible = false
            data.HealthBar.Visible = false
        end

        if Settings.ESPNames then
            data.Name.Text = player.DisplayName or player.Name
            data.Name.Position = Vector2.new(vector.X, boxPos.Y - 16)
            data.Name.Visible = true
        else
            data.Name.Visible = false
        end

        if Settings.ESPDistance and myHRP then
            local distance = math.floor((hrp.Position - myHRP.Position).Magnitude)
            data.Dist.Text = distance .. "m"
            data.Dist.Position = Vector2.new(vector.X, boxPos.Y + height + 4)
            data.Dist.Visible = true
        else
            data.Dist.Visible = false
        end

        if Settings.ESPLine then
            data.Line.Visible = true
            data.Line.Color = activeColor
            local originPos = Vector2.new(viewportSize.X / 2, viewportSize.Y)
            if Settings.ESPLineOrigin == "Center" then
                originPos = viewportSize / 2
            elseif Settings.ESPLineOrigin == "Top" then
                originPos = Vector2.new(viewportSize.X / 2, 0)
            end
            data.Line.From = originPos
            data.Line.To = Vector2.new(vector.X, boxPos.Y + height / 2)
        else
            data.Line.Visible = false
        end
    end
end

Players.PlayerAdded:Connect(CreateESP)
Players.PlayerRemoving:Connect(RemoveESP)
for _, p in pairs(Players:GetPlayers()) do
    if p ~= LocalPlayer then CreateESP(p) end
end
RunService.RenderStepped:Connect(UpdateESP)

-- ============================
-- HUD ИНФОРМЕР
-- ============================
RunService.RenderStepped:Connect(function()
    if not hudEnabled or not (hudFPS or hudSpeed or hudPing) then
        hudText.Visible = false
        return
    end

    local infoLines = {}
    if hudFPS then
        local currentTime = tick()
        if currentTime - lastFPSTick >= 0.5 then
            cachedFPS = math.round(1 / RunService.RenderStepped:Wait())
            lastFPSTick = currentTime
        end
        table.insert(infoLines, "FPS: " .. cachedFPS)
    end

    if hudSpeed and LocalPlayer.Character then
        local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            local speed = math.round(Vector3.new(hrp.AssemblyLinearVelocity.X, 0, hrp.AssemblyLinearVelocity.Z).Magnitude)
            table.insert(infoLines, "Speed: " .. speed)
        end
    end

    if hudPing then
        local ping = 0
        pcall(function()
            ping = math.round(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
        end)
        table.insert(infoLines, "MS: " .. ping .. "ms")
    end

    if #infoLines > 0 then
        hudText.Visible = true
        hudText.Text = table.concat(infoLines, " | ")
    else
        hudText.Visible = false
    end
end)

-- ============================
-- WORLD COLOR & NIGHTMODE
-- ============================
local function updateWorldColor()
    if worldColorEnabled then
        Lighting.Ambient = customWorldColor
        Lighting.OutdoorAmbient = customWorldColor
        Lighting.ColorShift_Bottom = customWorldColor
        Lighting.ColorShift_Top = customWorldColor
        if not activeAtmosphere then
            activeAtmosphere = Instance.new("Atmosphere")
            activeAtmosphere.Parent = Lighting
        end
        activeAtmosphere.Color = customWorldColor
        activeAtmosphere.Haze = 2
        activeAtmosphere.Density = 0.3
    else
        Lighting.Ambient = originalLightingProps.Ambient
        Lighting.OutdoorAmbient = originalLightingProps.OutdoorAmbient
        Lighting.ColorShift_Bottom = originalLightingProps.ColorShift_Bottom
        Lighting.ColorShift_Top = originalLightingProps.ColorShift_Top
        if activeAtmosphere then
            activeAtmosphere:Destroy()
            activeAtmosphere = nil
        end
    end
end

RunService.RenderStepped:Connect(function()
    if nightModeEnabled then
        Lighting.Brightness = nightBrightness
        Lighting.ClockTime = 0
        Lighting.FogEnd = 999999
    elseif not worldColorEnabled then
        Lighting.Brightness = 2
        Lighting.ClockTime = 14
        Lighting.FogEnd = 100000
    end
end)

-- ============================
-- BHOP + МИСК
-- ============================
UIS.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.Space then spaceHeld = true end
end)
UIS.InputEnded:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.Space then spaceHeld = false end
end)

task.spawn(function()
    while true do
        task.wait()
        if bhopEnabled and spaceHeld then
            local char = LocalPlayer.Character
            if char then
                local humanoid = char:FindFirstChildOfClass("Humanoid")
                if humanoid and humanoid.Health > 0 then
                    if humanoid.FloorMaterial ~= Enum.Material.Air then
                        humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                    end
                end
            end
        end
    end
end)

local function updateZoom()
    if zoomEnabled then
        LocalPlayer.CameraMode = Enum.CameraMode.Classic
        LocalPlayer.CameraMinZoomDistance = DESIRED_ZOOM
        LocalPlayer.CameraMaxZoomDistance = DESIRED_ZOOM
        if not zoomConnection then
            zoomConnection = RunService.RenderStepped:Connect(function()
                if zoomEnabled then
                    LocalPlayer.CameraMode = Enum.CameraMode.Classic
                    LocalPlayer.CameraMinZoomDistance = DESIRED_ZOOM
                    LocalPlayer.CameraMaxZoomDistance = DESIRED_ZOOM
                end
            end)
        end
    else
        if zoomConnection then
            zoomConnection:Disconnect()
            zoomConnection = nil
        end
        LocalPlayer.CameraMinZoomDistance = 0.5
        LocalPlayer.CameraMaxZoomDistance = 400
    end
end

RunService.RenderStepped:Connect(function()
    if cameraFOV then
        Camera.FieldOfView = cameraFOV
    end

    local char = LocalPlayer.Character
    if char then
        local torso = char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso")
        local head = char:FindFirstChild("Head")
        
        if zoomEnabled and Settings.AntiAimDown then
            if torso then
                local waist = torso:FindFirstChild("Waist") or char:FindFirstChild("HumanoidRootPart"):FindFirstChild("RootJoint")
                if waist and waist:IsA("Motor6D") then
                    if not waist.Part0 then return end
                    waist.C0 = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(80), 0, 0)
                end
            end
            if head then
                local neck = head:FindFirstChild("Neck")
                if neck and neck:IsA("Motor6D") then
                    neck.C0 = CFrame.new(0, 1, 0) * CFrame.Angles(math.rad(30), 0, 0)
                end
            end
        else
            if torso then
                local waist = torso:FindFirstChild("Waist")
                if waist and waist:IsA("Motor6D") then
                    waist.C0 = CFrame.new(0, 0, 0) * CFrame.Angles(0, 0, 0)
                end
            end
            if head then
                local neck = head:FindFirstChild("Neck")
                if neck and neck:IsA("Motor6D") then
                    neck.C0 = CFrame.new(0, 1, 0) * CFrame.Angles(0, 0, 0)
                end
            end
        end
    end
end)

-- ============================
-- WALLCAM
-- ============================
local function getAllPlayers()
    local players = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if isEnemy(p) then
            local char = p.Character
            if char then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum and hum.Health > 0 then table.insert(players, p) end
            end
        end
    end
    return players
end

local function selectNewTarget()
    if targetHumanoidDiedConnection then
        targetHumanoidDiedConnection:Disconnect()
        targetHumanoidDiedConnection = nil
    end
    local players = getAllPlayers()
    if #players > 0 then
        targetPlayer = players[math.random(1, #players)]
        local targetHumanoid = targetPlayer.Character and targetPlayer.Character:FindFirstChildOfClass("Humanoid")
        if targetHumanoid then
            targetHumanoidDiedConnection = targetHumanoid.Died:Connect(function()
                task.wait(0.1)
                selectNewTarget()
            end)
        end
    else
        targetPlayer = nil
    end
end

local function makeOriginalInvisible()
    local char = LocalPlayer.Character
    if not char then return end
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") or part:IsA("Decal") then
            part.LocalTransparencyModifier = 1
        end
    end
end

local function toggleWallCam()
    wallCamEnabled = not wallCamEnabled
    if wallCamEnabled then
        selectNewTarget()
        Camera.CameraType = Enum.CameraType.Scriptable
        UIS.MouseBehavior = Enum.MouseBehavior.LockCenter
        local char = LocalPlayer.Character
        local rootPart = char and char:FindFirstChild("HumanoidRootPart")
        if rootPart then savedCFrame = rootPart.CFrame end
        if wallCamConnection then wallCamConnection:Disconnect() wallCamConnection = nil end

        wallCamConnection = RunService.RenderStepped:Connect(function()
            local c = LocalPlayer.Character
            if not c then return end
            local rp = c:FindFirstChild("HumanoidRootPart")
            local h = c:FindFirstChildOfClass("Humanoid")
            if not rp or not h then return end

            if not targetPlayer or not targetPlayer.Character or not targetPlayer.Character:FindFirstChild("HumanoidRootPart") or targetPlayer.Character.Humanoid.Health <= 0 then
                selectNewTarget()
            end
            if not targetPlayer then return end

            local targetHeadPosition = nil
            local targetChar = targetPlayer.Character
            if targetChar then
                local head = targetChar:FindFirstChild("Head")
                local thrrp = targetChar:FindFirstChild("HumanoidRootPart")
                if head then targetHeadPosition = head.Position
                elseif thrrp then targetHeadPosition = thrrp.Position + Vector3.new(0, 1.5, 0) end
            end
            if not targetHeadPosition then return end

            makeOriginalInvisible()

            local cameraFocusPoint = targetHeadPosition
            local rotationCFrame = CFrame.Angles(0, math.rad(cameraRotationX), 0) * CFrame.Angles(math.rad(cameraRotationY), 0, 0)
            local cameraRelativeOffset = Vector3.new(0, 0, CAMERA_DISTANCE)
            local targetCameraPosition = cameraFocusPoint + (rotationCFrame * cameraRelativeOffset)

            Camera.CFrame = CFrame.new(targetCameraPosition, cameraFocusPoint)
            rp.CFrame = CFrame.new(targetHeadPosition) + Vector3.new(0, SKY_HEIGHT, 0)
            rp.AssemblyLinearVelocity = Vector3.zero
        end)
    else
        if wallCamConnection then wallCamConnection:Disconnect() wallCamConnection = nil end
        if targetHumanoidDiedConnection then targetHumanoidDiedConnection:Disconnect() targetHumanoidDiedConnection = nil end
        targetPlayer = nil
        Camera.CameraType = Enum.CameraType.Custom
        UIS.MouseBehavior = Enum.MouseBehavior.Default

        local char = LocalPlayer.Character
        if char then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") or part:IsA("Decal") then
                    part.LocalTransparencyModifier = 0
                end
            end
            if savedCFrame then
                local rp = char:FindFirstChild("HumanoidRootPart")
                if rp then rp.CFrame = savedCFrame end
            end
        end
    end
end

UIS.InputChanged:Connect(function(input, processed)
    if processed or not wallCamEnabled then return end
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        cameraRotationX = cameraRotationX - input.Delta.X * MOUSE_SENSITIVITY
        cameraRotationY = math.clamp(cameraRotationY - input.Delta.Y * MOUSE_SENSITIVITY, -85, 85)
    end
end)

-- ============================
-- LINORIALIB UI
-- ============================
local repo = 'https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/'
local Library = loadstring(game:HttpGet(repo .. 'Library.lua'))()
local ThemeManager = loadstring(game:HttpGet(repo .. 'addons/ThemeManager.lua'))()
local SaveManager = loadstring(game:HttpGet(repo .. 'addons/SaveManager.lua'))()

local Window = Library:CreateWindow({
    Title = '@set9p | SCRIPT HUB',
    Center = true,
    AutoShow = true,
    TabPadding = 8,
    MenuFadeTime = 0.2
})

local Tabs = {
    Combat = Window:AddTab('Бой'),
    Visuals = Window:AddTab('ESP & HUD'),
    Misc = Window:AddTab('Разное'),
    WallCam = Window:AddTab('WallCam'),
    Settings = Window:AddTab('Настройки')
}

-- TAB: БОЙ
local LeftCombatBox = Tabs.Combat:AddLeftGroupbox('Aim Bot')
local RightCombatBox = Tabs.Combat:AddRightGroupbox('Трейлы и Звуки')

LeftCombatBox:AddToggle('SilentAimToggle', {
    Text = CanHook and 'Silent Aim' or 'Silent Aim [NO WORK]',
    Default = false,
    Callback = function(v)
        if not CanHook then Settings.SilentAim = false return end
        Settings.SilentAim = v
    end
})

LeftCombatBox:AddToggle('Aim360Toggle', {
    Text = 'Aim 360° (Везде / Вокруг)',
    Default = false,
    Callback = function(v) Settings.Aim360 = v end
})

LeftCombatBox:AddToggle('AutoTriggerToggle', {
    Text = 'Auto Trigger (Спам выстрелами)',
    Default = false,
    Callback = function(v) Settings.AutoTrigger = v end
})

LeftCombatBox:AddToggle('VisibleCheckToggle', {
    Text = 'Visible Check (Только видимые)',
    Default = true,
    Callback = function(v) Settings.VisibleCheck = v end
})

-- Возвращенный элемент управления WallCheck в интерфейсе
LeftCombatBox:AddToggle('WallCheckToggle', {
    Text = 'WallCheck (Учет прострелов)',
    Default = true,
    Callback = function(v) Settings.WallCheck = v end
})

LeftCombatBox:AddDropdown('AimPartDropdown', {
    Values = {'Head', 'Torso'},
    Default = 1,
    Text = 'Выбор хитбокса',
    Callback = function(v) Settings.AimPart = v end
})

LeftCombatBox:AddSlider('AimFOVSlider', {
    Text = 'Aim FOV',
    Default = 200,
    Min = 20,
    Max = 800,
    Rounding = 0,
    Suffix = 'px',
    Callback = function(v) Settings.AimFOV = v end
})

LeftCombatBox:AddToggle('FOVCircleToggle', {
    Text = 'Показать FOV круг',
    Default = false,
    Callback = function(v) Settings.DrawFOV = v end
}):AddColorPicker('FOVColorPicker', {
    Default = Color3.fromRGB(255, 0, 80),
    Title = 'Цвет FOV круга',
    Callback = function(v) espColor = v end
})

-- Правая сторона Боя
RightCombatBox:AddToggle('BulletTrailToggle', {
    Text = 'Включить трейл пули',
    Default = false,
    Callback = function(v) Settings.BulletTrailEnabled = v end
}):AddColorPicker('BulletTrailColorPicker', {
    Default = Color3.fromRGB(255, 0, 80),
    Title = 'Цвет трейла',
    Callback = function(v) Settings.BulletTrailColor = v end
})

RightCombatBox:AddSlider('BulletTrailWidthSlider', {
    Text = 'Толщина трейла',
    Default = 0.2,
    Min = 0.05,
    Max = 1,
    Rounding = 2,
    Callback = function(v) Settings.BulletTrailWidth = v end
})

RightCombatBox:AddSlider('BulletTrailLifetimeSlider', {
    Text = 'Время жизни трейла',
    Default = 0.3,
    Min = 0.1,
    Max = 2,
    Rounding = 1,
    Suffix = 's',
    Callback = function(v) Settings.BulletTrailLifetime = v end
})

RightCombatBox:AddToggle('TriggerSoundToggle', {
    Text = 'Включить звук при выстреле',
    Default = false,
    Callback = function(v) Settings.TriggerSoundEnabled = v end
})

local soundOptions = {
    "140325083438865", "73332070629063", "71173310238334", "114072050006157", 
    "133319559387398", "8568536678", "82900255403344", "128418218662188", 
    "6837721511", "2868331684"
}

RightCombatBox:AddDropdown('TriggerSoundDropdown', {
    Values = soundOptions,
    Default = 1,
    Text = 'Выберите звук выстрела',
    Callback = function(v) Settings.TriggerSoundId = tostring(v) end
})

RightCombatBox:AddButton('PlaySoundButton', '▶ Прослушать звук', function()
    playSound(Settings.TriggerSoundId)
    Library:Notify("Воспроизведение: " .. tostring(Settings.TriggerSoundId), 2)
end)

-- TAB: ESP & HUD
local LeftESPBox = Tabs.Visuals:AddLeftGroupbox('ESP Настройки')
local RightHUDBox = Tabs.Visuals:AddRightGroupbox('HUD Информер')

LeftESPBox:AddToggle('ESPToggle', {
    Text = 'Включить ESP',
    Default = false,
    Callback = function(v) Settings.ESP = v end
}):AddColorPicker('ESPColorPicker', {
    Default = Color3.fromRGB(255, 0, 80),
    Title = 'Цвет ESP',
    Callback = function(v) espColor = v end
})

LeftESPBox:AddToggle('ESPBoxToggle', { Text = 'Box (Коробки)', Default = true, Callback = function(v) Settings.ESPBoxes = v end })
LeftESPBox:AddToggle('ESPNameToggle', { Text = 'Имена', Default = true, Callback = function(v) Settings.ESPNames = v end })
LeftESPBox:AddToggle('ESPDistToggle', { Text = 'Дистанция', Default = true, Callback = function(v) Settings.ESPDistance = v end })
LeftESPBox:AddToggle('ESPHealthToggle', { Text = 'Полоса здоровья (HP Bar)', Default = true, Callback = function(v) Settings.ESPHealth = v end })
LeftESPBox:AddToggle('ESPLineToggle', { Text = 'Линии (Line ESP)', Default = false, Callback = function(v) Settings.ESPLine = v end })

LeftESPBox:AddDropdown('ESPLineOriginDropdown', {
    Values = {'Bottom', 'Center', 'Top'},
    Default = 1,
    Text = 'Откуда вести линии',
    Callback = function(v) Settings.ESPLineOrigin = v end
})

LeftESPBox:AddToggle('ESPFillToggle', { Text = 'Заливка (Fill)', Default = false, Callback = function(v) Settings.ESPFill = v end })
LeftESPBox:AddSlider('ESPFillTransparency', { Text = 'Прозрачность заливки', Default = 0.5, Min = 0, Max = 1, Rounding = 2, Callback = function(v) Settings.ESPFillTransparency = v end })

LeftESPBox:AddToggle('ESPRGB', { Text = 'RGB Радуга ESP', Default = false, Callback = function(v) Settings.ESPRGB = v end })
LeftESPBox:AddSlider('ESPRGBSpeed', { Text = 'Скорость RGB', Default = 1, Min = 0.1, Max = 5, Rounding = 1, Callback = function(v) Settings.ESPRGBSpeed = v end })

RightHUDBox:AddToggle('HUDEnabledToggle', { Text = 'Включить HUD Информер', Default = false, Callback = function(v) hudEnabled = v end })
RightHUDBox:AddToggle('HUDFPSToggle', { Text = 'Показывать FPS', Default = false, Callback = function(v) hudFPS = v end })
RightHUDBox:AddToggle('HUDSpeedToggle', { Text = 'Показывать Скорость', Default = false, Callback = function(v) hudSpeed = v end })
RightHUDBox:AddToggle('HUDPingToggle', { Text = 'Показывать Пинг (MS)', Default = false, Callback = function(v) hudPing = v end })

-- TAB: РАЗНОЕ
local LeftMiscBox = Tabs.Misc:AddLeftGroupbox('Мир и Окружение')
local RightMiscBox = Tabs.Misc:AddRightGroupbox('Персонаж и Камера')

LeftMiscBox:AddToggle('WorldColorToggle', {
    Text = 'Цветной мир (World Color)',
    Default = false,
    Callback = function(v)
        worldColorEnabled = v
        updateWorldColor()
    end
}):AddColorPicker('WorldColorPicker', {
    Default = Color3.fromRGB(150, 50, 255),
    Title = 'Цвет мира',
    Callback = function(v)
        customWorldColor = v
        if worldColorEnabled then updateWorldColor() end
    end
})

LeftMiscBox:AddToggle('NightModeToggle', { Text = 'NightMode (Ночь)', Default = false, Callback = function(v) nightModeEnabled = v end })
LeftMiscBox:AddSlider('NightBrightnessSlider', { Text = 'Яркость NightMode', Default = 0.5, Min = 0, Max = 2, Rounding = 1, Callback = function(v) nightBrightness = v end })

RightMiscBox:AddToggle('BhopToggle', { Text = 'Bhop (Авто-прыжок)', Default = false, Callback = function(v) bhopEnabled = v end })
RightMiscBox:AddToggle('JumpSpeedToggle', { Text = 'Фиксация скорости прыжка (25)', Default = true, Callback = function(v) jumpSpeedEnabled = v end })

RightMiscBox:AddToggle('SpinToggle', {
    Text = 'Spin (Крутилка)',
    Default = false,
    Callback = function(v)
        spinEnabled = v
        updateSpin()
    end
})
RightMiscBox:AddSlider('SpinSpeedSlider', { Text = 'Скорость Spin', Default = 25, Min = 1, Max = 50, Rounding = 0, Suffix = '°', Callback = function(v) SPIN_SPEED = v end })

RightMiscBox:AddToggle('ZoomToggle', {
    Text = '3-е лицо (Zoom)',
    Default = false,
    Callback = function(v)
        zoomEnabled = v
        updateZoom()
    end
})
RightMiscBox:AddToggle('AntiAimDownToggle', { Text = 'Анти-Аим (Смотреть в пол в 3-м лице)', Default = false, Callback = function(v) Settings.AntiAimDown = v end })
RightMiscBox:AddSlider('ZoomDistanceSlider', { Text = 'Дистанция 3-го лица', Default = 30, Min = 5, Max = 150, Rounding = 0, Suffix = ' studs', Callback = function(v) DESIRED_ZOOM = v; updateZoom() end })
RightMiscBox:AddSlider('CameraFOVSlider', { Text = 'Камера FOV', Default = 70, Min = 1, Max = 120, Rounding = 0, Suffix = '°', Callback = function(v) cameraFOV = v end })

-- TAB: WALLCAM
local WallCamBox = Tabs.WallCam:AddLeftGroupbox('Настройки WallCam')

WallCamBox:AddToggle('WallCamToggle', {
    Text = 'Включить WallCam',
    Default = false,
    Callback = function(v)
        if v then toggleWallCam() else if wallCamEnabled then toggleWallCam() end end
    end
})

WallCamBox:AddSlider('WallCamDistance', { Text = 'Дистанция камеры', Default = 5, Min = 1, Max = 20, Rounding = 1, Suffix = ' studs', Callback = function(v) CAMERA_DISTANCE = v end })
WallCamBox:AddSlider('WallCamSensitivity', { Text = 'Чувствительность мыши', Default = 0.5, Min = 0.1, Max = 2, Rounding = 1, Callback = function(v) MOUSE_SENSITIVITY = v end })

-- TAB: НАСТРОЙКИ (Linoria Utilities)
ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})
ThemeManager:ApplyToTab(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)

Library:Notify("@set9p | WallCheck успешно возвращен в LinoriaLib!", 3)