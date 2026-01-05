--[[
    ╔════════════════════════════════════════════════════════════╗
    ║  📏 SKYWARS ULTIMATE PRO - SLIDER COMPONENT                ║
    ║  Created by: SAMIR (16bitplayer) - 2026                    ║
    ║  Professional slider with value display                    ║
    ╚════════════════════════════════════════════════════════════╝
]]

local Theme = require(script.Parent.Parent.Core.Theme)
local Utils = require(script.Parent.Parent.Core.Utilities)

local Slider = {}

function Slider.new(tab, name, min, max, default, callback)
    min = min or 0
    max = max or 100
    local value = default or min
    
    -- Container
    local container = Utils:Create("Frame", {
        Name = name .. "_Slider",
        Size = UDim2.new(1, 0, 0, Theme.Sizing.ComponentHeight),
        BackgroundColor3 = Theme.Background.Secondary,
        BorderSizePixel = 0,
        Parent = tab.Container
    })
    Utils:AddCorner(container, UDim.new(0, 8))
    Utils:AddStroke(container, Theme.Border, 1, 0.7)
    
    -- Label
    local label = Utils:Create("TextLabel", {
        Size = UDim2.new(0.6, 0, 0, 20),
        Position = UDim2.new(0, 15, 0, 8),
        BackgroundTransparency = 1,
        Text = name,
        Font = Theme.Fonts.Body,
        TextSize = Theme.FontSizes.Body,
        TextColor3 = Theme.Text.Primary,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = container
    })
    
    -- Value Display
    local valueDisplay = Utils:Create("TextLabel", {
        Size = UDim2.new(0, 50, 0, 20),
        Position = UDim2.new(1, -65, 0, 8),
        BackgroundTransparency = 1,
        Text = tostring(value),
        Font = Theme.Fonts.Mono,
        TextSize = Theme.FontSizes.Body,
        TextColor3 = Theme.Accent.Primary,
        TextXAlignment = Enum.TextXAlignment.Right,
        Parent = container
    })
    
    -- Slider Track
    local track = Utils:Create("Frame", {
        Size = UDim2.new(1, -30, 0, 6),
        Position = UDim2.new(0, 15, 1, -16),
        BackgroundColor3 = Theme.Background.Tertiary,
        BorderSizePixel = 0,
        Parent = container
    })
    Utils:AddCorner(track, UDim.new(1, 0))
    
    -- Slider Fill
    local fill = Utils:Create("Frame", {
        Size = UDim2.new((value - min) / (max - min), 0, 1, 0),
        BackgroundColor3 = Theme.Accent.Primary,
        BorderSizePixel = 0,
        Parent = track
    })
    Utils:AddCorner(fill, UDim.new(1, 0))
    Utils:AddGradient(fill, Theme:GetAccentGradient(), 90)
    
    -- Slider Thumb
    local thumb = Utils:Create("Frame", {
        Size = UDim2.new(0, 16, 0, 16),
        Position = UDim2.new((value - min) / (max - min), -8, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = Color3.new(1, 1, 1),
        BorderSizePixel = 0,
        ZIndex = 2,
        Parent = track
    })
    Utils:AddCorner(thumb, UDim.new(1, 0))
    Utils:AddStroke(thumb, Theme.Accent.Glow, 2, 0.5)
    
    -- Dragging logic
    local dragging = false
    local UserInputService = game:GetService("UserInputService")
    
    local function updateValue(input)
        local relativeX = Utils:Clamp(input.Position.X - track.AbsolutePosition.X, 0, track.AbsoluteSize.X)
        local percent = relativeX / track.AbsoluteSize.X
        value = math.floor(min + (max - min) * percent)
        
        -- Update UI
        fill.Size = UDim2.new(percent, 0, 1, 0)
        thumb.Position = UDim2.new(percent, -8, 0.5, 0)
        valueDisplay.Text = tostring(value)
        
        -- Callback
        if callback then
            callback(value)
        end
    end
    
    thumb.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or
           input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
        end
    end)
    
    thumb.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or
           input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or
           input.UserInputType == Enum.UserInputType.Touch) then
            updateValue(input)
        end
    end)
    
    -- Click on track to jump
    track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            updateValue(input)
        end
    end)
    
    -- Hover effect
    local hoverConnection
    hoverConnection = container.MouseEnter:Connect(function()
        Utils:Tween(container, {BackgroundColor3 = Theme.Background.Hover}, Theme.Animations.Fast)
        Utils:Tween(thumb, {Size = UDim2.new(0, 20, 0, 20)}, Theme.Animations.Fast, Enum.EasingStyle.Back)
    end)
    
    container.MouseLeave:Connect(function()
        Utils:Tween(container, {BackgroundColor3 = Theme.Background.Secondary}, Theme.Animations.Fast)
        Utils:Tween(thumb, {Size = UDim2.new(0, 16, 0, 16)}, Theme.Animations.Fast)
    end)
    
    -- Return control object
    return {
        SetValue = function(newValue)
            value = Utils:Clamp(newValue, min, max)
            local percent = (value - min) / (max - min)
            fill.Size = UDim2.new(percent, 0, 1, 0)
            thumb.Position = UDim2.new(percent, -8, 0.5, 0)
            valueDisplay.Text = tostring(value)
        end,
        GetValue = function()
            return value
        end,
        Destroy = function()
            if hoverConnection then hoverConnection:Disconnect() end
            container:Destroy()
        end
    }
end

return Slider
