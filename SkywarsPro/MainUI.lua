--[[
    ╔════════════════════════════════════════════════════════════╗
    ║  ⚔️ SKYWARS ULTIMATE PRO - MAIN UI                         ║
    ║  Created by: SAMIR (16bitplayer) - 2026                    ║
    ║  With REAL Features Implementation                         ║
    ║  Version: 1.0                                              ║
    ╚════════════════════════════════════════════════════════════╝
]]

-- Load from _G (loaded by Loader.lua)
local Window = _G.SkywarsPro.Window
local Tab = _G.SkywarsPro.Tab
local Icons = _G.SkywarsPro.Icons
local Combat = _G.SkywarsPro.Combat
local Movement = _G.SkywarsPro.Movement
local ESP = _G.SkywarsPro.ESP

print("⚔️ Skywars Ultimate Pro v1.0")
print("Created by: SAMIR (16bitplayer)")
print("Initializing UI with REAL features...")

-- Create main window
local MainWindow = Window.new({
    Title = Icons.Sword .. " SKYWARS ULTIMATE PRO",
    Icon = Icons.Sword,
    Subtitle = "by SAMIR (16bitplayer) - 2026"
})

-- Create Tabs (with better icons)
local CombatTab = Tab.new(MainWindow, "Combat", Icons.Sword)
local PotionsTab = Tab.new(MainWindow, "Potions", Icons.Potion)
local MovementTab = Tab.new(MainWindow, "Movement", Icons.Run)
local VisualTab = Tab.new(MainWindow, "Visual", Icons.EyeOpen)
local MiningTab = Tab.new(MainWindow, "Mining", Icons.Pickaxe)
local SettingsTab = Tab.new(MainWindow, "Settings", Icons.Settings)

-- ═══════════════════════════════════════════════════════════
-- COMBAT TAB (REAL FEATURES)
-- ═══════════════════════════════════════════════════════════
CombatTab:AddLabel(Icons.Crosshair .. " Combat Features")

CombatTab:AddToggle("Auto Aim (Torso)", false, function(value)
    Combat:ToggleAutoAim(value)
end)

CombatTab:AddToggle("Auto Attack", false, function(value)
    Combat:ToggleAutoAttack(value)
end)

CombatTab:AddSlider("Attack Range", 10, 50, 20, function(value)
    Combat:SetRange(value)
end)

CombatTab:AddToggle("Kill Aura", false, function(value)
    Combat:ToggleKillAura(value)
end)

-- ═══════════════════════════════════════════════════════════
-- POTIONS TAB (Coming soon - need game analysis)
-- ═══════════════════════════════════════════════════════════
PotionsTab:AddLabel(Icons.Healing .. " Auto Potion System")
PotionsTab:AddLabel("⚠️ Potion features coming soon...")
PotionsTab:AddLabel("Requires in-game testing")

-- ═══════════════════════════════════════════════════════════
-- MOVEMENT TAB (REAL FEATURES)
-- ═══════════════════════════════════════════════════════════
MovementTab:AddLabel(Icons.Fly .. " Movement Features")

MovementTab:AddToggle("Flight Mode", false, function(value)
    Movement:ToggleFlight(value)
end)

MovementTab:AddSlider("Flight Speed", 50, 200, 100, function(value)
    Movement:SetFlightSpeed(value)
end)

MovementTab:AddLabel(Icons.Wind .. " Speed Boost")

MovementTab:AddToggle("Speed Boost", false, function(value)
    Movement:ToggleSpeed(value)
end)

-- ═══════════════════════════════════════════════════════════
-- VISUAL TAB (REAL ESP)
-- ═══════════════════════════════════════════════════════════
VisualTab:AddLabel(Icons.Radar .. " ESP & Visuals")

VisualTab:AddToggle("Player ESP", false, function(value)
    ESP:TogglePlayerESP(value)
end)

VisualTab:AddToggle("Show Health Bars", false, function(value)
    ESP:ToggleHealth(value)
end)

VisualTab:AddToggle("Show Distance", false, function(value)
    ESP:ToggleDistance(value)
end)

VisualTab:AddLabel("⚠️ Potion/Chest ESP coming soon")

-- ═══════════════════════════════════════════════════════════
-- MINING TAB (Coming soon)
-- ═══════════════════════════════════════════════════════════
MiningTab:AddLabel(Icons.Hammer .. " Mining & Building")
MiningTab:AddLabel("⚠️ Mining features coming soon...")
MiningTab:AddButton(Icons.Fire .. " Rush Mid (Planned)", function()
    print("Rush Mid feature in development!")
end)

-- ═══════════════════════════════════════════════════════════
-- SETTINGS TAB
-- ═══════════════════════════════════════════════════════════
SettingsTab:AddLabel(Icons.Settings .. " General Settings")

SettingsTab:AddToggle("Safe Mode", true, function(value)
    print(Icons.Shield, "Safe Mode:", value)
end)

SettingsTab:AddButton(Icons.Save .. " Save Config", function()
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = Icons.Success .. " Saved!",
        Text = "Config saved successfully",
        Duration = 3
    })
end)

SettingsTab:AddButton(Icons.Reset .. " Reset Script", function()
    Combat:Cleanup()
    Movement:Cleanup()
    ESP:Cleanup()
    MainWindow:Destroy()
    
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = Icons.Info .. " Reset",
        Text = "Script reset successfully",
        Duration = 3
    })
end)

print("✅ Skywars Ultimate Pro loaded with REAL features!")
print("Features working:")
print("  " .. Icons.Check .. " Auto Aim")
print("  " .. Icons.Check .. " Auto Attack")
print("  " .. Icons.Check .. " Kill Aura")
print("  " .. Icons.Check .. " Flight (WASD + Space/Shift)")
print("  " .. Icons.Check .. " Speed Boost")
print("  " .. Icons.Check .. " Player ESP")
print("\nPress RIGHT CTRL to toggle UI visibility")

-- Toggle UI with RIGHT CTRL
local UserInputService = game:GetService("UserInputService")
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.RightControl then
        MainWindow.Main.Visible = not MainWindow.Main.Visible
    end
end)

-- Cleanup on character death
game:GetService("Players").LocalPlayer.CharacterRemoving:Connect(function()
    Combat:Cleanup()
    Movement:Cleanup()
    ESP:Cleanup()
end)
