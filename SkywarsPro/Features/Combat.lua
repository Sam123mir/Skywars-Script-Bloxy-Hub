--[[
    ╔════════════════════════════════════════════════════════════╗
    ║  ⚔️ SKYWARS ULTIMATE PRO - COMBAT (FIXED v2)               ║
    ║  Created by: SAMIR (16bitplayer) - 2026                    ║
    ║  Mejor sistema de auto-equip y ataque                      ║
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

-- Mejorado: Encontrar mejor arma
local function findBestWeapon()
    local weapons = {}
    
    -- Buscar en character
    if Player.Character then
        for _, tool in ipairs(Player.Character:GetChildren()) do
            if tool:IsA("Tool") then
                local name = tool.Name:lower()
                if name:find("sword") or name:find("blade") or name:find("katana") then
                    table.insert(weapons, {tool = tool, location = "equipped"})
                end
            end
        end
    end
    
    -- Buscar en backpack
    for _, tool in ipairs(Player.Backpack:GetChildren()) do
        if tool:IsA("Tool") then
            local name = tool.Name:lower()
            if name:find("sword") or name:find("blade") or name:find("katana") then
                table.insert(weapons, {tool = tool, location = "backpack"})
            end
        end
    end
    
    -- Prioridad: Obsidian > Diamond > Stone > Wood
    local priority = {
        ["obsidian"] = 4,
        ["diamond"] = 3,
        ["emerald"] = 3,
        ["stone"] = 2,
        ["wood"] = 1
    }
    
    table.sort(weapons, function(a, b)
        local aPriority = 0
        local bPriority = 0
        
        for tier, value in pairs(priority) do
            if a.tool.Name:lower():find(tier) then aPriority = value end
            if b.tool.Name:lower():find(tier) then bPriority = value end
        end
        
        return aPriority > bPriority
    end)
    
    return weapons[1]
end

-- Equipar arma mejorado
local function equipWeapon()
    if not Player.Character then return nil end
    
    local humanoid = Player.Character:FindFirstChild("Humanoid")
    if not humanoid then return nil end
    
    -- Verificar si ya tiene una equipada
    local equipped = Player.Character:FindFirstChildOfClass("Tool")
    if equipped and (equipped.Name:lower():find("sword") or equipped.Name:lower():find("blade")) then
        return equipped
    end
    
    -- Buscar mejor arma
    local bestWeapon = findBestWeapon()
    if not bestWeapon then
        return nil
    end
    
    -- Equipar
    if bestWeapon.location == "backpack" then
        humanoid:EquipTool(bestWeapon.tool)
        task.wait(0.1) -- Esperar a que se equipe
        return bestWeapon.tool
    else
        return bestWeapon.tool
    end
end

-- Get closest enemy (mejorado)
local function getClosestEnemy()
    if not Player.Character then return nil end
    
    local myHrp = Player.Character:FindFirstChild("HumanoidRootPart")
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

-- Auto Aim (sin cambios)
local aimConnection
function Combat:ToggleAutoAim(enabled)
    self.Enabled.AutoAim = enabled
    
    if enabled then
        task.spawn(function()
            if not Player.Character or not Player.Character:FindFirstChild("HumanoidRootPart") then
                task.wait(2)
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

-- Auto Attack (COMPLETAMENTE REESCRITO)
local attackConnection
local lastEquipAttempt = 0
local equipCooldown = 1 -- segundos

function Combat:ToggleAutoAttack(enabled)
    self.Enabled.AutoAttack = enabled
    
    if enabled then
        task.spawn(function()
            if not Player.Character or not Player.Character:FindFirstChild("HumanoidRootPart") then
                task.wait(2)
            end
            
            if attackConnection then attackConnection:Disconnect() end
            
            print("✅ Auto Attack: ENABLED")
            print("🔍 Buscando armas disponibles...")
            
            attackConnection = RunService.Heartbeat:Connect(function()
                if not self.Enabled.AutoAttack then return end
                if not Player.Character or not Player.Character:FindFirstChild("HumanoidRootPart") then
                    return
                end
                
                local target = getClosestEnemy()
                if target then
                    -- Intentar equipar arma
                    local currentTime = tick()
                    local weapon = Player.Character:FindFirstChildOfClass("Tool")
                    
                    if not weapon or not (weapon.Name:lower():find("sword") or weapon.Name:lower():find("blade")) then
                        -- Solo intentar equipar cada X segundos para no spammear
                        if currentTime - lastEquipAttempt > equipCooldown then
                            weapon = equipWeapon()
                            lastEquipAttempt = currentTime
                            
                            if weapon then
                                print("⚔️ Equipado:", weapon.Name)
                            end
                        end
                    end
                    
                    -- Atacar si tiene arma
                    if weapon and weapon:IsA("Tool") then
                        weapon:Activate()
                    end
                end
            end)
        end)
    else
        if attackConnection then
            attackConnection:Disconnect()
            attackConnection = nil
        end
        print("❌ Auto Attack: DISABLED")
    end
end

-- Kill Aura (MEJORADO)
local auraConnection
function Combat:ToggleKillAura(enabled)
    self.Enabled.KillAura = enabled
    
    if enabled then
        task.spawn(function()
            if not Player.Character or not Player.Character:FindFirstChild("HumanoidRootPart") then
                task.wait(2)
            end
            
            if auraConnection then auraConnection:Disconnect() end
            
            print("✅ Kill Aura: ENABLED")
            
            auraConnection = RunService.Heartbeat:Connect(function()
                if not self.Enabled.KillAura then return end
                if not Player.Character or not Player.Character:FindFirstChild("HumanoidRootPart") then
                    return
                end
                
                local myHrp = Player.Character.HumanoidRootPart
                local weapon = Player.Character:FindFirstChildOfClass("Tool")
                
                -- Auto-equipar si no tiene arma
                if not weapon or not (weapon.Name:lower():find("sword") or weapon.Name:lower():find("blade")) then
                    weapon = equipWeapon()
                end
                
                if not weapon then return end
                
                -- Atacar todos en rango
                local attacked = false
                for _, player in ipairs(Players:GetPlayers()) do
                    if player ~= Player and player.Character then
                        local enemyHrp = player.Character:FindFirstChild("HumanoidRootPart")
                        local enemyHumanoid = player.Character:FindFirstChild("Humanoid")
                        
                        if enemyHrp and enemyHumanoid and enemyHumanoid.Health > 0 then
                            local distance = (enemyHrp.Position - myHrp.Position).Magnitude
                            
                            if distance <= self.Settings.AttackRange then
                                weapon:Activate()
                                attacked = true
                                break -- Solo atacar uno por frame
                            end
                        end
                    end
                end
            end)
        end)
    else
        if auraConnection then
            auraConnection:Disconnect()
            auraConnection = nil
        end
        print("❌ Kill Aura: DISABLED")
    end
end

-- Set range
function Combat:SetRange(range)
    self.Settings.AttackRange = range
    print("⚔️ Attack Range:", range, "studs")
end

-- Cleanup
function Combat:Cleanup()
    if aimConnection then aimConnection:Disconnect() end
    if attackConnection then attackConnection:Disconnect() end
    if auraConnection then auraConnection:Disconnect() end
end

return Combat
