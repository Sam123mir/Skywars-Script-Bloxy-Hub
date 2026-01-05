--[[
    ╔════════════════════════════════════════════════════════════╗
    ║  📑 SKYWARS ULTIMATE PRO - TAB COMPONENT                   ║
    ║  Created by: SAMIR (16bitplayer) - 2026                    ║
    ║  Sidebar navigation tabs with icons                        ║
    ╚════════════════════════════════════════════════════════════╝
]]

local Theme = require(script.Parent.Parent.Core.Theme)
local Utils = require(script.Parent.Parent.Core.Utilities)

local Tab = {}
Tab.__index = Tab

function Tab.new(window, name, icon)
    local self = setmetatable({}, Tab)
    
    self.Window = window
    self.Name = name
    self.Icon = icon or "📄"
    self.Active = false
    self.Components = {}
    
    self:CreateTab()
    
    return self
end

function Tab:CreateTab()
    -- Tab Button (in sidebar)
    self.Button = Utils:Create("TextButton", {
        Name = self.Name .. "_Button",
        Size = UDim2.new(1, -10, 0, 45),
        BackgroundColor3 = Theme.Background.Tertiary,
        Text = "",
        BorderSizePixel = 0,
        AutoButtonColor = false,
        Parent = self.Window.TabsContainer
    })
    Utils:AddCorner(self.Button, UDim.new(0, 8))
    
    -- Icon
    local icon = Utils:Create("TextLabel", {
        Size = UDim2.new(0, 30, 0, 30),
        Position = UDim2.new(0, 10, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundTransparency = 1,
        Text = self.Icon,
        Font = Theme.Fonts.Header,
        TextSize = 18,
        TextColor3 = Theme.Text.Secondary,
        Parent = self.Button
    })
    
    -- Label
    local label = Utils:Create("TextLabel", {
        Size = UDim2.new(1, -50, 1, 0),
        Position = UDim2.new(0, 45, 0, 0),
        BackgroundTransparency = 1,
        Text = self.Name,
        Font = Theme.Fonts.Body,
        TextSize = Theme.FontSizes.Body,
        TextColor3 = Theme.Text.Secondary,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = self.Button
    })
    
    -- Tab Content (in content area)
    self.Container = Utils:Create("ScrollingFrame", {
        Name = self.Name .. "_Container",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 6,
        ScrollBarImageColor3 = Theme.Accent.Primary,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        Visible = false,
        Parent = self.Window.ContentContainer
    })
    Utils:AddPadding(self.Container, 10)
    
    -- List layout for components
    local layout = Utils:AddListLayout(self.Container, Theme.Sizing.ComponentSpacing)
    layout.Changed:Connect(function()
        self.Container.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 20)
    end)
    
    -- Click handler
    self.Button.MouseButton1Click:Connect(function()
        self:Activate()
    end)
    
    -- Hover effects
    self.Button.MouseEnter:Connect(function()
        if not self.Active then
            Utils:Tween(self.Button, {BackgroundColor3 = Theme.Background.Hover}, Theme.Animations.Fast)
        end
    end)
    
    self.Button.MouseLeave:Connect(function()
        if not self.Active then
            Utils:Tween(self.Button, {BackgroundColor3 = Theme.Background.Tertiary}, Theme.Animations.Fast)
        end
    end)
    
    -- Add to window's tabs
    table.insert(self.Window.Tabs, self)
    
    -- If first tab, activate it
    if #self.Window.Tabs == 1 then
        self:Activate()
    end
end

function Tab:Activate()
    -- Deactivate all tabs
    for _, tab in ipairs(self.Window.Tabs) do
        tab.Active = false
        tab.Container.Visible = false
        tab.Button.BackgroundColor3 = Theme.Background.Tertiary
        
        -- Reset text colors
        for _, child in ipairs(tab.Button:GetChildren()) do
            if child:IsA("TextLabel") then
                child.TextColor3 = Theme.Text.Secondary
            end
        end
    end
    
    -- Activate this tab
    self.Active = true
    self.Container.Visible = true
    self.Window.CurrentTab = self
    
    -- Update button appearance
    Utils:Tween(self.Button, {BackgroundColor3 = Theme.Accent.Primary}, Theme.Animations.Fast)
    
    -- Update text colors
    for _, child in ipairs(self.Button:GetChildren()) do
        if child:IsA("TextLabel") then
            Utils:Tween(child, {TextColor3 = Theme.Text.Primary}, Theme.Animations.Fast)
        end
    end
    
    -- Add gradient
    if not self.Button:FindFirstChild("UIGradient") then
        Utils:AddGradient(self.Button, Theme:GetAccentGradient(), 45)
    end
end

-- Component creation methods will be added here
function Tab:AddLabel(text)
    local label = Utils:Create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 25),
        BackgroundTransparency = 1,
        Text = text,
        Font = Theme.Fonts.Body,
        TextSize = Theme.FontSizes.Body,
        TextColor3 = Theme.Text.Primary,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = self.Container
    })
    
    table.insert(self.Components, label)
    return label
end

function Tab:AddToggle(name, default, callback)
    local Toggle = require(script.Parent.Toggle)
    local toggle = Toggle.new(self, name, default, callback)
    table.insert(self.Components, toggle)
    return toggle
end

function Tab:AddSlider(name, min, max, default, callback)
    local Slider = require(script.Parent.Slider)
    local slider = Slider.new(self, name, min, max, default, callback)
    table.insert(self.Components, slider)
    return slider
end

function Tab:AddButton(name, callback)
    local Button = require(script.Parent.Button)
    local button = Button.new(self, name, callback)
    table.insert(self.Components, button)
    return button
end

return Tab
