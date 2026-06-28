--[[
    Nexera - GAG 2 (Manual UI Version)
    UI diganti ke Manual (Roblox Instances), logic Harvest/Water/Plant/Sell
    tetap menggunakan logic asli dari GAG Hub reference.
]]

---------------------------------------------------------------
-- CORE: NETWORKING (SAMA PERSIS DENGAN ASLI)
---------------------------------------------------------------

local Networking = {}
local RS = game:GetService("ReplicatedStorage")

Networking._module = nil
Networking._cache = {}
Networking._log = false

function Networking._resolve()
    if Networking._module then return Networking._module end

    -- Method 1: require()
    local ok, result = pcall(function()
        local shared = RS:WaitForChild("SharedModules", 10)
        local net = shared:WaitForChild("Networking", 10)
        return require(net)
    end)
    if ok and type(result) == "table" then
        Networking._module = result
        return result
    end

    -- Method 2: getgc fallback
    local gcOk, gcResult = pcall(function()
        if not getgc then return nil end
        for _, v in pairs(getgc(true)) do
            if type(v) == "table" then
                local hasPlant = type(v.Plant) == "table" and v.Plant.PlantSeed ~= nil
                local hasGarden = type(v.Garden) == "table" and v.Garden.CollectFruit ~= nil
                local hasSeedShop = type(v.SeedShop) == "table" and v.SeedShop.PurchaseSeed ~= nil
                if hasPlant and hasGarden and hasSeedShop then return v end
            end
        end
        return nil
    end)
    if gcOk and type(gcResult) == "table" then
        Networking._module = gcResult
        return gcResult
    end

    -- Method 3: pre-require Packet, then Networking
    local pktOk, pktResult = pcall(function()
        local shared = RS:WaitForChild("SharedModules", 10)
        local pkt = shared:WaitForChild("Packet", 5)
        local net = shared:WaitForChild("Networking", 5)
        require(pkt)
        return require(net)
    end)
    if pktOk and type(pktResult) == "table" then
        Networking._module = pktResult
        return pktResult
    end

    warn("[Nexera] Failed to resolve Networking module")
    return nil
end

function Networking._resolveRemote(path)
    if Networking._cache[path] then return Networking._cache[path] end
    local net = Networking._resolve()
    if not net then return nil end

    local current = net
    for segment in string.gmatch(path, "[^%.]+") do
        if type(current) ~= "table" then return nil end
        current = current[segment]
        if current == nil then return nil end
    end

    Networking._cache[path] = current
    return current
end

function Networking.fire(path, ...)
    local remote = Networking._resolveRemote(path)
    if not remote then
        warn("[Nexera] Remote not found:", path)
        return false
    end
    local args = {...}
    local argc = select("#", ...)
    local ok, err = pcall(function()
        if remote.Fire then
            remote:Fire(unpack(args, 1, argc))
        else
            error("Remote has no :Fire")
        end
    end)
    if not ok then
        warn("[Nexera] Fire error on", path, ":", err)
        return false
    end
    if Networking._log then print("[Nexera] Fired:", path) end
    return true
end

function Networking.on(path, callback)
    local remote = Networking._resolveRemote(path)
    if not remote then return nil end
    local ok, connection = pcall(function()
        if remote.OnClientEvent then
            return remote.OnClientEvent:Connect(callback)
        end
        return nil
    end)
    if ok then return connection end
    return nil
end

Networking._resolve()

---------------------------------------------------------------
-- CORE: UTILITIES (SAMA PERSIS DENGAN ASLI)
---------------------------------------------------------------

local Utils = {}
local Players = game:GetService("Players")

function Utils.getLocalPlayer()
    return Players.LocalPlayer
end

function Utils.getCharacter()
    local lp = Players.LocalPlayer
    return lp and lp.Character or nil
end

function Utils.getHumanoidRootPart()
    local char = Utils.getCharacter()
    return char and char:FindFirstChild("HumanoidRootPart")
end

function Utils.getPlotId()
    local lp = Players.LocalPlayer
    return lp and lp:GetAttribute("PlotId")
end

function Utils.getMyGarden()
    local plotId = Utils.getPlotId()
    if not plotId then return nil end
    local gardens = workspace:FindFirstChild("Gardens")
    if not gardens then return nil end
    return gardens:FindFirstChild("Plot" .. tostring(plotId))
end

function Utils.getPlantsInGarden(garden)
    if not garden then return {} end
    local plants = {}
    local folder = garden:FindFirstChild("Plants")
    if not folder then return plants end
    for _, child in ipairs(folder:GetChildren()) do
        table.insert(plants, child)
    end
    return plants
end

function Utils.getPlantInfo(plant)
    if not plant then return nil end
    return {
        Name     = plant:GetAttribute("SeedName") or plant.Name,
        Growth   = plant:GetAttribute("Growth") or 0,
        Mutation = plant:GetAttribute("Mutation"),
        PlantId  = plant:GetAttribute("PlantId"),
        Instance = plant,
    }
end

function Utils.getBackpackItems()
    local lp = Players.LocalPlayer
    local bp = lp and lp:FindFirstChild("Backpack")
    if not bp then return {} end
    local items = {}
    for _, tool in ipairs(bp:GetChildren()) do
        if tool:IsA("Tool") then
            table.insert(items, tool)
        end
    end
    return items
end

function Utils.getSheckles()
    local lp = Players.LocalPlayer
    local leaderstats = lp and lp:FindFirstChild("leaderstats")
    if not leaderstats then return 0 end
    local sheckles = leaderstats:FindFirstChild("Sheckles")
    return sheckles and sheckles.Value or 0
end

---------------------------------------------------------------
-- SETTINGS
---------------------------------------------------------------

local Settings = {
    HarvestInterval = 0.5,
    WaterInterval   = 3,
    PlantInterval   = 5,
    SellInterval    = 5,

    WaterFullyGrown = false,
    RequiredCan     = "",

    PlantOrder        = "Top",
    GridSpacing       = 3,
    PreferSeed        = nil,
    BlacklistMutated  = true,

    SellMode = "all",
}

---------------------------------------------------------------
-- MANUAL UI SYSTEM
---------------------------------------------------------------

local GuiLib = {}
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

-- Cleanup existing GUI if any
for _, v in pairs(CoreGui:GetChildren()) do
    if v.Name == "NexeraManualUI" then v:Destroy() end
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "NexeraManualUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = CoreGui

-- Helper: Create Instance
local function New(class, props)
    local obj = Instance.new(class)
    for k, v in pairs(props) do
        if k ~= "Parent" then obj[k] = v end
    end
    return obj
end

-- Main Window Frame
local MainFrame = New("Frame", {
    Name = "MainFrame",
    Size = UDim2.new(0, 400, 0, 500),
    Position = UDim2.new(0.5, -200, 0.5, -250),
    BackgroundColor3 = Color3.fromRGB(30, 30, 30),
    BorderSizePixel = 0,
    Parent = ScreenGui
})

-- Title Bar
local TitleBar = New("Frame", {
    Name = "TitleBar",
    Size = UDim2.new(1, 0, 0, 40),
    BackgroundColor3 = Color3.fromRGB(20, 20, 20),
    Parent = MainFrame
})

local TitleLabel = New("TextLabel", {
    Name = "Title",
    Size = UDim2.new(1, -40, 1, 0),
    BackgroundTransparency = 1,
    Text = "Nexera - GAG 2",
    TextColor3 = Color3.fromRGB(255, 255, 255),
    Font = Enum.Font.GothamBold,
    TextSize = 18,
    TextXAlignment = Enum.TextXAlignment.Left,
    Parent = TitleBar
})

local CloseBtn = New("TextButton", {
    Name = "Close",
    Size = UDim2.new(0, 40, 1, 0),
    Position = UDim2.new(1, -40, 0, 0),
    BackgroundColor3 = Color3.fromRGB(200, 50, 50),
    Text = "X",
    TextColor3 = Color3.white,
    Font = Enum.Font.GothamBold,
    Parent = TitleBar
})

CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui.Enabled = not ScreenGui.Enabled
end)

-- Dragging Logic (FIXED)
local dragging = false
local dragStart = nil
local startPos = nil

local function update(input)
    if not dragging then
        return
    end

    if not dragStart or not startPos then
        return
    end

    if not input.Position then
        return
    end

    local delta = input.Position - dragStart

    MainFrame.Position = UDim2.new(
        startPos.X.Scale,
        startPos.X.Offset + delta.X,
        startPos.Y.Scale,
        startPos.Y.Offset + delta.Y
    )
end

TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then

        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
                dragStart = nil
                startPos = nil
            end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (
        input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch
    ) then
        update(input)
    end
end)

-- Tab Container
local TabContainer = New("Frame", {
    Name = "TabContainer",
    Size = UDim2.new(1, 0, 0, 40),
    Position = UDim2.new(0, 0, 0, 40),
    BackgroundColor3 = Color3.fromRGB(25, 25, 25),
    Parent = MainFrame
})

local ContentArea = New("ScrollingFrame", {
    Name = "ContentArea",
    Size = UDim2.new(1, 0, 1, -80),
    Position = UDim2.new(0, 0, 0, 80),
    BackgroundColor3 = Color3.fromRGB(35, 35, 35),
    BorderSizePixel = 0,
    ScrollBarThickness = 5,
    CanvasSize = UDim2.new(1, 0, 0, 0),
    AutomaticCanvasSize = Enum.AutomaticSize.Y,
    Parent = MainFrame
})

-- Tabs Logic
local Tabs = {}
local ActiveTab = nil

function GuiLib:CreateTab(name)
    local tabBtn = New("TextButton", {
        Name = name,
        Size = UDim2.new(0.5, 0, 1, 0),
        BackgroundColor3 = Color3.fromRGB(25, 25, 25),
        Text = name,
        TextColor3 = Color3.fromRGB(150, 150, 150),
        Font = Enum.Font.GothamMedium,
        Parent = TabContainer
    })
    
    local tabContent = New("Frame", {
        Name = name .. "Content",
        Size = UDim2.new(1, 0, 0, 0),
        BackgroundTransparency = 1,
        Visible = false,
        Parent = ContentArea
    })
    
    local layout = New("UIListLayout", {
        Parent = tabContent,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 5)
    })
    
    local padding = New("UIPadding", {
        Parent = tabContent,
        PaddingLeft = UDim.new(0, 10),
        PaddingRight = UDim.new(0, 10),
        PaddingTop = UDim.new(0, 10),
        PaddingBottom = UDim.new(0, 10)
    })

    local function switchTab()
        for _, t in pairs(Tabs) do
            t.Btn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
            t.Btn.TextColor3 = Color3.fromRGB(150, 150, 150)
            t.Frame.Visible = false
        end
        tabBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        tabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        tabContent.Visible = true
        ActiveTab = tabContent
    end

    tabBtn.MouseButton1Click:Connect(switchTab)
    
    table.insert(Tabs, { Btn = tabBtn, Frame = tabContent })
    if #Tabs == 1 then switchTab() end -- Select first tab by default

    local TabObj = {}
    
    function TabObj:CreateSection(title)
        local section = New("Frame", {
            Size = UDim2.new(1, 0, 0, 30),
            BackgroundTransparency = 1,
            LayoutOrder = 1,
            Parent = tabContent
        })
        New("TextLabel", {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Text = title,
            TextColor3 = Color3.fromRGB(255, 255, 255),
            Font = Enum.Font.GothamBold,
            TextSize = 16,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = section
        })
        New("Frame", {
            Size = UDim2.new(1, 0, 0, 1),
            Position = UDim2.new(0, 0, 1, -1),
            BackgroundColor3 = Color3.fromRGB(60, 60, 60),
            BorderSizePixel = 0,
            Parent = section
        })
    end

    function TabObj:CreateToggle(config)
        local container = New("Frame", {
            Size = UDim2.new(1, 0, 0, 30),
            BackgroundColor3 = Color3.fromRGB(40, 40, 40),
            LayoutOrder = 2,
            Parent = tabContent
        })
        
        local label = New("TextLabel", {
            Size = UDim2.new(1, -40, 1, 0),
            BackgroundTransparency = 1,
            Text = config.Name,
            TextColor3 = Color3.fromRGB(200, 200, 200),
            Font = Enum.Font.GothamMedium,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = container
        })
        
        local toggleBtn = New("TextButton", {
            Name = "ToggleBtn",
            Size = UDim2.new(0, 30, 0, 30),
            Position = UDim2.new(1, -30, 0, 0),
            BackgroundColor3 = config.CurrentValue and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(100, 100, 100),
            Text = "",
            Parent = container
        })
        
        local state = config.CurrentValue
        
        local function updateVisual()
            toggleBtn.BackgroundColor3 = state and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(100, 100, 100)
        end
        
        toggleBtn.MouseButton1Click:Connect(function()
            state = not state
            updateVisual()
            if config.Callback then config.Callback(state) end
        end)
        
        -- Return object to allow external updates if needed
        return {
            SetValue = function(val)
                state = val
                updateVisual()
            end
        }
    end

    function TabObj:CreateSlider(config)
        local container = New("Frame", {
            Size = UDim2.new(1, 0, 0, 40),
            BackgroundColor3 = Color3.fromRGB(40, 40, 40),
            LayoutOrder = 3,
            Parent = tabContent
        })
        
        local label = New("TextLabel", {
            Size = UDim2.new(1, 0, 0, 20),
            Position = UDim2.new(0, 5, 0, 0),
            BackgroundTransparency = 1,
            Text = config.Name,
            TextColor3 = Color3.fromRGB(200, 200, 200),
            Font = Enum.Font.GothamMedium,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = container
        })
        
        local valueLabel = New("TextLabel", {
            Size = UDim2.new(1, 0, 0, 20),
            Position = UDim2.new(0, 5, 0, 20),
            BackgroundTransparency = 1,
            Text = tostring(config.CurrentValue) .. " " .. (config.Suffix or ""),
            TextColor3 = Color3.fromRGB(150, 150, 150),
            Font = Enum.Font.GothamMedium,
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = container
        })
        
        local sliderBg = New("Frame", {
            Size = UDim2.new(1, -10, 0, 10),
            Position = UDim2.new(0, 5, 1, -15),
            BackgroundColor3 = Color3.fromRGB(60, 60, 60),
            Parent = container
        })
        
        local sliderFill = New("Frame", {
            Size = UDim2.new(0, 0, 1, 0),
            BackgroundColor3 = Color3.fromRGB(0, 120, 200),
            Parent = sliderBg
        })
        
        local min, max = config.Range[1], config.Range[2]
        local val = config.CurrentValue
        
        local function updateSlider(input)
            local pos = UDim2.new(0, math.clamp(input.Position.X - sliderBg.AbsolutePosition.X, 0, sliderBg.AbsoluteSize.X), 0, 0)
            local scale = pos.X.Offset / sliderBg.AbsoluteSize.X
            val = math.floor((min + (max - min) * scale) / config.Increment + 0.5) * config.Increment
            val = math.clamp(val, min, max)
            
            sliderFill.Size = UDim2.new(scale, 0, 1, 0)
            valueLabel.Text = tostring(val) .. " " .. (config.Suffix or "")
            
            if config.Callback then config.Callback(val) end
        end
        
        local draggingSlider = false
        sliderBg.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                draggingSlider = true
                updateSlider(input)
            end
        end)
        
        UserInputService.InputChanged:Connect(function(input)
            if draggingSlider and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                updateSlider(input)
            end
        end)
        
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                draggingSlider = false
            end
        end)
        
        -- Init visual
        local initScale = (val - min) / (max - min)
        sliderFill.Size = UDim2.new(initScale, 0, 1, 0)
    end

    function TabObj:CreateDropdown(config)
        local container = New("Frame", {
            Size = UDim2.new(1, 0, 0, 30),
            BackgroundColor3 = Color3.fromRGB(40, 40, 40),
            LayoutOrder = 4,
            Parent = tabContent
        })
        
        local label = New("TextLabel", {
            Size = UDim2.new(1, -100, 1, 0),
            BackgroundTransparency = 1,
            Text = config.Name,
            TextColor3 = Color3.fromRGB(200, 200, 200),
            Font = Enum.Font.GothamMedium,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = container
        })
        
        local dropBtn = New("TextButton", {
            Size = UDim2.new(0, 100, 1, 0),
            Position = UDim2.new(1, -100, 0, 0),
            BackgroundColor3 = Color3.fromRGB(50, 50, 50),
            Text = config.CurrentOption,
            TextColor3 = Color3.white,
            Font = Enum.Font.GothamMedium,
            TextSize = 12,
            Parent = container
        })
        
        local isOpen = false
        local listFrame = New("Frame", {
            Size = UDim2.new(1, 0, 0, 0),
            Position = UDim2.new(0, 0, 1, 0),
            BackgroundColor3 = Color3.fromRGB(30, 30, 30),
            ZIndex = 10,
            Visible = false,
            Parent = container
        })
        
        local listLayout = New("UIListLayout", { Parent = listFrame })
        
        for _, opt in ipairs(config.Options) do
            local btn = New("TextButton", {
                Size = UDim2.new(1, 0, 0, 25),
                BackgroundColor3 = Color3.fromRGB(40, 40, 40),
                Text = opt,
                TextColor3 = Color3.white,
                Font = Enum.Font.GothamMedium,
                TextSize = 12,
                Parent = listFrame
            })
            btn.MouseButton1Click:Connect(function()
                dropBtn.Text = opt
                listFrame.Visible = false
                isOpen = false
                container.Size = UDim2.new(1, 0, 0, 30)
                if config.Callback then config.Callback(opt) end
            end)
        end
        
        dropBtn.MouseButton1Click:Connect(function()
            isOpen = not isOpen
            listFrame.Visible = isOpen
            if isOpen then
                container.Size = UDim2.new(1, 0, 0, 30 + (#config.Options * 25))
            else
                container.Size = UDim2.new(1, 0, 0, 30)
            end
        end)
    end
    
    function TabObj:CreateInput(config)
        local container = New("Frame", {
            Size = UDim2.new(1, 0, 0, 30),
            BackgroundColor3 = Color3.fromRGB(40, 40, 40),
            LayoutOrder = 5,
            Parent = tabContent
        })
        
        local label = New("TextLabel", {
            Size = UDim2.new(1, -120, 1, 0),
            BackgroundTransparency = 1,
            Text = config.Name,
            TextColor3 = Color3.fromRGB(200, 200, 200),
            Font = Enum.Font.GothamMedium,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = container
        })
        
        local box = New("TextBox", {
            Size = UDim2.new(0, 120, 1, -4),
            Position = UDim2.new(1, -120, 0, 2),
            BackgroundColor3 = Color3.fromRGB(20, 20, 20),
            Text = "",
            PlaceholderText = config.PlaceholderText or "",
            TextColor3 = Color3.white,
            Font = Enum.Font.GothamMedium,
            ClearTextOnFocus = false,
            Parent = container
        })
        
        box.FocusLost:Connect(function(enterPressed)
            if config.Callback then config.Callback(box.Text) end
        end)
    end

    return TabObj
end

-- Notification System
local Notify = {}
function Notify:Fire(text)
    local notif = New("Frame", {
        Size = UDim2.new(1, -20, 0, 40),
        Position = UDim2.new(0, 10, 1, -50),
        BackgroundColor3 = Color3.fromRGB(0, 120, 200),
        BorderSizePixel = 0,
        Parent = ScreenGui
    })
    
    New("TextLabel", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = Color3.white,
        Font = Enum.Font.GothamBold,
        Parent = notif
    })
    
    task.delay(5, function()
        notif:Destroy()
    end)
end

---------------------------------------------------------------
-- WINDOW CREATION
---------------------------------------------------------------

local Window = {}
function Window:CreateTab(name)
    return GuiLib:CreateTab(name)
end

---------------------------------------------------------------
-- TAB 1: FARM
---------------------------------------------------------------

local FarmTab = Window:CreateTab("Farm")

FarmTab:CreateSection("⚡ Auto Modules")

---------------------------------------------------------------
-- AUTO HARVEST
---------------------------------------------------------------

local isAutoHarvesting = false

local function isHarvestable(model)
    if not model or not model.Parent then return false end
    local harvestPart = model:FindFirstChild("HarvestPart")
    if not harvestPart then return false end
    local prompt = harvestPart:FindFirstChild("HarvestPrompt")
    if not prompt then return false end
    return prompt.Enabled == true
end

local function collectAllFruits()
    local garden = Utils.getMyGarden()
    if not garden then return end

    local plantsFolder = garden:FindFirstChild("Plants")
    if not plantsFolder then return end

    for _, plantModel in ipairs(plantsFolder:GetChildren()) do
        if not isAutoHarvesting then break end
        local plantId = plantModel:GetAttribute("PlantId")
        if not plantId then continue end

        -- Path A: multi-harvest (Fruits folder)
        local fruitsFolder = plantModel:FindFirstChild("Fruits")
        if fruitsFolder then
            for _, fruitModel in ipairs(fruitsFolder:GetChildren()) do
                if not isAutoHarvesting then break end
                if isHarvestable(fruitModel) then
                    local fruitId = fruitModel:GetAttribute("FruitId")
                    Networking.fire("Garden.CollectFruit", plantId, fruitId or "")
                    task.wait(0.1)
                end
            end
        end

        -- Path B: single-harvest (HarvestPrompt directly on plant)
        if isHarvestable(plantModel) then
            Networking.fire("Garden.CollectFruit", plantId, "")
            task.wait(0.1)
        end
    end
end

local HarvestToggleObj = FarmTab:CreateToggle({
   Name = "Auto Harvest",
   CurrentValue = false,
   Flag = "AutoHarvestToggle",
   Callback = function(Value)
      isAutoHarvesting = Value

      if Value then
         Notify:Fire("Harvesting...")

         -- Instant-collect newly spawned fruit
         local fruitAddedConn = Networking.on("Garden.FruitAdded", function(plantId, fruitId)
            if not isAutoHarvesting then return end
            task.wait(0.15)
            pcall(function()
               Networking.fire("Garden.CollectFruit", plantId, fruitId or "")
            end)
         end)

         task.spawn(function()
            while isAutoHarvesting and task.wait(Settings.HarvestInterval) do
               pcall(collectAllFruits)
            end
            if fruitAddedConn then pcall(function() fruitAddedConn:Disconnect() end) end
         end)
      else
         Notify:Fire("Auto Harvest Disabled")
      end
   end,
})

---------------------------------------------------------------
-- AUTO WATER
---------------------------------------------------------------

local isAutoWatering = false

local function trim(s)
    if type(s) ~= "string" then return "" end
    return s:match("^%s*(.-)%s*$") or ""
end

local function findWateringCan(requiredCan)
    local lp = Utils.getLocalPlayer()
    if not lp then return nil, nil end

    local reqNorm = trim(requiredCan)
    local function matches(canName)
        if reqNorm == "" then return true end
        return trim(canName) == reqNorm
    end

    local function scan(container)
        if not container then return nil, nil end
        for _, tool in ipairs(container:GetChildren()) do
            if tool:IsA("Tool") and tool:GetAttribute("WateringCan") ~= nil then
                if matches(tool.Name) then return tool, tool.Name end
            end
        end
        return nil, nil
    end

    local tool, canName = scan(lp.Character)
    if tool then return tool, canName end
    return scan(lp:FindFirstChild("Backpack"))
end

local function equipCan(tool)
    local lp = Utils.getLocalPlayer()
    local char = lp and lp.Character
    local humanoid = char and char:FindFirstChildWhichIsA("Humanoid")
    if not humanoid then return false end
    if tool.Parent == char then return true end
    pcall(function() humanoid:EquipTool(tool) end)
    task.wait(0.2)
    return tool.Parent == char
end

local function waterPlants()
    local garden = Utils.getMyGarden()
    if not garden then return end

    local canTool, canName = findWateringCan(Settings.RequiredCan)
    if not canTool then return end
    if not equipCan(canTool) then return end

    local plants = Utils.getPlantsInGarden(garden)
    for _, plant in ipairs(plants) do
        if not isAutoWatering then break end

        local info = Utils.getPlantInfo(plant)
        if not info then continue end

        local growth = info.Growth or 0
        local isFullyGrown = growth >= 1
        if isFullyGrown and not Settings.WaterFullyGrown then continue end

        local rootPart = plant:FindFirstChildWhichIsA("BasePart")
        if not rootPart then continue end

        local pos = rootPart.Position - Vector3.new(0, 0.3, 0)
        pcall(function()
            Networking.fire("WateringCan.UseWateringCan", pos, canName, canTool)
        end)

        task.wait(0.5) -- cooldown to match game's TryWater cooldown
    end
end

local WateringToggleObj = FarmTab:CreateToggle({
   Name = "Auto Water",
   CurrentValue = false,
   Flag = "AutoWaterToggle",
   Callback = function(Value)
      isAutoWatering = Value

      if Value then
         Notify:Fire("Auto Watering...")
         task.spawn(function()
            while isAutoWatering and task.wait(Settings.WaterInterval) do
               pcall(waterPlants)
            end
         end)
      else
         Notify:Fire("Auto Water Disabled")
      end
   end,
})

---------------------------------------------------------------
-- AUTO PLANT
---------------------------------------------------------------

local isAutoPlanting = false
local CollectionService = game:GetService("CollectionService")

local function isMutatedSeed(seedToolValue)
    if not seedToolValue then return false end
    if seedToolValue == "Gold" or seedToolValue == "Rainbow" then return true end
    return seedToolValue:match("^Gold ") ~= nil or seedToolValue:match("^Rainbow ") ~= nil
end

local function getEquippedSeed()
    local char = Utils.getCharacter()
    if not char then return nil, nil end
    local tool = char:FindFirstChildWhichIsA("Tool")
    if not tool then return nil, nil end
    if tool:GetAttribute("MainCategory") ~= "Seed" then return nil, nil end
    local seedName = tool:GetAttribute("SeedTool")
    if not seedName then return nil, nil end
    return seedName, tool
end

local function findSeedsInBackpack(preferSeed, skipMutated)
    local lp = Utils.getLocalPlayer()
    local bp = lp and lp:FindFirstChild("Backpack")
    if not bp then return {} end
    local seeds = {}
    for _, tool in ipairs(bp:GetChildren()) do
        if tool:IsA("Tool") then
            local cat = tool:GetAttribute("MainCategory")
            local sn = tool:GetAttribute("SeedTool")
            if sn and cat == "Seed" then
                if not (skipMutated and isMutatedSeed(sn)) then
                    table.insert(seeds, { tool = tool, seedName = sn })
                end
            end
        end
    end
    table.sort(seeds, function(a, b)
        if preferSeed then
            local aMatch = (a.seedName == preferSeed) and 1 or 0
            local bMatch = (b.seedName == preferSeed) and 1 or 0
            if aMatch ~= bMatch then return aMatch > bMatch end
        end
        return a.seedName < b.seedName
    end)
    return seeds
end

local function equipSeed(preferSeed, skipMutated)
    local char = Utils.getCharacter()
    if not char then return nil, nil end
    local humanoid = char:FindFirstChildWhichIsA("Humanoid")
    if not humanoid then return nil, nil end

    local sn, tool = getEquippedSeed()
    if sn then
        if not (skipMutated and isMutatedSeed(sn)) then return sn, tool end
    end

    local seeds = findSeedsInBackpack(preferSeed, skipMutated)
    if #seeds == 0 then return nil, nil end

    local target = seeds[1]
    local ok = pcall(function() humanoid:EquipTool(target.tool) end)
    if not ok then return nil, nil end

    local waited = 0
    while waited < 2 do
        task.wait(0.1)
        waited += 0.1
        local equipped = char:FindFirstChild(target.tool.Name)
        if equipped and equipped:IsA("Tool") and equipped:GetAttribute("SeedTool") then
            return target.seedName, target.tool
        end
    end
    return nil, nil
end

local function unequipSeedTool()
    local lp = Utils.getLocalPlayer()
    local char = lp and lp.Character
    if not char then return end
    local tool = char:FindFirstChildWhichIsA("Tool")
    if not tool then return end
    pcall(function() tool.Parent = lp:FindFirstChild("Backpack") end)
end

local function isPosEmpty(pos, myPlot, minDist)
    minDist = minDist or 2.5
    local plantsFolder = myPlot:FindFirstChild("Plants")
    if not plantsFolder then return true end
    for _, plantModel in ipairs(plantsFolder:GetChildren()) do
        local root = plantModel.PrimaryPart or plantModel:FindFirstChildWhichIsA("BasePart")
        if root then
            local dist = (Vector2.new(root.Position.X, root.Position.Z) - Vector2.new(pos.X, pos.Z)).Magnitude
            if dist < minDist then return false end
        end
    end
    return true
end

local function generateGridFromPart(part, spacing)
    spacing = spacing or 3
    local positions = {}
    local size = part.Size
    local cf = part.CFrame
    local stepsX = math.max(1, math.floor(size.X / spacing))
    local stepsZ = math.max(1, math.floor(size.Z / spacing))
    for ix = 0, stepsX do
        for iz = 0, stepsZ do
            local localX = -(size.X / 2) + (ix / stepsX) * size.X
            local localZ = -(size.Z / 2) + (iz / stepsZ) * size.Z
            table.insert(positions, cf * Vector3.new(localX, size.Y / 2, localZ))
        end
    end
    return positions
end

local function findEmptySpots(myPlot, spacing, sortMode)
    local plantAreaParts = {}
    for _, part in ipairs(CollectionService:GetTagged("PlantArea")) do
        if part:IsA("BasePart") and part:IsDescendantOf(myPlot) then
            table.insert(plantAreaParts, part)
        end
    end

    local allPositions = {}
    for _, part in ipairs(plantAreaParts) do
        for _, pos in ipairs(generateGridFromPart(part, spacing)) do
            table.insert(allPositions, pos)
        end
    end

    local emptySpots = {}
    for _, pos in ipairs(allPositions) do
        if isPosEmpty(pos, myPlot) then table.insert(emptySpots, pos) end
    end

    sortMode = sortMode or "Top"
    if sortMode == "Top" then
        table.sort(emptySpots, function(a, b) return a.Y > b.Y end)
    elseif sortMode == "Bottom" then
        table.sort(emptySpots, function(a, b) return a.Y < b.Y end)
    else
        for i = #emptySpots, 2, -1 do
            local j = math.random(1, i)
            emptySpots[i], emptySpots[j] = emptySpots[j], emptySpots[i]
        end
    end
    return emptySpots
end

local function autoPlantCycle()
    local seedName, toolInstance = equipSeed(Settings.PreferSeed, Settings.BlacklistMutated)
    if not seedName then return end

    local myPlot = Utils.getMyGarden()
    if not myPlot then
        unequipSeedTool()
        return
    end

    local spots = findEmptySpots(myPlot, Settings.GridSpacing, Settings.PlantOrder)
    if #spots == 0 then
        unequipSeedTool()
        return
    end

    for _, pos in ipairs(spots) do
        if not isAutoPlanting then break end

        local curSn = getEquippedSeed()
        if not curSn then
            seedName, toolInstance = equipSeed(Settings.PreferSeed, Settings.BlacklistMutated)
            if not seedName then break end
        end

        pcall(function()
            Networking.fire("Plant.PlantSeed", pos, seedName, toolInstance)
        end)

        task.wait(0.3)
    end

    unequipSeedTool()
end

local AutoPlantToggleObj = FarmTab:CreateToggle({
   Name = "Auto Plant",
   CurrentValue = false,
   Flag = "AutoPlantToggle",
   Callback = function(Value)
      isAutoPlanting = Value

      if Value then
         Notify:Fire("Auto Planting...")
         task.spawn(function()
            while isAutoPlanting and task.wait(Settings.PlantInterval) do
               pcall(autoPlantCycle)
            end
         end)
      else
         Notify:Fire("Auto Plant Disabled")
      end
   end,
})

FarmTab:CreateSection("⏱ Intervals")

FarmTab:CreateSlider({
   Name = "Harvest", Range = {0.1, 10}, Increment = 0.1, Suffix = "s",
   CurrentValue = Settings.HarvestInterval, Flag = "HarvestInterval",
   Callback = function(Value) Settings.HarvestInterval = Value end,
})

FarmTab:CreateSlider({
   Name = "Water", Range = {1, 15}, Increment = 1, Suffix = "s",
   CurrentValue = Settings.WaterInterval, Flag = "WaterInterval",
   Callback = function(Value) Settings.WaterInterval = Value end,
})

FarmTab:CreateSlider({
   Name = "Plant", Range = {1, 15}, Increment = 1, Suffix = "s",
   CurrentValue = Settings.PlantInterval, Flag = "PlantInterval",
   Callback = function(Value) Settings.PlantInterval = Value end,
})

FarmTab:CreateSection("💧 Water Config")

FarmTab:CreateToggle({
   Name = "Water Fully Grown", CurrentValue = Settings.WaterFullyGrown, Flag = "WaterFullyGrown",
   Callback = function(Value) Settings.WaterFullyGrown = Value end,
})

FarmTab:CreateDropdown({
   Name = "Required Can (empty=any)",
   Options = {"", "Common Watering Can", "Super Watering Can"},
   CurrentOption = Settings.RequiredCan, Flag = "RequiredCan",
   Callback = function(Value) Settings.RequiredCan = Value end,
})

FarmTab:CreateSection("🌱 Plant Config")

FarmTab:CreateDropdown({
   Name = "Plant Order", Options = {"Top", "Bottom", "Random"},
   CurrentOption = Settings.PlantOrder, Flag = "PlantOrder",
   Callback = function(Value) Settings.PlantOrder = Value end,
})

FarmTab:CreateSlider({
   Name = "Grid Spacing", Range = {2, 8}, Increment = 0.5, Suffix = " studs",
   CurrentValue = Settings.GridSpacing, Flag = "GridSpacing",
   Callback = function(Value) Settings.GridSpacing = Value end,
})

FarmTab:CreateInput({
   Name = "Prefer Seed (empty=any)", PlaceholderText = "e.g. Carrot",
   RemoveTextAfterFocusLost = false, Flag = "PreferSeed",
   Callback = function(Value) Settings.PreferSeed = (Value ~= "" and Value or nil) end,
})

FarmTab:CreateToggle({
   Name = "Skip Mutated Seeds", CurrentValue = Settings.BlacklistMutated, Flag = "BlacklistMutated",
   Callback = function(Value) Settings.BlacklistMutated = Value end,
})

---------------------------------------------------------------
-- TAB 2: ECONOMY
---------------------------------------------------------------

local EconTab = Window:CreateTab("Economy")

EconTab:CreateSection("💰 Economy")

---------------------------------------------------------------
-- AUTO SELL
---------------------------------------------------------------

local isAutoSelling = false

local function hasFruitInInventory()
    local lp = Utils.getLocalPlayer()
    if not lp then return false end

    local bp = lp:FindFirstChild("Backpack")
    if bp then
        for _, tool in ipairs(bp:GetChildren()) do
            if tool:IsA("Tool") and (tool:GetAttribute("FruitName") or tool:GetAttribute("IsFruit")) then
                return true
            end
        end
    end

    if lp.Character then
        for _, tool in ipairs(lp.Character:GetChildren()) do
            if tool:IsA("Tool") and (tool:GetAttribute("FruitName") or tool:GetAttribute("IsFruit")) then
                return true
            end
        end
    end

    return false
end

local function autoSellCycle()
    if not hasFruitInInventory() then return end
    Networking.fire("NPCS.SellAll")
end

local SellToggleObj = EconTab:CreateToggle({
   Name = "Auto Sell (When Full)",
   CurrentValue = false,
   Flag = "AutoSellToggle",
   Callback = function(Value)
      isAutoSelling = Value

      if Value then
         Notify:Fire("Auto Selling...")
         task.spawn(function()
            while isAutoSelling and task.wait(Settings.SellInterval) do
               pcall(autoSellCycle)
            end
         end)
      else
         Notify:Fire("Auto Sell Disabled")
      end
   end,
})

-- EXAMPLE: Auto Claim Toggle
local ClaimToggleObj = EconTab:CreateToggle({
   Name = "Auto Claim Mail",
   CurrentValue = false,
   Flag = "AutoClaimToggle",
   Callback = function(Value)
      -- TODO: Isi logic auto claim di sini (belum ada referensi remote-nya)
   end,
})

EconTab:CreateSection("⏱ Intervals")

EconTab:CreateSlider({
   Name = "Sell", Range = {1, 30}, Increment = 1, Suffix = "s",
   CurrentValue = Settings.SellInterval, Flag = "SellInterval",
   Callback = function(Value) Settings.SellInterval = Value end,
})

print("[Nexera] Manual UI Loaded Successfully")
