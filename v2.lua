-- [[ TTF BY THONG V14 - FIX MENU & FORCE SHOW ]] --
repeat task.wait() until game:IsLoaded()

local Player = game.Players.LocalPlayer
local VIM = game:GetService("VirtualInputManager")
local pGui = Player:WaitForChild("PlayerGui")

-- Xóa sạch mọi phiên bản UI cũ để tránh bị kẹt (Fix lỗi không hiện menu)
for _, old in pairs(pGui:GetChildren()) do
    if old.Name:find("ThongHub") or old.Name == "ThongTarget" then
        old:Destroy()
    end
end

-- --- BIẾN HỆ THỐNG ---
_G.AutoFarm = false
_G.Combo = "Z,X,C"
_G.SkillDelay = 0.5
_G.ClickSpeed = 0.1

-- --- TẠO UI (DÙNG CƠ CHẾ AN TOÀN) ---
local Gui = Instance.new("ScreenGui")
Gui.Name = "ThongHubV14"
Gui.Parent = pGui
Gui.IgnoreGuiInset = true
Gui.ResetOnSpawn = false -- Giữ menu khi nhân vật hồi sinh

local Main = Instance.new("Frame", Gui)
Main.Size = UDim2.new(0, 240, 0, 360)
Main.Position = UDim2.new(0.5, -120, 0.5, -180) -- Hiện ngay giữa màn hình
Main.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Main.Active = true
Main.Draggable = true -- Cho phép kéo Menu đi
Instance.new("UICorner", Main)

-- Nút TARGET (Tâm ngắm) - LUÔN HIỆN
local Target = Instance.new("TextButton", Gui)
Target.Name = "ThongTarget"
Target.Size = UDim2.new(0, 50, 0, 50)
Target.Position = UDim2.new(0.8, 0, 0.5, 0)
Target.BackgroundColor3 = Color3.fromRGB(0, 255, 150)
Target.Text = "TARGET"
Target.Draggable = true
Target.Active = true
Target.ZIndex = 100
Instance.new("UICorner", Target).CornerRadius = UDim.new(1, 0)

-- Header
local Header = Instance.new("TextLabel", Main)
Header.Size = UDim2.new(1, 0, 0, 40)
Header.Text = "THONG HUB - V14"
Header.TextColor3 = Color3.new(1,1,1)
Header.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Header.Font = Enum.Font.SourceSansBold
Header.TextSize = 16
Instance.new("UICorner", Header)

-- Container chứa chức năng
local Container = Instance.new("ScrollingFrame", Main)
Container.Size = UDim2.new(1, -10, 1, -50)
Container.Position = UDim2.new(0, 5, 0, 45)
Container.BackgroundTransparency = 1
Container.CanvasSize = UDim2.new(0,0,1.5,0)
Container.ScrollBarThickness = 3
local List = Instance.new("UIListLayout", Container)
List.HorizontalAlignment = "Center"
List.Padding = UDim.new(0, 8)

-- --- CÁC HÀM TIỆN ÍCH ---
local function AddInput(placeholder, default, callback)
    local i = Instance.new("TextBox", Container)
    i.Size = UDim2.new(0.9, 0, 0, 35)
    i.PlaceholderText = placeholder
    i.Text = default
    i.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    i.TextColor3 = Color3.new(1,1,1)
    Instance.new("UICorner", i)
    i.FocusLost:Connect(function() callback(i.Text) end)
end

local function AddToggle(txt, callback)
    local b = Instance.new("TextButton", Container)
    b.Size = UDim2.new(0.9, 0, 0, 40)
    b.Text = txt .. ": OFF"
    b.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    b.TextColor3 = Color3.new(1,1,1)
    Instance.new("UICorner", b)
    local state = false
    b.MouseButton1Click:Connect(function()
        state = not state
        b.Text = txt .. (state and ": ON" or ": OFF")
        b.BackgroundColor3 = state and Color3.fromRGB(0, 180, 100) or Color3.fromRGB(50, 50, 60)
        callback(state)
    end)
end

-- THIẾT LẬP MENU
AddToggle("AUTO FARM", function(s) _G.AutoFarm = s end)
AddInput("Combo (Z,X,C)", "Z,X,C", function(t) _G.Combo = t end)
AddInput("Delay Skill (s)", "0.5", function(t) _G.SkillDelay = tonumber(t) or 0.5 end)
AddInput("Click Speed (s)", "0.1", function(t) _G.ClickSpeed = tonumber(t) or 0.1 end)

-- --- CORE LOGIC (VIM & TASK) ---
task.spawn(function()
    while true do
        if _G.AutoFarm then
            local x, y = Target.AbsolutePosition.X + 25, Target.AbsolutePosition.Y + 25
            VIM:SendMouseButtonEvent(x, y, 0, true, game, 1)
            task.wait(0.01)
            VIM:SendMouseButtonEvent(x, y, 0, false, game, 1)
        end
        task.wait(_G.ClickSpeed)
    end
end)

task.spawn(function()
    while true do
        if _G.AutoFarm then
            local keys = string.split(_G.Combo, ",")
            for _, k in ipairs(keys) do
                if not _G.AutoFarm then break end
                local key = string.upper(string.gsub(k, " ", ""))
                pcall(function()
                    VIM:SendKeyEvent(true, Enum.KeyCode[key], false, game)
                    task.wait(
 
