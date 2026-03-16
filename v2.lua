-- [[ TTF BY THONG - VERSION MOBILE FIX ]] --

if not game:IsLoaded() then game.Loaded:Wait() end

local Player = game.Players.LocalPlayer
local ParentUI = Player:WaitForChild("PlayerGui")

-- Xóa Menu cũ nếu đã tồn tại
if ParentUI:FindFirstChild("TtfByThongGui") then
    ParentUI:FindFirstChild("TtfByThongGui"):Destroy()
end

local vim = game:GetService("VirtualInputManager")
local Character = Player.Character or Player.CharacterAdded:Wait()
local RootPart = Character:WaitForChild("HumanoidRootPart")
local Humanoid = Character:WaitForChild("Humanoid")

-- --- KHỞI TẠO GUI ---
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TtfByThongGui"
ScreenGui.Parent = ParentUI
ScreenGui.ResetOnSpawn = false -- Quan trọng: Chết đi menu không mất

local MainFrame = Instance.new("Frame")
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.Position = UDim2.new(0.2, 0, 0.2, 0)
MainFrame.Size = UDim2.new(0, 260, 0, 420)
MainFrame.Active = true
MainFrame.Draggable = true

local UICorner = Instance.new("UICorner")
UICorner.Parent = MainFrame

local ScrollingFrame = Instance.new("ScrollingFrame")
ScrollingFrame.Parent = MainFrame
ScrollingFrame.Size = UDim2.new(1, 0, 1, -10)
ScrollingFrame.CanvasSize = UDim2.new(0, 0, 2.5, 0)
ScrollingFrame.BackgroundTransparency = 1
ScrollingFrame.ScrollBarThickness = 2

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Parent = ScrollingFrame
UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
UIListLayout.Padding = UDim.new(0, 10)

-- --- CÁC BIẾN LOGIC ---
local Fishing_Pos = nil
local Sell_Pos = nil
local Next_Sell_Time = 0
_G.AutoFarm = false
_G.AutoSellTimer = false
_G.ShouldGoSell = false

-- --- HÀM TIỆN ÍCH ---
local function createBtn(text, color)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.9, 0, 0, 40)
    btn.Text = text
    btn.BackgroundColor3 = color
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.SourceSansBold
    btn.Parent = ScrollingFrame
    Instance.new("UICorner").Parent = btn
    return btn
end

local function createLabel(text)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0.9, 0, 0, 30)
    lbl.Text = text
    lbl.TextColor3 = Color3.fromRGB(255, 255, 255)
    lbl.BackgroundTransparency = 1
    lbl.Parent = ScrollingFrame
    return lbl
end

-- --- GIAO DIỆN ---
createLabel("TITAN FISHING BY THONG V2")
local FishBtn = createBtn("LƯU VỊ TRÍ CÂU", Color3.fromRGB(0, 120, 200))
local SellBtn = createBtn("LƯU VỊ TRÍ BÁN", Color3.fromRGB(0, 120, 200))
local TimerLabel = createLabel("Chờ bán: --:--")
local IntervalInp = Instance.new("TextBox")
IntervalInp.Size = UDim2.new(0.6, 0, 0, 30); IntervalInp.Text = "5"; IntervalInp.Parent = ScrollingFrame

local FarmBtn = createBtn("BẮT ĐẦU FARM", Color3.fromRGB(150, 0, 0))
local SellToggle = createBtn("HẸN GIỜ BÁN: OFF", Color3.fromRGB(150, 0, 0))

-- --- LOGIC DI CHUYỂN & SKILL ---
local function SmartWalk(targetPos)
    if not targetPos then return end
    Humanoid:MoveTo(targetPos)
    local moving = true
    task.spawn(function()
        while moving do
            local res = workspace:Raycast(RootPart.Position, RootPart.CFrame.LookVector * 5)
            if res then Humanoid.Jump = true end
            task.wait(1)
            if (RootPart.Position - targetPos).Magnitude < 4 then moving = false end
        end
    end)
    Humanoid.MoveToFinished:Wait()
    moving = false
end

local function ExecuteSkills()
    local keys = {"Z", "X", "C", "V"}
    for _, k in ipairs(keys) do
        if not _G.AutoFarm then break end
        vim:SendKeyEvent(true, Enum.KeyCode[k], false, game)
        task.wait(0.1)
        vim:SendKeyEvent(false, Enum.KeyCode[k], false, game)
        task.wait(1.5)
    end
end

-- --- VÒNG LẶP ---
task.spawn(function()
    while true do
        if _G.AutoFarm then
            if _G.ShouldGoSell and Sell_Pos then
                _G.AutoFarm = false
                SmartWalk(Sell_Pos)
                task.wait(1) -- Giả lập bán cá
                SmartWalk(Fishing_Pos)
                _G.ShouldGoSell = false
                _G.AutoFarm = true
                Next_Sell_Time = tonumber(IntervalInp.Text) * 60
            end
            vim:SendMouseButtonEvent(0, 0, 0, true, game, 1); task.wait(0.1)
            vim:SendMouseButtonEvent(0, 0, 0, false, game, 1)
            task.wait(3)
            ExecuteSkills()
        end
        task.wait(1)
    end
end)

task.spawn(function()
    while true do
        if _G.AutoSellTimer and Next_Sell_Time > 0 then
            Next_Sell_Time = Next_Sell_Time - 1
            TimerLabel.Text = "Bán sau: "..math.floor(Next_Sell_Time/60).."p"..(Next_Sell_Time%60).."s"
            if Next_Sell_Time <= 0 then _G.ShouldGoSell = true end
        end
        task.wait(1)
    end
end)

-- --- SỰ KIỆN ---
FishBtn.MouseButton1Click:Connect(function() Fishing_Pos = RootPart.Position; FishBtn.Text = "ĐÃ LƯU CÂU ✅" end)
SellBtn.MouseButton1Click:Connect(function() Sell_Pos = RootPart.Position; SellBtn.Text = "ĐÃ LƯU BÁN ✅" end)
FarmBtn.MouseButton1Click:Connect(function()
    _G.AutoFarm = not _G.AutoFarm
    FarmBtn.Text = _G.AutoFarm and "FARMING..." or "BẮT ĐẦU FARM"
    FarmBtn.BackgroundColor3 = _G.AutoFarm and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(150, 0, 0)
    Next_Sell_Time = tonumber(IntervalInp.Text) * 60
end)
SellToggle.MouseButton1Click:Connect(function()
    _G.AutoSellTimer = not _G.AutoSellTimer
    SellToggle.Text = _G.AutoSellTimer and "HẸN GIỜ BÁN: ON" or "HẸN GIỜ BÁN: OFF"
    SellToggle.BackgroundColor3 = _G.AutoSellTimer and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(150, 0, 0)
end)
