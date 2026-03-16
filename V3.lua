-- [[ ★ THỐNG HUB V29 - NO KEY TITAN CLONE ★ ]] --
-- Bản quyền thuộc về Thống - Không cần Get Key
repeat task.wait() until game:IsLoaded()

local Player = game.Players.LocalPlayer
local VIM = game:GetService("VirtualInputManager")
local pGui = Player:WaitForChild("PlayerGui")

-- Dọn dẹp tàn dư
for _, v in pairs(pGui:GetChildren()) do
    if v.Name == "ThongHubV29" or v.Name == "ThongToggle" then v:Destroy() end
end

-- --- SETTINGS ---
_G.AutoFarm = false
_G.AutoSell = false
_G.Combo = "z,x,c,v"
_G.FishingCF = nil
_G.SellCF = nil
_G.Delays = {Z = 0.5, X = 0.5, C = 0.5, V = 0.5}

-- --- HÀM CHẠY BỘ AN TOÀN (SAFEWALK) ---
local function SafeRun(targetCF)
    local char = Player.Character
    if not char or not targetCF then return end
    local hum = char:FindFirstChild("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart")
    
    if hum and hrp then
        hum:MoveTo(targetCF.Position)
        local start = tick()
        while (hrp.Position - targetCF.Position).Magnitude > 5 do
            if tick() - start > 30 then break end
            if hrp.Velocity.Magnitude < 1 then hum.Jump = true end
            task.wait(0.5)
        end
        hrp.CFrame = targetCF -- Khóa hướng nhìn đúng lúc lưu
    end
end

-- --- GIAO DIỆN (3 TAB - HOA MỸ - KHÔNG LỖI) ---
local Gui = Instance.new("ScreenGui", pGui); Gui.Name = "ThongHubV29"
local Toggle = Instance.new("TextButton", Gui); Toggle.Name = "ThongToggle"
Toggle.Size = UDim2.new(0, 45, 0, 45); Toggle.Position = UDim2.new(0, 10, 0.5, 0)
Toggle.BackgroundColor3 = Color3.fromRGB(0, 170, 255); Toggle.Text = "MENU"; Toggle.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", Toggle).CornerRadius = UDim.new(1, 0)

local Main = Instance.new("Frame", Gui); Main.Visible = true
Main.Size = UDim2.new(0, 380, 0, 320); Main.Position = UDim2.new(0.5, -190, 0.4, -160)
Main.BackgroundColor3 = Color3.fromRGB(15, 15, 15); Instance.new("UICorner", Main)
Toggle.MouseButton1Click:Connect(function() Main.Visible = not Main.Visible end)

-- Sidebar Tabs
local Sidebar = Instance.new("Frame", Main); Sidebar.Size = UDim2.new(0, 90, 1, 0); Sidebar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
local PageCon = Instance.new("Frame", Main); PageCon.Size = UDim2.new(1, -100, 1, -10); PageCon.Position = UDim2.new(0, 95, 0, 5); PageCon.BackgroundTransparency = 1

local function CreateTab(name, pos)
    local b = Instance.new("TextButton", Sidebar); b.Size = UDim2.new(1, -10, 0, 35); b.Position = UDim2.new(0, 5, 0, pos)
    b.Text = name; b.BackgroundColor3 = Color3.fromRGB(40, 40, 40); b.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", b)
    local p = Instance.new("ScrollingFrame", PageCon); p.Size = UDim2.new(1, 0, 1, 0); p.Visible = false; p.BackgroundTransparency = 1; p.CanvasSize = UDim2.new(0,0,2,0)
    Instance.new("UIListLayout", p).Padding = UDim.new(0, 5)
    b.MouseButton1Click:Connect(function()
        for _, v in pairs(PageCon:GetChildren()) do v.Visible = false end
        p.Visible = true
    end)
    return p, b
end

local pFarm, bFarm = CreateTab("FARM", 10); pFarm.Visible = true
local pSell, bSell = CreateTab("SELL", 50)
local pSet, bSet = CreateTab("SKILL", 90)

-- --- CÁC NÚT ĐIỀU KHIỂN ---
local function AddToggle(parent, txt, callback)
    local b = Instance.new("TextButton", parent); b.Size = UDim2.new(0.95, 0, 0, 35); b.Text = txt..": OFF"; b.BackgroundColor3 = Color3.fromRGB(30, 30, 30); b.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", b)
    local s = false; b.MouseButton1Click:Connect(function() s = not s; b.Text = txt..(s and ": ON" or ": OFF"); b.BackgroundColor3 = s and Color3.fromRGB(0, 170, 255) or Color3.fromRGB(30, 30, 30); callback(s) end)
end

local function AddInput(parent, label, default, callback)
    local f = Instance.new("Frame", parent); f.Size = UDim2.new(0.95, 0, 0, 35); f.BackgroundTransparency = 1
    local l = Instance.new("TextLabel", f); l.Size = UDim2.new(0.6, 0, 1, 0); l.Text = label; l.TextColor3 = Color3.new(1,1,1); l.BackgroundTransparency = 1; l.TextXAlignment = "Left"
    local i = Instance.new("TextBox", f); i.Size = UDim2.new(0.35, 0, 0.8, 0); i.Position = UDim2.new(0.65, 0, 0.1, 0); i.Text = tostring(default); i.BackgroundColor3 = Color3.fromRGB(40, 40, 40); i.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", i)
    i.FocusLost:Connect(function() callback(i.Text) end)
end

-- PAGE FARM
AddToggle(pFarm, "AUTO FARM", function(v) _G.AutoFarm = v end)
AddInput(pFarm, "Thứ tự (z,x,c,v):", "z,x,c,v", function(t) _G.Combo = t end)
local btnLuuF = Instance.new("TextButton", pFarm); btnLuuF.Size = UDim2.new(0.95, 0, 0, 35); btnLuuF.Text = "LƯU VỊ TRÍ CÂU"; btnLuuF.BackgroundColor3 = Color3.fromRGB(40, 60, 40); btnLuuF.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", btnLuuF)
btnLuuF.MouseButton1Click:Connect(function() _G.FishingCF = Player.Character.HumanoidRootPart.CFrame end)

-- PAGE SELL
AddToggle(pSell, "AUTO SELL", function(v) _G.AutoSell = v end)
local btnLuuS = Instance.new("TextButton", pSell); btnLuuS.Size = UDim2.new(0.95, 0, 0, 35); btnLuuS.Text = "LƯU VỊ TRÍ BÁN"; btnLuuS.BackgroundColor3 = Color3.fromRGB(60, 40, 40); btnLuuS.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", btnLuuS)
btnLuuS.MouseButton1Click:Connect(function() _G.SellCF = Player.Character.HumanoidRootPart.CFrame end)

-- PAGE SKILL (DELAY RIÊNG BIỆT)
AddInput(pSet, "Delay Z (s):", 0.5, function(t) _G.Delays.Z = tonumber(t) or 0.5 end)
AddInput(pSet, "Delay X (s):", 0.5, function(t) _G.Delays.X = tonumber(t) or 0.5 end)
AddInput(pSet, "Delay C (s):", 0.5, function(t) _G.Delays.C = tonumber(t) or 0.5 end)
AddInput(pSet, "Delay V (s):", 0.5, function(t) _G.Delays.V = tonumber(t) or 0.5 end)

-- --- LOGIC VẬN HÀNH ---
task.spawn(function()
    while true do
        if _G.AutoFarm then
            VIM:SendMouseButtonEvent(500, 500, 0, true, game, 1); task.wait(0.01); VIM:SendMouseButtonEvent(500, 500, 0, false, game, 1)
            local order = string.split(string.gsub(_G.Combo, " ", ""), ",")
            for _, k in pairs(order) do
                if not _G.AutoFarm then break end
                local key = string.upper(k)
                if Enum.KeyCode[key] then
                    VIM:SendKeyEvent(true, Enum.KeyCode[key], false, game); task.wait(0.05); VIM:SendKeyEvent(false, Enum.KeyCode[key], false, game)
                    task.wait(_G.Delays[key] or 0.5)
                end
            end
        end
        task.wait(0.1)
    end
end)

task.spawn(function()
    while true do
        task.wait(240) -- 4 phút đi bán 1 lần
        if _G.AutoSell and _G.SellCF and _G.FishingCF then
            local wasF = _G.AutoFarm; _G.AutoFarm = false
            SafeRun(_G.SellCF); task.wait(5); SafeRun(_G.FishingCF); _G.AutoFarm = wasF
        end
    end
end)
 
