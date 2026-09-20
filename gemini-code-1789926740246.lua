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

pcall(function()
    local старыйИндекс
    старыйИндекс = hookmetamethod(game, "__index", function(self, method)
        if self == LocalPlayer and typeof(method) == "string" and method:lower() == "kick" then
            return error("Expected ':' not '.' calling member function Kick", 2)
        end
        return старыйИндекс(self, method)
    end)

    local старыйНеймколл
    старыйНеймколл = hookmetamethod(game, "__namecall", function(self, ...)
        if self == LocalPlayer then
            local method = getnamecallmethod()
            if typeof(method) == "string" and method:lower() == "kick" then
                return
            end
        end
        return старыйНеймколл(self, ...)
    end)
end)

local Настройки = {
    СайлентАим = false,
    ЧастьТела = "Head",
    АимФОВ = 200,
    Аим360 = false,
    РисоватьФОВ = false,
    
    АвтоТриггер = false,
    Валлбанг = false,
    МаксДистанцияЦели = 150,

    ТрейлПули = false,
    ЦветТрейла = Color3.fromRGB(255, 0, 80),
    ВремяЖизниТрейла = 0.3,
    ШиринаТрейла = 0.2,
    КДТрейла = 0.3,

    ЗвукТриггераВключен = false,
    АйдиЗвукаТриггера = "140325083438865",
    ГромкостьЗвукаТриггера = 1,
    КДЗвукаТриггера = 0.3,

    АнтиАимВниз = false,

    ЕСП = false,
    ЕСПБоксы = true,
    ЕСПИмена = true,
    ЕСПДистанция = true,
    ЕСПЗдоровье = true,
    ЕСПЛиния = false,
    ИсточникЛинииЕСП = "Bottom",
    ЕСПЗаливка = false,
    ПрозрачностьЗаливкиЕСП = 0.5,
    ЕСПРГБ = false,
    СкоростьРГБЕСП = 1
}

local цветЕсп = Color3.fromRGB(255, 0, 80)
local цель = nil
local времяВыстрела = 0
local последнееВремяЗвука = 0
local последнееВремяТрейла = 0
local ОбъектыЕСП = {}
local еспХайлайты = {}
local кругФОВ = nil

local худВключен = false
local худФПС = false
local худСкорость = false
local худПиинг = false
local кэшФПС = 0
local последнийТикФПС = 0

local текстХуд = Drawing.new("Text")
текстХуд.Visible = false
текстХуд.Size = 16
текстХуд.Position = Vector2.new(15, 15)
текстХуд.Color = Color3.fromRGB(255, 255, 255)
текстХуд.Outline = true
текстХуд.Center = false

local режимНочиВключен = false
local яркостьНочи = 0.5
local цветМираВключен = false
local кастомныйЦветМира = Color3.fromRGB(150, 50, 255)
local активнаяАтмосфера = nil
local исходныеСвойстваОсвещения = {
    Ambient = Lighting.Ambient,
    OutdoorAmbient = Lighting.OutdoorAmbient,
    ColorShift_Bottom = Lighting.ColorShift_Bottom,
    ColorShift_Top = Lighting.ColorShift_Top
}

local бхопВключен = false
local пробелЗажат = false
local фиксацияСкоростиПрыжка = true 
local ЦЕЛЕВАЯ_СКОРОСТЬ_ПРЫЖКА = 25

local спинВключен = false
local СКОРОСТЬ_СПИНА = 25
local спинСоединение = nil
local зумВключен = false
local ЖЕЛАЕМЫЙ_ЗУМ = 30
local зумСоединение = nil
local полеЗренияКамеры = 70

local валлКамВключен = false
local целевойИгрок = nil
local соединениеСмертиЦели = nil
local поворотКамерыХ = 0
local поворотКамерыУ = 0
local ВЫСОТА_НЕБА = 1000
local ДИСТАНЦИЯ_КАМЕРЫ = 5
local ЧУВСТВИТЕЛЬНОСТЬ_МЫШИ = 0.5
local валлКамСоединение = nil
local сохраненныйCFrame = nil

local function воспроизвестиЗвук(id)
    local текущееВремя = tick()
    if текущееВремя - последнееВремяЗвука < Настройки.КДЗвукаТриггера then
        return
    end
    последнееВремяЗвука = текущееВремя

    pcall(function()
        local sound = Instance.new("Sound")
        sound.SoundId = "rbxassetid://" .. tostring(id)
        sound.Volume = Настройки.ГромкостьЗвукаТриггера
        sound.Parent = SoundService
        sound:Play()
        sound.Ended:Connect(function()
            sound:Destroy()
        end)
    end)
end

local function воспроизвестиЗвукУбийства()
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

local function получитьРадужныйЦвет()
    local hue = (tick() * Настройки.СкоростьРГБЕСП) % 1
    return Color3.fromHSV(hue, 1, 1)
end

local function проверитьЦель(целеваяЧасть)
    if not целеваяЧасть or not целеваяЧасть.Parent then return false end
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return false end

    local origin = char.HumanoidRootPart.Position
    local targetPos = целеваяЧасть.Position

    if (origin - targetPos).Magnitude > Настройки.МаксДистанцияЦели then
        return false
    end

    if Настройки.Валлбанг then
        return true
    end

    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude
    raycastParams.IgnoreWater = true
    raycastParams.FilterDescendantsInstances = {char, целеваяЧасть.Parent}

    local result = Workspace:Raycast(origin, targetPos - origin, raycastParams)
    
    if not result or result.Instance == целеваяЧасть or result.Instance:IsDescendantOf(целеваяЧасть.Parent) then
        return true
    end
    
    local model = result.Instance:FindFirstAncestorOfClass("Model")
    if model and Players:GetPlayerFromCharacter(model) then
        return true
    end

    return false
end

local function этоВраг(player)
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

local function создатьТрейлПули(исхПозиция, хитПозиция)
    if not Настройки.ТрейлПули then return end
    
    local текущееВремя = tick()
    if текущееВремя - последнееВремяТрейла < Настройки.КДТрейла then
        return
    end
    последнееВремяТрейла = текущееВремя

    pcall(function()
        local part = Instance.new("Part")
        part.Size = Vector3.new(0.1, 0.1, 0.1)
        part.Transparency = 1
        part.Anchored = true
        part.CanCollide = false
        part.CFrame = CFrame.new(исхПозиция)
        part.Parent = Workspace

        local endPart = Instance.new("Part")
        endPart.Size = Vector3.new(0.1, 0.1, 0.1)
        endPart.Transparency = 1
        endPart.Anchored = true
        endPart.CanCollide = false
        endPart.CFrame = CFrame.new(хитПозиция)
        endPart.Parent = Workspace

        local att0 = Instance.new("Attachment", part)
        local att1 = Instance.new("Attachment", endPart)

        local beam = Instance.new("Beam")
        beam.Attachment0 = att0
        beam.Attachment1 = att1
        beam.Color = ColorSequence.new(Настройки.ЦветТрейла)
        beam.Width0 = Настройки.ШиринаТрейла
        beam.Width1 = Настройки.ШиринаТрейла
        beam.Transparency = NumberSequence.new(0)
        beam.FaceCamera = true
        beam.Parent = part

        task.delay(Настройки.ВремяЖизниТрейла, function()
            pcall(function()
                part:Destroy()
                endPart:Destroy()
            end)
        end)
    end)
end

local function ПолучитьБлижайшегоИгрока()
    local наименьшаяДистанция = math.huge
    local ближайшаяЦель = nil

    local center = Camera.ViewportSize / 2
    local plrs = Players:GetPlayers()
    local myChar = LocalPlayer.Character
    local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if not myHRP then return nil end

    for _, v in pairs(plrs) do
        if not этоВраг(v) then continue end
        local char = v.Character
        if not char then continue end
        
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp or not hrp:IsA("BasePart") then continue end

        local worldDist = (hrp.Position - myHRP.Position).Magnitude
        if worldDist > Настройки.МаксДистанцияЦели then
            continue
        end

        local targetHitPart = nil
        if Настройки.ЧастьТела == "Head" then
            targetHitPart = char:FindFirstChild("Head") or hrp
        else
            targetHitPart = char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso") or hrp
        end

        if not targetHitPart or not targetHitPart:IsA("BasePart") then continue end

        if проверитьЦель(targetHitPart) then
            if Настройки.Аим360 then
                if worldDist < наименьшаяДистанция then
                    найменьшаяДистанция = worldDist
                    ближайшаяЦель = targetHitPart
                end
            else
                local screenPos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
                if onScreen then
                    local distance = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
                    if distance <= Настройки.АимФОВ and distance < наименьшаяДистанция then
                        найменьшаяДистанция = distance
                        ближайшаяЦель = targetHitPart
                    end
                end
            end
        end
    end

    return ближайшаяЦель
end

local зафиксированнаяЦель = nil
local триггерАктивен = false

RunService.RenderStepped:Connect(function()
    if not Настройки.СайлентАим and not Настройки.АвтоТриггер then
        цель = nil
        зафиксированнаяЦель = nil
        return
    end

    if зафиксированнаяЦель and зафиксированнаяЦель.Parent then
        local char = зафиксированнаяЦель.Parent
        local hum = char:FindFirstChildOfClass("Humanoid")
        local всеЕщеВалидна = false
        if hum and hum.Health > 0 then
            if проверитьЦель(зафиксированнаяЦель) then
                всеЕщеВалидна = true
            end
        end
        if not всеЕщеВалидна then
            зафиксированнаяЦель = nil
        end
    else
        зафиксированнаяЦель = nil
    end

    if not зафиксированнаяЦель then
        зафиксированнаяЦель = ПолучитьБлижайшегоИгрока()
    end

    цель = зафиксированнаяЦель

    if Настройки.АвтоТриггер and цель and not триггерАктивен then
        триггерАктивен = true
        task.spawn(function()
            pcall(function()
                if mouse1press then mouse1press() end
                if Настройки.ЗвукТриггераВключен then
                    воспроизвестиЗвук(Настройки.АйдиЗвукаТриггера)
                end
                task.wait(0.04)
                if mouse1release then mouse1release() end
            end)
            task.wait(0.08)
            триггерАктивен = false
        end)
    end
end)

local старыйХук
if CanHook then
    pcall(function()
        старыйХук = hookfunction(Ray.new, newcclosure(function(origin, direction)
            local trace = debug.traceback()
            
            if trace:find("Client") and not trace:find("10420") and not trace:find("10595") then
                if Настройки.СайлентАим and цель and цель:IsA("BasePart") then
                    времяВыстрела = tick()
                    local realOrigin = origin
                    local targetPos = цель.Position
                    direction = targetPos - realOrigin
                    создатьТрейлПули(realOrigin, targetPos)
                    if Настройки.ЗвукТриггераВключен then
                        воспроизвестиЗвук(Настройки.АйдиЗвукаТриггера)
                    end
                end
            end
            
            return старыйХук(origin, direction)
        end))
    end)
end

local function создатьКругФОВ()
    if кругФОВ then pcall(function() кругФОВ:Remove() end) кругФОВ = nil end
    if Drawing and Drawing.new then
        кругФОВ = Drawing.new("Circle")
        кругФОВ.Thickness = 2
        кругФОВ.Filled = false
        кругФОВ.Transparency = 1
        кругФОВ.Visible = true
    end
end

RunService.RenderStepped:Connect(function()
    local активныйЦвет = Настройки.ЕСПРГБ and получитьРадужныйЦвет() or цветЕсп
    if Настройки.РисоватьФОВ and not Настройки.Аим360 then
        if not кругФОВ then создатьКругФОВ() end
        if кругФОВ then
            local center = Camera.ViewportSize / 2
            кругФОВ.Position = Vector2.new(center.X, center.Y)
            кругФОВ.Radius = Настройки.АимФОВ
            кругФОВ.Color = активныйЦвет
            кругФОВ.Visible = true
        end
    elseif кругФОВ then
        кругФОВ.Visible = false
    end
end)

local function применитьОсобенностиПерсонажа(character)
    local humanoid = character:WaitForChild("Humanoid", 5)
    local hrp = character:WaitForChild("HumanoidRootPart", 5)
    
    if humanoid and hrp then
        humanoid.StateChanged:Connect(function(oldState, newState)
            if фиксацияСкоростиПрыжка and newState == Enum.HumanoidStateType.Jumping then
                local currentVelocity = hrp.AssemblyLinearVelocity
                local moveDir = Vector3.new(currentVelocity.X, 0, currentVelocity.Z)
                
                if moveDir.Magnitude > 0 then
                    moveDir = moveDir.Unit * ЦЕЛЕВАЯ_СКОРОСТЬ_ПРЫЖКА
                else
                    moveDir = hrp.CFrame.LookVector * ЦЕЛЕВАЯ_СКОРОСТЬ_ПРЫЖКА
                end
                
                hrp.AssemblyLinearVelocity = Vector3.new(moveDir.X, currentVelocity.Y, moveDir.Z)
            end
        end)
    end
end

if LocalPlayer.Character then
    применитьОсобенностиПерсонажа(LocalPlayer.Character)
end
LocalPlayer.CharacterAdded:Connect(применитьОсобенностиПерсонажа)

local function обновитьСпин()
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then return end

    if спинВключен then
        hum.AutoRotate = false
        if not спинСоединение then
            спинСоединение = RunService.RenderStepped:Connect(function()
                local c = LocalPlayer.Character
                if not c then return end
                local root = c:FindFirstChild("HumanoidRootPart")
                local h = c:FindFirstChildOfClass("Humanoid")
                if root and h then
                    h.AutoRotate = false
                    root.CFrame = root.CFrame * CFrame.Angles(0, math.rad(СКОРОСТЬ_СПИНА), 0)
                end
            end)
        end
    else
        if спинСоединение then
            спинСоединение:Disconnect()
            спинСоединение = nil
        end
        hum.AutoRotate = true
    end
end

LocalPlayer.CharacterAdded:Connect(function(newChar)
    task.wait(0.5)
    if спинВключен then
        обновитьСпин()
    end
end)

local function мониторитьИгрока(player)
    if player == LocalPlayer then return end
    local function setupChar(char)
        local hum = char:WaitForChild("Humanoid", 5)
        if hum then
            hum.Died:Connect(function()
                if tick() - времяВыстрела < 1.5 then
                    воспроизвестиЗвукУбийства()
                end
            end)
        end
    end
    player.CharacterAdded:Connect(setupChar)
    if player.Character then setupChar(player.Character) end
end
for _, p in ipairs(Players:GetPlayers()) do мониторитьИгрока(p) end
Players.PlayerAdded:Connect(мониторитьИгрока)

local function УдалитьЕСП(player)
    local data = ОбъектыЕСП[player]
    if data then
        for _, v in pairs(data) do
            pcall(function() v:Remove() end)
        end
        ОбъектыЕСП[player] = nil
    end
    if еспХайлайты[player] then
        pcall(function() еспХайлайты[player]:Destroy() end)
        еспХайлайты[player] = nil
    end
end

local function СоздатьЕСП(player)
    if ОбъектыЕСП[player] then return end
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

    ОбъектыЕСП[player] = {Box = box, Outline = outline, Name = name, Dist = dist, HealthBarBg = hbBg, HealthBar = hb, Line = line}
end

local function ОбновитьЕСП()
    local активныйЦвет = Настройки.ЕСПРГБ and получитьРадужныйЦвет() or цветЕсп
    local myChar = LocalPlayer.Character
    local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
    local viewportSize = Camera.ViewportSize

    for player, data in pairs(ОбъектыЕСП) do
        local char = player.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")

        if not Настройки.ЕСП or not char or not этоВраг(player) or not hum or hum.Health <= 0 then
            data.Box.Visible = false
            data.Outline.Visible = false
            data.Name.Visible = false
            data.Dist.Visible = false
            data.HealthBarBg.Visible = false
            data.HealthBar.Visible = false
            data.Line.Visible = false
            if еспХайлайты[player] then еспХайлайты[player]:Destroy() еспХайлайты[player] = nil end
            continue
        end

        if Настройки.ЕСПЗаливка then
            if not еспХайлайты[player] or еспХайлайты[player].Parent ~= char then
                if еспХайлайты[player] then еспХайлайты[player]:Destroy() end
                local h = Instance.new("Highlight")
                h.Parent = char
                h.FillColor = активныйЦвет
                h.OutlineColor = Color3.new(1, 1, 1)
                h.FillTransparency = Настройки.ПрозрачностьЗаливкиЕСП
                еспХайлайты[player] = h
            else
                еспХайлайты[player].FillColor = активныйЦвет
                еспХайлайты[player].FillTransparency = Настройки.ПрозрачностьЗаливкиЕСП
            end
        else
            if еспХайлайты[player] then еспХайлайты[player]:Destroy() еспХайлайты[player] = nil end
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

        if Настройки.ЕСПБоксы then
            data.Box.Size = Vector2.new(width, height)
            data.Box.Position = boxPos
            data.Box.Color = активныйЦвет
            data.Box.Visible = true
            data.Outline.Size = data.Box.Size
            data.Outline.Position = data.Box.Position
            data.Outline.Visible = true
        else
            data.Box.Visible = false
            data.Outline.Visible = false
        end

        if Настройки.ЕСПЗдоровье then
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

        if Настройки.ЕСПИмена then
            data.Name.Text = player.DisplayName or player.Name
            data.Name.Position = Vector2.new(vector.X, boxPos.Y - 16)
            data.Name.Visible = true
        else
            data.Name.Visible = false
        end

        if Настройки.ЕСПДистанция and myHRP then
            local distance = math.floor((hrp.Position - myHRP.Position).Magnitude)
            data.Dist.Text = distance .. "m"
            data.Dist.Position = Vector2.new(vector.X, boxPos.Y + height + 4)
            data.Dist.Visible = true
        else
            data.Dist.Visible = false
        end

        if Настройки.ЕСПЛиния then
            data.Line.Visible = true
            data.Line.Color = активныйЦвет
            local originPos = Vector2.new(viewportSize.X / 2, viewportSize.Y)
            if Настройки.ИсточникЛинииЕСП == "Center" then
                originPos = viewportSize / 2
            elseif Настройки.ИсточникЛинииЕСП == "Top" then
                originPos = Vector2.new(viewportSize.X / 2, 0)
            end
            data.Line.From = originPos
            data.Line.To = Vector2.new(vector.X, boxPos.Y + height / 2)
        else
            data.Line.Visible = false
        end
    end
end

Players.PlayerAdded:Connect(СоздатьЕСП)
Players.PlayerRemoving:Connect(УдалитьЕСП)
for _, p in pairs(Players:GetPlayers()) do
    if p ~= LocalPlayer then СоздатьЕСП(p) end
end
RunService.RenderStepped:Connect(ОбновитьЕСП)

RunService.RenderStepped:Connect(function()
    if not худВключен or not (худФПС or худСкорость or худПиинг) then
        текстХуд.Visible = false
        return
    end

    local infoLines = {}
    if худФПС then
        local currentTime = tick()
        if currentTime - последнийТикФПС >= 0.5 then
            кэшФПС = math.round(1 / RunService.RenderStepped:Wait())
            последнийТикФПС = currentTime
        end
        table.insert(infoLines, "FPS: " .. кэшФПС)
    end

    if худСкорость and LocalPlayer.Character then
        local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            local speed = math.round(Vector3.new(hrp.AssemblyLinearVelocity.X, 0, hrp.AssemblyLinearVelocity.Z).Magnitude)
            table.insert(infoLines, "Speed: " .. speed)
        end
    end

    if худПиинг then
        local ping = 0
        pcall(function()
            ping = math.round(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
        end)
        table.insert(infoLines, "MS: " .. ping .. "ms")
    end

    if #infoLines > 0 then
        текстХуд.Visible = true
        текстХуд.Text = table.concat(infoLines, " | ")
    else
        текстХуд.Visible = false
    end
end)

local function обновитьЦветМира()
    if цветМираВключен then
        Lighting.Ambient = кастомныйЦветМира
        Lighting.OutdoorAmbient = кастомныйЦветМира
        Lighting.ColorShift_Bottom = кастомныйЦветМира
        Lighting.ColorShift_Top = кастомныйЦветМира
        if not активнаяАтмосфера then
            активнаяАтмосфера = Instance.new("Atmosphere")
            активнаяАтмосфера.Parent = Lighting
        end
        активнаяАтмосфера.Color = кастомныйЦветМира
        активнаяАтмосфера.Haze = 2
        активнаяАтмосфера.Density = 0.3
    else
        Lighting.Ambient = исходныеСвойстваОсвещения.Ambient
        Lighting.OutdoorAmbient = исходныеСвойстваОсвещения.OutdoorAmbient
        Lighting.ColorShift_Bottom = исходныеСвойстваОсвещения.ColorShift_Bottom
        Lighting.ColorShift_Top = исходныеСвойстваОсвещения.ColorShift_Top
        if активнаяАтмосфера then
            активнаяАтмосфера:Destroy()
            активнаяАтмосфера = nil
        end
    end
end

RunService.RenderStepped:Connect(function()
    if режимНочиВключен then
        Lighting.Brightness = яркостьНочи
        Lighting.ClockTime = 0
        Lighting.FogEnd = 999999
    elseif not цветМираВключен then
        Lighting.Brightness = 2
        Lighting.ClockTime = 14
        Lighting.FogEnd = 100000
    end
end)

UIS.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.Space then пробелЗажат = true end
end)
UIS.InputEnded:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.Space then пробелЗажат = false end
end)

task.spawn(function()
    while true do
        task.wait()
        if бхопВключен and пробелЗажат then
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

local function обновитьЗум()
    if зумВключен then
        LocalPlayer.CameraMode = Enum.CameraMode.Classic
        LocalPlayer.CameraMinZoomDistance = ЖЕЛАЕМЫЙ_ЗУМ
        LocalPlayer.CameraMaxZoomDistance = ЖЕЛАЕМЫЙ_ЗУМ
        if not зумСоединение then
            зумСоединение = RunService.RenderStepped:Connect(function()
                if зумВключен then
                    LocalPlayer.CameraMode = Enum.CameraMode.Classic
                    LocalPlayer.CameraMinZoomDistance = ЖЕЛАЕМЫЙ_ЗУМ
                    LocalPlayer.CameraMaxZoomDistance = ЖЕЛАЕМЫЙ_ЗУМ
                end
            end)
        end
    else
        if зумСоединение then
            зумСоединение:Disconnect()
            зумСоединение = nil
        end
        LocalPlayer.CameraMinZoomDistance = 0.5
        LocalPlayer.CameraMaxZoomDistance = 400
    end
end

RunService.RenderStepped:Connect(function()
    if полеЗренияКамеры then
        Camera.FieldOfView = полеЗренияКамеры
    end

    local char = LocalPlayer.Character
    if char then
        local torso = char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso")
        local head = char:FindFirstChild("Head")
        
        if зумВключен and Настройки.АнтиАимВниз then
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

local function получитьВсехИгроков()
    local players = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if этоВраг(p) then
            local char = p.Character
            if char then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum and hum.Health > 0 then table.insert(players, p) end
            end
        end
    end
    return players
end

local function выбратьНовуюЦель()
    if соединениеСмертиЦели then
        соединениеСмертиЦели:Disconnect()
        соединениеСмертиЦели = nil
    end
    local players = получитьВсехИгроков()
    if #players > 0 then
        целевойИгрок = players[math.random(1, #players)]
        local targetHumanoid = целевойИгрок.Character and целевойИгрок.Character:FindFirstChildOfClass("Humanoid")
        if targetHumanoid then
            соединениеСмертиЦели = targetHumanoid.Died:Connect(function()
                task.wait(0.1)
                выбратьНовуюЦель()
            end)
        end
    else
        целевойИгрок = nil
    end
end

local function сделатьОригиналНевидимым()
    local char = LocalPlayer.Character
    if not char then return end
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") or part:IsA("Decal") then
            part.LocalTransparencyModifier = 1
        end
    end
end

local function переключитьВаллКам()
    валлКамВключен = not валлКамВключен
    if валлКамВключен then
        выбратьНовуюЦель()
        Camera.CameraType = Enum.CameraType.Scriptable
        UIS.MouseBehavior = Enum.MouseBehavior.LockCenter
        local char = LocalPlayer.Character
        local rootPart = char and char:FindFirstChild("HumanoidRootPart")
        if rootPart then сохраненныйCFrame = rootPart.CFrame end
        if валлКамСоединение then валлКамСоединение:Disconnect() валлКамСоединение = nil end

        валлКамСоединение = RunService.RenderStepped:Connect(function()
            local c = LocalPlayer.Character
            if not c then return end
            local rp = c:FindFirstChild("HumanoidRootPart")
            local h = c:FindFirstChildOfClass("Humanoid")
            if not rp or not h then return end

            if not целевойИгрок or not целевойИгрок.Character or not целевойИгрок.Character:FindFirstChild("HumanoidRootPart") or целевойИгрок.Character.Humanoid.Health <= 0 then
                выбратьНовуюЦель()
            end
            if not целевойИгрок then return end

            local targetHeadPosition = nil
            local targetChar = целевойИгрок.Character
            if targetChar then
                local head = targetChar:FindFirstChild("Head")
                local thrrp = targetChar:FindFirstChild("HumanoidRootPart")
                if head then targetHeadPosition = head.Position
                elseif thrrp then targetHeadPosition = thrrp.Position + Vector3.new(0, 1.5, 0) end
            end
            if not targetHeadPosition then return end

            сделатьОригиналНевидимым()

            local cameraFocusPoint = targetHeadPosition
            local rotationCFrame = CFrame.Angles(0, math.rad(поворотКамерыХ), 0) * CFrame.Angles(math.rad(поворотКамерыУ), 0, 0)
            local cameraRelativeOffset = Vector3.new(0, 0, ДИСТАНЦИЯ_КАМЕРЫ)
            local targetCameraPosition = cameraFocusPoint + (rotationCFrame * cameraRelativeOffset)

            Camera.CFrame = CFrame.new(targetCameraPosition, cameraFocusPoint)
            rp.CFrame = CFrame.new(targetHeadPosition) + Vector3.new(0, ВЫСОТА_НЕБА, 0)
            rp.AssemblyLinearVelocity = Vector3.zero
        end)
    else
        if валлКамСоединение then валлКамСоединение:Disconnect() валлКамСоединение = nil end
        if соединениеСмертиЦели then соединениеСмертиЦели:Disconnect() соединениеСмертиЦели = nil end
        целевойИгрок = nil
        Camera.CameraType = Enum.CameraType.Custom
        UIS.MouseBehavior = Enum.MouseBehavior.Default

        local char = LocalPlayer.Character
        if char then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") or part:IsA("Decal") then
                    part.LocalTransparencyModifier = 0
                end
            end
            if сохраненныйCFrame then
                local rp = char:FindFirstChild("HumanoidRootPart")
                if rp then rp.CFrame = сохраненныйCFrame end
            end
        end
    end
end

UIS.InputChanged:Connect(function(input, processed)
    if processed or not валлКамВключен then return end
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        поворотКамерыХ = поворотКамерыХ - input.Delta.X * ЧУВСТВИТЕЛЬНОСТЬ_МЫШИ
        поворотКамерыУ = math.clamp(поворотКамерыУ - input.Delta.Y * ЧУВСТВИТЕЛЬНОСТЬ_МЫШИ, -85, 85)
    end
end)

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
if not Rayfield then return end

local Window = Rayfield:CreateWindow({
    Name = "@set9p | SCRIPT HUB",
    LoadingTitle = "Загрузка меню...",
    LoadingSubtitle = "by @set9p",
    ConfigurationSaving = { Enabled = false },
    Discord = { Enabled = false },
    KeySystem = false
})

local CombatTab = Window:CreateTab("Бой", 4483362458)

CombatTab:CreateToggle({
    Name = CanHook and "Silent Aim" or "Silent Aim [NO WORK]",
    CurrentValue = false,
    Flag = "SilentAimToggle",
    Callback = function(v) 
        if not CanHook then Настройки.СайлентАим = false return end
        Настройки.СайлентАим = v 
    end
})

CombatTab:CreateToggle({
    Name = "Aim 360° (Везде / Вокруг)",
    CurrentValue = false,
    Flag = "Aim360Toggle",
    Callback = function(v) Настройки.Aim360 = v end
})

CombatTab:CreateToggle({
    Name = "Wallbang (Стрельба сквозь стены)",
    CurrentValue = false,
    Flag = "WallbangToggle",
    Callback = function(v) Настройки.Валлбанг = v end
})

CombatTab:CreateToggle({
    Name = "Auto Trigger (Исправленный авто-триггер)",
    CurrentValue = false,
    Flag = "AutoTriggerToggle",
    Callback = function(v) Настройки.АвтоТриггер = v end
})

CombatTab:CreateSlider({
    Name = "Лимит дальности до цели (Анти-спавн)",
    Range = {50, 500},
    Increment = 25,
    Suffix = " studs",
    CurrentValue = 150,
    Flag = "MaxTargetWorldDistanceSlider",
    Callback = function(v) Настройки.МаксДистанцияЦели = v end
})

CombatTab:CreateSection("Трейл пули (Bullet Trail)")

CombatTab:CreateToggle({
    Name = "Включить трейл пули",
    CurrentValue = false,
    Flag = "BulletTrailToggle",
    Callback = function(v) Настройки.ТрейлПули = v end
})

CombatTab:CreateColorPicker({
    Name = "Цвет трейла",
    Color = Color3.fromRGB(255, 0, 80),
    Flag = "BulletTrailColorPicker",
    Callback = function(v) Настройки.ЦветТрейла = v end
})

CombatTab:CreateSlider({
    Name = "Толщина трейла",
    Range = {0.05, 1},
    Increment = 0.05,
    Suffix = "",
    CurrentValue = 0.2,
    Flag = "BulletTrailWidthSlider",
    Callback = function(v) Настройки.ШиринаТрейла = v end
})

CombatTab:CreateSlider({
    Name = "Время жизни трейла",
    Range = {0.1, 2},
    Increment = 0.1,
    Suffix = "s",
    CurrentValue = 0.3,
    Flag = "BulletTrailLifetimeSlider",
    Callback = function(v) Настройки.ВремяЖизниТрейла = v end
})

CombatTab:CreateSlider({
    Name = "КД трейла (Задержка)",
    Range = {0, 2},
    Increment = 0.05,
    Suffix = "s",
    CurrentValue = 0.3,
    Flag = "BulletTrailCD",
    Callback = function(v) Настройки.КДТрейла = v end
})

CombatTab:CreateSection("Звуки выстрела Trigger-бота")

CombatTab:CreateToggle({
    Name = "Включить звук при выстреле",
    CurrentValue = false,
    Flag = "TriggerSoundToggle",
    Callback = function(v) Настройки.ЗвукТриггераВключен = v end
})

local soundOptions = {
    "140325083438865",
    "73332070629063",
    "71173310238334",
    "114072050006157",
    "133319559387398",
    "8568536678",
    "82900255403344",
    "128418218662188",
    "6837721511",
    "2868331684"
}

CombatTab:CreateDropdown({
    Name = "Выберите звук выстрела",
    Options = soundOptions,
    CurrentOption = {soundOptions[1]},
    MultipleOptions = false,
    Flag = "TriggerSoundDropdown",
    Callback = function(v)
        if type(v) == "table" then
            Настройки.АйдиЗвукаТриггера = tostring(v[1] or soundOptions[1])
        else
            Настройки.АйдиЗвукаТриггера = tostring(v)
        end
    end
})

CombatTab:CreateButton({
    Name = "▶ Прослушать выбранный звук",
    Callback = function()
        воспроизвестиЗвук(Настройки.АйдиЗвукаТриггера)
        Rayfield:Notify({
            Title = "Звук",
            Content = "Воспроизведение: " .. tostring(Настройки.АйдиЗвукаТриггера),
            Duration = 2,
            Image = 4483362458,
        })
    end
})

CombatTab:CreateSlider({
    Name = "Громкость звука",
    Range = {0.1, 5},
    Increment = 0.1,
    Suffix = "",
    CurrentValue = 1,
    Flag = "TriggerSoundVol",
    Callback = function(v) Настройки.ГромкостьЗвукаТриггера = v end
})

CombatTab:CreateSlider({
    Name = "КД звука (Задержка)",
    Range = {0, 2},
    Increment = 0.05,
    Suffix = "s",
    CurrentValue = 0.3,
    Flag = "TriggerSoundCD",
    Callback = function(v) Настройки.КДЗвукаТриггера = v end
})

CombatTab:CreateSection("Выбор хитбокса (Цель)")

CombatTab:CreateToggle({
    Name = "Голова (Head)",
    CurrentValue = true,
    Flag = "AimHeadToggle",
    Callback = function(v)
        if v then
            Настройки.ЧастьТела = "Head"
        end
    end
})

CombatTab:CreateToggle({
    Name = "Торс (Torso)",
    CurrentValue = false,
    Flag = "AimTorsoToggle",
    Callback = function(v)
        if v then
            Настройки.ЧастьТела = "Torso"
        end
    end
})

CombatTab:CreateSlider({
    Name = "Aim FOV",
    Range = {20, 800},
    Increment = 10,
    Suffix = "px",
    CurrentValue = 200,
    Flag = "AimFOVSlider",
    Callback = function(v) Настройки.АимФОВ = v end
})

CombatTab:CreateToggle({
    Name = "Показать FOV круг",
    CurrentValue = false,
    Flag = "FOVCircleToggle",
    Callback = function(v) Настройки.РисоватьФОВ = v end
})

CombatTab:CreateColorPicker({
    Name = "Цвет FOV круга",
    Color = Color3.fromRGB(255, 0, 80),
    Flag = "FOVColorPicker",
    Callback = function(v) цветЕсп = v end
})

local ESPTab = Window:CreateTab("ESP & HUD", 4483362458)

ESPTab:CreateSection("ESP Настройки")

ESPTab:CreateToggle({
    Name = "Включить ESP",
    CurrentValue = false,
    Flag = "ESPToggle",
    Callback = function(v) Настройки.ЕСП = v end
})

ESPTab:CreateToggle({
    Name = "Box (Коробки)",
    CurrentValue = true,
    Flag = "ESPBoxToggle",
    Callback = function(v) Настройки.ЕСПБоксы = v end
})

ESPTab:CreateToggle({
    Name = "Имена",
    CurrentValue = true,
    Flag = "ESPNameToggle",
    Callback = function(v) Настройки.ЕСПИмена = v end
})

ESPTab:CreateToggle({
    Name = "Дистанция",
    CurrentValue = true,
    Flag = "ESPDistToggle",
    Callback = function(v) Настройки.ЕСПДистанция = v end
})

ESPTab:CreateToggle({
    Name = "Полоса здоровья (HP Bar)",
    CurrentValue = true,
    Flag = "ESPHealthToggle",
    Callback = function(v) Настройки.ЕСПЗдоровье = v end
})

ESPTab:CreateToggle({
    Name = "Линии (Line ESP)",
    CurrentValue = false,
    Flag = "ESPLineToggle",
    Callback = function(v) Настройки.ЕСПЛиния = v end
})

ESPTab:CreateDropdown({
    Name = "Откуда вести линии",
    Options = {"Bottom", "Center", "Top"},
    CurrentOption = {"Bottom"},
    MultipleOptions = false,
    Flag = "ESPLineOriginDropdown",
    Callback = function(v) 
        if type(v) == "table" then
            Настройки.ИсточникЛинииЕСП = tostring(v[1] or "Bottom")
        else
            Настройки.ИсточникЛинииЕСП = tostring(v)
        end
    end
})

ESPTab:CreateToggle({
    Name = "Заливка (Fill)",
    CurrentValue = false,
    Flag = "ESPFillToggle",
    Callback = function(v) Настройки.ЕСПЗаливка = v end
})

ESPTab:CreateSlider({
    Name = "Прозрачность заливки",
    Range = {0, 1},
    Increment = 0.05,
    Suffix = "",
    CurrentValue = 0.5,
    Flag = "ESPFillTransparency",
    Callback = function(v) Настройки.ПрозрачностьЗаливкиЕСП = v end
})

ESPTab:CreateToggle({
    Name = "RGB Радуга ESP",
    CurrentValue = false,
    Flag = "ESPRGB",
    Callback = function(v) Настройки.ЕСПРГБ = v end
})

ESPTab:CreateSlider({
    Name = "Скорость RGB",
    Range = {0.1, 5},
    Increment = 0.1,
    Suffix = "x",
    CurrentValue = 1,
    Flag = "ESPRGBSpeed",
    Callback = function(v) Настройки.СкоростьРГБЕСП = v end
})

ESPTab:CreateColorPicker({
    Name = "Цвет ESP",
    Color = Color3.fromRGB(255, 0, 80),
    Flag = "ESPColorPicker",
    Callback = function(v) цветЕсп = v end
})

ESPTab:CreateSection("HUD Информер")

ESPTab:CreateToggle({
    Name = "Включить HUD Информер",
    CurrentValue = false,
    Flag = "HUDEnabledToggle",
    Callback = function(v) худВключен = v end
})

ESPTab:CreateToggle({
    Name = "Показывать FPS",
    CurrentValue = false,
    Flag = "HUDFPSToggle",
    Callback = function(v) худФПС = v end
})

ESPTab:CreateToggle({
    Name = "Показывать Скорость",
    CurrentValue = false,
    Flag = "HUDSpeedToggle",
    Callback = function(v) худСкорость = v end
})

ESPTab:CreateToggle({
    Name = "Показывать Пинг (MS)",
    CurrentValue = false,
    Flag = "HUDPingToggle",
    Callback = function(v) худПиинг = v end
})

local MiscTab = Window:CreateTab("Разное", 4483362458)

MiscTab:CreateToggle({
    Name = "Цветной мир (World Color)",
    CurrentValue = false,
    Flag = "WorldColorToggle",
    Callback = function(v)
        цветМираВключен = v
        обновитьЦветМира()
    end
})

MiscTab:CreateColorPicker({
    Name = "Выбрать цвет мира",
    Color = Color3.fromRGB(150, 50, 255),
    Flag = "WorldColorPicker",
    Callback = function(v)
        кастомныйЦветМира = v
        if цветМираВключен then обновитьЦветМира() end
    end
})

MiscTab:CreateToggle({
    Name = "NightMode (Ночь)",
    CurrentValue = false,
    Flag = "NightModeToggle",
    Callback = function(v) режимНочиВключен = v end
})

MiscTab:CreateSlider({
    Name = "Яркость NightMode",
    Range = {0, 2},
    Increment = 0.1,
    Suffix = "",
    CurrentValue = 0.5,
    Flag = "NightBrightnessSlider",
    Callback = function(v) яркостьНочи = v end
})

MiscTab:CreateToggle({
    Name = "Bhop (Авто-прыжок)",
    CurrentValue = false,
    Flag = "BhopToggle",
    Callback = function(v) бхопВключен = v end
})

MiscTab:CreateToggle({
    Name = "Фиксация скорости прыжка (25)",
    CurrentValue = true,
    Flag = "JumpSpeedToggle",
    Callback = function(v) фиксацияСкоростиПрыжка = v end
})

MiscTab:CreateToggle({
    Name = "Spin (Крутилка)",
    CurrentValue = false,
    Flag = "SpinToggle",
    Callback = function(v)
        спинВключен = v
        обновитьСпин()
    end
})

MiscTab:CreateSlider({
    Name = "Скорость Spin",
    Range = {1, 50},
    Increment = 1,
    Suffix = "°",
    CurrentValue = 25,
    Flag = "SpinSpeedSlider",
    Callback = function(v) СКОРОСТЬ_СПИНА = v end
})

MiscTab:CreateToggle({
    Name = "3-е лицо (Zoom)",
    CurrentValue = false,
    Flag = "ZoomToggle",
    Callback = function(v)
        зумВключен = v
        обновитьЗум()
    end
})

MiscTab:CreateToggle({
    Name = "Анти-Аим (Смотреть в пол в 3-м лице)",
    CurrentValue = false,
    Flag = "AntiAimDownToggle",
    Callback = function(v) Настройки.АнтиАимВниз = v end
})

MiscTab:CreateSlider({
    Name = "Дистанция 3-го лица",
    Range = {5, 150},
    Increment = 5,
    Suffix = " studs",
    CurrentValue = 30,
    Flag = "ZoomDistanceSlider",
    Callback = function(v)
        ЖЕЛАЕМЫЙ_ЗУМ = v
        обновитьЗум()
    end
})

MiscTab:CreateSlider({
    Name = "Камера FOV",
    Range = {1, 120},
    Increment = 1,
    Suffix = "°",
    CurrentValue = 70,
    Flag = "CameraFOVSlider",
    Callback = function(v) полеЗренияКамеры = v end
})

local WallCamTab = Window:CreateTab("WallCam", 4483362458)

WallCamTab:CreateToggle({
    Name = "Включить WallCam",
    CurrentValue = false,
    Flag = "WallCamToggle",
    Callback = function(v)
        if v then переключитьВаллКам() else if валлКамВключен then переключитьВаллКам() end end
    end
})

WallCamTab:CreateSlider({
    Name = "Дистанция камеры",
    Range = {1, 20},
    Increment = 0.5,
    Suffix = " studs",
    CurrentValue = 5,
    Flag = "WallCamDistance",
    Callback = function(v) ДИСТАНЦИЯ_КАМЕРЫ = v end
})

WallCamTab:CreateSlider({
    Name = "Чувствительность мыши",
    Range = {0.1, 2},
    Increment = 0.1,
    Suffix = "",
    CurrentValue = 0.5,
    Flag = "WallCamSensitivity",
    Callback = function(v) ЧУВСТВИТЕЛЬНОСТЬ_МЫШИ = v end
})

Rayfield:Notify({
    Title = "@set9p",
    Content = "Скрипт успешно запущен!",
    Duration = 3,
    Image = 4483362458,
})