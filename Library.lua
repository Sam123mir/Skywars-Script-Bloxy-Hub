--[[
    ╔════════════════════════════════════════════════════════════╗
    ║  🎨 BLOXYHUB UI v2.0 - ULTRA PROFESSIONAL                  ║
    ║  Inspirado en diseño React moderno                         ║
    ║  Theme: Dark Mode + Indigo/Purple Accents                  ║
    ╚════════════════════════════════════════════════════════════╝
]]

local BloxyHub = {}
BloxyHub.__index = BloxyHub

-- ============================================
-- 🎨 MODERN DESIGN SYSTEM
-- ============================================

local THEME = {
    Background = {
        Primary = Color3.fromRGB(11, 11, 11),      -- #0B0B0B
        Secondary = Color3.fromRGB(21, 21, 21),    -- #151515
        Elevated = Color3.fromRGB(26, 26, 26),     -- #1A1A1A
        Hover = Color3.fromRGB(32, 32, 32),        -- #202020
    },
    Accent = {
        Primary = Color3.fromRGB(99, 102, 241),    -- Indigo #6366F1
        Secondary = Color3.fromRGB(139, 92, 246),  -- Purple #8B5CF6
        Success = Color3.fromRGB(16, 185, 129),    -- Green #10B981
        Warning = Color3.fromRGB(245, 158, 11),    -- Orange #F59E0B
        Danger = Color3.fromRGB(239, 68, 68),      -- Red #EF4444
    },
    Text = {
        Primary = Color3.fromRGB(255, 255, 255),   -- White
        Secondary = Color3.fromRGB(156, 163, 175), -- Gray #9CA3AF
        Muted = Color3.fromRGB(107, 114, 128),     -- Gray #6B7280
    },
    Border = Color3.fromRGB(37, 37, 37),           -- #252525
}

-- Services
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local Player = Players.LocalPlayer

-- Utility: Tween
local function Tween(obj, props, duration, style, direction)
    local info = TweenInfo.new(
        duration or 0.3,
        style or Enum.EasingStyle.Quart,
        direction or Enum.EasingDirection.Out
    )
    TweenService:Create(obj, info, props):Play()
end

-- ============================================
-- 🔔 NOTIFICATION SYSTEM V2.0
-- ============================================

function BloxyHub:Notify(title, message, duration, notifType)
    local PlayerGui = Player:WaitForChild("PlayerGui")
    local container = PlayerGui:FindFirstChild("BloxyNotifV2") or Instance.new("ScreenGui", PlayerGui)
    container.Name = "BloxyNotifV2"
    container.ResetOnSpawn = false
    container.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    local notif = Instance.new("Frame")
    notif.Size = UDim2.new(0, 320, 0, 90)
    notif.Position = UDim2.new(1, -330, 0, 10 + (#container:GetChildren() * 100))
    notif.BackgroundColor3 = THEME.Background.Secondary
    notif.BorderSizePixel = 0
    notif.Parent = container
    Instance.new("UICorner", notif).CornerRadius = UDim.new(0, 12)
    
    -- Border stroke
    local stroke = Instance.new("UIStroke", notif)
    stroke.Color = notifType == "success" and THEME.Accent.Success or
                   notifType == "warning" and THEME.Accent.Warning or
                   notifType == "error" and THEME.Accent.Danger or
                   THEME.Accent.Primary
    stroke.Thickness = 2
    stroke.Transparency = 0.5
    
    -- Icon background
    local iconBg = Instance.new("Frame", notif)
    iconBg.Size = UDim2.new(0, 40, 0, 40)
    iconBg.Position = UDim2.new(0, 15, 0, 15)
    iconBg.BackgroundColor3 = stroke.Color
    iconBg.BackgroundTransparency = 0.9
    iconBg.BorderSizePixel = 0
    Instance.new("UICorner", iconBg).CornerRadius = UDim.new(0, 10)
    
    -- Icon
    local icon = Instance.new("TextLabel", iconBg)
    icon.Size = UDim2.new(1, 0, 1, 0)
    icon.BackgroundTransparency = 1
    icon.Text = notifType == "success" and "✓" or
                notifType == "warning" and "⚠" or
                notifType == "error" and "✕" or "ℹ"
    icon.TextColor3 = stroke.Color
    icon.Font = Enum.Font.GothamBold
    icon.TextSize = 20
    
    -- Title
    local titleLabel = Instance.new("TextLabel", notif)
    titleLabel.Size = UDim2.new(1, -120, 0, 20)
    titleLabel.Position = UDim2.new(0, 65, 0, 15)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = THEME.Text.Primary
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 14
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Message
    local msgLabel = Instance.new("TextLabel", notif)
    msgLabel.Size = UDim2.new(1, -120, 0, 30)
    msgLabel.Position = UDim2.new(0, 65, 0, 35)
    msgLabel.BackgroundTransparency = 1
    msgLabel.Text = message
    msgLabel.TextColor3 = THEME.Text.Secondary
    msgLabel.Font = Enum.Font.Gotham
    msgLabel.TextSize = 11
    msgLabel.TextXAlignment = Enum.TextXAlignment.Left
    msgLabel.TextWrapped = true
    
    -- Close button
    local closeBtn = Instance.new("TextButton", notif)
    closeBtn.Size = UDim2.new(0, 20, 0, 20)
    closeBtn.Position = UDim2.new(1, -30, 0, 10)
    closeBtn.BackgroundTransparency = 1
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = THEME.Text.Muted
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 14
    
    -- Progress bar background
    local progressBg = Instance.new("Frame", notif)
    progressBg.Size = UDim2.new(1, -30, 0, 3)
    progressBg.Position = UDim2.new(0, 15, 1, -10)
    progressBg.BackgroundColor3 = THEME.Background.Elevated
    progressBg.BorderSizePixel = 0
    Instance.new("UICorner", progressBg).CornerRadius = UDim.new(1, 0)
    
    -- Progress bar fill
    local progressFill = Instance.new("Frame", progressBg)
    progressFill.Size = UDim2.new(1, 0, 1, 0)
    progressFill.BackgroundColor3 = stroke.Color
    progressFill.BorderSizePixel = 0
    Instance.new("UICorner", progressFill).CornerRadius = UDim.new(1, 0)
    
    -- Animation
    notif.Position = UDim2.new(1, 0, 0, notif.Position.Y.Offset)
    Tween(notif, {Position = UDim2.new(1, -330, 0, notif.Position.Y.Offset)}, 0.4, Enum.EasingStyle.Back)
    
    -- Progress animation
    Tween(progressFill, {Size = UDim2.new(0, 0, 1, 0)}, duration or 3, Enum.EasingStyle.Linear)
    
    -- Close functionality
    local function close()
        Tween(notif, {Position = UDim2.new(1, 0, 0, notif.Position.Y.Offset)}, 0.3)
        task.wait(0.3)
        notif:Destroy()
    end
    
    closeBtn.MouseButton1Click:Connect(close)
    task.delay(duration or 3, close)
end

-- ============================================
-- 🪟 CREATE WINDOW V2.0
-- ============================================

function BloxyHub:CreateWindow(config)
    local Window = {
        Tabs = {},
        Theme = THEME,
        Dragging = false,
    }
    
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "BloxyHubV2"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    if gethui then
        ScreenGui.Parent = gethui()
    else
        ScreenGui.Parent = game:GetService("CoreGui")
    end
    
    -- Main Container
    local Main = Instance.new("Frame")
    Main.Size = UDim2.new(0, 700, 0, 500)
    Main.Position = UDim2.new(0.5, -350, 0.5, -250)
    Main.BackgroundColor3 = THEME.Background.Primary
    Main.BorderSizePixel = 0
    Main.Parent = ScreenGui
    Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 16)
    
    -- Main shadow/glow
    local mainStroke = Instance.new("UIStroke", Main)
    mainStroke.Color = THEME.Border
    mainStroke.Thickness = 1
    mainStroke.Transparency = 0.5
    
    -- TopBar
    local TopBar = Instance.new("Frame", Main)
    TopBar.Size = UDim2.new(1, 0, 0, 50)
    TopBar.BackgroundColor3 = THEME.Background.Secondary
    TopBar.BorderSizePixel = 0
    local topCorner = Instance.new("UICorner", TopBar)
    topCorner.CornerRadius = UDim.new(0, 16)
    
    -- Title with icon
    local TitleContainer = Instance.new("Frame", TopBar)
    TitleContainer.Size = UDim2.new(1, -100, 1, 0)
    TitleContainer.Position = UDim2.new(0, 20, 0, 0)
    TitleContainer.BackgroundTransparency = 1
    
    local TitleIcon = Instance.new("TextLabel", TitleContainer)
    TitleIcon.Size = UDim2.new(0, 30, 0, 30)
    TitleIcon.Position = UDim2.new(0, 0, 0.5, -15)
    TitleIcon.BackgroundTransparency = 1
    TitleIcon.Text = "⚔️"
    TitleIcon.TextColor3 = THEME.Accent.Primary
    TitleIcon.Font = Enum.Font.GothamBold
    TitleIcon.TextSize = 20
    
    local Title = Instance.new("TextLabel", TitleContainer)
    Title.Size = UDim2.new(1, -40, 1, 0)
    Title.Position = UDim2.new(0, 40, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Text = config.Title or "BLOXYHUB"
    Title.TextColor3 = THEME.Text.Primary
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 16
    Title.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Minimize Logo (cuando se minimiza)
    local Logo = Instance.new("ImageButton", ScreenGui)
    Logo.Size = UDim2.new(0, 60, 0, 60)
    Logo.Position = UDim2.new(0, 15, 0.5, -30)
    Logo.BackgroundColor3 = THEME.Accent.Primary
    Logo.BorderSizePixel = 0
    Logo.Visible = false
    Logo.ZIndex = 10
    Instance.new("UICorner", Logo).CornerRadius = UDim.new(1, 0)
    
    local LogoStroke = Instance.new("UIStroke", Logo)
    LogoStroke.Color = THEME.Accent.Primary
    LogoStroke.Thickness = 3
    LogoStroke.Transparency = 0.7
    
    local LogoText = Instance.new("TextLabel", Logo)
    LogoText.Size = UDim2.new(1, 0, 1, 0)
    LogoText.BackgroundTransparency = 1
    LogoText.Text = "⚔️"
    LogoText.TextColor3 = Color3.new(1, 1, 1)
    LogoText.Font = Enum.Font.GothamBold
    LogoText.TextSize = 28
    
    -- Minimize Button
    local MinimizeBtn = Instance.new("TextButton", TopBar)
    MinimizeBtn.Size = UDim2.new(0, 35, 0, 35)
    MinimizeBtn.Position = UDim2.new(1, -45, 0.5, -17.5)
    MinimizeBtn.BackgroundColor3 = THEME.Accent.Warning
    MinimizeBtn.BackgroundTransparency = 0.9
    MinimizeBtn.Text = "—"
    MinimizeBtn.TextColor3 = THEME.Accent.Warning
    MinimizeBtn.Font = Enum.Font.GothamBold
    MinimizeBtn.TextSize = 16
    MinimizeBtn.BorderSizePixel = 0
    Instance.new("UICorner", MinimizeBtn).CornerRadius = UDim.new(0, 10)
    
    MinimizeBtn.MouseEnter:Connect(function()
        Tween(MinimizeBtn, {BackgroundTransparency = 0.7}, 0.2)
    end)
    
    MinimizeBtn.MouseLeave:Connect(function()
        Tween(MinimizeBtn, {BackgroundTransparency = 0.9}, 0.2)
    end)
    
    MinimizeBtn.MouseButton1Click:Connect(function()
        Main.Visible = false
        Logo.Visible = true
        Tween(Logo, {Size = UDim2.new(0, 60, 0, 60)}, 0.3, Enum.EasingStyle.Back)
    end)
    
    Logo.MouseButton1Click:Connect(function()
        Main.Visible = true
        Logo.Visible = false
    end)
    
    -- Dragging
    local dragStart, startPos
    TopBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            Window.Dragging = true
            dragStart = input.Position
            startPos = Main.Position
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if Window.Dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            Window.Dragging = false
        end
    end)
    
    -- Content Container (Sidebar + Main Content)
    local ContentContainer = Instance.new("Frame", Main)
    ContentContainer.Size = UDim2.new(1, 0, 1, -50)
    ContentContainer.Position = UDim2.new(0, 0, 0, 50)
    ContentContainer.BackgroundTransparency = 1
    
    -- Sidebar
    local Sidebar = Instance.new("ScrollingFrame", ContentContainer)
    Sidebar.Size = UDim2.new(0, 180, 1, -20)
    Sidebar.Position = UDim2.new(0, 10, 0, 10)
    Sidebar.BackgroundColor3 = THEME.Background.Secondary
    Sidebar.BorderSizePixel = 0
    Sidebar.ScrollBarThickness = 4
    Sidebar.ScrollBarImageColor3 = THEME.Accent.Primary
    Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 12)
    Instance.new("UIListLayout", Sidebar).Padding = UDim.new(0, 6)
    Instance.new("UIPadding", Sidebar).PaddingTop = UDim.new(0, 10)
    
    -- Main Content Area
    local Content = Instance.new("Frame", ContentContainer)
    Content.Size = UDim2.new(1, -210, 1, -20)
    Content.Position = UDim2.new(0, 200, 0, 10)
    Content.BackgroundTransparency = 1
    
    -- ============================================
    -- 📑 CREATE TAB V2.0
    -- ============================================
    
    function Window:CreateTab(tabName, iconEmoji)
        local Tab = {}
        
        -- Tab Button
        local TabBtn = Instance.new("TextButton", Sidebar)
        TabBtn.Size = UDim2.new(1, -16, 0, 45)
        TabBtn.BackgroundColor3 = THEME.Background.Primary
        TabBtn.BackgroundTransparency = 1
        TabBtn.BorderSizePixel = 0
        TabBtn.AutoButtonColor = false
        TabBtn.Text = ""
        
        local tabBtnCorner = Instance.new("UICorner", TabBtn)
        tabBtnCorner.CornerRadius = UDim.new(0, 10)
        
        -- Tab Icon
        local tabIcon = Instance.new("TextLabel", TabBtn)
        tabIcon.Size = UDim2.new(0, 25, 0, 25)
        tabIcon.Position = UDim2.new(0, 12, 0.5, -12.5)
        tabIcon.BackgroundTransparency = 1
        tabIcon.Text = iconEmoji or "📁"
        tabIcon.TextColor3 = THEME.Text.Secondary
        tabIcon.Font = Enum.Font.GothamBold
        tabIcon.TextSize = 16
        
        -- Tab Label
        local tabLabel = Instance.new("TextLabel", TabBtn)
        tabLabel.Size = UDim2.new(1, -50, 1, 0)
        tabLabel.Position = UDim2.new(0, 45, 0, 0)
        tabLabel.BackgroundTransparency = 1
        tabLabel.Text = tabName
        tabLabel.TextColor3 = THEME.Text.Secondary
        tabLabel.Font = Enum.Font.GothamBold
        tabLabel.TextSize = 13
        tabLabel.TextXAlignment = Enum.TextXAlignment.Left
        
        -- Tab Container
        local TabContainer = Instance.new("ScrollingFrame", Content)
        TabContainer.Size = UDim2.new(1, 0, 1, 0)
        TabContainer.BackgroundTransparency = 1
        TabContainer.BorderSizePixel = 0
        TabContainer.ScrollBarThickness = 4
        TabContainer.ScrollBarImageColor3 = THEME.Accent.Primary
        TabContainer.Visible = false
        
        local listLayout = Instance.new("UIListLayout", TabContainer)
        listLayout.Padding = UDim.new(0, 10)
        listLayout.SortOrder = Enum.SortOrder.LayoutOrder
        
        local padding = Instance.new("UIPadding", TabContainer)
        padding.PaddingTop = UDim.new(0, 5)
        padding.PaddingRight = UDim.new(0, 5)
        
        -- Tab Click
        TabBtn.MouseButton1Click:Connect(function()
            for _, t in pairs(Window.Tabs) do
                t.Container.Visible = false
                t.Button.BackgroundTransparency = 1
                t.Icon.TextColor3 = THEME.Text.Secondary
                t.Label.TextColor3 = THEME.Text.Secondary
            end
            
            TabContainer.Visible = true
            TabBtn.BackgroundTransparency = 0
            TabBtn.BackgroundColor3 = THEME.Background.Elevated
            tabIcon.TextColor3 = THEME.Accent.Primary
            tabLabel.TextColor3 = THEME.Text.Primary
        end)
        
        -- Hover effect
        TabBtn.MouseEnter:Connect(function()
            if not TabContainer.Visible then
                Tween(TabBtn, {BackgroundTransparency = 0.5}, 0.2)
            end
        end)
        
        TabBtn.MouseLeave:Connect(function()
            if not TabContainer.Visible then
                Tween(TabBtn, {BackgroundTransparency = 1}, 0.2)
            end
        end)
        
        -- First tab active by default
        if #Window.Tabs == 0 then
            TabBtn.BackgroundTransparency = 0
            TabBtn.BackgroundColor3 = THEME.Background.Elevated
            tabIcon.TextColor3 = THEME.Accent.Primary
            tabLabel.TextColor3 = THEME.Text.Primary
            TabContainer.Visible = true
        end
        
        table.insert(Window.Tabs, {
            Container = TabContainer,
            Button = TabBtn,
            Icon = tabIcon,
            Label = tabLabel
        })
        
        -- ============================================
        -- 🎨 CREATE MODERN TOGGLE
        -- ============================================
        
        function Tab:CreateToggle(config)
            local value = config.Default or false
            
            local frame = Instance.new("Frame", TabContainer)
            frame.Size = UDim2.new(1, 0, 0, 70)
            frame.BackgroundColor3 = THEME.Background.Elevated
            frame.BorderSizePixel = 0
            Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12)
            
            local frameStroke = Instance.new("UIStroke", frame)
            frameStroke.Color = value and THEME.Accent.Primary or THEME.Border
            frameStroke.Thickness = 1
            frameStroke.Transparency = value and 0.5 or 0.8
            
            -- Title
            local label = Instance.new("TextLabel", frame)
            label.Size = UDim2.new(1, -80, 0, 20)
            label.Position = UDim2.new(0, 20, 0, 15)
            label.BackgroundTransparency = 1
            label.Text = config.Name
            label.TextColor3 = THEME.Text.Primary
            label.Font = Enum.Font.GothamBold
            label.TextSize = 14
            label.TextXAlignment = Enum.TextXAlignment.Left
            
            -- Description
            if config.Description then
                local desc = Instance.new("TextLabel", frame)
                desc.Size = UDim2.new(1, -80, 0, 30)
                desc.Position = UDim2.new(0, 20, 0, 35)
                desc.BackgroundTransparency = 1
                desc.Text = config.Description
                desc.TextColor3 = THEME.Text.Muted
                desc.Font = Enum.Font.Gotham
                desc.TextSize = 11
                desc.TextXAlignment = Enum.TextXAlignment.Left
                desc.TextWrapped = true
            end
            
            -- Toggle background
            local toggleBg = Instance.new("Frame", frame)
            toggleBg.Size = UDim2.new(0, 48, 0, 24)
            toggleBg.Position = UDim2.new(1, -60, 0, 23)
            toggleBg.BackgroundColor3 = value and THEME.Accent.Primary or THEME.Background.Secondary
            toggleBg.BorderSizePixel = 0
            Instance.new("UICorner", toggleBg).CornerRadius = UDim.new(1, 0)
            
            -- Toggle circle
            local circle = Instance.new("Frame", toggleBg)
            circle.Size = UDim2.new(0, 18, 0, 18)
            circle.Position = value and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)
            circle.BackgroundColor3 = Color3.new(1, 1, 1)
            circle.BorderSizePixel = 0
            Instance.new("UICorner", circle).CornerRadius = UDim.new(1, 0)
            
            -- Click area
            local btn = Instance.new("TextButton", frame)
            btn.Size = UDim2.new(1, 0, 1, 0)
            btn.BackgroundTransparency = 1
            btn.Text = ""
            
            btn.MouseButton1Click:Connect(function()
                value = not value
                
                Tween(toggleBg, {BackgroundColor3 = value and THEME.Accent.Primary or THEME.Background.Secondary}, 0.3)
                Tween(circle, {Position = value and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)}, 0.3, Enum.EasingStyle.Back)
                Tween(frameStroke, {
                    Color = value and THEME.Accent.Primary or THEME.Border,
                    Transparency = value and 0.5 or 0.8
                }, 0.3)
                
                config.Callback(value)
            end)
        end
        
        -- ============================================
        -- 🎚️ CREATE MODERN SLIDER
        -- ============================================
        
        function Tab:CreateSlider(config)
            local value = config.Default or config.Min
            
            local frame = Instance.new("Frame", TabContainer)
            frame.Size = UDim2.new(1, 0, 0, 75)
            frame.BackgroundColor3 = THEME.Background.Elevated
            frame.BorderSizePixel = 0
            Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12)
            
            local frameStroke = Instance.new("UIStroke", frame)
            frameStroke.Color = THEME.Border
            frameStroke.Thickness = 1
            frameStroke.Transparency = 0.8
            
            -- Title
            local label = Instance.new("TextLabel", frame)
            label.Size = UDim2.new(1, -80, 0, 20)
            label.Position = UDim2.new(0, 20, 0, 15)
            label.BackgroundTransparency = 1
            label.Text = config.Name
            label.TextColor3 = THEME.Text.Primary
            label.Font = Enum.Font.GothamBold
            label.TextSize = 14
            label.TextXAlignment = Enum.TextXAlignment.Left
            
            -- Value display
            local valueLabel = Instance.new("TextLabel", frame)
            valueLabel.Size = UDim2.new(0, 60, 0, 25)
            valueLabel.Position = UDim2.new(1, -70, 0, 12)
            valueLabel.BackgroundColor3 = THEME.Accent.Primary
            valueLabel.BackgroundTransparency = 0.9
            valueLabel.Text = tostring(value)
            valueLabel.TextColor3 = THEME.Accent.Primary
            valueLabel.Font = Enum.Font.GothamBold
            valueLabel.TextSize = 13
            Instance.new("UICorner", valueLabel).CornerRadius = UDim.new(0, 8)
            
            -- Slider background
            local sliderBg = Instance.new("Frame", frame)
            sliderBg.Size = UDim2.new(1, -40, 0, 6)
            sliderBg.Position = UDim2.new(0, 20, 0, 50)
            sliderBg.BackgroundColor3 = THEME.Background.Secondary
            sliderBg.BorderSizePixel = 0
            Instance.new("UICorner", sliderBg).CornerRadius = UDim.new(1, 0)
            
            -- Slider fill
            local fill = Instance.new("Frame", sliderBg)
            local fillPercent = (value - config.Min) / (config.Max - config.Min)
            fill.Size = UDim2.new(fillPercent, 0, 1, 0)
            fill.BackgroundColor3 = THEME.Accent.Primary
            fill.BorderSizePixel = 0
            Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)
            
            -- Slider thumb
            local thumb = Instance.new("Frame", sliderBg)
            thumb.Size = UDim2.new(0, 16, 0, 16)
            thumb.Position = UDim2.new(fillPercent, -8, 0.5, -8)
            thumb.BackgroundColor3 = THEME.Accent.Primary
            thumb.BorderSizePixel = 0
            Instance.new("UICorner", thumb).CornerRadius = UDim.new(1, 0)
            
            local thumbGlow = Instance.new("UIStroke", thumb)
            thumbGlow.Color = THEME.Accent.Primary
            thumbGlow.Thickness = 3
            thumbGlow.Transparency = 0.7
            
            -- Dragging
            local btn = Instance.new("TextButton", sliderBg)
            btn.Size = UDim2.new(1, 0, 1, 10)
            btn.Position = UDim2.new(0, 0, 0, -5)
            btn.BackgroundTransparency = 1
            btn.Text = ""
            
            local dragging = false
            
            local function update(input)
                local pos = math.clamp((input.Position.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X, 0, 1)
                value = math.floor(config.Min + (config.Max - config.Min) * pos)
                valueLabel.Text = tostring(value)
                
                Tween(fill, {Size = UDim2.new(pos, 0, 1, 0)}, 0.1, Enum.EasingStyle.Linear)
                Tween(thumb, {Position = UDim2.new(pos, -8, 0.5, -8)}, 0.1, Enum.EasingStyle.Linear)
                
                config.Callback(value)
            end
            
            btn.MouseButton1Down:Connect(function() dragging = true end)
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
            end)
            UserInputService.InputChanged:Connect(function(input)
                if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then update(input) end
            end)
        end
        
        -- ============================================
        -- 🔲 CREATE MODERN BUTTON
        -- ============================================
        
        function Tab:CreateButton(config)
            local btn = Instance.new("TextButton", TabContainer)
            btn.Size = UDim2.new(1, 0, 0, 45)
            btn.BackgroundColor3 = THEME.Accent.Primary
            btn.BackgroundTransparency = 0.1
            btn.Text = config.Name
            btn.TextColor3 = THEME.Text.Primary
            btn.Font = Enum.Font.GothamBold
            btn.TextSize = 14
            btn.BorderSizePixel = 0
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 12)
            
            local btnStroke = Instance.new("UIStroke", btn)
            btnStroke.Color = THEME.Accent.Primary
            btnStroke.Thickness = 1
            btnStroke.Transparency = 0.5
            
            btn.MouseEnter:Connect(function()
                Tween(btn, {BackgroundTransparency = 0}, 0.2)
            end)
            
            btn.MouseLeave:Connect(function()
                Tween(btn, {BackgroundTransparency = 0.1}, 0.2)
            end)
            
            btn.MouseButton1Click:Connect(function()
                Tween(btn, {BackgroundColor3 = THEME.Accent.Secondary}, 0.1)
                task.wait(0.1)
                Tween(btn, {BackgroundColor3 = THEME.Accent.Primary}, 0.1)
                config.Callback()
            end)
        end
        
        -- ============================================
        -- 📋 CREATE MODERN DROPDOWN
        -- ============================================
        
        function Tab:CreateDropdown(config)
            local frame = Instance.new("Frame", TabContainer)
            frame.Size = UDim2.new(1, 0, 0, 60)
            frame.BackgroundColor3 = THEME.Background.Elevated
            frame.BorderSizePixel = 0
            Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12)
            
            local frameStroke = Instance.new("UIStroke", frame)
            frameStroke.Color = THEME.Border
            frameStroke.Thickness = 1
            frameStroke.Transparency = 0.8
            
            -- Label
            local label = Instance.new("TextLabel", frame)
            label.Size = UDim2.new(1, -40, 0, 20)
            label.Position = UDim2.new(0, 20, 0, 10)
            label.BackgroundTransparency = 1
            label.Text = config.Name
            label.TextColor3 = THEME.Text.Secondary
            label.Font = Enum.Font.Gotham
            label.TextSize = 11
            label.TextXAlignment = Enum.TextXAlignment.Left
            
            local selected = config.Default or config.Options[1] or "None"
            
            -- Dropdown button
            local dropBtn = Instance.new("TextButton", frame)
            dropBtn.Size = UDim2.new(1, -40, 0, 30)
            dropBtn.Position = UDim2.new(0, 20, 0, 25)
            dropBtn.BackgroundColor3 = THEME.Background.Secondary
            dropBtn.Text = ""
            dropBtn.BorderSizePixel = 0
            Instance.new("UICorner", dropBtn).CornerRadius = UDim.new(0, 8)
            
            local dropLabel = Instance.new("TextLabel", dropBtn)
            dropLabel.Size = UDim2.new(1, -30, 1, 0)
            dropLabel.Position = UDim2.new(0, 10, 0, 0)
            dropLabel.BackgroundTransparency = 1
            dropLabel.Text = selected
            dropLabel.TextColor3 = THEME.Text.Primary
            dropLabel.Font = Enum.Font.GothamBold
            dropLabel.TextSize = 12
            dropLabel.TextXAlignment = Enum.TextXAlignment.Left
            
            local arrow = Instance.new("TextLabel", dropBtn)
            arrow.Size = UDim2.new(0, 20, 1, 0)
            arrow.Position = UDim2.new(1, -25, 0, 0)
            arrow.BackgroundTransparency = 1
            arrow.Text = "▼"
            arrow.TextColor3 = THEME.Text.Muted
            arrow.Font = Enum.Font.Gotham
            arrow.TextSize = 10
            
            -- Options container
            local optionsFrame = Instance.new("ScrollingFrame", frame)
            optionsFrame.Size = UDim2.new(1, -40, 0, math.min(#config.Options * 32, 128))
            optionsFrame.Position = UDim2.new(0, 20, 1, 5)
            optionsFrame.BackgroundColor3 = THEME.Background.Elevated
            optionsFrame.BorderSizePixel = 0
            optionsFrame.Visible = false
            optionsFrame.ScrollBarThickness = 4
            optionsFrame.ScrollBarImageColor3 = THEME.Accent.Primary
            Instance.new("UICorner", optionsFrame).CornerRadius = UDim.new(0, 8)
            Instance.new("UIListLayout", optionsFrame).Padding = UDim.new(0, 2)
            
            local opStroke = Instance.new("UIStroke", optionsFrame)
            opStroke.Color = THEME.Border
            opStroke.Thickness = 1
            opStroke.Transparency = 0.5
            
            for _, option in ipairs(config.Options) do
                local optBtn = Instance.new("TextButton", optionsFrame)
                optBtn.Size = UDim2.new(1, 0, 0, 30)
                optBtn.BackgroundColor3 = option == selected and THEME.Accent.Primary or THEME.Background.Secondary
                optBtn.BackgroundTransparency = option == selected and 0.9 or 1
                optBtn.Text = option
                optBtn.TextColor3 = option == selected and THEME.Accent.Primary or THEME.Text.Primary
                optBtn.Font = Enum.Font.Gotham
                optBtn.TextSize = 11
                optBtn.BorderSizePixel = 0
                
                optBtn.MouseEnter:Connect(function()
                    if option ~= selected then
                        Tween(optBtn, {BackgroundTransparency = 0.95}, 0.2)
                    end
                end)
                
                optBtn.MouseLeave:Connect(function()
                    if option ~= selected then
                        Tween(optBtn, {BackgroundTransparency = 1}, 0.2)
                    end
                end)
                
                optBtn.MouseButton1Click:Connect(function()
                    selected = option
                    dropLabel.Text = option
                    optionsFrame.Visible = false
                    
                    for _, child in ipairs(optionsFrame:GetChildren()) do
                        if child:IsA("TextButton") then
                            child.BackgroundTransparency = child.Text == selected and 0.9 or 1
                            child.TextColor3 = child.Text == selected and THEME.Accent.Primary or THEME.Text.Primary
                        end
                    end
                    
                    config.Callback(option)
                end)
            end
            
            dropBtn.MouseButton1Click:Connect(function()
                optionsFrame.Visible = not optionsFrame.Visible
                frame.Size = optionsFrame.Visible and UDim2.new(1, 0, 0, 70 + optionsFrame.AbsoluteSize.Y) or UDim2.new(1, 0, 0, 60)
            end)
        end
        
        return Tab
    end
    
    return Window
end

return BloxyHub
