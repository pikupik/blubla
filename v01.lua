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
    Text = "🐟 Fish It - Codepikk",
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

-- ========== LOGIKA FISHING YANG DIPERBAIKI ==========
local net = ReplicatedStorage:WaitForChild("Packages")
    :WaitForChild("_Index")
    :WaitForChild("sleitnick_net@0.2.0")
    :WaitForChild("net")

local rodRemote = net:WaitForChild("RF/ChargeFishingRod")
local miniGameRemote = net:WaitForChild("RF/RequestFishingMinigameStarted")
local finishRemote = net:WaitForChild("RE/FishingCompleted")

-- State untuk auto fishing
local FuncAutoFish = {
    autofish = false,
    perfectCast = true,
    fishingActive = false,
    delayInitialized = false
}

-- Animasi fishing rod
local RodIdle = ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Animations"):WaitForChild("FishingRodReelIdle")
local RodReel = ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Animations"):WaitForChild("EasyFishReelStart")
local RodShake = ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Animations"):WaitForChild("CastFromFullChargePosition1Hand")

local character = Players.LocalPlayer.Character or Players.LocalPlayer.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local animator = humanoid:FindFirstChildOfClass("Animator") or Instance.new("Animator", humanoid)

local RodShakeAnim = animator:LoadAnimation(RodShake)
local RodIdleAnim = animator:LoadAnimation(RodIdle)
local RodReelAnim = animator:LoadAnimation(RodReel)

-- Rod delays yang lebih lengkap
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

local function getValidRodName()
    local player = Players.LocalPlayer
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
    if FuncAutoFish.delayInitialized then return end
    local rodName = getValidRodName()
    if rodName and RodDelays[rodName] then
        customDelay = RodDelays[rodName].custom
        BypassDelay = RodDelays[rodName].bypass
        FuncAutoFish.delayInitialized = true
        statusLabel.Text = "✅ Rod Detected: " .. rodName
        statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
    else
        customDelay = 10
        BypassDelay = 1
        FuncAutoFish.delayInitialized = true
        statusLabel.Text = "⚠️ Default Delay Applied"
        statusLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
    end
end

-- Setup rod watcher untuk deteksi perubahan rod
local function setupRodWatcher()
    local player = Players.LocalPlayer
    local display = player.PlayerGui:WaitForChild("Backpack"):WaitForChild("Display")
    display.ChildAdded:Connect(function()
        task.wait(0.05)
        if not FuncAutoFish.delayInitialized then
            updateDelayBasedOnRod()
        end
    end)
end
setupRodWatcher()

-- Event handler untuk fishing completion
local REReplicateTextEffect = ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net["RE/ReplicateTextEffect"]

REReplicateTextEffect.OnClientEvent:Connect(function(data)
    if FuncAutoFish.autofish and FuncAutoFish.fishingActive
    and data
    and data.TextData
    and data.TextData.EffectType == "Exclaim" then

        local myHead = Players.LocalPlayer.Character and Players.LocalPlayer.Character:FindFirstChild("Head")
        if myHead and data.Container == myHead then
            task.spawn(function()
                for i = 1, 3 do
                    task.wait(BypassDelay)
                    finishRemote:FireServer()
                end
            end)
        end
    end
end)

-- Auto Fishing Loop yang diperbaiki
local function StartAutoFish()
    if FuncAutoFish.autofish then return end
    
    FuncAutoFish.autofish = true
    updateDelayBasedOnRod()
    
    task.spawn(function()
        while FuncAutoFish.autofish do
            local success, err = pcall(function()
                FuncAutoFish.fishingActive = true

                statusLabel.Text = "🎣 Equipping Rod..."
                statusLabel.TextColor3 = Color3.fromRGB(100, 200, 255)
                
                local equipRemote = net:WaitForChild("RE/EquipToolFromHotbar")
                equipRemote:FireServer(1)
                task.wait(0.1)

                statusLabel.Text = "⚡ Charging Rod..."
                statusLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
                
                local chargeRemote = ReplicatedStorage
                    .Packages._Index["sleitnick_net@0.2.0"].net["RF/ChargeFishingRod"]
                chargeRemote:InvokeServer(workspace:GetServerTimeNow())
                task.wait(0.5)

                local timestamp = workspace:GetServerTimeNow()
                RodShakeAnim:Play()
                rodRemote:InvokeServer(timestamp)

                local baseX, baseY = -0.7499996423721313, 1
                local x, y
                if FuncAutoFish.perfectCast then
                    x = baseX + (math.random(-500, 500) / 10000000)
                    y = baseY + (math.random(-500, 500) / 10000000)
                else
                    x = math.random(-1000, 1000) / 1000
                    y = math.random(0, 1000) / 1000
                end

                statusLabel.Text = "🎯 Casting..."
                statusLabel.TextColor3 = Color3.fromRGB(100, 200, 255)
                
                RodIdleAnim:Play()
                miniGameRemote:InvokeServer(x, y)

                statusLabel.Text = "⏳ Waiting for fish..."
                statusLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
                
                task.wait(customDelay)
                FuncAutoFish.fishingActive = false
                
                fishCaught = fishCaught + 1
                statusLabel.Text = "🐟 Fish Caught! Total: " .. fishCaught
                statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
                
            end)
            
            if not success then
                warn("[Auto Fishing Error]:", err)
                statusLabel.Text = "❌ Error! Check Output"
                statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
                task.wait(2)
            end
        end
    end)
end

local function StopAutoFish()
    FuncAutoFish.autofish = false
    FuncAutoFish.fishingActive = false
    FuncAutoFish.delayInitialized = false
    RodIdleAnim:Stop()
    RodShakeAnim:Stop()
    RodReelAnim:Stop()
    
    statusLabel.Text = "🔴 Auto Fishing Stopped"
    statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
end

-- Auto Sell Loop yang diperbaiki
local lastSellTime = 0
local AUTO_SELL_DELAY = 30

local function autoSellLoop()
    while autoSellEnabled do
        task.wait(AUTO_SELL_DELAY)
        
        local success, err = pcall(function()
            statusLabel.Text = "💰 Selling fish..."
            statusLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
            
            local charFolder = workspace:FindFirstChild("Characters")
            local char = charFolder and charFolder:FindFirstChild(player.Name)
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            
            if not hrp then
                statusLabel.Text = "❌ Character not found"
                return
            end

            local sellRemote = net:WaitForChild("RF/SellAllItems")

            local sellSuccess = pcall(function()
                sellRemote:InvokeServer()
            end)

            if sellSuccess then
                fishSold = fishSold + 1
                statusLabel.Text = "✅ Sold! Total: " .. fishSold
                statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
                lastSellTime = os.time()
            else
                statusLabel.Text = "❌ Sell Failed"
                statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
            end
        end)
        
        if not success then
            warn("[Auto Sell Error]:", err)
            statusLabel.Text = "❌ Sell Error!"
            statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
        end
    end
end

-- ========== BUTTON FUNCTIONS ==========
fishBtn.MouseButton1Click:Connect(function()
    autoFishingEnabled = not autoFishingEnabled
    
    if autoFishingEnabled then
        fishBtn.Text = "STOP"
        fishBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        statusLabel.Text = "🟢 Auto Fishing Started"
        statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
        StartAutoFish()
    else
        fishBtn.Text = "START"
        fishBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
        StopAutoFish()
    end
end)

sellBtn.MouseButton1Click:Connect(function()
    autoSellEnabled = not autoSellEnabled
    
    if autoSellEnabled then
        sellBtn.Text = "STOP"
        sellBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        statusLabel.Text = "🟢 Auto Sell Started"
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
    StopAutoFish()
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
