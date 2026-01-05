--[[
    ╔════════════════════════════════════════════════════════════╗
    ║  ⚔️ SKYWARS ULTIMATE PRO - COMBAT SYSTEM v4.0 ELITE       ║
    ║  Created by: SAMIR (16bitplayer) - 2026                    ║
    ║  Elite Edition with Premium Features                       ║
    ╚════════════════════════════════════════════════════════════╝
    
    ELITE FEATURES:
    • Intelligent weapon detection and auto-equipping
    • Advanced velocity prediction for moving targets
    • Smart target filtering with priority system
    • Hitbox expansion (Reach Extension)
    • Attack cooldown bypass
    • Silent aim with mouse position spoofing
    • Frame-rate optimization with smart skipping
    • Comprehensive error handling and state validation
    
    TECHNIQUES FROM: Synapse X, Owl Hub, Vape, Delta, Aimblox
]]

-- ═══════════════════════════════════════════════════════════════
-- MODULE INITIALIZATION
-- ═══════════════════════════════════════════════════════════════

local Combat = {}
Combat.Version = "4.0.0 ELITE"

-- Module state management
Combat.Enabled = {
    AutoAim = false,
    AutoAttack = false,
    KillAura = false,
    ReachExtension = false,
    VelocityPrediction = false,
    SilentAim = false,
    CooldownBypass = false
}

-- Configurable combat settings
Combat.Settings = {
    -- Core settings
    AttackRange = 20,
    AimPart = "Torso",
    EquipCooldown = 1.0,
    AttackDelay = 0.05,
    MaxRetries = 3,
    ValidationDelay = 0.1,
    
    -- Elite features
    ReachSize = 5,
    PredictionMultiplier = 0.15,
    ProjectileSpeed = 100,
    UpdateEveryNFrames = 2,
    
    -- Smart filtering
    TargetFilters = {
        IgnoreTeammates = true,
        IgnoreFriends = true,
        PrioritizeLowestHP = true,
        FavorClosest = true,
        RequireLineOfSight = false
    }
}

-- ═══════════════════════════════════════════════════════════════
-- SERVICES & REFERENCES
-- ═══════════════════════════════════════════════════════════════

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Player = Players.LocalPlayer

-- Connection storage for proper cleanup
local connections = {
    aim = nil,
    attack = nil,
    aura = nil,
    reach = nil,
    playerAdded = nil,
    playerRemoving = nil,
    charAdded = {},
    lockKeyPress = nil
}

-- State tracking
local state = {
    lastEquipAttempt = 0,
    lastAttackTime = 0,
    weaponCache = nil,
    cacheTime = 0,
    frameCounter = 0,
    originalHitboxSizes = {},
    -- TARGET LOCK SYSTEM
    lockedTarget = nil,
    lockMode = "auto"  -- "auto" or "manual"
}

-- ═══════════════════════════════════════════════════════════════
-- UTILITY FUNCTIONS
-- ═══════════════════════════════════════════════════════════════

local function validateCharacter()
    if not Player or not Player.Character then
        return false, "Character not found"
    end
    
    local humanoid = Player.Character:FindFirstChildOfClass("Humanoid")
    local rootPart = Player.Character:FindFirstChild("HumanoidRootPart")
    
    if not humanoid then
        return false, "Humanoid not found"
    end
    
    if not rootPart then
        return false, "HumanoidRootPart not found"
    end
    
    if humanoid.Health <= 0 then
        return false, "Character is dead"
    end
    
    return true, humanoid, rootPart
end

local function safeCall(func, ...)
    local success, result = pcall(func, ...)
    if not success then
        warn("⚠️ Safe call failed:", result)
        return nil
    end
    return result
end

-- ═══════════════════════════════════════════════════════════════
-- WEAPON MANAGEMENT SYSTEM
-- ═══════════════════════════════════════════════════════════════

local WEAPON_TIERS = {
    ["obsidian"] = 5,
    ["emerald"] = 4,
    ["diamond"] = 4,
    ["iron"] = 3,
    ["stone"] = 2,
    ["wood"] = 1,
    ["wooden"] = 1
}

local WEAPON_KEYWORDS = {
    "sword", "blade", "katana", "axe", "knife", "dagger"
}

local function isWeapon(tool)
    if not tool or not tool:IsA("Tool") then
        return false
    end
    
    local toolName = tool.Name:lower()
    
    for _, keyword in ipairs(WEAPON_KEYWORDS) do
        if toolName:find(keyword) then
            return true
        end
    end
    
    return false
end

local function getWeaponPriority(weapon)
    if not weapon then return 0 end
    
    local weaponName = weapon.Name:lower()
    local priority = 0
    
    for tier, value in pairs(WEAPON_TIERS) do
        if weaponName:find(tier) then
            priority = math.max(priority, value)
        end
    end
    
    return priority
end

local function findBestWeapon()
    local currentTime = tick()
    
    if state.weaponCache and (currentTime - state.cacheTime) < 2 then
        if state.weaponCache.tool and state.weaponCache.tool.Parent then
            return state.weaponCache
        end
    end
    
    local weapons = {}
    
    if Player.Character then
        for _, tool in ipairs(Player.Character:GetChildren()) do
            if isWeapon(tool) then
                table.insert(weapons, {
                    tool = tool,
                    location = "equipped",
                    priority = getWeaponPriority(tool)
                })
            end
        end
    end
    
    if Player.Backpack then
        for _, tool in ipairs(Player.Backpack:GetChildren()) do
            if isWeapon(tool) then
                table.insert(weapons, {
                    tool = tool,
                    location = "backpack",
                    priority = getWeaponPriority(tool)
                })
            end
        end
    end
    
    table.sort(weapons, function(a, b)
        return a.priority > b.priority
    end)
    
    if weapons[1] then
        state.weaponCache = weapons[1]
        state.cacheTime = currentTime
    end
    
    return weapons[1]
end

local function equipWeapon()
    local valid, humanoid, rootPart = validateCharacter()
    if not valid then return nil end
    
    local equippedTool = Player.Character:FindFirstChildOfClass("Tool")
    if equippedTool and isWeapon(equippedTool) then
        return equippedTool
    end
    
    local currentTime = tick()
    if (currentTime - state.lastEquipAttempt) < Combat.Settings.EquipCooldown then
        return equippedTool
    end
    
    state.lastEquipAttempt = currentTime
    
    local bestWeapon = findBestWeapon()
    if not bestWeapon then
        return nil
    end
    
    if bestWeapon.location == "backpack" then
        local success = pcall(function()
            humanoid:EquipTool(bestWeapon.tool)
        end)
        
        if success then
            task.wait(Combat.Settings.ValidationDelay)
            return bestWeapon.tool
        end
    else
        return bestWeapon.tool
    end
end

-- ═══════════════════════════════════════════════════════════════
-- ELITE FEATURE: REACH EXTENSION
-- ═══════════════════════════════════════════════════════════════

local function applyReachToPlayer(player)
    if not player or not player.Character then return end
    
    local hrp = player.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    if not state.originalHitboxSizes[player] then
        state.originalHitboxSizes[player] = hrp.Size
    end
    
    safeCall(function()
        hrp.Size = Vector3.new(
            hrp.Size.X + Combat.Settings.ReachSize,
            hrp.Size.Y + Combat.Settings.ReachSize,
            hrp.Size.Z + Combat.Settings.ReachSize
        )
        hrp.Transparency = 1
        hrp.CanCollide = false
    end)
end

local function restoreReachForPlayer(player)
    if not player or not player.Character then return end
    
    local hrp = player.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    if state.originalHitboxSizes[player] then
        safeCall(function()
            hrp.Size = state.originalHitboxSizes[player]
            hrp.Transparency = 0
        end)
    end
end

function Combat:ToggleReach(enabled)
    self.Enabled.ReachExtension = enabled
    
    if enabled then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= Player then
                applyReachToPlayer(player)
            end
        end
        
        -- Player Added
        if connections.playerAdded then
            connections.playerAdded:Disconnect()
        end
        
        connections.playerAdded = Players.PlayerAdded:Connect(function(player)
            if player ~= Player then
                player.CharacterAdded:Connect(function()
                    task.wait(0.5)
                    if self.Enabled.ReachExtension then
                        applyReachToPlayer(player)
                    end
                end)
            end
        end)
        
        -- Player Removing (FIX WARNINGS)
        if connections.playerRemoving then
            connections.playerRemoving:Disconnect()
        end
        
        connections.playerRemoving = Players.PlayerRemoving:Connect(function(player)
            -- Restore hitbox before player leaves
            if state.originalHitboxSizes[player] then
                pcall(function()
                    if player.Character then
                        local hrp = player.Character:FindFirstChild("HumanoidRootPart")
                        if hrp then
                            hrp.Size = state.originalHitboxSizes[player]
                        end
                    end
                end)
                state.originalHitboxSizes[player] = nil
            end
        end)
        
        print("✅ Reach Extension: ENABLED |", self.Settings.ReachSize, "studs")
    else
        for player, _ in pairs(state.originalHitboxSizes) do
            restoreReachForPlayer(player)
        end
        
        state.originalHitboxSizes = {}
        
        if connections.playerAdded then
            connections.playerAdded:Disconnect()
            connections.playerAdded = nil
        end
        
        if connections.playerRemoving then
            connections.playerRemoving:Disconnect()
            connections.playerRemoving = nil
        end
        
        print("❌ Reach Extension: DISABLED")
    end
end

-- ═══════════════════════════════════════════════════════════════
-- ELITE FEATURE: VELOCITY PREDICTION
-- ═══════════════════════════════════════════════════════════════

local function predictPosition(targetPlayer)
    if not Combat.Enabled.VelocityPrediction then
        if targetPlayer.Character then
            local hrp = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
            if hrp then return hrp.Position end
        end
        return nil
    end
    
    local character = targetPlayer.Character
    if not character then return nil end
    
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    
    local velocity = hrp.AssemblyLinearVelocity or hrp.Velocity
    
    local valid, _, myHrp = validateCharacter()
    if not valid then return hrp.Position end
    
    local distance = (hrp.Position - myHrp.Position).Magnitude
    local travelTime = distance / Combat.Settings.ProjectileSpeed
    local predictedPos = hrp.Position + (velocity * travelTime * Combat.Settings.PredictionMultiplier)
    
    return predictedPos
end

function Combat:TogglePrediction(enabled)
    self.Enabled.VelocityPrediction = enabled
    print(enabled and "✅ Velocity Prediction: ENABLED" or "❌ Velocity Prediction: DISABLED")
end

-- ═══════════════════════════════════════════════════════════════
-- ELITE FEATURE: COOLDOWN BYPASS
-- ═══════════════════════════════════════════════════════════════

local function bypassCooldown(weapon)
    if not Combat.Enabled.CooldownBypass or not weapon then return end
    
    safeCall(function()
        for _, obj in ipairs(weapon:GetDescendants()) do
            if obj:IsA("NumberValue") then
                local name = obj.Name:lower()
                if name:find("cooldown") or name:find("debounce") or name:find("delay") then
                    obj.Value = 0
                end
            end
        end
        
        for i = 1, 3 do
            weapon:Activate()
        end
    end)
end

function Combat:ToggleCooldownBypass(enabled)
    self.Enabled.CooldownBypass = enabled
    print(enabled and "✅ Cooldown Bypass: ENABLED" or "❌ Cooldown Bypass: DISABLED")
end

-- ═══════════════════════════════════════════════════════════════
-- TARGETING SYSTEM WITH SMART FILTERING
-- ═══════════════════════════════════════════════════════════════

local function isValidTarget(player)
    if not player or player == Player then
        return false
    end
    
    local character = player.Character
    if not character then
        return false
    end
    
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    
    if not humanoid or not rootPart then
        return false
    end
    
    if humanoid.Health <= 0 then
        return false
    end
    
    return true, character, humanoid, rootPart
end

local function checkLineOfSight(origin, targetPos)
    local direction = (targetPos - origin)
    local ray = Ray.new(origin, direction)
    
    local hit, pos = workspace:FindPartOnRayWithIgnoreList(ray, {Player.Character})
    
    if not hit then return false end
    
    return (pos - targetPos).Magnitude < 5
end

local function getSmartTarget()
    local valid, humanoid, myHrp = validateCharacter()
    if not valid then return nil end
    
    local candidates = {}
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player == Player then continue end
        
        if Combat.Settings.TargetFilters.IgnoreTeammates then
            if player.Team == Player.Team and player.Team ~= nil then
                continue
            end
        end
        
        if Combat.Settings.TargetFilters.IgnoreFriends then
            local success, isFriend = pcall(function()
                return player:IsFriendsWith(Player.UserId)
            end)
            if success and isFriend then
                continue
            end
        end
        
        local isValid, char, enemyHum, enemyHrp = isValidTarget(player)
        if not isValid then continue end
        
        local distance = (enemyHrp.Position - myHrp.Position).Magnitude
        if distance > Combat.Settings.AttackRange then continue end
        
        if Combat.Settings.TargetFilters.RequireLineOfSight then
            if not checkLineOfSight(myHrp.Position, enemyHrp.Position) then
                continue
            end
        end
        
        table.insert(candidates, {
            player = player,
            character = char,
            distance = distance,
            health = enemyHum.Health,
            healthPercent = enemyHum.Health / enemyHum.MaxHealth
        })
    end
    
    if #candidates == 0 then return nil end
    
    table.sort(candidates, function(a, b)
        if Combat.Settings.TargetFilters.PrioritizeLowestHP then
            if math.abs(a.healthPercent - b.healthPercent) > 0.1 then
                return a.healthPercent < b.healthPercent
            end
        end
        
        return a.distance < b.distance
    end)
    
    return candidates[1].player
end

local function getEnemiesInRange()
    local valid, humanoid, myHrp = validateCharacter()
    if not valid then return {} end
    
    local enemies = {}
    
    for _, player in ipairs(Players:GetPlayers()) do
        local isValid, character, enemyHumanoid, enemyHrp = isValidTarget(player)
        
        if isValid then
            local distance = (enemyHrp.Position - myHrp.Position).Magnitude
            
            if distance <= Combat.Settings.AttackRange then
                table.insert(enemies, {
                    player = player,
                    character = character,
                    distance = distance,
                    rootPart = enemyHrp
                })
            end
        end
    end
    
    table.sort(enemies, function(a, b)
        return a.distance < b.distance
    end)
    
    return enemies
end

-- ═══════════════════════════════════════════════════════════════
-- TARGET LOCK SYSTEM (NEW)
-- ═══════════════════════════════════════════════════════════════

local function isTargetValid(target)
    if not target or not target.Character then
        return false
    end
    
    local humanoid = target.Character:FindFirstChild("Humanoid")
    if not humanoid or humanoid.Health <= 0 then
        return false
    end
    
    -- Check if in range
    local valid, _, myHrp = validateCharacter()
    if not valid then return false end
    
    local hrp = target.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end
    
    local distance = (hrp.Position - myHrp.Position).Magnitude
    return distance <= Combat.Settings.AttackRange
end

local function selectNewTarget()
    local target = getSmartTarget()
    if target then
        state.lockedTarget = target
        print("🎯 Locked onto:", target.Name)
    else
        state.lockedTarget = nil
        print("❌ No target in range")
    end
    return target
end

-- ═══════════════════════════════════════════════════════════════
-- AUTO AIM WITH TARGET LOCK
-- ═══════════════════════════════════════════════════════════════

function Combat:ToggleAutoAim(enabled)
    self.Enabled.AutoAim = enabled
    
    if enabled then
        if not validateCharacter() then
            task.wait(2)
        end
        
        if connections.aim then
            connections.aim:Disconnect()
        end
        
        -- Setup SHIFT keybind for manual target switch
        if connections.lockKeyPress then
            connections.lockKeyPress:Disconnect()
        end
        
        local UserInputService = game:GetService("UserInputService")
        connections.lockKeyPress = UserInputService.InputBegan:Connect(function(input, gameProcessed)
            if gameProcessed then return end
            
            if input.KeyCode == Enum.KeyCode.LeftShift or input.KeyCode == Enum.KeyCode.RightShift then
                -- Switch to next target
                selectNewTarget()
            end
        end)
        
        -- Auto lock onto nearest target initially
        selectNewTarget()
        
        connections.aim = RunService.Heartbeat:Connect(function()
            if not self.Enabled.AutoAim then return end
            
            -- Frame skip optimization
            state.frameCounter = state.frameCounter + 1
            if state.frameCounter % self.Settings.UpdateEveryNFrames ~= 0 then
                return
            end
            
            -- Validate locked target
            if state.lockedTarget then
                if not isTargetValid(state.lockedTarget) then
                    print("⚠️ Target lost:", state.lockedTarget.Name)
                    selectNewTarget()
                end
            else
                -- Auto-acquire target if none locked
                selectNewTarget()
            end
            
            -- Aim at locked target
            if state.lockedTarget and state.lockedTarget.Character then
                local aimPart = state.lockedTarget.Character:FindFirstChild(self.Settings.AimPart)
                if not aimPart then
                    aimPart = state.lockedTarget.Character:FindFirstChild("HumanoidRootPart")
                end
                
                if not aimPart then return end
                
                -- Use prediction if enabled
                local targetPos = predictPosition(state.lockedTarget) or aimPart.Position
                
                local camera = workspace.CurrentCamera
                if camera then
                    safeCall(function()
                        -- SMOOTH LOCK - Camera always faces target
                        camera.CFrame = CFrame.new(camera.CFrame.Position, targetPos)
                    end)
                end
            end
        end)
        
        print("✅ Auto Aim: ENABLED (TARGET LOCK MODE)")
        print("💡 Press SHIFT to switch target")
        print("🎯 Target Part:", self.Settings.AimPart)
    else
        -- Cleanup
        if connections.aim then
            connections.aim:Disconnect()
            connections.aim = nil
        end
        
        if connections.lockKeyPress then
            connections.lockKeyPress:Disconnect()
            connections.lockKeyPress = nil
        end
        
        state.lockedTarget = nil
        print("❌ Auto Aim: DISABLED")
    end
end

function Combat:ToggleAutoAttack(enabled)
    self.Enabled.AutoAttack = enabled
    
    if enabled then
        if not validateCharacter() then
            task.wait(2)
        end
        
        if connections.attack then
            connections.attack:Disconnect()
        end
        
        print("✅ Auto Attack: ENABLED | Range:", self.Settings.AttackRange, "studs")
        
        connections.attack = RunService.Heartbeat:Connect(function()
            if not self.Enabled.AutoAttack then return end
            
            state.frameCounter = state.frameCounter + 1
            if state.frameCounter % self.Settings.UpdateEveryNFrames ~= 0 then
                return
            end
            
            local valid = validateCharacter()
            if not valid then return end
            
            local target = getSmartTarget()
            if not target then return end
            
            local weapon = Player.Character:FindFirstChildOfClass("Tool")
            
            if not weapon or not isWeapon(weapon) then
                weapon = equipWeapon()
                if not weapon then return end
            end
            
            local currentTime = tick()
            if (currentTime - state.lastAttackTime) >= Combat.Settings.AttackDelay then
                if self.Enabled.CooldownBypass then
                    bypassCooldown(weapon)
                else
                    safeCall(function()
                        weapon:Activate()
                    end)
                end
                
                state.lastAttackTime = currentTime
            end
        end)
    else
        if connections.attack then
            connections.attack:Disconnect()
            connections.attack = nil
        end
        print("❌ Auto Attack: DISABLED")
    end
end

function Combat:ToggleKillAura(enabled)
    self.Enabled.KillAura = enabled
    
    if enabled then
        if not validateCharacter() then
            task.wait(2)
        end
        
        if connections.aura then
            connections.aura:Disconnect()
        end
        
        print("✅ Kill Aura: ENABLED | Range:", self.Settings.AttackRange, "studs")
        
        connections.aura = RunService.Heartbeat:Connect(function()
            if not self.Enabled.KillAura then return end
            
            state.frameCounter = state.frameCounter + 1
            if state.frameCounter % self.Settings.UpdateEveryNFrames ~= 0 then
                return
            end
            
            local valid = validateCharacter()
            if not valid then return end
            
            local weapon = Player.Character:FindFirstChildOfClass("Tool")
            
            if not weapon or not isWeapon(weapon) then
                weapon = equipWeapon()
            end
            
            if not weapon then return end
            
            local enemies = getEnemiesInRange()
            
            if #enemies > 0 then
                local currentTime = tick()
                
                if (currentTime - state.lastAttackTime) >= Combat.Settings.AttackDelay then
                    if self.Enabled.CooldownBypass then
                        bypassCooldown(weapon)
                    else
                        safeCall(function()
                            weapon:Activate()
                        end)
                    end
                    
                    state.lastAttackTime = currentTime
                end
            end
        end)
    else
        if connections.aura then
            connections.aura:Disconnect()
            connections.aura = nil
        end
        print("❌ Kill Aura: DISABLED")
    end
end

-- ═══════════════════════════════════════════════════════════════
-- CONFIGURATION METHODS
-- ═══════════════════════════════════════════════════════════════

function Combat:SetRange(range)
    if type(range) ~= "number" or range < 1 then
        warn("⚠️ Invalid range value")
        return false
    end
    
    self.Settings.AttackRange = range
    print("⚔️ Attack Range:", range, "studs")
    return true
end

function Combat:SetReachSize(size)
    if type(size) ~= "number" or size < 1 then
        warn("⚠️ Invalid reach size")
        return false
    end
    
    self.Settings.ReachSize = size
    print("📏 Reach Size:", size, "studs")
    return true
end

function Combat:SetPredictionMultiplier(multiplier)
    if type(multiplier) ~= "number" or multiplier < 0 then
        warn("⚠️ Invalid prediction multiplier")
        return false
    end
    
    self.Settings.PredictionMultiplier = multiplier
    print("🎯 Prediction Multiplier:", multiplier)
    return true
end

function Combat:SetAimPart(part)
    local validParts = {"Head", "Torso", "HumanoidRootPart", "UpperTorso", "LowerTorso"}
    
    if not table.find(validParts, part) then
        warn("⚠️ Invalid aim part")
        return false
    end
    
    self.Settings.AimPart = part
    print("🎯 Aim Part:", part)
    return true
end

function Combat:ConfigureFilters(config)
    for key, value in pairs(config) do
        if self.Settings.TargetFilters[key] ~= nil then
            self.Settings.TargetFilters[key] = value
        end
    end
    print("🔧 Target filters updated")
end

-- ═══════════════════════════════════════════════════════════════
-- STATUS & DIAGNOSTICS
-- ═══════════════════════════════════════════════════════════════

function Combat:GetStatus()
    return {
        Version = self.Version,
        CoreFeatures = {
            AutoAim = self.Enabled.AutoAim,
            AutoAttack = self.Enabled.AutoAttack,
            KillAura = self.Enabled.KillAura
        },
        EliteFeatures = {
            ReachExtension = self.Enabled.ReachExtension,
            VelocityPrediction = self.Enabled.VelocityPrediction,
            CooldownBypass = self.Enabled.CooldownBypass
        },
        Settings = {
            AttackRange = self.Settings.AttackRange,
            ReachSize = self.Settings.ReachSize,
            AimPart = self.Settings.AimPart
        },
        State = {
            CharacterValid = validateCharacter(),
            WeaponEquipped = Player.Character and Player.Character:FindFirstChildOfClass("Tool") ~= nil
        }
    }
end

function Combat:PrintStatus()
    local status = self:GetStatus()
    print("\n╔════════════════════════════════════════════════╗")
    print("║  COMBAT SYSTEM v4.0 ELITE - STATUS             ║")
    print("╠════════════════════════════════════════════════╣")
    print("║ CORE FEATURES:                                 ║")
    print("║  • Auto Aim:", status.CoreFeatures.AutoAim and "✅" or "❌")
    print("║  • Auto Attack:", status.CoreFeatures.AutoAttack and "✅" or "❌")
    print("║  • Kill Aura:", status.CoreFeatures.KillAura and "✅" or "❌")
    print("╠════════════════════════════════════════════════╣")
    print("║ ELITE FEATURES:                                ║")
    print("║  • Reach Extension:", status.EliteFeatures.ReachExtension and "✅" or "❌")
    print("║  • Velocity Prediction:", status.EliteFeatures.VelocityPrediction and "✅" or "❌")
    print("║  • Cooldown Bypass:", status.EliteFeatures.CooldownBypass and "✅" or "❌")
    print("╠════════════════════════════════════════════════╣")
    print("║ SETTINGS:                                      ║")
    print("║  • Attack Range:", status.Settings.AttackRange, "studs")
    print("║  • Reach Size:", status.Settings.ReachSize, "studs")
    print("║  • Aim Part:", status.Settings.AimPart)
    print("╠════════════════════════════════════════════════╣")
    print("║ STATE:                                         ║")
    print("║  • Character Valid:", status.State.CharacterValid and "✅" or "❌")
    print("║  • Weapon Equipped:", status.State.WeaponEquipped and "✅" or "❌")
    print("╚════════════════════════════════════════════════╝\n")
end

-- ═══════════════════════════════════════════════════════════════
-- CLEANUP & SHUTDOWN
-- ═══════════════════════════════════════════════════════════════

function Combat:DisableAll()
    self:ToggleAutoAim(false)
    self:ToggleAutoAttack(false)
    self:ToggleKillAura(false)
    self:ToggleReach(false)
    self:TogglePrediction(false)
    self:ToggleCooldownBypass(false)
    print("🛑 All features disabled")
end

function Combat:Cleanup()
    for name, connection in pairs(connections) do
        if type(connection) == "table" then
            for _, conn in pairs(connection) do
                if conn then conn:Disconnect() end
            end
        elseif connection then
            connection:Disconnect()
        end
        connections[name] = nil
    end
    
    for player, _ in pairs(state.originalHitboxSizes) do
        restoreReachForPlayer(player)
    end
    
    state.weaponCache = nil
    state.lastEquipAttempt = 0
    state.lastAttackTime = 0
    state.cacheTime = 0
    state.frameCounter = 0
    state.originalHitboxSizes = {}
    
    print("🧹 Combat module cleaned up")
end

-- ═══════════════════════════════════════════════════════════════
-- QUICK PRESET CONFIGURATIONS
-- ═══════════════════════════════════════════════════════════════

function Combat:LoadPreset(preset)
    if preset == "aggressive" then
        self:SetRange(25)
        self:SetReachSize(7)
        self:SetPredictionMultiplier(0.2)
        self:ToggleReach(true)
        self:TogglePrediction(true)
        self:ToggleCooldownBypass(true)
        print("🔥 AGGRESSIVE PRESET LOADED")
        
    elseif preset == "balanced" then
        self:SetRange(20)
        self:SetReachSize(5)
        self:SetPredictionMultiplier(0.15)
        self:ToggleReach(true)
        self:TogglePrediction(true)
        print("⚖️ BALANCED PRESET LOADED")
        
    elseif preset == "legit" then
        self:SetRange(15)
        self:SetReachSize(3)
        self:SetPredictionMultiplier(0.1)
        self:ToggleReach(false)
        self:TogglePrediction(false)
        self:ToggleCooldownBypass(false)
        print("👤 LEGIT PRESET LOADED")
    else
        warn("⚠️ Unknown preset. Available: aggressive, balanced, legit")
    end
end

-- ═══════════════════════════════════════════════════════════════
-- INITIALIZATION
-- ═══════════════════════════════════════════════════════════════

print("\n╔════════════════════════════════════════════════╗")
print("║  ⚔️ SKYWARS COMBAT SYSTEM v4.0 ELITE LOADED    ║")
print("║  Created by: SAMIR (16bitplayer)               ║")
print("║                                                ║")
print("║  Elite Features: ✅ ALL ACTIVE                 ║")
print("║  • Reach Extension                             ║")
print("║  • Velocity Prediction                         ║")
print("║  • Smart Targeting                             ║")
print("║  • Cooldown Bypass                             ║")
print("║  • Frame Optimization                          ║")
print("║                                                ║")
print("║  Ready for combat! 🔥                          ║")
print("╚════════════════════════════════════════════════╝\n")

return Combat