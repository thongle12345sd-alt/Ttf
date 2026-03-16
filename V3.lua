-- [[ ★ THỐNG HUB V30 - SPECIAL NPC INTERACT ★ ]] --
repeat task.wait() until game:IsLoaded()

local Player = game.Players.LocalPlayer
local VIM = game:GetService("VirtualInputManager")
local pGui = Player:WaitForChild("PlayerGui")

-- Dọn dẹp cũ
for _, v in pairs(pGui:GetChildren()) do
    if v.Name == "ThongHubV30" or v.Name == "ThongToggle" then v:Destroy() end
end

-- --- SETTINGS ---
_G.AutoFarm = false
_G.AutoSell = false
_G.Combo = "z,x,c,v"
_G.FishingCF = nil
_G.SellCF = nil
_G.Delays = {Z = 0.5, X = 0.5, C = 0.5, V = 0.5}

-- --- HÀM DI CHUYỂN & TƯƠNG TÁC NPC ---
local function TitanMoveAndSell(targetCF)
    local char = Player.Character
    local hum = char:FindFirstChild("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart")
    
    -- 1. Chạy bộ đến NPC
    hum:MoveTo(targetCF.Position)
    local start = tick()
    while (hrp.Position - targetCF.Position).Magnitude > 6 do
        if tick() - start > 25 then break end
        if hrp.Velocity.Magnitude < 1 then hum.Jump = true end
        task.wait(0.5)
    end
    
    -- 2. Nhấn phím E để mở Menu bán (Theo ảnh Thống gửi)
    task.wait(1)
    VIM:SendKeyEvent(true, Enum.KeyCode.E, false, game)
    task.wait(0.1)
    VIM:SendKeyEvent(false, Enum.KeyCode.E, false, game)
    
    -- 3. Đợi bảng "Bán hết" hiện ra rồi Click (Tọa độ ước tính cho nút Bán Hết)
    task.wait(1.5)
    VIM:SendMouseButtonEvent(450, 700, 0, true, game, 1) -- Vị trí nút "Bán hết"
    task.wait(0.1)
    VIM:SendMouseButtonEvent(450, 700, 0, false, game, 1)
    task.wait(1)
end

-- --- GIAO DIỆN (3 TAB RÕ RÀNG) ---
local Gui = Instance.new("ScreenGui", pGui); Gui.Name = "ThongHubV30"
local Toggle = Instance.new("TextButton", Gui); Toggle.Name = "ThongToggle"
Toggle.Size = UDim2.new(0, 50, 0, 50); Toggle.Position = UDim2.new(0, 10, 0.4, 0)
Toggle.Text = "MENU"; Toggle.BackgroundColor3 = Color3.fromRGB(0, 170, 255); Toggle.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", Toggle).CornerRadius = UDim.new(1, 0)

local Main = Instance.new("Frame", Gui); Main.Size = UDim2.new(0, 350, 0, 300); Main.Position = UDim2.new(0.5, -175, 0.4, -150); Main.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
Instance.new("UICorner", Main)
Toggle.MouseButton1Click:Connect(function() Main.Visible = not Main.Visible end)

-- Tabs
local Sidebar = Instance.new("Frame", Main); Sidebar.Size = UDim2.new(0, 80, 1, 0); Sidebar.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
local PageCon = Instance.new("Frame", Main); PageCon.Size = UDim2.new(1, -90, 1, -10); PageCon.Position = UDim2.new(0, 85, 0, 5); PageCon.BackgroundTransparency = 1

local function CreateTab(name, y)
    local b = Instance.new("TextButton", Sidebar); b.Size = UDim2.new(1, -10, 0, 35); b.Position = UDim2.new(0, 5, 0, y); b.Text = name; b.BackgroundColor3 = Color3.fromRGB(40,40,45); b.TextColor3 = Color3.new(1,1,1)
    Instance.new("UICorner", b)
    local p = Instance.new("ScrollingFrame", PageCon); p.Size = UDim2.new(1, 0, 1, 0); p.Visible = false; p.BackgroundTransparency = 1; p.CanvasSize = UDim2.new(0,0,2,0)
    Instance.new("UIListLayout", p).Padding = UDim.new(0, 5)
    b.MouseButton1Click:Connect(function() for _,v in pairs(PageCon:GetChildren()) do v.Visible = false end p.Visible = true end)
    return p
end

local pFarm = CreateTab("FARM", 10); pFarm.Visible = true
local pSell = CreateTab("SELL", 50)
local pSet = CreateTab("SET", 90)

-- --- CÁC NÚT BẤM (FIXED) ---
local function AddToggle(parent, txt, callback)
    local b = Instance.new("TextButton", parent); b.Size = UDim2.new(0.95, 0, 0, 35); b.Text = txt..": OFF"; b.BackgroundColor3 = Color3.fromRGB(30, 30, 35); b.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", b)
    local s = false; b.MouseButton1Click:Connect(function() s = not s; b.Text = txt..(s and ": ON" or ": OFF"); b.BackgroundColor3 = s and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(30,30,35); callback(s) end)
end

-- PAGE FARM
AddToggle(pFarm, "TỰ NHẤP CÂU", function(v) _G.AutoFarm = v end)
local lcF = Instance.new("TextButton", pFarm); lcF.Size = UDim2.new(0.95, 0, 0, 35); lcF.Text = "LƯU VỊ TRÍ CÂU"; lcF.BackgroundColor3 = Color3.fromRGB(50, 70, 50); lcF.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", lcF)
lcF.MouseButton1Click:Connect(function() _G.FishingCF = Player.Character.HumanoidRootPart.CFrame end)

-- PAGE SELL
AddToggle(pSell, "TỰ CHẠY ĐI BÁN", function(v) _G.AutoSell = v end)
local lcS = Instance.new("TextButton", pSell); lcS.Size = UDim2.new(0.95, 0, 0, 35); lcS.Text = "LƯU VỊ TRÍ NPC"; lcS.BackgroundColor3 = Color3.fromRGB(70, 50, 50); lcS.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", lcS)
lcS.MouseButton1Click:Connect(function() _G.SellCF = Player.Character.HumanoidRootPart.CFrame end)

-- --- LOGIC ---
task.spawn(function()
    while true do
        if _G.AutoFarm then
            VIM:SendMouseButtonEvent(500, 500, 0, true, game, 1); task.wait(0.01); VIM:SendMouseButtonEvent(500, 500, 0, false, game, 1)
            local keys = string.split(string.gsub(_G.Combo, " ", ""), ",")
            for _, k in pairs(keys) do
                local kn = string.upper(k)
                if Enum.KeyCode[kn] then
                    VIM:SendKeyEvent(true, Enum.KeyCode[kn], false, game); task.wait(0.05); VIM:SendKeyEvent(false, Enum.KeyCode[kn], false, game)
                    task.wait(_G.Delays[kn] or 0.5)
                end
            end
        end
        task.wait(0.1)
    end
end)

task.spawn(function()
    while true do
        task.wait(180) -- 3 phút đi bán 1 lần
        if _G.AutoSell and _G.SellCF and _G.FishingCF then
            local old = _G.AutoFarm; _G.AutoFarm = false
            TitanMoveAndSell(_G.SellCF)
            task.wait(2)
            Player.Character.HumanoidRootPart.CFrame = _G.FishingCF -- Quay về nhanh để câu tiếp
            _G.AutoFarm = old
        end
    end
end)
