--[[
    ╔════════════════════════════════════════════════════════════╗
    ║  🔘 SKYWARS ULTIMATE PRO - BUTTON COMPONENT                ║
    ║  Created by: SAMIR (16bitplayer) - 2026                    ║
    ║  Professional button with animations                       ║
    ╚════════════════════════════════════════════════════════════╝
]]

local Theme = require(script.Parent.Parent.Core.Theme)
local Utils = require(script.Parent.Parent.Core.Utilities)

local Button = {}

function Button.new(tab, name, callback)
    -- Button
    local btn = Utils:Create("TextButton", {
        Name = name .. "_Button",
        Size = UDim2.new(1, 0, 0, Theme.Sizing.ComponentHeight),
        BackgroundColor3 = Theme.Accent.Primary,
        Text = "",
        BorderSizePixel = 0,
        AutoButtonColor = false,
        Parent = tab.Container
    })
    Utils:AddCorner(btn, UDim.new(0, 8))
    Utils:AddGradient(btn, Theme:GetAccentGradient(), 45)
    Utils:AddStroke(btn, Theme.Accent.Glow, 1.5, 0.3)
    
    -- Button Label
    local label = Utils:Create("TextLabel", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = name,
        Font = Theme.Fonts.Header,
        TextSize = Theme.FontSizes.Header,
        TextColor3 = Theme.Text.Primary,
        Parent = btn
    })
    
    -- Click animation and callback
    btn.MouseButton1Click:Connect(function()
        -- Flash effect
        Utils:Tween(btn, {BackgroundColor3 = Theme.Accent.Secondary}, 0.1)
        task.wait(0.1)
        Utils:Tween(btn, {BackgroundColor3 = Theme.Accent.Primary}, 0.1)
        
        -- Callback
        if callback then
            task.spawn(callback)
        end
    end)
    
    -- Hover effects
    btn.MouseEnter:Connect(function()
        Utils:Tween(btn, {Size = UDim2.new(1, 0, 0, Theme.Sizing.ComponentHeight + 4)}, Theme.Animations.Fast, Enum.EasingStyle.Back)
        Utils:Tween(btn:FindFirstChild("UIStroke"), {Transparency = 0}, Theme.Animations.Fast)
    end)
    
    btn.MouseLeave:Connect(function()
        Utils:Tween(btn, {Size = UDim2.new(1, 0, 0, Theme.Sizing.ComponentHeight)}, Theme.Animations.Fast)
        Utils:Tween(btn:FindFirstChild("UIStroke"), {Transparency = 0.3}, Theme.Animations.Fast)
    end)
    
    return {
        SetText = function(text)
            label.Text = text
        end,
        Destroy = function()
            btn:Destroy()
        end
    }
end

return Button
