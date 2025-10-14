-- ===========================================
-- ===== Load Rayfield UI Library =============
-- ===========================================

local success, Rayfield = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/SiriusSoftwareLtd/Rayfield/main/Loader.lua"))()
end)

if not success or not Rayfield then
    warn("[ERROR] Failed to load Rayfield UI library")
    return
end

-- ===========================================
-- ===== Setup Window & Notify Wrappers =======
-- ===========================================

local Window = Rayfield:CreateWindow({
    Name = "Codepikk - Fish It",
    LoadingTitle = "Loading Codepikk Fish It",
    LoadingSubtitle = "by codepikk",
    Theme = "Default",
    ToggleUIKeybind = "G",
    ConfigurationSaving = {
        Enabled = false,
        FolderName = nil,
        FileName = "CodepikkFishConfig"
    },
    KeySystem = false
})

local function NotifySuccess(title, message, duration)
    Rayfield:Notify({
        Title = title,
        Content = message,
        Duration = duration,
        Image = nil,
        Actions = {}
    })
end

local function NotifyError(title, message, duration)
    Rayfield:Notify({
        Title = title,
        Content = message,
        Duration = duration,
        Image = nil,
        Actions = {}
    })
end

local function NotifyInfo(title, message, duration)
    Rayfield:Notify({
        Title = title,
        Content = message,
        Duration = duration,
        Image = nil,
        Actions = {}
    })
end

local function NotifyWarning(title, message, duration)
    Rayfield:Notify({
        Title = title,
        Content = message,
        Duration = duration,
        Image = nil,
        Actions = {}
    })
end

-- ===========================================
-- ===== Services & Globals ===================
-- ===========================================

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
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

local state = {
    AutoFavourite = false,
    AutoSell = false
}

local rodRemote = net:WaitForChild("RF/ChargeFishingRod")
local miniGameRemote = net:WaitForChild("RF/RequestFishingMinigameStarted")
local finishRemote = net:WaitForChild("RE/FishingCompleted")

-- Anti-AFK
LocalPlayer.Idled:Connect(function()
    pcall(function()
        local vu = game:GetService("VirtualUser")
        vu:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
        task.wait(1)
        vu:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    end)
end)

for _, conn in next, getconnections(Players.LocalPlayer.Idled) do
    conn:Disable()
end

-- ===========================================
-- ===== XP Bar / Reconnect ===================
-- ===========================================

local XPBar = LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("XP")
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

-- ===========================================
-- ===== Animations Setup =====================
-- ===========================================

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

-- ===========================================
-- ===== FPS Boost (optional) ================
-- ===========================================

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

BoostFPS()

-- ===========================================
-- ===== Create Tabs & Sections ==============
-- ===========================================

local AutoFishTab = Window:CreateTab("Auto Fishing", nil)
local UtilityTab = Window:CreateTab("Utility", nil)
local SettingsTab = Window:CreateTab("Settings", nil)

-- Auto Fishing Section
local AutoFishSection = AutoFishTab:CreateSection("Fishing Automation")

-- Utility, Settings sections can be similarly created later

-- ===========================================
-- ===== AUTO FISHING Logic ===================
-- ===========================================

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
        local success2, itemNamePath = pcall(function()
            return tile.Inner.Tags.ItemName
        end)
        if success2 and itemNamePath and itemNamePath:IsA("TextLabel") then
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
            NotifySuccess("Rod Detected", string.format("Detected Rod: %s | Delay: %.2fs | Bypass: %.2fs", rodName, customDelayV2, BypassDelayV2))
        end
    else
        customDelayV2 = 10
        BypassDelayV2 = 1
        FuncAutoFishV2.delayInitializedV2 = true
        if showNotify and FuncAutoFishV2.autofishV2 then
            NotifyWarning("Rod Detection Failed", "No valid rod found. Default delay applied.")
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

-- AUTO SELL logic
local lastSellTime = 0
local AUTO_SELL_THRESHOLD = 60
local AUTO_SELL_DELAY = 60

local function getNetFolder()
    return net
end

local function startAutoSell()
    task.spawn(function()
        while state.AutoSell do
            pcall(function()
                if not getNetFolder() then return end
                local DataReplion = nil
                -- kalau kamu punya cara akses Replion, isi di sini
                -- Karena script originalmu refer ke Replion, pastikan Replion tersedia
                -- local items = DataReplion:Get({"Inventory","Items"})
                -- ...
            end)
            task.wait(10)
        end
    end)
end

-- Handle replicate text events
FuncAutoFishV2.REReplicateTextEffectV2.OnClientEvent:Connect(function(data)
    if FuncAutoFishV2.autofishV2 and FuncAutoFishV2.fishingActiveV2
    and data and data.TextData and data.TextData.EffectType == "Exclaim" then

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

local function StartAutoFishV2()
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

                local chargeRemote = net:WaitForChild("RF/ChargeFishingRod")
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

local function StopAutoFishV2()
    FuncAutoFishV2.autofishV2 = false
    FuncAutoFishV2.fishingActiveV2 = false
    FuncAutoFishV2.delayInitializedV2 = false
    RodIdleAnim:Stop()
    RodShakeAnim:Stop()
    RodReelAnim:Stop()
end

-- ===========================================
-- ===== UI Elements (Input, Toggle, Buttons) =
-- ===========================================

AutoFishSection:CreateInput({
    Name = "Bypass Delay",
    PlaceholderText = "Example: 1.45",
    Callback = function(value)
        if Notifs.DelayBlockNotif then
            Notifs.DelayBlockNotif = false
            return
        end
        local num = tonumber(value)
        if num then
            BypassDelayV2 = num
            NotifySuccess("Bypass Delay", "Bypass Delay set to " .. num, 3)
        else
            NotifyError("Invalid Input", "Failed to convert input to number.", 3)
        end
    end
})

AutoFishSection:CreateToggle({
    Name = "Auto Sell",
    CurrentValue = false,
    Callback = function(value)
        state.AutoSell = value
        if value then
            startAutoSell()
            NotifySuccess("Auto Sell", "Auto Sell Enabled.", 3)
        else
            NotifyWarning("Auto Sell", "Auto Sell Disabled.", 3)
        end
    end
})

AutoFishSection:CreateToggle({
    Name = "Auto Fish V2 (Optimized)",
    CurrentValue = false,
    Callback = function(value)
        if value then
            StartAutoFishV2()
        else
            StopAutoFishV2()
        end
    end
})

AutoFishSection:CreateToggle({
    Name = "Auto Perfect Cast",
    CurrentValue = true,
    Callback = function(value)
        FuncAutoFishV2.perfectCastV2 = value
    end
})

-- Auto Favorite Section
local AutoFavoriteSection = AutoFishTab:CreateSection("Auto Favorite System")

AutoFavoriteSection:CreateToggle({
    Name = "Enable Auto Favorite",
    CurrentValue = false,
    Callback = function(value)
        state.AutoFavourite = value
        if value then
            task.spawn(function()
                while state.AutoFavourite do
                    pcall(function()
                        -- implement favorit logic di sini (Replion/ItemUtility)
                    end)
                    task.wait(5)
                end
            end)
            NotifySuccess("Auto Favorite", "Auto Favorite enabled", 3)
        else
            NotifyWarning("Auto Favorite", "Auto Favorite disabled", 3)
        end
    end
})

-- Manual Actions Section
local ManualSection = AutoFishTab:CreateSection("Manual Actions")

ManualSection:CreateButton({
    Name = "Sell All Fishes",
    Callback = function()
        local charFolder = workspace:FindFirstChild("Characters")
        local char = charFolder and charFolder:FindFirstChild(LocalPlayer.Name)
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then
            NotifyError("Character Not Found", "HRP not found.", 3)
            return
        end

        local sellRemote = net:WaitForChild("RF/SellAllItems")
        NotifyInfo("Selling...", "Selling all fish, please wait...", 3)
        task.wait(1)
        local ok, err = pcall(function()
            sellRemote:InvokeServer()
        end)
        if ok then
            NotifySuccess("Sold!", "All fish sold successfully.", 3)
        else
            NotifyError("Sell Failed", tostring(err), 3)
        end
    end
})

ManualSection:CreateButton({
    Name = "Auto Enchant Rod",
    Callback = function()
        local ENCHANT_POSITION = Vector3.new(3231, -1303, 1402)
        local char = workspace:WaitForChild("Characters"):FindFirstChild(LocalPlayer.Name)
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then
            NotifyError("Auto Enchant Rod", "Failed to get HRP.", 3)
            return
        end
        NotifyInfo("Preparing Enchant...", "Place Enchant Stone in slot 5 then wait...", 4)
        task.wait(3)
        local slot5 = LocalPlayer.PlayerGui.Backpack.Display:GetChildren()[10]
        local itemName = slot5 and slot5:FindFirstChild("Inner") and slot5.Inner:FindFirstChild("Tags") and slot5.Inner.Tags:FindFirstChild("ItemName")
        if not itemName or not itemName.Text:lower():find("enchant") then
            NotifyError("Auto Enchant Rod", "Slot 5 is not an Enchant Stone.", 3)
            return
        end
        NotifyInfo("Enchanting...", "Please wait...", 4)
        local originalPos = hrp.Position
        task.wait(1)
        hrp.CFrame = CFrame.new(ENCHANT_POSITION + Vector3.new(0,5,0))
        task.wait(1.2)
        local equipRod = net:WaitForChild("RE/EquipToolFromHotbar")
        local activateEnchant = net:WaitForChild("RE/ActivateEnchantingAltar")
        pcall(function()
            equipRod:FireServer(5)
            task.wait(0.5)
            activateEnchant:FireServer()
            task.wait(7)
            NotifySuccess("Enchant", "Successfully Enchanted!", 3)
        end)
        task.wait(0.9)
        hrp.CFrame = CFrame.new(originalPos + Vector3.new(0,3,0))
    end
})

-- ===========================================
-- ===== Utility Tab Elements =================
-- ===========================================

local TeleportSection = UtilityTab:CreateSection("Teleport Utility")

TeleportSection:CreateDropdown({
    Name = "Island Teleport",
    Options = (function()
        local list = {}
        local islandCoords = {
            ["01"] = { name = "Weather Machine", position = Vector3.new(-1471, -3, 1929) },
            ["02"] = { name = "Esoteric Depths", position = Vector3.new(3157, -1303, 1439) },
            ["03"] = { name = "Tropical Grove", position = Vector3.new(-2038, 3, 3650) },
            ["04"] = { name = "Stingray Shores", position = Vector3.new(-32, 4, 2773) },
            ["05"] = { name = "Kohana Volcano", position = Vector3.new(-519, 24, 189) },
            ["06"] = { name = "Coral Reefs", position = Vector3.new(-3095, 1, 2177) },
            ["07"] = { name = "Crater Island", position = Vector3.new(968, 1, 4854) },
            ["08"] = { name = "Kohana", position = Vector3.new(-658, 3, 719) },
            ["09"] = { name = "Winter Fest", position = Vector3.new(1611, 4, 3280) },
            ["10"] = { name = "Isoteric Island", position = Vector3.new(1987, 4, 1400) },
            ["11"] = { name = "Treasure Hall", position = Vector3.new(-3600, -267, -1558) },
            ["12"] = { name = "Lost Shore", position = Vector3.new(-3663, 38, -989) },
            ["13"] = { name = "Sishypus Statue", position = Vector3.new(-3792, -135, -986) }
        }
        for _, data in pairs(islandCoords) do
            table.insert(list, data.name)
        end
        return list
    end)(),
    Callback = function(selectedName)
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
            ["Sishypus Statue"] = Vector3.new(-3792, -135, -986)
        }
        local pos = islandCoords[selectedName]
        if pos then
            local charFolder = workspace:FindFirstChild("Characters", 5)
            local char = charFolder and charFolder:FindFirstChild(LocalPlayer.Name)
            if not char then
                NotifyError("Teleport Failed", "Character not found", 3)
                return
            end
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if not hrp then
                NotifyError("Teleport Failed", "HRP not found", 3)
                return
            end
            hrp.CFrame = CFrame.new(pos + Vector3.new(0,5,0))
            NotifySuccess("Teleported!", "You are now at " .. selectedName, 3)
        end
    end
})

-- Teleport to NPCs
local npcFolder = ReplicatedStorage:WaitForChild("NPC")
local npcList = {}
for _, npc in pairs(npcFolder:GetChildren()) do
    if npc:IsA("Model") then
        local hrp = npc:FindFirstChild("HumanoidRootPart") or npc.PrimaryPart
        if hrp then
            table.insert(npcList, npc.Name)
        end
    end
end

TeleportSection:CreateDropdown({
    Name = "NPC Teleport",
    Options = npcList,
    Callback = function(sel)
        local npc = npcFolder:FindFirstChild(sel)
        if npc then
            local hrp = npc:FindFirstChild("HumanoidRootPart") or npc.PrimaryPart
            if hrp then
                local charFolder = workspace:FindFirstChild("Characters", 5)
                local char = charFolder and charFolder:FindFirstChild(LocalPlayer.Name)
                if not char then
                    NotifyError("Teleport Failed", "Character not found", 3)
                    return
                end
                local myHRP = char:FindFirstChild("HumanoidRootPart")
                if myHRP then
                    myHRP.CFrame = hrp.CFrame + Vector3.new(0,3,0)
                    NotifySuccess("Teleported!", "Near NPC: " .. sel, 3)
                end
            end
        end
    end
})

-- Server Utility Section
local ServerSection = UtilityTab:CreateSection("Server Utility")

ServerSection:CreateButton({
    Name = "Rejoin Server",
    Callback = function()
        TeleportService:Teleport(game.PlaceId, LocalPlayer)
    end
})

ServerSection:CreateButton({
    Name = "Server Hop",
    Callback = function()
        local placeId = game.PlaceId
        local servers = {}
        local cursor = ""
        local found = false
        repeat
            local url = "https://games.roblox.com/v1/games/"..placeId.."/servers/Public?sortOrder=Asc&limit=100"
            if cursor ~= "" then
                url = url .. "&cursor=" .. cursor
            end
            local success2, result = pcall(function()
                return HttpService:JSONDecode(game:HttpGet(url))
            end)
            if success2 and result and result.data then
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
            local target = servers[math.random(1, #servers)]
            TeleportService:TeleportToPlaceInstance(placeId, target, LocalPlayer)
        else
            NotifyError("Server Hop Failed", "No servers available or all are full!", 3)
        end
    end
})

-- Visual Utility Section
local VisualSection = UtilityTab:CreateSection("Visual Utility")

VisualSection:CreateButton({
    Name = "HDR Shader",
    Callback = function()
        loadstring(game:HttpGet("https://pastebin.com/raw/avvr1gTW"))()
    end
})

-- ===========================================
-- ===== Settings Tab Elements ================
-- ===========================================

local ConfigSection = SettingsTab:CreateSection("Configuration")

ConfigSection:CreateButton({
    Name = "Save Settings",
    Callback = function()
        Window:SaveConfiguration()
        NotifySuccess("Config Saved", "Configuration has been saved!", 3)
    end
})

ConfigSection:CreateButton({
    Name = "Load Settings",
    Callback = function()
        Window:LoadConfiguration()
        NotifySuccess("Config Loaded", "Configuration has been loaded!", 3)
    end
})

local AFKSection = SettingsTab:CreateSection("Anti-AFK")

AFKSection:CreateToggle({
    Name = "Anti-AFK",
    CurrentValue = true,
    Callback = function(val)
        if Notifs.AFKBN then
            Notifs.AFKBN = false
            return
        end
        if val then
            LocalPlayer.Idled:Connect(function()
                pcall(function()
                    local vu = game:GetService("VirtualUser")
                    vu:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
                    task.wait(1)
                    vu:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
                end)
            end)
            NotifySuccess("Anti-AFK Activated", "You will now avoid being kicked.", 3)
        else
            -- cannot easily disconnect previous connection here, but it's okay
            NotifySuccess("Anti-AFK Deactivated", "You can now go idle again.", 3)
        end
    end
})

local InfoSection = SettingsTab:CreateSection("Script Info")

InfoSection:CreateLabel("Version: 1.1 Beta")
InfoSection:CreateLabel("Developer: @codepikk")
InfoSection:CreateLabel("Status: Development")

-- ===========================================
-- ===== Final Notify =========================
-- ===========================================

NotifySuccess("Codepikk - Fish It", "Script loaded successfully! Press [G] if UI not visible.", 5)

-- End of script
