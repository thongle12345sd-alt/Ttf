-- [[ ★ THỐNG HUB V27 - REALISTIC RUNNER (NO TELEPORT) ★ ]] --
repeat task.wait() until game:IsLoaded()

local Player = game.Players.LocalPlayer
local VIM = game:GetService("VirtualInputManager")
local pGui = Player:WaitForChild("PlayerGui")

-- Xóa UI cũ
for _, v in pairs(pGui:GetChildren()) do
    if v.Name == "ThongHubV27" then v:Destroy() end
end

-- --- CÀI ĐẶT ---
_G.AutoFarm = false
_G.AutoSell = false
_G.Combo = "Z,X,C,V"
_G.FishingCF = nil
_G.SellCF = nil
_G.SkillDelay = 0.5

-- --- HÀM CHẠY BỘ AN TOÀN (DI CHUYỂN THỰC TẾ) ---
local function ThongRunner(targetCF)
    local char = Player.Character
    if not char or not targetCF then return end
    local hum = char:FindFirstChild("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart")
    
    if hum and hrp then
        -- Lệnh di chuyển chân chạm đất
        hum:MoveTo(targetCF.Position)
        
        -- Kiểm tra xem đã đến chưa (Magnitude < 5 là dừng)
        local start = tick()
        while (hrp.Position - targetCF.Position).Magnitude > 5 do
            if not _G.AutoSell then break end
            if tick() - start > 30 then break end -- Timeout 30s nếu kẹt
            
            -- Nếu đứng im quá lâu (bị kẹt vật cản) thì nhảy lên
            if hrp.Velocity.Magnitude < 1 then
                hum.Jump = true
            end
            task.wait(0.5)
        end
        -- Khi đến nơi, khóa lại đúng hướng nhìn đã lưu
        hrp.CFrame = targetCF
    end
end

-- --- GIAO DIỆN (ĐƠN GIẢN - CHỐNG LỖI) ---
local Gui = Instance.new("ScreenGui", pGui); Gui.Name = "ThongHubV27"
local Main = Instance.new("Frame", Gui)
Main.Size = UDim2.new(0, 260, 0, 320); Main.Position = UDim2.new(0.5, -130, 0.4, -160)
Main.BackgroundColor3 = Color3.fromRGB(25, 25, 30); Main.Active = true; Main.Draggable = true
Instance.new("UICorner", Main)

local List = Instance.new("UIListLayout", Main)
List.Padding = UDim.new(0, 5); List.HorizontalAlignment = "Center"

local function AddBtn(txt, color, callback)
    local b = Instance.new("TextButton", Main)
    b.Size = UDim2.new(0.9, 0, 0, 40); b.Text = txt; b.BackgroundColor3 = color; b.TextColor3 = Color3.new(1,1,1)
    b.Font = "SourceSansBold"; Instance.new("UICorner", b)
    b.MouseButton1Click:Connect(function() callback(b) end)
end

-- --- NÚT BẤM ---
AddBtn("FARM: OFF", Color3.fromRGB(60, 60, 70), function(self)
    _G.AutoFarm = not _G.AutoFarm
    self.Text = _G.AutoFarm and "FARM: ON" or "FARM: OFF"
    self.BackgroundColor3 = _G.AutoFarm and Color3.fromRGB(0, 150, 255) or Color3.fromRGB(60, 60, 70)
end)

AddBtn("SELL (CHẠY BỘ): OFF", Color3.fromRGB(60, 60, 70), function(self)
    _G.AutoSell = not _G.AutoSell
    self.Text = _G.AutoSell and "SELL: ON" or "SELL: OFF"
    self.BackgroundColor3 = _G.AutoSell and Color3.fromRGB(0, 150, 255) or Color3.fromRGB(60, 60, 70)
end)

AddBtn("LƯU VỊ TRÍ CÂU", Color3.fromRGB(40, 100, 40), function()
    _G.FishingCF = Player.Character.HumanoidRootPart.CFrame
end)

AddBtn("LƯU VỊ TRÍ BÁN", Color3.fromRGB(100, 40, 40), function()
    _G.SellCF = Player.Character.HumanoidRootPart.CFrame
end)

-- --- LOGIC FARM & SKILL ---
task.spawn(function()
    while true do
        if _G.AutoFarm then
            -- Giả lập nhấp chuột câu cá
            VIM:SendMouseButtonEvent(500, 500, 0, true, game, 1); task.wait(0.01)
            VIM:SendMouseButtonEvent(500, 500, 0, false, game, 1)
            
            -- Combo chiêu Z,X,C,V
            for _, k in pairs({"Z", "X", "C", "V"}) do
                if not _G.AutoFarm then break end
                VIM:SendKeyEvent(true, Enum.KeyCode[k], false, game); task.wait(0.05)
                VIM:SendKeyEvent(false, Enum.KeyCode[k], false, game)
                task.wait(_G.SkillDelay)
            end
        end
        task.wait(0.1)
    end
end)

-- LOGIC TỰ ĐỘNG CHẠY ĐI BÁN (Mỗi 5 phút một lần)
task.spawn(function()
    while true do
        task.wait(300) -- Treo máy 5 phút thì đi bán
        if _G.AutoSell and _G.SellCF and _G.FishingCF then
            local oldFarm = _G.AutoFarm
            _G.AutoFarm = false -- Ngừng farm để chạy cho mượt
            
            ThongRunner(_G.SellCF) -- Chạy bộ tới NPC
            task.wait(5)           -- Đợi bán cá
            ThongRunner(_G.FishingCF) -- Chạy bộ về lại chỗ câu
            
            _G.AutoFarm = oldFarm  -- Tiếp tục farm
        end
    end
end)
 
