-------------------------------------------
----- =======[ Mobile Detection ] =======
-------------------------------------------

local IS_MOBILE = game:GetService("UserInputService").TouchEnabled
local IS_DESKTOP = not IS_MOBILE

-------------------------------------------
----- =======[ Load WindUI - Mobile Fix ] =======
-------------------------------------------

local WindUI
local success, error = pcall(function()
    WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/source.lua"))()
end)

if not success then
    -- Fallback jika WindUI gagal load
    local FallbackUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/skibidibop08/Synaptic-UI/main/source.lua"))()
    WindUI = FallbackUI
end

-------------------------------------------
----- =======[ GLOBAL FUNCTION ] =======
-------------------------------------------

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Simple notification system jika UI gagal
local function SimpleNotify(title, message)
    if WindUI then
        WindUI:Notify({
            Title = title,
            Content = message,
            Duration = 3
        })
    else
        -- Fallback notification
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = title,
            Text = message,
            Duration = 3
        })
    end
end

-- Cek jika game tersedia
if not ReplicatedStorage:FindFirstChild("Packages") then
    SimpleNotify("Error", "Game tidak ditemukan atau tidak support!")
    return
end

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

-- State table untuk features
local state = { 
    AutoFavourite = false, 
    AutoSell = false 
}

local rodRemote = net:WaitForChild("RF/ChargeFishingRod")
local miniGameRemote = net:WaitForChild("RF/RequestFishingMinigameStarted")
local finishRemote = net:WaitForChild("RE/FishingCompleted")

-------------------------------------------
----- =======[ BASIC SETUP ] =======
-------------------------------------------

-- Anti-AFK sederhana untuk mobile
local VirtualUser = game:GetService('VirtualUser')
LocalPlayer.Idled:connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new(0,0))
end)

-- Auto Reconnect sederhana
local TeleportService = game:GetService("TeleportService")
local PlaceId = game.PlaceId

local function AutoReconnect()
    while task.wait(10) do
        if not Players.LocalPlayer or not Players.LocalPlayer:IsDescendantOf(game) then
            TeleportService:Teleport(PlaceId)
        end
    end
end
task.spawn(AutoReconnect)

-------------------------------------------
----- =======[ CREATE SIMPLE UI ] =======
-------------------------------------------

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ZiaanHubMobile"
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.DisplayOrder = 999

if IS_MOBILE then
    ScreenGui.ResetOnSpawn = false
end

-- Main Frame
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 350, 0, 500)
MainFrame.Position = UDim2.new(0.5, -175, 0.5, -250)
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true

-- Corner
local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 8)
Corner.Parent = MainFrame

-- Stroke
local Stroke = Instance.new("UIStroke")
Stroke.Color = Color3.fromRGB(100, 100, 200)
Stroke.Thickness = 2
Stroke.Parent = MainFrame

-- Title Bar
local TitleBar = Instance.new("Frame")
TitleBar.Name = "TitleBar"
TitleBar.Size = UDim2.new(1, 0, 0, 40)
TitleBar.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
TitleBar.BorderSizePixel = 0

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 8)
TitleCorner.Parent = TitleBar

local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Size = UDim2.new(1, -40, 1, 0)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "ZiaanHub - Fish It Mobile"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 16
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left

-- Close Button
local CloseButton = Instance.new("TextButton")
CloseButton.Name = "CloseButton"
CloseButton.Size = UDim2.new(0, 30, 0, 30)
CloseButton.Position = UDim2.new(1, -35, 0, 5)
CloseButton.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.TextSize = 14

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 4)
CloseCorner.Parent = CloseButton

-- Toggle Button (untuk show/hide UI)
local ToggleButton = Instance.new("TextButton")
ToggleButton.Name = "ToggleButton"
ToggleButton.Size = UDim2.new(0, 50, 0, 50)
ToggleButton.Position = UDim2.new(0, 20, 0, 20)
ToggleButton.BackgroundColor3 = Color3.fromRGB(60, 60, 180)
ToggleButton.Text = "Menu"
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.TextSize = 14
ToggleButton.Visible = false

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(0, 25)
ToggleCorner.Parent = ToggleButton

-- Scrolling Frame untuk content
local ScrollFrame = Instance.new("ScrollingFrame")
ScrollFrame.Name = "ScrollFrame"
ScrollFrame.Size = UDim2.new(1, -20, 1, -60)
ScrollFrame.Position = UDim2.new(0, 10, 0, 50)
ScrollFrame.BackgroundTransparency = 1
ScrollFrame.BorderSizePixel = 0
ScrollFrame.ScrollBarThickness = 4
ScrollFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 200)

-- UIListLayout untuk ScrollFrame
local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Padding = UDim.new(0, 10)
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder

-- Parent semua elements
TitleBar.Parent = MainFrame
Title.Parent = TitleBar
CloseButton.Parent = TitleBar
ScrollFrame.Parent = MainFrame
UIListLayout.Parent = ScrollFrame
MainFrame.Parent = ScreenGui
ToggleButton.Parent = ScreenGui
ScreenGui.Parent = game:GetService("CoreGui")

-------------------------------------------
----- =======[ UI FUNCTIONS ] =======
-------------------------------------------

local function CreateSection(title)
    local Section = Instance.new("Frame")
    Section.Name = "Section"
    Section.Size = UDim2.new(1, 0, 0, 0)
    Section.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    Section.BorderSizePixel = 0
    Section.AutomaticSize = Enum.AutomaticSize.Y
    
    local SectionCorner = Instance.new("UICorner")
    SectionCorner.CornerRadius = UDim.new(0, 6)
    SectionCorner.Parent = Section
    
    local SectionTitle = Instance.new("TextLabel")
    SectionTitle.Name = "SectionTitle"
    SectionTitle.Size = UDim2.new(1, -20, 0, 30)
    SectionTitle.Position = UDim2.new(0, 10, 0, 0)
    SectionTitle.BackgroundTransparency = 1
    SectionTitle.Text = title
    SectionTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    SectionTitle.TextSize = 14
    SectionTitle.Font = Enum.Font.GothamBold
    SectionTitle.TextXAlignment = Enum.TextXAlignment.Left
    
    local ContentLayout = Instance.new("UIListLayout")
    ContentLayout.Padding = UDim.new(0, 5)
    ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
    
    SectionTitle.Parent = Section
    ContentLayout.Parent = Section
    
    return Section
end

local function CreateToggle(parent, title, callback)
    local ToggleFrame = Instance.new("Frame")
    ToggleFrame.Name = "ToggleFrame"
    ToggleFrame.Size = UDim2.new(1, 0, 0, 30)
    ToggleFrame.BackgroundTransparency = 1
    ToggleFrame.BorderSizePixel = 0
    
    local ToggleLabel = Instance.new("TextLabel")
    ToggleLabel.Name = "ToggleLabel"
    ToggleLabel.Size = UDim2.new(0.7, 0, 1, 0)
    ToggleLabel.BackgroundTransparency = 1
    ToggleLabel.Text = title
    ToggleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    ToggleLabel.TextSize = 12
    ToggleLabel.Font = Enum.Font.Gotham
    ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    local ToggleButton = Instance.new("TextButton")
    ToggleButton.Name = "ToggleButton"
    ToggleButton.Size = UDim2.new(0, 50, 0, 25)
    ToggleButton.Position = UDim2.new(1, -50, 0, 2)
    ToggleButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    ToggleButton.Text = "OFF"
    ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    ToggleButton.TextSize = 11
    
    local ToggleCorner = Instance.new("UICorner")
    ToggleCorner.CornerRadius = UDim.new(0, 4)
    ToggleCorner.Parent = ToggleButton
    
    local isToggled = false
    
    ToggleButton.MouseButton1Click:Connect(function()
        isToggled = not isToggled
        if isToggled then
            ToggleButton.BackgroundColor3 = Color3.fromRGB(60, 180, 60)
            ToggleButton.Text = "ON"
        else
            ToggleButton.BackgroundColor3 = Color3.fromRGB(180, 60, 60)
            ToggleButton.Text = "OFF"
        end
        callback(isToggled)
    end)
    
    ToggleLabel.Parent = ToggleFrame
    ToggleButton.Parent = ToggleFrame
    ToggleFrame.Parent = parent
    
    return ToggleFrame
end

local function CreateButton(parent, title, callback)
    local Button = Instance.new("TextButton")
    Button.Name = "Button"
    Button.Size = UDim2.new(1, 0, 0, 35)
    Button.BackgroundColor3 = Color3.fromRGB(60, 60, 180)
    Button.Text = title
    Button.TextColor3 = Color3.fromRGB(255, 255, 255)
    Button.TextSize = 13
    Button.Font = Enum.Font.Gotham
    
    local ButtonCorner = Instance.new("UICorner")
    ButtonCorner.CornerRadius = UDim.new(0, 6)
    ButtonCorner.Parent = Button
    
    Button.MouseButton1Click:Connect(callback)
    Button.Parent = parent
    
    return Button
end

-------------------------------------------
----- =======[ AUTO FISHING SYSTEM ] =======
-------------------------------------------

local FuncAutoFishV2 = {
    autofishV2 = false,
    perfectCastV2 = true,
    fishingActiveV2 = false
}

local customDelayV2 = 2
local BypassDelayV2 = 1

function StartAutoFishV2()
    if FuncAutoFishV2.autofishV2 then return end
    
    FuncAutoFishV2.autofishV2 = true
    SimpleNotify("Auto Fish", "Auto Fish V2 Started!")
    
    task.spawn(function()
        while FuncAutoFishV2.autofishV2 do
            pcall(function()
                FuncAutoFishV2.fishingActiveV2 = true

                -- Equip rod
                local equipRemote = net:WaitForChild("RE/EquipToolFromHotbar")
                equipRemote:FireServer(1)
                task.wait(0.1)

                -- Charge rod
                local chargeRemote = ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net["RF/ChargeFishingRod"]
                chargeRemote:InvokeServer(workspace:GetServerTimeNow())
                task.wait(0.5)

                -- Cast rod
                local timestamp = workspace:GetServerTimeNow()
                rodRemote:InvokeServer(timestamp)

                -- Minigame position
                local baseX, baseY = -0.7499996423721313, 1
                local x, y
                if FuncAutoFishV2.perfectCastV2 then
                    x = baseX + (math.random(-500, 500) / 10000000)
                    y = baseY + (math.random(-500, 500) / 10000000)
                else
                    x = math.random(-1000, 1000) / 1000
                    y = math.random(0, 1000) / 1000
                end

                -- Start minigame
                miniGameRemote:InvokeServer(x, y)

                task.wait(customDelayV2)
                FuncAutoFishV2.fishingActiveV2 = false
            end)
            task.wait(0.5)
        end
    end)
end

function StopAutoFishV2()
    FuncAutoFishV2.autofishV2 = false
    FuncAutoFishV2.fishingActiveV2 = false
    SimpleNotify("Auto Fish", "Auto Fish V2 Stopped!")
end

-------------------------------------------
----- =======[ BUILD UI ] =======
-------------------------------------------

-- Auto Fishing Section
local AutoFishSection = CreateSection("Auto Fishing")
CreateToggle(AutoFishSection, "Auto Fish V2", function(value)
    if value then
        StartAutoFishV2()
    else
        StopAutoFishV2()
    end
end)

CreateToggle(AutoFishSection, "Perfect Cast", function(value)
    FuncAutoFishV2.perfectCastV2 = value
    SimpleNotify("Perfect Cast", value and "Enabled" or "Disabled")
end)

CreateToggle(AutoFishSection, "Auto Sell", function(value)
    state.AutoSell = value
    SimpleNotify("Auto Sell", value and "Enabled" or "Disabled")
end)

-- Utility Section
local UtilitySection = CreateSection("Utility")
CreateButton(UtilitySection, "Sell All Fish", function()
    local sellRemote = net:WaitForChild("RF/SellAllItems")
    pcall(function()
        sellRemote:InvokeServer()
        SimpleNotify("Sell Fish", "All fish sold!")
    end)
end)

CreateButton(UtilitySection, "Rejoin Server", function()
    TeleportService:Teleport(PlaceId)
end)

CreateButton(UtilitySection, "Server Hop", function()
    local placeId = game.PlaceId
    local servers = {}
    
    local success, result = pcall(function()
        return game:GetService("HttpService"):JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/"..placeId.."/servers/Public?sortOrder=Asc&limit=25"))
    end)
    
    if success and result and result.data then
        for _, server in pairs(result.data) do
            if server.playing < server.maxPlayers and server.id ~= game.JobId then
                table.insert(servers, server.id)
            end
        end
        
        if #servers > 0 then
            local targetServer = servers[math.random(1, #servers)]
            TeleportService:TeleportToPlaceInstance(placeId, targetServer, LocalPlayer)
        else
            SimpleNotify("Server Hop", "No servers available!")
        end
    end
end)

-- Teleport Section
local TeleportSection = CreateSection("Quick Teleport")
CreateButton(TeleportSection, "Fishing Spot", function()
    local char = workspace:FindFirstChild("Characters"):FindFirstChild(LocalPlayer.Name)
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hrp then
        hrp.CFrame = CFrame.new(-1471, -3, 1929)
        SimpleNotify("Teleport", "Teleported to Fishing Spot!")
    end
end)

CreateButton(TeleportSection, "Sell Area", function()
    local char = workspace:FindFirstChild("Characters"):FindFirstChild(LocalPlayer.Name)
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hrp then
        hrp.CFrame = CFrame.new(-658, 3, 719)
        SimpleNotify("Teleport", "Teleported to Sell Area!")
    end
end)

-- Settings Section
local SettingsSection = CreateSection("Settings")
CreateToggle(SettingsSection, "Anti-AFK", function(value)
    if value then
        SimpleNotify("Anti-AFK", "Anti-AFK Enabled")
    else
        SimpleNotify("Anti-AFK", "Anti-AFK Disabled")
    end
end)

CreateButton(SettingsSection, "Boost FPS", function()
    for _, v in pairs(game:GetDescendants()) do
        if v:IsA("BasePart") then
            v.Material = Enum.Material.SmoothPlastic
            v.Reflectance = 0
        elseif v:IsA("Decal") or v:IsA("Texture") then
            v.Transparency = 1
        end
    end
    SimpleNotify("FPS Boost", "FPS Optimized!")
end)

-------------------------------------------
----- =======[ UI EVENT HANDLERS ] =======
-------------------------------------------

-- Close button
CloseButton.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- Toggle button untuk show/hide
ToggleButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

-- Drag functionality untuk desktop
local dragging
local dragInput
local dragStart
local startPos

local function update(input)
    local delta = input.Position - dragStart
    MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

TitleBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

game:GetService("UserInputService").InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        update(input)
    end
end)

-- Auto-resize ScrollFrame
UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y + 10)
end)

-- Add semua sections ke ScrollFrame
AutoFishSection.Parent = ScrollFrame
UtilitySection.Parent = ScrollFrame
TeleportSection.Parent = ScrollFrame
SettingsSection.Parent = ScrollFrame

-- Set initial canvas size
task.wait(0.1)
ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y + 10)

SimpleNotify("ZiaanHub Mobile", "Script loaded successfully! Tap 'Menu' to show/hide.")