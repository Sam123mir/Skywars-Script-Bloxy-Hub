--[[
    ╔═══════════════════════════════════════════════════════════╗
    ║  🎨 BLOXYHUB UI LIBRARY v1.0                             ║
    ║  Tu propia librería UI profesional para Roblox           ║
    ╠═══════════════════════════════════════════════════════════╣
    ║  📦 USO BÁSICO:                                           ║
    ║                                                           ║
    ║  local BloxyHub = loadstring(game:HttpGet("URL"))()      ║
    ║                                                           ║
    ║  local Window = BloxyHub:CreateWindow({                  ║
    ║      Title = "Mi Script Premium",                        ║
    ║      Theme = "Dark"  -- Dark, Blue, Purple, Green        ║
    ║  })                                                       ║
    ║                                                           ║
    ║  local Tab = Window:CreateTab("⚔️ Combat")               ║
    ║                                                           ║
    ║  Tab:CreateToggle({                                      ║
    ║      Name = "Auto Kill",                                 ║
    ║      Default = false,                                    ║
    ║      Callback = function(value)                          ║
    ║          print("Auto Kill:", value)                      ║
    ║      end                                                  ║
    ║  })                                                       ║
    ║                                                           ║
    ║  Tab:CreateSlider({                                      ║
    ║      Name = "Reach",                                     ║
    ║      Min = 10,                                           ║
    ║      Max = 30,                                           ║
    ║      Default = 18,                                       ║
    ║      Callback = function(value)                          ║
    ║          print("Reach:", value)                          ║
    ║      end                                                  ║
    ║  })                                                       ║
    ║                                                           ║
    ║  Tab:CreateButton({                                      ║
    ║      Name = "Execute",                                   ║
    ║      Callback = function()                               ║
    ║          print("Button clicked!")                        ║
    ║      end                                                  ║
    ║  })                                                       ║
    ║                                                           ║
    ║  -- Notificación                                         ║
    ║  BloxyHub:Notify("Título", "Mensaje", 3, "success")     ║
    ╚═══════════════════════════════════════════════════════════╝
]]

local BloxyHub = {}
BloxyHub.__index = BloxyHub

-- ============================================
-- 🎨 THEMES (Personaliza aquí los colores)
-- ============================================

local Themes = {
    Dark = {
        Background = Color3.fromRGB(15, 15, 15),
        Secondary = Color3.fromRGB(25, 25, 25),
        Accent = Color3.fromRGB(99, 102, 241),
        Text = Color3.fromRGB(255, 255, 255),
        TextDark = Color3.fromRGB(150, 150, 150),
    },
    Blue = {
        Background = Color3.fromRGB(10, 25, 47),
        Secondary = Color3.fromRGB(18, 38, 63),
        Accent = Color3.fromRGB(56, 189, 248),
        Text = Color3.fromRGB(255, 255, 255),
        TextDark = Color3.fromRGB(148, 163, 184),
    },
    Purple = {
        Background = Color3.fromRGB(20, 10, 30),
        Secondary = Color3.fromRGB(35, 20, 50),
        Accent = Color3.fromRGB(168, 85, 247),
        Text = Color3.fromRGB(255, 255, 255),
        TextDark = Color3.fromRGB(196, 181, 253),
    },
    Green = {
        Background = Color3.fromRGB(5, 20, 15),
        Secondary = Color3.fromRGB(10, 30, 25),
        Accent = Color3.fromRGB(16, 185, 129),
        Text = Color3.fromRGB(255, 255, 255),
        TextDark = Color3.fromRGB(134, 239, 172),
    },
}

-- Services
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local Player = Players.LocalPlayer

-- Utility: Tween
local function Tween(obj, props, duration)
    TweenService:Create(obj, TweenInfo.new(duration or 0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), props):Play()
end

-- ============================================
-- 🔔 NOTIFICATION SYSTEM
-- ============================================

function BloxyHub:Notify(title, message, duration, notifType)
    local PlayerGui = Player:WaitForChild("PlayerGui")
    local container = PlayerGui:FindFirstChild("BloxyNotif") or Instance.new("ScreenGui", PlayerGui)
    container.Name = "BloxyNotif"
    container.ResetOnSpawn = false
    
    local notif = Instance.new("Frame")
    notif.Size = UDim2.new(0, 300, 0, 70)
    notif.Position = UDim2.new(1, -310, 0, 10 + (#container:GetChildren() * 80))
    notif.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    notif.BorderSizePixel = 0
    notif.Parent = container
    
    Instance.new("UICorner", notif).CornerRadius = UDim.new(0, 10)
    local stroke = Instance.new("UIStroke", notif)
    stroke.Color = (notifType == "success" and Color3.fromRGB(16, 185, 129)) or
                   (notifType == "error" and Color3.fromRGB(239, 68, 68)) or
                   Color3.fromRGB(99, 102, 241)
    stroke.Thickness = 2
    
    local titleLabel = Instance.new("TextLabel", notif)
    titleLabel.Size = UDim2.new(1, -20, 0, 20)
    titleLabel.Position = UDim2.new(0, 10, 0, 10)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = Color3.new(1, 1, 1)
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 14
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    local msgLabel = Instance.new("TextLabel", notif)
    msgLabel.Size = UDim2.new(1, -20, 0, 30)
    msgLabel.Position = UDim2.new(0, 10, 0, 35)
    msgLabel.BackgroundTransparency = 1
    msgLabel.Text = message
    msgLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
    msgLabel.Font = Enum.Font.Gotham
    msgLabel.TextSize = 12
    msgLabel.TextXAlignment = Enum.TextXAlignment.Left
    msgLabel.TextWrapped = true
    
    notif.Position = UDim2.new(1, 0, 0, notif.Position.Y.Offset)
    Tween(notif, {Position = UDim2.new(1, -310, 0, notif.Position.Y.Offset)}, 0.4)
    
    task.delay(duration or 3, function()
        Tween(notif, {Position = UDim2.new(1, 0, 0, notif.Position.Y.Offset)}, 0.3)
        task.wait(0.3)
        notif:Destroy()
    end)
end

-- ============================================
-- 🪟 CREATE WINDOW
-- ============================================

function BloxyHub:CreateWindow(config)
    local Window = {
        Tabs = {},
        Theme = Themes[config.Theme] or Themes.Dark,
        Dragging = false,
    }
    
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "BloxyHub"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    if gethui then
        ScreenGui.Parent = gethui()
    else
        ScreenGui.Parent = game:GetService("CoreGui")
    end
    
    local Main = Instance.new("Frame")
    Main.Size = UDim2.new(0, 550, 0, 400)
    Main.Position = UDim2.new(0.5, -275, 0.5, -200)
    Main.BackgroundColor3 = Window.Theme.Background
    Main.BorderSizePixel = 0
    Main.Parent = ScreenGui
    Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 12)
    
    -- TopBar
    local TopBar = Instance.new("Frame", Main)
    TopBar.Size = UDim2.new(1, 0, 0, 40)
    TopBar.BackgroundColor3 = Window.Theme.Secondary
    TopBar.BorderSizePixel = 0
    Instance.new("UICorner", TopBar).CornerRadius = UDim.new(0, 12)
    
    local Title = Instance.new("TextLabel", TopBar)
    Title.Size = UDim2.new(1, -80, 1, 0)
    Title.Position = UDim2.new(0, 15, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Text = config.Title or "BloxyHub"
    Title.TextColor3 = Window.Theme.Text
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 16
    Title.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Close Button
    local CloseBtn = Instance.new("TextButton", TopBar)
    CloseBtn.Size = UDim2.new(0, 30, 0, 30)
    CloseBtn.Position = UDim2.new(1, -35, 0, 5)
    CloseBtn.BackgroundColor3 = Color3.fromRGB(239, 68, 68)
    CloseBtn.Text = "✕"
    CloseBtn.TextColor3 = Color3.new(1, 1, 1)
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.TextSize = 16
    CloseBtn.BorderSizePixel = 0
    Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 8)
    CloseBtn.MouseButton1Click:Connect(function()
        Tween(Main, {Size = UDim2.new(0, 0, 0, 0)}, 0.3)
        task.wait(0.3)
        ScreenGui:Destroy()
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
    
    -- Sidebar
    local Sidebar = Instance.new("ScrollingFrame", Main)
    Sidebar.Size = UDim2.new(0, 130, 1, -50)
    Sidebar.Position = UDim2.new(0, 10, 0, 45)
    Sidebar.BackgroundTransparency = 1
    Sidebar.BorderSizePixel = 0
    Sidebar.ScrollBarThickness = 4
    Sidebar.ScrollBarImageColor3 = Window.Theme.Accent
    Instance.new("UIListLayout", Sidebar).Padding = UDim.new(0, 5)
    
    -- Content
    local Content = Instance.new("Frame", Main)
    Content.Size = UDim2.new(1, -150, 1, -50)
    Content.Position = UDim2.new(0, 145, 0, 45)
    Content.BackgroundTransparency = 1
    Content.BorderSizePixel = 0
    
    -- ============================================
    -- 📑 CREATE TAB
    -- ============================================
    
    function Window:CreateTab(tabName)
        local Tab = {}
        
        local TabBtn = Instance.new("TextButton", Sidebar)
        TabBtn.Size = UDim2.new(1, 0, 0, 35)
        TabBtn.BackgroundColor3 = Window.Theme.Secondary
        TabBtn.Text = tabName
        TabBtn.TextColor3 = Window.Theme.Text
        TabBtn.Font = Enum.Font.GothamBold
        TabBtn.TextSize = 13
        TabBtn.BorderSizePixel = 0
        Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 8)
        
        local TabContainer = Instance.new("ScrollingFrame", Content)
        TabContainer.Size = UDim2.new(1, 0, 1, 0)
        TabContainer.BackgroundTransparency = 1
        TabContainer.BorderSizePixel = 0
        TabContainer.ScrollBarThickness = 4
        TabContainer.ScrollBarImageColor3 = Window.Theme.Accent
        TabContainer.Visible = false
        Instance.new("UIListLayout", TabContainer).Padding = UDim.new(0, 8)
        
        TabBtn.MouseButton1Click:Connect(function()
            for _, t in pairs(Window.Tabs) do
                t.Container.Visible = false
                t.Button.BackgroundColor3 = Window.Theme.Secondary
            end
            TabContainer.Visible = true
            TabBtn.BackgroundColor3 = Window.Theme.Accent
        end)
        
        if #Window.Tabs == 0 then
            TabBtn.BackgroundColor3 = Window.Theme.Accent
            TabContainer.Visible = true
        end
        
        table.insert(Window.Tabs, {Container = TabContainer, Button = TabBtn})
        
        -- ============================================
        -- 🔘 CREATE TOGGLE
        -- ============================================
        
        function Tab:CreateToggle(config)
            local value = config.Default or false
            
            local frame = Instance.new("Frame", TabContainer)
            frame.Size = UDim2.new(1, -5, 0, 40)
            frame.BackgroundColor3 = Window.Theme.Secondary
            frame.BorderSizePixel = 0
            Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)
            
            local label = Instance.new("TextLabel", frame)
            label.Size = UDim2.new(1, -60, 1, 0)
            label.Position = UDim2.new(0, 15, 0, 0)
            label.BackgroundTransparency = 1
            label.Text = config.Name
            label.TextColor3 = Window.Theme.Text
            label.Font = Enum.Font.GothamBold
            label.TextSize = 13
            label.TextXAlignment = Enum.TextXAlignment.Left
            
            local toggleBg = Instance.new("Frame", frame)
            toggleBg.Size = UDim2.new(0, 40, 0, 22)
            toggleBg.Position = UDim2.new(1, -45, 0.5, -11)
            toggleBg.BackgroundColor3 = value and Window.Theme.Accent or Color3.fromRGB(50, 50, 50)
            toggleBg.BorderSizePixel = 0
            Instance.new("UICorner", toggleBg).CornerRadius = UDim.new(1, 0)
            
            local circle = Instance.new("Frame", toggleBg)
            circle.Size = UDim2.new(0, 16, 0, 16)
            circle.Position = value and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
            circle.BackgroundColor3 = Color3.new(1, 1, 1)
            circle.BorderSizePixel = 0
            Instance.new("UICorner", circle).CornerRadius = UDim.new(1, 0)
            
            local btn = Instance.new("TextButton", frame)
            btn.Size = UDim2.new(1, 0, 1, 0)
            btn.BackgroundTransparency = 1
            btn.Text = ""
            
            btn.MouseButton1Click:Connect(function()
                value = not value
                Tween(toggleBg, {BackgroundColor3 = value and Window.Theme.Accent or Color3.fromRGB(50, 50, 50)}, 0.2)
                Tween(circle, {Position = value and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)}, 0.3)
                config.Callback(value)
            end)
        end
        
        -- ============================================
        -- 🎚️ CREATE SLIDER
        -- ============================================
        
        function Tab:CreateSlider(config)
            local value = config.Default or config.Min
            
            local frame = Instance.new("Frame", TabContainer)
            frame.Size = UDim2.new(1, -5, 0, 50)
            frame.BackgroundColor3 = Window.Theme.Secondary
            frame.BorderSizePixel = 0
            Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)
            
            local label = Instance.new("TextLabel", frame)
            label.Size = UDim2.new(1, -60, 0, 20)
            label.Position = UDim2.new(0, 15, 0, 5)
            label.BackgroundTransparency = 1
            label.Text = config.Name
            label.TextColor3 = Window.Theme.Text
            label.Font = Enum.Font.GothamBold
            label.TextSize = 13
            label.TextXAlignment = Enum.TextXAlignment.Left
            
            local valueLabel = Instance.new("TextLabel", frame)
            valueLabel.Size = UDim2.new(0, 40, 0, 20)
            valueLabel.Position = UDim2.new(1, -50, 0, 5)
            valueLabel.BackgroundTransparency = 1
            valueLabel.Text = tostring(value)
            valueLabel.TextColor3 = Window.Theme.Accent
            valueLabel.Font = Enum.Font.GothamBold
            valueLabel.TextSize = 13
            
            local sliderBg = Instance.new("Frame", frame)
            sliderBg.Size = UDim2.new(1, -30, 0, 5)
            sliderBg.Position = UDim2.new(0, 15, 1, -15)
            sliderBg.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
            sliderBg.BorderSizePixel = 0
            Instance.new("UICorner", sliderBg).CornerRadius = UDim.new(1, 0)
            
            local fill = Instance.new("Frame", sliderBg)
            fill.Size = UDim2.new((value - config.Min) / (config.Max - config.Min), 0, 1, 0)
            fill.BackgroundColor3 = Window.Theme.Accent
            fill.BorderSizePixel = 0
            Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)
            
            local btn = Instance.new("TextButton", sliderBg)
            btn.Size = UDim2.new(1, 0, 1, 0)
            btn.BackgroundTransparency = 1
            btn.Text = ""
            
            local dragging = false
            
            local function update(input)
                local pos = math.clamp((input.Position.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X, 0, 1)
                value = math.floor(config.Min + (config.Max - config.Min) * pos)
                valueLabel.Text = tostring(value)
                Tween(fill, {Size = UDim2.new(pos, 0, 1, 0)}, 0.1)
                config.Callback(value)
            end
            
            btn.MouseButton1Down:Connect(function() dragging = true end)
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
            end)
            UserInputService.InputChanged:Connect(function(input)
                if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then update(input) end
            end)
            btn.MouseButton1Click:Connect(function() update(UserInputService:GetMouseLocation()) end)
        end
        
        -- ============================================
        -- 🔲 CREATE BUTTON
        -- ============================================
        
        function Tab:CreateButton(config)
            local btn = Instance.new("TextButton", TabContainer)
            btn.Size = UDim2.new(1, -5, 0, 35)
            btn.BackgroundColor3 = Window.Theme.Accent
            btn.Text = config.Name
            btn.TextColor3 = Color3.new(1, 1, 1)
            btn.Font = Enum.Font.GothamBold
            btn.TextSize = 13
            btn.BorderSizePixel = 0
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
            
            btn.MouseButton1Click:Connect(function()
                Tween(btn, {BackgroundColor3 = Color3.fromRGB(70, 74, 200)}, 0.1)
                task.wait(0.1)
                Tween(btn, {BackgroundColor3 = Window.Theme.Accent}, 0.1)
                config.Callback()
            end)
        end
        
        -- ============================================
        -- ➕ CREATE INPUT (Nuevo)
        -- ============================================
        
        function Tab:CreateInput(config)
            local frame = Instance.new("Frame", TabContainer)
            frame.Size = UDim2.new(1, -5, 0, 40)
            frame.BackgroundColor3 = Window.Theme.Secondary
            frame.BorderSizePixel = 0
            Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)
            
            local input = Instance.new("TextBox", frame)
            input.Size = UDim2.new(1, -20, 1, -10)
            input.Position = UDim2.new(0, 10, 0, 5)
            input.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
            input.Text = config.Default or ""
            input.PlaceholderText = config.Placeholder or config.Name
            input.TextColor3 = Window.Theme.Text
            input.PlaceholderColor3 = Window.Theme.TextDark
            input.Font = Enum.Font.Gotham
            input.TextSize = 12
            input.BorderSizePixel = 0
            input.ClearTextOnFocus = false
            Instance.new("UICorner", input).CornerRadius = UDim.new(0, 6)
            
            input.FocusLost:Connect(function()
                config.Callback(input.Text)
            end)
        end
        
        -- ============================================
        -- 📋 CREATE DROPDOWN (Nuevo)
        -- ============================================
        
        function Tab:CreateDropdown(config)
            local frame = Instance.new("Frame", TabContainer)
            frame.Size = UDim2.new(1, -5, 0, 40)
            frame.BackgroundColor3 = Window.Theme.Secondary
            frame.BorderSizePixel = 0
            Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)
            
            local selected = config.Default or config.Options[1] or "None"
            
            local btn = Instance.new("TextButton", frame)
            btn.Size = UDim2.new(1, -20, 1, -10)
            btn.Position = UDim2.new(0, 10, 0, 5)
            btn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
            btn.Text = selected
            btn.TextColor3 = Window.Theme.Text
            btn.Font = Enum.Font.GothamBold
            btn.TextSize = 12
            btn.BorderSizePixel = 0
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
            
            local optionsFrame = Instance.new("Frame", frame)
            optionsFrame.Size = UDim2.new(1, -20, 0, #config.Options * 30)
            optionsFrame.Position = UDim2.new(0, 10, 1, 5)
            optionsFrame.BackgroundColor3 = Window.Theme.Secondary
            optionsFrame.BorderSizePixel = 0
            optionsFrame.Visible = false
            Instance.new("UICorner", optionsFrame).CornerRadius = UDim.new(0, 6)
            Instance.new("UIListLayout", optionsFrame).Padding = UDim.new(0, 2)
            
            for _, option in ipairs(config.Options) do
                local optBtn = Instance.new("TextButton", optionsFrame)
                optBtn.Size = UDim2.new(1, 0, 0, 28)
                optBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
                optBtn.Text = option
                optBtn.TextColor3 = Window.Theme.Text
                optBtn.Font = Enum.Font.Gotham
                optBtn.TextSize = 11
                optBtn.BorderSizePixel = 0
                
                optBtn.MouseButton1Click:Connect(function()
                    selected = option
                    btn.Text = option
                    optionsFrame.Visible = false
                    config.Callback(option)
                end)
            end
            
            btn.MouseButton1Click:Connect(function()
                optionsFrame.Visible = not optionsFrame.Visible
            end)
        end
        
        return Tab
    end
    
    return Window
end

return BloxyHub
