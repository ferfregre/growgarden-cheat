--[[
    SoloScriptHub Library Core (Extended) — By set33p
    Includes: Window, Tabs, Toggles, Sliders, Section Headers, Resizer & Smooth Animations.
]]

local SoloLib = {}

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

function SoloLib:CreateWindow(config)
    local windowName = config.Name or "SoloScriptHub"
    local subtitleText = config.Subtitle or "By set33p"
    local accentColor = config.ThemeColor or Color3.fromRGB(138, 43, 226)

    -- GUI Setup
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "SoloScriptLib_UI"
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

    local MainFrame = Instance.new("Frame", ScreenGui)
    MainFrame.Size = UDim2.new(0, 580, 0, 380)
    MainFrame.Position = UDim2.new(0.5, -290, 0.5, -190)
    MainFrame.BackgroundColor3 = Color3.fromRGB(14, 14, 20)
    MainFrame.BorderSizePixel = 0
    MainFrame.Active = true
    MainFrame.Draggable = true

    Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)
    local MainStroke = Instance.new("UIStroke", MainFrame)
    MainStroke.Color = accentColor
    MainStroke.Transparency = 0.4
    MainStroke.Thickness = 1.5

    -- Шапка (TopBar)
    local TopBar = Instance.new("Frame", MainFrame)
    TopBar.Size = UDim2.new(1, 0, 0, 45)
    TopBar.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
    TopBar.BorderSizePixel = 0
    Instance.new("UICorner", TopBar).CornerRadius = UDim.new(0, 10)

    local Title = Instance.new("TextLabel", TopBar)
    Title.Size = UDim2.new(0, 200, 0, 20)
    Title.Position = UDim2.new(0, 15, 0, 6)
    Title.BackgroundTransparency = 1
    Title.Font = Enum.Font.GothamBold
    Title.Text = windowName
    Title.TextColor3 = Color3.fromRGB(240, 240, 255)
    Title.TextSize = 13
    Title.TextXAlignment = Enum.TextXAlignment.Left

    local Subtitle = Instance.new("TextLabel", TopBar)
    Subtitle.Size = UDim2.new(0, 200, 0, 15)
    Subtitle.Position = UDim2.new(0, 15, 0, 24)
    Subtitle.BackgroundTransparency = 1
    Subtitle.Font = Enum.Font.Gotham
    Subtitle.Text = subtitleText
    Subtitle.TextColor3 = Color3.fromRGB(150, 150, 180)
    Subtitle.TextSize = 10
    Subtitle.TextXAlignment = Enum.TextXAlignment.Left

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

    -- Контейнер страниц
    local PagesContainer = Instance.new("Folder", MainFrame)
    
    local WindowObj = {}
    local tabs = {}
    local firstTab = true
    local normalSize = MainFrame.Size

    function WindowObj:CreateTab(tabName, tabIcon)
        local container = Instance.new("ScrollingFrame", MainFrame)
        container.Size = UDim2.new(1, -190, 1, -55)
        container.Position = UDim2.new(0, 180, 0, 50)
        container.BackgroundTransparency = 1
        container.BorderSizePixel = 0
        container.CanvasSize = UDim2.new(0, 0, 2, 0)
        container.ScrollBarThickness = 3
        container.ScrollBarImageColor3 = accentColor
        container.Visible = false
        container.Parent = PagesContainer

        local layout = Instance.new("UIListLayout", container)
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        layout.Padding = UDim.new(0, 10)

        local btn = Instance.new("TextButton", Sidebar)
        btn.Size = UDim2.new(1, -5, 0, 36)
        btn.BackgroundColor3 = firstTab and accentColor or Color3.fromRGB(22, 22, 32)
        btn.BorderSizePixel = 0
        btn.Text = "   " .. (tabIcon or "📄") .. "   " .. tabName
        btn.TextColor3 = firstTab and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(170, 170, 190)
        btn.TextSize = 12
        btn.Font = Enum.Font.GothamSemibold
        btn.TextXAlignment = Enum.TextXAlignment.Left
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)

        if firstTab then
            container.Visible = true
            firstTab = false
        end

        btn.MouseButton1Click:Connect(function()
            for _, p in pairs(PagesContainer:GetChildren()) do p.Visible = false end
            for _, t in pairs(tabs) do 
                TweenService:Create(t, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(22, 22, 32), TextColor3 = Color3.fromRGB(170, 170, 190)}):Play()
            end
            container.Visible = true
            TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = accentColor, TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
        end)
        table.insert(tabs, btn)

        local TabObj = {}

        -- Создание заголовка раздела (Section)
        function TabObj:CreateSection(sectionTitle)
            local header = Instance.new("TextLabel", container)
            header.Size = UDim2.new(1, 0, 0, 25)
            header.BackgroundTransparency = 1
            header.Font = Enum.Font.GothamBold
            header.Text = "  ⚡ " .. sectionTitle
            header.TextColor3 = Color3.fromRGB(180, 130, 255)
            header.TextSize = 13
            header.TextXAlignment = Enum.TextXAlignment.Left
        end

        -- Создание переключателя (Toggle)
        function TabObj:CreateToggle(toggleConfig)
            local title = toggleConfig.Name or "Toggle"
            local desc = toggleConfig.Info or ""
            local callback = toggleConfig.Callback or function() end

            local frame = Instance.new("Frame", container)
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
                local goalColor = state and accentColor or Color3.fromRGB(35, 35, 50)
                local goalPos = state and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)
                
                TweenService:Create(toggleBtn, TweenInfo.new(0.25), {BackgroundColor3 = goalColor}):Play()
                TweenService:Create(circle, TweenInfo.new(0.25), {Position = goalPos}):Play()
                
                pcall(callback, state)
            end)
        end

        -- Создание слайдера (Slider)
        function TabObj:CreateSlider(sliderConfig)
            local title = sliderConfig.Name or "Slider"
            local min = sliderConfig.Range[1] or 0
            local max = sliderConfig.Range[2] or 100
            local default = sliderConfig.CurrentValue or min
            local callback = sliderConfig.Callback or function() end

            local frame = Instance.new("Frame", container)
            frame.Size = UDim2.new(1, -10, 0, 55)
            frame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
            frame.BorderSizePixel = 0
            Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)

            local lbl = Instance.new("TextLabel", frame)
            lbl.Size = UDim2.new(1, -20, 0, 20)
            lbl.Position = UDim2.new(0, 14, 0, 6)
            lbl.BackgroundTransparency = 1
            lbl.Font = Enum.Font.GothamBold
            lbl.Text = title .. ": " .. tostring(default)
            lbl.TextColor3 = Color3.fromRGB(235, 235, 245)
            lbl.TextSize = 12
            lbl.TextXAlignment = Enum.TextXAlignment.Left

            local sliderBg = Instance.new("Frame", frame)
            sliderBg.Size = UDim2.new(1, -28, 0, 8)
            sliderBg.Position = UDim2.new(0, 14, 0, 34)
            sliderBg.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
            sliderBg.BorderSizePixel = 0
            Instance.new("UICorner", sliderBg).CornerRadius = UDim.new(1, 0)

            local sliderFill = Instance.new("Frame", sliderBg)
            sliderFill.Size = UDim2.new((default - min)/(max - min), 0, 1, 0)
            sliderFill.BackgroundColor3 = accentColor
            sliderFill.BorderSizePixel = 0
            Instance.new("UICorner", sliderFill).CornerRadius = UDim.new(1, 0)

            local dragging = false
            sliderBg.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = true
                end
            end)

            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = false
                end
            end)

            UserInputService.InputChanged:Connect(function(input)
                if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    local pos = math.clamp((input.Position.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X, 0, 1)
                    sliderFill.Size = UDim2.new(pos, 0, 1, 0)
                    local val = math.floor(min + (max - min) * pos)
                    lbl.Text = title .. ": " .. tostring(val)
                    pcall(callback, val)
                end
            end)
        end

        return TabObj
    end

    -- Изменение размера окна мышкой
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

    -- Скрытие/Показ по RightShift
    local menuVisible = true
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed and input.KeyCode == Enum.KeyCode.RightShift then
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
    end)

    return WindowObj
end

return SoloLib