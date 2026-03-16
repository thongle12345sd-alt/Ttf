-- [[ TTF BY THONG V9 - FINAL ENGINE ]] --
if not game:IsLoaded() then game.Loaded:Wait() end

local Player = game.Players.LocalPlayer
local VIM = game:GetService("VirtualInputManager")
local pGui = Player:WaitForChild("PlayerGui")

-- Xóa sạch bản cũ
if pGui:FindFirstChild("ThongHubV9") then pGui.ThongHubV9:Destroy() end

_G.AutoFarm = false
_G.FishingPos = nil
_G.SellPos = nil

-- --- UI CHUYÊN NGHIỆP ---
local Gui = Instance.new("ScreenGui", pGui); Gui.Name = "ThongHubV9"; Gui.IgnoreGuiInset = true

-- Nút TARGET (Phải hiện ra để bạn kéo vào chữ "Câu cá")
local Target = Instance.new("TextButton", Gui)
Target.Size = UDim2.new(0, 60, 0, 60); Target.Position = UDim2.new(0.7, 0, 0.7, 0)
Target.BackgroundColor3 = Color3.fromRGB(0, 255, 100); Target.Text = "KÉO VÀO\nCÂU CÁ"; Target.Draggable = true
Target.Active = true; Target.ZIndex = 100; Instance.new("UICorner", Target).CornerRadius = UDim.new(1, 0)

local Main = Instance.new("Frame", Gui)
Main.Size = UDim2.new(0, 220, 0, 300); Main.Position = UDim2.new(0.1, 0, 0.3, 0)
Main.BackgroundColor3 = Color3.fromRGB(20, 20, 25); Main.Draggable = true; Main.Active = true
Instance.new("UICorner", Main)

local function MakeBtn(txt, callback)
    local b = Instance.new("TextButton", Main)
    b.Size = UDim2.new(0.9, 0, 0, 40); b.Position = UDim2.new(0.05, 0, 0, 0) -- Sẽ tự xếp hàng bằng UIListLayout
    b.Text = txt; b.BackgroundColor3 = Color3.fromRGB(45, 45, 55); b.TextColor3 = Color3.new(1,1,1)
    Instance.new("UICorner", b); b.MouseButton1Click:Connect(callback); return b
end
local List = Instance.new("UIListLayout", Main); List.HorizontalAlignment = "Center"; List.Padding = UDim.new(0, 10)

-- --- CƠ CHẾ CLICK & SKILL CẢI TIẾN ---
local function AutoAction()
    -- 1. Click vào nút "Câu cá" (vị trí bạn đặt tâm xanh)
    local x = Target.AbsolutePosition.X + 30
    local y = Target.AbsolutePosition.Y + 30
    VIM:SendMouseButtonEvent(x, y, 0, true, game, 1)
    task.wait(0.05)
    VIM:SendMouseButtonEvent(x, y, 0, false, game, 1)
    
    -- 2. Spam Skill (Z, X, C, V) theo nhịp
    task.wait(0.5)
    local keys = {Enum.KeyCode.Z, Enum.KeyCode.X, Enum.KeyCode.C}
    for _, k in ipairs(keys) do
        VIM:SendKeyEvent(true, k, false, game)
        task.wait(0.1)
        VIM:SendKeyEvent(false, k, false, game)
        task.wait(0.2)
    end
end

-- --- VÒNG LẶP ---
task.spawn(function()
    while true do
        if _G.AutoFarm then
            AutoAction()
        end
        task.wait(0.8) -- Nghỉ một chút để tránh giật lag điện thoại
    end
end)

-- Nút bấm
MakeBtn("LƯU CHỖ CÂU", function() _G.FishingPos = Player.Character.HumanoidRootPart.Position end)
MakeBtn("LƯU CHỖ BÁN", function() _G.SellPos = Player.Character.HumanoidRootPart.Position end)
local fBtn = MakeBtn("AUTO FARM: OFF", function() 
    _G.AutoFarm = not _G.AutoFarm 
    fBtn.Text = _G.AutoFarm and "AUTO FARM: ON" or "AUTO FARM: OFF"
end)
