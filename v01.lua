local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local net = ReplicatedStorage:WaitForChild("Packages")
	:WaitForChild("_Index")
	:WaitForChild("sleitnick_net@0.2.0")
	:WaitForChild("net")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

-- Hapus GUI lama
if playerGui:FindFirstChild("FishItAutoGUI") then
    playerGui:FindFirstChild("FishItAutoGUI"):Destroy()
end

-- Helper function
local function create(className, properties)
    local instance = Instance.new(className)
    for property, value in pairs(properties) do
        if property ~= "Parent" then
            instance[property] = value
        end
    end
    if properties.Parent then
        instance.Parent = properties.Parent
    end
    return instance
end

-- ===================================
-- ========== GUI ELEMENTS (MOBILE FRIENDLY) ===========
-- ===================================

-- ScreenGui
local screenGui = create("ScreenGui", {
    Name = "FishItAutoGUI",
    Parent = playerGui,
    ResetOnSpawn = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling
})

-- Main Frame (Revisi: Lebih kecil dan menggunakan Scale)
local mainFrame = create("Frame", {
    Name = "MainFrame",
    Parent = screenGui,
    -- Ukuran diperkecil dan menggunakan Scale untuk mobile
    Size = UDim2.new(0.8, 0, 0, 350), -- 80% lebar, tinggi 350px
    Position = UDim2.new(0.5, 0, 0.5, 0),
    AnchorPoint = Vector2.new(0.5, 0.5), -- Penting untuk penempatan di tengah
    BackgroundColor3 = Color3.fromRGB(15, 20, 30),
    BorderSizePixel = 0
})

create("UICorner", {Parent = mainFrame, CornerRadius = UDim.new(0, 10)})
create("UIStroke", {Parent = mainFrame, Color = Color3.fromRGB(40, 80, 150), Thickness = 1.5})

local gradient = create("UIGradient", {
    Parent = mainFrame,
    Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(20, 30, 45)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 15, 25))
    }),
    Rotation = 45
})

local titleBar = create("Frame", {
    Name = "TitleBar",
    Parent = mainFrame,
    Size = UDim2.new(1, 0, 0, 45), -- Tinggi diperkecil
    BackgroundColor3 = Color3.fromRGB(25, 35, 55),
    BorderSizePixel = 0
})

create("UICorner", {Parent = titleBar, CornerRadius = UDim.new(0, 10)})

local titleText = create("TextLabel", {
    Parent = titleBar,
    Size = UDim2.new(0.7, 0, 1, 0), 
    Position = UDim2.new(0, 10, 0, 0),
    BackgroundTransparency = 1,
    Text = "🐟 Fish It - Codepikk",
    Font = Enum.Font.GothamBold,
    TextSize = 18,
    TextScaled = true, -- PENTING: Untuk penyesuaian font di mobile
    TextColor3 = Color3.fromRGB(100, 180, 255),
    TextXAlignment = Enum.TextXAlignment.Left
})

local closeBtn = create("TextButton", {
    Parent = titleBar,
    Size = UDim2.new(0, 35, 0, 35), -- Ukuran tombol diperkecil
    Position = UDim2.new(1, -10, 0.5, 0),
    AnchorPoint = Vector2.new(1, 0.5), -- Penempatan di kanan
    BackgroundColor3 = Color3.fromRGB(220, 50, 50),
    Text = "✕",
    Font = Enum.Font.GothamBold,
    TextSize = 18,
    TextScaled = true,
    TextColor3 = Color3.fromRGB(255, 255, 255)
})

create("UICorner", {Parent = closeBtn, CornerRadius = UDim.new(0, 8)})

local minimizeBtn = create("TextButton", {
    Parent = titleBar,
    Size = UDim2.new(0, 35, 0, 35), -- Ukuran tombol diperkecil
    Position = UDim2.new(1, -50, 0.5, 0),
    AnchorPoint = Vector2.new(1, 0.5),
    BackgroundColor3 = Color3.fromRGB(70, 80, 100),
    Text = "—",
    Font = Enum.Font.GothamBold,
    TextSize = 18,
    TextScaled = true,
    TextColor3 = Color3.fromRGB(255, 255, 255)
})

create("UICorner", {Parent = minimizeBtn, CornerRadius = UDim.new(0, 8)})

local contentFrame = create("ScrollingFrame", {
    Name = "Content",
    Parent = mainFrame,
    Size = UDim2.new(1, -20, 1, -60), -- Disesuaikan
    Position = UDim2.new(0, 10, 0, 50), -- Disesuaikan
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    ScrollBarThickness = 6, -- Scrollbar diperkecil
    ScrollBarImageColor3 = Color3.fromRGB(50, 100, 180),
    CanvasSize = UDim2.new(0, 0, 0, 350) -- Ukuran canvas sementara
})

local statusBox = create("Frame", {
    Parent = contentFrame,
    Size = UDim2.new(1, 0, 0, 55), -- Tinggi diperkecil
    BackgroundColor3 = Color3.fromRGB(25, 35, 50),
    Position = UDim2.new(0, 0, 0, 5) -- Margin atas
})

create("UICorner", {Parent = statusBox, CornerRadius = UDim.new(0, 10)})
create("UIStroke", {Parent = statusBox, Color = Color3.fromRGB(40, 60, 90), Thickness = 1.0})

local statusLabel = create("TextLabel", {
    Parent = statusBox,
    Size = UDim2.new(1, -20, 1, 0),
    Position = UDim2.new(0, 10, 0, 0),
    BackgroundTransparency = 1,
    Text = "🔴 Status: Idle",
    Font = Enum.Font.GothamBold,
    TextSize = 16,
    TextScaled = true,
    TextColor3 = Color3.fromRGB(255, 100, 100),
    TextXAlignment = Enum.TextXAlignment.Left
})

local fishSection = create("Frame", {
    Parent = contentFrame,
    Size = UDim2.new(1, 0, 0, 50), -- Tinggi diperkecil
    Position = UDim2.new(0, 0, 0, 70), -- Posisi disesuaikan
    BackgroundColor3 = Color3.fromRGB(25, 35, 50),
})

create("UICorner", {Parent = fishSection, CornerRadius = UDim.new(0, 10)})
create("UIStroke", {Parent = fishSection, Color = Color3.fromRGB(40, 60, 90), Thickness = 1.0})

local fishTitle = create("TextLabel", {
    Parent = fishSection,
    Size = UDim2.new(0.6, 0, 1, 0),
    Position = UDim2.new(0, 10, 0, 0),
    BackgroundTransparency = 1,
    Text = "🎣 Auto Instant Fishing V1",
    Font = Enum.Font.GothamBold,
    TextSize = 14,
    TextScaled = true,
    TextColor3 = Color3.fromRGB(220, 220, 220),
    TextXAlignment = Enum.TextXAlignment.Left,
    TextYAlignment = Enum.TextYAlignment.Center
})

local fishBtn = create("TextButton", {
    Parent = fishSection,
    Size = UDim2.new(0, 80, 0, 35), -- Ukuran tombol diperkecil
    Position = UDim2.new(1, -10, 0.5, 0), 
    AnchorPoint = Vector2.new(1, 0.5),
    BackgroundColor3 = Color3.fromRGB(50, 150, 50),
    Text = "START",
    Font = Enum.Font.GothamBold,
    TextSize = 14,
    TextScaled = true,
    TextColor3 = Color3.fromRGB(255, 255, 255)
})

create("UICorner", {Parent = fishBtn, CornerRadius = UDim.new(0, 8)})

local sellSection = create("Frame", {
    Parent = contentFrame,
    Size = UDim2.new(1, 0, 0, 50), -- Tinggi diperkecil
    Position = UDim2.new(0, 0, 0, 125), -- Posisi disesuaikan
    BackgroundColor3 = Color3.fromRGB(25, 35, 50),
})

create("UICorner", {Parent = sellSection, CornerRadius = UDim.new(0, 10)})
create("UIStroke", {Parent = sellSection, Color = Color3.fromRGB(40, 60, 90), Thickness = 1.0})

local sellTitle = create("TextLabel", {
    Parent = sellSection,
    Size = UDim2.new(0.6, 0, 1, 0),
    Position = UDim2.new(0, 10, 0, 0),
    BackgroundTransparency = 1,
    Text = "💰 Auto Sell All",
    Font = Enum.Font.GothamBold,
    TextSize = 14,
    TextScaled = true,
    TextColor3 = Color3.fromRGB(220, 220, 220),
    TextXAlignment = Enum.TextXAlignment.Left,
    TextYAlignment = Enum.TextYAlignment.Center
})

local sellBtn = create("TextButton", {
    Parent = sellSection,
    Size = UDim2.new(0, 80, 0, 35), -- Ukuran tombol diperkecil
    Position = UDim2.new(1, -10, 0.5, 0),
    AnchorPoint = Vector2.new(1, 0.5),
    BackgroundColor3 = Color3.fromRGB(50, 150, 50),
    Text = "START",
    Font = Enum.Font.GothamBold,
    TextSize = 14,
    TextScaled = true,
    TextColor3 = Color3.fromRGB(255, 255, 255)
})

create("UICorner", {Parent = sellBtn, CornerRadius = UDim.new(0, 8)})

-- Info Box dihilangkan atau dipersingkat jika tidak diperlukan untuk menghemat ruang
local infoText = create("TextLabel", {
    Parent = contentFrame,
    Size = UDim2.new(1, 0, 0, 50),
    Position = UDim2.new(0, 0, 0, 185), -- Posisi disesuaikan
    BackgroundTransparency = 1,
    Text = "Pastikan rod ter-equip sebelum START.\nUI Mobile-Friendly oleh Codepikk.",
    Font = Enum.Font.Gotham,
    TextSize = 13,
    TextScaled = true,
    TextColor3 = Color3.fromRGB(150, 150, 150),
    TextWrapped = true,
})

-- Sesuaikan CanvasSize agar konten terlihat semua
contentFrame.CanvasSize = UDim2.new(0, 0, 0, 240)


-- ===================================
-- ========== DRAG & HOVER (Disesuaikan) ===========
-- ===================================
local dragging, dragInput, dragStart, startPos

local function updateDrag(input)
    local delta = input.Position - dragStart
    -- Menggunakan AnchorPoint 0.5, 0.5
    local newX = startPos.X.Offset + delta.X
    local newY = startPos.Y.Offset + delta.Y
    
    -- Konversi kembali ke UDim2 (Offset)
    local newPos = UDim2.new(startPos.X.Scale, newX, startPos.Y.Scale, newY)

    TweenService:Create(mainFrame, TweenInfo.new(0.12, Enum.EasingStyle.Quad), {
        Position = newPos
    }):Play()
end

titleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        -- Ambil posisi offset saat ini
        startPos = UDim2.new(0, mainFrame.AbsolutePosition.X - mainFrame.AbsoluteSize.X * 0.5, 0, mainFrame.AbsolutePosition.Y - mainFrame.AbsoluteSize.Y * 0.5)
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

titleBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input == dragInput then
        updateDrag(input)
    end
end)

local function addHover(btn, normal, hover)
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = hover}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = normal}):Play()
    end)
end

addHover(closeBtn, Color3.fromRGB(220, 50, 50), Color3.fromRGB(240, 80, 80)) 
addHover(minimizeBtn, Color3.fromRGB(70, 80, 100), Color3.fromRGB(90, 100, 120))
addHover(fishBtn, Color3.fromRGB(50, 150, 50), Color3.fromRGB(70, 170, 70))
addHover(sellBtn, Color3.fromRGB(50, 150, 50), Color3.fromRGB(70, 170, 70))

-- ===================================
-- ========== FISHING CORE ===========
-- ===================================
local autoFishingEnabled = false
local autoSellEnabled = false
local delayInitialized = false

-- Remote Events/Functions
local rodRemote = net:WaitForChild("RF/ChargeFishingRod")
local miniGameRemote = net:WaitForChild("RF/RequestFishingMinigameStarted")
local finishRemote = net:WaitForChild("RE/FishingCompleted")
local equipRemote = net:WaitForChild("RE/EquipToolFromHotbar")
local sellRemote = net:WaitForChild("RF/SellAllItems") -- Remote function untuk jual

-- Rod Delays (dari base.lua)
local RodDelays = {
    ["Ares Rod"] = {custom = 1.12, bypass = 1.45},
    ["Angler Rod"] = {custom = 1.12, bypass = 1.45},
    ["Ghostfinn Rod"] = {custom = 1.12, bypass = 1.45},
    ["Astral Rod"] = {custom = 1.9, bypass = 1.45},
    ["Hazmat Rod"] = {custom = 1.9, bypass = 1.45},
    ["Chrome Rod"] = {custom = 2.3, bypass = 2},
    ["Steampunk Rod"] = {custom = 2.5, bypass = 2.3},
    ["Lucky Rod"] = {custom = 3.5, bypass = 3.6},
    ["Midnight Rod"] = {custom = 3.3, bypass = 3.4},
    ["Demascus Rod"] = {custom = 3.9, bypass = 3.8},
    ["Grass Rod"] = {custom = 3.8, bypass = 3.9},
    ["Luck Rod"] = {custom = 4.2, bypass = 4.1},
    ["Carbon Rod"] = {custom = 4, bypass = 3.8},
    ["Lava Rod"] = {custom = 4.2, bypass = 4.1},
    ["Starter Rod"] = {custom = 4.3, bypass = 4.2},
}

local customDelay = 1
local BypassDelay = 0.5
local fishingActive = false 

local function getValidRodName()
    local display = player.PlayerGui:WaitForChild("Backpack"):WaitForChild("Display")
    for _, tile in ipairs(display:GetChildren()) do
        local success, itemNamePath = pcall(function()
            return tile.Inner.Tags.ItemName
        end)
        if success and itemNamePath and itemNamePath:IsA("TextLabel") then
            local name = itemNamePath.Text
            if RodDelays[name] then
                return name
            end
        end
    end
    return nil
end

local function updateDelayBasedOnRod()
    if delayInitialized then return end
    local rodName = getValidRodName()
    if rodName and RodDelays[rodName] then
        customDelay = RodDelays[rodName].custom
        BypassDelay = RodDelays[rodName].bypass
        delayInitialized = true
        statusLabel.Text = "✅ Rod Detected: " .. rodName
        statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
    else
        customDelay = 10
        BypassDelay = 1
        delayInitialized = true
        statusLabel.Text = "⚠️ Default Delay Applied (Coba equip ulang rod)"
        statusLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
    end
end

-- Fungsi utama Auto Fishing
local function autoFishingLoop()
    while autoFishingEnabled do
        fishingActive = false
        local success, err = pcall(function()
            updateDelayBasedOnRod()
            
            fishingActive = true
            
            -- 1. Equip Rod
            statusLabel.Text = "🎣 Equipping Rod..."
            statusLabel.TextColor3 = Color3.fromRGB(100, 200, 255)
            equipRemote:FireServer(1)
            task.wait(0.1)

            -- 2. Charge Rod
            statusLabel.Text = "⚡ Charging Rod..."
            statusLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
            local chargeRemote = ReplicatedStorage
                .Packages._Index["sleitnick_net@0.2.0"].net["RF/ChargeFishingRod"]
            chargeRemote:InvokeServer(workspace:GetServerTimeNow())
            task.wait(0.5)

            local timestamp = workspace:GetServerTimeNow()
            rodRemote:InvokeServer(timestamp) -- Panggil remote rod

            -- 3. Cast Rod (Request Minigame)
            local baseX, baseY = -0.7499996423721313, 1
            local x = baseX + (math.random(-500, 500) / 10000000)
            local y = baseY + (math.random(-500, 500) / 10000000)

            statusLabel.Text = "🎯 Casting..."
            statusLabel.TextColor3 = Color3.fromRGB(100, 200, 255)
            miniGameRemote:InvokeServer(x, y)

            statusLabel.Text = "⏳ Waiting for fish (" .. string.format("%.2f", customDelay) .. "s)..."
            statusLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
            
            task.wait(customDelay) -- Tunggu waktu gigitan
            
            -- Selesaikan Minigame (Bypass)
            statusLabel.Text = "✅ Fish Caught! Finishing..."
            statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
            
            finishRemote:FireServer(true) -- Kirim sinyal penyelesaian ke server
            
            task.wait(BypassDelay) -- Jeda bypass sebelum siklus baru
            
            fishingActive = false
                        
        end)
        
        if not success then
            warn("[Auto Fishing Error]:", err)
            statusLabel.Text = "❌ Error! Check Output"
            statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
            task.wait(2)
        end
        
        task.wait(0.2)
    end
    
    fishingActive = false
    statusLabel.Text = "🔴 Status: Idle"
    statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
end

-- Auto Sell Loop (Revisi Bug Sell All)
local function autoSellLoop()
    while autoSellEnabled do
        -- Tunggu 30 detik antar penjualan untuk mengurangi spam server
        task.wait(30) 
        
        local success, result = pcall(function()
            statusLabel.Text = "💰 Mencoba Menjual Ikan..."
            statusLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
            
            -- Panggil Remote Function SellAllItems secara langsung
            local sellResult = sellRemote:InvokeServer() 
            
            -- Cek hasil dari server. Asumsi server mengembalikan true/jumlah item terjual.
            if sellResult == true or type(sellResult) == "number" or (type(sellResult) == "string" and sellResult ~= "") then
                return sellResult
            else
                -- Jika tidak ada balasan yang diharapkan, anggap gagal
                error("SellAllItems did not return a valid success message.")
            end
        end)
        
        if success then
            local soldCount = type(result) == "number" and result or "Semua"
            statusLabel.Text = "✅ Berhasil Terjual! (" .. tostring(soldCount) .. ")"
            statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
        else
            warn("[Auto Sell Error]:", result)
            statusLabel.Text = "❌ Gagal Jual! Cek Output"
            statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
        end
        
        -- Jeda singkat sebelum perulangan berikutnya
        task.wait(1) 
    end
end

-- ===================================
-- ========== BUTTON LOGIC ===========
-- ===================================

fishBtn.MouseButton1Click:Connect(function()
    autoFishingEnabled = not autoFishingEnabled
    
    if autoFishingEnabled then
        fishBtn.Text = "STOP"
        fishBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        statusLabel.Text = "🟢 Auto Fishing Started"
        statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
        task.spawn(autoFishingLoop)
    else
        fishBtn.Text = "START"
        fishBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
        statusLabel.Text = "🔴 Auto Fishing Stopped"
        statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
        delayInitialized = false
        fishingActive = false
    end
end)

sellBtn.MouseButton1Click:Connect(function()
    autoSellEnabled = not autoSellEnabled
    
    if autoSellEnabled then
        sellBtn.Text = "STOP"
        sellBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        statusLabel.Text = "🟢 Auto Sell Started (Jual tiap 30s)"
        statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
        task.spawn(autoSellLoop)
    else
        sellBtn.Text = "START"
        sellBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
        statusLabel.Text = "🔴 Auto Sell Stopped"
        statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
    end
end)

closeBtn.MouseButton1Click:Connect(function()
    autoFishingEnabled = false
    autoSellEnabled = false
    fishingActive = false
    screenGui:Destroy()
end)

-- Minimize functionality
local minimized = false
minimizeBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    TweenService:Create(mainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
        -- Menggunakan ukuran minimize/normal baru
        Size = minimized and UDim2.new(0.8, 0, 0, 45) or UDim2.new(0.8, 0, 0, 350) 
    }):Play()
    minimizeBtn.Text = minimized and "+" or "—"
end)

print("=================================")
print("🐟 Fish It Auto Farm Loaded!")
print("=================================")
print("✅ GUI (Mobile Ready) dimuat untuk:", player.Name)
print("📌 Equip fishing rod dan tekan START")
print("🎯 Logic fishing & Sell All diperbaiki.")
print("=================================")
