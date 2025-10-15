-- Fish It Auto Farm Script
-- Load dengan: loadstring(game:HttpGet("YOUR_RAW_GITHUB_URL"))()

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")

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

-- ScreenGui
local screenGui = create("ScreenGui", {
    Name = "FishItAutoGUI",
    Parent = playerGui,
    ResetOnSpawn = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling
})

-- Main Frame
local mainFrame = create("Frame", {
    Name = "MainFrame",
    Parent = screenGui,
    Size = UDim2.new(0, 500, 0, 450),
    Position = UDim2.new(0.5, -250, 0.5, -225),
    BackgroundColor3 = Color3.fromRGB(15, 20, 30),
    BorderSizePixel = 0
})

create("UICorner", {Parent = mainFrame, CornerRadius = UDim.new(0, 14)})
create("UIStroke", {Parent = mainFrame, Color = Color3.fromRGB(40, 80, 150), Thickness = 2.5})

-- Gradient Background
local gradient = create("UIGradient", {
    Parent = mainFrame,
    Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(20, 30, 45)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 15, 25))
    }),
    Rotation = 45
})

-- Title Bar
local titleBar = create("Frame", {
    Name = "TitleBar",
    Parent = mainFrame,
    Size = UDim2.new(1, 0, 0, 55),
    BackgroundColor3 = Color3.fromRGB(25, 35, 55),
    BorderSizePixel = 0
})

create("UICorner", {Parent = titleBar, CornerRadius = UDim.new(0, 14)})

local titleText = create("TextLabel", {
    Parent = titleBar,
    Size = UDim2.new(1, -110, 1, 0),
    Position = UDim2.new(0, 20, 0, 0),
    BackgroundTransparency = 1,
    Text = "🐟 Fish It Auto Farm",
    Font = Enum.Font.GothamBold,
    TextSize = 22,
    TextColor3 = Color3.fromRGB(100, 180, 255),
    TextXAlignment = Enum.TextXAlignment.Left
})

-- Close & Minimize Buttons
local closeBtn = create("TextButton", {
    Parent = titleBar,
    Size = UDim2.new(0, 42, 0, 42),
    Position = UDim2.new(1, -48, 0, 7),
    BackgroundColor3 = Color3.fromRGB(220, 50, 50),
    Text = "✕",
    Font = Enum.Font.GothamBold,
    TextSize = 22,
    TextColor3 = Color3.fromRGB(255, 255, 255)
})

create("UICorner", {Parent = closeBtn, CornerRadius = UDim.new(0, 10)})

local minimizeBtn = create("TextButton", {
    Parent = titleBar,
    Size = UDim2.new(0, 42, 0, 42),
    Position = UDim2.new(1, -96, 0, 7),
    BackgroundColor3 = Color3.fromRGB(70, 80, 100),
    Text = "—",
    Font = Enum.Font.GothamBold,
    TextSize = 22,
    TextColor3 = Color3.fromRGB(255, 255, 255)
})

create("UICorner", {Parent = minimizeBtn, CornerRadius = UDim.new(0, 10)})

-- Content Frame
local contentFrame = create("ScrollingFrame", {
    Name = "Content",
    Parent = mainFrame,
    Size = UDim2.new(1, -30, 1, -85),
    Position = UDim2.new(0, 15, 0, 70),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    ScrollBarThickness = 8,
    ScrollBarImageColor3 = Color3.fromRGB(50, 100, 180),
    CanvasSize = UDim2.new(0, 0, 0, 700)
})

-- Status Display
local statusBox = create("Frame", {
    Parent = contentFrame,
    Size = UDim2.new(1, 0, 0, 90),
    BackgroundColor3 = Color3.fromRGB(25, 35, 50),
})

create("UICorner", {Parent = statusBox, CornerRadius = UDim.new(0, 12)})
create("UIStroke", {Parent = statusBox, Color = Color3.fromRGB(40, 60, 90), Thickness = 1.5})

local statusLabel = create("TextLabel", {
    Parent = statusBox,
    Size = UDim2.new(1, -20, 0, 30),
    Position = UDim2.new(0, 10, 0, 8),
    BackgroundTransparency = 1,
    Text = "🔴 Status: Idle",
    Font = Enum.Font.GothamBold,
    TextSize = 17,
    TextColor3 = Color3.fromRGB(255, 100, 100),
    TextXAlignment = Enum.TextXAlignment.Left
})

local statsLabel = create("TextLabel", {
    Parent = statusBox,
    Size = UDim2.new(1, -20, 0, 50),
    Position = UDim2.new(0, 10, 0, 38),
    BackgroundTransparency = 1,
    Text = "🎣 Fish Caught: 0\n💰 Fish Sold: 0 | Coins: $0",
    Font = Enum.Font.Gotham,
    TextSize = 14,
    TextColor3 = Color3.fromRGB(180, 200, 220),
    TextXAlignment = Enum.TextXAlignment.Left,
    TextYAlignment = Enum.TextYAlignment.Top
})

-- Auto Fishing Section
local fishSection = create("Frame", {
    Parent = contentFrame,
    Size = UDim2.new(1, 0, 0, 70),
    Position = UDim2.new(0, 0, 0, 105),
    BackgroundColor3 = Color3.fromRGB(25, 35, 50),
})

create("UICorner", {Parent = fishSection, CornerRadius = UDim.new(0, 12)})
create("UIStroke", {Parent = fishSection, Color = Color3.fromRGB(40, 60, 90), Thickness = 1.5})

local fishTitle = create("TextLabel", {
    Parent = fishSection,
    Size = UDim2.new(0.55, 0, 1, 0),
    Position = UDim2.new(0, 15, 0, 0),
    BackgroundTransparency = 1,
    Text = "🎣 Auto Fishing\nSpam click untuk catch",
    Font = Enum.Font.GothamBold,
    TextSize = 15,
    TextColor3 = Color3.fromRGB(220, 220, 220),
    TextXAlignment = Enum.TextXAlignment.Left,
    TextYAlignment = Enum.TextYAlignment.Center
})

local fishBtn = create("TextButton", {
    Parent = fishSection,
    Size = UDim2.new(0, 120, 0, 48),
    Position = UDim2.new(1, -130, 0, 11),
    BackgroundColor3 = Color3.fromRGB(50, 150, 50),
    Text = "START",
    Font = Enum.Font.GothamBold,
    TextSize = 16,
    TextColor3 = Color3.fromRGB(255, 255, 255)
})

create("UICorner", {Parent = fishBtn, CornerRadius = UDim.new(0, 10)})

-- Auto Sell Section
local sellSection = create("Frame", {
    Parent = contentFrame,
    Size = UDim2.new(1, 0, 0, 70),
    Position = UDim2.new(0, 0, 0, 190),
    BackgroundColor3 = Color3.fromRGB(25, 35, 50),
})

create("UICorner", {Parent = sellSection, CornerRadius = UDim.new(0, 12)})
create("UIStroke", {Parent = sellSection, Color = Color3.fromRGB(40, 60, 90), Thickness = 1.5})

local sellTitle = create("TextLabel", {
    Parent = sellSection,
    Size = UDim2.new(0.55, 0, 1, 0),
    Position = UDim2.new(0, 15, 0, 0),
    BackgroundTransparency = 1,
    Text = "💰 Auto Sell\nJual ikan otomatis",
    Font = Enum.Font.GothamBold,
    TextSize = 15,
    TextColor3 = Color3.fromRGB(220, 220, 220),
    TextXAlignment = Enum.TextXAlignment.Left,
    TextYAlignment = Enum.TextYAlignment.Center
})

local sellBtn = create("TextButton", {
    Parent = sellSection,
    Size = UDim2.new(0, 120, 0, 48),
    Position = UDim2.new(1, -130, 0, 11),
    BackgroundColor3 = Color3.fromRGB(50, 150, 50),
    Text = "START",
    Font = Enum.Font.GothamBold,
    TextSize = 16,
    TextColor3 = Color3.fromRGB(255, 255, 255)
})

create("UICorner", {Parent = sellBtn, CornerRadius = UDim.new(0, 10)})

-- Settings Section
local settingsBox = create("Frame", {
    Parent = contentFrame,
    Size = UDim2.new(1, 0, 0, 140),
    Position = UDim2.new(0, 0, 0, 275),
    BackgroundColor3 = Color3.fromRGB(25, 35, 50),
})

create("UICorner", {Parent = settingsBox, CornerRadius = UDim.new(0, 12)})
create("UIStroke", {Parent = settingsBox, Color = Color3.fromRGB(40, 60, 90), Thickness = 1.5})

local settingsTitle = create("TextLabel", {
    Parent = settingsBox,
    Size = UDim2.new(1, -20, 0, 28),
    Position = UDim2.new(0, 10, 0, 8),
    BackgroundTransparency = 1,
    Text = "⚙️ Settings",
    Font = Enum.Font.GothamBold,
    TextSize = 16,
    TextColor3 = Color3.fromRGB(220, 220, 220),
    TextXAlignment = Enum.TextXAlignment.Left
})

local clickSpeedLabel = create("TextLabel", {
    Parent = settingsBox,
    Size = UDim2.new(1, -20, 0, 25),
    Position = UDim2.new(0, 10, 0, 42),
    BackgroundTransparency = 1,
    Text = "⚡ Click Speed: 20 clicks/sec",
    Font = Enum.Font.Gotham,
    TextSize = 14,
    TextColor3 = Color3.fromRGB(180, 200, 220),
    TextXAlignment = Enum.TextXAlignment.Left
})

local sellIntervalLabel = create("TextLabel", {
    Parent = settingsBox,
    Size = UDim2.new(1, -20, 0, 25),
    Position = UDim2.new(0, 10, 0, 72),
    BackgroundTransparency = 1,
    Text = "⏱️ Sell Interval: 30 seconds",
    Font = Enum.Font.Gotham,
    TextSize = 14,
    TextColor3 = Color3.fromRGB(180, 200, 220),
    TextXAlignment = Enum.TextXAlignment.Left
})

local castDelayLabel = create("TextLabel", {
    Parent = settingsBox,
    Size = UDim2.new(1, -20, 0, 25),
    Position = UDim2.new(0, 10, 0, 102),
    BackgroundTransparency = 1,
    Text = "🎯 Cast Delay: 1.5 seconds",
    Font = Enum.Font.Gotham,
    TextSize = 14,
    TextColor3 = Color3.fromRGB(180, 200, 220),
    TextXAlignment = Enum.TextXAlignment.Left
})

-- Info Box
local infoBox = create("Frame", {
    Parent = contentFrame,
    Size = UDim2.new(1, 0, 0, 80),
    Position = UDim2.new(0, 0, 0, 430),
    BackgroundColor3 = Color3.fromRGB(35, 60, 100),
})

create("UICorner", {Parent = infoBox, CornerRadius = UDim.new(0, 12)})

local infoText = create("TextLabel", {
    Parent = infoBox,
    Size = UDim2.new(1, -20, 1, -20),
    Position = UDim2.new(0, 10, 0, 10),
    BackgroundTransparency = 1,
    Text = "ℹ️ Instructions:\n• Equip fishing rod sebelum start\n• Drag title bar untuk pindah GUI\n• Auto fishing akan spam click otomatis",
    Font = Enum.Font.Gotham,
    TextSize = 13,
    TextColor3 = Color3.fromRGB(180, 200, 230),
    TextWrapped = true,
    TextXAlignment = Enum.TextXAlignment.Left,
    TextYAlignment = Enum.TextYAlignment.Top
})

-- ========== DRAG FUNCTIONALITY ==========
local dragging, dragInput, dragStart, startPos

local function updateDrag(input)
    local delta = input.Position - dragStart
    TweenService:Create(mainFrame, TweenInfo.new(0.12, Enum.EasingStyle.Quad), {
        Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    }):Play()
end

titleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
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

-- ========== FISH IT GAME FUNCTIONS ==========
local autoFishingEnabled = false
local autoSellEnabled = false
local fishCaught = 0
local fishSold = 0
local totalCoins = 0

-- Get player's equipped tool
local function getEquippedTool()
    return character:FindFirstChildOfClass("Tool")
end

-- Check if fishing rod is equipped
local function hasRodEquipped()
    local tool = getEquippedTool()
    return tool and (tool.Name:lower():find("rod") or tool:FindFirstChild("Rod"))
end

-- Cast fishing rod (hold mouse button)
local function castRod()
    local tool = getEquippedTool()
    if tool then
        tool:Activate()
        return true
    end
    return false
end

-- Spam click for catching fish (Fish It mechanic: click as fast as you can)
local function spamClick(duration)
    local clickCount = 0
    local clickSpeed = 0.05 -- 20 clicks per second
    local endTime = tick() + duration
    
    while tick() < endTime and autoFishingEnabled do
        local tool = getEquippedTool()
        if tool then
            tool:Activate()
            clickCount = clickCount + 1
        end
        task.wait(clickSpeed)
    end
    
    return clickCount
end

-- Check if player caught a fish
local function checkFishCaught()
    local tool = getEquippedTool()
    if tool then
        -- Check for fish in backpack or inventory increase
        local backpack = player:FindFirstChild("Backpack")
        if backpack then
            for _, item in pairs(backpack:GetChildren()) do
                if item:IsA("Tool") and item.Name:lower():find("fish") then
                    return true
                end
            end
        end
    end
    return false
end

-- Sell fish at merchant
local function sellFish()
    local success = pcall(function()
        -- Find sell NPC/trigger in workspace
        local sellZone = workspace:FindFirstChild("SellZone") or 
                        workspace:FindFirstChild("Merchant") or
                        workspace:FindFirstChild("Shop")
        
        if sellZone then
            local originalPos = humanoidRootPart.CFrame
            
            -- Teleport to sell zone
            if sellZone:FindFirstChild("HumanoidRootPart") then
                humanoidRootPart.CFrame = sellZone.HumanoidRootPart.CFrame + Vector3.new(0, 3, 0)
            elseif sellZone:IsA("Part") or sellZone:IsA("BasePart") then
                humanoidRootPart.CFrame = sellZone.CFrame + Vector3.new(0, 5, 0)
            end
            
            task.wait(0.5)
            
            -- Try to find sell remote
            local sellRemote = ReplicatedStorage:FindFirstChild("SellFish") or
                              ReplicatedStorage:FindFirstChild("Sell") or
                              ReplicatedStorage:FindFirstChild("Events")
            
            if sellRemote then
                if sellRemote:IsA("RemoteEvent") then
                    sellRemote:FireServer()
                elseif sellRemote:IsA("RemoteFunction") then
                    sellRemote:InvokeServer()
                elseif sellRemote:FindFirstChild("SellFish") then
                    sellRemote.SellFish:FireServer()
                end
            end
            
            task.wait(0.5)
            fishSold = fishSold + 1
            
            -- Return to original position
            humanoidRootPart.CFrame = originalPos
        end
    end)
    
    return success
end

-- Auto Fishing Loop
local function autoFishingLoop()
    while autoFishingEnabled do
        local success, err = pcall(function()
            -- Check if rod equipped
            if not hasRodEquipped() then
                statusLabel.Text = "⚠️ Equip Fishing Rod!"
                statusLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
                task.wait(2)
                return
            end
            
            -- Phase 1: Cast rod (hold to charge)
            statusLabel.Text = "🎣 Casting rod..."
            statusLabel.TextColor3 = Color3.fromRGB(100, 200, 255)
            
            castRod()
            task.wait(1.5) -- Hold cast
            
            -- Phase 2: Wait and spam click
            statusLabel.Text = "⚡ Spam clicking..."
            statusLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
            
            local clicks = spamClick(3) -- Spam for 3 seconds
            
            -- Phase 3: Check if caught
            task.wait(0.5)
            if checkFishCaught() then
                fishCaught = fishCaught + 1
                statusLabel.Text = "🐟 Fish Caught!"
                statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
            end
            
            -- Update stats
            statsLabel.Text = string.format("🎣 Fish Caught: %d\n💰 Fish Sold: %d | Coins: $%d", 
                fishCaught, fishSold, totalCoins)
            
            task.wait(1.5) -- Delay before next cast
        end)
        
        if not success then
            warn("[Auto Fishing Error]:", err)
            statusLabel.Text = "❌ Error! Check Output"
            statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
        end
    end
    
    statusLabel.Text = "🔴 Status: Idle"
    statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
end

-- Auto Sell Loop
local function autoSellLoop()
    while autoSellEnabled do
        task.wait(30) -- Sell every 30 seconds
        
        local success, err = pcall(function()
            statusLabel.Text = "💰 Selling fish..."
            statusLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
            
            sellFish()
            
            statsLabel.Text = string.format("🎣 Fish Caught: %d\n💰 Fish Sold: %d | Coins: $%d", 
                fishCaught, fishSold, totalCoins)
        end)
        
        if not success then
            warn("[Auto Sell Error]:", err)
        end
    end
end

-- ========== BUTTON FUNCTIONS ==========
fishBtn.MouseButton1Click:Connect(function()
    autoFishingEnabled = not autoFishingEnabled
    
    if autoFishingEnabled then
        fishBtn.Text = "STOP"
        fishBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        task.spawn(autoFishingLoop)
    else
        fishBtn.Text = "START"
        fishBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
    end
end)

sellBtn.MouseButton1Click:Connect(function()
    autoSellEnabled = not autoSellEnabled
    
    if autoSellEnabled then
        sellBtn.Text = "STOP"
        sellBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        task.spawn(autoSellLoop)
    else
        sellBtn.Text = "START"
        sellBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
    end
end)

closeBtn.MouseButton1Click:Connect(function()
    autoFishingEnabled = false
    autoSellEnabled = false
    screenGui:Destroy()
end)

-- Minimize functionality
local minimized = false
minimizeBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    TweenService:Create(mainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
        Size = minimized and UDim2.new(0, 500, 0, 55) or UDim2.new(0, 500, 0, 450)
    }):Play()
    minimizeBtn.Text = minimized and "+" or "—"
end)

-- Hover effects
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

print("=================================")
print("🐟 Fish It Auto Farm Loaded!")
print("=================================")
print("✅ GUI berhasil dimuat untuk:", player.Name)
print("📌 Equip fishing rod dan tekan START")
print("🎯 Mekanisme: Hold to cast → Spam click to catch")
print("=================================")
