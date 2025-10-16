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

-- Main Frame
local mainFrame = create("Frame", {
    Name = "MainFrame",
    Parent = screenGui,
    Size = UDim2.new(0, 300, 0, 370),
    Position = UDim2.new(0.5, -150, 0.5, -185),
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

local contentFrame = create("ScrollingFrame", {
    Name = "Content",
    Parent = mainFrame,
    Size = UDim2.new(1, -18, 1, -51),
    Position = UDim2.new(0, 9, 0, 42),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    ScrollBarThickness = 5,
    ScrollBarImageColor3 = Color3.fromRGB(50, 100, 180),
    CanvasSize = UDim2.new(0, 0, 0, 520)
})

local statusBox = create("Frame", {
    Parent = contentFrame,
    Size = UDim2.new(1, 0, 0, 54),
    BackgroundColor3 = Color3.fromRGB(25, 35, 50),
})

create("UICorner", {Parent = statusBox, CornerRadius = UDim.new(0, 7)})
create("UIStroke", {Parent = statusBox, Color = Color3.fromRGB(40, 60, 90), Thickness = 1})

local statusLabel = create("TextLabel", {
    Parent = statusBox,
    Size = UDim2.new(1, -12, 0, 18),
    Position = UDim2.new(0, 6, 0, 5),
    BackgroundTransparency = 1,
    Text = "🔴 Status: Idle\n🔴 Script: Beta Test V.0.1a\nNote: found bug on script? Pm me on discord!",
    Font = Enum.Font.GothamBold,
    TextSize = 10,
    TextColor3 = Color3.fromRGB(255, 100, 100),
    TextXAlignment = Enum.TextXAlignment.Left
})

local fishSection = create("Frame", {
    Parent = contentFrame,
    Size = UDim2.new(1, 0, 0, 42),
    Position = UDim2.new(0, 0, 0, 63),
    BackgroundColor3 = Color3.fromRGB(25, 35, 50),
})

create("UICorner", {Parent = fishSection, CornerRadius = UDim.new(0, 7)})
create("UIStroke", {Parent = fishSection, Color = Color3.fromRGB(40, 60, 90), Thickness = 1})

local fishTitle = create("TextLabel", {
    Parent = fishSection,
    Size = UDim2.new(0.55, 0, 1, 0),
    Position = UDim2.new(0, 9, 0, 0),
    BackgroundTransparency = 1,
    Text = "🎣 Auto Instant Fishing V1",
    Font = Enum.Font.GothamBold,
    TextSize = 9,
    TextColor3 = Color3.fromRGB(220, 220, 220),
    TextXAlignment = Enum.TextXAlignment.Left,
    TextYAlignment = Enum.TextYAlignment.Center
})

local fishBtn = create("TextButton", {
    Parent = fishSection,
    Size = UDim2.new(0, 72, 0, 29),
    Position = UDim2.new(1, -78, 0, 7),
    BackgroundColor3 = Color3.fromRGB(50, 150, 50),
    Text = "START",
    Font = Enum.Font.GothamBold,
    TextSize = 10,
    TextColor3 = Color3.fromRGB(255, 255, 255)
})

create("UICorner", {Parent = fishBtn, CornerRadius = UDim.new(0, 6)})

local sellSection = create("Frame", {
    Parent = contentFrame,
    Size = UDim2.new(1, 0, 0, 42),
    Position = UDim2.new(0, 0, 0, 114),
    BackgroundColor3 = Color3.fromRGB(25, 35, 50),
})

create("UICorner", {Parent = sellSection, CornerRadius = UDim.new(0, 7)})
create("UIStroke", {Parent = sellSection, Color = Color3.fromRGB(40, 60, 90), Thickness = 1})

local sellTitle = create("TextLabel", {
    Parent = sellSection,
    Size = UDim2.new(0.55, 0, 1, 0),
    Position = UDim2.new(0, 9, 0, 0),
    BackgroundTransparency = 1,
    Text = "💰 Auto Sell All",
    Font = Enum.Font.GothamBold,
    TextSize = 9,
    TextColor3 = Color3.fromRGB(220, 220, 220),
    TextXAlignment = Enum.TextXAlignment.Left,
    TextYAlignment = Enum.TextYAlignment.Center
})

local sellBtn = create("TextButton", {
    Parent = sellSection,
    Size = UDim2.new(0, 72, 0, 29),
    Position = UDim2.new(1, -78, 0, 7),
    BackgroundColor3 = Color3.fromRGB(50, 150, 50),
    Text = "START",
    Font = Enum.Font.GothamBold,
    TextSize = 10,
    TextColor3 = Color3.fromRGB(255, 255, 255)
})

create("UICorner", {Parent = sellBtn, CornerRadius = UDim.new(0, 6)})

-- ========== TELEPORT SECTION ==========
local teleportSection = create("Frame", {
    Parent = contentFrame,
    Size = UDim2.new(1, 0, 0, 42),
    Position = UDim2.new(0, 0, 0, 165),
    BackgroundColor3 = Color3.fromRGB(25, 35, 50),
})

create("UICorner", {Parent = teleportSection, CornerRadius = UDim.new(0, 7)})
create("UIStroke", {Parent = teleportSection, Color = Color3.fromRGB(40, 60, 90), Thickness = 1})

local teleportTitle = create("TextLabel", {
    Parent = teleportSection,
    Size = UDim2.new(0.55, 0, 1, 0),
    Position = UDim2.new(0, 9, 0, 0),
    BackgroundTransparency = 1,
    Text = "🚀 Teleport to Islands",
    Font = Enum.Font.GothamBold,
    TextSize = 9,
    TextColor3 = Color3.fromRGB(220, 220, 220),
    TextXAlignment = Enum.TextXAlignment.Left,
    TextYAlignment = Enum.TextYAlignment.Center
})

local teleportBtn = create("TextButton", {
    Parent = teleportSection,
    Size = UDim2.new(0, 72, 0, 29),
    Position = UDim2.new(1, -78, 0, 7),
    BackgroundColor3 = Color3.fromRGB(150, 100, 50),
    Text = "OPEN",
    Font = Enum.Font.GothamBold,
    TextSize = 10,
    TextColor3 = Color3.fromRGB(255, 255, 255)
})

create("UICorner", {Parent = teleportBtn, CornerRadius = UDim.new(0, 6)})

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
addHover(teleportBtn, Color3.fromRGB(150, 100, 50), Color3.fromRGB(170, 120, 70))

-- ===================================
-- ========== TELEPORT SYSTEM =========
-- ===================================

local islandCoords = {
    ["Weather Machine"] = Vector3.new(-1471, -3, 1929),
    ["Esoteric Depths"] = Vector3.new(3157, -1303, 1439),
    ["Tropical Grove"] = Vector3.new(-2038, 3, 3650),
    ["Stingray Shores"] = Vector3.new(-32, 4, 2773),
    ["Kohana Volcano"] = Vector3.new(-519, 24, 189),
    ["Coral Reefs"] = Vector3.new(-3095, 1, 2177),
    ["Crater Island"] = Vector3.new(968, 1, 4854),
    ["Kohana"] = Vector3.new(-658, 3, 719),
    ["Winter Fest"] = Vector3.new(1611, 4, 3280),
    ["Isoteric Island"] = Vector3.new(1987, 4, 1400),
    ["Treasure Hall"] = Vector3.new(-3600, -267, -1558),
    ["Lost Shore"] = Vector3.new(-3663, 38, -989),
    ["Sishypus Statue"] = Vector3.new(-3792, -135, -986),
    ["Ancient Jungle"] = Vector3.new(1316, 7, -196)
}

local function createTeleportGUI()
    local teleportGui = create("ScreenGui", {
        Name = "TeleportGUI",
        Parent = playerGui,
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    })

    local teleportFrame = create("Frame", {
        Name = "TeleportFrame",
        Parent = teleportGui,
        Size = UDim2.new(0, 280, 0, 350),
        Position = UDim2.new(0.5, -140, 0.5, -175),
        BackgroundColor3 = Color3.fromRGB(15, 20, 30),
        BorderSizePixel = 0
    })

    create("UICorner", {Parent = teleportFrame, CornerRadius = UDim.new(0, 10)})
    create("UIStroke", {Parent = teleportFrame, Color = Color3.fromRGB(40, 80, 150), Thickness = 1.5})

    local teleportTitle = create("TextLabel", {
        Parent = teleportFrame,
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundColor3 = Color3.fromRGB(25, 35, 55),
        Text = "🚀 Island Teleport",
        Font = Enum.Font.GothamBold,
        TextSize = 16,
        TextColor3 = Color3.fromRGB(100, 180, 255),
        TextYAlignment = Enum.TextYAlignment.Center
    })

    create("UICorner", {Parent = teleportTitle, CornerRadius = UDim.new(0, 10)})

    local closeTeleportBtn = create("TextButton", {
        Parent = teleportTitle,
        Size = UDim2.new(0, 25, 0, 25),
        Position = UDim2.new(1, -29, 0, 7),
        BackgroundColor3 = Color3.fromRGB(220, 50, 50),
        Text = "X",
        Font = Enum.Font.GothamBold,
        TextSize = 13,
        TextColor3 = Color3.fromRGB(255, 255, 255)
    })

    create("UICorner", {Parent = closeTeleportBtn, CornerRadius = UDim.new(0, 6)})

    local scrollFrame = create("ScrollingFrame", {
        Parent = teleportFrame,
        Size = UDim2.new(1, -20, 1, -60),
        Position = UDim2.new(0, 10, 0, 50),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 5,
        ScrollBarImageColor3 = Color3.fromRGB(50, 100, 180),
        CanvasSize = UDim2.new(0, 0, 0, #game:GetService("HttpService"):JSONEncode(islandCoords) * 40)
    })

    local yPosition = 0
    for islandName, position in pairs(islandCoords) do
        local islandBtn = create("TextButton", {
            Parent = scrollFrame,
            Size = UDim2.new(1, 0, 0, 35),
            Position = UDim2.new(0, 0, 0, yPosition),
            BackgroundColor3 = Color3.fromRGB(35, 45, 65),
            Text = "📍 " .. islandName,
            Font = Enum.Font.Gotham,
            TextSize = 12,
            TextColor3 = Color3.fromRGB(220, 220, 220),
            TextYAlignment = Enum.TextYAlignment.Center
        })

        create("UICorner", {Parent = islandBtn, CornerRadius = UDim.new(0, 6)})
        create("UIStroke", {Parent = islandBtn, Color = Color3.fromRGB(60, 100, 160), Thickness = 1})

        -- Hover effect
        addHover(islandBtn, Color3.fromRGB(35, 45, 65), Color3.fromRGB(45, 55, 75))

        islandBtn.MouseButton1Click:Connect(function()
            local charFolder = workspace:WaitForChild("Characters", 5)
            local char = charFolder:FindFirstChild(player.Name)
            if not char then 
                statusLabel.Text = "❌ Character not found"
                return 
            end
            
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if not hrp then 
                statusLabel.Text = "❌ HRP not found"
                return 
            end

            local success, err = pcall(function()
                hrp.CFrame = CFrame.new(position + Vector3.new(0, 5, 0))
            end)

            if success then
                statusLabel.Text = "✅ Teleported to " .. islandName
                statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
                teleportGui:Destroy()
            else
                statusLabel.Text = "❌ Teleport failed"
                statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
            end
        end)
        statusLabel.Text = "🔴 Status: Idle\n🔴 Script: Beta Test V.0.1a\nNote: found bug on script? Pm me on discord!"
        statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)

        yPosition = yPosition + 40
    end

    closeTeleportBtn.MouseButton1Click:Connect(function()
        teleportGui:Destroy()
    end)

    -- Drag functionality for teleport window
    local teleportDragging, teleportDragInput, teleportDragStart, teleportStartPos

    local function updateTeleportDrag(input)
        local delta = input.Position - teleportDragStart
        TweenService:Create(teleportFrame, TweenInfo.new(0.12, Enum.EasingStyle.Quad), {
            Position = UDim2.new(teleportStartPos.X.Scale, teleportStartPos.X.Offset + delta.X, teleportStartPos.Y.Scale, teleportStartPos.Y.Offset + delta.Y)
        }):Play()
    end

    teleportTitle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            teleportDragging = true
            teleportDragStart = input.Position
            teleportStartPos = teleportFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    teleportDragging = false
                end
            end)
        end
    end)

    teleportTitle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            teleportDragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if teleportDragging and input == teleportDragInput then
            updateTeleportDrag(input)
        end
    end)
end

-- ===================================
-- ========== EVENT TELEPORT ==========
-- ===================================

local eventsList = { 
    "Shark Hunt", 
    "Ghost Shark Hunt", 
    "Worm Hunt", 
    "Black Hole", 
    "Shocked", 
    "Ghost Worm", 
    "Meteor Rain" 
}

-- Tambah tombol baru di bawah tombol teleport island
local eventTeleportSection = create("Frame", {
    Parent = contentFrame,
    Size = UDim2.new(1, 0, 0, 42),
    Position = UDim2.new(0, 0, 0, 216), -- di bawah teleport island
    BackgroundColor3 = Color3.fromRGB(25, 35, 50),
})
create("UICorner", {Parent = eventTeleportSection, CornerRadius = UDim.new(0, 7)})
create("UIStroke", {Parent = eventTeleportSection, Color = Color3.fromRGB(40, 60, 90), Thickness = 1})

local eventTeleportTitle = create("TextLabel", {
    Parent = eventTeleportSection,
    Size = UDim2.new(0.55, 0, 1, 0),
    Position = UDim2.new(0, 9, 0, 0),
    BackgroundTransparency = 1,
    Text = "🌪️ Teleport to Event",
    Font = Enum.Font.GothamBold,
    TextSize = 9,
    TextColor3 = Color3.fromRGB(220, 220, 220),
    TextXAlignment = Enum.TextXAlignment.Left,
    TextYAlignment = Enum.TextYAlignment.Center
})

local eventTeleportBtn = create("TextButton", {
    Parent = eventTeleportSection,
    Size = UDim2.new(0, 72, 0, 29),
    Position = UDim2.new(1, -78, 0, 7),
    BackgroundColor3 = Color3.fromRGB(100, 120, 180),
    Text = "OPEN",
    Font = Enum.Font.GothamBold,
    TextSize = 10,
    TextColor3 = Color3.fromRGB(255, 255, 255)
})
create("UICorner", {Parent = eventTeleportBtn, CornerRadius = UDim.new(0, 6)})
addHover(eventTeleportBtn, Color3.fromRGB(100, 120, 180), Color3.fromRGB(120, 140, 200))


-- Fungsi untuk buat GUI teleport event
local function createEventTeleportGUI()
    local eventGui = create("ScreenGui", {
        Name = "EventTeleportGUI",
        Parent = playerGui,
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    })

    local eventFrame = create("Frame", {
        Parent = eventGui,
        Size = UDim2.new(0, 280, 0, 350),
        Position = UDim2.new(0.5, -140, 0.5, -175),
        BackgroundColor3 = Color3.fromRGB(15, 20, 30),
        BorderSizePixel = 0
    })
    create("UICorner", {Parent = eventFrame, CornerRadius = UDim.new(0, 10)})
    create("UIStroke", {Parent = eventFrame, Color = Color3.fromRGB(40, 80, 150), Thickness = 1.5})

    local title = create("TextLabel", {
        Parent = eventFrame,
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundColor3 = Color3.fromRGB(25, 35, 55),
        Text = "🌪️ Active Event Teleport",
        Font = Enum.Font.GothamBold,
        TextSize = 16,
        TextColor3 = Color3.fromRGB(100, 180, 255)
    })
    create("UICorner", {Parent = title, CornerRadius = UDim.new(0, 10)})

    local closeBtn = create("TextButton", {
        Parent = title,
        Size = UDim2.new(0, 25, 0, 25),
        Position = UDim2.new(1, -29, 0, 7),
        BackgroundColor3 = Color3.fromRGB(220, 50, 50),
        Text = "X",
        Font = Enum.Font.GothamBold,
        TextSize = 13,
        TextColor3 = Color3.fromRGB(255, 255, 255)
    })
    create("UICorner", {Parent = closeBtn, CornerRadius = UDim.new(0, 6)})

    local scroll = create("ScrollingFrame", {
        Parent = eventFrame,
        Size = UDim2.new(1, -20, 1, -60),
        Position = UDim2.new(0, 10, 0, 50),
        BackgroundTransparency = 1,
        ScrollBarThickness = 5,
        ScrollBarImageColor3 = Color3.fromRGB(50, 100, 180),
        CanvasSize = UDim2.new(0, 0, 0, #eventsList * 40)
    })

    local y = 0
    for _, eventName in ipairs(eventsList) do
        local eventBtn = create("TextButton", {
            Parent = scroll,
            Size = UDim2.new(1, 0, 0, 35),
            Position = UDim2.new(0, 0, 0, y),
            BackgroundColor3 = Color3.fromRGB(35, 45, 65),
            Text = "📍 " .. eventName,
            Font = Enum.Font.Gotham,
            TextSize = 12,
            TextColor3 = Color3.fromRGB(220, 220, 220)
        })
        create("UICorner", {Parent = eventBtn, CornerRadius = UDim.new(0, 6)})
        create("UIStroke", {Parent = eventBtn, Color = Color3.fromRGB(60, 100, 160), Thickness = 1})
        addHover(eventBtn, Color3.fromRGB(35, 45, 65), Color3.fromRGB(45, 55, 75))

        eventBtn.MouseButton1Click:Connect(function()
            local props = workspace:FindFirstChild("Props")
            if props and props:FindFirstChild(eventName) and props[eventName]:FindFirstChild("Fishing Boat") then
                local fishingBoat = props[eventName]["Fishing Boat"]
                local boatCFrame = fishingBoat:GetPivot()
                local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    hrp.CFrame = boatCFrame + Vector3.new(0, 15, 0)
                    statusLabel.Text = "✅ Teleported to " .. eventName
                    statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
                    eventGui:Destroy()
                end
            else
                statusLabel.Text = "❌ Event not found: " .. eventName
                statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
            end
        end)

        y += 40
    end

    closeBtn.MouseButton1Click:Connect(function()
        eventGui:Destroy()
    end)
end

-- Buka GUI Event Teleport
eventTeleportBtn.MouseButton1Click:Connect(function()
    createEventTeleportGUI()
end)

-- ===================================
-- ========== NPC TELEPORT ===========
-- ===================================

-- Ambil folder NPC
local npcFolder = game:GetService("ReplicatedStorage"):WaitForChild("NPC")

-- Ambil semua NPC yang punya HumanoidRootPart
local npcList = {}
for _, npc in pairs(npcFolder:GetChildren()) do
	if npc:IsA("Model") then
		local hrp = npc:FindFirstChild("HumanoidRootPart") or npc.PrimaryPart
		if hrp then
			table.insert(npcList, npc.Name)
		end
	end
end

-- Tambah section baru di bawah event teleport
local npcTeleportSection = create("Frame", {
    Parent = contentFrame,
    Size = UDim2.new(1, 0, 0, 42),
    Position = UDim2.new(0, 0, 0, 267), -- di bawah Event Teleport
    BackgroundColor3 = Color3.fromRGB(25, 35, 50),
})
create("UICorner", {Parent = npcTeleportSection, CornerRadius = UDim.new(0, 7)})
create("UIStroke", {Parent = npcTeleportSection, Color = Color3.fromRGB(40, 60, 90), Thickness = 1})

local npcTeleportTitle = create("TextLabel", {
    Parent = npcTeleportSection,
    Size = UDim2.new(0.55, 0, 1, 0),
    Position = UDim2.new(0, 9, 0, 0),
    BackgroundTransparency = 1,
    Text = "🧍 Teleport to NPC",
    Font = Enum.Font.GothamBold,
    TextSize = 9,
    TextColor3 = Color3.fromRGB(220, 220, 220),
    TextXAlignment = Enum.TextXAlignment.Left,
    TextYAlignment = Enum.TextYAlignment.Center
})

local npcTeleportBtn = create("TextButton", {
    Parent = npcTeleportSection,
    Size = UDim2.new(0, 72, 0, 29),
    Position = UDim2.new(1, -78, 0, 7),
    BackgroundColor3 = Color3.fromRGB(80, 120, 160),
    Text = "OPEN",
    Font = Enum.Font.GothamBold,
    TextSize = 10,
    TextColor3 = Color3.fromRGB(255, 255, 255)
})
create("UICorner", {Parent = npcTeleportBtn, CornerRadius = UDim.new(0, 6)})
addHover(npcTeleportBtn, Color3.fromRGB(80, 120, 160), Color3.fromRGB(100, 140, 180))


-- Fungsi buat GUI list NPC
local function createNPCTeleportGUI()
    local npcGui = create("ScreenGui", {
        Name = "NPCTeleportGUI",
        Parent = playerGui,
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    })

    local npcFrame = create("Frame", {
        Parent = npcGui,
        Size = UDim2.new(0, 280, 0, 350),
        Position = UDim2.new(0.5, -140, 0.5, -175),
        BackgroundColor3 = Color3.fromRGB(15, 20, 30),
        BorderSizePixel = 0
    })
    create("UICorner", {Parent = npcFrame, CornerRadius = UDim.new(0, 10)})
    create("UIStroke", {Parent = npcFrame, Color = Color3.fromRGB(40, 80, 150), Thickness = 1.5})

    local title = create("TextLabel", {
        Parent = npcFrame,
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundColor3 = Color3.fromRGB(25, 35, 55),
        Text = "🧍 NPC Teleport List",
        Font = Enum.Font.GothamBold,
        TextSize = 16,
        TextColor3 = Color3.fromRGB(100, 180, 255)
    })
    create("UICorner", {Parent = title, CornerRadius = UDim.new(0, 10)})

    local closeBtn = create("TextButton", {
        Parent = title,
        Size = UDim2.new(0, 25, 0, 25),
        Position = UDim2.new(1, -29, 0, 7),
        BackgroundColor3 = Color3.fromRGB(220, 50, 50),
        Text = "X",
        Font = Enum.Font.GothamBold,
        TextSize = 13,
        TextColor3 = Color3.fromRGB(255, 255, 255)
    })
    create("UICorner", {Parent = closeBtn, CornerRadius = UDim.new(0, 6)})

    local scroll = create("ScrollingFrame", {
        Parent = npcFrame,
        Size = UDim2.new(1, -20, 1, -60),
        Position = UDim2.new(0, 10, 0, 50),
        BackgroundTransparency = 1,
        ScrollBarThickness = 5,
        ScrollBarImageColor3 = Color3.fromRGB(50, 100, 180),
        CanvasSize = UDim2.new(0, 0, 0, #npcList * 40)
    })

    local y = 0
    for _, npcName in ipairs(npcList) do
        local npcBtn = create("TextButton", {
            Parent = scroll,
            Size = UDim2.new(1, 0, 0, 35),
            Position = UDim2.new(0, 0, 0, y),
            BackgroundColor3 = Color3.fromRGB(35, 45, 65),
            Text = "📍 " .. npcName,
            Font = Enum.Font.Gotham,
            TextSize = 12,
            TextColor3 = Color3.fromRGB(220, 220, 220)
        })
        create("UICorner", {Parent = npcBtn, CornerRadius = UDim.new(0, 6)})
        create("UIStroke", {Parent = npcBtn, Color = Color3.fromRGB(60, 100, 160), Thickness = 1})
        addHover(npcBtn, Color3.fromRGB(35, 45, 65), Color3.fromRGB(45, 55, 75))

        npcBtn.MouseButton1Click:Connect(function()
            local npc = npcFolder:FindFirstChild(npcName)
            if npc and npc:IsA("Model") then
                local npcHrp = npc:FindFirstChild("HumanoidRootPart") or npc.PrimaryPart
                if npcHrp then
                    local charFolder = workspace:FindFirstChild("Characters", 5)
                    local char = charFolder and charFolder:FindFirstChild(player.Name)
                    if not char then 
                        statusLabel.Text = "❌ Character not found"
                        return 
                    end

                    local myHRP = char:FindFirstChild("HumanoidRootPart")
                    if myHRP then
                        myHRP.CFrame = npcHrp.CFrame + Vector3.new(0, 3, 0)
                        statusLabel.Text = "✅ Teleported to NPC: " .. npcName
                        statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
                        npcGui:Destroy()
                    end
                end
            else
                statusLabel.Text = "❌ NPC not found: " .. npcName
                statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
            end
        end)
        y += 40
    end

    closeBtn.MouseButton1Click:Connect(function()
        npcGui:Destroy()
    end)
end

-- Buka GUI NPC Teleport
npcTeleportBtn.MouseButton1Click:Connect(function()
    createNPCTeleportGUI()
end)

-- ===================================
-- ========== ANTI-AFK SYSTEM =========
-- ===================================

local VirtualUser = game:GetService("VirtualUser")
local AntiAFKEnabled = false
local AFKConnection = nil

-- Tambah section Anti-AFK di bawah NPC Teleport
local antiAFKSection = create("Frame", {
    Parent = contentFrame,
    Size = UDim2.new(1, 0, 0, 42),
    Position = UDim2.new(0, 0, 0, 318), -- di bawah Teleport to NPC
    BackgroundColor3 = Color3.fromRGB(25, 35, 50),
})
create("UICorner", {Parent = antiAFKSection, CornerRadius = UDim.new(0, 7)})
create("UIStroke", {Parent = antiAFKSection, Color = Color3.fromRGB(40, 60, 90), Thickness = 1})

local antiAFKTitle = create("TextLabel", {
    Parent = antiAFKSection,
    Size = UDim2.new(0.55, 0, 1, 0),
    Position = UDim2.new(0, 9, 0, 0),
    BackgroundTransparency = 1,
    Text = "👤 Anti-AFK System",
    Font = Enum.Font.GothamBold,
    TextSize = 9,
    TextColor3 = Color3.fromRGB(220, 220, 220),
    TextXAlignment = Enum.TextXAlignment.Left,
    TextYAlignment = Enum.TextYAlignment.Center
})

local antiAFKBtn = create("TextButton", {
    Parent = antiAFKSection,
    Size = UDim2.new(0, 72, 0, 29),
    Position = UDim2.new(1, -78, 0, 7),
    BackgroundColor3 = Color3.fromRGB(150, 100, 50),
    Text = "ENABLE",
    Font = Enum.Font.GothamBold,
    TextSize = 10,
    TextColor3 = Color3.fromRGB(255, 255, 255)
})
create("UICorner", {Parent = antiAFKBtn, CornerRadius = UDim.new(0, 6)})
addHover(antiAFKBtn, Color3.fromRGB(150, 100, 50), Color3.fromRGB(170, 120, 70))


-- Fungsi untuk mengaktifkan/menonaktifkan Anti-AFK
local function toggleAntiAFK(enable)
    AntiAFKEnabled = enable

    if enable then
        if AFKConnection then
            AFKConnection:Disconnect()
        end

        AFKConnection = player.Idled:Connect(function()
            pcall(function()
                VirtualUser:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
                task.wait(1)
                VirtualUser:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
            end)
        end)

        statusLabel.Text = "🟢 Anti-AFK Activated"
        statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
        antiAFKBtn.Text = "DISABLE"
        antiAFKBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    else
        if AFKConnection then
            AFKConnection:Disconnect()
            AFKConnection = nil
        end
        statusLabel.Text = "🔴 Anti-AFK Disabled"
        statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
        antiAFKBtn.Text = "ENABLE"
        antiAFKBtn.BackgroundColor3 = Color3.fromRGB(150, 100, 50)
    end
end

-- Klik tombol untuk aktifkan/matikan anti-AFK
antiAFKBtn.MouseButton1Click:Connect(function()
    toggleAntiAFK(not AntiAFKEnabled)
end)

-- ===================================
-- ========== FISHING V1 ===========
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
        statusLabel.Text = "✅ Rod Detected: " .. rodName
        statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
    else
        customDelay = 10
        BypassDelay = 1
        delayInitialized = true
        statusLabel.Text = "⚠️ Default Delay Applied"
        statusLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
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
                    task.wait(BypassDelayV2)
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

			statusLabel.Text = "🎣 Casting..."
			equipRemote:FireServer(1)
			task.wait(0.1)

			local timestamp = workspace:GetServerTimeNow()
         RodShakeAnim:Play()
			rodRemote:InvokeServer(timestamp)

			local baseX, baseY = -0.7499996, 1
			local x = baseX + (math.random(-500, 500) / 10000000)
			local y = baseY + (math.random(-500, 500) / 10000000)

         RodIdleAnim:Play()
			miniGameRemote:InvokeServer(x, y)
			task.wait(customDelay)

			finishRemote:FireServer(true)
			task.wait(BypassDelay)
		end)
		if not ok then warn(err) end
		task.wait(0.2)
	end
	fishingActive = false
   statusLabel.Text = "🔴 Status: Idle\n🔴 Script: Beta Test V.0.1a\nNote: found bug on script? Pm me on discord!"
   statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
end

-- ===================================
-- ========== AUTO SELL LOOP =========
-- ===================================

local function autoSellLoop()
    local lastSellTime = 0 -- waktu terakhir jual
    local cooldown = 60    -- jeda 60 detik sebelum bisa jual lagi

    while autoSellEnabled do
        task.wait(1) -- loop tetap hidup, tapi cek tiap 1 detik

        local now = os.time()
        if now - lastSellTime >= cooldown then
            -- waktunya jual lagi
            local success, err = pcall(function()
                statusLabel.Text = "💰 Selling fish..."
                statusLabel.TextColor3 = Color3.fromRGB(255, 215, 0)

                local sellSuccess = pcall(function()
                    sellRemote:InvokeServer()
                end)

                if sellSuccess then
                    statusLabel.Text = "✅ Sold! (Next sell in 60s)"
                    statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
                    lastSellTime = os.time() -- update waktu terakhir jual
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
        else
            -- masih cooldown
            local remaining = cooldown - (now - lastSellTime)
            statusLabel.Text = string.format("⏳ Next sell in %ds", remaining)
            statusLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
        end
    end

    statusLabel.Text = "🔴 Status: Idle\n🔴 Script: Beta Test V.0.1a\nNote: found bug on script? Pm me on discord!"
    statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
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

-- Teleport Button Logic
teleportBtn.MouseButton1Click:Connect(function()
    createTeleportGUI()
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
        Size = minimized and UDim2.new(0, 300, 0, 33) or UDim2.new(0, 300, 0, 370)
    }):Play()
    minimizeBtn.Text = minimized and "+" or "—"
end)

print("=================================")
print("🐟 Fish It Auto Farm Loaded!")
print("=================================")
print("✅ GUI berhasil dimuat untuk:", player.Name)
print("📌 Equip fishing rod dan tekan START")
print("🎯 Logic fishing telah diperbaiki.")
print("🚀 Teleport feature added!")
print("=================================")
