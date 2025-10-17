local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

---- Hapus GUI lama
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
-- ========== GUI ELEMENTS ===========
-- ===================================

-- ScreenGui
local screenGui = create("ScreenGui", {
    Name = "FishItAutoGUI",
    Parent = playerGui,
    ResetOnSpawn = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling
})

-- Main Frame - Diperbesar untuk menampung lebih banyak kategori
local mainFrame = create("Frame", {
    Name = "MainFrame",
    Parent = screenGui,
    Size = UDim2.new(0, 320, 0, 400),
    Position = UDim2.new(0.5, -160, 0.5, -200),
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
    Size = UDim2.new(1, 0, 0, 33),
    BackgroundColor3 = Color3.fromRGB(25, 35, 55),
    BorderSizePixel = 0
})

create("UICorner", {Parent = titleBar, CornerRadius = UDim.new(0, 10)})

local titleText = create("TextLabel", {
    Parent = titleBar,
    Size = UDim2.new(1, -66, 1, 0),
    Position = UDim2.new(0, 12, 0, 0),
    BackgroundTransparency = 1,
    Text = "🐟 Fish It - Codepikk",
    Font = Enum.Font.GothamBold,
    TextSize = 13,
    TextColor3 = Color3.fromRGB(100, 180, 255),
    TextXAlignment = Enum.TextXAlignment.Left
})

local closeBtn = create("TextButton", {
    Parent = titleBar,
    Size = UDim2.new(0, 25, 0, 25),
    Position = UDim2.new(1, -29, 0, 4),
    BackgroundColor3 = Color3.fromRGB(220, 50, 50),
    Text = "X",
    Font = Enum.Font.GothamBold,
    TextSize = 13,
    TextColor3 = Color3.fromRGB(255, 255, 255)
})

create("UICorner", {Parent = closeBtn, CornerRadius = UDim.new(0, 6)})

local minimizeBtn = create("TextButton", {
    Parent = titleBar,
    Size = UDim2.new(0, 25, 0, 25),
    Position = UDim2.new(1, -58, 0, 4),
    BackgroundColor3 = Color3.fromRGB(70, 80, 100),
    Text = "—",
    Font = Enum.Font.GothamBold,
    TextSize = 13,
    TextColor3 = Color3.fromRGB(255, 255, 255)
})

create("UICorner", {Parent = minimizeBtn, CornerRadius = UDim.new(0, 6)})

-- Content Frame - Diperbesar untuk menampung kategori
local contentFrame = create("ScrollingFrame", {
    Name = "Content",
    Parent = mainFrame,
    Size = UDim2.new(1, -18, 1, -51),
    Position = UDim2.new(0, 9, 0, 42),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    ScrollBarThickness = 5,
    ScrollBarImageColor3 = Color3.fromRGB(50, 100, 180),
    CanvasSize = UDim2.new(0, 0, 0, 650)
})

-- Status Box
local statusBox = create("Frame", {
    Parent = contentFrame,
    Size = UDim2.new(1, 0, 0, 50),
    BackgroundColor3 = Color3.fromRGB(25, 35, 50),
})

create("UICorner", {Parent = statusBox, CornerRadius = UDim.new(0, 7)})
create("UIStroke", {Parent = statusBox, Color = Color3.fromRGB(40, 60, 90), Thickness = 1})

local statusLabel = create("TextLabel", {
    Parent = statusBox,
    Size = UDim2.new(1, -12, 1, -8),
    Position = UDim2.new(0, 6, 0, 4),
    BackgroundTransparency = 1,
    Text = "🔴 Status: Idle\n🔴 Script: Beta Test V.0.1a\nNote: found bug on script? Pm me on discord!",
    Font = Enum.Font.GothamBold,
    TextSize = 10,
    TextColor3 = Color3.fromRGB(255, 100, 100),
    TextXAlignment = Enum.TextXAlignment.Left
})

-- Fungsi untuk update status
local function updateStatus(newStatus, color)
    local baseText = "🔴 Script: Beta Test V.0.1a\nNote: found bug on script? Pm me on discord!"
    statusLabel.Text = newStatus .. "\n" .. baseText
    statusLabel.TextColor3 = color or Color3.fromRGB(255, 100, 100)
end

-- Inisialisasi status awal
updateStatus("🔴 Status: Idle")

-- ===================================
-- ========== CATEGORY SYSTEM =========
-- ===================================

local categoryYPosition = 58

-- Fungsi untuk membuat kategori
local function createCategory(categoryName, icon)
    local categoryFrame = create("Frame", {
        Parent = contentFrame,
        Size = UDim2.new(1, 0, 0, 32),
        Position = UDim2.new(0, 0, 0, categoryYPosition),
        BackgroundColor3 = Color3.fromRGB(30, 40, 60),
        BorderSizePixel = 0
    })
    
    create("UICorner", {Parent = categoryFrame, CornerRadius = UDim.new(0, 7)})
    create("UIStroke", {Parent = categoryFrame, Color = Color3.fromRGB(50, 80, 120), Thickness = 1})
    
    local categoryText = create("TextLabel", {
        Parent = categoryFrame,
        Size = UDim2.new(1, -12, 1, 0),
        Position = UDim2.new(0, 12, 0, 0),
        BackgroundTransparency = 1,
        Text = icon .. " " .. categoryName,
        Font = Enum.Font.GothamBold,
        TextSize = 12,
        TextColor3 = Color3.fromRGB(180, 200, 255),
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center
    })
    
    categoryYPosition = categoryYPosition + 40
    return categoryFrame, categoryYPosition
end

-- Fungsi untuk membuat section dalam kategori
local function createSection(parentCategory, sectionName, buttonText, buttonColor, yOffset)
    local section = create("Frame", {
        Parent = parentCategory,
        Size = UDim2.new(1, -10, 0, 32),
        Position = UDim2.new(0, 5, 0, yOffset),
        BackgroundColor3 = Color3.fromRGB(25, 35, 50),
        BorderSizePixel = 0
    })
    
    create("UICorner", {Parent = section, CornerRadius = UDim.new(0, 6)})
    create("UIStroke", {Parent = section, Color = Color3.fromRGB(40, 60, 90), Thickness = 1})
    
    local sectionTitle = create("TextLabel", {
        Parent = section,
        Size = UDim2.new(0.6, 0, 1, 0),
        Position = UDim2.new(0, 8, 0, 0),
        BackgroundTransparency = 1,
        Text = sectionName,
        Font = Enum.Font.Gotham,
        TextSize = 11,
        TextColor3 = Color3.fromRGB(220, 220, 220),
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center
    })
    
    local sectionBtn = create("TextButton", {
        Parent = section,
        Size = UDim2.new(0, 70, 0, 24),
        Position = UDim2.new(1, -75, 0, 4),
        BackgroundColor3 = buttonColor,
        Text = buttonText,
        Font = Enum.Font.GothamBold,
        TextSize = 10,
        TextColor3 = Color3.fromRGB(255, 255, 255)
    })
    
    create("UICorner", {Parent = sectionBtn, CornerRadius = UDim.new(0, 6)})
    
    return section, sectionBtn
end

-- Fungsi untuk membuat dropdown
local function createDropdown(parentCategory, sectionName, options, yOffset)
    local dropdownOpen = false
    local dropdownHeight = 32
    
    local dropdownSection = create("Frame", {
        Parent = parentCategory,
        Size = UDim2.new(1, -10, 0, dropdownHeight),
        Position = UDim2.new(0, 5, 0, yOffset),
        BackgroundColor3 = Color3.fromRGB(25, 35, 50),
        BorderSizePixel = 0,
        ClipsDescendants = true
    })
    
    create("UICorner", {Parent = dropdownSection, CornerRadius = UDim.new(0, 6)})
    create("UIStroke", {Parent = dropdownSection, Color = Color3.fromRGB(40, 60, 90), Thickness = 1})
    
    local dropdownTitle = create("TextLabel", {
        Parent = dropdownSection,
        Size = UDim2.new(0.6, 0, 0, 32),
        Position = UDim2.new(0, 8, 0, 0),
        BackgroundTransparency = 1,
        Text = sectionName,
        Font = Enum.Font.Gotham,
        TextSize = 11,
        TextColor3 = Color3.fromRGB(220, 220, 220),
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center
    })
    
    local dropdownBtn = create("TextButton", {
        Parent = dropdownSection,
        Size = UDim2.new(0, 70, 0, 24),
        Position = UDim2.new(1, -75, 0, 4),
        BackgroundColor3 = Color3.fromRGB(80, 120, 200),
        Text = "OPEN",
        Font = Enum.Font.GothamBold,
        TextSize = 10,
        TextColor3 = Color3.fromRGB(255, 255, 255)
    })
    
    create("UICorner", {Parent = dropdownBtn, CornerRadius = UDim.new(0, 6)})
    
    -- Options container
    local optionsContainer = create("Frame", {
        Parent = dropdownSection,
        Size = UDim2.new(1, -10, 0, 0),
        Position = UDim2.new(0, 5, 0, 35),
        BackgroundTransparency = 1,
        Visible = false
    })
    
    local function toggleDropdown()
        dropdownOpen = not dropdownOpen
        local targetSize = dropdownOpen and (32 + (#options * 30) + 5) or 32
        local targetCanvas = dropdownOpen and (32 + (#options * 30) + 5) or 32
        
        TweenService:Create(dropdownSection, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
            Size = UDim2.new(1, -10, 0, targetSize)
        }):Play()
        
        optionsContainer.Visible = dropdownOpen
        dropdownBtn.Text = dropdownOpen and "CLOSE" : "OPEN"
        
        if dropdownOpen then
            for i, option in pairs(options) do
                local optionBtn = create("TextButton", {
                    Parent = optionsContainer,
                    Size = UDim2.new(1, 0, 0, 28),
                    Position = UDim2.new(0, 0, 0, (i-1) * 30),
                    BackgroundColor3 = Color3.fromRGB(35, 45, 65),
                    Text = option.name,
                    Font = Enum.Font.Gotham,
                    TextSize = 10,
                    TextColor3 = Color3.fromRGB(220, 220, 220),
                    TextYAlignment = Enum.TextYAlignment.Center
                })
                
                create("UICorner", {Parent = optionBtn, CornerRadius = UDim.new(0, 4)})
                create("UIStroke", {Parent = optionBtn, Color = Color3.fromRGB(60, 100, 160), Thickness = 1})
                
                addHover(optionBtn, Color3.fromRGB(35, 45, 65), Color3.fromRGB(45, 55, 75))
                
                optionBtn.MouseButton1Click:Connect(function()
                    option.callback()
                    if option.closeOnClick then
                        toggleDropdown()
                    end
                end)
            end
            optionsContainer.Size = UDim2.new(1, 0, 0, #options * 30)
        else
            optionsContainer:ClearAllChildren()
        end
    end
    
    dropdownBtn.MouseButton1Click:Connect(toggleDropdown)
    
    return dropdownSection
end

-- ===================================
-- ========== CREATE CATEGORIES =========
-- ===================================

-- Kategori: MAIN
local mainCategory, mainY = createCategory("MAIN", "🏠")
mainCategory.Size = UDim2.new(1, 0, 0, 120)

-- Auto Fishing Section
local fishSection, fishBtn = createSection(mainCategory, "🎣 Auto Instant Fishing V1", "START", Color3.fromRGB(50, 150, 50), 35)

-- Auto Sell Section  
local sellSection, sellBtn = createSection(mainCategory, "💰 Auto Sell All", "START", Color3.fromRGB(50, 150, 50), 72)

-- Kategori: TELEPORT
local teleportCategory, teleportY = createCategory("TELEPORT", "🚀")
teleportCategory.Size = UDim2.new(1, 0, 0, 180)

-- Island Teleport Dropdown
local islandCoords = {
    {name = "📍 Weather Machine", callback = function() teleportToIsland("Weather Machine", Vector3.new(-1471, -3, 1929)) end},
    {name = "📍 Esoteric Depths", callback = function() teleportToIsland("Esoteric Depths", Vector3.new(3157, -1303, 1439)) end},
    {name = "📍 Tropical Grove", callback = function() teleportToIsland("Tropical Grove", Vector3.new(-2038, 3, 3650)) end},
    {name = "📍 Stingray Shores", callback = function() teleportToIsland("Stingray Shores", Vector3.new(-32, 4, 2773)) end},
    {name = "📍 Kohana Volcano", callback = function() teleportToIsland("Kohana Volcano", Vector3.new(-519, 24, 189)) end},
    {name = "📍 Coral Reefs", callback = function() teleportToIsland("Coral Reefs", Vector3.new(-3095, 1, 2177)) end},
    {name = "📍 Crater Island", callback = function() teleportToIsland("Crater Island", Vector3.new(968, 1, 4854)) end}
}

local islandDropdown = createDropdown(teleportCategory, "🏝️ Teleport to Islands", islandCoords, 35)

-- Event Teleport Dropdown
local eventCoords = {
    {name = "🎄 Winter Fest", callback = function() teleportToIsland("Winter Fest", Vector3.new(1611, 4, 3280)) end},
    {name = "🏛️ Treasure Hall", callback = function() teleportToIsland("Treasure Hall", Vector3.new(-3600, -267, -1558)) end},
    {name = "🗿 Sishypus Statue", callback = function() teleportToIsland("Sishypus Statue", Vector3.new(-3792, -135, -986)) end}
}

local eventDropdown = createDropdown(teleportCategory, "🎪 Event Locations", eventCoords, 80)

-- Kategori: MISC
local miscCategory, miscY = createCategory("MISC", "⚙️")
miscCategory.Size = UDim2.new(1, 0, 0, 120)

-- Anti AFK Section
local antiAfkSection, antiAfkBtn = createSection(miscCategory, "🔒 Anti AFK", "START", Color3.fromRGB(80, 120, 200), 35)

-- No Clip Section
local noClipSection, noClipBtn = createSection(miscCategory, "👻 No Clip", "START", Color3.fromRGB(150, 100, 200), 72)

-- Kategori: SERVER
local serverCategory, serverY = createCategory("SERVER", "🌐")
serverCategory.Size = UDim2.new(1, 0, 0, 80)

-- Server Hop Section
local serverHopSection, serverHopBtn = createSection(serverCategory, "🔄 Server Hop", "HOP", Color3.fromRGB(200, 100, 50), 35)

-- Reconnect Section
local reconnectSection, reconnectBtn = createSection(serverCategory, "🔁 Reconnect", "RECONNECT", Color3.fromRGB(200, 150, 50), 72)

-- Update canvas size
contentFrame.CanvasSize = UDim2.new(0, 0, 0, serverY + 10)

-- ===================================
-- ========== DRAG & HOVER ==========
-- ===================================
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
addHover(antiAfkBtn, Color3.fromRGB(80, 120, 200), Color3.fromRGB(100, 140, 220))
addHover(noClipBtn, Color3.fromRGB(150, 100, 200), Color3.fromRGB(170, 120, 220))
addHover(serverHopBtn, Color3.fromRGB(200, 100, 50), Color3.fromRGB(220, 120, 70))
addHover(reconnectBtn, Color3.fromRGB(200, 150, 50), Color3.fromRGB(220, 170, 70))

-- ===================================
-- ========== TELEPORT SYSTEM =========
-- ===================================

local function teleportToIsland(islandName, position)
    local charFolder = workspace:WaitForChild("Characters", 5)
    local char = charFolder:FindFirstChild(player.Name)
    if not char then 
        updateStatus("❌ Character not found")
        return 
    end
    
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then 
        updateStatus("❌ HRP not found")
        return 
    end

    local success, err = pcall(function()
        hrp.CFrame = CFrame.new(position + Vector3.new(0, 5, 0))
    end)

    if success then
        updateStatus("✅ Teleported to " .. islandName, Color3.fromRGB(100, 255, 100))
    else
        updateStatus("❌ Teleport failed: " .. tostring(err))
    end
end

-- ===================================
-- ========== FISHING SYSTEM =========
-- ===================================
local autoFishingEnabled = false
local autoSellEnabled = false
local delayInitialized = false

-- Remote Events/Functions
local net
local success, err = pcall(function()
    net = ReplicatedStorage:WaitForChild("Packages")
        :WaitForChild("_Index")
        :WaitForChild("sleitnick_net@0.2.0")
        :WaitForChild("net")
end)

if not success then
    warn("Net package not found, trying alternative path...")
    net = ReplicatedStorage:WaitForChild("Net")
end

local rodRemote = net:WaitForChild("RF/ChargeFishingRod")
local miniGameRemote = net:WaitForChild("RF/RequestFishingMinigameStarted")
local finishRemote = net:WaitForChild("RE/FishingCompleted")
local equipRemote = net:WaitForChild("RE/EquipToolFromHotbar")
local sellRemote = net:WaitForChild("RF/SellAllItems")

-- Rod Delays
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
    local backpackGui = player.PlayerGui:FindFirstChild("Backpack")
    if not backpackGui then return nil end
    
    local display = backpackGui:FindFirstChild("Display")
    if not display then return nil end
    
    for _, tile in ipairs(display:GetChildren()) do
        if tile:IsA("Frame") then
            local inner = tile:FindFirstChild("Inner")
            if inner then
                local tags = inner:FindFirstChild("Tags")
                if tags then
                    local itemName = tags:FindFirstChild("ItemName")
                    if itemName and itemName:IsA("TextLabel") then
                        local name = itemName.Text
                        if RodDelays[name] then
                            return name
                        end
                    end
                end
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
        updateStatus("✅ Rod Detected: " .. rodName, Color3.fromRGB(100, 255, 100))
    else
        customDelay = 10
        BypassDelay = 1
        delayInitialized = true
        updateStatus("⚠️ Default Delay Applied", Color3.fromRGB(255, 200, 100))
    end
end

-- 🎯 Exclaim (Tanda Seru) Listener + Auto Cast lagi
task.spawn(function()
	local success, exclaimEvent = pcall(function()
		return net:WaitForChild("RE/ReplicateTextEffect", 5)
	end)

	if success and exclaimEvent then
		exclaimEvent.OnClientEvent:Connect(function(data)
			if autoFishingEnabled and data and data.TextData
				and data.TextData.EffectType == "Exclaim" then

				local head = player.Character and player.Character:FindFirstChild("Head")
				if head and data.Container == head then
					task.spawn(function()
						for i = 1, 3 do
                    task.wait(BypassDelay)
                    finishRemote:FireServer()
                    rconsoleclear()
                  end
					end)
				end
			end
		end)
		print("[✅] Exclaim detection active (auto recast).")
	else
		warn("[⚠️] ReplicateTextEffect not found, skipping Exclaim logic.")
	end
end)

-- Fungsi utama Auto Fishing
local function autoFishingLoop()
	while autoFishingEnabled do
		local ok, err = pcall(function()
			updateDelayBasedOnRod()
			fishingActive = true
			updateStatus("🎣 Status: Fishing", Color3.fromRGB(100, 255, 100))
			equipRemote:FireServer(1)
			task.wait(0.1)

			local timestamp = workspace:GetServerTimeNow()
			rodRemote:InvokeServer(timestamp)

			local baseX, baseY = -0.7499996, 1
			local x = baseX + (math.random(-500, 500) / 10000000)
			local y = baseY + (math.random(-500, 500) / 10000000)

			miniGameRemote:InvokeServer(x, y)
			task.wait(customDelay)
			finishRemote:FireServer(true)

			task.wait(BypassDelay)
		end)
		if not ok then warn(err) end
		task.wait(0.2)
	end
	fishingActive = false
   updateStatus("🔴 Status: Idle")
end

-- ===================================
-- ========== AUTO SELL LOOP =========
-- ===================================
local function autoSellLoop()
    while autoSellEnabled do
        task.wait(1)
        
        local success, err = pcall(function()
            updateStatus("💰 Status: Selling", Color3.fromRGB(255, 215, 0))
            
            local sellSuccess = pcall(function()
                sellRemote:InvokeServer()
            end)

            if sellSuccess then
                updateStatus("✅ Status: Sold!. Please Stop Selling Button", Color3.fromRGB(100, 255, 100))
            else
                updateStatus("❌ Status: Sell Failed")
            end
        end)
          
        
        if not success then
            warn("[Auto Sell Error]:", err)
            updateStatus("❌ Status: Sell Error!")
        end
    end
    updateStatus("🔴 Status: Idle")
end

-- ===================================
-- ========== MISC FUNCTIONS =========
-- ===================================
local antiAfkEnabled = false
local noClipEnabled = false

-- Anti AFK
local function antiAfkLoop()
    while antiAfkEnabled do
        local virtualUser = game:GetService("VirtualUser")
        virtualUser:CaptureController()
        virtualUser:ClickButton2(Vector2.new())
        task.wait(30)
    end
end

-- No Clip
local function noClipLoop()
    while noClipEnabled do
        if character then
            for _, part in pairs(character:GetDescendants()) do
                if part:IsA("BasePart") and part.CanCollide then
                    part.CanCollide = false
                end
            end
        end
        task.wait(0.1)
    end
end

-- ===================================
-- ========== BUTTON LOGIC ===========
-- ===================================

-- Fishing Button
fishBtn.MouseButton1Click:Connect(function()
    autoFishingEnabled = not autoFishingEnabled
    
    if autoFishingEnabled then
        fishBtn.Text = "STOP"
        fishBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        updateStatus("🟢 Status: Auto Fishing Started", Color3.fromRGB(100, 255, 100))
        task.spawn(autoFishingLoop)
    else
        fishBtn.Text = "START"
        fishBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
        updateStatus("🔴 Status: Auto Fishing Stopped")
        delayInitialized = false
        fishingActive = false
    end
end)

-- Sell Button
sellBtn.MouseButton1Click:Connect(function()
    autoSellEnabled = not autoSellEnabled
    
    if autoSellEnabled then
        sellBtn.Text = "STOP"
        sellBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        updateStatus("🟢 Status: Auto Sell Started", Color3.fromRGB(100, 255, 100))
        task.spawn(autoSellLoop)
    else
        sellBtn.Text = "START"
        sellBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
        updateStatus("🔴 Status: Auto Sell Stopped")
    end
end)

-- Anti AFK Button
antiAfkBtn.MouseButton1Click:Connect(function()
    antiAfkEnabled = not antiAfkEnabled
    
    if antiAfkEnabled then
        antiAfkBtn.Text = "STOP"
        antiAfkBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        updateStatus("🟢 Anti AFK Enabled", Color3.fromRGB(100, 255, 100))
        task.spawn(antiAfkLoop)
    else
        antiAfkBtn.Text = "START"
        antiAfkBtn.BackgroundColor3 = Color3.fromRGB(80, 120, 200)
        updateStatus("🔴 Anti AFK Disabled")
    end
end)

-- No Clip Button
noClipBtn.MouseButton1Click:Connect(function()
    noClipEnabled = not noClipEnabled
    
    if noClipEnabled then
        noClipBtn.Text = "STOP"
        noClipBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        updateStatus("🟢 No Clip Enabled", Color3.fromRGB(100, 255, 100))
        task.spawn(noClipLoop)
    else
        noClipBtn.Text = "START"
        noClipBtn.BackgroundColor3 = Color3.fromRGB(150, 100, 200)
        updateStatus("🔴 No Clip Disabled")
    end
end)

-- Server Hop Button (Placeholder)
serverHopBtn.MouseButton1Click:Connect(function()
    updateStatus("🔄 Server Hop Feature - Coming Soon", Color3.fromRGB(255, 200, 100))
end)

-- Reconnect Button (Placeholder)
reconnectBtn.MouseButton1Click:Connect(function()
    updateStatus("🔁 Reconnect Feature - Coming Soon", Color3.fromRGB(255, 200, 100))
end)

closeBtn.MouseButton1Click:Connect(function()
    autoFishingEnabled = false
    autoSellEnabled = false
    antiAfkEnabled = false
    noClipEnabled = false
    fishingActive = false
    screenGui:Destroy()
end)

-- Minimize functionality
local minimized = false
minimizeBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    TweenService:Create(mainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
        Size = minimized and UDim2.new(0, 320, 0, 33) or UDim2.new(0, 320, 0, 400)
    }):Play()
    minimizeBtn.Text = minimized and "+" or "—"
end)

print("=================================")
print("🐟 Fish It Auto Farm Loaded!")
print("📁 Categories: MAIN, TELEPORT, MISC, SERVER")
print("=================================")
