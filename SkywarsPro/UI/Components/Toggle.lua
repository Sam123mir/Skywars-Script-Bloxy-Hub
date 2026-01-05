--[[
    ╔════════════════════════════════════════════════════════════╗
    ║  🎚️ SKYWARS ULTIMATE PRO - TOGGLE COMPONENT               ║
    ║  Created by: SAMIR (16bitplayer) - 2026                    ║
    ║  Professional toggle switch with smooth animations         ║
    ╚════════════════════════════════════════════════════════════╝
]]

local Theme = require(script.Parent.Parent.Core.Theme)
local Utils = require(script.Parent.Parent.Core.Utilities)

local Toggle = {}

function Toggle.new(tab, name, default, callback)
    local value = default or false
    
    -- Container
    local container = Utils:Create("Frame", {
        Name = name .. "_Toggle",
        Size = UDim2.new(1, 0, 0, Theme.Sizing.ComponentHeight),
        BackgroundColor3 = Theme.Background.Secondary,
        BorderSizePixel = 0,
        Parent = tab.Container
    })
    Utils:AddCorner(container, UDim.new(0, 8))
    Utils:AddStroke(container, Theme.Border, 1, 0.7)
    
    -- Label
    local label = Utils:Create("TextLabel", {
        Size = UDim2.new(1, -70, 1, 0),
        Position = UDim2.new(0, 15, 0, 0),
        BackgroundTransparency = 1,
        Text = name,
        Font = Theme.Fonts.Body,
        TextSize = Theme.FontSizes.Body,
        TextColor3 = Theme.Text.Primary,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = container
    })
    
    -- Toggle Background
    local toggleBg = Utils:Create("Frame", {
        Name = "ToggleBG",
        Size = UDim2.new(0, 50, 0, 26),
        Position = UDim2.new(1, -60, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = value and Theme.Accent.Primary or Theme.Background.Tertiary,
        BorderSizePixel = 0,
        Parent = container
    })
    Utils:AddCorner(toggleBg, UDim.new(1, 0)) -- Fully rounded
    
    -- Gradient for active state
    if value then
        Utils:AddGradient(toggleBg, Theme:GetAccentGradient(), 90)
    end
    
    -- Toggle Circle
    local circle = Utils:Create("Frame", {
        Name = "Circle",
        Size = UDim2.new(0, 22, 0, 22),
        Position = value and UDim2.new(1, -24, 0.5, 0) or UDim2.new(0, 2, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = Color3.new(1, 1, 1),
        BorderSizePixel = 0,
        Parent = toggleBg
    })
    Utils:AddCorner(circle, UDim.new(1, 0))
    
    -- Shadow on circle
    local circleShadow = Utils:Create("UIStroke", {
        Color = Theme.Shadow,
        Thickness = 2,
        Transparency = 0.8,
        Parent = circle
    })
    
    -- Click Button (invisible, covers whole container)
    local button = Utils:Create("TextButton", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "",
        Parent = container
    })
    
    -- Toggle function
    local function toggle()
        value = not value
        
        -- Animate background
        if value then
            Utils:Tween(toggleBg, {BackgroundColor3 = Theme.Accent.Primary}, Theme.Animations.Fast)
            -- Add gradient
            if not toggleBg:FindFirstChild("UIGradient") then
                Utils:AddGradient(toggleBg, Theme:GetAccentGradient(), 90)
            end
        else
            Utils:Tween(toggleBg, {BackgroundColor3 = Theme.Background.Tertiary}, Theme.Animations.Fast)
            -- Remove gradient
            local gradient = toggleBg:FindFirstChild("UIGradient")
            if gradient then
                gradient:Destroy()
            end
        end
        
        -- Animate circle position
        local targetPos = value and UDim2.new(1, -24, 0.5, 0) or UDim2.new(0, 2, 0.5, 0)
        Utils:Tween(circle, {Position = targetPos}, Theme.Animations.Fast, Enum.EasingStyle.Back)
        
        -- Callback
        if callback then
            task.spawn(callback, value)
        end
    end
    
    button.MouseButton1Click:Connect(toggle)
    
    -- Hover effect
    button.MouseEnter:Connect(function()
        Utils:Tween(container, {BackgroundColor3 = Theme.Background.Hover}, Theme.Animations.Fast)
    end)
    
    button.MouseLeave:Connect(function()
        Utils:Tween(container, {BackgroundColor3 = Theme.Background.Secondary}, Theme.Animations.Fast)
    end)
    
    -- Return control object
    return {
        SetValue = function(newValue)
            if newValue ~= value then
                toggle()
            end
        end,
        GetValue = function()
            return value
        end,
        Destroy = function()
            container:Destroy()
        end
    }
end

return Toggle
