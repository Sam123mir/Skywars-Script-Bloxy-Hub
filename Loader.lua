--[[
    ╔════════════════════════════════════════════════════════════╗
    ║  📦 SKYWARS ULTIMATE PRO - LOADER                          ║
    ║  Created by: SAMIR (16bitplayer) - 2026                    ║
    ║  Loads all modules from GitHub                            ║
    ╚════════════════════════════════════════════════════════════╝
]]

-- GitHub raw URL base
local BASE_URL = "https://raw.githubusercontent.com/Sam123mir/Skywars-Script-Bloxy-Hub/main/"

-- Loading notification
local function notify(title, text, duration)
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = title,
        Text = text,
        Duration = duration or 3
    })
end

print("⚔️ Skywars Ultimate Pro - Loader")
print("Loading components...")

-- Load Key System first
notify("⚔️ Skywars Pro", "Loading Key System...", 2)
local KeySystem = loadstring(game:HttpGet(BASE_URL .. "KeySystem.lua"))()

-- Verify key before loading
KeySystem:Verify(function(keyData)
    notify("✅ Welcome!", "Key verified: " .. keyData.tier, 3)
    
    -- Load UI components into _G for sharing
    notify("📦 Loading", "UI Components...", 2)
    
    _G.SkywarsPro = _G.SkywarsPro or {}
    
    -- Load Theme
    _G.SkywarsPro.Theme = loadstring(game:HttpGet(BASE_URL .. "SkywarsPro/UI/Core/Theme.lua"))()
    
    -- Load Utilities
    _G.SkywarsPro.Utils = loadstring(game:HttpGet(BASE_URL .. "SkywarsPro/UI/Core/Utilities.lua"))()
    
    -- Load Icons
    _G.SkywarsPro.Icons = loadstring(game:HttpGet(BASE_URL .. "SkywarsPro/UI/Core/Icons.lua"))()
    
    -- Load Components
    _G.SkywarsPro.Window = loadstring(game:HttpGet(BASE_URL .. "SkywarsPro/UI/Components/Window.lua"))()
    _G.SkywarsPro.Tab = loadstring(game:HttpGet(BASE_URL .. "SkywarsPro/UI/Components/Tab.lua"))()
    _G.SkywarsPro.Toggle = loadstring(game:HttpGet(BASE_URL .. "SkywarsPro/UI/Components/Toggle.lua"))()
    _G.SkywarsPro.Slider = loadstring(game:HttpGet(BASE_URL .. "SkywarsPro/UI/Components/Slider.lua"))()
    _G.SkywarsPro.Button = loadstring(game:HttpGet(BASE_URL .. "SkywarsPro/UI/Components/Button.lua"))()
    
    notify("🔧 Loading", "Features...", 2)
    
    -- Load Features
    _G.SkywarsPro.Combat = loadstring(game:HttpGet(BASE_URL .. "SkywarsPro/Features/Combat.lua"))()
    _G.SkywarsPro.Movement = loadstring(game:HttpGet(BASE_URL .. "SkywarsPro/Features/Movement.lua"))()
    _G.SkywarsPro.ESP = loadstring(game:HttpGet(BASE_URL .. "SkywarsPro/Features/ESP.lua"))()
    
    notify("✅ Loaded", "All components ready!", 2)
    task.wait(0.5)
    
    -- Load main script
    notify("🚀 Starting", "Skywars Ultimate Pro...", 2)
    loadstring(game:HttpGet(BASE_URL .. "SkywarsPro/MainUI.lua"))()
end)
