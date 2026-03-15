-- [[ OMEGA-7 TITAN FISHING - V6: SMART NAVIGATION ]] --
local vim = game:GetService("VirtualInputManager")
local Player = game.Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local RootPart = Character:WaitForChild("HumanoidRootPart")
local Humanoid = Character:WaitForChild("Humanoid")

-- Biến hệ thống
local Fishing_Pos = nil
local Sell_Pos = nil
local Next_Sell_Time = 0
_G.AutoFarm = false
_G.AutoSellTimer = false
_G.SellInterval = 5 

-- Khởi tạo UI (Rút gọn từ bản V5 để tập trung vào tính năng mới)
local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local ScrollingFrame = Instance.new("ScrollingFrame")
local UIListLayout = Instance.new("UIListLayout")

ScreenGui.Parent = game.CoreGui
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.Position = UDim2.new(0.05, 0, 0.1, 0)
MainFrame.Size = UDim2.new(0, 280, 0, 520)
MainFrame.Active = true
MainFrame.Draggable = true

ScrollingFrame.Parent = MainFrame
ScrollingFrame.Size = UDim2.new(1, 0, 1, 0)
ScrollingFrame.CanvasSize = UDim2.new(0, 0, 2, 0)
ScrollingFrame.BackgroundTransparency = 1
UIListLayout.Parent = ScrollingFrame
UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
UIListLayout.Padding = UDim.new(0, 8)

local function createBtn(text, color)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.9, 0, 0, 35)
    btn.Text = text
    btn.BackgroundColor3 = color
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Parent = ScrollingFrame
    return btn
end

-- UI Setup
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40); Title.Text = "TITAN FISHING V6 (ADVANCED)"; Title.TextColor3 = Color3.fromRGB(255, 200, 0); Title.Parent = ScrollingFrame
local FishPosBtn = createBtn("LƯU VỊ TRÍ CÂU", Color3.fromRGB(0, 100, 200))
local SellPosBtn = createBtn("LƯU VỊ TRÍ BÁN", Color3.fromRGB(0, 100, 200))
local TimerLabel = Instance.new("TextLabel")
TimerLabel.Size = UDim2.new(0.9, 0, 0, 30); TimerLabel.Text = "Hệ thống: Chờ lệnh"; TimerLabel.TextColor3 = Color3.fromRGB(255, 255, 255); TimerLabel.Parent = ScrollingFrame
local IntervalInput = Instance.new("TextBox")
IntervalInput.Size = UDim2.new(0.6, 0, 0, 30); IntervalInput.PlaceholderText = "Phút đi bán"; IntervalInput.Text = "5"; IntervalInput.Parent = ScrollingFrame
local FarmBtn = createBtn("BẮT ĐẦU AUTO FARM", Color3.fromRGB(150, 0, 0))
local TimerToggleBtn = createBtn("TỰ ĐỘNG BÁN: OFF", Color3.fromRGB(150, 0, 0))

-- [[ CHỨC NĂNG NHẬN DIỆN VẬT CẢN (RAYCAST) ]] --

local function SmartWalk(targetPos)
    if not targetPos then return end
    local char = Player.Character
    local hum = char:WaitForChild("Humanoid")
    local root = char:WaitForChild("HumanoidRootPart")
    
    hum:MoveTo(targetPos)
    
    local isMoving = true
    task.spawn(function()
        while isMoving do
            -- 1. Raycast quét phía trước (Khoảng cách 4 studs)
            local rayOrigin = root.Position
            local rayDirection = root.CFrame.LookVector * 4
            
            local raycastParams = RaycastParams.new()
            raycastParams.FilterDescendantsInstances = {char}
            raycastParams.FilterType = Enum.RaycastFilterType.Exclude
            
            local raycastResult = workspace:Raycast(rayOrigin, rayDirection, raycastParams)
            
            if raycastResult then
                -- Nếu thấy vật cản -> NHẢY
                hum.Jump = true
                print("🚧 Phát hiện vật cản! Đang nhảy né...")
            end
            
            -- 2. Kiểm tra nếu bị đứng yên (Kẹt góc)
            local lastPos = root.Position
            task.wait(1)
            if (root.Position - lastPos).Magnitude < 1 and hum.MoveDirection.Magnitude > 0 then
                print("⚠️ Đang bị kẹt! Đang tìm cách thoát...")
                hum.Jump = true
                -- Đi chệch hướng một chút để thoát kẹt
                hum:MoveTo(targetPos + Vector3.new(math.random(-5, 5), 0, math.random(-5, 5)))
                task.wait(0.5)
                hum:MoveTo(targetPos)
            end
            
            -- Kiểm tra xem đã đến đích chưa
            if (root.Position - targetPos).Magnitude < 4 then
                isMoving = false
            end
        end
    end)
    
    hum.MoveToFinished:Wait()
    isMoving = false
end

-- [[ LOGIC KỸ NĂNG PC (Z, X, C, V) ]] --

local function Press(key)
    vim:SendKeyEvent(true, Enum.KeyCode[key], false, game)
    task.wait(0.1)
    vim:SendKeyEvent(false, Enum.KeyCode[key], false, game)
end

-- Vòng lặp chính
task.spawn(function()
    while true do
        if _G.AutoFarm then
            if _G.ShouldGoSell and Sell_Pos then
                local oldFarm = _G.AutoFarm
                _G.AutoFarm = false
                print("🎒 Đến giờ bán cá!")
                SmartWalk(Sell_Pos)
                task.wait(1)
                Press("E") -- Bán cá
                task.wait(2)
                SmartWalk(Fishing_Pos)
                _G.ShouldGoSell = false
                Next_Sell_Time = tonumber(IntervalInput.Text) * 60
                _G.AutoFarm = oldFarm
            end

            -- Quăng cần
            vim:SendMouseButtonEvent(0, 0, 0, true, game, 1)
            task.wait(0.1)
            vim:SendMouseButtonEvent(0, 0, 0, false, game, 1)
            
            task.wait(3.5) -- Chờ cá cắn
            
            -- Combo Skill Z, X, C, V (Bạn có thể thêm menu nhập thứ tự như V3)
            Press("Z") task.wait(1.5)
            Press("X") task.wait(1.5)
            Press("C") task.wait(1.5)
            Press("V") task.wait(1.5)
        end
        task.wait(1)
    end
end)

-- Vòng lặp đếm ngược (Hệ thống đếm thời gian)
task.spawn(function()
    while true do
        if _G.AutoSellTimer and Next_Sell_Time > 0 then
            Next_Sell_Time = Next_Sell_Time - 1
            local mins = math.floor(Next_Sell_Time / 60)
            local secs = Next_Sell_Time % 60
            TimerLabel.Text = string.format("Bán sau: %02d:%02d", mins, secs)
            if Next_Sell_Time <= 0 then _G.ShouldGoSell = true end
        end
        task.wait(1)
    end
end)

-- Event Nút bấm
FishPosBtn.MouseButton1Click:Connect(function() Fishing_Pos = RootPart.Position; FishPosBtn.Text = "LƯU CÂU ✅" end)
SellPosBtn.MouseButton1Click:Connect(function() Sell_Pos = RootPart.Position; SellPosBtn.Text = "LƯU BÁN ✅" end)

FarmBtn.MouseButton1Click:Connect(function()
    _G.AutoFarm = not _G.AutoFarm
    FarmBtn.Text = _G.AutoFarm and "FARM: ĐANG CHẠY" or "BẮT ĐẦU FARM"
    FarmBtn.BackgroundColor3 = _G.AutoFarm and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(150, 0, 0)
    Next_Sell_Time = tonumber(IntervalInput.Text) * 60
end)

TimerToggleBtn.MouseButton1Click:Connect(function()
    _G.AutoSellTimer = not _G.AutoSellTimer
    TimerToggleBtn.Text = _G.AutoSellTimer and "BÁN HẸN GIỜ: ON" or "BÁN HẸN GIỜ: OFF"
    TimerToggleBtn.BackgroundColor3 = _G.AutoSellTimer and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(150, 0, 0)
end)
