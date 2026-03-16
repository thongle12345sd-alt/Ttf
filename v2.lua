-- [[ ★ THỐNG HUB V23 - ULTIMATE EVOLUTION ★ ]] --
repeat task.wait() until game:IsLoaded()

local Player = game.Players.LocalPlayer
local VIM = game:GetService("VirtualInputManager")
local TweenService = game:GetService("TweenService")
local pGui = Player:WaitForChild("PlayerGui")

-- Xóa sạch UI cũ
for _, old in pairs(pGui:GetChildren()) do
    if old.Name:find("ThốngHub") or old.Name == "ThongTarget" or old.Name == "ThongToggleUI" then old:Destroy() end
end

-- --- HỆ THỐNG BIẾN TOÀN CỤC ---
_G.AutoFarm = false
_G.AutoSell = false
_G.ComboOrder = "Z,X,C,V"
_G.Delays = {Z = 0.5, X = 0.5, C = 0.5, V = 0.5}
_G.FishingCFrame = nil
_G.SellCFrame = nil

-- --- HÀM DI CHUYỂN AN TOÀN ---
local function SafeMove(targetCF)
    local char = Player.Character
    if not char or not targetCF then return end
    local hum = char:FindFirstChild("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart")
    
    hum:MoveTo(targetCF.Position)
    local start = tick()
    while (hrp.Position - targetCF.Position).Magnitude > 5 and tick() - start < 25 do
        if hrp.Velocity.Magnitude < 1 then hum.Jump = true end
        task.wait(0.5)
    end
    hrp.CFrame = targetCF -- Khóa hướng nhìn chuẩn xác
end

-- --- GIAO DIỆN HOA MĨ ---
local Gui = Instance.new("ScreenGui", pGui); Gui.Name = "ThốngHubV23"; Gui.IgnoreGuiInset = true

-- Nút Bật/Tắt UI Gọn Gàng
local ToggleUI = Instance.new("TextButton", Gui); ToggleUI.Name = "ThongToggleUI"
ToggleUI.Size = UDim2.new(0, 40, 0, 40); ToggleUI.Position = UDim2.new(0, 10, 0.5, 0)
ToggleUI.Text = "T"; ToggleUI.BackgroundColor3 = Color3.fromRGB(0, 170, 255); ToggleUI.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", ToggleUI).CornerRadius = UDim.new(1, 0)

local Main = Instance.new("Frame", Gui); Main.Visible = true
Main.Size = UDim2.new(0, 420, 0, 300); Main.Position = UDim2.new(0.5, -210, 0.4, -150)
Main.BackgroundColor3 = Color3.fromRGB(15, 15, 18); Instance.new("UICorner", Main)
local Stroke = Instance.new("UIStroke", Main); Stroke.Color = Color3.fromRGB(40, 40, 45); Stroke.Thickness = 2

-- Chức năng ẩn hiện Menu
ToggleUI.MouseButton1Click:Connect(function() Main.Visible = not Main.Visible end)

-- Sidebar (Tabs)
local Sidebar = Instance.new("Frame", Main); Sidebar.Size = UDim2.new(0, 100, 1, 0); Sidebar.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
Instance.new("UICorner", Sidebar)

local function CreateTabBtn(name, pos)
    local b = Instance.new("TextButton", Sidebar); b.Size = UDim2.new(1, 0, 0, 40); b.Position = UDim2.new(0, 0, 0, pos)
    b.Text = name; b.BackgroundTransparency = 1; b.TextColor3 = Color3.new(1,1,1); b.Font = "SourceSansBold"
    return b
end

local TabF = CreateTabBtn("FARM", 50); local TabS = CreateTabBtn("SELL", 90); local TabSet = CreateTabBtn("SKILL", 130)

-- Page Container
local PageCon = Instance.new("Frame", Main); PageCon.Size = UDim2.new(1, -110, 1, -10); PageCon.Position = UDim2.new(0, 105, 0, 5); PageCon.BackgroundTransparency = 1
local function CreatePage()
    local p = Instance.new("ScrollingFrame", PageCon); p.Size = UDim2.new(1, 0, 1, 0); p.Visible = false; p.BackgroundTransparency = 1; p.CanvasSize = UDim2.new(0,0,2,0); p.ScrollBarThickness = 0
    Instance.new("UIListLayout", p).Padding = UDim.new(0, 8); return p
end

local FarmPage = CreatePage(); local SellPage = CreatePage(); local SkillPage = CreatePage()
FarmPage.Visible = true -- Mặc định hiện Farm

-- Hàm chuyển Tab
local function ShowTab(page)
    FarmPage.Visible = false; SellPage.Visible = false; SkillPage.Visible = false; page.Visible = true
end
TabF.MouseButton1Click:Connect(function() ShowTab(FarmPage) end)
TabS.MouseButton1Click:Connect(function() ShowTab(SellPage) end)
TabSet.MouseButton1Click:Connect(function() ShowTab(SkillPage) end)

-- --- CÁC NÚT ĐIỀU KHIỂN ---
local function AddToggle(p, txt, callback)
    local b = Instance.new("TextButton", p); b.Size = UDim2.new(0.9, 0, 0, 35); b.Text = txt..": OFF"; b.BackgroundColor3 = Color3.fromRGB(30, 30, 35); b.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", b)
    local s = false; b.MouseButton1Click:Connect(function() s = not s; b.Text = txt..(s and ": ON" or ": OFF"); b.BackgroundColor3 = s and Color3.fromRGB(0, 170, 255) or Color3.fromRGB(30, 30, 35); callback(s) end)
end

local function AddInput(p, label, default, callback)
    local f = Instance.new("Frame", p); f.Size = UDim2.new(0.9, 0, 0, 35); f.BackgroundTransparency = 1
    local l = Instance.new("TextLabel", f); l.Size = UDim2.new(0.6, 1, 1, 0); l.Text = label; l.TextColor3 = Color3.new(1,1,1); l.BackgroundTransparency = 1; l.TextXAlignment = "Left"
    local i = Instance.new("TextBox", f); i.Size = UDim2.new(0.35, 0, 0.8, 0); i.Position = UDim2.new(0.6, 0, 0.1, 0); i.Text = tostring(default); i.BackgroundColor3 = Color3.fromRGB(40, 40, 45); i.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", i)
    i.FocusLost:Connect(function() callback(i.Text) end)
end

local function AddBtn(p, txt, callback)
    local b = Instance.new("TextButton", p); b.Size = UDim2.new(0.9, 0, 0, 35); b.Text = txt; b.BackgroundColor3 = Color3.fromRGB(40, 40, 45); b.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", b)
    b.MouseButton1Click:Connect(callback)
end

-- TAB FARM
AddToggle(FarmPage, "AUTO FARM", function(v) _G.AutoFarm = v end)
AddInput(FarmPage, "Thứ tự (vd: Z,X,V):", "Z,X,C,V", function(t) _G.ComboOrder = t end)
AddBtn(FarmPage, "LƯU VỊ TRÍ CÂU", function() _G.FishingCFrame = Player.Character.HumanoidRootPart.CFrame end)

-- TAB SELL
AddToggle(SellPage, "AUTO SELL", function(v) _G.AutoSell = v end)
AddBtn(SellPage, "LƯU VỊ TRÍ BÁN", function() _G.SellCFrame = Player.Character.HumanoidRootPart.CFrame end)

-- TAB SKILL
AddInput(SkillPage, "Delay Z (giây):", 0.5, function(t) _G.Delays.Z = tonumber(t) or 0.5 end)
AddInput(SkillPage, "Delay X (giây):", 0.5, function(t) _G.Delays.X = tonumber(t) or 0.5 end)
AddInput(SkillPage, "Delay C (giây):", 0.5, function(t) _G.Delays.C = tonumber(t) or 0.5 end)
AddInput(SkillPage, "Delay V (giây):", 0.5, function(t) _G.Delays.V = tonumber(t) or 0.5 end)

-- --- CORE LOGIC ---
task.spawn(function()
    while true do
        if _G.AutoFarm then
            -- Click câu cá thần tốc
            VIM:SendMouseButtonEvent(500, 500, 0, true, game, 1); task.wait(0.01); VIM:SendMouseButtonEvent(500, 500, 0, false, game, 1)
            
            -- Xử lý Combo theo thứ tự Thống chọn
            local order = string.split(_G.ComboOrder, ",")
            for _, k in ipairs(order) do
                if not _G.AutoFarm then break end
                local key = string.upper(string.gsub(k, " ", ""))
                if Enum.KeyCode[key] then
                    VIM:SendKeyEvent(true, Enum.KeyCode[key], false, game)
                    task.wait(0.05)
                    VIM:SendKeyEvent(false, Enum.KeyCode[key], false, game)
                    task.wait(_G.Delays[key] or 0.5)
                end
            end
        end
        task.wait(0.1)
    end
end)

-- Vòng lặp Auto Sell (Giả lập kiểm tra túi đầy mỗi 4 phút)
task.spawn(function()
    while true do
        task.wait(240)
        if _G.AutoSell and _G.SellCFrame and _G.FishingCFrame then
            local wasF = _G.AutoFarm; _G.AutoFarm = false
            SafeMove(_G.SellCFrame); task.wait(4)
            SafeMove(_G.FishingCFrame); _G.AutoFarm = wasF
        end
    end
end)
 
