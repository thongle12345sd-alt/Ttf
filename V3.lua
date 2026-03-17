-- [[ ★ THỐNG HUB V31 - STABLE ENGINE ★ ]] --
repeat task.wait() until game:IsLoaded()

local Player = game.Players.LocalPlayer
local VU = game:GetService("VirtualUser")
local pGui = Player:WaitForChild("PlayerGui")

-- Dọn dẹp UI cũ để tránh kẹt bộ nhớ
for _, v in pairs(pGui:GetChildren()) do
    if v.Name == "ThongHubV31" or v.Name == "ThongToggle" then v:Destroy() end
end

-- --- BIẾN ĐIỀU KHIỂN ---
_G.AutoFarm = false
_G.AutoSell = false
_G.Combo = {"Z", "X", "C", "V"}
_G.FishingCF = nil
_G.SellCF = nil

-- --- HÀM TỰ ĐỘNG BÁN (CAN THIỆP SERVER) ---
local function DirectSell()
    -- Thay vì bấm E, mình ép nhân vật chạm vào NPC để kích hoạt bảng
    -- Sau đó dùng VirtualUser để click vào nút "Bán hết" dựa trên tên Object
    pcall(function()
        local sellMenu = pGui:FindFirstChild("SellMenu") or pGui:FindFirstChild("ShopGui")
        if sellMenu then
            -- Thống ơi, mình sẽ quét toàn bộ UI để tìm nút có chữ "Bán hết" hoặc "Sell All"
            for _, btn in pairs(sellMenu:GetDescendants()) do
                if btn:IsA("TextButton") and (btn.Text:find("Bán hết") or btn.Name:find("All")) then
                    -- Click trực tiếp vào tâm của nút đó, không sợ sai màn hình
                    local pos = btn.AbsolutePosition
                    local size = btn.AbsoluteSize
                    VU:Button1Down(Vector2.new(pos.X + size.X/2, pos.Y + size.Y/2))
                    task.wait(0.1)
                    VU:Button1Up(Vector2.new(pos.X + size.X/2, pos.Y + size.Y/2))
                end
            end
        end
    end)
end

-- --- GIAO DIỆN SIÊU ỔN ĐỊNH ---
local Gui = Instance.new("ScreenGui", pGui); Gui.Name = "ThongHubV31"
local Main = Instance.new("Frame", Gui)
Main.Size = UDim2.new(0, 280, 0, 350); Main.Position = UDim2.new(0.5, -140, 0.4, -175)
Main.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
Instance.new("UICorner", Main)

local List = Instance.new("UIListLayout", Main); List.Padding = UDim.new(0, 8); List.HorizontalAlignment = "Center"

local function AddBtn(txt, callback)
    local b = Instance.new("TextButton", Main)
    b.Size = UDim2.new(0.9, 0, 0, 40); b.Text = txt; b.BackgroundColor3 = Color3.fromRGB(45, 45, 50); b.TextColor3 = Color3.new(1,1,1)
    Instance.new("UICorner", b)
    b.MouseButton1Click:Connect(function() callback(b) end)
end

-- --- CÁC NÚT CHỨC NĂNG ---
AddBtn("AUTO FARM: OFF", function(self)
    _G.AutoFarm = not _G.AutoFarm
    self.Text = _G.AutoFarm and "AUTO FARM: ON" or "AUTO FARM: OFF"
    self.BackgroundColor3 = _G.AutoFarm and Color3.fromRGB(0, 170, 255) or Color3.fromRGB(45, 45, 50)
end)

AddBtn("AUTO SELL: OFF", function(self)
    _G.AutoSell = not _G.AutoSell
    self.Text = _G.AutoSell and "AUTO SELL: ON" or "AUTO SELL: OFF"
    self.BackgroundColor3 = _G.AutoSell and Color3.fromRGB(0, 170, 255) or Color3.fromRGB(45, 45, 50)
end)

AddBtn("📍 SET FISHING POS", function() _G.FishingCF = Player.Character.HumanoidRootPart.CFrame end)
AddBtn("📍 SET NPC POS", function() _G.SellCF = Player.Character.HumanoidRootPart.CFrame end)

-- --- CORE LOGIC (VÒNG LẶP KHÔNG LỖI) ---
task.spawn(function()
    Player.Idled:Connect(function() VU:CaptureController(); VU:ClickButton2(Vector2.new(0,0)) end) -- Chống treo máy bị văng
    while true do
        if _G.AutoFarm then
            -- Tự động nhấp câu bằng VirtualUser (Nhẹ và chuẩn hơn VIM)
            VU:Button1Down(Vector2.new(500, 500))
            task.wait(0.01)
            VU:Button1Up(Vector2.new(500, 500))
            
            -- Combo chiêu
            for _, k in pairs(_G.Combo) do
                game:GetService("KeyPressService"):SendKeyEvent(k) -- Một cách nhấn phím khác ổn định hơn
                task.wait(0.5)
            end
        end
        task.wait(0.5)
    end
end)

-- Vòng lặp đi bán
task.spawn(function()
    while true do
        task.wait(120) -- 2 phút đi bán 1 lần cho chắc
        if _G.AutoSell and _G.SellCF and _G.FishingCF then
            local wasFarm = _G.AutoFarm; _G.AutoFarm = false
            -- Chạy bộ tới
            Player.Character.Humanoid:MoveTo(_G.SellCF.Position)
            Player.Character.Humanoid.MoveToFinished:Wait()
            
            -- Thực hiện tương tác bán
            DirectSell()
            task.wait(2)
            
            -- Quay lại chỗ câu
            Player.Character.HumanoidRootPart.CFrame = _G.FishingCF
            _G.AutoFarm = wasFarm
        end
    end
end)
