-- Loading a nice interface library called Orion
local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/shlexware/Orion/main/source.lua')))()

-- Creating the main window
local Window = OrionLib:MakeWindow({
    Name = "Grow a Garden 2 | Delta Script", 
    HidePremium = false, 
    SaveConfig = true, 
    ConfigFolder = "GrowAGardenConfig"
})

-- Variables for functions
local AutoFarm = false
local Noclip = false
local InfiniteJump = false

-- Game services
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")

-- Character variables
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")

LocalPlayer.CharacterAdded:Connect(function(char)
    Character = char
    Humanoid = char:WaitForChild("Humanoid")
end)

-- Tab: Home (AutoFarm)
local FarmTab = Window:MakeTab({
    Name = "AutoFarm",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

FarmTab:AddToggle({
    Name = "Auto collect all harvest",
    Default = false,
    Callback = function(Value)
        AutoFarm = Value
        while AutoFarm do
            task.wait(0.5) -- Optimal delay to avoid getting kicked from the game
            
            -- Harvest finding logic (basic algorithm for Grow a Garden)
            -- The script looks for objects with ProximityPrompt or folders containing ready harvests in Workspace
            for _, obj in pairs(workspace:GetDescendants()) do
                if obj:IsA("ProximityPrompt") then
                    -- Check if the prompt relates to collecting (usually contains Harvest, Pick, Collect)
                    if string.find(string.lower(obj.ObjectText), "harvest") or string.find(string.lower(obj.ActionText), "pick") or string.find(string.lower(obj.ActionText), "collect") then
                        if LocalPlayer:DistanceFromCharacter(obj.Parent.Position) < 30 then -- Collection distance
                            fireproximityprompt(obj, 1)
                        end
                    end
                end
            end
        end
    end
})

-- Tab: Player (Character Cheats)
local PlayerTab = Window:MakeTab({
    Name = "Character",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

PlayerTab:AddSlider({
    Name = "Walk Speed (WalkSpeed)",
    Min = 16,
    Max = 150,
    Default = 16,
    Color = Color3.fromRGB(255,255,255),
    Increment = 1,
    ValueName = "Speed",
    Callback = function(Value)
        if Humanoid then Humanoid.WalkSpeed = Value end
    end
})

PlayerTab:AddSlider({
    Name = "Jump Height (JumpPower)",
    Min = 50,
    Max = 300,
    Default = 50,
    Color = Color3.fromRGB(255,255,255),
    Increment = 1,
    ValueName = "Power",
    Callback = function(Value)
        if Humanoid then 
            Humanoid.UseJumpPower = true
            Humanoid.JumpPower = Value 
        end
    end
})

PlayerTab:AddToggle({
    Name = "Noclip (Walking through walls)",
    Default = false,
    Callback = function(Value)
        Noclip = Value
        if Noclip then
            RunService.Stepped:Connect(function()
                if Noclip and Character then
                    for _, part in pairs(Character:GetChildren()) do
                        if part:IsA("BasePart") then
                            part.CanCollide = false
                        end
                    end
                end
            end)
        else
            if Character then
                for _, part in pairs(Character:GetChildren()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = true
                    end
                end
            end
        end
    end
})

PlayerTab:AddToggle({
    Name = "Infinite Jump",
    Default = false,
    Callback = function(Value)
        InfiniteJump = Value
    end
})

-- Infinite jump logic
game:GetService("UserInputService").JumpRequest:Connect(function()
    if InfiniteJump and Humanoid then
        Humanoid:ChangeState("Jumping")
    end
end)

-- Tab: Menu Settings
local SettingsTab = Window:MakeTab({
    Name = "Settings",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

SettingsTab:AddButton({
    Name = "Close cheat (Destroy UI)",
    Callback = function()
        OrionLib:Destroy()
    end
})

-- Initialize the interface
OrionLib:Init()
