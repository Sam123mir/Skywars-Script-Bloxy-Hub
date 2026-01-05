--[[
    ╔════════════════════════════════════════════════════════════╗
    ║  ⚔️ SKYWARS ULTIMATE PRO - COMBAT FEATURES (FIXED)         ║
    ║  Created by: SAMIR (16bitplayer) - 2026                    ║
    ║  Real combat functionality with proper nil checking        ║
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
    AimPart = "Torso"
}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Player = Players.LocalPlayer

-- Safe wait for character
local function waitForCharacter()
    local char = Player.Character
    if not char then
        Player.CharacterAdded:Wait()
        char = Player.Character
    end
    
    -- Wait for HumanoidRootPart
    local hrp = char:WaitForChild("HumanoidRootPart", 5)
    local humanoid = char:WaitForChild("Humanoid", 5)
    
    return char, hrp, humanoid
end

-- Get closest enemy with nil checks
local function getClosestEnemy()
    local char, myHrp = Player.Character, nil
    if char then
        myHrp = char:FindFirstChild("HumanoidRootPart")
    end
    
    if not myHrp then return nil end
    
    local closestPlayer = nil
    local shortestDistance = Combat.Settings.AttackRange
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= Player then
            local enemyChar = player.Character
            if enemyChar then
                local humanoid = enemyChar:FindFirstChild("Humanoid")
                local hrp = enemyChar:FindFirstChild("HumanoidRootPart")
                
                if humanoid and hrp and humanoid.Health > 0 then
                    local distance = (hrp.Position - myHrp.Position).Magnitude
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

-- Auto Aim (FIXED)
local aimConnection
function Combat:ToggleAutoAim(enabled)
    self.Enabled.AutoAim = enabled
    
    if enabled then
        -- Wait for character first
        task.spawn(function()
            local char, hrp  = waitForCharacter()
            if not char or not hrp then
                warn("❌ Cannot enable Auto Aim - Character not ready")
                return
            end
            
            if aimConnection then aimConnection:Disconnect() end
            
            aimConnection = RunService.Heartbeat:Connect(function()
                if not self.Enabled.AutoAim then return end
                
                local target = getClosestEnemy()
                if target and target.Character then
                    local aimPart = target.Character:FindFirstChild(self.Settings.AimPart)
                    if not aimPart then
                        aimPart = target.Character:FindFirstChild("HumanoidRootPart")
                    end
                    
                    if aimPart then
                        local camera = workspace.CurrentCamera
                        if camera then
                            camera.CFrame = CFrame.new(camera.CFrame.Position, aimPart.Position)
                        end
                    end
                end
            end)
            
            print("✅ Auto Aim: ENABLED")
        end)
    else
        if aimConnection then
            aimConnection:Disconnect()
            aimConnection = nil
        end
        print("❌ Auto Aim: DISABLED")
    end
end

-- Auto Attack (FIXED)
local attackConnection
function Combat:ToggleAutoAttack(enabled)
    self.Enabled.AutoAttack = enabled
    
    if enabled then
        task.spawn(function()
            local char, hrp = waitForCharacter()
            if not char or not hrp then
                warn("❌ Cannot enable Auto Attack - Character not ready")
                return
            end
            
            if attackConnection then attackConnection:Disconnect() end
            
            attackConnection = RunService.Heartbeat:Connect(function()
                if not self.Enabled.AutoAttack then return end
                
                -- Check character still exists
                if not Player.Character or not Player.Character:FindFirstChild("HumanoidRootPart") then
                    return
                end
                
                local target = getClosestEnemy()
                if target then
                    -- Find sword
                    local sword = Player.Character:FindFirstChildOfClass("Tool")
                    
                    if not sword or not sword.Name:lower():find("sword") then
                        -- Try to equip from backpack
                        for _, tool in ipairs(Player.Backpack:GetChildren()) do
                            if tool:IsA("Tool") and tool.Name:lower():find("sword") then
                                sword = tool
                                humanoid = Player.Character:FindFirstChild("Humanoid")
                                if humanoid then
                                    humanoid:EquipTool(tool)
                                end
                                break
                            end
                        end
                    end
                    
                    -- Activate sword
                    if sword and sword:FindFirstChild("Handle") then
                        sword:Activate()
                    end
                end
            end)
            
            print("✅ Auto Attack: ENABLED")
        end)
    else
        if attackConnection then
            attackConnection:Disconnect()
            attackConnection = nil
        end
        print("❌ Auto Attack: DISABLED")
    end
end

-- Kill Aura (FIXED)
local auraConnection
function Combat:ToggleKillAura(enabled)
    self.Enabled.KillAura = enabled
    
    if enabled then
        task.spawn(function()
            local char, hrp = waitForCharacter()
            if not char or not hrp then
                warn("❌ Cannot enable Kill Aura - Character not ready")
                return
            end
            
            if auraConnection then auraConnection:Disconnect() end
            
            auraConnection = RunService.Heartbeat:Connect(function()
                if not self.Enabled.KillAura then return end
                
                -- Check character
                if not Player.Character or not Player.Character:FindFirstChild("HumanoidRootPart") then
                    return
                end
                
                local myHrp = Player.Character.HumanoidRootPart
                
                -- Attack all in range
                for _, player in ipairs(Players:GetPlayers()) do
                    if player ~= Player and player.Character then
                        local enemyHrp = player.Character:FindFirstChild("HumanoidRootPart")
                        if enemyHrp then
                            local distance = (enemyHrp.Position - myHrp.Position).Magnitude
                            
                            if distance <= self.Settings.AttackRange then
                                -- Find and activate sword
                                local sword = Player.Character:FindFirstChildOfClass("Tool")
                                if not sword or not sword.Name:lower():find("sword") then
                                    for _, tool in ipairs(Player.Backpack:GetChildren()) do
                                        if tool:IsA("Tool") and tool.Name:lower():find("sword") then
                                            local humanoid = Player.Character:FindFirstChild("Humanoid")
                                            if humanoid then
                                                humanoid:EquipTool(tool)
                                                sword = tool
                                            end
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
                end
            end)
            
            print("✅ Kill Aura: ENABLED")
        end)
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
