-------------------------------------------
----- =======[ CUSTOM UI SYSTEM ] =======
-------------------------------------------

local CustomUI = {}
CustomUI.__index = CustomUI

-- Services
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- Colors
CustomUI.Themes = {
    Indigo = {
        Primary = Color3.fromRGB(79, 70, 229),
        Secondary = Color3.fromRGB(99, 102, 241),
        Background = Color3.fromRGB(23, 23, 23),
        Surface = Color3.fromRGB(38, 38, 38),
        Text = Color3.fromRGB(255, 255, 255),
        TextSecondary = Color3.fromRGB(156, 163, 175),
        Success = Color3.fromRGB(34, 197, 94),
        Warning = Color3.fromRGB(234, 179, 8),
        Error = Color3.fromRGB(239, 68, 68)
    }
}

function CustomUI:CreateWindow(config)
    local window = {}
    setmetatable(window, CustomUI)
    
    window.Title = config.Title or "Custom UI"
    window.Icon = config.Icon or "settings"
    window.Theme = CustomUI.Themes[config.Theme or "Indigo"]
    window.Tabs = {}
    window.Visible = false
    window.Notifications = {}
    
    -- Create main screen GUI
    window.ScreenGui = Instance.new("ScreenGui")
    window.ScreenGui.Name = "ZiaanHubUI"
    window.ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    window.ScreenGui.ResetOnSpawn = false
    
    -- Main container
    window.MainFrame = Instance.new("Frame")
    window.MainFrame.Name = "MainFrame"
    window.MainFrame.Size = config.Size or UDim2.new(0, 600, 0, 450)
    window.MainFrame.Position = UDim2.new(0.5, -300, 0.5, -225)
    window.MainFrame.BackgroundColor3 = window.Theme.Background
    window.MainFrame.BorderSizePixel = 0
    window.MainFrame.ClipsDescendants = true
    
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 8)
    UICorner.Parent = window.MainFrame
    
    -- Header
    local header = Instance.new("Frame")
    header.Name = "Header"
    header.Size = UDim2.new(1, 0, 0, 50)
    header.BackgroundColor3 = window.Theme.Surface
    header.BorderSizePixel = 0
    header.Parent = window.MainFrame
    
    local headerCorner = Instance.new("UICorner")
    headerCorner.CornerRadius = UDim.new(0, 8)
    headerCorner.Parent = header
    
    -- Title
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "Title"
    titleLabel.Size = UDim2.new(1, -100, 1, 0)
    titleLabel.Position = UDim2.new(0, 15, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = window.Title
    titleLabel.TextColor3 = window.Theme.Text
    titleLabel.TextSize = 18
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = header
    
    -- Close button
    local closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.Size = UDim2.new(0, 30, 0, 30)
    closeButton.Position = UDim2.new(1, -40, 0.5, -15)
    closeButton.BackgroundColor3 = window.Theme.Error
    closeButton.TextColor3 = window.Theme.Text
    closeButton.Text = "X"
    closeButton.TextSize = 14
    closeButton.Font = Enum.Font.GothamBold
    closeButton.Parent = header
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 4)
    closeCorner.Parent = closeButton
    
    closeButton.MouseButton1Click:Connect(function()
        window:Toggle()
    end)
    
    -- Tabs container
    window.TabsContainer = Instance.new("Frame")
    window.TabsContainer.Name = "TabsContainer"
    window.TabsContainer.Size = UDim2.new(0, 150, 1, -50)
    window.TabsContainer.Position = UDim2.new(0, 0, 0, 50)
    window.TabsContainer.BackgroundColor3 = window.Theme.Surface
    window.TabsContainer.BorderSizePixel = 0
    window.TabsContainer.Parent = window.MainFrame
    
    -- Content container
    window.ContentContainer = Instance.new("Frame")
    window.ContentContainer.Name = "ContentContainer"
    window.ContentContainer.Size = UDim2.new(1, -150, 1, -50)
    window.ContentContainer.Position = UDim2.new(0, 150, 0, 50)
    window.ContentContainer.BackgroundTransparency = 1
    window.ContentContainer.ClipsDescendants = true
    window.ContentContainer.Parent = window.MainFrame
    
    -- Tabs list
    window.TabsList = Instance.new("ScrollingFrame")
    window.TabsList.Name = "TabsList"
    window.TabsList.Size = UDim2.new(1, 0, 1, 0)
    window.TabsList.BackgroundTransparency = 1
    window.TabsList.ScrollingDirection = Enum.ScrollingDirection.Y
    window.TabsList.ScrollBarThickness = 3
    window.TabsList.AutomaticCanvasSize = Enum.AutomaticSize.Y
    window.TabsList.Parent = window.TabsContainer
    
    local UIListLayout = Instance.new("UIListLayout")
    UIListLayout.Padding = UDim.new(0, 5)
    UIListLayout.Parent = window.TabsList
    
    -- Make draggable
    local dragging
    local dragInput
    local dragStart
    local startPos
    
    local function update(input)
        local delta = input.Position - dragStart
        window.MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
    
    header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = window.MainFrame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    header.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end)
    
    window.ScreenGui.Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
    
    return window
end

function CustomUI:Toggle()
    self.Visible = not self.Visible
    self.MainFrame.Visible = self.Visible
end

function CustomUI:SetToggleKey(key)
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.KeyCode == key then
            self:Toggle()
        end
    end)
end

function CustomUI:Tab(config)
    local tab = {
        Title = config.Title,
        Icon = config.Icon,
        Sections = {}
    }
    
    -- Create tab button
    local tabButton = Instance.new("TextButton")
    tabButton.Name = config.Title .. "Tab"
    tabButton.Size = UDim2.new(1, -10, 0, 40)
    tabButton.BackgroundColor3 = self.Theme.Surface
    tabButton.Text = ""
    tabButton.AutoButtonColor = false
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = tabButton
    
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, -10, 1, 0)
    title.Position = UDim2.new(0, 10, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = config.Title
    title.TextColor3 = self.Theme.TextSecondary
    title.TextSize = 14
    title.Font = Enum.Font.Gotham
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = tabButton
    
    -- Tab content frame
    local tabContent = Instance.new("ScrollingFrame")
    tabContent.Name = config.Title .. "Content"
    tabContent.Size = UDim2.new(1, 0, 1, 0)
    tabContent.BackgroundTransparency = 1
    tabContent.ScrollBarThickness = 3
    tabContent.AutomaticCanvasSize = Enum.AutomaticSize.Y
    tabContent.Visible = #self.Tabs == 0 -- First tab is visible by default
    tabContent.Parent = self.ContentContainer
    
    local contentLayout = Instance.new("UIListLayout")
    contentLayout.Padding = UDim.new(0, 10)
    contentLayout.Parent = tabContent
    
    tabButton.MouseButton1Click:Connect(function()
        -- Hide all tab contents
        for _, existingTab in pairs(self.Tabs) do
            existingTab.Content.Visible = false
        end
        
        -- Show this tab content
        tabContent.Visible = true
        
        -- Update tab button colors
        for _, btn in pairs(self.TabsList:GetChildren()) do
            if btn:IsA("TextButton") then
                btn.BackgroundColor3 = self.Theme.Surface
                btn.Title.TextColor3 = self.Theme.TextSecondary
            end
        end
        
        tabButton.BackgroundColor3 = self.Theme.Primary
        title.TextColor3 = self.Theme.Text
    end)
    
    tabButton.Parent = self.TabsList
    
    tab.Content = tabContent
    table.insert(self.Tabs, tab)
    
    local tabInterface = {}
    
    function tabInterface:Section(config)
        local section = {
            Title = config.Title,
            Icon = config.Icon,
            Elements = {}
        }
        
        -- Section frame
        local sectionFrame = Instance.new("Frame")
        sectionFrame.Name = config.Title .. "Section"
        sectionFrame.Size = UDim2.new(1, -20, 0, 0)
        sectionFrame.BackgroundColor3 = self.Theme.Surface
        sectionFrame.AutomaticSize = Enum.AutomaticSize.Y
        
        local sectionCorner = Instance.new("UICorner")
        sectionCorner.CornerRadius = UDim.new(0, 6)
        sectionCorner.Parent = sectionFrame
        
        -- Section header
        local header = Instance.new("Frame")
        header.Name = "Header"
        header.Size = UDim2.new(1, 0, 0, 40)
        header.BackgroundTransparency = 1
        header.Parent = sectionFrame
        
        local titleLabel = Instance.new("TextLabel")
        titleLabel.Name = "Title"
        titleLabel.Size = UDim2.new(1, -20, 1, 0)
        titleLabel.Position = UDim2.new(0, 15, 0, 0)
        titleLabel.BackgroundTransparency = 1
        titleLabel.Text = config.Title
        titleLabel.TextColor3 = self.Theme.Text
        titleLabel.TextSize = 16
        titleLabel.Font = Enum.Font.GothamBold
        titleLabel.TextXAlignment = Enum.TextXAlignment.Left
        titleLabel.Parent = header
        
        -- Content container
        local content = Instance.new("Frame")
        content.Name = "Content"
        content.Size = UDim2.new(1, 0, 0, 0)
        content.Position = UDim2.new(0, 0, 0, 40)
        content.BackgroundTransparency = 1
        content.AutomaticSize = Enum.AutomaticSize.Y
        content.Parent = sectionFrame
        
        local contentLayout = Instance.new("UIListLayout")
        contentLayout.Padding = UDim.new(0, 10)
        contentLayout.Parent = content
        
        sectionFrame.Parent = tabContent
        
        local sectionInterface = {}
        
        -- Element creation functions
        function sectionInterface:Button(config)
            local button = Instance.new("TextButton")
            button.Name = config.Title .. "Button"
            button.Size = UDim2.new(1, -20, 0, 40)
            button.Position = UDim2.new(0, 10, 0, 0)
            button.BackgroundColor3 = self.Theme.Primary
            button.Text = config.Title
            button.TextColor3 = self.Theme.Text
            button.TextSize = 14
            button.Font = Enum.Font.Gotham
            button.AutoButtonColor = false
            
            local corner = Instance.new("UICorner")
            corner.CornerRadius = UDim.new(0, 4)
            corner.Parent = button
            
            button.MouseEnter:Connect(function()
                TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = self.Theme.Secondary}):Play()
            end)
            
            button.MouseLeave:Connect(function()
                TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = self.Theme.Primary}):Play()
            end)
            
            button.MouseButton1Click:Connect(function()
                if config.Callback then
                    config.Callback()
                end
            end)
            
            button.Parent = content
        end
        
        function sectionInterface:Toggle(config)
            local toggleFrame = Instance.new("Frame")
            toggleFrame.Name = config.Title .. "Toggle"
            toggleFrame.Size = UDim2.new(1, -20, 0, 30)
            toggleFrame.BackgroundTransparency = 1
            toggleFrame.Parent = content
            
            local label = Instance.new("TextLabel")
            label.Name = "Label"
            label.Size = UDim2.new(0.7, 0, 1, 0)
            label.BackgroundTransparency = 1
            label.Text = config.Title
            label.TextColor3 = self.Theme.Text
            label.TextSize = 14
            label.Font = Enum.Font.Gotham
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.Parent = toggleFrame
            
            local toggleButton = Instance.new("TextButton")
            toggleButton.Name = "Toggle"
            toggleButton.Size = UDim2.new(0, 50, 0, 25)
            toggleButton.Position = UDim2.new(1, -50, 0.5, -12.5)
            toggleButton.BackgroundColor3 = config.Value and self.Theme.Success or self.Theme.Surface
            toggleButton.Text = ""
            toggleButton.AutoButtonColor = false
            
            local corner = Instance.new("UICorner")
            corner.CornerRadius = UDim.new(0, 12)
            corner.Parent = toggleButton
            
            local toggleCircle = Instance.new("Frame")
            toggleCircle.Name = "Circle"
            toggleCircle.Size = UDim2.new(0, 21, 0, 21)
            toggleCircle.Position = UDim2.new(0, config.Value and 29 or 2, 0.5, -10.5)
            toggleCircle.BackgroundColor3 = self.Theme.Text
            toggleCircle.Parent = toggleButton
            
            local circleCorner = Instance.new("UICorner")
            circleCorner.CornerRadius = UDim.new(1, 0)
            circleCorner.Parent = toggleCircle
            
            local value = config.Value or false
            
            toggleButton.MouseButton1Click:Connect(function()
                value = not value
                
                TweenService:Create(toggleButton, TweenInfo.new(0.2), {
                    BackgroundColor3 = value and self.Theme.Success or self.Theme.Surface
                }):Play()
                
                TweenService:Create(toggleCircle, TweenInfo.new(0.2), {
                    Position = UDim2.new(0, value and 29 or 2, 0.5, -10.5)
                }):Play()
                
                if config.Callback then
                    config.Callback(value)
                end
            end)
            
            toggleButton.Parent = toggleFrame
        end
        
        function sectionInterface:Input(config)
            local inputFrame = Instance.new("Frame")
            inputFrame.Name = config.Title .. "Input"
            inputFrame.Size = UDim2.new(1, -20, 0, 60)
            inputFrame.BackgroundTransparency = 1
            inputFrame.Parent = content
            
            local label = Instance.new("TextLabel")
            label.Name = "Label"
            label.Size = UDim2.new(1, 0, 0, 20)
            label.BackgroundTransparency = 1
            label.Text = config.Title
            label.TextColor3 = self.Theme.Text
            label.TextSize = 14
            label.Font = Enum.Font.Gotham
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.Parent = inputFrame
            
            local textBox = Instance.new("TextBox")
            textBox.Name = "Input"
            textBox.Size = UDim2.new(1, 0, 0, 35)
            textBox.Position = UDim2.new(0, 0, 0, 25)
            textBox.BackgroundColor3 = self.Theme.Background
            textBox.TextColor3 = self.Theme.Text
            textBox.Text = ""
            textBox.PlaceholderText = config.Placeholder or "Enter value..."
            textBox.TextSize = 14
            textBox.Font = Enum.Font.Gotham
            textBox.ClearTextOnFocus = false
            
            local corner = Instance.new("UICorner")
            corner.CornerRadius = UDim.new(0, 4)
            corner.Parent = textBox
            
            textBox.FocusLost:Connect(function(enterPressed)
                if enterPressed and config.Callback then
                    config.Callback(textBox.Text)
                end
            end)
            
            textBox.Parent = inputFrame
        end
        
        function sectionInterface:Dropdown(config)
            local dropdownFrame = Instance.new("Frame")
            dropdownFrame.Name = config.Title .. "Dropdown"
            dropdownFrame.Size = UDim2.new(1, -20, 0, 60)
            dropdownFrame.BackgroundTransparency = 1
            dropdownFrame.Parent = content
            
            local label = Instance.new("TextLabel")
            label.Name = "Label"
            label.Size = UDim2.new(1, 0, 0, 20)
            label.BackgroundTransparency = 1
            label.Text = config.Title
            label.TextColor3 = self.Theme.Text
            label.TextSize = 14
            label.Font = Enum.Font.Gotham
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.Parent = dropdownFrame
            
            local dropdownButton = Instance.new("TextButton")
            dropdownButton.Name = "Dropdown"
            dropdownButton.Size = UDim2.new(1, 0, 0, 35)
            dropdownButton.Position = UDim2.new(0, 0, 0, 25)
            dropdownButton.BackgroundColor3 = self.Theme.Background
            dropdownButton.TextColor3 = self.Theme.TextSecondary
            dropdownButton.Text = "Select..."
            dropdownButton.TextSize = 14
            dropdownButton.Font = Enum.Font.Gotham
            dropdownButton.AutoButtonColor = false
            
            local corner = Instance.new("UICorner")
            corner.CornerRadius = UDim.new(0, 4)
            corner.Parent = dropdownButton
            
            local dropdownOpen = false
            local selectedValue = nil
            
            dropdownButton.MouseButton1Click:Connect(function()
                dropdownOpen = not dropdownOpen
                -- Implement dropdown list here
                if config.Callback and selectedValue then
                    config.Callback(selectedValue)
                end
            end)
            
            dropdownButton.Parent = dropdownFrame
        end
        
        function sectionInterface:Label(config)
            local labelFrame = Instance.new("Frame")
            labelFrame.Name = config.Title .. "Label"
            labelFrame.Size = UDim2.new(1, -20, 0, 40)
            labelFrame.BackgroundTransparency = 1
            labelFrame.Parent = content
            
            local titleLabel = Instance.new("TextLabel")
            titleLabel.Name = "Title"
            titleLabel.Size = UDim2.new(1, 0, 0, 20)
            titleLabel.BackgroundTransparency = 1
            titleLabel.Text = config.Title
            titleLabel.TextColor3 = self.Theme.Text
            titleLabel.TextSize = 14
            titleLabel.Font = Enum.Font.GothamBold
            titleLabel.TextXAlignment = Enum.TextXAlignment.Left
            titleLabel.Parent = labelFrame
            
            local contentLabel = Instance.new("TextLabel")
            contentLabel.Name = "Content"
            contentLabel.Size = UDim2.new(1, 0, 0, 20)
            contentLabel.Position = UDim2.new(0, 0, 0, 20)
            contentLabel.BackgroundTransparency = 1
            contentLabel.Text = config.Content or ""
            contentLabel.TextColor3 = self.Theme.TextSecondary
            contentLabel.TextSize = 12
            contentLabel.Font = Enum.Font.Gotham
            contentLabel.TextXAlignment = Enum.TextXAlignment.Left
            contentLabel.TextWrapped = true
            contentLabel.Parent = labelFrame
        end
        
        function sectionInterface:Paragraph(config)
            local paragraphFrame = Instance.new("Frame")
            paragraphFrame.Name = "Paragraph"
            paragraphFrame.Size = UDim2.new(1, -20, 0, 60)
            paragraphFrame.BackgroundTransparency = 1
            paragraphFrame.AutomaticSize = Enum.AutomaticSize.Y
            paragraphFrame.Parent = content
            
            local titleLabel = Instance.new("TextLabel")
            titleLabel.Name = "Title"
            titleLabel.Size = UDim2.new(1, 0, 0, 20)
            titleLabel.BackgroundTransparency = 1
            titleLabel.Text = config.Title
            titleLabel.TextColor3 = self.Theme.Text
            titleLabel.TextSize = 14
            titleLabel.Font = Enum.Font.GothamBold
            titleLabel.TextXAlignment = Enum.TextXAlignment.Left
            titleLabel.Parent = paragraphFrame
            
            local contentLabel = Instance.new("TextLabel")
            contentLabel.Name = "Content"
            contentLabel.Size = UDim2.new(1, 0, 0, 0)
            contentLabel.Position = UDim2.new(0, 0, 0, 25)
            contentLabel.BackgroundTransparency = 1
            contentLabel.Text = config.Content or ""
            contentLabel.TextColor3 = self.Theme.TextSecondary
            contentLabel.TextSize = 12
            contentLabel.Font = Enum.Font.Gotham
            contentLabel.TextXAlignment = Enum.TextXAlignment.Left
            contentLabel.TextWrapped = true
            contentLabel.AutomaticSize = Enum.AutomaticSize.Y
            contentLabel.Parent = paragraphFrame
        end
        
        return sectionInterface
    end
    
    return sectionInterface
end

-- Notification system
function CustomUI:Notify(config)
    local notification = Instance.new("Frame")
    notification.Name = "Notification"
    notification.Size = UDim2.new(0, 300, 0, 80)
    notification.Position = UDim2.new(1, 10, 1, -90)
    notification.BackgroundColor3 = self.Theme.Surface
    notification.BorderSizePixel = 0
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = notification
    
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, -20, 0, 25)
    title.Position = UDim2.new(0, 10, 0, 10)
    title.BackgroundTransparency = 1
    title.Text = config.Title or "Notification"
    title.TextColor3 = self.Theme.Text
    title.TextSize = 16
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = notification
    
    local content = Instance.new("TextLabel")
    content.Name = "Content"
    content.Size = UDim2.new(1, -20, 0, 35)
    content.Position = UDim2.new(0, 10, 0, 35)
    content.BackgroundTransparency = 1
    content.Text = config.Content or ""
    content.TextColor3 = self.Theme.TextSecondary
    content.TextSize = 14
    content.Font = Enum.Font.Gotham
    content.TextXAlignment = Enum.TextXAlignment.Left
    content.TextWrapped = true
    content.Parent = notification
    
    notification.Parent = self.ScreenGui
    
    -- Animate in
    TweenService:Create(notification, TweenInfo.new(0.3), {
        Position = UDim2.new(1, -310, 1, -90)
    }):Play()
    
    -- Auto remove after duration
    task.delay(config.Duration or 5, function()
        TweenService:Create(notification, TweenInfo.new(0.3), {
            Position = UDim2.new(1, 10, 1, -90)
        }):Play()
        
        task.wait(0.3)
        notification:Destroy()
    end)
end

return CustomUI