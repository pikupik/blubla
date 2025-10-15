-------------------------------------------
----- =======[ GLOBAL FUNCTION ] =======
-------------------------------------------

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local net = ReplicatedStorage:WaitForChild("Packages")
	:WaitForChild("_Index")
	:WaitForChild("sleitnick_net@0.2.0")
	:WaitForChild("net")
	
local Notifs = {
	WBN = true,
	FavBlockNotif = true,
	FishBlockNotif = true,
	DelayBlockNotif = true,
	AFKBN = true,
	APIBN = true
}

-- State table for new features
local state = { 
    AutoFavourite = false, 
    AutoSell = false 
}

local rodRemote = net:WaitForChild("RF/ChargeFishingRod")
local miniGameRemote = net:WaitForChild("RF/RequestFishingMinigameStarted")
local finishRemote = net:WaitForChild("RE/FishingCompleted")

local Player = Players.LocalPlayer
local XPBar = Player:WaitForChild("PlayerGui"):WaitForChild("XP")

LocalPlayer.Idled:Connect(function()
    VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    task.wait(1)
    VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
end)

for i,v in next, getconnections(game:GetService("Players").LocalPlayer.Idled) do
    v:Disable()
end

task.spawn(function()
    if XPBar then
        XPBar.Enabled = true
    end
end)

local TeleportService = game:GetService("TeleportService")
local PlaceId = game.PlaceId

local function AutoReconnect()
    while task.wait(5) do
        if not Players.LocalPlayer or not Players.LocalPlayer:IsDescendantOf(game) then
            TeleportService:Teleport(PlaceId)
        end
    end
end

Players.LocalPlayer.OnTeleport:Connect(function(teleportState)
    if teleportState == Enum.TeleportState.Failed then
        TeleportService:Teleport(PlaceId)
    end
end)

task.spawn(AutoReconnect)

local RodIdle = ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Animations"):WaitForChild("FishingRodReelIdle")
local RodReel = ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Animations"):WaitForChild("EasyFishReelStart")
local RodShake = ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Animations"):WaitForChild("CastFromFullChargePosition1Hand")

local character = Players.LocalPlayer.Character or Players.LocalPlayer.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local animator = humanoid:FindFirstChildOfClass("Animator") or Instance.new("Animator", humanoid)

local RodShakeAnim = animator:LoadAnimation(RodShake)
local RodIdleAnim = animator:LoadAnimation(RodIdle)
local RodReelAnim = animator:LoadAnimation(RodReel)

local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

-------------------------------------------
----- =======[ AUTO BOOST FPS ] =======
-------------------------------------------
local function BoostFPS()
    for _, v in pairs(game:GetDescendants()) do
        if v:IsA("BasePart") then
            v.Material = Enum.Material.SmoothPlastic
            v.Reflectance = 0
        elseif v:IsA("Decal") or v:IsA("Texture") then
            v.Transparency = 1
        end
    end

    local Lighting = game:GetService("Lighting")
    for _, effect in pairs(Lighting:GetChildren()) do
        if effect:IsA("PostEffect") then
            effect.Enabled = false
        end
    end

    Lighting.GlobalShadows = false
    Lighting.FogEnd = 1e10

    settings().Rendering.QualityLevel = "Level01"
end

BoostFPS() -- Activate FPS Boost on script execution

-------------------------------------------
----- =======[ CUSTOM UI CREATION ] =======
-------------------------------------------

local playerGui = Player:WaitForChild("PlayerGui")

-- Hapus GUI lama
if playerGui:FindFirstChild("ZiaanHubGUI") then
    playerGui:FindFirstChild("ZiaanHubGUI"):Destroy()
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
    Name = "ZiaanHubGUI",
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
    Text = "🐟 ZiaanHub - Fish It",
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

-- Tab Buttons
local tabButtonsFrame = create("Frame", {
    Parent = mainFrame,
    Size = UDim2.new(1, -30, 0, 40),
    Position = UDim2.new(0, 15, 0, 60),
    BackgroundTransparency = 1,
})

local autoFishTabBtn = create("TextButton", {
    Parent = tabButtonsFrame,
    Size = UDim2.new(0.33, -5, 1, 0),
    Position = UDim2.new(0, 0, 0, 0),
    BackgroundColor3 = Color3.fromRGB(40, 60, 90),
    Text = "🎣 Auto Fish",
    Font = Enum.Font.GothamBold,
    TextSize = 14,
    TextColor3 = Color3.fromRGB(255, 255, 255)
})

create("UICorner", {Parent = autoFishTabBtn, CornerRadius = UDim.new(0, 8)})

local utilityTabBtn = create("TextButton", {
    Parent = tabButtonsFrame,
    Size = UDim2.new(0.33, -5, 1, 0),
    Position = UDim2.new(0.33, 0, 0, 0),
    BackgroundColor3 = Color3.fromRGB(40, 60, 90),
    Text = "⚙️ Utility",
    Font = Enum.Font.GothamBold,
    TextSize = 14,
    TextColor3 = Color3.fromRGB(255, 255, 255)
})

create("UICorner", {Parent = utilityTabBtn, CornerRadius = UDim.new(0, 8)})

local settingsTabBtn = create("TextButton", {
    Parent = tabButtonsFrame,
    Size = UDim2.new(0.33, -5, 1, 0),
    Position = UDim2.new(0.66, 0, 0, 0),
    BackgroundColor3 = Color3.fromRGB(40, 60, 90),
    Text = "🔧 Settings",
    Font = Enum.Font.GothamBold,
    TextSize = 14,
    TextColor3 = Color3.fromRGB(255, 255, 255)
})

create("UICorner", {Parent = settingsTabBtn, CornerRadius = UDim.new(0, 8)})

-- Content Frame
local contentFrame = create("ScrollingFrame", {
    Name = "Content",
    Parent = mainFrame,
    Size = UDim2.new(1, -30, 1, -120),
    Position = UDim2.new(0, 15, 0, 110),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    ScrollBarThickness = 8,
    ScrollBarImageColor3 = Color3.fromRGB(50, 100, 180),
    CanvasSize = UDim2.new(0, 0, 0, 1200)
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

-- ========== NOTIFY FUNCTION ==========
local function NotifySuccess(message, duration)
    statusLabel.Text = "✅ " .. message
    statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
    if duration then
        task.wait(duration)
        statusLabel.Text = "🔴 Status: Idle"
        statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
    end
end

local function NotifyError(message, duration)
    statusLabel.Text = "❌ " .. message
    statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
    if duration then
        task.wait(duration)
        statusLabel.Text = "🔴 Status: Idle"
        statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
    end
end

local function NotifyInfo(message, duration)
    statusLabel.Text = "ℹ️ " .. message
    statusLabel.TextColor3 = Color3.fromRGB(100, 200, 255)
    if duration then
        task.wait(duration)
        statusLabel.Text = "🔴 Status: Idle"
        statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
    end
end

local function NotifyWarning(message, duration)
    statusLabel.Text = "⚠️ " .. message
    statusLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
    if duration then
        task.wait(duration)
        statusLabel.Text = "🔴 Status: Idle"
        statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
    end
end

-------------------------------------------
----- =======[ AUTO FISHING SYSTEM ] =======
-------------------------------------------

local FuncAutoFishV2 = {
	REReplicateTextEffectV2 = ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net["RE/ReplicateTextEffect"],
	autofishV2 = false,
	perfectCastV2 = true,
	fishingActiveV2 = false,
	delayInitializedV2 = false
}

local RodDelaysV2 = {
    ["Ares Rod"] = {custom = 1.12, bypass = 1.45},
    ["Angler Rod"] = {custom = 1.12, bypass = 1.45},
    ["Ghostfinn Rod"] = {custom = 1.12, bypass = 1.45},
    ["Astral Rod"] = {custom = 1.9, bypass = 1.45},
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

local customDelayV2 = 1
local BypassDelayV2 = 0.5

local function getValidRodNameV2()
    local player = Players.LocalPlayer
    local display = player.PlayerGui:WaitForChild("Backpack"):WaitForChild("Display")
    for _, tile in ipairs(display:GetChildren()) do
        local success, itemNamePath = pcall(function()
            return tile.Inner.Tags.ItemName
        end)
        if success and itemNamePath and itemNamePath:IsA("TextLabel") then
            local name = itemNamePath.Text
            if RodDelaysV2[name] then
                return name
            end
        end
    end
    return nil
end

local function updateDelayBasedOnRodV2(showNotify)
    if FuncAutoFishV2.delayInitializedV2 then return end
    local rodName = getValidRodNameV2()
    if rodName and RodDelaysV2[rodName] then
        customDelayV2 = RodDelaysV2[rodName].custom
        BypassDelayV2 = RodDelaysV2[rodName].bypass
        FuncAutoFishV2.delayInitializedV2 = true
        if showNotify and FuncAutoFishV2.autofishV2 then
            NotifySuccess("Rod Detected: " .. rodName)
        end
    else
        customDelayV2 = 10
        BypassDelayV2 = 1
        FuncAutoFishV2.delayInitializedV2 = true
        if showNotify and FuncAutoFishV2.autofishV2 then
            NotifyWarning("Rod Detection Failed - Default delay applied")
        end
    end
end

local function setupRodWatcher()
    local player = Players.LocalPlayer
    local display = player.PlayerGui:WaitForChild("Backpack"):WaitForChild("Display")
    display.ChildAdded:Connect(function()
        task.wait(0.05)
        if not FuncAutoFishV2.delayInitializedV2 then
            updateDelayBasedOnRodV2(true)
        end
    end)
end
setupRodWatcher()

-- NEW AUTO SELL
local lastSellTime = 0
local AUTO_SELL_THRESHOLD = 60 -- Sell when non-favorited fish > 60
local AUTO_SELL_DELAY = 60 -- Minimum seconds between sells

local function getNetFolder() return net end

local function startAutoSell()
    task.spawn(function()
        while state.AutoSell do
            pcall(function()
                if not Replion then return end
                local DataReplion = Replion.Client:WaitReplion("Data")
                local items = DataReplion and DataReplion:Get({"Inventory","Items"})
                if type(items) ~= "table" then return end

                -- Count non-favorited fish
                local unfavoritedCount = 0
                for _, item in ipairs(items) do
                    if not item.Favorited then
                        unfavoritedCount = unfavoritedCount + (item.Count or 1)
                    end
                end

                -- Only sell if above threshold and delay passed
                if unfavoritedCount >= AUTO_SELL_THRESHOLD and os.time() - lastSellTime >= AUTO_SELL_DELAY then
                    local netFolder = getNetFolder()
                    if netFolder then
                        local sellFunc = netFolder:FindFirstChild("RF/SellAllItems")
                        if sellFunc then
                            task.spawn(sellFunc.InvokeServer, sellFunc)
							NotifyInfo("Auto Sell: Selling non-favorited items...")
                            lastSellTime = os.time()
                        end
                    end
                end
            end)
            task.wait(10) -- check every 10 seconds
        end
    end)
end

FuncAutoFishV2.REReplicateTextEffectV2.OnClientEvent:Connect(function(data)
    if FuncAutoFishV2.autofishV2 and FuncAutoFishV2.fishingActiveV2
    and data
    and data.TextData
    and data.TextData.EffectType == "Exclaim" then

        local myHead = Players.LocalPlayer.Character and Players.LocalPlayer.Character:FindFirstChild("Head")
        if myHead and data.Container == myHead then
            task.spawn(function()
                for i = 1, 3 do
                    task.wait(BypassDelayV2)
                    finishRemote:FireServer()
                end
            end)
        end
    end
end)

function StartAutoFishV2()
    if FuncAutoFishV2.autofishV2 then return end
    
    FuncAutoFishV2.autofishV2 = true
    updateDelayBasedOnRodV2(true)
    task.spawn(function()
        while FuncAutoFishV2.autofishV2 do
            pcall(function()
                FuncAutoFishV2.fishingActiveV2 = true

                local equipRemote = net:WaitForChild("RE/EquipToolFromHotbar")
                equipRemote:FireServer(1)
                task.wait(0.1)

                local chargeRemote = ReplicatedStorage
                    .Packages._Index["sleitnick_net@0.2.0"].net["RF/ChargeFishingRod"]
                chargeRemote:InvokeServer(workspace:GetServerTimeNow())
                task.wait(0.5)

                local timestamp = workspace:GetServerTimeNow()
                RodShakeAnim:Play()
                rodRemote:InvokeServer(timestamp)

                local baseX, baseY = -0.7499996423721313, 1
                local x, y
                if FuncAutoFishV2.perfectCastV2 then
                    x = baseX + (math.random(-500, 500) / 10000000)
                    y = baseY + (math.random(-500, 500) / 10000000)
                else
                    x = math.random(-1000, 1000) / 1000
                    y = math.random(0, 1000) / 1000
                end

                RodIdleAnim:Play()
                miniGameRemote:InvokeServer(x, y)

                task.wait(customDelayV2)
                FuncAutoFishV2.fishingActiveV2 = false
            end)
        end
    end)
end

function StopAutoFishV2()
    FuncAutoFishV2.autofishV2 = false
    FuncAutoFishV2.fishingActiveV2 = false
    FuncAutoFishV2.delayInitializedV2 = false
    RodIdleAnim:Stop()
    RodShakeAnim:Stop()
    RodReelAnim:Stop()
end

-------------------------------------------
----- =======[ UI ELEMENTS CREATION ] =======
-------------------------------------------

-- Auto Fishing Section
local autoFishSection = create("Frame", {
    Parent = contentFrame,
    Size = UDim2.new(1, 0, 0, 200),
    Position = UDim2.new(0, 0, 0, 105),
    BackgroundColor3 = Color3.fromRGB(25, 35, 50),
})

create("UICorner", {Parent = autoFishSection, CornerRadius = UDim.new(0, 12)})
create("UIStroke", {Parent = autoFishSection, Color = Color3.fromRGB(40, 60, 90), Thickness = 1.5})

local autoFishTitle = create("TextLabel", {
    Parent = autoFishSection,
    Size = UDim2.new(1, -20, 0, 30),
    Position = UDim2.new(0, 10, 0, 10),
    BackgroundTransparency = 1,
    Text = "🎣 Auto Fishing System",
    Font = Enum.Font.GothamBold,
    TextSize = 16,
    TextColor3 = Color3.fromRGB(220, 220, 220),
    TextXAlignment = Enum.TextXAlignment.Left
})

-- Auto Fish Toggle
local autoFishBtn = create("TextButton", {
    Parent = autoFishSection,
    Size = UDim2.new(1, -20, 0, 40),
    Position = UDim2.new(0, 10, 0, 50),
    BackgroundColor3 = Color3.fromRGB(50, 150, 50),
    Text = "START AUTO FISH",
    Font = Enum.Font.GothamBold,
    TextSize = 14,
    TextColor3 = Color3.fromRGB(255, 255, 255)
})

create("UICorner", {Parent = autoFishBtn, CornerRadius = UDim.new(0, 8)})

-- Perfect Cast Toggle
local perfectCastBtn = create("TextButton", {
    Parent = autoFishSection,
    Size = UDim2.new(1, -20, 0, 40),
    Position = UDim2.new(0, 10, 0, 100),
    BackgroundColor3 = Color3.fromRGB(70, 80, 100),
    Text = "PERFECT CAST: ON",
    Font = Enum.Font.GothamBold,
    TextSize = 14,
    TextColor3 = Color3.fromRGB(255, 255, 255)
})

create("UICorner", {Parent = perfectCastBtn, CornerRadius = UDim.new(0, 8)})

-- Auto Sell Section
local autoSellSection = create("Frame", {
    Parent = contentFrame,
    Size = UDim2.new(1, 0, 0, 120),
    Position = UDim2.new(0, 0, 0, 320),
    BackgroundColor3 = Color3.fromRGB(25, 35, 50),
})

create("UICorner", {Parent = autoSellSection, CornerRadius = UDim.new(0, 12)})
create("UIStroke", {Parent = autoSellSection, Color = Color3.fromRGB(40, 60, 90), Thickness = 1.5})

local autoSellTitle = create("TextLabel", {
    Parent = autoSellSection,
    Size = UDim2.new(1, -20, 0, 30),
    Position = UDim2.new(0, 10, 0, 10),
    BackgroundTransparency = 1,
    Text = "💰 Auto Sell System",
    Font = Enum.Font.GothamBold,
    TextSize = 16,
    TextColor3 = Color3.fromRGB(220, 220, 220),
    TextXAlignment = Enum.TextXAlignment.Left
})

local autoSellBtn = create("TextButton", {
    Parent = autoSellSection,
    Size = UDim2.new(1, -20, 0, 40),
    Position = UDim2.new(0, 10, 0, 50),
    BackgroundColor3 = Color3.fromRGB(50, 150, 50),
    Text = "START AUTO SELL",
    Font = Enum.Font.GothamBold,
    TextSize = 14,
    TextColor3 = Color3.fromRGB(255, 255, 255)
})

create("UICorner", {Parent = autoSellBtn, CornerRadius = UDim.new(0, 8)})

-- Manual Actions Section
local manualSection = create("Frame", {
    Parent = contentFrame,
    Size = UDim2.new(1, 0, 0, 120),
    Position = UDim2.new(0, 0, 0, 460),
    BackgroundColor3 = Color3.fromRGB(25, 35, 50),
})

create("UICorner", {Parent = manualSection, CornerRadius = UDim.new(0, 12)})
create("UIStroke", {Parent = manualSection, Color = Color3.fromRGB(40, 60, 90), Thickness = 1.5})

local manualTitle = create("TextLabel", {
    Parent = manualSection,
    Size = UDim2.new(1, -20, 0, 30),
    Position = UDim2.new(0, 10, 0, 10),
    BackgroundTransparency = 1,
    Text = "🛠️ Manual Actions",
    Font = Enum.Font.GothamBold,
    TextSize = 16,
    TextColor3 = Color3.fromRGB(220, 220, 220),
    TextXAlignment = Enum.TextXAlignment.Left
})

local sellAllBtn = create("TextButton", {
    Parent = manualSection,
    Size = UDim2.new(1, -20, 0, 40),
    Position = UDim2.new(0, 10, 0, 50),
    BackgroundColor3 = Color3.fromRGB(180, 120, 50),
    Text = "SELL ALL FISH",
    Font = Enum.Font.GothamBold,
    TextSize = 14,
    TextColor3 = Color3.fromRGB(255, 255, 255)
})

create("UICorner", {Parent = sellAllBtn, CornerRadius = UDim.new(0, 8)})

-- Utility Section
local utilitySection = create("Frame", {
    Parent = contentFrame,
    Size = UDim2.new(1, 0, 0, 150),
    Position = UDim2.new(0, 0, 0, 600),
    BackgroundColor3 = Color3.fromRGB(25, 35, 50),
})

create("UICorner", {Parent = utilitySection, CornerRadius = UDim.new(0, 12)})
create("UIStroke", {Parent = utilitySection, Color = Color3.fromRGB(40, 60, 90), Thickness = 1.5})

local utilityTitle = create("TextLabel", {
    Parent = utilitySection,
    Size = UDim2.new(1, -20, 0, 30),
    Position = UDim2.new(0, 10, 0, 10),
    BackgroundTransparency = 1,
    Text = "⚡ Utility Actions",
    Font = Enum.Font.GothamBold,
    TextSize = 16,
    TextColor3 = Color3.fromRGB(220, 220, 220),
    TextXAlignment = Enum.TextXAlignment.Left
})

local rejoinBtn = create("TextButton", {
    Parent = utilitySection,
    Size = UDim2.new(0.48, -5, 0, 40),
    Position = UDim2.new(0, 10, 0, 50),
    BackgroundColor3 = Color3.fromRGB(70, 80, 100),
    Text = "REJOIN SERVER",
    Font = Enum.Font.GothamBold,
    TextSize = 12,
    TextColor3 = Color3.fromRGB(255, 255, 255)
})

create("UICorner", {Parent = rejoinBtn, CornerRadius = UDim.new(0, 8)})

local serverHopBtn = create("TextButton", {
    Parent = utilitySection,
    Size = UDim2.new(0.48, -5, 0, 40),
    Position = UDim2.new(0.52, 0, 0, 50),
    BackgroundColor3 = Color3.fromRGB(70, 80, 100),
    Text = "SERVER HOP",
    Font = Enum.Font.GothamBold,
    TextSize = 12,
    TextColor3 = Color3.fromRGB(255, 255, 255)
})

create("UICorner", {Parent = serverHopBtn, CornerRadius = UDim.new(0, 8)})

-- Info Box
local infoBox = create("Frame", {
    Parent = contentFrame,
    Size = UDim2.new(1, 0, 0, 80),
    Position = UDim2.new(0, 0, 0, 770),
    BackgroundColor3 = Color3.fromRGB(35, 60, 100),
})

create("UICorner", {Parent = infoBox, CornerRadius = UDim.new(0, 12)})

local infoText = create("TextLabel", {
    Parent = infoBox,
    Size = UDim2.new(1, -20, 1, -20),
    Position = UDim2.new(0, 10, 0, 10),
    BackgroundTransparency = 1,
    Text = "ℹ️ ZiaanHub v1.6.45\nby @ziaandev - Advanced fishing automation",
    Font = Enum.Font.Gotham,
    TextSize = 12,
    TextColor3 = Color3.fromRGB(180, 200, 230),
    TextWrapped = true,
    TextXAlignment = Enum.TextXAlignment.Left,
    TextYAlignment = Enum.TextYAlignment.Top
})

-------------------------------------------
----- =======[ BUTTON FUNCTIONALITY ] =======
-------------------------------------------

-- Auto Fish Button
autoFishBtn.MouseButton1Click:Connect(function()
    if FuncAutoFishV2.autofishV2 then
        StopAutoFishV2()
        autoFishBtn.Text = "START AUTO FISH"
        autoFishBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
        NotifyInfo("Auto Fishing Stopped")
    else
        StartAutoFishV2()
        autoFishBtn.Text = "STOP AUTO FISH"
        autoFishBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        NotifySuccess("Auto Fishing Started")
    end
end)

-- Perfect Cast Button
perfectCastBtn.MouseButton1Click:Connect(function()
    FuncAutoFishV2.perfectCastV2 = not FuncAutoFishV2.perfectCastV2
    if FuncAutoFishV2.perfectCastV2 then
        perfectCastBtn.Text = "PERFECT CAST: ON"
        perfectCastBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
        NotifySuccess("Perfect Cast Enabled")
    else
        perfectCastBtn.Text = "PERFECT CAST: OFF"
        perfectCastBtn.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
        NotifyWarning("Perfect Cast Disabled")
    end
end)

-- Auto Sell Button
autoSellBtn.MouseButton1Click:Connect(function()
    state.AutoSell = not state.AutoSell
    if state.AutoSell then
        autoSellBtn.Text = "STOP AUTO SELL"
        autoSellBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        startAutoSell()
        NotifySuccess("Auto Sell Enabled")
    else
        autoSellBtn.Text = "START AUTO SELL"
        autoSellBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
        NotifyWarning("Auto Sell Disabled")
    end
end)

-- Sell All Button
function sellAllFishes()
	local charFolder = workspace:FindFirstChild("Characters")
	local char = charFolder and charFolder:FindFirstChild(LocalPlayer.Name)
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	if not hrp then
		NotifyError("Character Not Found")
		return
	end

	local sellRemote = net:WaitForChild("RF/SellAllItems")

	task.spawn(function()
		NotifyInfo("Selling all fish...")

		task.wait(1)
		local success, err = pcall(function()
			sellRemote:InvokeServer()
		end)

		if success then
			NotifySuccess("All fish sold successfully!")
		else
			NotifyError("Sell Failed: " .. tostring(err))
		end
	end)
end

sellAllBtn.MouseButton1Click:Connect(function()
    sellAllFishes()
end)

-- Rejoin Button
local function Rejoin()
	local player = Players.LocalPlayer
	if player then
		TeleportService:Teleport(game.PlaceId, player)
	end
end

rejoinBtn.MouseButton1Click:Connect(function()
    Rejoin()
end)

-- Server Hop Button
local function ServerHop()
	local placeId = game.PlaceId
	local servers = {}
	local cursor = ""
	local found = false

	repeat
		local url = "https://games.roblox.com/v1/games/"..placeId.."/servers/Public?sortOrder=Asc&limit=100"
		if cursor ~= "" then
			url = url .. "&cursor=" .. cursor
		end

		local success, result = pcall(function()
			return HttpService:JSONDecode(game:HttpGet(url))
		end)

		if success and result and result.data then
			for _, server in pairs(result.data) do
				if server.playing < server.maxPlayers and server.id ~= game.JobId then
					table.insert(servers, server.id)
				end
			end
			cursor = result.nextPageCursor or ""
		else
			break
		end
	until not cursor or #servers > 0

	if #servers > 0 then
		local targetServer = servers[math.random(1, #servers)]
		TeleportService:TeleportToPlaceInstance(placeId, targetServer, LocalPlayer)
	else
		NotifyError("Server Hop Failed - No servers available")
	end
end

serverHopBtn.MouseButton1Click:Connect(function()
    ServerHop()
end)

-- Close Button
closeBtn.MouseButton1Click:Connect(function()
    FuncAutoFishV2.autofishV2 = false
    state.AutoSell = false
    StopAutoFishV2()
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
addHover(autoFishBtn, Color3.fromRGB(50, 150, 50), Color3.fromRGB(70, 170, 70))
addHover(perfectCastBtn, Color3.fromRGB(70, 80, 100), Color3.fromRGB(90, 100, 120))
addHover(autoSellBtn, Color3.fromRGB(50, 150, 50), Color3.fromRGB(70, 170, 70))
addHover(sellAllBtn, Color3.fromRGB(180, 120, 50), Color3.fromRGB(200, 140, 70))
addHover(rejoinBtn, Color3.fromRGB(70, 80, 100), Color3.fromRGB(90, 100, 120))
addHover(serverHopBtn, Color3.fromRGB(70, 80, 100), Color3.fromRGB(90, 100, 120))

-- Tab functionality (simplified)
local currentTab = "autofish"

local function showTab(tabName)
    currentTab = tabName
    -- For now, we show all sections since it's a simplified UI
    -- In a more complex implementation, you would hide/show different sections
end

autoFishTabBtn.MouseButton1Click:Connect(function()
    showTab("autofish")
    autoFishTabBtn.BackgroundColor3 = Color3.fromRGB(60, 100, 150)
    utilityTabBtn.BackgroundColor3 = Color3.fromRGB(40, 60, 90)
    settingsTabBtn.BackgroundColor3 = Color3.fromRGB(40, 60, 90)
end)

utilityTabBtn.MouseButton1Click:Connect(function()
    showTab("utility")
    autoFishTabBtn.BackgroundColor3 = Color3.fromRGB(40, 60, 90)
    utilityTabBtn.BackgroundColor3 = Color3.fromRGB(60, 100, 150)
    settingsTabBtn.BackgroundColor3 = Color3.fromRGB(40, 60, 90)
end)

settingsTabBtn.MouseButton1Click:Connect(function()
    showTab("settings")
    autoFishTabBtn.BackgroundColor3 = Color3.fromRGB(40, 60, 90)
    utilityTabBtn.BackgroundColor3 = Color3.fromRGB(40, 60, 90)
    settingsTabBtn.BackgroundColor3 = Color3.fromRGB(60, 100, 150)
end)

-- Initial notification
NotifySuccess("ZiaanHub v1.6.45 Loaded Successfully!", 3)

print("=================================")
print("🐟 ZiaanHub - Fish It Loaded!")
print("=================================")
print("✅ Advanced fishing automation")
print("✅ Custom UI with all features")
print("✅ Auto Sell & Favorite systems")
print("✅ Utility functions included")
print("=================================")
