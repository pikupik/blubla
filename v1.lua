--[[
    Nexera - GAG 2 (Simple Manual UI)
    Tanpa UI Library. Menggunakan basic Roblox ScreenGui.
]]

---------------------------------------------------------------
-- SETTINGS (Ubah manual di sini)
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
}

---------------------------------------------------------------
-- CORE: NETWORKING & UTILS
---------------------------------------------------------------
local Networking = {}
local RS = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

Networking._module = nil
Networking._cache = {}

function Networking._resolve()
    if Networking._module then return Networking._module end
    pcall(function() Networking._module = require(RS:WaitForChild("SharedModules", 10):WaitForChild("Networking", 10)) end)
    if Networking._module then return Networking._module end
    pcall(function()
        for _, v in pairs(getgc(true)) do
            if type(v) == "table" and type(v.Plant) == "table" and v.Plant.PlantSeed ~= nil then Networking._module = v return v end
        end
    end)
    return Networking._module
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
    if remote and remote.Fire then
        pcall(function(...) remote:Fire(...) end, ...)
    end
end

function Networking.on(path, callback)
    local remote = Networking._resolveRemote(path)
    if remote and remote.OnClientEvent then
        return remote.OnClientEvent:Connect(callback)
    end
end

Networking._resolve()

local Utils = {}
function Utils.getLocalPlayer() return Players.LocalPlayer end
function Utils.getCharacter() return Players.LocalPlayer.Character end
function Utils.getMyGarden()
    local plotId = Players.LocalPlayer:GetAttribute("PlotId")
    if not plotId then return nil end
    return workspace:FindFirstChild("Gardens") and workspace.Gardens:FindFirstChild("Plot" .. tostring(plotId))
end

---------------------------------------------------------------
-- FARMING LOGIC
---------------------------------------------------------------
local isAutoHarvesting, isAutoWatering, isAutoPlanting, isAutoSelling = false, false, false, false

-- HARVEST
local function collectAllFruits()
    local garden = Utils.getMyGarden()
    if not garden or not garden:FindFirstChild("Plants") then return end
    for _, plantModel in ipairs(garden.Plants:GetChildren()) do
        if not isAutoHarvesting then break end
        local plantId = plantModel:GetAttribute("PlantId")
        if not plantId then continue end

        local fruitsFolder = plantModel:FindFirstChild("Fruits")
        if fruitsFolder then
            for _, fruitModel in ipairs(fruitsFolder:GetChildren()) do
                if not isAutoHarvesting then break end
                local prompt = fruitModel:FindFirstChild("HarvestPart") and fruitModel.HarvestPart:FindFirstChild("HarvestPrompt")
                if prompt and prompt.Enabled then
                    Networking.fire("Garden.CollectFruit", plantId, fruitModel:GetAttribute("FruitId") or "")
                    task.wait(0.1)
                end
            end
        end

        local prompt = plantModel:FindFirstChild("HarvestPart") and plantModel.HarvestPart:FindFirstChild("HarvestPrompt")
        if prompt and prompt.Enabled then
            Networking.fire("Garden.CollectFruit", plantId, "")
            task.wait(0.1)
        end
    end
end

-- WATER
local function waterPlants()
    local garden = Utils.getMyGarden()
    if not garden or not garden:FindFirstChild("Plants") then return end
    
    local tool
    local char = Utils.getCharacter()
    local bp = Players.LocalPlayer:FindFirstChild("Backpack")
    
    for _, t in ipairs(char and char:GetChildren() or {}) do if t:GetAttribute("WateringCan") then tool = t break end end
    if not tool then for _, t in ipairs(bp and bp:GetChildren() or {}) do if t:GetAttribute("WateringCan") then tool = t break end end end
    if not tool then return end
    
    local humanoid = char and char:FindFirstChildWhichIsA("Humanoid")
    if humanoid and tool.Parent ~= char then humanoid:EquipTool(tool) task.wait(0.2) end

    for _, plant in ipairs(garden.Plants:GetChildren()) do
        if not isAutoWatering then break end
        local growth = plant:GetAttribute("Growth") or 0
        if growth >= 1 and not Settings.WaterFullyGrown then continue end
        local rootPart = plant:FindFirstChildWhichIsA("BasePart")
        if rootPart then
            Networking.fire("WateringCan.UseWateringCan", rootPart.Position - Vector3.new(0, 0.3, 0), tool.Name, tool)
            task.wait(0.5)
        end
    end
end

-- PLANT (Simplified)
local CollectionService = game:GetService("CollectionService")
local function autoPlantCycle()
    local char = Utils.getCharacter()
    local bp = Players.LocalPlayer:FindFirstChild("Backpack")
    if not char or not bp then return end

    local seedTool
    for _, t in ipairs(bp:GetChildren()) do
        if t:GetAttribute("MainCategory") == "Seed" then
            local sn = t:GetAttribute("SeedTool")
            if not Settings.BlacklistMutated or (not sn:match("^Gold ") and not sn:match("^Rainbow ")) then
                seedTool = t break
            end
        end
    end
    if not seedTool then return end

    local humanoid = char:FindFirstChildWhichIsA("Humanoid")
    if humanoid then pcall(function() humanoid:EquipTool(seedTool) end) task.wait(0.2) end

    local myPlot = Utils.getMyGarden()
    if not myPlot then return end
    
    local spots = {}
    for _, part in ipairs(CollectionService:GetTagged("PlantArea")) do
        if part:IsDescendantOf(myPlot) then
            local size, cf = part.Size, part.CFrame
            local stepsX = math.max(1, math.floor(size.X / Settings.GridSpacing))
            local stepsZ = math.max(1, math.floor(size.Z / Settings.GridSpacing))
            for ix = 0, stepsX do
                for iz = 0, stepsZ do
                    table.insert(spots, cf * Vector3.new(-(size.X/2) + (ix/stepsX)*size.X, size.Y/2, -(size.Z/2) + (iz/stepsZ)*size.Z))
                end
            end
        end
    end

    for _, pos in ipairs(spots) do
        if not isAutoPlanting then break end
        Networking.fire("Plant.PlantSeed", pos, seedTool:GetAttribute("SeedTool"), seedTool)
        task.wait(0.3)
    end
end

-- SELL
local function autoSellCycle()
    Networking.fire("NPCS.SellAll")
end

---------------------------------------------------------------
-- SIMPLE GUI (Draggable Frame)
---------------------------------------------------------------
local CoreGui = game:GetService("CoreGui")
if CoreGui:FindFirstChild("SimpleNexeraUI") then
    CoreGui.SimpleNexeraUI:Destroy()
end

local sg = Instance.new("ScreenGui")
sg.Name = "SimpleNexeraUI"
sg.Parent = CoreGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 160, 0, 180)
frame.Position = UDim2.new(0.05, 0, 0.4, 0)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Parent = sg

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 20)
title.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Text = " Nexera Simple"
title.Font = Enum.Font.Code
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = frame

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 5)
layout.Parent = frame

local spacer = Instance.new("Frame")
spacer.Size = UDim2.new(1, 0, 0, 20)
spacer.BackgroundTransparency = 1
spacer.Parent = frame

local function createToggle(name, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -10, 0, 30)
    btn.Position = UDim2.new(0, 5, 0, 0)
    btn.Text = name .. " [OFF]"
    btn.Font = Enum.Font.SourceSansBold
    btn.TextColor3 = Color3.fromRGB(255, 100, 100)
    btn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    btn.Parent = frame

    local state = false
    btn.MouseButton1Click:Connect(function()
        state = not state
        if state then
            btn.Text = name .. " [ON]"
            btn.TextColor3 = Color3.fromRGB(100, 255, 100)
        else
            btn.Text = name .. " [OFF]"
            btn.TextColor3 = Color3.fromRGB(255, 100, 100)
        end
        callback(state)
    end)
end

createToggle("Auto Harvest", function(state)
    isAutoHarvesting = state
    if state then
        task.spawn(function()
            while isAutoHarvesting and task.wait(Settings.HarvestInterval) do pcall(collectAllFruits) end
        end)
    end
end)

createToggle("Auto Water", function(state)
    isAutoWatering = state
    if state then
        task.spawn(function()
            while isAutoWatering and task.wait(Settings.WaterInterval) do pcall(waterPlants) end
        end)
    end
end)

createToggle("Auto Plant", function(state)
    isAutoPlanting = state
    if state then
        task.spawn(function()
            while isAutoPlanting and task.wait(Settings.PlantInterval) do pcall(autoPlantCycle) end
        end)
    end
end)

createToggle("Auto Sell", function(state)
    isAutoSelling = state
    if state then
        task.spawn(function()
            while isAutoSelling and task.wait(Settings.SellInterval) do pcall(autoSellCycle) end
        end)
    end
end)
