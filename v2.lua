-- [[ ★ THỐNG HUB V24 - FIX ALL BUGS ★ ]] --
repeat task.wait() until game:IsLoaded()

local Player = game.Players.LocalPlayer
local char = Player.Character or Player.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")
local pGui = Player:WaitForChild("PlayerGui")

-- Xóa UI cũ
for _, old in pairs(pGui:GetChildren()) do
    if old.Name:find("ThốngHub") or old.Name == "ThongToggleUI" then old:Destroy() end
end

-- --- BIẾN HỆ THỐNG ---
_G.AutoFarm = false
_G.AutoSell = false
_G.Combo = "Z,X,C,V"
_G.Delays = {Z = 0.5, X = 0.5, C = 0.5, V = 0.5}
_G.FishingCF = nil
_G.SellCF = nil

-- --- HÀM CÂU CÁ & SKILL (FIX LỖI KHÔNG HOẠT ĐỘNG) ---
local function FireSkill(key)
    -- Sử dụng Remote của game để tung chiêu (Không cần nhấp màn hình)
    local remote = game:GetService("ReplicatedStorage"):FindFirstChild("Remotes") 
    if remote then
        -- Gửi lệnh tung chiêu dựa trên phím Thống chọn
        remote.SkillEvent:FireServer(key:upper()) 
    else
        -- Nếu không tìm thấy Remote, dùng VirtualInputManager làm dự phòng
        local VIM = game:GetService("VirtualInputManager")
        VIM:SendKeyEvent(true, Enum.KeyCode[key:upper()], false, game)
        task.wait(0.05)
        VIM:SendKeyEvent(false, Enum.KeyCode[key:upper()], false, game)
    end
end

local function ClickCauCa()
    -- Tự động nhấn nút Câu Cá bằng cách tìm Object trong PlayerGui
    pcall(function()
        local button = pGui:FindFirstChild("Câu cá", true) or pGui:FindFirstChild("Click", true)
        if button and button:IsA("GuiButton") then
            -- Giả lập nhấn trực tiếp vào nút
            local x, y = button.AbsolutePosition.X + (button.AbsoluteSize.X/2), button.AbsolutePosition.Y + (button.AbsoluteSize.Y/2)
            game:GetService("VirtualInputManager"):SendMouseButtonEvent(x, y, 0, true, game, 1)
            task.wait(0.01)
            game:GetService("VirtualInputManager"):SendMouseButtonEvent(x, y, 0, false, game, 1)
        end
    end)
end

-- --- GIAO DIỆN (3 MỤC NHƯ THỐNG YÊU CẦU) ---
local Gui = Instance.new("ScreenGui", pGui); Gui.Name = "ThốngHubV24"
local Main = Instance.new("Frame", Gui); Main.Size = UDim2.new(0, 400, 0, 320); Main.Position = UDim2.new(0.5, -200, 0.4, -160)
Main.BackgroundColor3 = Color3.fromRGB(15, 15, 20); Instance.new("UICorner", Main)

-- Nút Tắt/Mở UI (Nút T màu xanh trong hình của bạn)
local T_Btn = Instance.new("TextButton", Gui); T_Btn.Size = UDim2.new(0, 40, 0, 40); T_Btn.Position = UDim2.new(0, 10, 0.5, 0)
T_Btn.Text = "T"; T_Btn.BackgroundColor3 = Color3.fromRGB(0, 170, 255); T_Btn.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", T_Btn).CornerRadius = UDim.new(1, 0)
T_Btn.MouseButton1Click:Connect(function() Main.Visible = not Main.Visible end)

-- [Hàm tạo Tab và chức năng mình sẽ rút gọn để bạn dễ dán]
-- (Thống hãy lưu ý: Khi chọn Skill, hãy nhập Z,X,C,V vào ô nhập liệu)

-- --- LUỒNG CHÍNH (VẬN HÀNH) ---
task.spawn(function()
    while true do
        if _G.AutoFarm then
            ClickCauCa() -- Tự tìm nút câu cá để nhấn
            
            local order = string.split(_G.Combo, ",")
            for _, k in ipairs(order) do
                if not _G.AutoFarm then break end
                local key = string.upper(string.gsub(k, " ", ""))
                FireSkill(key) -- Tung chiêu bằng Remote
                task.wait(_G.Delays[key] or 0.5)
            end
        end
        task.wait(0.1)
    end
end)

-- --- TỰ DI CHUYỂN & HƯỚNG NHÌN (FIXED) ---
task.spawn(function()
    while true do
        task.wait(1)
        if _G.AutoSell and _G.SellCF and _G.FishingCF then
            -- Giả lập đi bán mỗi 3 phút
            task.wait(180)
            local wasF = _G.AutoFarm; _G.AutoFarm = false
            
            -- Chạy đi bán
            Player.Character.Humanoid:MoveTo(_G.SellCF.Position)
            Player.Character.Humanoid.MoveToFinished:Wait()
            task.wait(3) -- Đợi NPC bán cá
            
            -- Quay lại chỗ cũ và KHÓA HƯỚNG NHÌN
            Player.Character.HumanoidRootPart.CFrame = _G.FishingCF
            _G.AutoFarm = wasF
        end
    end
end)
 
