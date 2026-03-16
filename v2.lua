-- [[ TTF BY THONG V6 - KHFRESH INSPIRED EDITION ]] --
if not game:IsLoaded() then game.Loaded:Wait() end

local Player = game.Players.LocalPlayer
local VirtualUser = game:GetService("VirtualUser")
local PathfindingService = game:GetService("PathfindingService")
local TweenService = game:GetService("TweenService")

-- Xóa UI cũ để tránh lag
if Player.PlayerGui:FindFirstChild("ThongHubV6") then Player.PlayerGui.ThongHubV6:Destroy() end

-- --- HỆ THỐNG THÔNG BÁO ---
local function Notify(title, text)
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = title,
        Text = text,
        Duration = 3
    })
end

-- --- BIẾN HỆ THỐNG ---
_G.AutoFarm = false
_G.AutoSell = false
_G.FishingPos = nil
_G.SellPos = nil
local TimeLeft = 300

-- --- GIAO DIỆN (PHONG CÁCH HUB CHUYÊN NGHIỆP) ---
local Gui = Instance.new("ScreenGui", Player.PlayerGui); Gui.Name = "ThongHubV6"
local Main = Instance.new("Frame", Gui)
Main.Size = UDim2.new(0, 250, 0, 350); Main.Position = UDim2.new(0.5, -125, 0.4, -175)
Main.BackgroundColor3 = Color3.fromRGB(25, 25, 30); Main.BorderSizePixel = 0; Main.Active = true; Main.Draggable = true
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 10)

-- Thanh tiêu đề
local Header = Instance.new("Frame", Main)
Header.Size = UDim2.new(1, 0, 0, 40); Header.BackgroundColor3 = Color3.fromRGB(35, 35, 45); Header.BorderSizePixel = 0
local HeaderCorner = Instance.new("UICorner", Header); HeaderCorner.CornerRadius = UDim.new(0, 10)
local Title = Instance.new("TextLabel", Header)
Title.Size = UDim2.new(1, 0, 1, 0); Title.Text = "TTF BY THONG [V6]"; Title.TextColor3 = Color3.new(1,1,1); Title.BackgroundTransparency = 1; Title.Font = "SourceSansBold"; Title.TextSize = 18

-- Nút tâm ngắm (Kéo thả)
local Target = Instance.new("TextButton", Gui)
Target.Size = UDim2.new(0, 50, 0, 50); Target.Position = UDim2.new(0.5, 50, 0.5, 0)
Target.BackgroundColor3 = Color3.fromRGB(0, 255, 150); Target.Text = "TARGET"; Target.TextColor3 = Color3.new(0,0,0); Target.Draggable = true; Target.Font = "SourceSansBold"; Target.TextSize = 10
Instance.new("UICorner", Target).CornerRadius = UDim.new(1, 0)

local Container = Instance.new("ScrollingFrame", Main)
Container.Size = UDim2.new(1, -10, 1, -50); Container.Position = UDim2.new(0, 5, 0, 45); Container.BackgroundTransparency = 1; Container.CanvasSize = UDim2.new(0,0,2,0); Container.ScrollBarThickness = 2
Instance.new("UIListLayout", Container).HorizontalAlignment = "Center"; Container.UIListLayout.Padding = UDim.new(0, 8)

local function MakeBtn(txt, callback)
    local b = Instance.new("TextButton", Container)
    b.Size = UDim2.new(0.9, 0, 0, 35); b.Text = txt; b.BackgroundColor3 = Color3.fromRGB(45, 45, 55); b.TextColor3 = Color3.new(1,1,1)
    Instance.new("UICorner", b); b.Font = "SourceSansBold"
    b.MouseButton1Click:Connect(callback)
    return b
end

-- --- LOGIC ---
MakeBtn("SET FISHING POS", function() _G.FishingPos = Player.Character.HumanoidRootPart.Position; Notify("Success", "Lưu vị trí câu thành công!") end)
MakeBtn("SET SELL POS", function() _G.SellPos = Player.Character.HumanoidRootPart.Position; Notify("Success", "Lưu vị trí bán thành công!") end)

local FarmBtn = MakeBtn("AUTO FARM: OFF", function() end)
FarmBtn.MouseButton1Click:Connect(function()
    _G.AutoFarm = not _G.AutoFarm
    FarmBtn.Text = _G.AutoFarm and "AUTO FARM: ON" or "AUTO FARM: OFF"
    FarmBtn.BackgroundColor3 = _G.AutoFarm and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(45, 45, 55)
    Notify("Auto Farm", _G.AutoFarm and "Đã bật!" or "Đã tắt!")
end)

local SellBtn = MakeBtn("AUTO SELL: OFF", function() end)
SellBtn.MouseButton1Click:Connect(function()
    _G.AutoSell = not _G.AutoSell
    SellBtn.Text = _G.AutoSell and "AUTO SELL: ON" or "AUTO SELL: OFF"
    SellBtn.BackgroundColor3 = _G.AutoSell and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(45, 45, 55)
    TimeLeft = 300
end)

-- Vòng lặp Spam Click tại tâm
task.spawn(function()
    while task.wait(0.5) do
        if _G.AutoFarm then
            local x, y = Target.AbsolutePosition.X + 25, Target.AbsolutePosition.Y + 25
            VirtualUser:CaptureController()
            VirtualUser:ClickButton1(Vector2.new(x, y + 36))
        end
    end
end)

-- (Giữ nguyên logic SafeWalk từ V4 để an toàn)
