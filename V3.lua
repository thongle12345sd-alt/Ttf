-- [[ ★ THỐNG HUB V25 - HOÀN MỸ ĐẾN TỪNG CHI TIẾT ★ ]] --
repeat task.wait() until game:IsLoaded()

local Player = game.Players.LocalPlayer
local VIM = game:GetService("VirtualInputManager")
local pGui = Player:WaitForChild("PlayerGui")

-- Dọn dẹp tàn dư cũ
for _, old in pairs(pGui:GetChildren()) do
    if old.Name:find("ThốngHub") or old.Name == "ThongToggleUI" then old:Destroy() end
end
task.wait(0.2)

-- --- BIẾN HỆ THỐNG CỦA THỐNG ---
_G.AutoFarm = false
_G.AutoSell = false
_G.ComboOrder = "Z,X,C,V"
_G.Delays = {Z = 0.5, X = 0.5, C = 0.5, V = 0.5}
_G.FishingCF = nil
_G.SellCF = nil

-- --- HÀM DI CHUYỂN AN TOÀN (NO BAN) ---
local function SafeWalk(targetCF)
    local char = Player.Character
    if not char or not targetCF then return end
    local hum = char:FindFirstChild("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hum or not hrp then return end
    
    hum:MoveTo(targetCF.Position)
    local start = tick()
    while (hrp.Position - targetCF.Position).Magnitude > 4 do
        if tick() - start > 20 then break end -- Kẹt quá 20s thì bỏ qua
        if hrp.Velocity.Magnitude < 1 then hum.Jump = true end -- Tự nhảy nếu vướng đá
        task.wait(0.5)
    end
    -- Khóa chính xác tọa độ và hướng nhìn khi đến nơi
    hrp.CFrame = targetCF 
end

-- --- XÂY DỰNG UI (CHỐNG LỖI BẢNG ĐEN) ---
local Gui = Instance.new("ScreenGui")
Gui.Name = "ThốngHubV25"
Gui.ResetOnSpawn = false
Gui.Parent = pGui

-- Nút Bật/Tắt Menu (Tròn, Đẹp)
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0, 45, 0, 45)
ToggleBtn.Position = UDim2.new(0, 15, 0.4, 0)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 255)
ToggleBtn.Text = "MENU"
ToggleBtn.TextColor3 = Color3.new(1,1,1)
ToggleBtn.Font = Enum.Font.GothamBold
Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(1,0)
ToggleBtn.Parent = Gui

-- Khung Main
local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 400, 0, 280)
Main.Position = UDim2.new(0.5, -200, 0.5, -140)
Main.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 8)
Main.Parent = Gui

-- Hiệu ứng ẩn hiện Menu
ToggleBtn.MouseButton1Click:Connect(function() Main.Visible = not Main.Visible end)

-- Khung chứa 3 Tab Button (Top Bar)
local TabBar = Instance.new("Frame")
TabBar.Size = UDim2.new(1, 0, 0, 40)
TabBar.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
Instance.new("UICorner", TabBar).CornerRadius = UDim.new(0, 8)
TabBar.Parent = Main

local function CreateTabBtn(txt, pos, size)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(size, 0, 1, 0)
    b.Position = UDim2.new(pos, 0, 0, 0)
    b.BackgroundTransparency = 1
    b.Text = txt
    b.TextColor3 = Color3.new(0.7, 0.7, 0.7)
    b.Font = Enum.Font.GothamBold
    b.Parent = TabBar
    return b
end

local bFarm = CreateTabBtn("AUTO FARM", 0, 0.33)
local bSell = CreateTabBtn("AUTO SELL", 0.33, 0.33)
local bSet = CreateTabBtn("SETTING", 0.66, 0.33)

-- Khung chứa Nội dung Tab
local PageContainer = Instance.new("Frame")
PageContainer.Size = UDim2.new(1, 0, 1, -45)
PageContainer.Position = UDim2.new(0, 0, 0, 45)
PageContainer.BackgroundTransparency = 1
PageContainer.Parent = Main

local function CreatePage()
    local p = Instance.new("ScrollingFrame")
    p.Size = UDim2.new(1, -20, 1, -10)
    p.Position = UDim2.new(0, 10, 0, 5)
    p.BackgroundTransparency = 1
    p.CanvasSize = UDim2.new(0, 0, 1.5, 0)
    p.ScrollBarThickness = 2
    p.Visible = false
    local l = Instance.new("UIListLayout", p)
    l.Padding = UDim.new(0, 8)
    l.HorizontalAlignment = Enum.HorizontalAlignment.Center
    p.Parent = PageContainer
    return p
end

local pFarm = CreatePage()
local pSell = CreatePage()
local pSet = CreatePage()
pFarm.Visible = true; bFarm.TextColor3 = Color3.new(1,1,1) -- Mặc định hiện Farm

-- Hàm chuyển Tab mượt
local function SwitchTab(btn, page)
    pFarm.Visible = false; pSell.Visible = false; pSet.Visible = false
    bFarm.TextColor3 = Color3.new(0.7,0.7,0.7); bSell.TextColor3 = Color3.new(0.7,0.7,0.7); bSet.TextColor3 = Color3.new(0.7,0.7,0.7)
    page.Visible = true; btn.TextColor3 = Color3.new(1,1,1)
end
bFarm.MouseButton1Click:Connect(function() SwitchTab(bFarm, pFarm) end)
bSell.MouseButton1Click:Connect(function() SwitchTab(bSell, pSell) end)
bSet.MouseButton1Click:Connect(function() SwitchTab(bSet, pSet) end)

-- --- CÁC HÀM TẠO ELEMENT (FIX CHUẨN) ---
local function AddToggle(parent, txt, callback)
    task.wait(0.05)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0.95, 0, 0, 35)
    b.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    b.Text = txt .. " [TẮT]"
    b.TextColor3 = Color3.new(1,1,1)
    b.Font = Enum.Font.Gotham
    Instance.new("UICorner", b).CornerRadius = UDim.new(0,6)
    b.Parent = parent
    
    local state = false
    b.MouseButton1Click:Connect(function()
        state = not state
        b.BackgroundColor3 = state and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(35, 35, 45)
        b.Text = txt .. (state and " [BẬT]" or " [TẮT]")
        callback(state)
    end)
end

local function AddInput(parent, label, default, callback)
    task.wait(0.05)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(0.95, 0, 0, 35)
    f.BackgroundTransparency = 1
    f.Parent = parent
    
    local l = Instance.new("TextLabel", f)
    l.Size = UDim2.new(0.5, 0, 1, 0)
    l.Text = label
    l.TextColor3 = Color3.new(1,1,1)
    l.BackgroundTransparency = 1
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.Font = Enum.Font.Gotham
    
    local i = Instance.new("TextBox", f)
    i.Size = UDim2.new(0.45, 0, 0.8, 0)
    i.Position = UDim2.new(0.55, 0, 0.1, 0)
    i.Text = tostring(default)
    i.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    i.TextColor3 = Color3.new(1,1,1)
    i.Font = Enum.Font.Gotham
    Instance.new("UICorner", i)
    i.FocusLost:Connect(function() callback(i.Text) end)
end

local function AddBtn(parent, txt, callback)
    task.wait(0.05)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0.95, 0, 0, 35)
    b.Text = txt
    b.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    b.TextColor3 = Color3.new(1,1,1)
    b.Font = Enum.Font.GothamBold
    Instance.new("UICorner", b).CornerRadius = UDim.new(0,6)
    b.Parent = parent
    b.MouseButton1Click:Connect(callback)
end

-- --- THÊM CHỨC NĂNG VÀO TỪNG TAB ---
-- TAB 1: FARM
AddToggle(pFarm, "BẬT AUTO FARM", function(v) _G.AutoFarm = v end)
AddInput(pFarm, "Thứ tự Skill (vd: z,x,c,v):", "z,x,c,v", function(t) _G.ComboOrder = t end)
AddBtn(pFarm, "📍 LƯU VỊ TRÍ & HƯỚNG CÂU", function() _G.FishingCF = Player.Character.HumanoidRootPart.CFrame end)

-- TAB 2: SELL
AddToggle(pSell, "BẬT AUTO SELL (ĐI BỘ)", function(v) _G.AutoSell = v end)
AddBtn(pSell, "📍 LƯU VỊ TRÍ NPC BÁN", function() _G.SellCF = Player.Character.HumanoidRootPart.CFrame end)

-- TAB 3: SETTING
AddInput(pSet, "Thời gian ném Z (giây):", 0.5, function(t) _G.Delays.Z = tonumber(t) or 0.5 end)
AddInput(pSet, "Thời gian ném X (giây):", 0.5, function(t) _G.Delays.X = tonumber(t) or 0.5 end)
AddInput(pSet, "Thời gian ném C (giây):", 0.5, function(t) _G.Delays.C = tonumber(t) or 0.5 end)
AddInput(pSet, "Thời gian ném V (giây):", 0.5, function(t) _G.Delays.V = tonumber(t) or 0.5 end)

-- --- CORE LOGIC VẬN HÀNH ---
task.spawn(function()
    while true do
        if _G.AutoFarm then
            -- 1. Click câu cá (Dùng vị trí giữa màn hình cho chuẩn)
            VIM:SendMouseButtonEvent(500, 500, 0, true, game, 1)
            task.wait(0.01)
            VIM:SendMouseButtonEvent(500, 500, 0, false, game, 1)
            
            -- 2. Đọc thứ tự Skill (Tự động nhận diện chữ hoa/thường)
            local rawOrder = string.gsub(_G.ComboOrder, " ", "") -- Xóa khoảng trắng
            local keys = string.split(rawOrder, ",")
            
            for _, k in pairs(keys) do
                if not _G.AutoFarm then break end
                local keyName = string.upper(k) -- Tự động viết hoa (z -> Z)
                
                if Enum.KeyCode[keyName] then
                    pcall(function()
                        VIM:SendKeyEvent(true, Enum.KeyCode[keyName], false, game)
                        task.wait(0.05)
                        VIM:SendKeyEvent(false, Enum.KeyCode[keyName], false, game)
                    end)
                    -- Đợi đúng thời gian Thống đã cài cho chiêu đó
                    task.wait(_G.Delays[keyName] or 0.5) 
                end
            end
        end
        task.wait(0.1)
    end
end)

-- Vòng lặp tự đi bán (Khoảng 3-4 phút 1 lần)
task.spawn(function()
    while true do
        task.wait(200) -- Chờ khoảng hơn 3 phút
        if _G.AutoSell and _G.SellCF and _G.FishingCF then
            local oldFarmState = _G.AutoFarm
            _G.AutoFarm = false -- Tạm dừng farm
            
            SafeWalk(_G.SellCF) -- Đi đến chỗ bán
            task.wait(3) -- Đợi 3 giây để game xử lý bán cá
            
            SafeWalk(_G.FishingCF) -- Quay về chỗ câu, tự động xoay đúng hướng
            _G.AutoFarm = oldFarmState -- Trả lại trạng thái farm
        end
    end
end)
 
