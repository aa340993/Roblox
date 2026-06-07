--// Rayfield 介面載入
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "風格代碼中心 / 販售檸檬",
    LoadingTitle = "風格代碼啟動",
    LoadingSubtitle = "作者：Claude",
    ConfigurationSaving = {
        Enabled = false,
    },
    KeySystem = false,
})

local MainTab = Window:CreateTab("主要功能", 4483362458)

--// 遊戲服務
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

--// 尋找玩家專屬大亨地盤
local userTycoon = (function()
    for _, v in pairs(workspace:GetChildren()) do
        if v:IsA("Folder") and v.Name:match("Tycoon%d") then
            if v:FindFirstChild("Owner") and v.Owner.Value == LocalPlayer then
                return v
            end
        end
    end
end)()

if not userTycoon then
    Rayfield:Notify({
        Title = "錯誤",
        Content = "未找到你的大亨地盤！",
        Duration = 5,
    })
    return
end

--// 功能開關變數
local AutoBuy = false
local AutoUpgrade = false
local AutoFruit = false
local AutoRebirth = false
local AutoEvolve = false
local AutoPowerLevel = false

-- 即時計數器（顯示各功能執行次數）
local stats = { buys = 0, upgrades = 0, fruit = 0, rebirths = 0, evolves = 0 }

local Buying = false

-- 自動購買建築：直接呼叫遠端函數，無需移動角色，瞬間購買
local function buyAllAffordable()
    for _, obj in ipairs(userTycoon.Purchases:GetDescendants()) do
        if obj:IsA("Model") then
            local shown = obj:GetAttribute("Shown")
            local purchased = obj:GetAttribute("Purchased")
            if shown == true and purchased ~= true then
                local purchase = obj:FindFirstChild("Purchase")
                if purchase and purchase:IsA("RemoteFunction") then
                    pcall(function() purchase:InvokeServer() end)
                    stats.buys = stats.buys + 1
                end
            end
        end
    end
end

task.spawn(function()
    while true do
        task.wait(0.05)

        if AutoBuy then
            pcall(buyAllAffordable)
        end
    end
end)

-- 自動升級建築：快取遠端函數、優化效能，自動升到無法升級為止
local upgradeRemotes  = {}
local upgradeLevel    = {}
local lastUpgradeScan = 0

local function refreshUpgradeRemotes()
    upgradeRemotes = {}
    upgradeLevel   = {}
    local purchases = userTycoon:FindFirstChild("Purchases")
    if not purchases then return end
    for _, obj in ipairs(purchases:GetDescendants()) do
        if obj:IsA("RemoteFunction") and obj.Name == "Upgrade" then
            upgradeRemotes[#upgradeRemotes + 1] = obj
        end
    end
end

task.spawn(function()
    while true do
        task.wait(0.25)

        if AutoUpgrade then
            if tick() - lastUpgradeScan > 3 then
                refreshUpgradeRemotes()
                lastUpgradeScan = tick()
            end

            for _, remote in ipairs(upgradeRemotes) do
                if remote.Parent then
                    local lvl = (upgradeLevel[remote] or 0) + 1
                    while lvl <= 100 do
                        local ok, res = pcall(function() return remote:InvokeServer(lvl) end)
                        if (not ok) or res == false then break end
                        upgradeLevel[remote] = lvl
                        stats.upgrades = stats.upgrades + 1
                        lvl = lvl + 1
                    end
                end
            end
        end
    end
end)

--// 自動強化等級
local function getPowerLevelRemote()
    local remotes = userTycoon:FindFirstChild("Remotes")
    return remotes and remotes:FindFirstChild("UpgradePowerLevel")
end

task.spawn(function()
    while true do
        task.wait(0.25)

        if AutoPowerLevel then
            local remote = getPowerLevelRemote()
            if remote then
                pcall(function() remote:InvokeServer() end)
            end
        end
    end
end)

--// 自動重生：判斷收益再重生，避免無意義刷重生
local RebirthGainMultiple = 1.0
local MinPotential        = 1
local RebirthCooldown     = 2
local RebirthTimeout      = 8
local rebirthBusy         = false

local function getRebirthRemote()
    local remotes = userTycoon:FindFirstChild("Remotes")
    return remotes and remotes:FindFirstChild("Rebirth")
end

local function getRebirthedSignal()
    local remotes = userTycoon:FindFirstChild("Remotes")
    return remotes and remotes:FindFirstChild("Rebirthed")
end

-- 解析遊戲大數值（千/百萬/十億等單位）
local NUM_SCALE = {
    thousand=1e3, million=1e6, billion=1e9, trillion=1e12, quadrillion=1e15,
    quintillion=1e18, sextillion=1e21, septillion=1e24, octillion=1e27,
    nonillion=1e30, decillion=1e33, undecillion=1e36, duodecillion=1e39,
    tredecillion=1e42, quattuordecillion=1e45, quindecillion=1e48,
    sexdecillion=1e51, septendecillion=1e54, octodecillion=1e57,
    novemdecillion=1e60, vigintillion=1e63,
    k=1e3, m=1e6, b=1e9, t=1e12, qd=1e15, qn=1e18, sx=1e21, sp=1e24,
}
local function parseNumber(s)
    if not s then return nil end
    s = tostring(s):gsub(",", ""):lower()
    local num = s:match("[%d%.]+")
    local val = num and tonumber(num)
    if not val then return nil end
    local word = s:match("[%d%.%s]+([a-z]+)")
    if word and NUM_SCALE[word] then val = val * NUM_SCALE[word] end
    return val
end

-- 讀取投資者數據
local function investorBody()
    local pg = LocalPlayer:FindFirstChildOfClass("PlayerGui")
    local r  = pg and pg:FindFirstChild("Rebirth")
    local im = r and r:FindFirstChild("InvestorsMenu")
    return im and im:FindFirstChild("Body")
end
local function readQuantity(frameName)
    local body  = investorBody()
    local frame = body and body:FindFirstChild(frameName)
    local q     = frame and frame:FindFirstChild("Quantity")
    return q and parseNumber(q.Text)
end
local function getCurrentInvestors()   return readQuantity("Amount")    or 0 end
local function getPotentialInvestors() return readQuantity("Potential")       end

task.spawn(function()
    while true do
        task.wait(0.5)

        if AutoRebirth and not rebirthBusy then
            local remote    = getRebirthRemote()
            local potential = getPotentialInvestors()
            local current   = getCurrentInvestors()

            local worthIt = remote and potential
                and potential >= MinPotential
                and potential >= current * RebirthGainMultiple

            if worthIt then
                rebirthBusy = true

                pcall(function()
                    local done   = false
                    local signal = getRebirthedSignal()
                    local conn
                    if signal and signal:IsA("RemoteEvent") then
                        conn = signal.OnClientEvent:Connect(function() done = true end)
                    end

                    remote:InvokeServer()
                    stats.rebirths = stats.rebirths + 1

                    local t = 0
                    while not done and t < RebirthTimeout do
                        task.wait(0.1)
                        t = t + 0.1
                    end
                    if conn then conn:Disconnect() end
                end)

                task.wait(RebirthCooldown)
                rebirthBusy = false
            end
        end
    end
end)

--// 自動進化：進化進度滿時自動執行，提升收益倍率
local EvolveAt        = 100
local EvolveCooldown  = 2
local EvolveTimeout   = 8
local evolveBusy      = false

local function getEvolveRemote()
    local remotes = userTycoon:FindFirstChild("Remotes")
    return remotes and remotes:FindFirstChild("Evolve")
end
local function getEvolvedSignal()
    local remotes = userTycoon:FindFirstChild("Remotes")
    return remotes and remotes:FindFirstChild("Evolved")
end
local function getEvolveProgress()
    local pg = LocalPlayer:FindFirstChildOfClass("PlayerGui")
    local r  = pg and pg:FindFirstChild("Rebirth")
    local em = r and r:FindFirstChild("EvolutionMenu")
    local body = em and em:FindFirstChild("Body")
    local p  = body and body:FindFirstChild("Progress")
    if not p then return nil end
    return tonumber(tostring(p.Text):match("[%d%.]+"))
end

task.spawn(function()
    while true do
        task.wait(0.5)

        if AutoEvolve and not evolveBusy then
            local remote   = getEvolveRemote()
            local progress = getEvolveProgress()

            if remote and progress and progress >= EvolveAt then
                evolveBusy = true
                pcall(function()
                    local done   = false
                    local signal = getEvolvedSignal()
                    local conn
                    if signal and signal:IsA("RemoteEvent") then
                        conn = signal.OnClientEvent:Connect(function() done = true end)
                    end
                    remote:InvokeServer()
                    stats.evolves = stats.evolves + 1
                    local t = 0
                    while not done and t < EvolveTimeout do
                        task.wait(0.1); t = t + 0.1
                    end
                    if conn then conn:Disconnect() end
                end)
                task.wait(EvolveCooldown)
                evolveBusy = false
            end
        end
    end
end)

--// 下水道功能：拉下所有閥門、拾取鑰匙
local function pullAllLevers()
    local char = LocalPlayer.Character
    local hrp  = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return 0 end

    local map   = workspace:FindFirstChild("Map")
    local sewer = map and map:FindFirstChild("Sewer")
    local root  = sewer or workspace

    local pulled = 0
    for _, o in ipairs(root:GetDescendants()) do
        if o:IsA("BasePart") and (o.Name == "Lever" or string.find(string.lower(o.Name), "lever", 1, true)) then
            pcall(function()
                firetouchinterest(hrp, o, 0)
                firetouchinterest(hrp, o, 1)
            end)
            pulled = pulled + 1
        end
    end

    -- 拾取下水道獎勵鑰匙
    if sewer then
        for _, o in ipairs(sewer:GetDescendants()) do
            if o:IsA("BasePart") and (o.Name == "VineKey" or o.Name == "UFOKey") then
                pcall(function()
                    firetouchinterest(hrp, o, 0)
                    firetouchinterest(hrp, o, 1)
                end)
            end
        end
    end

    return pulled
end

--// 藤蔓採集（下水道完整流程：拉閥→拿鑰匙→開門→採收）
local function touchPart(hrp, part)
    pcall(function()
        firetouchinterest(hrp, part, 0)
        firetouchinterest(hrp, part, 1)
    end)
end

local function doSewerRun()
    local char = LocalPlayer.Character
    local hrp  = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return false, "未載入角色" end

    local map   = workspace:FindFirstChild("Map")
    local sewer = map and map:FindFirstChild("Sewer")
    if not sewer then return false, "未找到下水道區域" end

    -- 1. 拉下所有閥門
    for _, o in ipairs(sewer:GetDescendants()) do
        if o:IsA("BasePart") and string.find(string.lower(o.Name), "lever", 1, true) then
            touchPart(hrp, o)
        end
    end

    -- 2. 拾取鑰匙
    for _, folderName in ipairs({ "CashVine", "SewerAlien" }) do
        local folder = sewer:FindFirstChild(folderName)
        if folder then
            for _, o in ipairs(folder:GetDescendants()) do
                if o:IsA("BasePart") and (o.Name == "VineKey" or o.Name == "UFOKey") then
                    touchPart(hrp, o)
                end
            end
        end
    end
    task.wait(0.3)

    local cashVine = sewer:FindFirstChild("CashVine")

    -- 3. 開啟藤蔓門
    if cashVine then
        local vineDoor = cashVine:FindFirstChild("VineDoor")
        if vineDoor then
            for _, o in ipairs(vineDoor:GetDescendants()) do
                if o:IsA("BasePart") then touchPart(hrp, o) end
            end
        end
    end
    task.wait(0.3)

    -- 4. 傳送並採收藤蔓獎勵
    if cashVine then
        local vineModel = cashVine:FindFirstChild("CashVine")
        if vineModel then
            local pivot = vineModel:GetPivot()
            pcall(function() hrp.CFrame = pivot + Vector3.new(0, 3, 0) end)
            task.wait(0.2)
            for _, o in ipairs(vineModel:GetDescendants()) do
                if o:IsA("BasePart") then touchPart(hrp, o) end
            end
        end
    end

    return true
end

--// 傳送到下水道外星人位置
local SEWER_ALIEN_POS = Vector3.new(-42, -41, 180)
local function teleportToAlien()
    local char = LocalPlayer.Character
    local hrp  = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return false, "未載入角色" end

    pcall(function() hrp.CFrame = CFrame.new(SEWER_ALIEN_POS) end)
    return true
end

--// 檸檬樹偵測 & 自動採集檸檬
local Trees = {}

local function addTree(obj)
    if obj:IsA("Model") and obj.Name == "LemonTree" then
        if not table.find(Trees, obj) then
            table.insert(Trees, obj)
        end
    end
end

local function removeTree(obj)
    local index = table.find(Trees, obj)
    if index then
        table.remove(Trees, index)
    end
end

-- 初始掃描所有檸檬樹
for _, v in ipairs(workspace:GetDescendants()) do
    addTree(v)
end

-- 即時監聽新樹生成/消失
workspace.DescendantAdded:Connect(addTree)
workspace.DescendantRemoving:Connect(removeTree)

-- 關閉樹木碰撞，避免卡模
local function noCollisionTree(tree)
    for _, obj in ipairs(tree:GetDescendants()) do
        if obj:IsA("BasePart") then
            obj.CanCollide = false
        end
    end
end

-- 傳送到檸檬樹位置
local function teleportToTree(tree)
    local character = LocalPlayer.Character
    if not character then
        return false
    end

    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then
        return false
    end

    local cf = tree:GetPivot()
    hrp.CFrame = cf + Vector3.new(0, 5, 0)
    return true
end

-- 採集檸檬果實
local function collectFruit(tree)
    noCollisionTree(tree)
    local success = teleportToTree(tree)
    if not success then
        return
    end

    for _, obj in ipairs(tree:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Name == "Fruit" then
            obj.CanCollide = false
            local clickPart = obj:FindFirstChild("ClickPart")
            if clickPart then
                local detector = clickPart:FindFirstChildOfClass("ClickDetector")
                if detector then
                    task.wait(0.45)
                    pcall(function()
                        fireclickdetector(detector)
                    end)
                    stats.fruit = stats.fruit + 1
                end
            end
        end
    end
end

-- 自動採果執行緒
task.spawn(function()
    while true do
        task.wait(0.1)
        if AutoFruit then
            for _, tree in ipairs(Trees) do
                if not AutoFruit then
                    break
                end
                if tree and tree.Parent then
                    pcall(function()
                        collectFruit(tree)
                    end)
                end
            end
        end
    end
end)

-- ========== 介面開關 / 按鈕（全中文） ==========
MainTab:CreateToggle({
    Name = "自動購買建築",
    CurrentValue = false,
    Flag = "AutoBuy",
    Callback = function(Value)
        AutoBuy = Value
        Rayfield:Notify({
            Title = "自動購買建築",
            Content = Value and "已開啟" or "已關閉",
            Duration = 3,
        })
    end,
})

MainTab:CreateToggle({
    Name = "自動升級建築",
    CurrentValue = false,
    Flag = "AutoUpgrade",
    Callback = function(Value)
        AutoUpgrade = Value
        Rayfield:Notify({
            Title = "自動升級建築",
            Content = Value and "已開啟" or "已關閉",
            Duration = 3,
        })
    end,
})

MainTab:CreateToggle({
    Name = "自動採集檸檬",
    CurrentValue = false,
    Flag = "AutoFruit",
    Callback = function(Value)
        AutoFruit = Value
        Rayfield:Notify({
            Title = "自動採集檸檬",
            Content = Value and "已開啟" or "已關閉",
            Duration = 3,
        })
    end,
})

MainTab:CreateToggle({
    Name = "自動重生",
    CurrentValue = false,
    Flag = "AutoRebirth",
    Callback = function(Value)
        AutoRebirth = Value
        if Value and not getRebirthRemote() then
            Rayfield:Notify({
                Title = "自動重生",
                Content = "找不到重生遠端函數！",
                Duration = 5,
            })
            return
        end
        Rayfield:Notify({
            Title = "自動重生",
            Content = Value and "已開啟" or "已關閉",
            Duration = 3,
        })
    end,
})

MainTab:CreateToggle({
    Name = "自動進化（收益×10）",
    CurrentValue = false,
    Flag = "AutoEvolve",
    Callback = function(Value)
        AutoEvolve = Value
        if Value and not getEvolveRemote() then
            Rayfield:Notify({
                Title = "自動進化",
                Content = "找不到進化遠端函數！",
                Duration = 5,
            })
            return
        end
        Rayfield:Notify({
            Title = "自動進化",
            Content = Value and "已開啟（進度滿時自動執行）" or "已關閉",
            Duration = 3,
        })
    end,
})

MainTab:CreateToggle({
    Name = "自動強化等級",
    CurrentValue = false,
    Flag = "AutoPowerLevel",
    Callback = function(Value)
        AutoPowerLevel = Value
        Rayfield:Notify({
            Title = "自動強化等級",
            Content = Value and "已開啟" or "已關閉",
            Duration = 3,
        })
    end,
})

MainTab:CreateButton({
    Name = "拉下所有下水道閥門",
    Callback = function()
        local n = pullAllLevers()
        Rayfield:Notify({
            Title = "閥門操作",
            Content = n > 0 and ("成功拉下 " .. n .. " 個閥門 + 拾取下水道鑰匙")
                or "未偵測到閥門（下水道未載入？）",
            Duration = 4,
        })
    end,
})

MainTab:CreateButton({
    Name = "藤蔓完整採收",
    Callback = function()
        Rayfield:Notify({ Title = "藤蔓採收", Content = "執行中...", Duration = 2 })
        task.spawn(function()
            local ok, err = doSewerRun()
            Rayfield:Notify({
                Title = "藤蔓採收",
                Content = ok and "執行完成！已拉閥、拿鑰匙、採收藤蔓"
                    or ("執行失敗：" .. tostring(err)),
                Duration = 5,
            })
        end)
    end,
})

MainTab:CreateButton({
    Name = "傳送到下水道外星人",
    Callback = function()
        local ok, err = teleportToAlien()
        Rayfield:Notify({
            Title = "位置傳送",
            Content = ok and "已傳送到下水道外星人（UFO）位置" or ("傳送失敗：" .. tostring(err)),
            Duration = 3,
        })
    end,
})

MainTab:CreateButton({
    Name = "關閉介面",
    Callback = function()
        Rayfield:Destroy()
    end,
})

--// 浮動狀態面板（可拖曳：顯示FPS、金錢、各功能執行次數與狀態）
task.spawn(function()
    local parent = LocalPlayer:FindFirstChildOfClass("PlayerGui")
    if not parent then
        local okh, hui = pcall(function() return gethui() end)
        parent = (okh and hui) or game:GetService("CoreGui")
    end
    pcall(function()
        local old = parent:FindFirstChild("AutoStatusGui")
        if old then old:Destroy() end
    end)

    local gui = Instance.new("ScreenGui")
    gui.Name = "AutoStatusGui"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.DisplayOrder = 9999
    gui.Parent = parent

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 200, 0, 168)
    frame.Position = UDim2.new(0, 10, 0, 90)
    frame.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
    frame.BackgroundTransparency = 0.1
    frame.BorderSizePixel = 0
    frame.Active = true
    frame.Parent = gui
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 24)
    title.BackgroundColor3 = Color3.fromRGB(38, 40, 54)
    title.BorderSizePixel = 0
    title.Text = "自動功能狀態"
    title.TextColor3 = Color3.fromRGB(120, 235, 140)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 13
    title.Parent = frame
    Instance.new("UICorner", title).CornerRadius = UDim.new(0, 8)

    local body = Instance.new("TextLabel")
    body.Size = UDim2.new(1, -12, 1, -30)
    body.Position = UDim2.new(0, 8, 0, 28)
    body.BackgroundTransparency = 1
    body.TextXAlignment = Enum.TextXAlignment.Left
    body.TextYAlignment = Enum.TextYAlignment.Top
    body.RichText = true
    body.Text = "載入中..."
    body.TextColor3 = Color3.fromRGB(235, 235, 245)
    body.Font = Enum.Font.Code
    body.TextSize = 12
    body.Parent = frame

    -- 視窗拖曳功能
    local UIS = game:GetService("UserInputService")
    local dragging, ds, sp
    title.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1
           or i.UserInputType == Enum.UserInputType.Touch then
            dragging, ds, sp = true, i.Position, frame.Position
            i.Changed:Connect(function()
                if i.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    UIS.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement
           or i.UserInputType == Enum.UserInputType.Touch) then
            local d = i.Position - ds
            frame.Position = UDim2.new(sp.X.Scale, sp.X.Offset + d.X, sp.Y.Scale, sp.Y.Offset + d.Y)
        end
    end)

    -- FPS 偵測
    local RunService = game:GetService("RunService")
    local frames, fps, fpsT = 0, 0, tick()
    RunService.RenderStepped:Connect(function()
        frames = frames + 1
        if tick() - fpsT >= 1 then fps, frames, fpsT = frames, 0, tick() end
    end)

    local function on(b) return b and "<font color='#7CFF7C'>開啟</font>" or "<font color='#777'>關閉</font>" end

    while gui.Parent do
        local cashStr = "?"
        local ls = LocalPlayer:FindFirstChild("leaderstats")
        local c  = ls and ls:FindFirstChild("Cash")
        if c then cashStr = tostring(c.Value) end

        body.Text = string.format(
            "畫面幀數：%d\n金錢：%s\n"
          .. "購買次數：%d  %s\n升級次數：%d  %s\n採果次數：%d  %s\n重生次數：%d  %s\n進化次數：%d  %s",
            fps, cashStr,
            stats.buys,     on(AutoBuy),
            stats.upgrades, on(AutoUpgrade),
            stats.fruit,    on(AutoFruit),
            stats.rebirths, on(AutoRebirth),
            stats.evolves,  on(AutoEvolve)
        )
        task.wait(0.25)
    end
end)

Rayfield:Notify({
    Title = "載入完成",
    Content = "大亨自動掛機腳本載入成功",
    Duration = 5,
})
