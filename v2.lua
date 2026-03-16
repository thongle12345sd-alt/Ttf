-- [[ TTF BY THONG V13 - KHFRESH CLONE EDITION ]] --
if not game:IsLoaded() then game.Loaded:Wait() end

local Player = game.Players.LocalPlayer
local VIM = game:GetService("VirtualInputManager")
local pGui = Player:WaitForChild("PlayerGui")

-- Xóa UI cũ
if pGui:FindFirstChild("ThongHubV13") then pGui.ThongHubV13:Destroy() end

-- --- BIẾN HỆ THỐNG (HỌC HỎI CẤU TRÚC KHFRESH) ---
_G.AutoFarm = false
_G.Combo = "Z,X,C"
_G.SkillDelay = 0.5
_G.ClickSpeed = 0.1

-- --- KHỞI TẠO UI PHONG CÁCH HUB ---
local Gui = Instance.new("ScreenGui", pGui); Gui.Name = "ThongHubV13"; Gui.IgnoreGuiInset = true
local Main = Instance.new("Frame", Gui)
Main.Size = UDim2.new(0, 260, 0, 380); Main.Position = UDim2.new(0.5, -130, 0.4, -190)
Main.BackgroundColor3 = Color3.fromRGB(15, 15, 15); Main.Active = true; Main.Draggable = true
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 8)

-- Nút TARGET (Tâm ngắm)
local Target = Instance.new("TextButton", Gui)
Target.Size = UDim2.new(0, 50, 0, 50); Target.Position = UDim2.new(0.8, 0, 0.5, 0)
Target.BackgroundColor3 = Color3.fromRGB(0, 255, 150); Target.Text = "TARGET"; Target.Draggable = true; Target.Active = true; Target.ZIndex = 100
Instance.new("UICorner", Target).CornerRadius = UDim.new(1, 0)

-- Header
local Header = Instance.new("Frame", Main)
Header.Size = UDim2.new(1, 0, 0, 35); Header.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Instance.new("UICorner", Header)
local Title = Instance.new("TextLabel", Header)
Title.Size = UDim2.new(1, 0, 1, 0); Title.Text = "THONG HUB - BMONKIE STYLE"; Title.TextColor3 = Color3.new(1,1,1); Title.BackgroundTransparency = 1; Title.Font = "SourceSansBold"

-- Container chứa các chức năng
local Container = Instance.new("ScrollingFrame", Main)
Container.Size = UDim2.new(1, -10, 1, -45); Container.Position = UDim2.new(0, 5, 0, 40); Container.BackgroundTransparency = 1; Container.CanvasSize = UDim2.new(0,0,1.5,0); Container.ScrollBarThickness = 2
local List = Instance.new("UIListLayout", Container); List.HorizontalAlignment = "Center"; List.Padding = UDim.new(0, 10)

-- --- CÁC HÀM TẠO COMPONENT (GIỐNG SCRIPT TRÊN) ---
local function AddLabel(txt)
    local l = Instance.new("TextLabel", Container); l.Size = UDim2.new(0.9, 0, 0, 20); l.Text = txt; l.TextColor3 = Color3.fromRGB(200, 200, 200); l.BackgroundTransparency = 1; l.TextXAlignment = "Left"
end

local function AddInput(placeholder, default, callback)
    local i = Instance.new("TextBox", Container)
    i.Size = UDim2.new(0.9, 0, 0, 35); i.PlaceholderText = placeholder; i.Text = default; i.BackgroundColor3 = Color3.fromRGB(25, 25, 25); i.TextColor3 = Color3.new(1,1,1)
    Instance.new("UICorner", i); i.FocusLost:Connect(function() callback(i.Text) end)
end

local function AddToggle(txt, callback)
    local b = Instance.new("TextButton", Container)
    b.Size = UDim2.new(0.9, 0, 0, 40); b.Text = txt .. ": OFF"; b.BackgroundColor3 = Color3.fromRGB(35, 35, 35); b.TextColor3 = Color3.new(1,1,1)
    Instance.new("UICorner", b)
    local state = false
    b.MouseButton1Click:Connect(function()
        state = not state
        b.Text = txt .. (state and ": ON" or ": OFF")
        b.BackgroundColor3 = state and Color3.fromRGB(0, 150, 100) or Color3.fromRGB(35, 35, 35)
        callback(state)
    end)
end

-- --- THIẾT LẬP GIAO DIỆN ---
AddLabel("MAIN FARMING")
AddToggle("AUTO FARM", function(s) _G.AutoFarm = s end)

AddLabel("SETTINGS COMBO")
AddInput("Combo (vd: Z,X,C)", "Z,X,C", function(t) _G.Combo = t end)
AddInput("Delay Skill (s)", "0.5", function(t) _G.SkillDelay = tonumber(t) or 0.5 end)
AddInput("Click Speed (s)", "0.1", function(t) _G.ClickSpeed = tonumber(t) or 0.1 end)

-- --- VÒNG LẶP CORE (HỌC TỪ BMONKIE) ---
task.spawn(function()
    while true do
        if _G.AutoFarm then
            -- Nhấp tại Target (Nhấp liên tục)
            local x, y = Target.AbsolutePosition.X + 25, Target.AbsolutePosition.Y + 25
            VIM:SendMouseButtonEvent(x, y, 0, true, game, 1)
            task.wait(0.02)
            VIM:SendMouseButtonEvent(x, y, 0, false, game, 1)
        end
        task.wait(_G.ClickSpeed)
    end
end)

task.spawn(function()
    while true do
        if _G.AutoFarm then
            -- Combo Skill
            local keys = string.split(_G.Combo, ",")
            for _, k in ipairs(keys) do
                if not _G.AutoFarm then break end
                local key = string.upper(string.gsub(k, " ", ""))
                pcall(function()
                    VIM:SendKeyEvent(true, Enum.KeyCode[key], false, game)
                    task.wait(0.05)
                    VIM:SendKeyEvent(false, Enum.KeyCode[key], false, game)
                end)
                task.wait(_G.SkillDelay)
            end
        end
        task.wait(0.1)
    end
  
