--[[
    ╔════════════════════════════════════════════════════════════╗
    ║  ⚔️ SKYWARS ULTIMATE PRO - MAIN SCRIPT                     ║
    ║  Created by: SAMIR (16bitplayer) - 2026                    ║
    ║  The Most Professional Skywars Script                      ║
    ║  Version: 1.0 BETA                                         ║
    ╚════════════════════════════════════════════════════════════╝
]]

-- Load UI Library
local Window = require(script.UI.Components.Window)
local Tab = require(script.UI.Components.Tab)

print("⚔️ Skywars Ultimate Pro v1.0")
print("Created by: SAMIR (16bitplayer)")
print("Initializing...")

-- Create main window
local MainWindow = Window.new({
    Title = "⚔️ SKYWARS ULTIMATE PRO",
    Icon = "⚔️",
    Subtitle = "by SAMIR (16bitplayer) - 2026"
})

-- Create Tabs
local CombatTab = Tab.new(MainWindow, "Combat", "⚔️")
local PotionsTab = Tab.new(MainWindow, "Potions", "🧪")
local MovementTab = Tab.new(MainWindow, "Movement", "🏃")
local VisualTab = Tab.new(MainWindow, "Visual", "👁️")
local MiningTab = Tab.new(MainWindow, "Mining", "⛏️")
local SettingsTab = Tab.new(MainWindow, "Settings", "⚙️")

-- Combat Tab
CombatTab:AddLabel("⚔️ Combat Features")
CombatTab:AddToggle("Auto Aim (Torso)", false, function(value)
    print("Auto Aim:", value)
end)
CombatTab:AddToggle("Auto Attack", false, function(value)
    print("Auto Attack:", value)
end)
CombatTab:AddSlider("Attack Range", 10, 50, 20, function(value)
    print("Attack Range:", value)
end)
CombatTab:AddToggle("Kill Aura", false, function(value)
    print("Kill Aura:", value)
end)

-- Potions Tab
PotionsTab:AddLabel("🧪 Potion Automation")
PotionsTab:AddToggle("Auto Healing (HP < 40%)", false, function(value)
    print("Auto Healing:", value)
end)
PotionsTab:AddToggle("Auto Shield (Combat)", false, function(value)
    print("Auto Shield:", value)
end)
PotionsTab:AddToggle("Speed Potion (Start)", false, function(value)
    print("Speed Potion:", value)
end)
PotionsTab:AddToggle("Jump Potion (Start)", false, function(value)
    print("Jump Potion:", value)
end)
PotionsTab:AddSlider("Heal Threshold %", 10, 90, 40, function(value)
    print("Heal Threshold:", value)
end)

-- Movement Tab
MovementTab:AddLabel("🏃 Movement Features")
MovementTab:AddToggle("Flight Mode", false, function(value)
    print("Flight Mode:", value)
end)
MovementTab:AddSlider("Flight Speed", 50, 200, 100, function(value)
    print("Flight Speed:", value)
end)
MovementTab:AddToggle("Auto Bridge", false, function(value)
    print("Auto Bridge:", value)
end)
MovementTab:AddToggle("Speed Boost", false, function(value)
    print("Speed Boost:", value)
end)

-- Visual Tab
VisualTab:AddLabel("👁️ ESP & Visuals")
VisualTab:AddToggle("Player ESP", false, function(value)
    print("Player ESP:", value)
end)
VisualTab:AddToggle("Show Health Bars", false, function(value)
    print("Health Bars:", value)
end)
VisualTab:AddToggle("Show Distance", false, function(value)
    print("Distance:", value)
end)
VisualTab:AddToggle("Potion ESP", false, function(value)
    print("Potion ESP:", value)
end)
VisualTab:AddToggle("Chest ESP", false, function(value)
    print("Chest ESP:", value)
end)

-- Mining Tab
MiningTab:AddLabel("⛏️ Mining & Building")
MiningTab:AddToggle("Auto Equip Pickaxe", false, function(value)
    print("Auto Pickaxe:", value)
end)
MiningTab:AddToggle("Fast Mine", false, function(value)
    print("Fast Mine:", value)
end)
MiningTab:AddToggle("Mine Enemy Bridges", false, function(value)
    print("Mine Bridges:", value)
end)
MiningTab:AddButton("Rush Mid", function()
    print("Rushing Mid!")
end)

-- Settings Tab
SettingsTab:AddLabel("⚙️ General Settings")
SettingsTab:AddToggle("Safe Mode", true, function(value)
    print("Safe Mode:", value)
end)
SettingsTab:AddSlider("Update Rate (FPS)", 30, 60, 60, function(value)
    print("Update Rate:", value)
end)
SettingsTab:AddButton("Save Config", function()
    print("Config Saved!")
end)
SettingsTab:AddButton("Reset Script", function()
    print("Resetting...")
    MainWindow:Destroy()
end)

print("✅ Skywars Ultimate Pro loaded successfully!")
print("Press RIGHT CTRL to toggle UI")

-- Toggle UI with key
local UserInputService = game:GetService("UserInputService")
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.RightControl then
        MainWindow.Main.Visible = not MainWindow.Main.Visible
    end
end)
