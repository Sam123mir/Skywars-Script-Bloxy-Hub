--[[
    ╔════════════════════════════════════════════════════════════╗
    ║  ⚔️ SKYWARS ULTIMATE PRO - COMBAT FEATURES                 ║
    ║  Created by: SAMIR (16bitplayer) - 2026                    ║
    ║  Real combat functionality                                 ║
    ╚════════════════════════════════════════════════════════════╝
]]

local Combat = {}
Combat.Enabled = {
    AutoAim = false,
    AutoAttack = false,
    KillAura = false
}
Combat.Settings = {
    AttackRange = 20,
    AimPart = "Torso"  -- Apuntar al torso (helmets deflect headshots)
}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Player = Players.LocalPlayer

-- Get closest enemy
local function getClosestEnemy()
    local closestPlayer = nil
    local shortestDistance = Combat.Settings.AttackRange
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= Player and player.Character and player.Character:FindFirstChild("Humanoid") then
            local humanoid = player.Character.Humanoid
            if humanoid.Health > 0 then
                local hrp = player.Character:FindFirstChild("HumanoidRootPart")
                if hrp and Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
                    local distance = (hrp.Position - Player.Character.HumanoidRootPart.Position).Magnitude
                    if distance < shortestDistance then
                        shortestDistance = distance
                        closestPlayer = player
                    end
                end
            end
        end
    end
    
    return closestPlayer
end

-- Auto Aim
local aimConnection
function Combat:ToggleAutoAim(enabled)
    self.Enabled.AutoAim = enabled
    
    if enabled then
        if aimConnection then aimConnection:Disconnect() end
        
        aimConnection = RunService.Heartbeat:Connect(function()
            if not self.Enabled.AutoAim then return end
            
            local target = getClosestEnemy()
            if target and target.Character then
                local aimPart = target.Character:FindFirstChild(self.Settings.AimPart) or target.Character:FindFirstChild("HumanoidRootPart")
                if aimPart and Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
                    -- Aim camera at target
                    local camera = workspace.CurrentCamera
                    camera.CFrame = CFrame.new(camera.CFrame.Position, aimPart.Position)
                end
            end
        end)
        
        print("✅ Auto Aim: ENABLED")
    else
        if aimConnection then
            aimConnection:Disconnect()
            aimConnection = nil
        end
        print("❌ Auto Aim: DISABLED")
    end
end

-- Auto Attack
local attackConnection
function Combat:ToggleAutoAttack(enabled)
    self.Enabled.AutoAttack = enabled
    
    if enabled then
        if attackConnection then attackConnection:Disconnect() end
        
        attackConnection = RunService.Heartbeat:Connect(function()
            if not self.Enabled.AutoAttack then return end
            
            local target = getClosestEnemy()
            if target and Player.Character then
                -- Find sword in backpack or character
                local sword = Player.Character:FindFirstChildOfClass("Tool")
                if not sword then
                    for _, tool in ipairs(Player.Backpack:GetChildren()) do
                        if tool.Name:lower():find("sword") then
                            sword = tool
                            sword.Parent = Player.Character
                            break
                        end
                    end
                end
                
                if sword and sword:FindFirstChild("Handle") then
                    -- Attack
                    sword:Activate()
                end
            end
        end)
        
        print("✅ Auto Attack: ENABLED")
    else
        if attackConnection then
            attackConnection:Disconnect()
            attackConnection = nil
        end
        print("❌ Auto Attack: DISABLED")
    end
end

-- Kill Aura
local auraConnection
function Combat:ToggleKillAura(enabled)
    self.Enabled.KillAura = enabled
    
    if enabled then
        if auraConnection then auraConnection:Disconnect() end
        
        auraConnection = RunService.Heartbeat:Connect(function()
            if not self.Enabled.KillAura then return end
            
            -- Attack all enemies in range
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= Player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    local distance = (player.Character.HumanoidRootPart.Position - Player.Character.HumanoidRootPart.Position).Magnitude
                    
                    if distance <= self.Settings.AttackRange then
                        -- Find sword
                        local sword = Player.Character:FindFirstChildOfClass("Tool")
                        if not sword then
                            for _, tool in ipairs(Player.Backpack:GetChildren()) do
                                if tool.Name:lower():find("sword") then
                                    sword = tool
                                    sword.Parent = Player.Character
                                    break
                                end
                            end
                        end
                        
                        if sword then
                            sword:Activate()
                        end
                    end
                end
            end
        end)
        
        print("✅ Kill Aura: ENABLED")
    else
        if auraConnection then
            auraConnection:Disconnect()
            auraConnection = nil
        end
        print("❌ Kill Aura: DISABLED")
    end
end

-- Set attack range
function Combat:SetRange(range)
    self.Settings.AttackRange = range
    print("⚔️ Attack Range:", range)
end

-- Cleanup
function Combat:Cleanup()
    if aimConnection then aimConnection:Disconnect() end
    if attackConnection then attackConnection:Disconnect() end
    if auraConnection then auraConnection:Disconnect() end
end

return Combat
