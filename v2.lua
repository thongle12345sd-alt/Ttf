-- [[ TITAN FISHING BY THONG - MOBILE OPTIMIZED ]] --

-- Chờ game load xong hẳn mới chạy
if not game:IsLoaded() then game.Loaded:Wait() end

local Player = game.Players.LocalPlayer
-- Fix lỗi không hiện trên điện thoại: Dùng PlayerGui thay vì CoreGui
local ParentUI = Player:WaitForChild("PlayerGui")

-- Xóa Menu cũ nếu đã tồn tại để tránh trùng lặp
if ParentUI:FindFirstChild("TtfByThongGui") then
    ParentUI:FindFirstChild("TtfByThongGui"):Destroy()
end

local vim = game:GetService("VirtualInputManager")
local Character = Player.Character or Player.CharacterAdded:Wait()
local RootPart = Character:WaitForChild("HumanoidRootPart")
local Humanoid = Character:WaitForChild("Humanoid")

-- --- GIAO DIỆN CHUẨN MOBILE ---
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TtfByThongGui"
ScreenGui.Parent = ParentUI
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local MainFrame = Instance.new("Frame")
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.BorderSizePixel = 0
MainFrame.Position = UDim2.new(0.3, 0, 0.2, 0)
MainFrame.Size = UDim2.new(0, 260, 0, 400)
MainFrame.Active = true
MainFrame.Draggable = true -- Có thể di chuyển trên màn hình cảm ứng

-- Bo góc cho đẹp
local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 10)
UICorner.Parent = MainFrame

local ScrollingFrame = Instance.new("ScrollingFrame")
ScrollingFrame.Parent = MainFrame
ScrollingFrame.Size = UDim2.new(1, 0, 1, -10)
ScrollingFrame.CanvasSize = UDim2.new(0, 0, 2, 0)
ScrollingFrame.BackgroundTransparency = 1
ScrollingFrame.ScrollBarThickness = 2

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Parent = ScrollingFrame
UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
UIListLayout.Padding = UDim.new(0, 10)

-- Hàm tạo nút chuẩn Mobile
local function createBtn(text, color)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.9, 0, 0, 40)
    btn.Text = text
    btn.BackgroundColor3 = color
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 16
    btn.Parent = ScrollingFrame
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = btn
    return btn
end

-- --- NỘI DUNG ---
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Text = "TITAN FISHING BY THONG"
Title.TextColor3 = Color3.fromRGB(255, 215, 0)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 20
Title.Parent = ScrollingFrame

local FishPosBtn = createBtn("LƯU VỊ TRÍ CÂU", Color3.fromRGB(0, 120, 215))
local SellPosBtn = createBtn("LƯU VỊ TRÍ BÁN", Color3.fromRGB(0, 120, 215))

local FarmBtn = createBtn("BẮT ĐẦU AUTO FARM", Color3.fromRGB(150, 0, 0))
local TimerToggleBtn = createBtn("AUTO SELL (HẸN GIỜ): OFF", Color3.fromRGB(150, 0, 0))

-- [[ PHẦN LOGIC VÀ COMBO SKILL GIỮ NGUYÊN TỪ V6 ]] --
-- (Copy phần logic SmartWalk, Press, ExecuteSkills và các vòng lặp từ bản V6 dán vào đây)
-- Lưu ý: Đảm bảo các biến Fishing_Pos, Sell_Pos đã được khai báo.

print("Script TtfByThong da load thanh cong tren Mobile!")
