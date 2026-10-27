--[[
NOVA PURPLE UI LIBRARY v3 — Neon dashboard layout
For Roblox client-side UI. Public API:
local Nova = loadstring(game:HttpGet("YOUR_RAW_GITHUB_URL"))()
local Window = Nova:CreateWindow({Name="NOVA PURPLE", Subtitle="My UI", Size=UDim2.fromOffset(1000,650)})
local Tab = Window:CreateTab({Name="Главная", Icon="⌂"})
Tab:CreateSection({Name="ДЕМО"})
Tab:CreateButton({Name="Нажми меня", Callback=function() print("Clicked") end})
Tab:CreateToggle({Name="Переключатель", Default=false, Callback=function(v) print(v) end})
Tab:CreateSlider({Name="Слайдер", Min=0, Max=100, Default=50, Callback=function(v) print(v) end})
Tab:CreateDropdown({Name="Выбор", Options={"A","B","C"}, Default="A", Callback=function(v) print(v) end})
Tab:CreateColorPicker({Name="Акцент", Default=Color3.fromRGB(147,72,255), Callback=function(c) Window:SetTheme({Accent=c, Accent2=c}) end})

NOTE: loadstring + HttpGet is not supported in ordinary Roblox Studio LocalScripts.
It is commonly used by third-party script executors. For a Roblox Studio game,
put this code in a ModuleScript and use require(ReplicatedStorage.NovaPurple).
]]

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local Nova = {}
local Window, Tab = {}, {}
Window.__index, Tab.__index = Window, Tab

local BASE = {
    Background = Color3.fromRGB(7, 11, 29),
    Panel = Color3.fromRGB(10, 16, 38),
    Card = Color3.fromRGB(15, 23, 51),
    CardHover = Color3.fromRGB(25, 32, 70),
    Text = Color3.fromRGB(243, 240, 255),
    Muted = Color3.fromRGB(154, 159, 207),
    Accent = Color3.fromRGB(139, 54, 255),
    Accent2 = Color3.fromRGB(190, 91, 255),
    Border = Color3.fromRGB(45, 49, 99),
    Good = Color3.fromRGB(65, 226, 156),
}
local function inst(class, props, parent)
    local o = Instance.new(class)
    for k,v in pairs(props or {}) do o[k] = v end
    o.Parent = parent
    return o
end
local function round(o, r) return inst("UICorner",{CornerRadius=UDim.new(0,r or 10)},o) end
local function outline(o,c,t,a) return inst("UIStroke",{Color=c,Thickness=t or 1,Transparency=a or 0},o) end
local function pad(o,l,r,t,b)
    return inst("UIPadding",{PaddingLeft=UDim.new(0,l or 0),PaddingRight=UDim.new(0,r or 0),PaddingTop=UDim.new(0,t or 0),PaddingBottom=UDim.new(0,b or 0)},o)
end
local function tw(o,p,d)
    local ok,x=pcall(function() return TweenService:Create(o,TweenInfo.new(math.max(0.01,d or .18),Enum.EasingStyle.Quint,Enum.EasingDirection.Out),p) end)
    if ok then x:Play() end
end
local function txt(parent,text,size,color,font,props)
    local p={BackgroundTransparency=1,BorderSizePixel=0,Text=text or "",TextSize=size or 13,TextColor3=color or BASE.Text,Font=font or Enum.Font.Gotham,TextXAlignment=Enum.TextXAlignment.Left,TextYAlignment=Enum.TextYAlignment.Center}
    for k,v in pairs(props or {}) do p[k]=v end
    return inst("TextLabel",p,parent)
end
local function btn(parent,text,bg,fg,size)
    return inst("TextButton",{AutoButtonColor=false,Text=text or "",TextSize=size or 12,Font=Enum.Font.GothamMedium,TextColor3=fg or BASE.Text,BackgroundColor3=bg or BASE.Card,BorderSizePixel=0},parent)
end
local function safeCall(fn,...)
    if typeof(fn)=="function" then task.spawn(function() local ok,err=pcall(fn,...); if not ok then warn("[NovaPurple callback]",err) end end) end
end

function Nova:CreateWindow(cfg)
    cfg=cfg or {}
    local w=setmetatable({},Window)
    w.Name=cfg.Name or "NOVA PURPLE"; w.Subtitle=cfg.Subtitle or "Ultimate UI Library"
    w.Theme={}; for k,v in pairs(BASE) do w.Theme[k]=v end
    if typeof(cfg.Theme)=="table" then for k,v in pairs(cfg.Theme) do if w.Theme[k] and typeof(v)=="Color3" then w.Theme[k]=v end end end
    w.Settings={Radius=cfg.CornerRadius or 12,Duration=cfg.AnimationDuration or .18,Glow=cfg.Glow~=false}
    w.Tabs={}; w.Connections={}; w._destroyed=false
    local player=Players.LocalPlayer
    if not player then error("NovaPurple must run on the client.") end
    local pg=player:WaitForChild("PlayerGui")
    local previous=pg:FindFirstChild("NovaPurpleUI"); if previous then previous:Destroy() end
    w.Gui=inst("ScreenGui",{Name="NovaPurpleUI",ResetOnSpawn=false,IgnoreGuiInset=true,ZIndexBehavior=Enum.ZIndexBehavior.Sibling},pg)

    local main=inst("Frame",{Name="Window",AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.5),Size=cfg.Size or UDim2.fromOffset(1000,650),BackgroundColor3=w.Theme.Background,BorderSizePixel=0,ClipsDescendants=true},w.Gui)
    w.Main=main; round(main,w.Settings.Radius); w.MainStroke=outline(main,w.Theme.Accent,1.4,.1)
    w.Glow=inst("Frame",{Name="Glow",Position=UDim2.fromOffset(0,0),Size=UDim2.new(1,0,0,3),BackgroundColor3=w.Theme.Accent,BorderSizePixel=0,ZIndex=5},main)
    inst("UIGradient",{Color=ColorSequence.new({ColorSequenceKeypoint.new(0,w.Theme.Accent),ColorSequenceKeypoint.new(.5,w.Theme.Accent2),ColorSequenceKeypoint.new(1,w.Theme.Accent)}),Transparency=NumberSequence.new(0)},w.Glow)

    local header=inst("Frame",{Name="Header",Size=UDim2.new(1,0,0,82),BackgroundColor3=w.Theme.Panel,BorderSizePixel=0},main); w.Header=header
    txt(header,"N",25,w.Theme.Text,Enum.Font.GothamBlack,{Position=UDim2.fromOffset(20,17),Size=UDim2.fromOffset(44,44),TextColor3=w.Theme.Accent2})
    txt(header,w.Name,24,w.Theme.Text,Enum.Font.GothamBold,{Position=UDim2.fromOffset(66,17),Size=UDim2.new(.45,0,0,30)})
    txt(header,w.Subtitle,12,w.Theme.Muted,Enum.Font.Gotham,{Position=UDim2.fromOffset(68,46),Size=UDim2.new(.45,0,0,20)})
    local badge=inst("Frame",{AnchorPoint=Vector2.new(1,.5),Position=UDim2.new(1,-62,.5,0),Size=UDim2.fromOffset(245,34),BackgroundColor3=w.Theme.Card,BorderSizePixel=0},header); round(badge,17)
    txt(badge,"✦  Современная UI-библиотека",11,w.Theme.Accent2,Enum.Font.GothamMedium,{Position=UDim2.fromOffset(12,0),Size=UDim2.new(1,-24,1,0),TextXAlignment=Enum.TextXAlignment.Center})
    local close=btn(header,"×",w.Theme.Card,w.Theme.Accent2,23); close.Size=UDim2.fromOffset(34,34); close.Position=UDim2.new(1,-45,0,8); close.ZIndex=4; round(close,9)
    close.Activated:Connect(function() w:Destroy() end)

    local body=inst("Frame",{Name="Body",Position=UDim2.fromOffset(0,82),Size=UDim2.new(1,0,1,-82),BackgroundTransparency=1},main)
    local sidebar=inst("Frame",{Name="Sidebar",Size=UDim2.new(0,196,1,0),BackgroundColor3=w.Theme.Panel,BorderSizePixel=0},body); w.Sidebar=sidebar
    local tabScroll=inst("ScrollingFrame",{Name="Tabs",Position=UDim2.fromOffset(10,12),Size=UDim2.new(1,-20,1,-24),BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=2,ScrollBarImageColor3=w.Theme.Accent,AutomaticCanvasSize=Enum.AutomaticSize.Y,CanvasSize=UDim2.new()},sidebar); w.TabScroll=tabScroll
    inst("UIListLayout",{Padding=UDim.new(0,7),SortOrder=Enum.SortOrder.LayoutOrder},tabScroll)
    local separator=inst("Frame",{Position=UDim2.new(0,195,0,0),Size=UDim2.new(0,1,1,0),BackgroundColor3=w.Theme.Border,BorderSizePixel=0},body)
    local pageHost=inst("Frame",{Name="Pages",Position=UDim2.fromOffset(196,0),Size=UDim2.new(1,-196,1,0),BackgroundTransparency=1},body); w.PageHost=pageHost

    -- Drag only from header; resize from the lower-right grip.
    local dragging,dragStart,startPos=false,nil,nil
    header.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dragging=true; dragStart=i.Position; startPos=main.Position end
    end)
    header.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dragging=false end end)
    table.insert(w.Connections,UserInputService.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
            local d=i.Position-dragStart
            main.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+d.X,startPos.Y.Scale,startPos.Y.Offset+d.Y)
        end
    end))
    local grip=btn(main,"◢",w.Theme.Accent,w.Theme.Text,12); grip.Name="ResizeGrip"; grip.Size=UDim2.fromOffset(22,22); grip.AnchorPoint=Vector2.new(1,1); grip.Position=UDim2.new(1,0,1,0); grip.ZIndex=10; round(grip,5)
    local resizing,rStart,rSize=false,nil,nil
    grip.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then resizing=true;rStart=i.Position;rSize=main.AbsoluteSize end end)
    table.insert(w.Connections,UserInputService.InputChanged:Connect(function(i)
        if resizing and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
            local d=i.Position-rStart
            main.Size=UDim2.fromOffset(math.clamp(rSize.X+d.X,650,1300),math.clamp(rSize.Y+d.Y,430,900))
        end
    end))
    table.insert(w.Connections,UserInputService.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then resizing=false end end))
    w:_makeSettingsTab()
    return w
end

function Window:CreateTab(cfg)
    cfg=cfg or {}
    local t=setmetatable({},Tab); t.Window=self; t.Name=cfg.Name or ("Tab "..(#self.Tabs+1)); t.Order=#self.Tabs+1
    t.Button=btn(self.TabScroll,(cfg.Icon and cfg.Icon.."   " or "◇   ")..t.Name,self.Theme.Card,self.Theme.Muted,13)
    t.Button.Name="TabButton_"..t.Order; t.Button.Size=UDim2.new(1,0,0,42); t.Button.TextXAlignment=Enum.TextXAlignment.Left; t.Button.LayoutOrder=t.Order; pad(t.Button,14,8,0,0); round(t.Button,11)
    t.Page=inst("ScrollingFrame",{Name="Page_"..t.Order,Position=UDim2.fromOffset(0,0),Size=UDim2.fromScale(1,1),BackgroundTransparency=1,BorderSizePixel=0,Visible=false,ScrollBarThickness=3,ScrollBarImageColor3=self.Theme.Accent,AutomaticCanvasSize=Enum.AutomaticSize.Y,CanvasSize=UDim2.new()},self.PageHost)
    pad(t.Page,15,15,15,15)
    t.Columns=inst("Frame",{BackgroundTransparency=1,Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y},t.Page)
    t.ColumnLayout=inst("UIListLayout",{FillDirection=Enum.FillDirection.Horizontal,Padding=UDim.new(0,12),SortOrder=Enum.SortOrder.LayoutOrder,HorizontalAlignment=Enum.HorizontalAlignment.Left},t.Columns)
    t.Left=inst("Frame",{Name="LeftColumn",BackgroundTransparency=1,Size=UDim2.new(.56,-6,0,0),AutomaticSize=Enum.AutomaticSize.Y},t.Columns)
    t.Right=inst("Frame",{Name="RightColumn",BackgroundTransparency=1,Size=UDim2.new(.44,-6,0,0),AutomaticSize=Enum.AutomaticSize.Y},t.Columns)
    inst("UIListLayout",{Padding=UDim.new(0,10),SortOrder=Enum.SortOrder.LayoutOrder},t.Left)
    inst("UIListLayout",{Padding=UDim.new(0,10),SortOrder=Enum.SortOrder.LayoutOrder},t.Right)
    t._column="Left"; t._leftCount=0; t._rightCount=0
    t.Button.Activated:Connect(function() self:_select(t) end)
    table.insert(self.Tabs,t); self:_select(t)
    return t
end
function Window:_select(t)
    self.ActiveTab=t
    for _,x in ipairs(self.Tabs) do
        local active=x==t; x.Page.Visible=active
        tw(x.Button,{BackgroundColor3=active and self.Theme.Accent or self.Theme.Card,TextColor3=active and self.Theme.Text or self.Theme.Muted},self.Settings.Duration)
    end
end
function Tab:SetColumn(name) self._column=(name=="Right" and "Right" or "Left"); return self end
function Tab:_card(height,title,desc)
    local parent=self._column=="Right" and self.Right or self.Left
    local c=inst("Frame",{Size=UDim2.new(1,0,0,height or 60),BackgroundColor3=self.Window.Theme.Card,BorderSizePixel=0,ClipsDescendants=false},parent)
    round(c,self.Window.Settings.Radius); outline(c,self.Window.Theme.Border,1,.4)
    if title then txt(c,title,14,self.Window.Theme.Text,Enum.Font.GothamSemibold,{Position=UDim2.fromOffset(13,9),Size=UDim2.new(1,-26,0,21)}) end
    if desc then txt(c,desc,11,self.Window.Theme.Muted,Enum.Font.Gotham,{Position=UDim2.fromOffset(13,30),Size=UDim2.new(1,-26,0,17)}) end
    return c
end
function Tab:CreateSection(cfg)
    cfg=cfg or {}; local c=self:_card(34)
    txt(c,cfg.Name or "SECTION",12,self.Window.Theme.Accent2,Enum.Font.GothamBold,{Position=UDim2.fromOffset(13,0),Size=UDim2.new(1,-26,1,0)})
    return c
end
function Tab:CreateLabel(cfg)
    cfg=cfg or {}; local c=self:_card(40)
    txt(c,cfg.Text or cfg.Name or "Label",12,self.Window.Theme.Text,Enum.Font.Gotham,{Position=UDim2.fromOffset(13,0),Size=UDim2.new(1,-26,1,0)})
    return c
end
function Tab:CreateParagraph(cfg)
    cfg=cfg or {}; local c=self:_card(cfg.Height or 76,cfg.Title or cfg.Name or "Information",cfg.Content or cfg.Text or "")
    local l=c:FindFirstChildWhichIsA("TextLabel"); if l then l.TextWrapped=true;l.TextYAlignment=Enum.TextYAlignment.Top;l.Size=UDim2.new(1,-26,1,-38) end
    return c
end
function Tab:CreateButton(cfg)
    cfg=cfg or {}; local w=self.Window; local c=self:_card(58,cfg.Name or "Button",cfg.Description)
    local b=btn(c,cfg.ButtonText or "Нажать",w.Theme.Accent,w.Theme.Text,12); b.Position=UDim2.new(.43,0,0,14); b.Size=UDim2.new(.53,-12,0,32); round(b,9)
    b.Activated:Connect(function() tw(b,{BackgroundColor3=w.Theme.Accent2},.1); task.delay(.12,function() if b.Parent then tw(b,{BackgroundColor3=w.Theme.Accent},.15) end end); safeCall(cfg.Callback) end)
    return b
end
function Tab:CreateToggle(cfg)
    cfg=cfg or {}; local w=self.Window; local val=cfg.Default==true; local c=self:_card(56,cfg.Name or "Toggle",cfg.Description)
    local track=inst("Frame",{AnchorPoint=Vector2.new(1,.5),Position=UDim2.new(1,-14,.5,0),Size=UDim2.fromOffset(46,24),BackgroundColor3=val and w.Theme.Accent or w.Theme.Border,BorderSizePixel=0},c); round(track,12)
    local knob=inst("Frame",{Position=val and UDim2.new(1,-21,0,3) or UDim2.fromOffset(3,3),Size=UDim2.fromOffset(18,18),BackgroundColor3=Color3.new(1,1,1),BorderSizePixel=0},track); round(knob,9)
    local hit=btn(c,"",Color3.new(1,1,1),Color3.new(1,1,1),1); hit.BackgroundTransparency=1;hit.Size=UDim2.fromScale(1,1);hit.ZIndex=4
    local function set(v,quiet) val=v==true;tw(track,{BackgroundColor3=val and w.Theme.Accent or w.Theme.Border},w.Settings.Duration);tw(knob,{Position=val and UDim2.new(1,-21,0,3) or UDim2.fromOffset(3,3)},w.Settings.Duration);if not quiet then safeCall(cfg.Callback,val) end end
    hit.Activated:Connect(function() set(not val,false) end)
    return {Get=function() return val end,Set=function(_,v,q) set(v,q) end}
end
function Tab:CreateSlider(cfg)
    cfg=cfg or {}; local w=self.Window; local min,max=cfg.Min or 0,cfg.Max or 100;if max<=min then max=min+1 end
    local val=math.clamp(cfg.Default or min,min,max); local c=self:_card(76,cfg.Name or "Slider",cfg.Description)
    local valText=txt(c,tostring(val)..(cfg.Suffix or ""),12,w.Theme.Text,Enum.Font.GothamMedium,{Position=UDim2.new(1,-70,0,9),Size=UDim2.fromOffset(55,20),TextXAlignment=Enum.TextXAlignment.Right})
    local bar=inst("Frame",{Position=UDim2.new(0,13,0,51),Size=UDim2.new(1,-26,0,7),BackgroundColor3=w.Theme.Border,BorderSizePixel=0},c);round(bar,4)
    local fill=inst("Frame",{Size=UDim2.new((val-min)/(max-min),0,1,0),BackgroundColor3=w.Theme.Accent,BorderSizePixel=0},bar);round(fill,4)
    local knob=inst("Frame",{AnchorPoint=Vector2.new(.5,.5),Position=UDim2.new((val-min)/(max-min),0,.5,0),Size=UDim2.fromOffset(14,14),BackgroundColor3=w.Theme.Text,BorderSizePixel=0},bar);round(knob,7)
    local dragging=false
    local function setX(x,quiet)
        local a=math.clamp((x-bar.AbsolutePosition.X)/math.max(1,bar.AbsoluteSize.X),0,1);val=min+(max-min)*a
        if cfg.Decimals==0 then val=math.floor(val+.5) else val=math.floor(val*100+.5)/100 end
        a=(val-min)/(max-min);fill.Size=UDim2.new(a,0,1,0);knob.Position=UDim2.new(a,0,.5,0);valText.Text=tostring(val)..(cfg.Suffix or "")
        if not quiet then safeCall(cfg.Callback,val) end
    end
    bar.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dragging=true;setX(i.Position.X) end end)
    table.insert(w.Connections,UserInputService.InputChanged:Connect(function(i) if dragging and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then setX(i.Position.X) end end))
    table.insert(w.Connections,UserInputService.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dragging=false end end))
    return {Get=function() return val end,Set=function(_,v,q) val=math.clamp(tonumber(v) or min,min,max);local a=(val-min)/(max-min);fill.Size=UDim2.new(a,0,1,0);knob.Position=UDim2.new(a,0,.5,0);valText.Text=tostring(val)..(cfg.Suffix or "");if not q then safeCall(cfg.Callback,val) end end}
end
function Tab:CreateDropdown(cfg)
    cfg=cfg or {}; local w=self.Window;local options=cfg.Options or {};local val=cfg.Default or options[1] or "Select"
    local c=self:_card(58,cfg.Name or "Dropdown",cfg.Description)
    local b=btn(c,tostring(val).."  ﹀",w.Theme.CardHover,w.Theme.Text,11);b.Position=UDim2.new(.43,0,0,13);b.Size=UDim2.new(.53,-12,0,32);round(b,8)
    local pop=inst("Frame",{Visible=false,Position=UDim2.new(.43,0,1,2),Size=UDim2.new(.53,-12,0,0),BackgroundColor3=w.Theme.Panel,BorderSizePixel=0,ZIndex=20},c);round(pop,8);outline(pop,w.Theme.Border,1)
    local list=inst("UIListLayout",{Padding=UDim.new(0,3)},pop)
    local function rebuild()
        for _,x in ipairs(pop:GetChildren()) do if x:IsA("TextButton") then x:Destroy() end end
        for _,opt in ipairs(options) do local ob=btn(pop,tostring(opt),w.Theme.Card,w.Theme.Text,11);ob.Size=UDim2.new(1,-8,0,27);ob.Position=UDim2.fromOffset(4,0);ob.ZIndex=21;round(ob,6);ob.Activated:Connect(function() val=opt;b.Text=tostring(val).."  ﹀";pop.Visible=false;safeCall(cfg.Callback,val) end) end
        pop.Size=UDim2.new(.53,-12,0,math.min(#options*30+5,150))
    end
    rebuild();b.Activated:Connect(function() pop.Visible=not pop.Visible end)
    return {Get=function() return val end,Set=function(_,v,q) if table.find(options,v) then val=v;b.Text=tostring(v).."  ﹀";if not q then safeCall(cfg.Callback,val) end end end,Refresh=function(_,opts) options=opts or {};rebuild() end}
end
function Tab:CreateInput(cfg)
    cfg=cfg or {};local w=self.Window;local c=self:_card(58,cfg.Name or "Input",cfg.Description)
    local box=inst("TextBox",{Position=UDim2.new(.43,0,0,13),Size=UDim2.new(.53,-12,0,32),BackgroundColor3=w.Theme.CardHover,BorderSizePixel=0,Text=cfg.Default or "",PlaceholderText=cfg.Placeholder or "Введите текст...",PlaceholderColor3=w.Theme.Muted,TextColor3=w.Theme.Text,TextSize=11,Font=Enum.Font.Gotham,ClearTextOnFocus=false},c);round(box,8);pad(box,9,9,0,0)
    box.FocusLost:Connect(function(enter) safeCall(cfg.Callback,box.Text,enter) end)
    return {Get=function() return box.Text end,Set=function(_,v) box.Text=tostring(v) end}
end
function Tab:CreateColorPicker(cfg)
    cfg=cfg or {};local w=self.Window;local color=cfg.Default or w.Theme.Accent
    local c=self:_card(240,cfg.Name or "Цветовая палитра",cfg.Description or "Выбери свой любимый цвет")
    local swatches=inst("Frame",{Position=UDim2.fromOffset(12,55),Size=UDim2.new(1,-24,0,27),BackgroundTransparency=1},c)
    local colors={Color3.fromRGB(139,54,255),Color3.fromRGB(230,45,211),Color3.fromRGB(53,126,255),Color3.fromRGB(0,190,220),Color3.fromRGB(48,190,125),Color3.fromRGB(255,170,45),Color3.fromRGB(245,45,83)}
    inst("UIListLayout",{FillDirection=Enum.FillDirection.Horizontal,HorizontalAlignment=Enum.HorizontalAlignment.SpaceBetween,VerticalAlignment=Enum.VerticalAlignment.Center},swatches)
    local palette=inst("Frame",{Position=UDim2.fromOffset(12,94),Size=UDim2.new(1,-55,0,102),BackgroundColor3=color,BorderSizePixel=0},c);round(palette,7)
    inst("UIGradient",{Rotation=90,Color=ColorSequence.new(Color3.new(1,1,1),Color3.new(0,0,0)),Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,.03),NumberSequenceKeypoint.new(1,0)})},palette)
    local hue=inst("Frame",{AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-12,0,94),Size=UDim2.fromOffset(24,102),BorderSizePixel=0,BackgroundColor3=Color3.new(1,1,1)},c);round(hue,6)
    inst("UIGradient",{Rotation=90,Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(255,0,0)),ColorSequenceKeypoint.new(.17,Color3.fromRGB(255,255,0)),ColorSequenceKeypoint.new(.33,Color3.fromRGB(0,255,0)),ColorSequenceKeypoint.new(.5,Color3.fromRGB(0,255,255)),ColorSequenceKeypoint.new(.67,Color3.fromRGB(0,0,255)),ColorSequenceKeypoint.new(.83,Color3.fromRGB(255,0,255)),ColorSequenceKeypoint.new(1,Color3.fromRGB(255,0,0))})},hue)
    local hex=inst("TextBox",{Position=UDim2.fromOffset(12,205),Size=UDim2.new(1,-24,0,25),BackgroundColor3=w.Theme.Panel,BorderSizePixel=0,Text="#8B36FF",PlaceholderText="#RRGGBB",TextColor3=w.Theme.Text,TextSize=11,Font=Enum.Font.Gotham,ClearTextOnFocus=false},c);round(hex,7);pad(hex,9,9,0,0)
    local h,s,v=color:ToHSV()
    local function update(call)
        color=Color3.fromHSV(h,s,v);palette.BackgroundColor3=Color3.fromHSV(h,1,1);hex.Text=string.format("#%02X%02X%02X",math.floor(color.R*255),math.floor(color.G*255),math.floor(color.B*255))
        if call then safeCall(cfg.Callback,color) end
    end
    local function setColor(col,call) color=col;h,s,v=col:ToHSV();update(call) end
    for _,col in ipairs(colors) do local sw=btn(swatches,"",col,col,10);sw.Size=UDim2.fromOffset(22,22);round(sw,11);sw.Activated:Connect(function() setColor(col,true) end) end
    local function dragArea(obj,fn)
        local active=false
        obj.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then active=true;fn(i.Position) end end)
        table.insert(w.Connections,UserInputService.InputChanged:Connect(function(i) if active and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then fn(i.Position) end end))
        table.insert(w.Connections,UserInputService.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then active=false end end))
    end
    dragArea(palette,function(p) s=math.clamp((p.X-palette.AbsolutePosition.X)/palette.AbsoluteSize.X,0,1);v=1-math.clamp((p.Y-palette.AbsolutePosition.Y)/palette.AbsoluteSize.Y,0,1);update(true) end)
    dragArea(hue,function(p) h=math.clamp((p.Y-hue.AbsolutePosition.Y)/hue.AbsoluteSize.Y,0,1);update(true) end)
    hex.FocusLost:Connect(function()
        local raw=hex.Text:gsub("#","")
        if #raw==6 then local r,g,b=tonumber(raw:sub(1,2),16),tonumber(raw:sub(3,4),16),tonumber(raw:sub(5,6),16);if r and g and b then setColor(Color3.fromRGB(r,g,b),true) end end
    end)
    return {Get=function() return color end,Set=function(_,col,q) if typeof(col)=="Color3" then setColor(col,not q) end end}
end
function Tab:CreateNotification(cfg)
    cfg=cfg or {};return self.Window:Notify(cfg.Title or "Уведомление",cfg.Content or cfg.Text or "",cfg.Duration or 4)
end
function Window:Notify(title,message,duration)
    local n=inst("Frame",{AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,320,0,95),Size=UDim2.fromOffset(290,75),BackgroundColor3=self.Theme.Card,BorderSizePixel=0,ZIndex=50},self.Gui);round(n,12);outline(n,self.Theme.Accent,1.2)
    txt(n,"✦  "..title,13,self.Theme.Accent2,Enum.Font.GothamBold,{Position=UDim2.fromOffset(13,8),Size=UDim2.new(1,-26,0,22),ZIndex=51})
    txt(n,message,11,self.Theme.Muted,Enum.Font.Gotham,{Position=UDim2.fromOffset(13,32),Size=UDim2.new(1,-26,0,32),TextWrapped=true,ZIndex=51})
    tw(n,{Position=UDim2.new(1,-15,0,95)},self.Settings.Duration)
    task.delay(duration or 4,function() if n.Parent then tw(n,{Position=UDim2.new(1,320,0,95)},self.Settings.Duration);task.delay(.3,function() if n.Parent then n:Destroy() end end) end end)
    return n
end
function Window:SetSize(width,height) self.Main.Size=UDim2.fromOffset(math.clamp(width,650,1300),math.clamp(height,430,900)) end
function Window:SetAnimationDuration(v) self.Settings.Duration=math.clamp(tonumber(v) or .18,0,.8) end
function Window:SetCornerRadius(v)
    self.Settings.Radius=math.clamp(tonumber(v) or 12,0,24)
    for _,o in ipairs(self.Gui:GetDescendants()) do if o:IsA("UICorner") then o.CornerRadius=UDim.new(0,self.Settings.Radius) end end
end
function Window:SetGlow(v) self.Settings.Glow=v==true; self.MainStroke.Transparency=self.Settings.Glow and .1 or .65; self.MainStroke.Thickness=self.Settings.Glow and 1.5 or 1 end
function Window:SetTheme(theme)
    for k,v in pairs(theme or {}) do if self.Theme[k] and typeof(v)=="Color3" then self.Theme[k]=v end end
    local t=self.Theme
    self.Main.BackgroundColor3=t.Background;self.Header.BackgroundColor3=t.Panel;self.Sidebar.BackgroundColor3=t.Panel
    self.MainStroke.Color=t.Accent;self.Glow.BackgroundColor3=t.Accent
    for _,o in ipairs(self.Gui:GetDescendants()) do
        if o:IsA("UIStroke") then o.Color=t.Border end
        if o:IsA("ScrollingFrame") then o.ScrollBarImageColor3=t.Accent end
        if o:IsA("TextButton") and o.Name:match("^TabButton_") then
            local active=self.ActiveTab and o==self.ActiveTab.Button
            o.BackgroundColor3=active and t.Accent or t.Card;o.TextColor3=active and t.Text or t.Muted
        end
    end
end
function Window:Toggle() self.Main.Visible=not self.Main.Visible end
function Window:Destroy()
    if self._destroyed then return end;self._destroyed=true
    for _,c in ipairs(self.Connections) do pcall(function() c:Disconnect() end) end
    if self.Gui then self.Gui:Destroy() end
end
function Window:_makeSettingsTab()
    local t=self:CreateTab({Name="Настройки",Icon="⚙"})
    t:CreateSection({Name="ВНЕШНИЙ ВИД"})
    t:CreateSlider({Name="Закругления",Min=0,Max=24,Default=self.Settings.Radius,Decimals=0,Callback=function(v) self:SetCornerRadius(v) end})
    t:CreateSlider({Name="Скорость анимаций",Min=0,Max=.8,Default=self.Settings.Duration,Callback=function(v) self:SetAnimationDuration(v) end})
    t:CreateToggle({Name="Свечение окна",Default=self.Settings.Glow,Callback=function(v) self:SetGlow(v) end})
    t:CreateColorPicker({Name="Акцентный цвет",Default=self.Theme.Accent,Callback=function(c) self:SetTheme({Accent=c,Accent2=c}) end})
    t:CreateSection({Name="РАЗМЕР ОКНА"})
    t:CreateSlider({Name="Ширина",Min=650,Max=1300,Default=self.Main.AbsoluteSize.X,Decimals=0,Callback=function(v) self:SetSize(v,self.Main.AbsoluteSize.Y) end})
    t:CreateSlider({Name="Высота",Min=430,Max=900,Default=self.Main.AbsoluteSize.Y,Decimals=0,Callback=function(v) self:SetSize(self.Main.AbsoluteSize.X,v) end})
    t:CreateButton({Name="Закрыть меню",ButtonText="Закрыть",Callback=function() self:Destroy() end})
end

return Nova
