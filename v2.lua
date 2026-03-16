-- [[ TTF BY THONG V5 - CUSTOM TARGET CLICKER & SAFE WALK ]] --

if not game:IsLoaded() then game.Loaded:Wait() end

local Player = game.Players.LocalPlayer
local VirtualUser = game:GetService("VirtualUser")
local PathfindingService = game:GetService("PathfindingService")
local Character = Player.Character or Player.CharacterAdded:Wait()
local RootPart = Character:WaitForChild("HumanoidRootPart")
local Humanoid = Character:WaitForChild("Humanoid")

-- Biến hệ thống
_G.AutoFarm = false
_G.AutoSell = false
_G.FishingPos = nil
_G.SellPos = nil
local TimeLeft = 0

-- --- 1. TẠO NÚT TÂM NGẮM (ĐỂ BẠN KÉO ĐẾN CHỖ CẦN NHẤN) ---
local TargetGui = Instance.new("ScreenGui", Player.PlayerGui)
TargetGui.Name = "ThongTargetGui"

local TargetBtn = Instance.new("TextButton", TargetGui)
TargetBtn.Size = UDim2.new(0, 60, 0, 60)
TargetBtn.Position = UDim2.new(0.5, 0, 0.5, 0)
TargetBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
TargetBtn.BackgroundTransparency = 0.4
TargetBtn.Text = "KÉO TÂM\nVÀO NÚT"
TargetBtn.TextColor3 = Color3.new(1, 1, 1)
TargetBtn.Font = Enum.Font.SourceSansBold
TargetBtn.TextSize = 12
TargetBtn.Draggable = true -- Tính năng quan trọng nhất của bạn
TargetBtn.Active = true

local UICornerTarget = Instance.new("UICorner", TargetBtn)
UICornerTarget.CornerRadius = UDim.new(1, 0) -- Làm nút hình tròn cho dễ nhìn

-- --- 2. HÀM ĐI BỘ AN TOÀN (CHỐNG BỊ REPORT) ---
local function SafeWalk(targetPos)
    if not targetPos then return end
    local path = PathfindingService:CreatePath({AgentCanJump = true})
    path:ComputeAsync(RootPart.Position, targetPos)
    if path.Status == Enum.PathStatus.Success then
        for _, wp in ipairs(path:GetWaypoints()) do
            if wp.Action == Enum.PathWaypointAction.Jump then Humanoid.Jump = true end
            Humanoid:MoveTo(wp.Position)
            local t = tick()
            while (RootPart.Position - wp.Position).Magnitude > 4 do
                if tick() - t > 3 then Humanoid.Jump = true; break end
                task.wait()
            end
        end
    end
end

-- --- 3. HÀM SPAM CLICK TẠI TÂM ---
local function SpamClick()
    if _G.AutoFarm then
        -- Lấy tọa độ chính xác của nút Xanh trên màn hình
        local x = TargetBtn.AbsolutePosition.X + (TargetBtn.AbsoluteSize.X / 2)
        local y = TargetBtn.AbsolutePosition.Y + (TargetBtn.AbsoluteSize.Y / 2)
        
        VirtualUser:CaptureController()
        VirtualUser:ClickButton1(Vector2.new(x, y + 36)) -- Nhấn vào đúng tâm nút xanh
    end
end

-- --- 4. GIAO DIỆN MENU ---
local MainGui = Instance.new("ScreenGui", Player.PlayerGui)
local Frame = Instance.new("Frame", MainGui)
Frame.Size = UDim2.new(0, 220, 0, 320); Frame.Position = UDim2.new(0.1, 0, 0.2, 0)
Frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20); Frame.Active = true; Frame.Draggable = true
Instance.new("UICorner", Frame)

local function createBtn(txt, col)
    local b = Instance.new("TextButton", Frame)
    b.Size = UDim2.new(0.9, 0, 0, 40); b.Text = txt; b.BackgroundColor3 = col
    b.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", b)
    return b
end

local List = Instance.new("UIListLayout", Frame); List.HorizontalAlignment = "Center"; List.Padding = UDim.new(0,8)
local SetFish = createBtn("LƯU VỊ TRÍ CÂU", Color3.fromRGB(0, 100, 200))
local SetSell = createBtn("LƯU VỊ TRÍ BÁN", Color3.fromRGB(0, 100, 200))
local FarmTgl = createBtn("AUTO FARM: OFF", Color3.fromRGB(150, 0, 0))
local SellTgl = createBtn("AUTO SELL: OFF", Color3.fromRGB(150, 0, 0))
local Status = Instance.new("TextLabel", Frame); Status.Size = UDim2.new(1,0,0,30); Status.Text = "Sẵn sàng!"; Status.TextColor3 = Color3.new(1,1,1); Status.BackgroundTransparency = 1

-- --- 5. VÒNG LẶP HOẠT ĐỘNG ---
task.spawn(function()
    while task.wait(0.5) do -- Tốc độ spam 0.5 giây/lần
        if _G.AutoFarm then SpamClick() end
    end
end)

task.spawn(function()
    while task.wait(1) do
        if _G.AutoSell and TimeLeft > 0 then
            TimeLeft = TimeLeft - 1
            Status.Text = "Bán sau: "..TimeLeft.."s"
            if TimeLeft <= 0 then
                _G.AutoFarm = false
                Status.Text = "Đang đi bán cá..."
                SafeWalk(_G.SellPos)
                task.wait(2)
                Status.Text = "Quay lại chỗ câu..."
                SafeWalk(_G.FishingPos)
                TimeLeft = 300
                _G.AutoFarm = true
            end
        end
    end
end)

-- --- SỰ KIỆN NÚT ---
SetFish.MouseButton1Click:Connect(function() _G.FishingPos = RootPart.Position; Status.Text = "Đã lưu chỗ câu!" end)
SetSell.MouseButton1Click:Connect(function() _G.SellPos = RootPart.Position; Status.Text = "Đã lưu chỗ bán!" end)
FarmTgl.MouseButton1Click:Connect(function()
    _G.AutoFarm = not _G.AutoFarm
    FarmTgl.Text = _G.AutoFarm and "AUTO FARM: ON" or "AUTO FARM: OFF"
    FarmTgl.BackgroundColor3 = _G.AutoFarm and Color3.new(0, 0.5, 0) or Color3.new(0.5, 0, 0)
    TimeLeft = 300
end)
SellTgl.MouseButton1Click:Connect(function()
    _G.AutoSell = not _G.AutoSell
    SellTgl.Text = _G.AutoSell and "AUTO SELL: ON" or "AUTO SELL: OFF"
    SellTgl.BackgroundColor3 = _G.AutoSell and Color3.new(0, 0.5, 0) or Color3.new(0.5, 0, 0)
end)
