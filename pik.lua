-------------------------------------------
----- =======[ MOBILE FISH IT - FIXED ] =======
-------------------------------------------

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-------------------------------------------
----- =======[ MOBILE UI LIBRARY ] =======
-------------------------------------------

local MobileUI = {}
MobileUI.__index = MobileUI

function MobileUI.new()
    local self = setmetatable({}, MobileUI)
    self.elements = {}
    self.open = false
    self:createMainUI()
    return self
end

function MobileUI:createMainUI()
    -- Main Screen GUI
    self.screenGui = Instance.new("ScreenGui")
    self.screenGui.Name = "MobileFishIt"
    self.screenGui.ResetOnSpawn = false
    self.screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    self.screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    
    -- Toggle Button (Floating Action Button)
    self.toggleButton = Instance.new("ImageButton")
    self.toggleButton.Name = "ToggleButton"
    self.toggleButton.Size = UDim2.new(0, 70, 0, 70)
    self.toggleButton.Position = UDim2.new(0.02, 0, 0.8, 0)
    self.toggleButton.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
    self.toggleButton.Image = "rbxassetid://3926305904"
    self.toggleButton.ImageRectOffset = Vector2.new(964, 324)
    self.toggleButton.ImageRectSize = Vector2.new(36, 36)
    self.toggleButton.BackgroundTransparency = 0.1
    self.toggleButton.ZIndex = 10
    
    -- Add shadow effect
    local shadow = Instance.new("UIStroke")
    shadow.Color = Color3.fromRGB(0, 100, 150)
    shadow.Thickness = 3
    shadow.Parent = self.toggleButton
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0.3, 0)
    corner.Parent = self.toggleButton
    
    self.toggleButton.Parent = self.screenGui
    
    -- Main Container
    self.mainContainer = Instance.new("Frame")
    self.mainContainer.Name = "MainContainer"
    self.mainContainer.Size = UDim2.new(0.9, 0, 0.8, 0)
    self.mainContainer.Position = UDim2.new(0.05, 0, 0.1, 0)
    self.mainContainer.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    self.mainContainer.BackgroundTransparency = 0.1
    self.mainContainer.Visible = false
    self.mainContainer.ZIndex = 5
    
    local containerCorner = Instance.new("UICorner")
    containerCorner.CornerRadius = UDim.new(0.04, 0)
    containerCorner.Parent = self.mainContainer
    
    local containerStroke = Instance.new("UIStroke")
    containerStroke.Color = Color3.fromRGB(100, 100, 150)
    containerStroke.Thickness = 2
    containerStroke.Parent = self.mainContainer
    
    self.mainContainer.Parent = self.screenGui
    
    -- Header
    local header = Instance.new("Frame")
    header.Name = "Header"
    header.Size = UDim2.new(1, 0, 0, 60)
    header.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
    header.BorderSizePixel = 0
    
    local headerCorner = Instance.new("UICorner")
    headerCorner.CornerRadius = UDim.new(0.04, 0)
    headerCorner.Parent = header
    
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(0.7, 0, 1, 0)
    title.Position = UDim2.new(0.15, 0, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "🎣 Mobile Fish It"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextScaled = true
    title.Font = Enum.Font.GothamBold
    title.Parent = header
    
    local closeButton = Instance.new("ImageButton")
    closeButton.Name = "CloseButton"
    closeButton.Size = UDim2.new(0, 40, 0, 40)
    closeButton.Position = UDim2.new(0.9, 0, 0.15, 0)
    closeButton.BackgroundTransparency = 1
    closeButton.Image = "rbxassetid://3926305904"
    closeButton.ImageRectOffset = Vector2.new(284, 4)
    closeButton.ImageRectSize = Vector2.new(24, 24)
    closeButton.ImageColor3 = Color3.fromRGB(255, 255, 255)
    closeButton.Parent = header
    
    header.Parent = self.mainContainer
    
    -- Content Scrolling Frame
    self.contentFrame = Instance.new("ScrollingFrame")
    self.contentFrame.Name = "ContentFrame"
    self.contentFrame.Size = UDim2.new(1, 0, 1, -60)
    self.contentFrame.Position = UDim2.new(0, 0, 0, 60)
    self.contentFrame.BackgroundTransparency = 1
    self.contentFrame.ScrollBarThickness = 4
    self.contentFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 150)
    self.contentFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    self.contentFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    
    local uiListLayout = Instance.new("UIListLayout")
    uiListLayout.Padding = UDim.new(0, 10)
    uiListLayout.Parent = self.contentFrame
    
    local padding = Instance.new("UIPadding")
    padding.PaddingTop = UDim.new(0, 10)
    padding.PaddingLeft = UDim.new(0, 10)
    padding.PaddingRight = UDim.new(0, 10)
    padding.Parent = self.contentFrame
    
    self.contentFrame.Parent = self.mainContainer
    
    -- Connect events
    self.toggleButton.MouseButton1Click:Connect(function()
        self:toggleUI()
    end)
    
    closeButton.MouseButton1Click:Connect(function()
        self:toggleUI()
    end)
    
    -- Make toggle button draggable
    self:makeDraggable(self.toggleButton)
end

function MobileUI:makeDraggable(frame)
    local dragging = false
    local dragInput, dragStart, startPos
    
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale, 
                startPos.X.Offset + delta.X,
                startPos.Y.Scale, 
                startPos.Y.Offset + delta.Y
            )
        end
    end)
end

function MobileUI:toggleUI()
    self.open = not self.open
    self.mainContainer.Visible = self.open
    
    if self.open then
        self.mainContainer.Size = UDim2.new(0, 0, 0.8, 0)
        self.mainContainer.Position = UDim2.new(0.5, 0, 0.1, 0)
        
        local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
        local tween = TweenService:Create(self.mainContainer, tweenInfo, {
            Size = UDim2.new(0.9, 0, 0.8, 0),
            Position = UDim2.new(0.05, 0, 0.1, 0)
        })
        tween:Play()
    else
        local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.In)
        local tween = TweenService:Create(self.mainContainer, tweenInfo, {
            Size = UDim2.new(0, 0, 0.8, 0),
            Position = UDim2.new(0.5, 0, 0.1, 0)
        })
        tween:Play()
        
        tween.Completed:Connect(function()
            if not self.open then
                self.mainContainer.Visible = false
            end
        end)
    end
end

function MobileUI:createSection(title)
    local section = Instance.new("Frame")
    section.Name = "Section"
    section.Size = UDim2.new(1, 0, 0, 0)
    section.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    section.BackgroundTransparency = 0.1
    section.AutomaticSize = Enum.AutomaticSize.Y
    
    local sectionCorner = Instance.new("UICorner")
    sectionCorner.CornerRadius = UDim.new(0.03, 0)
    sectionCorner.Parent = section
    
    local sectionStroke = Instance.new("UIStroke")
    sectionStroke.Color = Color3.fromRGB(80, 80, 120)
    sectionStroke.Thickness = 1
    sectionStroke.Parent = section
    
    local sectionLayout = Instance.new("UIListLayout")
    sectionLayout.Padding = UDim.new(0, 8)
    sectionLayout.Parent = section
    
    local sectionPadding = Instance.new("UIPadding")
    sectionPadding.PaddingTop = UDim.new(0, 10)
    sectionPadding.PaddingBottom = UDim.new(0, 10)
    sectionPadding.PaddingLeft = UDim.new(0, 15)
    sectionPadding.PaddingRight = UDim.new(0, 15)
    sectionPadding.Parent = section
    
    -- Section Title
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "Title"
    titleLabel.Size = UDim2.new(1, 0, 0, 25)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.TextScaled = true
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = section
    
    local contentFrame = Instance.new("Frame")
    contentFrame.Name = "Content"
    contentFrame.Size = UDim2.new(1, 0, 0, 0)
    contentFrame.BackgroundTransparency = 1
    contentFrame.AutomaticSize = Enum.AutomaticSize.Y
    
    local contentLayout = Instance.new("UIListLayout")
    contentLayout.Padding = UDim.new(0, 8)
    contentLayout.Parent = contentFrame
    
    contentFrame.Parent = section
    section.Parent = self.contentFrame
    
    return contentFrame
end

function MobileUI:createToggle(options)
    local toggleFrame = Instance.new("Frame")
    toggleFrame.Name = "Toggle"
    toggleFrame.Size = UDim2.new(1, 0, 0, 50)
    toggleFrame.BackgroundTransparency = 1
    
    local toggleButton = Instance.new("TextButton")
    toggleButton.Name = "ToggleButton"
    toggleButton.Size = UDim2.new(1, 0, 1, 0)
    toggleButton.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
    toggleButton.AutoButtonColor = false
    toggleButton.Text = ""
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0.03, 0)
    corner.Parent = toggleButton
    
    -- Toggle Content
    local contentLayout = Instance.new("UIListLayout")
    contentLayout.FillDirection = Enum.FillDirection.Horizontal
    contentLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    contentLayout.Padding = UDim.new(0, 15)
    contentLayout.Parent = toggleButton
    
    local padding = Instance.new("UIPadding")
    padding.PaddingLeft = UDim.new(0, 15)
    padding.PaddingRight = UDim.new(0, 15)
    padding.Parent = toggleButton
    
    -- Icon
    local icon = Instance.new("ImageLabel")
    icon.Name = "Icon"
    icon.Size = UDim2.new(0, 25, 0, 25)
    icon.BackgroundTransparency = 1
    icon.Image = options.Icon or "rbxassetid://3926305904"
    icon.ImageRectOffset = options.IconRectOffset or Vector2.new(964, 324)
    icon.ImageRectSize = options.IconRectSize or Vector2.new(36, 36)
    icon.ImageColor3 = Color3.fromRGB(200, 200, 200)
    icon.Parent = toggleButton
    
    -- Text
    local textFrame = Instance.new("Frame")
    textFrame.Name = "TextFrame"
    textFrame.Size = UDim2.new(0.7, 0, 1, 0)
    textFrame.BackgroundTransparency = 1
    
    local textLayout = Instance.new("UIListLayout")
    textLayout.Parent = textFrame
    
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, 0, 0, 25)
    title.BackgroundTransparency = 1
    title.Text = options.Title
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextScaled = true
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = textFrame
    
    if options.Content then
        local content = Instance.new("TextLabel")
        content.Name = "Content"
        content.Size = UDim2.new(1, 0, 0, 20)
        content.BackgroundTransparency = 1
        content.Text = options.Content
        content.TextColor3 = Color3.fromRGB(180, 180, 180)
        content.TextScaled = true
        content.Font = Enum.Font.Gotham
        content.TextXAlignment = Enum.TextXAlignment.Left
        content.Parent = textFrame
    end
    
    textFrame.Parent = toggleButton
    
    -- Toggle Switch
    local switchFrame = Instance.new("Frame")
    switchFrame.Name = "Switch"
    switchFrame.Size = UDim2.new(0, 50, 0, 25)
    switchFrame.BackgroundColor3 = Color3.fromRGB(80, 80, 100)
    
    local switchCorner = Instance.new("UICorner")
    switchCorner.CornerRadius = UDim.new(0.5, 0)
    switchCorner.Parent = switchFrame
    
    local toggleCircle = Instance.new("Frame")
    toggleCircle.Name = "Circle"
    toggleCircle.Size = UDim2.new(0, 20, 0, 20)
    toggleCircle.Position = UDim2.new(0.05, 0, 0.1, 0)
    toggleCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    toggleCircle.BorderSizePixel = 0
    
    local circleCorner = Instance.new("UICorner")
    circleCorner.CornerRadius = UDim.new(0.5, 0)
    circleCorner.Parent = toggleCircle
    
    toggleCircle.Parent = switchFrame
    switchFrame.Parent = toggleButton
    
    toggleButton.Parent = toggleFrame
    toggleFrame.Parent = options.Parent
    
    -- State management
    local isToggled = options.Value or false
    local function updateToggle()
        if isToggled then
            switchFrame.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
            local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
            local tween = TweenService:Create(toggleCircle, tweenInfo, {
                Position = UDim2.new(0.5, 0, 0.1, 0)
            })
            tween:Play()
        else
            switchFrame.BackgroundColor3 = Color3.fromRGB(80, 80, 100)
            local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
            local tween = TweenService:Create(toggleCircle, tweenInfo, {
                Position = UDim2.new(0.05, 0, 0.1, 0)
            })
            tween:Play()
        end
    end
    
    updateToggle()
    
    -- Click event
    toggleButton.MouseButton1Click:Connect(function()
        isToggled = not isToggled
        updateToggle()
        if options.Callback then
            options.Callback(isToggled)
        end
    end)
    
    return {
        Set = function(value)
            isToggled = value
            updateToggle()
        end,
        Get = function()
            return isToggled
        end
    }
end

-------------------------------------------
----- =======[ AUTO FISHING SYSTEM - FIXED ] =======
-------------------------------------------

local AutoFishSystem = {}
AutoFishSystem.__index = AutoFishSystem

function AutoFishSystem.new()
    local self = setmetatable({}, AutoFishSystem)
    
    -- Game services
    self.ReplicatedStorage = game:GetService("ReplicatedStorage")
    self.Players = game:GetService("Players")
    self.LocalPlayer = self.Players.LocalPlayer
    
    -- Net references
    self.net = self.ReplicatedStorage:WaitForChild("Packages")
        :WaitForChild("_Index")
        :WaitForChild("sleitnick_net@0.2.0")
        :WaitForChild("net")
    
    -- Remotes
    self.rodRemote = self.net:WaitForChild("RF/ChargeFishingRod")
    self.miniGameRemote = self.net:WaitForChild("RF/RequestFishingMinigameStarted")
    self.finishRemote = self.net:WaitForChild("RE/FishingCompleted")
    self.textEffectRemote = self.net:WaitForChild("RE/ReplicateTextEffect")
    
    -- Auto fish state
    self.isAutoFishing = false
    self.isFishingActive = false
    self.perfectCast = true
    self.customDelay = 1.12
    self.bypassDelay = 1.45
    
    -- Animation references
    self.rodShakeAnim = nil
    self.rodIdleAnim = nil
    self.rodReelAnim = nil
    
    -- Setup text effect listener
    self:setupTextEffectListener()
    
    -- Setup animations when character loads
    self:setupCharacterAnimations()
    
    return self
end

function AutoFishSystem:setupCharacterAnimations()
    -- Wait for character to load
    local character = self.LocalPlayer.Character
    if character then
        self:loadAnimations(character)
    else
        self.LocalPlayer.CharacterAdded:Connect(function(char)
            self:loadAnimations(char)
        end)
    end
end

function AutoFishSystem:loadAnimations(character)
    task.wait(1) -- Wait for character to fully load
    
    local humanoid = character:WaitForChild("Humanoid")
    local animator = humanoid:FindFirstChildOfClass("Animator") or Instance.new("Animator", humanoid)
    
    local animationsFolder = self.ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Animations")
    
    -- Load animations with error handling
    pcall(function()
        local rodShake = animationsFolder:WaitForChild("CastFromFullChargePosition1Hand")
        local rodIdle = animationsFolder:WaitForChild("FishingRodReelIdle")
        local rodReel = animationsFolder:WaitForChild("EasyFishReelStart")
        
        self.rodShakeAnim = animator:LoadAnimation(rodShake)
        self.rodIdleAnim = animator:LoadAnimation(rodIdle)
        self.rodReelAnim = animator:LoadAnimation(rodReel)
        
        print("✅ Animations loaded successfully!")
    end)
end

function AutoFishSystem:setupTextEffectListener()
    self.textEffectRemote.OnClientEvent:Connect(function(data)
        if self.isAutoFishing and self.isFishingActive and data and data.TextData and data.TextData.EffectType == "Exclaim" then
            local myHead = self.LocalPlayer.Character and self.LocalPlayer.Character:FindFirstChild("Head")
            if myHead and data.Container == myHead then
                self:handleFishCaught()
            end
        end
    end)
end

function AutoFishSystem:handleFishCaught()
    task.spawn(function()
        for i = 1, 3 do
            task.wait(self.bypassDelay)
            pcall(function()
                self.finishRemote:FireServer()
            end)
        end
    end)
end

function AutoFishSystem:startAutoFishing()
    if self.isAutoFishing then 
        self:showNotification("Auto Fishing", "Already running!", Color3.fromRGB(255, 255, 0))
        return 
    end
    
    self.isAutoFishing = true
    self:showNotification("Auto Fishing", "Started successfully! 🎣", Color3.fromRGB(0, 255, 0))
    
    task.spawn(function()
        while self.isAutoFishing do
            pcall(function()
                self.isFishingActive = true

                -- Equip fishing rod (slot 1)
                local equipRemote = self.net:WaitForChild("RE/EquipToolFromHotbar")
                equipRemote:FireServer(1)
                task.wait(0.2)

                -- Charge fishing rod
                local timestamp = workspace:GetServerTimeNow()
                self.rodRemote:InvokeServer(timestamp)
                task.wait(0.3)

                -- Play shake animation if available
                if self.rodShakeAnim then
                    self.rodShakeAnim:Play()
                end

                -- Calculate cast position
                local baseX, baseY = -0.7499996423721313, 1
                local x, y
                
                if self.perfectCast then
                    -- Perfect cast coordinates
                    x = baseX + (math.random(-500, 500) / 10000000)
                    y = baseY + (math.random(-500, 500) / 10000000)
                else
                    -- Random cast
                    x = math.random(-1000, 1000) / 1000
                    y = math.random(0, 1000) / 1000
                end

                -- Play idle animation if available
                if self.rodIdleAnim then
                    self.rodIdleAnim:Play()
                end

                -- Start fishing minigame
                self.miniGameRemote:InvokeServer(x, y)

                -- Wait for fish
                task.wait(self.customDelay)
                self.isFishingActive = false
                
                -- Small random delay between cycles
                task.wait(math.random(0.1, 0.3))
            end)
        end
    end)
end

function AutoFishSystem:stopAutoFishing()
    if not self.isAutoFishing then return end
    
    self.isAutoFishing = false
    self.isFishingActive = false
    
    -- Stop animations
    if self.rodIdleAnim then
        self.rodIdleAnim:Stop()
    end
    if self.rodShakeAnim then
        self.rodShakeAnim:Stop()
    end
    if self.rodReelAnim then
        self.rodReelAnim:Stop()
    end
    
    self:showNotification("Auto Fishing", "Stopped! ⏹️", Color3.fromRGB(255, 100, 100))
end

function AutoFishSystem:setPerfectCast(value)
    self.perfectCast = value
    if value then
        self:showNotification("Perfect Cast", "Enabled! 🎯", Color3.fromRGB(0, 255, 0))
    else
        self:showNotification("Perfect Cast", "Disabled!", Color3.fromRGB(255, 100, 100))
    end
end

function AutoFishSystem:setDelays(customDelay, bypassDelay)
    if customDelay then
        self.customDelay = customDelay
        self:showNotification("Custom Delay", "Set to " .. customDelay .. "s", Color3.fromRGB(0, 200, 255))
    end
    if bypassDelay then
        self.bypassDelay = bypassDelay
        self:showNotification("Bypass Delay", "Set to " .. bypassDelay .. "s", Color3.fromRGB(0, 200, 255))
    end
end

function AutoFishSystem:showNotification(title, message, color)
    -- Create notification
    local notify = Instance.new("Frame")
    notify.Name = "Notification"
    notify.Size = UDim2.new(0.8, 0, 0, 70)
    notify.Position = UDim2.new(0.1, 0, 0.05, 0)
    notify.BackgroundColor3 = color or Color3.fromRGB(0, 150, 100)
    notify.ZIndex = 20
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0.03, 0)
    corner.Parent = notify
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(0, 0, 0)
    stroke.Thickness = 2
    stroke.Parent = notify
    
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 5)
    layout.Parent = notify
    
    local padding = Instance.new("UIPadding")
    padding.PaddingTop = UDim.new(0, 8)
    padding.PaddingLeft = UDim.new(0, 10)
    padding.PaddingRight = UDim.new(0, 10)
    padding.Parent = notify
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, 0, 0, 25)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.TextScaled = true
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.Parent = notify
    
    local messageLabel = Instance.new("TextLabel")
    messageLabel.Size = UDim2.new(1, 0, 0, 25)
    messageLabel.BackgroundTransparency = 1
    messageLabel.Text = message
    messageLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    messageLabel.TextScaled = true
    messageLabel.Font = Enum.Font.Gotham
    messageLabel.Parent = notify
    
    notify.Parent = game:GetService("CoreGui") or LocalPlayer:WaitForChild("PlayerGui")
    
    -- Auto-hide notification
    task.spawn(function()
        task.wait(3)
        
        local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        local tween = TweenService:Create(notify, tweenInfo, {
            Position = UDim2.new(0.1, 0, -0.1, 0)
        })
        tween:Play()
        
        tween.Completed:Connect(function()
            notify:Destroy()
        end)
    end)
end

-------------------------------------------
----- =======[ MAIN EXECUTION - FIXED ] =======
-------------------------------------------

-- Initialize Mobile UI
local mobileUI = MobileUI.new()

-- Initialize Auto Fish System
local autoFishSystem = AutoFishSystem.new()

-- Wait a bit for everything to load
task.wait(2)

-- Create Auto Fishing Section
local autoFishSection = mobileUI:createSection("🎣 AUTO FISHING")

-- Auto Fish Toggle
local autoFishToggle = mobileUI:createToggle({
    Parent = autoFishSection,
    Title = "AUTO FISHING",
    Content = "Automatically catch fish continuously",
    Icon = "rbxassetid://3926305904",
    IconRectOffset = Vector2.new(964, 324),
    IconRectSize = Vector2.new(36, 36),
    Value = false,
    Callback = function(value)
        if value then
            autoFishSystem:startAutoFishing()
        else
            autoFishSystem:stopAutoFishing()
        end
    end
})

-- Perfect Cast Toggle
local perfectCastToggle = mobileUI:createToggle({
    Parent = autoFishSection,
    Title = "PERFECT CAST",
    Content = "Always achieve perfect casting accuracy",
    Icon = "rbxassetid://3926305904", 
    IconRectOffset = Vector2.new(324, 964),
    IconRectSize = Vector2.new(36, 36),
    Value = true,
    Callback = function(value)
        autoFishSystem:setPerfectCast(value)
    end
})

-- Status Section
local statusSection = mobileUI:createSection("📊 STATUS")

-- Status labels with better visibility
local fishingStatus = Instance.new("TextLabel")
fishingStatus.Name = "FishingStatus"
fishingStatus.Size = UDim2.new(1, 0, 0, 30)
fishingStatus.BackgroundTransparency = 1
fishingStatus.Text = "🟥 AUTO FISHING: OFF"
fishingStatus.TextColor3 = Color3.fromRGB(255, 100, 100)
fishingStatus.TextScaled = true
fishingStatus.Font = Enum.Font.GothamBold
fishingStatus.TextXAlignment = Enum.TextXAlignment.Left
fishingStatus.Parent = statusSection

local castStatus = Instance.new("TextLabel")
castStatus.Name = "CastStatus"
castStatus.Size = UDim2.new(1, 0, 0, 30)
castStatus.BackgroundTransparency = 1
castStatus.Text = "🟩 PERFECT CAST: ON"
castStatus.TextColor3 = Color3.fromRGB(100, 255, 100)
castStatus.TextScaled = true
castStatus.Font = Enum.Font.GothamBold
castStatus.TextXAlignment = Enum.TextXAlignment.Left
castStatus.Parent = statusSection

local activityStatus = Instance.new("TextLabel")
activityStatus.Name = "ActivityStatus"
activityStatus.Size = UDim2.new(1, 0, 0, 25)
activityStatus.BackgroundTransparency = 1
activityStatus.Text = "Current: Idle"
activityStatus.TextColor3 = Color3.fromRGB(200, 200, 200)
activityStatus.TextScaled = true
activityStatus.Font = Enum.Font.Gotham
activityStatus.TextXAlignment = Enum.TextXAlignment.Left
activityStatus.Parent = statusSection

-- Update status in real-time
RunService.Heartbeat:Connect(function()
    -- Update fishing status
    if autoFishSystem.isAutoFishing then
        fishingStatus.Text = "🟢 AUTO FISHING: ON"
        fishingStatus.TextColor3 = Color3.fromRGB(100, 255, 100)
    else
        fishingStatus.Text = "🔴 AUTO FISHING: OFF" 
        fishingStatus.TextColor3 = Color3.fromRGB(255, 100, 100)
    end
    
    -- Update cast status
    if autoFishSystem.perfectCast then
        castStatus.Text = "🎯 PERFECT CAST: ON"
        castStatus.TextColor3 = Color3.fromRGB(100, 255, 100)
    else
        castStatus.Text = "🎯 PERFECT CAST: OFF"
        castStatus.TextColor3 = Color3.fromRGB(255, 100, 100)
    end
    
    -- Update activity status
    if autoFishSystem.isFishingActive then
        activityStatus.Text = "Current: Fishing... 🎣"
        activityStatus.TextColor3 = Color3.fromRGB(255, 255, 100)
    elseif autoFishSystem.isAutoFishing then
        activityStatus.Text = "Current: Waiting ⏳"
        activityStatus.TextColor3 = Color3.fromRGB(200, 200, 255)
    else
        activityStatus.Text = "Current: Idle"
        activityStatus.TextColor3 = Color3.fromRGB(200, 200, 200)
    end
end)

-- Delay Settings Section
local delaySection = mobileUI:createSection("⏱️ DELAY SETTINGS")

-- Delay information
local delayInfo = Instance.new("TextLabel")
delayInfo.Name = "DelayInfo"
delayInfo.Size = UDim2.new(1, 0, 0, 50)
delayInfo.BackgroundTransparency = 1
delayInfo.Text = "Default delays work for most rods. Adjust if fishing fails."
delayInfo.TextColor3 = Color3.fromRGB(180, 180, 180)
delayInfo.TextScaled = true
delayInfo.Font = Enum.Font.Gotham
delayInfo.TextWrapped = true
delayInfo.Parent = delaySection

-- Current delays display
local currentDelays = Instance.new("TextLabel")
currentDelays.Name = "CurrentDelays"
currentDelays.Size = UDim2.new(1, 0, 0, 30)
currentDelays.BackgroundTransparency = 1
currentDelays.Text = "Custom: " .. autoFishSystem.customDelay .. "s | Bypass: " .. autoFishSystem.bypassDelay .. "s"
currentDelays.TextColor3 = Color3.fromRGB(0, 200, 255)
currentDelays.TextScaled = true
currentDelays.Font = Enum.Font.GothamBold
currentDelays.Parent = delaySection

-- Info Section
local infoSection = mobileUI:createSection("ℹ️ INFORMATION")

local infoText = Instance.new("TextLabel")
infoText.Name = "InfoText"
infoText.Size = UDim2.new(1, 0, 0, 80)
infoText.BackgroundTransparency = 1
infoText.Text = "🎣 MOBILE FISH IT v2.0\n\n• Tap the fishing icon to open/close\n• Enable Auto Fishing to start\n• Perfect Cast recommended for best results"
infoText.TextColor3 = Color3.fromRGB(200, 200, 255)
infoText.TextScaled = true
infoText.Font = Enum.Font.Gotham
infoText.TextWrapped = true
infoText.Parent = infoSection

-- Initial notification
task.spawn(function()
    task.wait(1)
    autoFishSystem:showNotification(
        "Mobile Fish It", 
        "Loaded successfully! 🎣\nTap the fishing icon to start", 
        Color3.fromRGB(0, 150, 255)
    )
end)

print("🎣 Mobile Fish It v2.0 loaded successfully!")
print("📱 Optimized for mobile devices")
print("🎯 Features: Auto Fishing, Perfect Cast, Real-time Status")
print("⚡ Ready to fish!")

-- Anti-AFK for mobile
local VirtualUser = game:GetService("VirtualUser")
LocalPlayer.Idled:Connect(function()
    VirtualUser:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    task.wait(1)
    VirtualUser:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
end)