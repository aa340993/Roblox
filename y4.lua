local Players = game:GetService("Players")
local localPlr = Players.LocalPlayer
local gui = Instance.new("ScreenGui")
gui.Name = "TycoonTool"
gui.Parent = localPlr.PlayerGui

-- 主視窗
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0,200,0,205)
frame.Position = UDim2.new(0.01,0,0.2,0)
frame.BackgroundColor3 = Color3.new(0.1,0.1,0.1)
frame.BorderColor3 = Color3.new(0,0.7,1)
frame.BorderSizePixel = 2
frame.Parent = gui

-- 標題
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1,0,0,22)
title.BackgroundTransparency = 1
title.Text = "Tycoon8 工具"
title.TextColor3 = Color3.new(1,1,1)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 16
title.Parent = frame

-- 開關變數
local autoAscend = false
local autoEvolve = false
local waitTime = 1

-- 1.自動飛升開關
local toggleAscend = Instance.new("TextButton")
toggleAscend.Size = UDim2.new(0.9,0,0,24)
toggleAscend.Position = UDim2.new(0.05,0,0.17,0)
toggleAscend.BackgroundColor3 = Color3.new(0.2,0.2,0.2)
toggleAscend.Text = "自動飛升 [關]"
toggleAscend.TextColor3 = Color3.new(1,1,1)
toggleAscend.TextSize = 14
toggleAscend.Parent = frame

toggleAscend.MouseButton1Click:Connect(function()
    autoAscend = not autoAscend
    if autoAscend then
        toggleAscend.Text = "自動飛升 [開]"
        toggleAscend.BackgroundColor3 = Color3.new(0,0.4,0)
    else
        toggleAscend.Text = "自動飛升 [關]"
        toggleAscend.BackgroundColor3 = Color3.new(0.2,0.2,0.2)
    end
end)

-- 2.自動進化開關
local toggleEvolve = Instance.new("TextButton")
toggleEvolve.Size = UDim2.new(0.9,0,0,24)
toggleEvolve.Position = UDim2.new(0.05,0,0.36,0)
toggleEvolve.BackgroundColor3 = Color3.new(0.2,0.2,0.2)
toggleEvolve.Text = "自動進化 [關]"
toggleEvolve.TextColor3 = Color3.new(1,1,1)
toggleEvolve.TextSize = 14
toggleEvolve.Parent = frame

toggleEvolve.MouseButton1Click:Connect(function()
    autoEvolve = not autoEvolve
    if autoEvolve then
        toggleEvolve.Text = "自動進化 [開]"
        toggleEvolve.BackgroundColor3 = Color3.new(0,0.4,0)
    else
        toggleEvolve.Text = "自動進化 [關]"
        toggleEvolve.BackgroundColor3 = Color3.new(0.2,0.2,0.2)
    end
end)

-- 3.手動飛升一次
local btnAscend = Instance.new("TextButton")
btnAscend.Size = UDim2.new(0.9,0,0,24)
btnAscend.Position = UDim2.new(0.05,0,0.55,0)
btnAscend.BackgroundColor3 = Color3.new(0.25,0.25,0.25)
btnAscend.Text = "手動飛升一次"
btnAscend.TextColor3 = Color3.new(1,1,1)
btnAscend.TextSize = 14
btnAscend.Parent = frame

btnAscend.MouseButton1Click:Connect(function()
    pcall(function()
        workspace.Tycoon8.Remotes.Ascend:InvokeServer()
    end)
end)

-- 4.手動進化一次
local btnEvolve = Instance.new("TextButton")
btnEvolve.Size = UDim2.new(0.9,0,0,24)
btnEvolve.Position = UDim2.new(0.05,0,0.74,0)
btnEvolve.BackgroundColor3 = Color3.new(0.25,0.25,0.25)
btnEvolve.Text = "手動進化一次"
btnEvolve.TextColor3 = Color3.new(1,1,1)
btnEvolve.TextSize = 14
btnEvolve.Parent = frame

btnEvolve.MouseButton1Click:Connect(function()
    pcall(function()
        workspace.Tycoon8.Remotes.Evolve:InvokeServer()
    end)
end)

-- 5.手動重生一次（無自動）
local btnRebirth = Instance.new("TextButton")
btnRebirth.Size = UDim2.new(0.9,0,0,24)
btnRebirth.Position = UDim2.new(0.05,0,0.93,0)
btnRebirth.BackgroundColor3 = Color3.new(0.25,0.25,0.25)
btnRebirth.Text = "手動重生一次"
btnRebirth.TextColor3 = Color3.new(1,1,1)
btnRebirth.TextSize = 14
btnRebirth.Parent = frame

btnRebirth.MouseButton1Click:Connect(function()
    pcall(function()
        workspace.Tycoon8.Remotes.Rebirth:InvokeServer()
    end)
end)

-- 自動後台循環（只執行飛升、進化，不含重生）
task.spawn(function()
    while true do
        task.wait(waitTime)
        pcall(function()
            if autoAscend then
                workspace.Tycoon8.Remotes.Ascend:InvokeServer()
            end
            if autoEvolve then
                workspace.Tycoon8.Remotes.Evolve:InvokeServer()
            end
        end)
    end
end)
