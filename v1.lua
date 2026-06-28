--[[
    Nexera - GAG 2
    UI tetap sama (Farm + Economy tab), logic Harvest/Water/Plant/Sell
    diisi pakai logic asli dari GAG Hub reference (Networking + Utils
    yang robust, bukan asumsi remote/attribute lagi).
]]

---------------------------------------------------------------
-- CORE: NETWORKING (robust remote resolver, dot-path based)
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
-- CORE: UTILITIES
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
-- SETTINGS (interval + behavior config, controlled by UI)
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
-- LOAD UI LIBRARY
---------------------------------------------------------------

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Notify = {}
function Notify:Fire(text)
    Rayfield:Notify({ Title = "Nexera", Content = text, Duration = 5 })
end

---------------------------------------------------------------
-- WINDOW
---------------------------------------------------------------

local Window = Rayfield:CreateWindow({
   Name = "Nexera - GAG 2",
   Icon = 0,
   LoadingTitle = "Nexera Scripts",
   LoadingSubtitle = "by Codepikk",
   ShowText = "NexERA",
   Theme = "Default",
   ToggleUIKeybind = "K",
   DisableRayfieldPrompts = false,
   DisableBuildWarnings = false,
   ConfigurationSaving = {
      Enabled = true,
      FolderName = nil,
      FileName = "Big Hub"
   },
   Discord = {
      Enabled = false,
      Invite = "noinvitelink",
      RememberJoins = true
   },
   KeySystem = false,
   KeySettings = {
      Title = "Untitled",
      Subtitle = "Key System",
      Note = "No method of obtaining the key is provided",
      FileName = "Key",
      SaveKey = true,
      GrabKeyFromSite = false,
      Key = {"Hello"}
   }
})

---------------------------------------------------------------
-- TAB 1: FARM
---------------------------------------------------------------

local FarmTab = Window:CreateTab("Farm", "sprout")

FarmTab:CreateSection("⚡ Auto Modules")

---------------------------------------------------------------
-- AUTO HARVEST (real logic — periodic scan + isHarvestable guard)
-- Handles both multi-fruit plants (Fruits folder) and single-harvest
-- plants (HarvestPrompt directly on the plant model).
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

local HarvestToggle = FarmTab:CreateToggle({
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
-- AUTO WATER (real logic — find/equip can, water plants under
-- growth threshold). Remote: WateringCan.UseWateringCan(pos, canName, tool)
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

local WateringToggle = FarmTab:CreateToggle({
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
-- AUTO PLANT (real logic — equip seed from backpack, scan empty
-- grid spots across PlantArea parts, fire Plant.PlantSeed)
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

local AutoPlantToggle = FarmTab:CreateToggle({
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

local EconTab = Window:CreateTab("Economy", "dollar-sign")

EconTab:CreateSection("💰 Economy")

---------------------------------------------------------------
-- AUTO SELL (real logic — checks backpack/character for fruit
-- before firing, then NPCS.SellAll)
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

local SellToggle = EconTab:CreateToggle({
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

-- EXAMPLE: Auto Claim Toggle (belum ada remote referensinya — tinggal kamu isi)
local ClaimToggle = EconTab:CreateToggle({
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

Rayfield:LoadConfiguration()
