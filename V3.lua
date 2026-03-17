-- [[ ★ THỐNG HUB V33 - TITAN MOBILE ULTIMATE ★ ]] --
-- Tối ưu hóa tuyệt đối cho Executor Điện Thoại (Delta, Fluxus, Codex...)
-- Không dùng UI Library nặng, Không dùng VirtualInputManager gây kẹt.

repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")
local CoreGui = game:GetService("CoreGui")

local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()

-- 1. DỌN DẸP RÁC BỘ NHỚ (CHỐNG LAG)
pcall(function()
    for _, v in pairs(CoreGui:GetChildren()) do
        if v.Name == "ThongTitanMobile" then v:Destroy() end
    end
end)

-- 2. GIAO DIỆN SIÊU NHẸ (NATIVE UI - Dành riêng cho Mobile)
-- Sử dụng CoreGui để tránh bị game phát hiện (Anti-Cheat Bypass)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ThongTitanMobile"
ScreenGui.ResetOnSpawn = false
pcall(function() ScreenGui.Parent = CoreGui end)
if not ScreenGui.Parent then ScreenGui.Parent = Player:WaitForChild("PlayerGui") end

-- Nút Toggle Mini (Có thể kéo thả)
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0, 100, 0, 40)
ToggleBtn.Position = UDim2.new(0, 10, 0, 10)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
ToggleBtn.TextColor3 = Color3.fromRGB(0, 255, 150)
ToggleBtn.Font = Enum.Font.Code
ToggleBtn.TextScaled = true
ToggleBtn.Text = "TITAN: OFF"
ToggleBtn.Active = true
ToggleBtn.Draggable = true
ToggleBtn.BorderSizePixel = 2
ToggleBtn.BorderColor3 = Color3.fromRGB(0, 255, 150)
ToggleBtn.Parent = ScreenGui

-- 3. CÀI ĐẶT BẢO MẬT & MÔ PHỎNG (ANTI-BAN)
local config = {
    IsFarming = false,
    FishingPos = nil,
    SellPos = nil,
    WaitTime = 0
}

-- Hàm tạo độ trễ ngẫu nhiên (Mô phỏng người thật, đánh lừa Anti-Cheat)
local function RandomDelay(min, max)
    task.wait(math.random(min * 10, max * 10) / 10)
end

-- Hàm chạy bộ an toàn (Không Teleport)
local function WalkTo(targetCFrame)
    local char = Player.Character
    if not char or not targetCFrame then return end
    local hum = char:FindFirstChild("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart")
    
    if hum and hrp then
        hum:MoveTo(targetCFrame.Position)
        local timeOut = 0
        while (hrp.Position - targetCFrame.Position).Magnitude > 5 and timeOut < 20 do
            task.wait(0.5)
            timeOut = timeOut + 0.5
            -- Chống kẹt: Nếu vận tốc = 0 thì tự nhảy
            if hrp.Velocity.Magnitude < 0.5 then hum.Jump = true end
        end
        hrp.CFrame = targetCFrame -- Chỉnh lại hướng nhìn
    end
end

-- 4. LOGIC FARM (LÕI CỦA TITANFISHING)
-- Thay vì giả lập click chuột gây lỗi trên điện thoại, ta kích hoạt Tool trực tiếp
local function AutoFishingLogic()
    local char = Player.Character
    if not char then return end

    -- Tìm Cần câu trong tay hoặc trong Balo
    local rod = char:FindFirstChildOfClass("Tool") or Player.Backpack:FindFirstChildOfClass("Tool")
    if rod and rod:IsA("Tool") then
        if rod.Parent ~= char then
            rod.Parent = char -- Tự động cầm cần lên
            RandomDelay(0.5, 1.2)
        end
        
        -- Kích hoạt cần câu (Tương đương việc nhấp chuột trên PC)
        rod:Activate() 
        
        -- Mô phỏng thời gian chờ cá cắn (Thêm độ trễ để không bị kick vì spam)
        RandomDelay(2, 4)
    else
        warn("Không tìm thấy Cần Câu!")
    end
end

-- 5. VÒNG LẶP CHÍNH (TỐI ƯU HÓA LUỒNG)
-- Chống AFK (Tránh văng game khi treo lâu)
Player.Idled:Connect(function()
    VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    task.wait(1)
    VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
end)

-- Nút điều khiển chính
ToggleBtn.MouseButton1Click:Connect(function()
    config.IsFarming = not config.IsFarming
    
    if config.IsFarming then
        ToggleBtn.Text = "TITAN: ON"
        ToggleBtn.BorderColor3 = Color3.fromRGB(255, 0, 0)
        ToggleBtn.TextColor3 = Color3.fromRGB(255, 0, 0)
        
        -- Lưu vị trí hiện tại làm chỗ câu cá
        if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
            config.FishingPos = Player.Character.HumanoidRootPart.CFrame
        end
        
        -- Khởi động luồng Farm riêng biệt (Không gây lag Main Thread)
        task.spawn(function()
            while config.IsFarming and task.wait() do
                pcall(function()
                    AutoFishingLogic()
                end)
                RandomDelay(0.1, 0.5) -- Tránh tràn RAM
            end
        end)
    else
        ToggleBtn.Text = "TITAN: OFF"
        ToggleBtn.BorderColor3 = Color3.fromRGB(0, 255, 150)
        ToggleBtn.TextColor3 = Color3.fromRGB(0, 255, 150)
    end
end)
 
