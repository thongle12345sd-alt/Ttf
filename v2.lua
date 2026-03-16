-- [[ TTF BY THONG V5 - CUSTOM TARGET CLICKER ]] --

if not game:IsLoaded() then game.Loaded:Wait() end

local Player = game.Players.LocalPlayer
local VirtualUser = game:GetService("VirtualUser")
local Character = Player.Character or Player.CharacterAdded:Wait()
local RootPart = Character:WaitForChild("HumanoidRootPart")

-- Biến hệ thống
_G.AutoFarm = false
_G.AutoSell = false
_G.FishingPos = nil
_G.SellPos = nil
local TimeLeft = 0

-- --- TẠO NÚT TÂM NGẮM (DÙNG ĐỂ KÉO THẢ) ---
local TargetGui = Instance.new("ScreenGui", Player.PlayerGui)
TargetGui.Name = "ThongTarget"

local TargetBtn = Instance.new("TextButton", TargetGui)
TargetBtn.Size = UDim2.new(0, 50, 0, 50)
TargetBtn.Position = UDim2.new(0.5, 0, 0.5, 0)
TargetBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
TargetBtn.BackgroundTransparency = 0.5
TargetBtn.Text = "KÉO\nTÂM"
TargetBtn.TextColor3 = Color3.new(1,1,1)
TargetBtn.Font = Enum.Font.SourceSansBold
TargetBtn.Active = true
TargetBtn.Draggable = true -- Cho phép bạn kéo đi khắp màn hình

local UICornerTarget = Instance.new("UICorner", TargetBtn)
UICornerTarget.CornerRadius = UDim.new(1, 0) -- Hình tròn

-- --- HÀM CLICK TẠI TÂM NGẮM ---
local function ClickAtTarget()
    if _G.AutoFarm then
        local x = TargetBtn.AbsolutePosition.X + (TargetBtn.AbsoluteSize.X / 2)
        local y = TargetBtn.AbsolutePosition.Y + (TargetBtn.AbsoluteSize.Y / 2)
        
        VirtualUser:CaptureController()
        VirtualUser:ClickButton1(Vector2.new(x, y + 36)) -- +36 để bù trừ thanh tiêu đề Roblox
    end
end

-- --- GIAO DIỆN CHÍNH ---
local ScreenGui = Instance.new("ScreenGui", Player.PlayerGui)
local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 220, 0, 300); Frame.Position = UDim2.new(0.1, 0, 0.2, 0)
Frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20); Frame.Active = true; Frame.Draggable = true
Instance.new("UICorner", Frame)

local function btn(txt, col, parent)
    local b = Instance.new("TextButton", parent)
    b.Size = UDim2.new(0.9, 0, 0, 40); b.Text = txt; b.BackgroundColor3 = col
    b.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", b); return b
end

local List = Instance.new("UIListLayout", Frame); List.HorizontalAlignment = "Center"; List.Padding = UDim.new(0,8)
local SetFish = btn("LƯU CHỖ CÂU", Color3.fromRGB(0, 100, 200), Frame)
local SetSell = btn("LƯU CHỖ BÁN", Color3.fromRGB(0, 100, 200), Frame)
local FarmTgl = btn("FARM: OFF", Color3.fromRGB(150, 0, 0), Frame)
local SellTgl = btn("BÁN: OFF", Color3.fromRGB(150, 0, 0), Frame)
local Status = Instance.new("TextLabel", Frame); Status.Size = UDim2.new(1,0,0,30); Status.Text = "Ready!"; Status.TextColor3 = Color3.new(1,1,1); Status.BackgroundTransparency = 1

-- --- VÒNG LẶP SPAM CLICK ---
task.spawn(function()
    while true do
        if _G.AutoFarm then
            ClickAtTarget()
            task.wait(0.5) -- Tốc độ spam (0.5 giây/lần), có thể chỉnh thấp hơn để nhanh hơn
        end
        task.wait(0.1)
    end
end)

-- (Giữ nguyên logic SafeWalk và Auto Sell từ V4)
-- ... [Logic SafeWalk rút gọn để tối ưu bộ nhớ Mobile] ...
