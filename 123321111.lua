local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")

-- ===== GUI =====
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "CustomGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local GUI_WIDTH = 240

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, GUI_WIDTH, 0, 0)
MainFrame.Position = UDim2.new(0.5, -GUI_WIDTH/2, 0.5, -100)
MainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 38)
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(55, 55, 90)
MainStroke.Thickness = 1
MainStroke.Parent = MainFrame

-- ===== 標題列 =====
local TitleBar = Instance.new("Frame")
TitleBar.Name = "TitleBar"
TitleBar.Size = UDim2.new(1, 0, 0, 36)
TitleBar.BackgroundColor3 = Color3.fromRGB(14, 14, 30)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 10)
TitleCorner.Parent = TitleBar

local TitleFix = Instance.new("Frame")
TitleFix.Size = UDim2.new(1, 0, 0.5, 0)
TitleFix.Position = UDim2.new(0, 0, 0.5, 0)
TitleFix.BackgroundColor3 = Color3.fromRGB(14, 14, 30)
TitleFix.BorderSizePixel = 0
TitleFix.Parent = TitleBar

local TitleDot = Instance.new("Frame")
TitleDot.Size = UDim2.new(0, 8, 0, 8)
TitleDot.Position = UDim2.new(0, 12, 0.5, -4)
TitleDot.BackgroundColor3 = Color3.fromRGB(120, 100, 220)
TitleDot.BorderSizePixel = 0
TitleDot.Parent = TitleBar
local DotCorner = Instance.new("UICorner")
DotCorner.CornerRadius = UDim.new(1, 0)
DotCorner.Parent = TitleDot

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -90, 1, 0)
TitleLabel.Position = UDim2.new(0, 28, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "賣檸檬輔助"
TitleLabel.TextColor3 = Color3.fromRGB(200, 200, 230)
TitleLabel.TextSize = 13
TitleLabel.Font = Enum.Font.GothamMedium
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = TitleBar

-- 縮小按鈕
local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Size = UDim2.new(0, 26, 0, 26)
MinimizeBtn.Position = UDim2.new(1, -58, 0.5, -13)
MinimizeBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 70)
MinimizeBtn.BorderSizePixel = 0
MinimizeBtn.Text = "－"
MinimizeBtn.TextColor3 = Color3.fromRGB(180, 180, 220)
MinimizeBtn.TextSize = 14
MinimizeBtn.Font = Enum.Font.GothamBold
MinimizeBtn.Parent = TitleBar
local MinCorner = Instance.new("UICorner")
MinCorner.CornerRadius = UDim.new(0, 6)
MinCorner.Parent = MinimizeBtn

-- 關閉按鈕
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 26, 0, 26)
CloseBtn.Position = UDim2.new(1, -28, 0.5, -13)
CloseBtn.BackgroundColor3 = Color3.fromRGB(160, 40, 60)
CloseBtn.BorderSizePixel = 0
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(255, 200, 200)
CloseBtn.TextSize = 12
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Parent = TitleBar
local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 6)
CloseCorner.Parent = CloseBtn

-- ===== 內容區 =====
local Content = Instance.new("Frame")
Content.Name = "Content"
Content.Size = UDim2.new(1, 0, 1, -36)
Content.Position = UDim2.new(0, 0, 0, 36)
Content.BackgroundTransparency = 1
Content.Parent = MainFrame

local ContentLayout = Instance.new("UIListLayout")
ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
ContentLayout.Padding = UDim.new(0, 0)
ContentLayout.Parent = Content

local ContentPadding = Instance.new("UIPadding")
ContentPadding.PaddingBottom = UDim.new(0, 10)
ContentPadding.Parent = Content

-- ===== 縮小/關閉邏輯 =====
local isMinimized = false
local fullHeight = 0

local function UpdateHeight()
    local h = 36
    for _, v in pairs(Content:GetChildren()) do
        if v:IsA("GuiObject") then
            h = h + v.AbsoluteSize.Y
        end
    end
    fullHeight = h + 10
    if not isMinimized then
        TweenService:Create(MainFrame, TweenInfo.new(0.1), {Size = UDim2.new(0, GUI_WIDTH, 0, fullHeight)}):Play()
    end
end

ContentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(UpdateHeight)

MinimizeBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    if isMinimized then
        Content.Visible = false
        TweenService:Create(MainFrame, TweenInfo.new(0.15), {Size = UDim2.new(0, GUI_WIDTH, 0, 36)}):Play()
        MinimizeBtn.Text = "＋"
    else
        Content.Visible = true
        TweenService:Create(MainFrame, TweenInfo.new(0.15), {Size = UDim2.new(0, GUI_WIDTH, 0, fullHeight)}):Play()
        MinimizeBtn.Text = "－"
    end
end)

CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- ===== 工具函數 =====
local function AddSection(name)
    local SectionLabel = Instance.new("TextLabel")
    SectionLabel.Size = UDim2.new(1, 0, 0, 26)
    SectionLabel.BackgroundTransparency = 1
    SectionLabel.Text = name:upper()
    SectionLabel.TextColor3 = Color3.fromRGB(80, 80, 130)
    SectionLabel.TextSize = 10
    SectionLabel.Font = Enum.Font.GothamBold
    SectionLabel.TextXAlignment = Enum.TextXAlignment.Left
    SectionLabel.Parent = Content
    local P = Instance.new("UIPadding")
    P.PaddingLeft = UDim.new(0, 14)
    P.Parent = SectionLabel
end

local Toggles = {}
local Options = {}

local function AddToggle(labelText, id, default, callback)
    local Row = Instance.new("Frame")
    Row.Name = id
    Row.Size = UDim2.new(1, 0, 0, 40)
    Row.BackgroundTransparency = 1
    Row.Parent = Content

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -56, 1, 0)
    Label.Position = UDim2.new(0, 14, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = labelText
    Label.TextColor3 = Color3.fromRGB(185, 185, 215)
    Label.TextSize = 12
    Label.Font = Enum.Font.Gotham
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.TextWrapped = true
    Label.Parent = Row

    local Track = Instance.new("Frame")
    Track.Size = UDim2.new(0, 34, 0, 18)
    Track.Position = UDim2.new(1, -46, 0.5, -9)
    Track.BackgroundColor3 = Color3.fromRGB(45, 45, 75)
    Track.BorderSizePixel = 0
    Track.Parent = Row
    local TC = Instance.new("UICorner")
    TC.CornerRadius = UDim.new(1, 0)
    TC.Parent = Track

    local Thumb = Instance.new("Frame")
    Thumb.Size = UDim2.new(0, 12, 0, 12)
    Thumb.Position = UDim2.new(0, 3, 0.5, -6)
    Thumb.BackgroundColor3 = Color3.fromRGB(110, 110, 160)
    Thumb.BorderSizePixel = 0
    Thumb.Parent = Track
    local ThC = Instance.new("UICorner")
    ThC.CornerRadius = UDim.new(1, 0)
    ThC.Parent = Thumb

    local value = default or false
    local toggleObj = {}
    toggleObj.Value = value

    local function setState(v)
        value = v
        toggleObj.Value = v
        TweenService:Create(Track, TweenInfo.new(0.15), {
            BackgroundColor3 = v and Color3.fromRGB(110, 90, 210) or Color3.fromRGB(45, 45, 75)
        }):Play()
        TweenService:Create(Thumb, TweenInfo.new(0.15), {
            Position = v and UDim2.new(0, 19, 0.5, -6) or UDim2.new(0, 3, 0.5, -6),
            BackgroundColor3 = v and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(110, 110, 160)
        }):Play()
        if callback then callback(v) end
    end

    toggleObj.SetValue = setState
    toggleObj.GetValue = function() return value end
    setState(value)

    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(1, 0, 1, 0)
    Button.BackgroundTransparency = 1
    Button.Text = ""
    Button.Parent = Row
    Button.MouseButton1Click:Connect(function()
        setState(not value)
    end)
    Button.MouseEnter:Connect(function()
        Row.BackgroundColor3 = Color3.fromRGB(25, 25, 50)
        Row.BackgroundTransparency = 0
    end)
    Button.MouseLeave:Connect(function()
        Row.BackgroundTransparency = 1
    end)

    Toggles[id] = toggleObj
    return toggleObj
end

local function AddSlider(labelText, id, min, max, default, callback)
    local Row = Instance.new("Frame")
    Row.Name = id
    Row.Size = UDim2.new(1, 0, 0, 44)
    Row.BackgroundTransparency = 1
    Row.Parent = Content

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -46, 0, 20)
    Label.Position = UDim2.new(0, 14, 0, 2)
    Label.BackgroundTransparency = 1
    Label.Text = labelText
    Label.TextColor3 = Color3.fromRGB(185, 185, 215)
    Label.TextSize = 12
    Label.Font = Enum.Font.Gotham
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Row

    local ValueLabel = Instance.new("TextLabel")
    ValueLabel.Size = UDim2.new(0, 38, 0, 20)
    ValueLabel.Position = UDim2.new(1, -46, 0, 2)
    ValueLabel.BackgroundTransparency = 1
    ValueLabel.Text = tostring(default) .. "秒"
    ValueLabel.TextColor3 = Color3.fromRGB(140, 130, 200)
    ValueLabel.TextSize = 11
    ValueLabel.Font = Enum.Font.GothamMedium
    ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
    ValueLabel.Parent = Row

    local Track = Instance.new("Frame")
    Track.Size = UDim2.new(1, -28, 0, 6)
    Track.Position = UDim2.new(0, 14, 0, 28)
    Track.BackgroundColor3 = Color3.fromRGB(45, 45, 75)
    Track.BorderSizePixel = 0
    Track.Parent = Row
    local TrC = Instance.new("UICorner")
    TrC.CornerRadius = UDim.new(1, 0)
    TrC.Parent = Track

    local Fill = Instance.new("Frame")
    Fill.BackgroundColor3 = Color3.fromRGB(110, 90, 210)
    Fill.BorderSizePixel = 0
    Fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    Fill.Parent = Track
    local FC = Instance.new("UICorner")
    FC.CornerRadius = UDim.new(1, 0)
    FC.Parent = Fill

    local Knob = Instance.new("Frame")
    Knob.Size = UDim2.new(0, 12, 0, 12)
    Knob.AnchorPoint = Vector2.new(0.5, 0.5)
    Knob.Position = UDim2.new((default - min) / (max - min), 0, 0.5, 0)
    Knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Knob.BorderSizePixel = 0
    Knob.ZIndex = 2
    Knob.Parent = Track
    local KC = Instance.new("UICorner")
    KC.CornerRadius = UDim.new(1, 0)
    KC.Parent = Knob

    local value = default
    local sliderObj = {Value = value}

    local function setFromAlpha(alpha)
        alpha = math.clamp(alpha, 0, 1)
        local v = math.floor(min + (max - min) * alpha + 0.5)
        value = v
        sliderObj.Value = v
        Fill.Size = UDim2.new(alpha, 0, 1, 0)
        Knob.Position = UDim2.new(alpha, 0, 0.5, 0)
        ValueLabel.Text = tostring(v) .. "秒"
        if callback then callback(v) end
    end

    sliderObj.SetValue = function(v)
        setFromAlpha((v - min) / (max - min))
    end

    local dragging = false
    local function updateFromInput(input)
        local relX = input.Position.X - Track.AbsolutePosition.X
        local alpha = relX / Track.AbsoluteSize.X
        setFromAlpha(alpha)
    end

    Track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            updateFromInput(input)
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            updateFromInput(input)
        end
    end)
    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    Options[id] = sliderObj
    return sliderObj
end

local function AddDivider()
    local D = Instance.new("Frame")
    D.Size = UDim2.new(1, -28, 0, 1)
    D.BackgroundColor3 = Color3.fromRGB(40, 40, 70)
    D.BorderSizePixel = 0
    D.Parent = Content
end

-- StatusBar
local StatusBar = Instance.new("Frame")
StatusBar.Size = UDim2.new(1, 0, 0, 26)
StatusBar.BackgroundColor3 = Color3.fromRGB(14, 14, 30)
StatusBar.BorderSizePixel = 0
StatusBar.Parent = Content

local StatusLayout = Instance.new("UIListLayout")
StatusLayout.FillDirection = Enum.FillDirection.Horizontal
StatusLayout.VerticalAlignment = Enum.VerticalAlignment.Center
StatusLayout.Padding = UDim.new(0, 0)
StatusLayout.Parent = StatusBar

local StatusPad = Instance.new("UIPadding")
StatusPad.PaddingLeft = UDim.new(0, 4)
StatusPad.Parent = StatusBar

local StatusLabels = {}
local function AddStatus(id, offText)
    local Wrap = Instance.new("Frame")
    Wrap.Size = UDim2.new(0, 58, 1, 0)
    Wrap.BackgroundTransparency = 1
    Wrap.Parent = StatusBar

    local Dot = Instance.new("Frame")
    Dot.Size = UDim2.new(0, 5, 0, 5)
    Dot.Position = UDim2.new(0, 3, 0.5, -2.5)
    Dot.BackgroundColor3 = Color3.fromRGB(50, 50, 80)
    Dot.BorderSizePixel = 0
    Dot.Parent = Wrap
    local DC = Instance.new("UICorner")
    DC.CornerRadius = UDim.new(1, 0)
    DC.Parent = Dot

    local Txt = Instance.new("TextLabel")
    Txt.Size = UDim2.new(1, -12, 1, 0)
    Txt.Position = UDim2.new(0, 12, 0, 0)
    Txt.BackgroundTransparency = 1
    Txt.Text = offText
    Txt.TextColor3 = Color3.fromRGB(70, 70, 110)
    Txt.TextSize = 8
    Txt.Font = Enum.Font.Gotham
    Txt.TextXAlignment = Enum.TextXAlignment.Left
    Txt.Parent = Wrap

    StatusLabels[id] = {Dot = Dot, Txt = Txt}
end

local function SetStatus(id, active, activeText, offText)
    local s = StatusLabels[id]
    if not s then return end
    TweenService:Create(s.Dot, TweenInfo.new(0.2), {
        BackgroundColor3 = active and Color3.fromRGB(110, 90, 210) or Color3.fromRGB(50, 50, 80)
    }):Play()
    s.Txt.Text = active and activeText or offText
    s.Txt.TextColor3 = active and Color3.fromRGB(140, 130, 200) or Color3.fromRGB(70, 70, 110)
end

-- ===== 拖曳 =====
local dragging, dragStart, startPos
TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
    end
end)
UIS.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

-- 右 Ctrl 隱藏/顯示
UIS.InputBegan:Connect(function(input, gp)
    if not gp and input.KeyCode == Enum.KeyCode.RightControl then
        ScreenGui.Enabled = not ScreenGui.Enabled
    end
end)

-- ===== 找 Tycoon =====
local OwnerTycoon = nil
while OwnerTycoon == nil do
    task.wait(0.5)
    for _, v in pairs(game.Workspace:GetChildren()) do
        if v.Name:match("Tycoon") then
            local Owner = v:FindFirstChild("Owner")
            if Owner and Owner.Value == LocalPlayer then
                OwnerTycoon = v
                break
            end
        end
    end
end

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Balance = require(ReplicatedStorage.Balance)
local Tycoon = require(ReplicatedStorage.Modules.Tycoon.Tycoon)
local TycoonAnalyzer = require(ReplicatedStorage.Modules.Tycoon.Component.TycoonAnalyzer)
local TycoonRoot = Tycoon.getLocal()
local Purchases = TycoonRoot:GetComponent(TycoonAnalyzer):GetPurchases()

local AutoUpgradeOptions = {
    "Lemon Republic", "LemonX", "LemonDash", "Lemon Robotics",
    "Lemon Stand", "Lemon Trading", "Lemon Depot", "Lemon Labs"
}

local Trees = {}
local function addTree(obj)
    if obj:IsA("Model") and obj.Name == "LemonTree" then
        if not table.find(Trees, obj) then table.insert(Trees, obj) end
    end
end
local function removeTree(obj)
    local index = table.find(Trees, obj)
    if index then table.remove(Trees, index) end
end
for _, v in ipairs(workspace:GetDescendants()) do addTree(v) end
workspace.DescendantAdded:Connect(addTree)
workspace.DescendantRemoving:Connect(removeTree)

-- ===== UI 建構 =====
AddSection("自動化")

AddToggle("自動升級收入", "AutoUpgrade", false, function(v)
    SetStatus("upgrade", v, "升級中", "升級關閉")
end)
AddDivider()
AddToggle("自動購買按鈕", "AutoPurchase", false, function(v)
    SetStatus("purchase", v, "購買中", "購買關閉")
end)
AddDivider()
AddToggle("自動喚醒收入", "AutoWake", false, function(v)
    SetStatus("wake", v, "喚醒中", "喚醒關閉")
end)
AddDivider()
AddToggle("自動採集水果", "AutoFruit", false, function(v)
    SetStatus("fruit", v, "採集中", "採集關閉")
end)
AddDivider()
AddToggle("自動收集藤蔓", "AutoVine", false, function(v)
    SetStatus("vine", v, "收集中", "收集關閉")
end)
AddSlider("藤蔓間隔秒數", "VineInterval", 1, 60, 5, function(v) end)
AddDivider()
AddToggle("自動接聽電話", "AutoPhone", false, function(v)
    SetStatus("phone", v, "接聽中", "電話關閉")
end)
AddSlider("電話間隔秒數", "PhoneInterval", 1, 60, 10, function(v) end)

AddSection("工具")

AddToggle("AFK 掛機防踢", "AFK", false, function(v)
    SetStatus("afk", v, "掛機中", "AFK關閉")
end)
AddDivider()
AddToggle("FPS 優化", "FPSOpt", false, function(v)
    SetStatus("fps", v, "優化中", "FPS關閉")
    if v then
        -- 關閉高消耗渲染設定
        Lighting.GlobalShadows = false
        Lighting.FogEnd = 100000
        workspace.StreamingEnabled = pcall(function()
            workspace.StreamingEnabled = false
        end) and false or workspace.StreamingEnabled
        -- 嘗試設定 FPS 上限（部分執行器支援）
        pcall(function() setfpscap(144) end)
    else
        Lighting.GlobalShadows = true
        pcall(function() setfpscap(60) end)
    end
end)

-- StatusBar
AddStatus("upgrade", "升級關閉")
AddStatus("purchase", "購買關閉")
AddStatus("wake", "喚醒關閉")
AddStatus("fruit", "採集關閉")
AddStatus("vine", "收集關閉")
AddStatus("phone", "電話關閉")
AddStatus("afk", "AFK關閉")
AddStatus("fps", "FPS關閉")

UpdateHeight()

-- ===== 功能迴圈 =====

-- 自動購買
task.spawn(function()
    while true do
        task.wait(0.1)
        if not Toggles.AutoPurchase.Value then continue end
        for _, purchase in pairs(Balance.PurchaseOrder) do
            local buttonTable = Purchases[purchase]
            if buttonTable and (buttonTable:IsEnabled() and not buttonTable:IsPurchased()) then
                buttonTable:TryPurchaseAsync()
            end
        end
    end
end)

-- 自動升級
task.spawn(function()
    while true do
        task.wait(0.1)
        if not Toggles.AutoUpgrade.Value then continue end
        for _, v in pairs(OwnerTycoon.Purchases:GetDescendants()) do
            if v.Name == "Upgrade" then
                if v.Parent and table.find(AutoUpgradeOptions, v.Parent.Name) then
                    pcall(function()
                        v:InvokeServer(1)
                        v:InvokeServer(5)
                        v:InvokeServer(25)
                        v:InvokeServer(100)
                        v:InvokeServer(500)
                    end)
                end
            end
        end
    end
end)

-- 自動喚醒
task.spawn(function()
    while wait(1) do
        if not Toggles.AutoWake.Value then continue end
        pcall(function()
            OwnerTycoon.Remotes.WakeIncomeStream:InvokeServer("LemonStand")
            OwnerTycoon.Remotes.WakeIncomeStream:InvokeServer("LemonX")
            OwnerTycoon.Remotes.WakeIncomeStream:InvokeServer("LemonRepublic")
            OwnerTycoon.Remotes.WakeIncomeStream:InvokeServer("LemonDash")
            OwnerTycoon.Remotes.WakeIncomeStream:InvokeServer("LemonRobotics")
            OwnerTycoon.Remotes.WakeIncomeStream:InvokeServer("LemonTrading")
            OwnerTycoon.Remotes.WakeIncomeStream:InvokeServer("LemonDepot")
            OwnerTycoon.Remotes.WakeIncomeStream:InvokeServer("LemonLabs")
        end)
    end
end)

-- 自動採集水果
task.spawn(function()
    while true do
        task.wait(0.1)
        if not Toggles.AutoFruit.Value then continue end
        for _, tree in ipairs(Trees) do
            if not Toggles.AutoFruit.Value then break end
            if not (tree and tree.Parent) then continue end
            pcall(function()
                for _, obj in ipairs(tree:GetDescendants()) do
                    if obj:IsA("BasePart") then obj.CanCollide = false end
                end
                local char = LocalPlayer.Character
                if not char then return end
                local hrp = char:FindFirstChild("HumanoidRootPart")
                if not hrp then return end
                hrp.CFrame = tree:GetPivot() + Vector3.new(0, 5, 0)
                task.wait(0.05)
                for _, obj in ipairs(tree:GetDescendants()) do
                    if not Toggles.AutoFruit.Value then break end
                    if obj:IsA("BasePart") and obj.Name == "Fruit" then
                        obj.CanCollide = false
                        local clickPart = obj:FindFirstChild("ClickPart")
                        if clickPart then
                            local detector = clickPart:FindFirstChildOfClass("ClickDetector")
                            if detector then
                                hrp.CFrame = clickPart.CFrame + Vector3.new(0, 3, 0)
                                task.wait(0.05)
                                pcall(function() fireclickdetector(detector) end)
                                task.wait(0.05)
                            end
                        end
                    end
                end
            end)
        end
    end
end)

-- 自動收集藤蔓
task.spawn(function()
    while true do
        local interval = math.clamp(Options.VineInterval.Value, 1, 60)
        task.wait(interval)
        if not Toggles.AutoVine.Value then continue end
        pcall(function()
            workspace.Map.Sewer.CashVine.CashVine.Use:InvokeServer()
        end)
    end
end)

-- 自動接聽電話
task.spawn(function()
    while true do
        local interval = math.clamp(Options.PhoneInterval.Value, 1, 60)
        task.wait(interval)
        if not Toggles.AutoPhone.Value then continue end
        pcall(function()
            OwnerTycoon.Remotes.PhoneOffer:FireServer("Accept")
        end)
    end
end)

-- AFK 掛機防踢（虛假輸入，角色完全不動）
local VirtualUser = game:GetService("VirtualUser")
LocalPlayer.Idled:Connect(function()
    if not Toggles.AFK.Value then return end
    VirtualUser:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    task.wait(0.1)
    VirtualUser:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
end)
