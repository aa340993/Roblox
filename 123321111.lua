--==================================================================
-- 🍋 LEMON HUB — 自動存讀永久版
-- 機制：開關切換自動存、開腳本自動載、關閉自動備份
-- 移除：自動撿金幣、離線收益、小遊戲、舊電話、DataStore、手動存載按鈕
-- 電話間隔0.1，功能完整分頁
-- 快捷鍵：右Ctrl隱藏視窗，—最小化，✕關閉
--==================================================================
if _G.LemonFarm and _G.LemonFarm.Destroy then pcall(_G.LemonFarm.Destroy) end
local Players=game:GetService("Players")
local LocalPlayer=Players.LocalPlayer
local HttpService=game:GetService("HttpService")
local CollectionService=game:GetService("CollectionService")
local UserInputService=game:GetService("UserInputService")
local TweenService=game:GetService("TweenService")
local RS=game:GetService("ReplicatedStorage")
local VirtualUser=game:GetService("VirtualUser")
local lp=LocalPlayer
local POWERS={"UpgradeStack","BuyNext","Manage","WalkSpeed","ClickFruitValue"}

-- 自動升級廠房列表
local AutoUpgradeOptions = {
    "Lemon Republic", "LemonX", "LemonDash", "Lemon Robotics",
    "Lemon Stand", "Lemon Trading", "Lemon Depot", "Lemon Labs"
}
-- 檸檬樹緩存
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

local function getMyTycoon()
    for _,f in ipairs(workspace:GetChildren()) do
        if f:IsA("Folder") and f.Name:match("^Tycoon%d+$") then
            local o=f:FindFirstChild("Owner")
            if o and o:IsA("ObjectValue") and o.Value==lp then return f end
        end
    end
end
local function rem(myT,name) if myT and myT:FindFirstChild("Remotes") then return myT.Remotes:FindFirstChild(name) end end

-- 預設設定
local S={
    buy=false,
    powers=false,
    ascend=false,
    evolve=false,
    wake=false,
    antiafk=false,
    autoUpgrade=false,
    autoFruit=false,
    autoVine=false,
    autoPhoneNew=false,
    vineInterval=5,
    phoneInterval=0.1,
    cUp=0,
    cBuy=0
}

-- 自動存讀核心函數
local function SaveConfig()
    local data = {
        buy=S.buy,
        powers=S.powers,
        ascend=S.ascend,
        evolve=S.evolve,
        wake=S.wake,
        antiafk=S.antiafk,
        autoUpgrade=S.autoUpgrade,
        autoFruit=S.autoFruit,
        autoVine=S.autoVine,
        autoPhoneNew=S.autoPhoneNew,
        vineInterval=S.vineInterval,
        phoneInterval=S.phoneInterval
    }
    local ok,str = pcall(HttpService.JSONEncode, HttpService, data)
    if ok then pcall(setclipboard, str) end
end

local function LoadConfig()
    local ok,clip = pcall(getclipboard)
    if not ok or clip == "" then return end
    local ok2,data = pcall(HttpService.JSONDecode, HttpService, clip)
    if not ok2 or type(data) ~= "table" then return end
    for k,v in pairs(data) do
        if S[k] ~= nil then S[k] = v end
    end
end

-- 載入上次配置（腳本一打開自動執行）
LoadConfig()

-- UI配色
local ACCENT=Color3.fromRGB(120,220,90)
local ACCENT2=Color3.fromRGB(255,214,60)
local BG=Color3.fromRGB(18,19,24)
local BG2=Color3.fromRGB(26,28,35)
local BG3=Color3.fromRGB(34,37,46)
local TXT=Color3.fromRGB(236,238,243)
local SUB=Color3.fromRGB(150,155,168)

-- UI工具函數
local function corner(p,r) local c=Instance.new("UICorner") c.CornerRadius=UDim.new(0,r) c.Parent=p return c end
local function pad(p,t,b,l,r) local u=Instance.new("UIPadding") u.PaddingTop=UDim.new(0,t) u.PaddingBottom=UDim.new(0,b) u.PaddingLeft=UDim.new(0,l) u.PaddingRight=UDim.new(0,r) u.Parent=p return u end
local function gradient(p,c1,c2,rot) local g=Instance.new("UIGradient") g.Color=ColorSequence.new(c1,c2) g.Rotation=rot or 0 g.Parent=p return g end

-- 建立GUI
local parent=(gethui and gethui()) or game:GetService("CoreGui")
local gui=Instance.new("ScreenGui"); gui.Name="LemonHub"; gui.ResetOnSpawn=false
gui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling; gui.IgnoreGuiInset=true; gui.Parent=parent

local main=Instance.new("Frame"); main.Size=UDim2.fromOffset(500,330); main.Position=UDim2.fromScale(0.5,0.5)
main.AnchorPoint=Vector2.new(0.5,0.5); main.BackgroundColor3=BG; main.BorderSizePixel=0; main.ClipsDescendants=true; main.Parent=gui
corner(main,16)
local mst=Instance.new("UIStroke",main); mst.Color=Color3.fromRGB(60,64,76); mst.Thickness=1; mst.Transparency=0.2

local shadow=Instance.new("ImageLabel"); shadow.BackgroundTransparency=1; shadow.Image="rbxassetid://5554236805"
shadow.ImageColor3=Color3.new(0,0,0); shadow.ImageTransparency=0.45; shadow.ScaleType=Enum.ScaleType.Slice
shadow.SliceCenter=Rect.new(23,23,277,277); shadow.Size=UDim2.new(1,40,1,40); shadow.Position=UDim2.fromOffset(-20,-16)
shadow.ZIndex=0; shadow.Parent=main

-- 標題列
local header=Instance.new("Frame"); header.Size=UDim2.new(1,0,0,56); header.BackgroundColor3=BG2; header.BorderSizePixel=0; header.Parent=main
corner(header,16)
local hfix=Instance.new("Frame"); hfix.Size=UDim2.new(1,0,0,16); hfix.Position=UDim2.new(0,0,1,-16); hfix.BackgroundColor3=BG2; hfix.BorderSizePixel=0; hfix.Parent=header

local logo=Instance.new("TextLabel"); logo.Size=UDim2.fromOffset(40,40); logo.Position=UDim2.fromOffset(14,8); logo.BackgroundTransparency=1
logo.Font=Enum.Font.GothamBold; logo.Text="🍋"; logo.TextSize=28; logo.Parent=header

local titleC=Instance.new("TextLabel"); titleC.Size=UDim2.fromOffset(200,22); titleC.Position=UDim2.fromOffset(58,11); titleC.BackgroundTransparency=1
titleC.Font=Enum.Font.GothamBold; titleC.TextSize=19; titleC.TextColor3=TXT; titleC.Text="檸檬輔助工具"; titleC.TextXAlignment=Enum.TextXAlignment.Left; titleC.Parent=header
gradient(titleC,ACCENT2,ACCENT,0)

local cashL=Instance.new("TextLabel"); cashL.Size=UDim2.fromOffset(280,16); cashL.Position=UDim2.fromOffset(58,32); cashL.BackgroundTransparency=1
cashL.Font=Enum.Font.GothamMedium; cashL.TextSize=12; cashL.Text="—"; cashL.TextXAlignment=Enum.TextXAlignment.Left; cashL.Parent=header

local function hbtn(txt,x) local b=Instance.new("TextButton"); b.Size=UDim2.fromOffset(28,28); b.Position=UDim2.new(1,x,0,14)
    b.BackgroundColor3=BG3; b.Text=txt; b.TextColor3=TXT; b.Font=Enum.Font.GothamBold; b.TextSize=15; b.AutoButtonColor=true; b.Parent=header; corner(b,8); return b end
local closeB=hbtn("✕",-40); local minB=hbtn("—",-74)

-- 左右分區
local body=Instance.new("Frame"); body.Size=UDim2.new(1,0,1,-56); body.Position=UDim2.fromOffset(0,56); body.BackgroundTransparency=1; body.Parent=main
local side=Instance.new("Frame"); side.Size=UDim2.new(0,140,1,0); side.BackgroundColor3=BG2; side.BorderSizePixel=0; side.Parent=body
pad(side,12,12,10,10)
local sl=Instance.new("UIListLayout",side); sl.Padding=UDim.new(0,6); sl.SortOrder=Enum.SortOrder.LayoutOrder
local content=Instance.new("Frame"); content.Size=UDim2.new(1,-140,1,0); content.Position=UDim2.fromOffset(140,0); content.BackgroundTransparency=1; content.Parent=body

-- 分頁系統
local tabs={}; local pages={}; local activeTab=nil
local function selectTab(name)
    activeTab=name
    for n,m in pairs(tabs) do
        local on=(n==name)
        TweenService:Create(m.btn,TweenInfo.new(0.18),{BackgroundColor3=on and BG3 or BG2}):Play()
        m.accent.Visible=on
        m.lbl.TextColor3=on and TXT or SUB
    end
    for n,p in pairs(pages) do p.Visible=(n==name) end
end
local tabOrder=0
local function makeTab(name,icon)
    tabOrder+=1
    local b=Instance.new("TextButton"); b.Size=UDim2.new(1,0,0,40); b.BackgroundColor3=BG2; b.AutoButtonColor=false
    b.Text=""; b.LayoutOrder=tabOrder; b.Parent=side; corner(b,10)
    local acc=Instance.new("Frame"); acc.Size=UDim2.fromOffset(3,20); acc.Position=UDim2.fromOffset(0,10)
    acc.BackgroundColor3=ACCENT; acc.BorderSizePixel=0; acc.Visible=false; acc.Parent=b; corner(acc,2)
    local lbl=Instance.new("TextLabel"); lbl.Size=UDim2.new(1,-16,1,0); lbl.Position=UDim2.fromOffset(14,0)
    lbl.BackgroundTransparency=1; lbl.Font=Enum.Font.GothamMedium; lbl.TextSize=13.5; lbl.TextColor3=SUB
    lbl.Text=icon.."  "..name; lbl.TextXAlignment=Enum.TextXAlignment.Left; lbl.Parent=b
    tabs[name]={btn=b,accent=acc,lbl=lbl}
    b.MouseEnter:Connect(function() if activeTab~=name then b.BackgroundColor3=BG3 end end)
    b.MouseLeave:Connect(function() if activeTab~=name then b.BackgroundColor3=BG2 end end)
    b.MouseButton1Click:Connect(function() selectTab(name) end)
    local page=Instance.new("ScrollingFrame"); page.Size=UDim2.new(1,0,1,0); page.BackgroundTransparency=1; page.BorderSizePixel=0
    page.ScrollBarThickness=3; page.ScrollBarImageColor3=ACCENT; page.CanvasSize=UDim2.new(); page.AutomaticCanvasSize=Enum.AutomaticSize.Y
    page.Visible=false; page.Parent=content; pad(page,14,14,16,14)
    local pl=Instance.new("UIListLayout",page); pl.Padding=UDim.new(0,9); pl.SortOrder=Enum.SortOrder.LayoutOrder
    pages[name]=page
    return page
end

-- 開關元件（切換時自動SaveConfig）
local rowOrder=0
local function makeToggle(page,label,desc,key)
    rowOrder+=1
    local row=Instance.new("Frame"); row.Name="Row"; row.Size=UDim2.new(1,0,0,46); row.BackgroundColor3=BG2; row.BorderSizePixel=0; row.LayoutOrder=rowOrder; row.Parent=page
    corner(row,10)
    local st=Instance.new("UIStroke",row); st.Color=Color3.fromRGB(46,49,60); st.Thickness=1; st.Transparency=0.4
    local t=Instance.new("TextLabel"); t.Size=UDim2.new(1,-70,0,18); t.Position=UDim2.fromOffset(12,6); t.BackgroundTransparency=1
    t.Font=Enum.Font.GothamMedium; t.TextSize=13.5; t.TextColor3=TXT; t.Text=label; t.TextXAlignment=Enum.TextXAlignment.Left; t.Parent=row
    local d=Instance.new("TextLabel"); d.Size=UDim2.new(1,-70,0,13); d.Position=UDim2.fromOffset(12,25); d.BackgroundTransparency=1
    d.Font=Enum.Font.Gotham; d.TextSize=10.5; d.TextColor3=SUB; d.Text=desc; d.TextXAlignment=Enum.TextXAlignment.Left; d.Parent=row
    local sw=Instance.new("Frame"); sw.Size=UDim2.fromOffset(44,24); sw.Position=UDim2.new(1,-56,0.5,-12); sw.BackgroundColor3=BG3; sw.BorderSizePixel=0; sw.Parent=row
    corner(sw,12)
    local knob=Instance.new("Frame"); knob.Size=UDim2.fromOffset(18,18); knob.Position=UDim2.fromOffset(3,3); knob.BackgroundColor3=Color3.fromRGB(245,246,250); knob.BorderSizePixel=0; knob.Parent=sw
    corner(knob,9)
    local btn=Instance.new("TextButton"); btn.Size=UDim2.fromScale(1,1); btn.BackgroundTransparency=1; btn.Text=""; btn.Parent=row
    local function render()
        local on=S[key]
        TweenService:Create(sw,TweenInfo.new(0.18),{BackgroundColor3=on and ACCENT or BG3}):Play()
        TweenService:Create(knob,TweenInfo.new(0.18,Enum.EasingStyle.Back),{Position=on and UDim2.fromOffset(23,3) or UDim2.fromOffset(3,3)}):Play()
        TweenService:Create(st,TweenInfo.new(0.18),{Color=on and ACCENT or Color3.fromRGB(46,49,60)}):Play()
    end
    btn.MouseButton1Click:Connect(function()
        S[key]=not S[key]
        render()
        SaveConfig() -- 切換開關自動存
    end)
    render()
end

local function sectionInfo(page,text)
    rowOrder+=1
    local l=Instance.new("TextLabel"); l.Size=UDim2.new(1,0,0,0); l.AutomaticSize=Enum.AutomaticSize.Y; l.BackgroundTransparency=1
    l.Font=Enum.Font.Gotham; l.TextSize=11.5; l.TextColor3=SUB; l.TextWrapped=true; l.RichText=true
    l.Text=text; l.LayoutOrder=rowOrder; l.Parent=page
end

-- ========== 分頁建立 ==========
-- 1. 農場自動化
local pFarm=makeTab("農場自動化","🌱")
makeToggle(pFarm,"自動購買廠房","解鎖後自動購買全部可買設備","buy")
makeToggle(pFarm,"自動升級收入","批量點擊廠房各階段升級","autoUpgrade")
makeToggle(pFarm,"喚醒收益機台","持續激活所有產出建築","wake")

-- 2. 果樹&藤蔓
local pFruitVine=makeTab("果樹&藤蔓","🍋")
makeToggle(pFruitVine,"自動採集水果","自動傳送採摘檸檬樹果實","autoFruit")
makeToggle(pFruitVine,"自動收集藤蔓","定時領取下水道藤蔓收益","autoVine")
sectionInfo(pFruitVine,"藤蔓間隔預設5秒，修改腳本S.vineInterval調整")

-- 3. 電話收益
local pPhone=makeTab("電話收益","📞")
makeToggle(pPhone,"自動接聽電話","定時同意電話合約領獎勵","autoPhoneNew")
sectionInfo(pPhone,"電話間隔預設0.1秒，修改腳本S.phoneInterval調整")

-- 4. 轉生強化
local pPrest=makeTab("轉生強化","🔼")
makeToggle(pPrest,"自動強化天賦","自動點滿堆疊、速度、產出天賦","powers")
makeToggle(pPrest,"自動晉升(Ascend)","極快間隔重複執行晉升","ascend")
makeToggle(pPrest,"自動進化(Evolve)","極快間隔重複執行進化","evolve")

-- 5. 雜項設定
local pMisc=makeTab("雜項設定","⚙️")
makeToggle(pMisc,"防掛機踢除","閒置自動模擬輸入避免被踢","antiafk")
sectionInfo(pMisc,"<font color='#8A8F9C'>右Ctrl隱藏介面｜拖曳標題移動視窗</font>")
sectionInfo(pMisc,"<font color='#4fc070'>自動存讀：切開關自動存、重載腳本自動恢復</font>")

local stats=Instance.new("TextLabel"); stats.Size=UDim2.new(1,0,0,0); stats.AutomaticSize=Enum.AutomaticSize.Y; stats.BackgroundTransparency=1
stats.Font=Enum.Font.Code; stats.TextSize=12; stats.TextColor3=ACCENT; stats.TextXAlignment=Enum.TextXAlignment.Left; stats.RichText=true; stats.LayoutOrder=99; stats.Text="購買次數  "..S.cBuy
stats.Parent=pMisc

selectTab("農場自動化")

-- 視窗拖曳
do local drag,sp,si
    header.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
        drag=true; sp=main.Position; si=i.Position
        i.Changed:Connect(function() if i.UserInputState==Enum.UserInputState.End then drag=false end end) end end)
    UserInputService.InputChanged:Connect(function(i) if drag and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
        local dd=i.Position-si; main.Position=UDim2.new(sp.X.Scale,sp.X.Offset+dd.X,sp.Y.Scale,sp.Y.Offset+dd.Y) end end)
end

-- 最小化按鈕
local mini=false
minB.MouseButton1Click:Connect(function() mini=not mini
    TweenService:Create(main,TweenInfo.new(0.2,Enum.EasingStyle.Quad),{Size=mini and UDim2.fromOffset(500,56) or UDim2.fromOffset(500,330)}):Play()
    body.Visible=not mini end)

-- 右Ctrl隱藏介面
UserInputService.InputBegan:Connect(function(i,gpe) if gpe then return end
    if i.KeyCode==Enum.KeyCode.RightControl then main.Visible=not main.Visible end end)

local alive=true
local function loop(iv,fn) task.spawn(function() while alive do pcall(fn) task.wait(iv) end end) end

-- 自動購買
loop(0.00000000001,function() if not S.buy then return end local myT=getMyTycoon() if not myT then return end
    for _,p in ipairs(CollectionService:GetTagged("Tycoon.Purchase")) do if not S.buy then break end
        if p:IsDescendantOf(myT) and p:GetAttribute("Enabled") and p:GetAttribute("Shown") and not p:GetAttribute("Purchased") then
            local r=p:FindFirstChild("Purchase") if r and r:IsA("RemoteFunction") then pcall(function() r:InvokeServer(false) end)
                if p:GetAttribute("Purchased") then S.cBuy+=1 end end end end end)

loop(0.5,function() if not S.powers then return end local r=rem(getMyTycoon(),"UpgradePowerLevel") if not r then return end
    for _,n in ipairs(POWERS) do if not S.powers then break end pcall(function() r:InvokeServer(n) end) end end)

loop(0.0001,function()
    if not S.ascend then return end
    local myT=getMyTycoon()
    if not myT then return end
    local ascRemote=rem(myT,"Ascend")
    if ascRemote then pcall(function() ascRemote:InvokeServer() end) end
end)

loop(0.0001,function()
    if not S.evolve then return end
    local myT=getMyTycoon()
    if not myT then return end
    local evoRemote=rem(myT,"Evolve")
    if evoRemote then pcall(function() evoRemote:InvokeServer() end) end
end)

loop(8,function() if not S.wake then return end local myT=getMyTycoon() local r=rem(myT,"WakeIncomeStream") if not r then return end
    for _,e in ipairs(CollectionService:GetTagged("Tycoon.Earner")) do if e:IsDescendantOf(myT) then pcall(function() r:InvokeServer(e.Name) end) end end end)

-- 自動升級收入
task.spawn(function()
    while alive do
        task.wait(0.1)
        if not S.autoUpgrade then continue end
        local myT = getMyTycoon()
        if not myT then continue end
        for _, v in pairs(myT.Purchases:GetDescendants()) do
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

-- 自動採集水果
task.spawn(function()
    while alive do
        task.wait(0.1)
        if not S.autoFruit then continue end
        for _, tree in ipairs(Trees) do
            if not S.autoFruit then break end
            if not (tree and tree.Parent) then continue end
            pcall(function()
                for _, obj in ipairs(tree:GetDescendants()) do
                    if obj:IsA("BasePart") then obj.CanCollide = false end
                end
                local char = lp.Character
                if not char then return end
                local hrp = char:FindFirstChild("HumanoidRootPart")
                if not hrp then return end
                hrp.CFrame = tree:GetPivot() + Vector3.new(0, 5, 0)
                task.wait(0.05)
                for _, obj in ipairs(tree:GetDescendants()) do
                    if not S.autoFruit then break end
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
    while alive do
        local interval = math.clamp(S.vineInterval, 1, 60)
        task.wait(interval)
        if not S.autoVine then continue end
        pcall(function()
            workspace.Map.Sewer.CashVine.CashVine.Use:InvokeServer()
        end)
    end
end)

-- 新版定時自動接聽電話
task.spawn(function()
    while alive do
        local interval = math.clamp(S.phoneInterval, 0.1, 60)
        task.wait(interval)
        if not S.autoPhoneNew then continue end
        local myT = getMyTycoon()
        if not myT then continue end
        pcall(function()
            myT.Remotes.PhoneOffer:FireServer("Accept")
        end)
    end
end)

-- 防AFK
lp.Idled:Connect(function() if S.antiafk then pcall(function() VirtualUser:CaptureController() VirtualUser:ClickButton2(Vector2.new()) end) end end)

-- 統計文字
loop(0.4,function()
    local myT=getMyTycoon()
    local cash=lp:FindFirstChild("leaderstats") and lp.leaderstats:FindFirstChild("Cash") and lp.leaderstats.Cash.Value or "?"
    cashL.Text="💰 金幣："..tostring(cash).."   •   廠房："..(myT and myT.Name or "未知")
    stats.Text="購買次數  "..S.cBuy
end)

-- 銷毀介面時自動備份一次設定
closeB.MouseButton1Click:Connect(function() if _G.LemonFarm then _G.LemonFarm.Destroy() end end)
_G.LemonFarm={Destroy=function()
    alive=false
    SaveConfig() -- 關閉自動存備份
    for k in pairs(S) do
        if type(S[k])=="boolean" then S[k]=false end
    end
    if gui then gui:Destroy() end
end}
print("[🍋 檸檬輔助工具] 載入完成｜自動存讀開關狀態，無需手動操作")
