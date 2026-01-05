--[[
    ╔════════════════════════════════════════════════════════════╗
    ║  🎨 SKYWARS ULTIMATE PRO - CUSTOM UI LIBRARY               ║
    ║  Created by: SAMIR (16bitplayer) - 2026                    ║
    ║  Theme System - Professional Color Palette                 ║
    ╚════════════════════════════════════════════════════════════╝
]]

-- No dependencies, standalone module

local Theme = {
    -- Background colors (Dark Mode)
    Background = {
        Main = Color3.fromRGB(8, 8, 12),        -- #08080C - Ultra dark
        Secondary = Color3.fromRGB(16, 16, 24),  -- #101018 - Dark elevated
        Tertiary = Color3.fromRGB(22, 22, 32),   -- #161620 - Elevated
        Hover = Color3.fromRGB(28, 28, 40),      -- #1C1C28 - Hover state
        Glass = Color3.fromRGB(18, 18, 26),      -- #12121A - Glassmorphism
    },
    
    -- Accent colors (Vibrant)
    Accent = {
        Primary = Color3.fromRGB(109, 112, 255),   -- #6D70FF - Indigo (main)
        Secondary = Color3.fromRGB(149, 102, 255), -- #9566FF - Purple
        Success = Color3.fromRGB(26, 195, 139),    -- #1AC38B - Green
        Warning = Color3.fromRGB(255, 168, 21),    -- #FFA815 - Orange
        Danger = Color3.fromRGB(249, 78, 78),      -- #F94E4E - Red
        Glow = Color3.fromRGB(119, 122, 255),      -- #777AFF - Glow effect
        Info = Color3.fromRGB(59, 130, 246),       -- #3B82F6 - Blue
    },
    
    -- Text colors
    Text = {
        Primary = Color3.fromRGB(255, 255, 255),   -- #FFFFFF - White
        Secondary = Color3.fromRGB(166, 173, 185), -- #A6ADB9 - Light gray
        Muted = Color3.fromRGB(117, 124, 138),     -- #757C8A - Muted gray
        Disabled = Color3.fromRGB(80, 80, 90),     -- #50505A - Disabled
    },
    
    -- Border and strokes
    Border = Color3.fromRGB(42, 42, 52),           -- #2A2A34
    Shadow = Color3.fromRGB(0, 0, 0),              -- #000000
    
    -- UI Element sizes
    Sizing = {
        CornerRadius = UDim.new(0, 12),            -- Rounded corners
        StrokeThickness = 1.5,                     -- Border thickness
        WindowWidth = 700,
        WindowHeight = 500,
        TopBarHeight = 50,
        SidebarWidth = 180,
        ComponentHeight = 45,
        ComponentSpacing = 8,
    },
    
    -- Fonts
    Fonts = {
        Header = Enum.Font.GothamBold,
        Body = Enum.Font.Gotham,
        Mono = Enum.Font.Code,
    },
    
    -- Font sizes
    FontSizes = {
        Title = 18,
        Header = 16,
        Body = 14,
        Small = 12,
        Tiny = 10,
    },
    
    -- Transparency values
    Transparency = {
        Solid = 0,
        SemiTransparent = 0.3,
        Faded = 0.7,
        AlmostInvisible = 0.9,
    },
    
    -- Animation durations (seconds)
    Animations = {
        Fast = 0.15,
        Normal = 0.3,
        Slow = 0.5,
    },
}

-- Helper: Get gradient for buttons/toggles
function Theme:GetAccentGradient()
    return ColorSequence.new{
        ColorSequenceKeypoint.new(0, self.Accent.Primary),
        ColorSequenceKeypoint.new(1, self.Accent.Secondary)
    }
end

-- Helper: Get background gradient
function Theme:GetBackgroundGradient()
    return ColorSequence.new{
        ColorSequenceKeypoint.new(0, self.Background.Secondary),
        ColorSequenceKeypoint.new(1, self.Background.Glass)
    }
end

-- Helper: Get notification color by type
function Theme:GetNotificationColor(notifType)
    local colors = {
        success = self.Accent.Success,
        warning = self.Accent.Warning,
        error = self.Accent.Danger,
        info = self.Accent.Info,
        primary = self.Accent.Primary
    }
    return colors[notifType] or self.Accent.Primary
end

return Theme
