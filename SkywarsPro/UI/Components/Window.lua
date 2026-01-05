--[[
    ╔════════════════════════════════════════════════════════════╗
    ║  🪟 SKYWARS ULTIMATE PRO - WINDOW COMPONENT                ║
    ║  Created by: SAMIR (16bitplayer) - 2026                    ║
    ║  Professional window with minimize/maximize/close          ║
    ╚════════════════════════════════════════════════════════════╝
]]

local Theme = require(script.Parent.Parent.Core.Theme)
local Utils = require(script.Parent.Parent.Core.Utilities)

local Window = {}
Window.__index = Window

function Window.new(config)
    local self = setmetatable({}, Window)
    
    -- Configuration
    self.Title = config.Title or "Skywars Ultimate Pro"
    self.Icon = config.Icon or "⚔️"
    self.Subtitle = config.Subtitle or "by SAMIR (16bitplayer)"
    
    -- State
    self.IsMinimized = false
    self.IsMaximized = false
    self.Tabs = {}
    self.CurrentTab = nil
    
    -- Create GUI
    self:CreateGUI()
    
    return self
end

function Window:CreateGUI()
    -- Main ScreenGui
    self.ScreenGui = Utils:Create("ScreenGui", {
        Name = "SkywarsPro_UI",
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        DisplayOrder = 100,
    })
    
    -- Try protected GUI first
    if gethui then
        self.ScreenGui.Parent = gethui()
    elseif syn and syn.protect_gui then
        syn.protect_gui(self.ScreenGui)
        self.ScreenGui.Parent = game:GetService("CoreGui")
    else
        self.ScreenGui.Parent = game:GetService("CoreGui")
    end
    
    -- Main Container
    self.Main = Utils:Create("Frame", {
        Name = "MainWindow",
        Size = UDim2.new(0, Theme.Sizing.WindowWidth, 0, Theme.Sizing.WindowHeight),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Theme.Background.Main,
        BorderSizePixel = 0,
        Parent = self.ScreenGui
    })
    Utils:AddCorner(self.Main, Theme.Sizing.CornerRadius)
    Utils:AddStroke(self.Main, Theme.Border, Theme.Sizing.StrokeThickness, 0.6)
    
    -- Drop shadow effect
    local shadow = Utils:Create("ImageLabel", {
        Size = UDim2.new(1, 30, 1, 30),
        Position = UDim2.new(0, -15, 0, -15),
        BackgroundTransparency = 1,
        Image = "rbxassetid://5028857084",
        ImageColor3 = Theme.Shadow,
        ImageTransparency = 0.7,
        ZIndex = 0,
        Parent = self.Main
    })
    
    -- Create components
    self:CreateTopBar()
    self:CreateSidebar()
    self:CreateContentArea()
    
    -- Make draggable
    Utils:MakeDraggable(self.Main, self.TopBar)
    
    -- Intro animation
    self.Main.Size = UDim2.new(0, 0, 0, 0)
    Utils:Tween(self.Main, {
        Size = UDim2.new(0, Theme.Sizing.WindowWidth, 0, Theme.Sizing.WindowHeight)
    }, 0.4, Enum.EasingStyle.Back)
end

function Window:CreateTopBar()
    -- Top Bar Background
    self.TopBar = Utils:Create("Frame", {
        Name = "TopBar",
        Size = UDim2.new(1, 0, 0, Theme.Sizing.TopBarHeight),
        BackgroundColor3 = Theme.Background.Secondary,
        BorderSizePixel = 0,
        Parent = self.Main
    })
    Utils:AddCorner(self.TopBar, UDim.new(0, 12))
    
    -- Gradient
    Utils:AddGradient(self.TopBar, Theme:GetBackgroundGradient(), 135)
    
    -- Icon
    local icon = Utils:Create("TextLabel", {
        Size = UDim2.new(0, 40, 0, 40),
        Position = UDim2.new(0, 15, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundTransparency = 1,
        Text = self.Icon,
        Font = Theme.Fonts.Header,
        TextSize = 24,
        TextColor3 = Theme.Text.Primary,
        Parent = self.TopBar
    })
    
    -- Title
    local title = Utils:Create("TextLabel", {
        Size = UDim2.new(0, 300, 0, 20),
        Position = UDim2.new(0, 60, 0, 10),
        BackgroundTransparency = 1,
        Text = self.Title,
        Font = Theme.Fonts.Header,
        TextSize = Theme.FontSizes.Title,
        TextColor3 = Theme.Text.Primary,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = self.TopBar
    })
    
    -- Subtitle
    local subtitle = Utils:Create("TextLabel", {
        Size = UDim2.new(0, 300, 0, 16),
        Position = UDim2.new(0, 60, 0, 30),
        BackgroundTransparency = 1,
        Text = self.Subtitle,
        Font = Theme.Fonts.Body,
        TextSize = Theme.FontSizes.Small,
        TextColor3 = Theme.Text.Muted,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = self.TopBar
    })
    
    -- Window Controls
    self:CreateWindowControls()
end

function Window:CreateWindowControls()
    local buttonSize = 32
    local spacing = 8
    local rightPadding = 15
    
    -- Close Button
    local closeBtn = Utils:Create("TextButton", {
        Name = "CloseButton",
        Size = UDim2.new(0, buttonSize, 0, buttonSize),
        Position = UDim2.new(1, -(rightPadding + buttonSize), 0.5, -buttonSize/2),
        BackgroundColor3 = Theme.Accent.Danger,
        Text = "✕",
        TextColor3 = Color3.new(1, 1, 1),
        Font = Theme.Fonts.Header,
        TextSize = 16,
       BorderSizePixel = 0,
        Parent = self.TopBar
    })
    Utils:AddCorner(closeBtn, UDim.new(0, 8))
    
    closeBtn.MouseEnter:Connect(function()
        Utils:Tween(closeBtn, {BackgroundColor3 = Color3.fromRGB(255, 50, 50)}, 0.2)
    end)
    closeBtn.MouseLeave:Connect(function()
        Utils:Tween(closeBtn, {BackgroundColor3 = Theme.Accent.Danger}, 0.2)
    end)
    closeBtn.MouseButton1Click:Connect(function()
        self:Destroy()
    end)
    
    -- Maximize Button
    local maxBtn = Utils:Create("TextButton", {
        Name = "MaximizeButton",
        Size = UDim2.new(0, buttonSize, 0, buttonSize),
        Position = UDim2.new(1, -(rightPadding + (buttonSize + spacing) * 2), 0.5, -buttonSize/2),
        BackgroundColor3 = Theme.Background.Tertiary,
        Text = "□",
        TextColor3 = Theme.Text.Primary,
        Font = Theme.Fonts.Header,
        TextSize = 14,
        BorderSizePixel = 0,
        Parent = self.TopBar
    })
    Utils:AddCorner(maxBtn, UDim.new(0, 8))
    Utils:AddStroke(maxBtn, Theme.Border, 1, 0.5)
    
    maxBtn.MouseEnter:Connect(function()
        Utils:Tween(maxBtn, {BackgroundColor3 = Theme.Background.Hover}, 0.2)
    end)
    maxBtn.MouseLeave:Connect(function()
        Utils:Tween(maxBtn, {BackgroundColor3 = Theme.Background.Tertiary}, 0.2)
    end)
    maxBtn.MouseButton1Click:Connect(function()
        self:ToggleMaximize()
    end)
    
    -- Minimize Button
    local minBtn = Utils:Create("TextButton", {
        Name = "MinimizeButton",
        Size = UDim2.new(0, buttonSize, 0, buttonSize),
        Position = UDim2.new(1, -(rightPadding + buttonSize + spacing), 0.5, -buttonSize/2),
        BackgroundColor3 = Theme.Background.Tertiary,
        Text = "−",
        TextColor3 = Theme.Text.Primary,
        Font = Theme.Fonts.Header,
        TextSize = 18,
        BorderSizePixel = 0,
        Parent = self.TopBar
    })
    Utils:AddCorner(minBtn, UDim.new(0, 8))
    Utils:AddStroke(minBtn, Theme.Border, 1, 0.5)
    
    minBtn.MouseEnter:Connect(function()
        Utils:Tween(minBtn, {BackgroundColor3 = Theme.Background.Hover}, 0.2)
    end)
    minBtn.MouseLeave:Connect(function()
        Utils:Tween(minBtn, {BackgroundColor3 = Theme.Background.Tertiary}, 0.2)
    end)
    minBtn.MouseButton1Click:Connect(function()
        self:ToggleMinimize()
    end)
end

function Window:CreateSidebar()
    self.Sidebar = Utils:Create("Frame", {
        Name = "Sidebar",
        Size = UDim2.new(0, Theme.Sizing.SidebarWidth, 1, -Theme.Sizing.TopBarHeight - 10),
        Position = UDim2.new(0, 10, 0, Theme.Sizing.TopBarHeight + 10),
        BackgroundColor3 = Theme.Background.Secondary,
        BorderSizePixel = 0,
        Parent = self.Main
    })
    Utils:AddCorner(self.Sidebar, Theme.Sizing.CornerRadius)
    
    -- Scrolling frame for tabs
    self.TabsContainer = Utils:Create("ScrollingFrame", {
        Size = UDim2.new(1, -10, 1, -10),
        Position = UDim2.new(0, 5, 0, 5),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 4,
        ScrollBarImageColor3 = Theme.Accent.Primary,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        Parent = self.Sidebar
    })
    
    -- List layout
    local layout = Utils:AddListLayout(self.TabsContainer, 5)
    layout.Changed:Connect(function()
        self.TabsContainer.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 10)
    end)
end

function Window:CreateContentArea()
    self.ContentContainer = Utils:Create("Frame", {
        Name = "Content",
        Size = UDim2.new(1, -(Theme.Sizing.SidebarWidth + 30), 1, -(Theme.Sizing.TopBarHeight + 20)),
        Position = UDim2.new(0, Theme.Sizing.SidebarWidth + 20, 0, Theme.Sizing.TopBarHeight + 10),
        BackgroundTransparency = 1,
        Parent = self.Main
    })
end

function Window:ToggleMinimize()
    self.IsMinimized = not self.IsMinimized
    
    if self.IsMinimized then
        Utils:Tween(self.Main, {
            Size = UDim2.new(0, Theme.Sizing.WindowWidth, 0, Theme.Sizing.TopBarHeight)
        }, Theme.Animations.Normal)
    else
        Utils:Tween(self.Main, {
            Size = UDim2.new(0, Theme.Sizing.WindowWidth, 0, Theme.Sizing.WindowHeight)
        }, Theme.Animations.Normal, Enum.EasingStyle.Back)
    end
end

function Window:ToggleMaximize()
    self.IsMaximized = not self.IsMaximized
    
    if self.IsMaximized then
        Utils:Tween(self.Main, {
            Size = UDim2.new(1, -100, 1, -100),
            Position = UDim2.new(0.5, 0, 0.5, 0)
        }, Theme.Animations.Normal)
    else
        Utils:Tween(self.Main, {
            Size = UDim2.new(0, Theme.Sizing.WindowWidth, 0, Theme.Sizing.WindowHeight),
            Position = UDim2.new(0.5, 0, 0.5, 0)
        }, Theme.Animations.Normal)
    end
end

function Window:Destroy()
    -- Outro animation
    Utils:Tween(self.Main, {
        Size = UDim2.new(0, 0, 0, 0)
    }, Theme.Animations.Normal, nil, nil, function()
        self.ScreenGui:Destroy()
    end)
end

return Window
