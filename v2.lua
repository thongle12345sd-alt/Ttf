-- [[ TTF BY THONG V11 - CUSTOM COMBO & DELAY ]] --
if not game:IsLoaded() then game.Loaded:Wait() end

local Player = game.Players.LocalPlayer
local VIM = game:GetService("VirtualInputManager")
local PathfindingService = game:GetService("PathfindingService")
local pGui = Player:WaitForChild("PlayerGui")

-- Xóa bản cũ
if pGui:FindFirstChild("ThongHubV11") then pGui.ThongHubV11:Destroy() end

-- Biến hệ thống (Có thể chỉnh trên UI)
_G.AutoFarm = false
_G.AutoSell = false
_G.FishingPos = nil
_G.SellPos = nil
_G.ComboOrder = "Z,X,C" -- Thứ tự mặc định
_G.SkillDelay = 0.5     -- Nghỉ giữa các chiêu mặc định

-- --- HÀM ĐI BỘ (SMART WALK) ---
local function SmartWalk(targetPos)
    if not targetPos then return end
    local char = Player.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        char.Humanoid:MoveTo(targetPos) -- Đơn giản hóa để chạy nhanh hơn trên Mobile
    end
end

-- --- UI ---
local Gui = Instance.new("ScreenGui", pGui); Gui.Name = "ThongHubV11"; Gui.IgnoreGuiInset = true
local Main = Instance.new("Frame", Gui)
Main.Size = UDim2.new(0, 250, 0, 420); Main.Position = UDim2.new(0.1, 0, 0.2, 0)
Main.BackgroundColor3 = Color3.fromRGB(15, 15, 20); Main.Active = true; Main.Draggable = true
Instance.new("UICorner", Main)

local List = Instance.new("UIListLayout", Main); List.HorizontalAlignment = "Center"; List.Padding = UDim.new(0, 8)
local Title = Instance.new("TextLabel", Main); Title.Size = UDim2.new(1,0,0,30); Title.Text = "TTF BY THONG V11"; Title.TextColor3 = Color3.new(1,1,1); Title.BackgroundTransparency = 1

-- Nút TARGET (Kéo vào nút Câu Cá)
local Target = Instance.new("TextButton", Gui)
Target.Size = UDim2.new(0, 50, 0, 50); Target.Position = UDim2.new(0.7, 0, 0.5, 0)
Target.BackgroundColor3 = Color3.fromRGB(255, 50, 50); Target.Text = "TARGET"; Target.Draggable = true; Target.Active = true; Target.ZIndex = 100
Instance.new("UICorner", Target).CornerRadius = UDim.new(1, 0)

local function MakeInput(placeholder, default, callback)
    local i = Instance.new("TextBox", Main)
    i.Size = UDim2.new(0.9, 0, 0, 35); i.PlaceholderText = placeholder; i.Text = default
    i.BackgroundColor3 = Color3.fromRGB(30, 30, 40); i.TextColor3 = Color3.new(1,1,1)
    Instance.new("UICorner", i); i.FocusLost:Connect(function() callback(i.Text) end)
    return i
end

local function MakeBtn(txt, callback)
    local b = Instance.new("TextButton", Main)
    b.Size = UDim2.new(0.9, 0, 0, 35); b.Text = txt; b.BackgroundColor3 = Color3.fromRGB(45, 45, 55); b.TextColor3 = Color3.new(1,1,1)
    Instance.new("UICorner", b); b.MouseButton1Click:Connect(callback); return b
end

-- CÀI ĐẶT COMBO
MakeInput("Thứ tự chiêu (vd: Z,X,C)", "Z,X,C", function(t) _G.ComboOrder = t end)
MakeInput("Delay giữa chiêu (giây)", "0.5", function(t) _G.SkillDelay = tonumber(t) or 0.5 end)

-- NÚT CHỨC NĂNG
local bFish = MakeBtn("LƯU CHỖ CÂU", function() _G.FishingPos = Player.Character.HumanoidRootPart.Position; bFish.Text = "✅ ĐÃ LƯU CÂU" end)
local bSell = MakeBtn("LƯU CHỖ BÁN", function() _G.SellPos = Player.Character.HumanoidRootPart.Position; bSell.Text = "✅ ĐÃ LƯU BÁN" end)
local fBtn = MakeBtn("AUTO FARM: OFF", function() 
    _G.AutoFarm = not _G.AutoFarm 
    fBtn.Text = _G.AutoFarm and "AUTO FARM: ON" or "AUTO FARM: OFF"
    fBtn.BackgroundColor3 = _G.AutoFarm and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(45, 45, 55)
end)

-- --- HÀM TỰ ĐỘNG ---
task.spawn(function()
    while true do
        if _G.AutoFarm then
            -- 1. Tự động nhấp Câu Cá (nhấp liên tục)
            local x, y = Target.AbsolutePosition.X + 25, Target.AbsolutePosition.Y + 25
            VIM:SendMouseButtonEvent(x, y, 0, true, game, 1)
            task.wait(0.1)
            VIM:SendMouseButtonEvent(x, y, 0, false, game, 1)

            -- 2. Thực hiện Combo theo thứ tự người dùng nhập
            local combo = string.split(_G.ComboOrder, ",")
            for _, keyName in ipairs(combo) do
                if not _G.AutoFarm then break end
                local key = string.upper(string.gsub(keyName, " ", "")) -- Xóa khoảng trắng, viết hoa
                pcall(function()
                    VIM:SendKeyEvent(true, Enum.KeyCode[key], false, game)
                    task.wait(0.05)
                    VIM:SendKeyEvent(false, Enum.KeyCode[key], false, game)
                end)
                task.wait(_G.SkillDelay) -- Delay tùy chỉnh giữa các chiêu
            end
        end
        task.wait(0.2)
    end
end)
