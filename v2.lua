-- [[ TTF BY THONG V12 - OPTIMIZED ENGINE ]] --
if not game:IsLoaded() then game.Loaded:Wait() end

local Player = game.Players.LocalPlayer
local VIM = game:GetService("VirtualInputManager")
local pGui = Player:WaitForChild("PlayerGui")

-- Xóa UI cũ để tránh chồng chéo
if pGui:FindFirstChild("ThongHubV12") then pGui.ThongHubV12:Destroy() end

-- --- HỆ THỐNG BIẾN TÙY CHỈNH ---
_G.AutoFarm = false
_G.Combo = "Z,X,C"      -- Thứ tự chiêu bạn muốn
_G.SkillDelay = 0.5     -- Delay giữa các chiêu (giây)
_G.ClickSpeed = 0.1     -- Tốc độ nhấp câu cá (giây)

-- --- GIAO DIỆN (UI) ---
local Gui = Instance.new("ScreenGui", pGui); Gui.Name = "ThongHubV12"; Gui.IgnoreGuiInset = true
local Main = Instance.new("Frame", Gui)
Main.Size = UDim2.new(0, 250, 0, 400); Main.Position = UDim2.new(0.1, 0, 0.2, 0)
Main.BackgroundColor3 = Color3.fromRGB(18, 18, 22); Main.Active = true; Main.Draggable = true
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 10)

-- Nút TARGET (Phải kéo vào nút Câu cá)
local Target = Instance.new("TextButton", Gui)
Target.Size = UDim2.new(0, 50, 0, 50); Target.Position = UDim2.new(0.7, 0, 0.5, 0)
Target.BackgroundColor3 = Color3.fromRGB(255, 60, 60); Target.Text = "TARGET"; Target.Draggable = true; Target.Active = true; Target.ZIndex = 100
Instance.new("UICorner", Target).CornerRadius = UDim.new(1, 0)

local List = Instance.new("UIListLayout", Main); List.HorizontalAlignment = "Center"; List.Padding = UDim.new(0, 10)
local Title = Instance.new("TextLabel", Main); Title.Size = UDim2.new(1,0,0,40); Title.Text = "THONG HUB V12"; Title.TextColor3 = Color3.new(1,1,1); Title.BackgroundTransparency = 1; Title.Font = "SourceSansBold"

-- --- CÁC Ô NHẬP LIỆU (OPTIMIZED) ---
local function CreateInput(label, default, callback)
    local box = Instance.new("TextBox", Main)
    box.Size = UDim2.new(0.9, 0, 0, 35); box.PlaceholderText = label; box.Text = default
    box.BackgroundColor3 = Color3.fromRGB(35, 35, 45); box.TextColor3 = Color3.new(1,1,1); box.Font = "SourceSans"
    Instance.new("UICorner", box)
    box.FocusLost:Connect(function() callback(box.Text) end)
end

CreateInput("Thứ tự: Z,X,C", "Z,X,C", function(t) _G.Combo = t end)
CreateInput("Delay Skill (vd: 0.5)", "0.5", function(t) _G.SkillDelay = tonumber(t) or 0.5 end)
CreateInput("Tốc độ Nhấp (vd: 0.1)", "0.1", function(t) _G.ClickSpeed = tonumber(t) or 0.1 end)

local fBtn = Instance.new("TextButton", Main)
fBtn.Size = UDim2.new(0.9, 0, 0, 40); fBtn.Text = "AUTO FARM: OFF"; fBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 60); fBtn.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", fBtn)

fBtn.MouseButton1Click:Connect(function()
    _G.AutoFarm = not _G.AutoFarm
    fBtn.Text = _G.AutoFarm and "AUTO FARM: ON" or "AUTO FARM: OFF"
    fBtn.BackgroundColor3 = _G.AutoFarm and Color3.fromRGB(0, 180, 0) or Color3.fromRGB(50, 50, 60)
end)

-- --- CORE LOGIC (HỌC HỎI TỪ KHFRESH) ---

-- 1. Vòng lặp Nhấp Câu Cá (Chạy độc lập để cực nhanh)
task.spawn(function()
    while true do
        if _G.AutoFarm then
            local x, y = Target.AbsolutePosition.X + 25, Target.AbsolutePosition.Y + 25
            VIM:SendMouseButtonEvent(x, y, 0, true, game, 1)
            task.wait(0.01) -- Nhấp cực nhanh
            VIM:SendMouseButtonEvent(x, y, 0, false, game, 1)
        end
        task.wait(_G.ClickSpeed) -- Thời gian nghỉ giữa các lần nhấp
    end
end)

-- 2. Vòng lặp Combo Skill (Chạy riêng để không làm chậm việc Câu)
task.spawn(function()
    while true do
        if _G.AutoFarm then
            local keys = string.split(_G.Combo, ",")
            for _, k in ipairs(keys) do
                if not _G.AutoFarm then break end
                local key = string.upper(string.gsub(k, " ", ""))
                pcall(function()
                    VIM:SendKeyEvent(true, Enum.KeyCode[key], false, game)
                    task.wait(0.05)
                    VIM:SendKeyEvent(false, Enum.KeyCode[key], false, game)
                end)
                task.wait(_G.SkillDelay) -- Delay chỉnh được giữa các chiêu
            end
        end
        task.wait(0.1)
    end
end)
