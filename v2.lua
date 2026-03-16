-- [[ THỐNG HUB V21 - SPECIAL EDITION ]] --
repeat task.wait() until game:IsLoaded()

local Player = game.Players.LocalPlayer
local VIM = game:GetService("VirtualInputManager")
local pGui = Player:WaitForChild("PlayerGui")
local TweenService = game:GetService("TweenService")

-- Xóa UI cũ để cập nhật tên mới
for _, old in pairs(pGui:GetChildren()) do
    if old.Name:find("ThongHub") or old.Name == "ThongTarget" or old.Name:find("ThốngHub") then 
        old:Destroy() 
    end
end

-- --- BIẾN HỆ THỐNG ---
_G.AutoFarm = false
_G.AutoSell = false
_G.FishingPos = nil
_G.SellPos = nil
_G.ClickSpeed = 0.1

-- Delay riêng biệt cho Thống tùy chỉnh
_G.DelayZ = 0.5
_G.DelayX = 0.5
_G.DelayC = 0.5
_G.DelayV = 0.5

-- --- GIAO DIỆN THỐNG HUB (TITAN STYLE) ---
local Gui = Instance.new("ScreenGui", pGui); Gui.Name = "ThốngHubV21"; Gui.IgnoreGuiInset = true
local Main = Instance.new("Frame", Gui)
Main.Size = UDim2.new(0, 380, 0, 350); Main.Position = UDim2.new(0.5, -190, 0.4, -175)
Main.BackgroundColor3 = Color3.fromRGB(12, 12, 12); Main.BorderSizePixel = 0; Main.Active = true; Main.Draggable = true
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 8)

-- Nút TARGET (Tâm ngắm cho Thống)
local Target = Instance.new("TextButton", Gui)
Target.Name = "ThongTarget"; Target.Size = UDim2.new(0, 45, 0, 45); Target.Position = UDim2.new(0.85, 0, 0.5, 0)
Target.BackgroundColor3 = Color3.fromRGB(0, 170, 255); Target.Text = "TARGET"; Target.Draggable = true; Target.Active = true
Target.TextColor3 = Color3.new(1,1,1); Target.Font = "SourceSansBold"; Target.TextSize = 10
Instance.new("UICorner", Target).CornerRadius = UDim.new(1, 0)

-- Header với tên bạn
local Header = Instance.new("TextLabel", Main)
Header.Size = UDim2.new(1, 0, 0, 40); Header.Text = "★ THỐNG HUB V21 ★"; Header.TextColor3 = Color3.fromRGB(0, 170, 255)
Header.BackgroundColor3 = Color3.fromRGB(20, 20, 20); Header.Font = "SourceSansBold"; Header.TextSize = 18
Instance.new("UICorner", Header)

local Container = Instance.new("ScrollingFrame", Main)
Container.Size = UDim2.new(1, -20, 1, -50); Container.Position = UDim2.new(0, 10, 0, 45)
Container.BackgroundTransparency = 1; Container.CanvasSize = UDim2.new(0,0,2.2,0); Container.ScrollBarThickness = 2
local List = Instance.new("UIListLayout", Container); List.Padding = UDim.new(0, 10); List.HorizontalAlignment = "Center"

-- --- HÀM TẠO COMPONENT ---
local function AddInput(label, default, callback)
    local f = Instance.new("Frame", Container); f.Size = UDim2.new(0.95, 0, 0, 35); f.BackgroundTransparency = 1
    local l = Instance.new("TextLabel", f); l.Size = UDim2.new(0.6, 0, 1, 0); l.Text = label; l.TextColor3 = Color3.new(1,1,1)
    l.TextXAlignment = "Left"; l.BackgroundTransparency = 1; l.Font = "SourceSans"
    local i = Instance.new("TextBox", f); i.Size = UDim2.new(0.35, 0, 0.8, 0); i.Position = UDim2.new(0.65, 0, 0.1, 0)
    i.Text = tostring(default); i.BackgroundColor3 = Color3.fromRGB(30, 30, 30); i.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", i)
    i.FocusLost:Connect(function() callback(i.Text) end)
end

local function AddToggle(txt, callback)
    local b = Instance.new("TextButton", Container); b.Size = UDim2.new(0.95, 0, 0, 40); b.Text = txt .. ": OFF"
    b.BackgroundColor3 = Color3.fromRGB(25, 25, 25); b.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", b)
    local s = false
    b.MouseButton1Click:Connect(function()
        s = not s; callback(s)
        b.Text = txt .. (s and ": ON" or ": OFF")
        b.BackgroundColor3 = s and Color3.fromRGB(0, 170, 255) or Color3.fromRGB(25, 25, 25)
    end)
end

-- --- THIẾT LẬP MENU ---
AddToggle("AUTO FARM", function(v) _G.AutoFarm = v end)
AddToggle("AUTO SELL", function(v) _G.AutoSell = v end)
AddInput("Delay Z (giây):", 0.5, function(t) _G.DelayZ = tonumber(t) or 0.5 end)
AddInput("Delay X (giây):", 0.5, function(t) _G.DelayX = tonumber(t) or 0.5 end)
AddInput("Delay C (giây):", 0.5, function(t) _G.DelayC = tonumber(t) or 0.5 end)
AddInput("Delay V (giây):", 0.5, function(t) _G.DelayV = tonumber(t) or 0.5 end)

-- --- CORE LOGIC (VẬN HÀNH BỞI THỐNG HUB) ---
task.spawn(function()
    while true do
        if _G.AutoFarm then
            -- Click nhấp câu
            local x, y = Target.AbsolutePosition.X + 22, Target.AbsolutePosition.Y + 22
            VIM:SendMouseButtonEvent(x, y, 0, true, game, 1); task.wait(0.01); VIM:SendMouseButtonEvent(x, y, 0, false, game, 1)

            -- Combo chiêu thức với delay riêng biệt
            local skills = {
                {K = Enum.KeyCode.Z, D = _G.DelayZ},
                {K = Enum.KeyCode.X, D = _G.DelayX},
                {K = Enum.KeyCode.C, D = _G.DelayC},
                {K = Enum.KeyCode.V, D = _G.DelayV}
            }
            for _, s in ipairs(skills) do
                if not _G.AutoFarm then break end
                VIM:SendKeyEvent(true, s.K, false, game); task.wait(0.05); VIM:SendKeyEvent(false, s.K, false, game)
                task.wait(s.D)
            end
        end
        task.wait(_G.ClickSpeed)
    end
end)
