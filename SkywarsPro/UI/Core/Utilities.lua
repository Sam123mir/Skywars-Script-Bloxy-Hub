--[[
    ╔════════════════════════════════════════════════════════════╗
    ║  🔧 SKYWARS ULTIMATE PRO - UTILITY FUNCTIONS               ║
    ║  Created by: SAMIR (16bitplayer) - 2026                    ║
    ║  Helper functions for UI creation                          ║
    ╚════════════════════════════════════════════════════════════╝
]]

local TweenService = game:GetService("TweenService")
local Utilities = {}

-- Create instance with properties
function Utilities:Create(className, properties)
    local instance = Instance.new(className)
    
    for prop, value in pairs(properties) do
        if prop ~= "Parent" then
            instance[prop] = value
        end
    end
    
    -- Set parent last to avoid unnecessary replication
    if properties.Parent then
        instance.Parent = properties.Parent
    end
    
    return instance
end

-- Smooth tween animation
function Utilities:Tween(instance, goal, duration, easingStyle, easingDirection, callback)
    duration = duration or 0.3
    easingStyle = easingStyle or Enum.EasingStyle.Quart
    easingDirection = easingDirection or Enum.EasingDirection.Out
    
    local tweenInfo = TweenInfo.new(duration, easingStyle, easingDirection)
    local tween = TweenService:Create(instance, tweenInfo, goal)
    
    if callback then
        tween.Completed:Connect(callback)
    end
    
    tween:Play()
    return tween
end

-- Add rounded corner
function Utilities:AddCorner(parent, radius)
    return self:Create("UICorner", {
        CornerRadius = radius or UDim.new(0, 12),
        Parent = parent
    })
end

-- Add stroke/border
function Utilities:AddStroke(parent, color, thickness, transparency)
    return self:Create("UIStroke", {
        Color = color,
        Thickness = thickness or 1.5,
        Transparency = transparency or 0.5,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Parent = parent
    })
end

-- Add gradient
function Utilities:AddGradient(parent, colorSequence, rotation)
    return self:Create("UIGradient", {
        Color = colorSequence,
        Rotation = rotation or 0,
        Parent = parent
    })
end

-- Add padding
function Utilities:AddPadding(parent, all, top, bottom, left, right)
    if all then
        return self:Create("UIPadding", {
            PaddingTop = UDim.new(0, all),
            PaddingBottom = UDim.new(0, all),
            PaddingLeft = UDim.new(0, all),
            PaddingRight = UDim.new(0, all),
            Parent = parent
        })
    else
        return self:Create("UIPadding", {
            PaddingTop = UDim.new(0, top or 0),
            PaddingBottom = UDim.new(0, bottom or 0),
            PaddingLeft = UDim.new(0, left or 0),
            PaddingRight = UDim.new(0, right or 0),
            Parent = parent
        })
    end
end

-- Add list layout
function Utilities:AddListLayout(parent, padding, fillDirection, horizontalAlignment, verticalAlignment)
    return self:Create("UIListLayout", {
        Padding = UDim.new(0, padding or 8),
        FillDirection = fillDirection or Enum.FillDirection.Vertical,
        HorizontalAlignment = horizontalAlignment or Enum.HorizontalAlignment.Left,
        VerticalAlignment = verticalAlignment or Enum.VerticalAlignment.Top,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = parent
    })
end

-- Drag functionality for frames
function Utilities:MakeDraggable(frame, dragHandle)
    local UserInputService = game:GetService("UserInputService")
    dragHandle = dragHandle or frame
    
    local dragging = false
    local dragInput, dragStart, startPos
    
    local function update(input)
        local delta = input.Position - dragStart
        self:Tween(frame, {
            Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        }, 0.1)
    end
    
    dragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or 
           input.UserInputType == Enum.UserInputType.Touch then
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
    
    dragHandle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or
           input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input == dragInput then
            update(input)
        end
    end)
end

-- Rainbow color cycle (for cool effects)
function Utilities:RainbowColor(speed)
    speed = speed or 1
    local hue = tick() * speed % 1
    return Color3.fromHSV(hue, 1, 1)
end

-- Lerp number
function Utilities:Lerp(a, b, t)
    return a + (b - a) * t
end

-- Clamp number
function Utilities:Clamp(value, min, max)
    return math.max(min, math.min(max, value))
end

-- Format number with commas
function Utilities:FormatNumber(number)
    local formatted = tostring(number)
    while true do
        formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
        if k == 0 then break end
    end
    return formatted
end

-- Short number format (1000 -> 1K)
function Utilities:ShortNumber(number)
    if number >= 1000000 then
        return string.format("%.1fM", number / 1000000)
    elseif number >= 1000 then
        return string.format("%.1fK", number / 1000)
    else
        return tostring(number)
    end
end

return Utilities
