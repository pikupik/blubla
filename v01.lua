-- Fish It Auto Farm Script
-- Load dengan: loadstring(game:HttpGet("YOUR_RAW_GITHUB_URL"))()

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Tunggu karakter muncul
local character
if player.Character then
    character = player.Character
else
    character = player.CharacterAdded:Wait()
end

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
    Size = UDim2.new(0, 500, 0, 500),
    Position = UDim2.new(0.5, -250, 0.5, -250),
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
    CanvasSize = UDim2.new(0, 0, 0, 750)
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

-- Auto Fishing Section - Legit
local legitFishSection = create("Frame", {
    Parent = contentFrame,
    Size = UDim2.new(1, 0, 0, 70),
    Position = UDim2.new(0, 0, 0, 105),
    BackgroundColor3 = Color3.fromRGB(25, 35, 50),
})

create("UICorner", {Parent = legitFishSection, CornerRadius = UDim.new(0, 12)})
create("UIStroke", {Parent = legitFishSection, Color = Color3.fromRGB(40, 60, 90), Thickness = 1.5})

local legitFishTitle = create("TextLabel", {
    Parent = legitFishSection,
    Size = UDim2.new(0.55, 0, 1, 0),
    Position = UDim2.new(0, 15, 0, 0),
    BackgroundTransparency = 1,
    Text = "🎣 Auto Fishing (Legit)\nSpam click untuk catch",
    Font = Enum.Font.GothamBold,
    TextSize = 15,
    TextColor3 = Color3.fromRGB(220, 220, 220),
    TextXAlignment = Enum.TextXAlignment.Left,
    TextYAlignment = Enum.TextYAlignment.Center
})

local legitFishBtn = create("TextButton", {
    Parent = legitFishSection,
    Size = UDim2.new(0, 120, 0, 48),
    Position = UDim2.new(1, -130, 0, 11),
    BackgroundColor3 = Color3.fromRGB(50, 150, 50),
    Text = "START",
    Font = Enum.Font.GothamBold,
    TextSize = 16,
    TextColor3 = Color3.fromRGB(255, 255, 255)
})

create("UICorner", {Parent = legitFishBtn, CornerRadius = UDim.new(0, 10)})

-- Auto Fishing Section - Blatant
local blatantFishSection = create("Frame", {
    Parent = contentFrame,
    Size = UDim2.new(1, 0, 0, 70),
    Position = UDim2.new(0, 0, 0, 190),
    BackgroundColor3 = Color3.fromRGB(25, 35, 50),
})

create("UICorner", {Parent = blatantFishSection, CornerRadius = UDim.new(0, 12)})
create("UIStroke", {Parent = blatantFishSection, Color = Color3.fromRGB(40, 60, 90), Thickness = 1.5})

local blatantFishTitle = create("TextLabel", {
    Parent = blatantFishSection,
    Size = UDim2.new(0.55, 0, 1, 0),
    Position = UDim2.new(0, 15, 0, 0),
    BackgroundTransparency = 1,
    Text = "⚡ Auto Fishing (Blatant)\nInstant catch tanpa animasi",
    Font = Enum.Font.GothamBold,
    TextSize = 15,
    TextColor3 = Color3.fromRGB(220, 220, 220),
    TextXAlignment = Enum.TextXAlignment.Left,
    TextYAlignment = Enum.TextYAlignment.Center
})

local blatantFishBtn = create("TextButton", {
    Parent = blatantFishSection,
    Size = UDim2.new(0, 120, 0, 48),
    Position = UDim2.new(1, -130, 0, 11),
    BackgroundColor3 = Color3.fromRGB(150, 100, 50),
    Text = "START",
    Font = Enum.Font.GothamBold,
    TextSize = 16,
    TextColor3 = Color3.fromRGB(255, 255, 255)
})

create("UICorner", {Parent = blatantFishBtn, CornerRadius = UDim.new(0, 10)})

-- Auto Sell Section
local sellSection = create("Frame", {
    Parent = contentFrame,
    Size = UDim2.new(1, 0, 0, 70),
    Position = UDim2.new(0, 0, 0, 275),
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
    Position = UDim2.new(0, 0, 0, 360),
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
    Position = UDim2.new(0, 0, 0, 515),
    BackgroundColor3 = Color3.fromRGB(35, 60, 100),
})

create("UICorner", {Parent = infoBox, CornerRadius = UDim.new(0, 12)})

local infoText = create("TextLabel", {
    Parent = infoBox,
    Size = UDim2.new(1, -20, 1, -20),
    Position = UDim2.new(0, 10, 0, 10),
    BackgroundTransparency = 1,
    Text = "ℹ️ Instructions:\n• Equip fishing rod sebelum start\n• Legit: Spam click manual\n• Blatant: Instant catch (risky)\n• Drag title bar untuk pindah GUI",
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
local legitFishingEnabled = false
local blatantFishingEnabled = false
local autoSellEnabled = false
local fishCaught = 0
local fishSold = 0
local totalCoins = 0

-- Mouse click functions
function mouse1click()
    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1)
    task.wait()
    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1)
end

function mouse1release()
    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1)
end

-- Get player's equipped tool
local function getEquippedTool()
    if character then
        return character:FindFirstChildOfClass("Tool")
    end
    return nil
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
        mouse1click()
        return true
    end
    return false
end

-- Release fishing rod
local function releaseRod()
    mouse1release()
end

-- Spam click for catching fish (Fish It mechanic: click as fast as you can)
local function spamClick(duration)
    local clickCount = 0
    local clickSpeed = 0.05 -- 20 clicks per second
    local endTime = tick() + duration
    
    while tick() < endTime and legitFishingEnabled do
        mouse1click()
        clickCount = clickCount + 1
        task.wait(clickSpeed)
    end
    
    return clickCount
end

-- Check if player caught a fish by monitoring inventory changes
local function checkFishCaught()
    local backpack = player:FindFirstChild("Backpack")
    if backpack then
        for _, item in pairs(backpack:GetChildren()) do
            if item:IsA("Tool") and (item.Name:lower():find("fish") or item.Name:lower():find("salmon") or item.Name:lower():find("trout") or item.Name:lower():find("tuna")) then
                return true
            end
        end
    end
    return false
end

-- Find fishing remote events/functions
local function findFishingRemotes()
    local fishingRemotes = {}
    
    -- Check ReplicatedStorage
    for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
        if (obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction")) and 
           (obj.Name:lower():find("fish") or obj.Name:lower():find("cast") or obj.Name:lower():find("catch")) then
            table.insert(fishingRemotes, obj)
        end
    end
    
    -- Check workspace
    for _, obj in pairs(workspace:GetDescendants()) do
        if (obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction")) and 
           (obj.Name:lower():find("fish") or obj.Name:lower():find("cast") or obj.Name:lower():find("catch")) then
            table.insert(fishingRemotes, obj)
        end
    end
    
    return fishingRemotes
end

-- Try to catch fish instantly (Blatant method)
local function instantCatch()
    local fishingRemotes = findFishingRemotes()
    
    for _, remote in pairs(fishingRemotes) do
        pcall(function()
            if remote:IsA("RemoteEvent") then
                remote:FireServer()
            elseif remote:IsA("RemoteFunction") then
                remote:InvokeServer()
            end
        end)
    end
    
    -- Also try common fishing remote names
    local commonNames = {"Fish", "Catch", "Cast", "Fishing", "FishEvent", "CatchFish"}
    for _, name in pairs(commonNames) do
        pcall(function()
            local remote = ReplicatedStorage:FindFirstChild(name)
            if remote and remote:IsA("RemoteEvent") then
                remote:FireServer()
            elseif remote and remote:IsA("RemoteFunction") then
                remote:InvokeServer()
            end
        end)
    end
end

-- Sell fish at merchant
local function sellFish()
    local success = pcall(function()
        -- Find sell NPC/trigger in workspace
        local sellZone = workspace:FindFirstChild("SellZone") or 
                        workspace:FindFirstChild("Merchant") or
                        workspace:FindFirstChild("Shop") or
                        workspace:FindFirstChild("Sell")
        
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
                              ReplicatedStorage:FindFirstChild("Events") or
                              workspace:FindFirstChild("SellFish")
            
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

-- Legit Auto Fishing Loop
local function legitFishingLoop()
    while legitFishingEnabled do
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
            releaseRod()
            
            -- Phase 2: Wait for bite and spam click
            statusLabel.Text = "⏳ Waiting for bite..."
            statusLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
            
            -- Wait random time for fish to bite (2-5 seconds)
            local waitTime = math.random(2, 5)
            local waitStart = tick()
            
            while tick() - waitStart < waitTime and legitFishingEnabled do
                task.wait(0.1)
            end
            
            -- Phase 3: Spam click to catch
            statusLabel.Text = "⚡ Spam clicking..."
            statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
            
            local clicks = spamClick(3) -- Spam for 3 seconds
            
            -- Phase 4: Check if caught
            task.wait(0.5)
            if checkFishCaught() then
                fishCaught = fishCaught + 1
                statusLabel.Text = "🐟 Fish Caught! Total: " .. fishCaught
                statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
            else
                statusLabel.Text = "❌ Missed! Trying again..."
                statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
            end
            
            task.wait(0.5) -- Small delay between attempts
            
        end)
        
        if not success then
            warn("[Legit Fishing Error]:", err)
            statusLabel.Text = "❌ Error! Check Output"
            statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
        end
    end
    
    statusLabel.Text = "🔴 Status: Idle"
    statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
end

-- Blatant Auto Fishing Loop
local function blatantFishingLoop()
    while blatantFishingEnabled do
        local success, err = pcall(function()
            -- Check if rod equipped
            if not hasRodEquipped() then
                statusLabel.Text = "⚠️ Equip Fishing Rod!"
                statusLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
                task.wait(2)
                return
            end
            
            -- Cast rod briefly
            statusLabel.Text = "🎣 Casting..."
            statusLabel.TextColor3 = Color3.fromRGB(100, 200, 255)
            
            castRod()
            task.wait(0.5)
            releaseRod()
            
            -- Wait random time (1-5 seconds max)
            local waitTime = math.random(1, 5)
            statusLabel.Text = "⏳ Waiting " .. waitTime .. "s..."
            statusLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
            
            local waitStart = tick()
            while tick() - waitStart < waitTime and blatantFishingEnabled do
                task.wait(0.1)
            end
            
            -- Instant catch
            statusLabel.Text = "⚡ Instant Catch!"
            statusLabel.TextColor3 = Color3.fromRGB(255, 100, 255)
            
            instantCatch()
            fishCaught = fishCaught + 1
            
            statusLabel.Text = "🐟 Fish Caught! Total: " .. fishCaught
            statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
            
            task.wait(0.5) -- Small delay between attempts
            
        end)
        
        if not success then
            warn("[Blatant Fishing Error]:", err)
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
            statusLabel.Text = "💰 Sold fish! Total: " .. fishSold
            statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
        end)
        
        if not success then
            warn("[Auto Sell Error]:", err)
        end
    end
end

-- ========== BUTTON FUNCTIONS ==========
legitFishBtn.MouseButton1Click:Connect(function()
    legitFishingEnabled = not legitFishingEnabled
    blatantFishingEnabled = false -- Ensure only one mode is active
    
    if legitFishingEnabled then
        legitFishBtn.Text = "STOP"
        legitFishBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        blatantFishBtn.Text = "START"
        blatantFishBtn.BackgroundColor3 = Color3.fromRGB(150, 100, 50)
        task.spawn(legitFishingLoop)
    else
        legitFishBtn.Text = "START"
        legitFishBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
    end
end)

blatantFishBtn.MouseButton1Click:Connect(function()
    blatantFishingEnabled = not blatantFishingEnabled
    legitFishingEnabled = false -- Ensure only one mode is active
    
    if blatantFishingEnabled then
        blatantFishBtn.Text = "STOP"
        blatantFishBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        legitFishBtn.Text = "START"
        legitFishBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
        task.spawn(blatantFishingLoop)
    else
        blatantFishBtn.Text = "START"
        blatantFishBtn.BackgroundColor3 = Color3.fromRGB(150, 100, 50)
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
    legitFishingEnabled = false
    blatantFishingEnabled = false
    autoSellEnabled = false
    screenGui:Destroy()
end)

-- Minimize functionality
local minimized = false
minimizeBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    TweenService:Create(mainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
        Size = minimized and UDim2.new(0, 500, 0, 55) or UDim2.new(0, 500, 0, 500)
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
addHover(legitFishBtn, Color3.fromRGB(50, 150, 50), Color3.fromRGB(70, 170, 70))
addHover(blatantFishBtn, Color3.fromRGB(150, 100, 50), Color3.fromRGB(170, 120, 70))
addHover(sellBtn, Color3.fromRGB(50, 150, 50), Color3.fromRGB(70, 170, 70))

-- Handle character respawn
player.CharacterAdded:Connect(function(newChar)
    character = newChar
    humanoidRootPart = newChar:WaitForChild("HumanoidRootPart")
end)

print("=================================")
print("🐟 Fish It Auto Farm Loaded!")
print("=================================")
print("✅ GUI berhasil dimuat untuk:", player.Name)
print("🎣 Mode Legit: Spam click manual")
print("⚡ Mode Blatant: Instant catch")
print("💰 Auto Sell: Jual otomatis setiap 30 detik")
print("=================================")
