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

-- Main Frame - Diperbesar untuk menampung section V2
local mainFrame = create("Frame", {
    Name = "MainFrame",
    Parent = screenGui,
    Size = UDim2.new(0, 300, 0, 390), -- Diperbesar dari 340 menjadi 390
    Position = UDim2.new(0.5, -150, 0.5, -195),
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
    Text = "🐟 Fish It - Codepikk (free)",
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

-- Content Frame - Diperbesar untuk menampung section V2
local contentFrame = create("ScrollingFrame", {
    Name = "Content",
    Parent = mainFrame,
    Size = UDim2.new(1, -18, 1, -51),
    Position = UDim2.new(0, 9, 0, 42),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    ScrollBarThickness = 5,
    ScrollBarImageColor3 = Color3.fromRGB(50, 100, 180),
    CanvasSize = UDim2.new(0, 0, 0, 470) -- Diperbesar dari 420 menjadi 470
})

-- Status Box - Diperkecil
local statusBox = create("Frame", {
    Parent = contentFrame,
    Size = UDim2.new(1, 0, 0, 50),
    BackgroundColor3 = Color3.fromRGB(25, 35, 50),
})

create("UICorner", {Parent = statusBox, CornerRadius = UDim.new(0, 7)})
create("UIStroke", {Parent = statusBox, Color = Color3.fromRGB(40, 60, 90), Thickness = 1})

-- Status Label dengan format yang dipertahankan
local statusLabel = create("TextLabel", {
    Parent = statusBox,
    Size = UDim2.new(1, -12, 1, -8),
    Position = UDim2.new(0, 6, 0, 4),
    BackgroundTransparency = 1,
    Text = "🔴 Status: Idle\nScript: Beta Release V.2.1a\nUpdate: +Adding Teleport To NPC, Islands & Events\nNote: found bug on script? Pm me on discord!",
    Font = Enum.Font.GothamBold,
    TextSize = 10,
    TextColor3 = Color3.fromRGB(255, 100, 100),
    TextXAlignment = Enum.TextXAlignment.Left
})

-- Fungsi untuk update status dengan format yang dipertahankan
local function updateStatus(newStatus, color)
    local baseText = "Script: Beta Release V.2.1a\nUpdate: +Adding Teleport to NPC, Islands & Events\nNote: found bug on script? Pm me on discord!"
    statusLabel.Text = newStatus .. "\n" .. baseText
    statusLabel.TextColor3 = color or Color3.fromRGB(255, 100, 100)
end

-- Inisialisasi status awal
updateStatus("🔴 Status: Idle")

-- ========== FISHING V2 SECTION ==========
local fishV2Section = create("Frame", {
    Parent = contentFrame,
    Size = UDim2.new(1, 0, 0, 40),
    Position = UDim2.new(0, 0, 0, 58),
    BackgroundColor3 = Color3.fromRGB(25, 35, 50),
})

create("UICorner", {Parent = fishV2Section, CornerRadius = UDim.new(0, 7)})
create("UIStroke", {Parent = fishV2Section, Color = Color3.fromRGB(40, 60, 90), Thickness = 1})

local fishV2Title = create("TextLabel", {
    Parent = fishV2Section,
    Size = UDim2.new(0.55, 0, 1, 0),
    Position = UDim2.new(0, 9, 0, 0),
    BackgroundTransparency = 1,
    Text = "🎣 Auto Instant Fishing V2 (FAST)",
    Font = Enum.Font.GothamBold,
    TextSize = 9,
    TextColor3 = Color3.fromRGB(220, 220, 220),
    TextXAlignment = Enum.TextXAlignment.Left,
    TextYAlignment = Enum.TextYAlignment.Center
})

local fishV2Btn = create("TextButton", {
    Parent = fishV2Section,
    Size = UDim2.new(0, 72, 0, 27),
    Position = UDim2.new(1, -78, 0, 6),
    BackgroundColor3 = Color3.fromRGB(50, 150, 50),
    Text = "START",
    Font = Enum.Font.GothamBold,
    TextSize = 10,
    TextColor3 = Color3.fromRGB(255, 255, 255)
})

create("UICorner", {Parent = fishV2Btn, CornerRadius = UDim.new(0, 6)})

-- Fish Section V1 - Posisi diatur ulang
local fishSection = create("Frame", {
    Parent = contentFrame,
    Size = UDim2.new(1, 0, 0, 40),
    Position = UDim2.new(0, 0, 0, 106),
    BackgroundColor3 = Color3.fromRGB(25, 35, 50),
})

create("UICorner", {Parent = fishSection, CornerRadius = UDim.new(0, 7)})
create("UIStroke", {Parent = fishSection, Color = Color3.fromRGB(40, 60, 90), Thickness = 1})

local fishTitle = create("TextLabel", {
    Parent = fishSection,
    Size = UDim2.new(0.55, 0, 1, 0),
    Position = UDim2.new(0, 9, 0, 0),
    BackgroundTransparency = 1,
    Text = "🎣 Auto Instant Fishing V1 (Hold Your Rod First)",
    Font = Enum.Font.GothamBold,
    TextSize = 9,
    TextColor3 = Color3.fromRGB(220, 220, 220),
    TextXAlignment = Enum.TextXAlignment.Left,
    TextYAlignment = Enum.TextYAlignment.Center
})

local fishBtn = create("TextButton", {
    Parent = fishSection,
    Size = UDim2.new(0, 72, 0, 27),
    Position = UDim2.new(1, -78, 0, 6),
    BackgroundColor3 = Color3.fromRGB(50, 150, 50),
    Text = "START",
    Font = Enum.Font.GothamBold,
    TextSize = 10,
    TextColor3 = Color3.fromRGB(255, 255, 255)
})

create("UICorner", {Parent = fishBtn, CornerRadius = UDim.new(0, 6)})

-- Sell Section - Posisi diatur ulang
local sellSection = create("Frame", {
    Parent = contentFrame,
    Size = UDim2.new(1, 0, 0, 40),
    Position = UDim2.new(0, 0, 0, 154),
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
    Size = UDim2.new(0, 72, 0, 27),
    Position = UDim2.new(1, -78, 0, 6),
    BackgroundColor3 = Color3.fromRGB(50, 150, 50),
    Text = "START",
    Font = Enum.Font.GothamBold,
    TextSize = 10,
    TextColor3 = Color3.fromRGB(255, 255, 255)
})

create("UICorner", {Parent = sellBtn, CornerRadius = UDim.new(0, 6)})

-- ========== TELEPORT TO ISLANDS SECTION ==========
local teleportSection = create("Frame", {
    Parent = contentFrame,
    Size = UDim2.new(1, 0, 0, 40),
    Position = UDim2.new(0, 0, 0, 202),
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
    Size = UDim2.new(0, 72, 0, 27),
    Position = UDim2.new(1, -78, 0, 6),
    BackgroundColor3 = Color3.fromRGB(150, 100, 50),
    Text = "OPEN",
    Font = Enum.Font.GothamBold,
    TextSize = 10,
    TextColor3 = Color3.fromRGB(255, 255, 255)
})

create("UICorner", {Parent = teleportBtn, CornerRadius = UDim.new(0, 6)})

-- ========== TELEPORT TO NPC SECTION ==========
local teleportNPCSection = create("Frame", {
    Parent = contentFrame,
    Size = UDim2.new(1, 0, 0, 40),
    Position = UDim2.new(0, 0, 0, 250),
    BackgroundColor3 = Color3.fromRGB(25, 35, 50),
})

create("UICorner", {Parent = teleportNPCSection, CornerRadius = UDim.new(0, 7)})
create("UIStroke", {Parent = teleportNPCSection, Color = Color3.fromRGB(40, 60, 90), Thickness = 1})

local teleportNPCTitle = create("TextLabel", {
    Parent = teleportNPCSection,
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

local teleportNPCBtn = create("TextButton", {
    Parent = teleportNPCSection,
    Size = UDim2.new(0, 72, 0, 27),
    Position = UDim2.new(1, -78, 0, 6),
    BackgroundColor3 = Color3.fromRGB(100, 80, 180),
    Text = "OPEN",
    Font = Enum.Font.GothamBold,
    TextSize = 10,
    TextColor3 = Color3.fromRGB(255, 255, 255)
})

create("UICorner", {Parent = teleportNPCBtn, CornerRadius = UDim.new(0, 6)})

-- ========== TELEPORT TO EVENT SECTION ==========
local teleportEventSection = create("Frame", {
    Parent = contentFrame,
    Size = UDim2.new(1, 0, 0, 40),
    Position = UDim2.new(0, 0, 0, 298),
    BackgroundColor3 = Color3.fromRGB(25, 35, 50),
})

create("UICorner", {Parent = teleportEventSection, CornerRadius = UDim.new(0, 7)})
create("UIStroke", {Parent = teleportEventSection, Color = Color3.fromRGB(40, 60, 90), Thickness = 1})

local teleportEventTitle = create("TextLabel", {
    Parent = teleportEventSection,
    Size = UDim2.new(0.55, 0, 1, 0),
    Position = UDim2.new(0, 9, 0, 0),
    BackgroundTransparency = 1,
    Text = "🎯 Teleport to Events",
    Font = Enum.Font.GothamBold,
    TextSize = 9,
    TextColor3 = Color3.fromRGB(220, 220, 220),
    TextXAlignment = Enum.TextXAlignment.Left,
    TextYAlignment = Enum.TextYAlignment.Center
})

local teleportEventBtn = create("TextButton", {
    Parent = teleportEventSection,
    Size = UDim2.new(0, 72, 0, 27),
    Position = UDim2.new(1, -78, 0, 6),
    BackgroundColor3 = Color3.fromRGB(180, 80, 120),
    Text = "OPEN",
    Font = Enum.Font.GothamBold,
    TextSize = 10,
    TextColor3 = Color3.fromRGB(255, 255, 255)
})

create("UICorner", {Parent = teleportEventBtn, CornerRadius = UDim.new(0, 6)})

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
addHover(fishV2Btn, Color3.fromRGB(50, 150, 50), Color3.fromRGB(70, 170, 70))
addHover(fishBtn, Color3.fromRGB(50, 150, 50), Color3.fromRGB(70, 170, 70))
addHover(sellBtn, Color3.fromRGB(50, 150, 50), Color3.fromRGB(70, 170, 70))
addHover(teleportBtn, Color3.fromRGB(150, 100, 50), Color3.fromRGB(170, 120, 70))
addHover(teleportNPCBtn, Color3.fromRGB(100, 80, 180), Color3.fromRGB(120, 100, 200))
addHover(teleportEventBtn, Color3.fromRGB(180, 80, 120), Color3.fromRGB(200, 100, 140))

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

    -- Teleport Frame - Diperkecil menjadi lebih compact
    local teleportFrame = create("Frame", {
        Name = "TeleportFrame",
        Parent = teleportGui,
        Size = UDim2.new(0, 280, 0, 300),
        Position = UDim2.new(0.5, -140, 0.5, -150),
        BackgroundColor3 = Color3.fromRGB(15, 20, 30),
        BorderSizePixel = 0
    })

    create("UICorner", {Parent = teleportFrame, CornerRadius = UDim.new(0, 10)})
    create("UIStroke", {Parent = teleportFrame, Color = Color3.fromRGB(40, 80, 150), Thickness = 1.5})

    local teleportTitle = create("TextLabel", {
        Parent = teleportFrame,
        Size = UDim2.new(1, 0, 0, 35),
        BackgroundColor3 = Color3.fromRGB(25, 35, 55),
        Text = "🚀 Island Teleport",
        Font = Enum.Font.GothamBold,
        TextSize = 14,
        TextColor3 = Color3.fromRGB(100, 180, 255),
        TextYAlignment = Enum.TextYAlignment.Center
    })

    create("UICorner", {Parent = teleportTitle, CornerRadius = UDim.new(0, 10)})

    local closeTeleportBtn = create("TextButton", {
        Parent = teleportTitle,
        Size = UDim2.new(0, 22, 0, 22),
        Position = UDim2.new(1, -26, 0, 6),
        BackgroundColor3 = Color3.fromRGB(220, 50, 50),
        Text = "X",
        Font = Enum.Font.GothamBold,
        TextSize = 12,
        TextColor3 = Color3.fromRGB(255, 255, 255)
    })

    create("UICorner", {Parent = closeTeleportBtn, CornerRadius = UDim.new(0, 6)})

    local scrollFrame = create("ScrollingFrame", {
        Parent = teleportFrame,
        Size = UDim2.new(1, -20, 1, -50),
        Position = UDim2.new(0, 10, 0, 45),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 5,
        ScrollBarImageColor3 = Color3.fromRGB(50, 100, 180),
        CanvasSize = UDim2.new(0, 0, 0, #game:GetService("HttpService"):JSONEncode(islandCoords) * 35)
    })

    local yPosition = 0
    for islandName, position in pairs(islandCoords) do
        local islandBtn = create("TextButton", {
            Parent = scrollFrame,
            Size = UDim2.new(1, 0, 0, 32),
            Position = UDim2.new(0, 0, 0, yPosition),
            BackgroundColor3 = Color3.fromRGB(35, 45, 65),
            Text = "📍 " .. islandName,
            Font = Enum.Font.Gotham,
            TextSize = 11,
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
                updateStatus("✅ Success Teleport to " .. islandName, Color3.fromRGB(100, 255, 100))
                teleportGui:Destroy()
            else
                updateStatus("❌ Teleport failed")
            end
        end)

        yPosition = yPosition + 35
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
-- ========== TELEPORT TO NPC SYSTEM =========
-- ===================================

local function createNPCTeleportGUI()
    -- Cari folder NPC
    local npcFolder = ReplicatedStorage:FindFirstChild("NPC")
    if not npcFolder then
        updateStatus("❌ NPC folder not found")
        return
    end

    -- Dapatkan daftar NPC
    local npcList = {}
    for _, npc in pairs(npcFolder:GetChildren()) do
        if npc:IsA("Model") then
            local hrp = npc:FindFirstChild("HumanoidRootPart") or npc.PrimaryPart
            if hrp then
                table.insert(npcList, npc.Name)
            end
        end
    end

    if #npcList == 0 then
        updateStatus("❌ No NPCs found")
        return
    end

    -- Buat GUI untuk Teleport to NPC
    local npcTeleportGui = create("ScreenGui", {
        Name = "NPCTeleportGUI",
        Parent = playerGui,
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    })

    -- NPC Teleport Frame
    local npcTeleportFrame = create("Frame", {
        Name = "NPCTeleportFrame",
        Parent = npcTeleportGui,
        Size = UDim2.new(0, 280, 0, 350),
        Position = UDim2.new(0.5, -140, 0.5, -175),
        BackgroundColor3 = Color3.fromRGB(15, 20, 30),
        BorderSizePixel = 0
    })

    create("UICorner", {Parent = npcTeleportFrame, CornerRadius = UDim.new(0, 10)})
    create("UIStroke", {Parent = npcTeleportFrame, Color = Color3.fromRGB(40, 80, 150), Thickness = 1.5})

    local npcTeleportTitle = create("TextLabel", {
        Parent = npcTeleportFrame,
        Size = UDim2.new(1, 0, 0, 35),
        BackgroundColor3 = Color3.fromRGB(25, 35, 55),
        Text = "🧍 NPC Teleport",
        Font = Enum.Font.GothamBold,
        TextSize = 14,
        TextColor3 = Color3.fromRGB(100, 180, 255),
        TextYAlignment = Enum.TextYAlignment.Center
    })

    create("UICorner", {Parent = npcTeleportTitle, CornerRadius = UDim.new(0, 10)})

    local closeNPCTeleportBtn = create("TextButton", {
        Parent = npcTeleportTitle,
        Size = UDim2.new(0, 22, 0, 22),
        Position = UDim2.new(1, -26, 0, 6),
        BackgroundColor3 = Color3.fromRGB(220, 50, 50),
        Text = "X",
        Font = Enum.Font.GothamBold,
        TextSize = 12,
        TextColor3 = Color3.fromRGB(255, 255, 255)
    })

    create("UICorner", {Parent = closeNPCTeleportBtn, CornerRadius = UDim.new(0, 6)})

    -- Search Box
    local searchBox = create("TextBox", {
        Parent = npcTeleportFrame,
        Size = UDim2.new(1, -20, 0, 30),
        Position = UDim2.new(0, 10, 0, 45),
        BackgroundColor3 = Color3.fromRGB(25, 35, 50),
        PlaceholderText = "🔍 Search NPC...",
        PlaceholderColor3 = Color3.fromRGB(150, 150, 150),
        Text = "",
        Font = Enum.Font.Gotham,
        TextSize = 12,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextXAlignment = Enum.TextXAlignment.Left,
        ClearTextOnFocus = false
    })

    create("UICorner", {Parent = searchBox, CornerRadius = UDim.new(0, 6)})
    create("UIStroke", {Parent = searchBox, Color = Color3.fromRGB(40, 60, 90), Thickness = 1})

    create("UIPadding", {
        Parent = searchBox,
        PaddingLeft = UDim.new(0, 8)
    })

    local scrollFrame = create("ScrollingFrame", {
        Parent = npcTeleportFrame,
        Size = UDim2.new(1, -20, 1, -95),
        Position = UDim2.new(0, 10, 0, 85),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 5,
        ScrollBarImageColor3 = Color3.fromRGB(50, 100, 180),
        CanvasSize = UDim2.new(0, 0, 0, #npcList * 35)
    })

    local function createNPCButtons(filterText)
        -- Hapus button yang sudah ada
        for _, child in ipairs(scrollFrame:GetChildren()) do
            if child:IsA("TextButton") then
                child:Destroy()
            end
        end

        local yPosition = 0
        local filteredCount = 0

        for _, npcName in ipairs(npcList) do
            if string.lower(npcName):find(string.lower(filterText or "")) then
                local npcBtn = create("TextButton", {
                    Parent = scrollFrame,
                    Size = UDim2.new(1, 0, 0, 32),
                    Position = UDim2.new(0, 0, 0, yPosition),
                    BackgroundColor3 = Color3.fromRGB(35, 45, 65),
                    Text = "🧍 " .. npcName,
                    Font = Enum.Font.Gotham,
                    TextSize = 11,
                    TextColor3 = Color3.fromRGB(220, 220, 220),
                    TextYAlignment = Enum.TextYAlignment.Center
                })

                create("UICorner", {Parent = npcBtn, CornerRadius = UDim.new(0, 6)})
                create("UIStroke", {Parent = npcBtn, Color = Color3.fromRGB(60, 100, 160), Thickness = 1})

                -- Hover effect
                addHover(npcBtn, Color3.fromRGB(35, 45, 65), Color3.fromRGB(45, 55, 75))

                npcBtn.MouseButton1Click:Connect(function()
                    local npc = npcFolder:FindFirstChild(npcName)
                    if npc and npc:IsA("Model") then
                        local hrp = npc:FindFirstChild("HumanoidRootPart") or npc.PrimaryPart
                        if hrp then
                            local charFolder = workspace:FindFirstChild("Characters")
                            local char = charFolder and charFolder:FindFirstChild(player.Name)
                            if not char then 
                                updateStatus("❌ Character not found")
                                return 
                            end
                            
                            local myHRP = char:FindFirstChild("HumanoidRootPart")
                            if myHRP then
                                local success, err = pcall(function()
                                    myHRP.CFrame = hrp.CFrame + Vector3.new(0, 3, 0)
                                end)

                                if success then
                                    updateStatus("✅ Teleported to: " .. npcName, Color3.fromRGB(100, 255, 100))
                                    npcTeleportGui:Destroy()
                                else
                                    updateStatus("❌ Teleport failed: " .. tostring(err))
                                end
                            else
                                updateStatus("❌ HRP not found")
                            end
                        else
                            updateStatus("❌ NPC HRP not found")
                        end
                    else
                        updateStatus("❌ NPC not found")
                    end
                end)

                yPosition = yPosition + 35
                filteredCount = filteredCount + 1
            end
        end

        scrollFrame.CanvasSize = UDim2.new(0, 0, 0, filteredCount * 35)
    end

    -- Buat button NPC awal
    createNPCButtons("")

    -- Fungsi search
    searchBox:GetPropertyChangedSignal("Text"):Connect(function()
        createNPCButtons(searchBox.Text)
    end)

    closeNPCTeleportBtn.MouseButton1Click:Connect(function()
        npcTeleportGui:Destroy()
    end)

    -- Drag functionality untuk NPC teleport window
    local npcDragging, npcDragInput, npcDragStart, npcStartPos

    local function updateNPCDrag(input)
        local delta = input.Position - npcDragStart
        TweenService:Create(npcTeleportFrame, TweenInfo.new(0.12, Enum.EasingStyle.Quad), {
            Position = UDim2.new(npcStartPos.X.Scale, npcStartPos.X.Offset + delta.X, npcStartPos.Y.Scale, npcStartPos.Y.Offset + delta.Y)
        }):Play()
    end

    npcTeleportTitle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            npcDragging = true
            npcDragStart = input.Position
            npcStartPos = npcTeleportFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    npcDragging = false
                end
            end)
        end
    end)

    npcTeleportTitle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            npcDragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if npcDragging and input == npcDragInput then
            updateNPCDrag(input)
        end
    end)

    addHover(closeNPCTeleportBtn, Color3.fromRGB(220, 50, 50), Color3.fromRGB(240, 80, 80))
end

-- ===================================
-- ========== SIMPLE EVENT TELEPORT =========
-- ===================================

local eventsList = { "Shark Hunt", "Ghost Shark Hunt", "Worm Hunt", "Black Hole", "Shocked", "Ghost Worm", "Meteor Rain" }

local function findEventLocation(eventName)
    print("🔍 Mencari event:", eventName)
    
    -- Coba di berbagai lokasi yang mungkin
    local searchLocations = {
        workspace,
        workspace:FindFirstChild("Events"),
        workspace:FindFirstChild("Props"), 
        workspace:FindFirstChild("Map"),
        workspace:FindFirstChild("World"),
        workspace:FindFirstChild("Game"),
    }
    
    for _, location in pairs(searchLocations) do
        if location then
            print("📍 Cek di:", location.Name)
            local eventObj = location:FindFirstChild(eventName)
            if eventObj then
                print("✅ Ditemukan di:", location.Name)
                return eventObj
            end
            
            -- Coba cari dengan partial name
            for _, child in pairs(location:GetChildren()) do
                if string.find(string.lower(child.Name), string.lower(eventName)) then
                    print("✅ Ditemukan (partial match):", child.Name, "di", location.Name)
                    return child
                end
            end
        end
    end
    
    -- Coba cari di seluruh workspace
    for _, obj in pairs(workspace:GetDescendants()) do
        if string.lower(obj.Name) == string.lower(eventName) then
            print("✅ Ditemukan di:", obj:GetFullName())
            return obj
        end
    end
    
    print("❌ Tidak ditemukan di mana pun")
    return nil
end

local function createEventTeleportGUI()
    local eventTeleportGui = create("ScreenGui", {
        Name = "EventTeleportGUI",
        Parent = playerGui,
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    })

    -- Event Teleport Frame
    local eventTeleportFrame = create("Frame", {
        Name = "EventTeleportFrame",
        Parent = eventTeleportGui,
        Size = UDim2.new(0, 300, 0, 350),
        Position = UDim2.new(0.5, -150, 0.5, -175),
        BackgroundColor3 = Color3.fromRGB(15, 20, 30),
        BorderSizePixel = 0
    })

    create("UICorner", {Parent = eventTeleportFrame, CornerRadius = UDim.new(0, 10)})
    create("UIStroke", {Parent = eventTeleportFrame, Color = Color3.fromRGB(40, 80, 150), Thickness = 1.5})

    local eventTeleportTitle = create("TextLabel", {
        Parent = eventTeleportFrame,
        Size = UDim2.new(1, 0, 0, 35),
        BackgroundColor3 = Color3.fromRGB(25, 35, 55),
        Text = "🎯 Event Teleport",
        Font = Enum.Font.GothamBold,
        TextSize = 12,
        TextColor3 = Color3.fromRGB(100, 180, 255),
        TextYAlignment = Enum.TextYAlignment.Center
    })

    create("UICorner", {Parent = eventTeleportTitle, CornerRadius = UDim.new(0, 10)})

    local closeEventTeleportBtn = create("TextButton", {
        Parent = eventTeleportTitle,
        Size = UDim2.new(0, 22, 0, 22),
        Position = UDim2.new(1, -26, 0, 6),
        BackgroundColor3 = Color3.fromRGB(220, 50, 50),
        Text = "X",
        Font = Enum.Font.GothamBold,
        TextSize = 12,
        TextColor3 = Color3.fromRGB(255, 255, 255)
    })

    create("UICorner", {Parent = closeEventTeleportBtn, CornerRadius = UDim.new(0, 6)})

    local infoLabel = create("TextLabel", {
        Parent = eventTeleportFrame,
        Size = UDim2.new(1, -20, 0, 50),
        Position = UDim2.new(0, 10, 0, 45),
        BackgroundTransparency = 1,
        Text = "Teleport to active events\n⚡ Hanya work ketika event ACTIVE",
        Font = Enum.Font.Gotham,
        TextSize = 10,
        TextColor3 = Color3.fromRGB(100, 255, 200),
        TextXAlignment = Enum.TextXAlignment.Center,
        TextYAlignment = Enum.TextYAlignment.Center
    })

    local scrollFrame = create("ScrollingFrame", {
        Parent = eventTeleportFrame,
        Size = UDim2.new(1, -20, 1, -110),
        Position = UDim2.new(0, 10, 0, 105),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 5,
        ScrollBarImageColor3 = Color3.fromRGB(50, 100, 180),
        CanvasSize = UDim2.new(0, 0, 0, #eventsList * 40)
    })

    local yPosition = 0
    for _, eventName in ipairs(eventsList) do
        local eventBtn = create("TextButton", {
            Parent = scrollFrame,
            Size = UDim2.new(1, 0, 0, 35),
            Position = UDim2.new(0, 0, 0, yPosition),
            BackgroundColor3 = Color3.fromRGB(35, 45, 65),
            Text = "⚡ " .. eventName,
            Font = Enum.Font.Gotham,
            TextSize = 11,
            TextColor3 = Color3.fromRGB(220, 220, 220),
            TextYAlignment = Enum.TextYAlignment.Center
        })

        create("UICorner", {Parent = eventBtn, CornerRadius = UDim.new(0, 6)})
        create("UIStroke", {Parent = eventBtn, Color = Color3.fromRGB(60, 100, 160), Thickness = 1})

        -- Hover effect
        addHover(eventBtn, Color3.fromRGB(35, 45, 65), Color3.fromRGB(45, 55, 75))

        eventBtn.MouseButton1Click:Connect(function()
            updateStatus("🔍 Mencari: " .. eventName, Color3.fromRGB(255, 200, 100))
            
            task.wait(0.3)
            
            local eventObject = findEventLocation(eventName)
            
            if eventObject then
                local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local success, err = pcall(function()
                        -- Coba cari Fishing Boat dulu
                        local fishingBoat = eventObject:FindFirstChild("Fishing Boat")
                        if fishingBoat then
                            hrp.CFrame = fishingBoat:GetPivot() + Vector3.new(0, 15, 0)
                            updateStatus("✅ Teleport ke Fishing Boat " .. eventName, Color3.fromRGB(100, 255, 100))
                        else
                            -- Kalau ga ada fishing boat, teleport ke event object langsung
                            hrp.CFrame = eventObject:GetPivot() + Vector3.new(0, 10, 0)
                            updateStatus("✅ Teleport ke " .. eventName, Color3.fromRGB(100, 255, 100))
                        end
                        eventTeleportGui:Destroy()
                    end)

                    if not success then
                        updateStatus("❌ Gagal teleport: " .. tostring(err))
                    end
                else
                    updateStatus("❌ HRP tidak ditemukan")
                end
            else
                updateStatus("❌ " .. eventName .. " tidak ditemukan\nPastikan event sedang ACTIVE", Color3.fromRGB(255, 100, 100))
            end
        end)

        yPosition = yPosition + 40
    end

    closeEventTeleportBtn.MouseButton1Click:Connect(function()
        eventTeleportGui:Destroy()
    end)

    -- Drag functionality
    local eventDragging, eventDragInput, eventDragStart, eventStartPos

    local function updateEventDrag(input)
        if not eventDragging then return end
        local delta = input.Position - eventDragStart
        eventTeleportFrame.Position = UDim2.new(
            eventStartPos.X.Scale, 
            eventStartPos.X.Offset + delta.X, 
            eventStartPos.Y.Scale, 
            eventStartPos.Y.Offset + delta.Y
        )
    end

    eventTeleportTitle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            eventDragging = true
            eventDragStart = input.Position
            eventStartPos = eventTeleportFrame.Position
            
            local connection
            connection = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    eventDragging = false
                    connection:Disconnect()
                end
            end)
        end
    end)

    eventTeleportTitle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            eventDragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == eventDragInput and eventDragging then
            updateEventDrag(input)
        end
    end)

    addHover(closeEventTeleportBtn, Color3.fromRGB(220, 50, 50), Color3.fromRGB(240, 80, 80))
end

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

-- Fungsi utama Auto Fishing V1
local function autoFishingLoop()
	while autoFishingEnabled do
		local ok, err = pcall(function()

			updateDelayBasedOnRod()
			fishingActive = true
			updateStatus("🎣 Status: Fishing V1", Color3.fromRGB(100, 255, 100))
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
-- ========== FISHING V2 ===========
-- ===================================

local autoFishingV2Enabled = false
local fishingActiveV2 = false

-- Remote Events/Functions untuk V2
local rodRemoteV2 = net:WaitForChild("RF/ChargeFishingRod")
local miniGameRemoteV2 = net:WaitForChild("RF/RequestFishingMinigameStarted")
local finishRemoteV2 = net:WaitForChild("RE/FishingCompleted")
local equipRemoteV2 = net:WaitForChild("RE/EquipToolFromHotbar")

-- 🎯 Exclaim (Tanda Seru) Listener untuk V2 - INSTANT FINISH
task.spawn(function()
	local success, exclaimEvent = pcall(function()
		return net:WaitForChild("RE/ReplicateTextEffect", 5)
	end)

	if success and exclaimEvent then
		exclaimEvent.OnClientEvent:Connect(function(data)
			if autoFishingV2Enabled and data and data.TextData
				and data.TextData.EffectType == "Exclaim" then

				local head = player.Character and player.Character:FindFirstChild("Head")
				if head and data.Container == head then
					print("🎯 Tanda seru detected! Instant finish...")
					
					-- Langsung finish tanpa delay
					finishRemoteV2:FireServer()
					
					-- Auto recast cepat
					task.wait(0.2)  -- Delay kecil biar smooth
					local timestamp = workspace:GetServerTimeNow()
					rodRemoteV2:InvokeServer(timestamp)
					
					local baseX, baseY = -0.7499996, 1
					local x = baseX + (math.random(-500, 500) / 10000000)
					local y = baseY + (math.random(-500, 500) / 10000000)
					
					miniGameRemoteV2:InvokeServer(x, y)
				end
			end
		end)
		print("[✅] Exclaim detection active V2 (instant finish).")
	else
		warn("[⚠️] ReplicateTextEffect not found, skipping Exclaim logic V2.")
	end
end)

-- Fungsi utama Auto Fishing V2
local function autoFishingLoopV2()
	while autoFishingV2Enabled do
		local ok, err = pcall(function()
			fishingActiveV2 = true
			updateStatus("🎣 Status: Fishing V2 (FAST)", Color3.fromRGB(100, 255, 100))
			equipRemoteV2:FireServer(1)
			task.wait(0.1)

			local timestamp = workspace:GetServerTimeNow()
			rodRemoteV2:InvokeServer(timestamp)

			local baseX, baseY = -0.7499996, 1
			local x = baseX + (math.random(-500, 500) / 10000000)
			local y = baseY + (math.random(-500, 500) / 10000000)

			miniGameRemoteV2:InvokeServer(x, y)
			
			-- V2 menggunakan delay yang lebih pendek karena ada instant finish
			task.wait(1.5) -- Base delay, akan diinterrupt oleh exclaim listener
			
			-- Fallback jika exclaim tidak terdeteksi
			finishRemoteV2:FireServer(true)
			task.wait(0.3)
		end)
		if not ok then warn(err) end
		task.wait(0.2)
	end
	fishingActiveV2 = false
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
-- ========== BUTTON LOGIC ===========
-- ===================================

-- Fishing V2 Button
fishV2Btn.MouseButton1Click:Connect(function()
    autoFishingV2Enabled = not autoFishingV2Enabled
    
    if autoFishingV2Enabled then
        -- Stop V1 jika sedang berjalan
        if autoFishingEnabled then
            autoFishingEnabled = false
            fishBtn.Text = "START"
            fishBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
        end
        
        fishV2Btn.Text = "STOP"
        fishV2Btn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        updateStatus("⚡ Status: Auto Fishing V2 Started", Color3.fromRGB(100, 255, 100))
        task.spawn(autoFishingLoopV2)
    else
        fishV2Btn.Text = "START"
        fishV2Btn.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
        updateStatus("🔴 Status: Auto Fishing V2 Stopped")
        fishingActiveV2 = false
    end
end)

-- Fishing V1 Button
fishBtn.MouseButton1Click:Connect(function()
    autoFishingEnabled = not autoFishingEnabled
    
    if autoFishingEnabled then
        -- Stop V2 jika sedang berjalan
        if autoFishingV2Enabled then
            autoFishingV2Enabled = false
            fishV2Btn.Text = "START"
            fishV2Btn.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
        end
        
        fishBtn.Text = "STOP"
        fishBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        updateStatus("🟢 Status: Auto Fishing V1 Started", Color3.fromRGB(100, 255, 100))
        task.spawn(autoFishingLoop)
    else
        fishBtn.Text = "START"
        fishBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
        updateStatus("🔴 Status: Auto Fishing V1 Stopped")
        delayInitialized = false
        fishingActive = false
    end
end)

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

-- Teleport Button Logic
teleportBtn.MouseButton1Click:Connect(function()
    createTeleportGUI()
end)

-- Teleport to NPC Button Logic
teleportNPCBtn.MouseButton1Click:Connect(function()
    createNPCTeleportGUI()
end)

-- Teleport to Event Button Logic
teleportEventBtn.MouseButton1Click:Connect(function()
    createEventTeleportGUI()
end)

closeBtn.MouseButton1Click:Connect(function()
    autoFishingEnabled = false
    autoFishingV2Enabled = false
    autoSellEnabled = false
    fishingActive = false
    fishingActiveV2 = false
    screenGui:Destroy()
end)

-- Minimize functionality
local minimized = false
minimizeBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    TweenService:Create(mainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
        Size = minimized and UDim2.new(0, 300, 0, 33) or UDim2.new(0, 300, 0, 390)
    }):Play()
    minimizeBtn.Text = minimized and "+" or "—"
end)

print("=================================")
print("🐟 Fish It Auto Farm Loaded!")
print("📌 Features: Auto Fish V1 & V2, Auto Sell, Island TP, NPC TP, Event TP")
print("🎯 V2 Features: Instant Finish (Fast Fishing)")
print("=================================")
