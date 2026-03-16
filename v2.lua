-- [[ ★ THỐNG HUB V24 - FIX CƠ CHẾ HIỂN THỊ ★ ]] --
repeat task.wait() until game:IsLoaded()

local Player = game.Players.LocalPlayer
local VIM = game:GetService("VirtualInputManager")
local pGui = Player:WaitForChild("PlayerGui")

-- Xóa UI cũ để tránh xung đột
for _, old in pairs(pGui:GetChildren()) do
    if old.Name:find("ThốngHub") or old.Name == "ThongToggleUI" then old:Destroy() end
end

-- --- BIẾN HỆ THỐNG ---
_G.AutoFarm = false
_G.AutoSell = false
_G.ComboOrder = "Z,X,C,V"
_G.Delays = {Z = 0.5, X = 0.5, C = 0.5, V = 0.5}

-- --- KHỞI TẠO UI ---
local Gui = Instance.new("ScreenGui")
Gui.Name = "ThốngHubV24"
Gui.IgnoreGuiInset = true
Gui.Parent = pGui

-- Nút Bật/Tắt (Luôn hiện để cứu cánh)
local ToggleUI = Instance.new("TextButton")
ToggleUI.Name = "ThongToggleUI"
ToggleUI.Size = UDim2.new(0, 45, 0, 45)
ToggleUI.Position = UDim2.new(0, 10, 0.4, 0)
ToggleUI.Text = "MENU"
ToggleUI.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
ToggleUI.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", ToggleUI).CornerRadius = UDim.new(1, 0)
ToggleUI.Parent = Gui

local Main = Instance.new("Frame")
Main.Name = "MainFrame"
Main.Size = UDim2.new(0, 360, 0, 280)
Main.Position = UDim2.new(0.5, -180, 0.5, -140)
Main.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
Instance.new("UICorner", Main)
Main.Parent = Gui

-- Sự kiện ẩn hiện
ToggleUI.MouseButton1Click:Connect(function()
    Main.Visible = not Main.Visible
end)

-- Tạo các Tab đơn giản (Để tránh lỗi Mobile)
local Container = Instance.new("ScrollingFrame")
Container.Size = UDim2.new(1, -20, 1, -20)
Container.Position = UDim2.new(0, 10, 0, 10)
Container.BackgroundTransparency = 1
Container.CanvasSize = UDim2.new(0, 0, 2, 0)
Container.ScrollBarThickness = 2
Container.Parent = Main
local List = Instance.new("UIListLayout", Container)
List.Padding = UDim.new(0, 5)

-- --- HÀM TẠO NÚT BẤM (CÓ THỜI GIAN CHỜ ĐỂ FIX LỖI) ---
local function AddToggle(txt, callback)
    task.wait(0.1) -- Đợi một chút để tránh kẹt UI
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, 0, 0, 35)
    b.Text = txt .. ": OFF"
    b.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    b.TextColor3 = Color3.new(1, 1, 1)
    Instance.new("UICorner", b)
    b.Parent = Container
    
    local s = false
    b.MouseButton1Click:Connect(function()
        s = not s
        b.Text = txt .. (s and ": ON" or ": OFF")
        b.BackgroundColor3 = s and Color3.fromRGB(0, 170, 255) or Color3.fromRGB(30, 30, 30)
        callback(s)
    end)
end

-- --- ĐỔ CHỨC NĂNG VÀO MENU ---
AddToggle("AUTO FARM", function(v) _G.AutoFarm = v end)
AddToggle("AUTO SELL", function(v) _G.AutoSell = v end)

-- Nút lưu vị trí (Fix lỗi tọa độ)
local function AddBtn(txt, callback)
    task.wait(0.1)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, 0, 0, 35)
    b.Text = txt
    b.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
    b.TextColor3 = Color3.new(1, 1, 1)
    Instance.new("UICorner", b)
    b.Parent = Container
    b.MouseButton1Click:Connect(callback)
end

AddBtn("LƯU VỊ TRÍ CÂU", function() _G.FishingPos = Player.Character.HumanoidRootPart.CFrame end)
AddBtn("LƯU VỊ TRÍ BÁN", function() _G.SellPos = Player.Character.HumanoidRootPart.CFrame end)

-- --- CORE LOGIC ---
task.spawn(function()
    while true do
        if _G.AutoFarm then
            -- Click bằng tọa độ tuyệt đối để tránh lỗi tâm màn hình
            VIM:SendMouseButtonEvent(500, 500, 0, true, game, 1)
            task.wait(0.01)
            VIM:SendMouseButtonEvent(500, 500, 0, false, game, 1)
            -- Tự động bấm Z,X,C,V
            for _, k in pairs({"Z","X","C","V"}) do
                VIM:SendKeyEvent(true, Enum.KeyCode[k], false, game)
                task.wait(0.05)
                VIM:SendKeyEvent(false, Enum.KeyCode[k], false, game)
                task.wait(0.5)
            end
        end
        task.wait(0.1)
    end
end)

print("Thống Hub V24 đã sẵn sàng!")
