-- [[ TTF BY THONG V8 - KHFRESH MECHANICS ]] --
if not game:IsLoaded() then game.Loaded:Wait() end

local Player = game.Players.LocalPlayer
local VIM = game:GetService("VirtualInputManager")
local VirtualUser = game:GetService("VirtualUser")

-- Dọn dẹp UI cũ
local pGui = Player:WaitForChild("PlayerGui")
if pGui:FindFirstChild("ThongHubV8") then pGui.ThongHubV8:Destroy() end

-- Biến hệ thống
_G.AutoFarm = false
_G.AutoSell = false
_G.FishingPos = nil
_G.SellPos = nil

-- --- GIAO DIỆN MỚI ---
local Gui = Instance.new("ScreenGui", pGui); Gui.Name = "ThongHubV8"
local Main = Instance.new("Frame", Gui)
Main.Size = UDim2.new(0, 240, 0, 320); Main.Position = UDim2.new(0.5, -120, 0.4, -160)
Main.BackgroundColor3 = Color3.fromRGB(20, 20, 25); Main.Active = true; Main.Draggable = true
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 10)

-- Nút Target (Kéo thả)
local Target = Instance.new("TextButton", Gui)
Target.Size = UDim2.new(0, 50, 0, 50); Target.Position = UDim2.new(0.5, 70, 0.5, 0)
Target.BackgroundColor3 = Color3.fromRGB(0, 255, 120); Target.Text = "TARGET"; Target.Draggable = true; Target.Active = true
Instance.new("UICorner", Target).CornerRadius = UDim.new(1, 0)

-- --- CƠ CHẾ CLICK HỌC TỪ KHFRESH ---
local function SmartClick()
    local x = Target.AbsolutePosition.X + (Target.AbsoluteSize.X / 2)
    local y = Target.AbsolutePosition.Y + (Target.AbsoluteSize.Y / 2)
    
    -- Giả lập chạm màn hình chính xác hơn
    VIM:SendMouseButtonEvent(x, y + 36, 0, true, game, 1)
    task.wait(0.05)
    VIM:SendMouseButtonEvent(x, y + 36, 0, false, game, 1)
end

-- --- CƠ CHẾ SKILL HỌC TỪ KHFRESH ---
local function CastSkills()
    local keys = {"Z", "X", "C", "V"}
    for _, key in ipairs(keys) do
        if not _G.AutoFarm then break end
        VIM:SendKeyEvent(true, Enum.KeyCode[key], false, game)
        task.wait(0.1) -- Nhấn giữ ngắn
        VIM:SendKeyEvent(false, Enum.KeyCode[key], false, game)
        task.wait(0.3) -- Nghỉ giữa các skill để tránh lỗi
    end
end

-- --- VÒNG LẶP CHÍNH (TOI UU HOA) ---
task.spawn(function()
    while true do
        if _G.AutoFarm then
            SmartClick() -- Thả cần
            task.wait(0.5) 
            CastSkills() -- Tung combo
        end
        task.wait(0.2) -- Tốc độ vòng lặp cực nhanh nhưng không gây lag
    end
end)

-- --- CÁC NÚT BẤM ---
local Container = Instance.new("ScrollingFrame", Main)
Container.Size = UDim2.new(1, -10, 1, -50); Container.Position = UDim2.new(0, 5, 0, 45); Container.BackgroundTransparency = 1
Instance.new("UIListLayout", Container).HorizontalAlignment = "Center"; Container.UIListLayout.Padding = UDim.new(0, 8)

local function MakeBtn(txt, callback)
    local b = Instance.new("TextButton", Container)
    b.Size = UDim2.new(0.9, 0, 0, 35); b.Text = txt; b.BackgroundColor3 = Color3.fromRGB(40, 40, 50); b.TextColor3 = Color3.new(1,1,1)
    Instance.new("UICorner", b); b.MouseButton1Click:Connect(callback); return b
end

MakeBtn("LƯU CHỖ CÂU", function() _G.FishingPos = Player.Character.HumanoidRootPart.Position end)
MakeBtn("LƯU CHỖ BÁN", function() _G.SellPos = Player.Character.HumanoidRootPart.Position end)
local fBtn = MakeBtn("AUTO FARM: OFF", function() 
    _G.AutoFarm = not _G.AutoFarm 
    fBtn.Text = _G.AutoFarm and "AUTO FARM: ON" or "AUTO FARM: OFF"
end)
