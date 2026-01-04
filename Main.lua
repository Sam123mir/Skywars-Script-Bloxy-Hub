--[[
    ╔═══════════════════════════════════════════════════════════╗
    ║  ⚔️ SKYWARS ULTIMATE PRO v5.1                            ║
    ║  👨‍💻 By: 16bitplayer                                      ║
    ║  📅 Build: 2026-01-03                                     ║
    ║  🎨 UI: BloxyHub (Custom)                                 ║
    ║  🎯 Features: Raycast, Macros, Prediction, Anti-Detect   ║
    ╚═══════════════════════════════════════════════════════════╝
]]

print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
print("  ⚔️ SKYWARS ULTIMATE PRO v5.1")
print("  🔄 Iniciando sistemas...")
print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

-- ============================================
-- SERVICIOS Y VARIABLES GLOBALES
-- ============================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local VirtualUser = game:GetService("VirtualUser")
local StarterGui = game:GetService("StarterGui")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local RootPart = Character:WaitForChild("HumanoidRootPart")

-- ============================================
-- AUTO-UPDATE SYSTEM
-- ============================================

local CURRENT_VERSION = "6.1"
local VERSION_URL = "https://raw.githubusercontent.com/Sam123mir/Skywars-Script-Bloxy-Hub/main/version.txt"
local SCRIPT_URL = "https://raw.githubusercontent.com/Sam123mir/Skywars-Script-Bloxy-Hub/main/Main.lua"

local function simpleNotify(title, text, duration)
    StarterGui:SetCore("SendNotification", {
        Title = title,
        Text = text,
        Duration = duration or 5
    })
end

-- Verificar si ya está ejecutándose (prevenir duplicados)
if getgenv and getgenv().SkywarsBloxyRunning then
    warn("⚠️ SKYWARS ya está ejecutándose!")
    return
end

if getgenv then
    getgenv().SkywarsBloxyRunning = true
end

local function checkForUpdates()
    local success, versionData = pcall(function()
        return game:HttpGet(VERSION_URL, true)
    end)
    
    if success and versionData then
        -- Convertir a string y limpiar espacios
        versionData = tostring(versionData):gsub("%s+", "")
        
        -- Validar que sea un string válido
        if type(versionData) == "string" and #versionData > 0 then
            local latestVersion = versionData:match("([%d%.]+)")
            
            if latestVersion and latestVersion ~= CURRENT_VERSION then
                simpleNotify("🔄 UPDATE", "v"..latestVersion.." disponible", 5)
                task.wait(2)
                simpleNotify("⚡ Actualizando", "En 3 segundos...", 3)
                task.wait(3)
                
                local scriptSuccess, newScript = pcall(function()
                    return game:HttpGet(SCRIPT_URL, true)
                end)
                
                if scriptSuccess then
                    simpleNotify("✅ Actualizado!", "Reiniciando v"..latestVersion, 2)
                    task.wait(1)
                    
                    -- Limpiar flag antes de cargar nueva versión
                    if getgenv then
                        getgenv().SkywarsBloxyRunning = nil
                    end
                    
                    loadstring(newScript)()
                    return true  -- Indica que se actualizó
                end
            else
                print("✅ Versión actual: v" .. CURRENT_VERSION)
            end
        else
            warn("⚠️ No se pudo leer la versión desde GitHub")
        end
    else
        warn("⚠️ Error al verificar updates:", versionData)
    end
    return false
end

-- Verificar updates
if checkForUpdates() then
    return  -- Si se actualizó, terminar este script
end

-- ============================================
-- CARGAR BLOXYHUB UI
-- ============================================

print("📦 Cargando BloxyHub UI...")
local BloxyHub = loadstring(game:HttpGet("https://raw.githubusercontent.com/Sam123mir/Skywars-Script-Bloxy-Hub/main/Library.lua"))()
print("✅ BloxyHub UI cargada!")

-- ============================================
-- CONFIGURACIÓN
-- ============================================

local Config = {
    -- Combat
    combatEnabled = false,
    reach = 18,
    attackSpeed = 18,
    autoAim = false,
    smoothAim = false,
    smoothFactor = 0.18,
    predictMovement = false,
    predictionTime = 120,
    hitChance = 95,
    targetMode = "Nearest",
    
    -- Macros
    macrosEnabled = false,
    currentMacro = "None",
    actionDelay = 50,
    
    -- Weapons
    autoEquip = false,
    preferSword = true,
    
    -- Movement
    walkSpeed = 23,
    jumpPower = 50,
    infiniteJump = false,
    noSlowdown = false,
    
    -- Visual
    highlightTarget = false,
    
    -- Safety
    antiVoid = false,
    antiAfk = false,
}

-- ============================================
-- ALLY SYSTEM
-- ============================================

local Allies = {}

local function isAlly(player)
    if not player then return false end
    
    for _, ally in ipairs(Allies) do
        if ally == player.Name then
            return true
        end
    end
    
    if player.Team and LocalPlayer.Team and player.Team == LocalPlayer.Team then
        return true
    end
    
    return false
end

local function addAlly(playerName)
    if not table.find(Allies, playerName) then
        table.insert(Allies, playerName)
        BloxyHub:Notify("👥 Aliado", playerName .. " añadido", 3, "success")
    end
end

local function removeAlly(playerName)
    local index = table.find(Allies, playerName)
    if index then
        table.remove(Allies, index)
        BloxyHub:Notify("👥 Aliado", playerName .. " removido", 3, "error")
    end
end

local function clearAllies()
    Allies = {}
    BloxyHub:Notify("👥 Aliados", "Lista limpiada", 3, "success")
end

-- ============================================
-- RAYCAST SYSTEM
-- ============================================

local function isVisible(origin, target)
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    raycastParams.FilterDescendantsInstances = {Character, target.Parent}
    
    local raycastResult = Workspace:Raycast(origin, (target.Position - origin), raycastParams)
    
    return raycastResult == nil
end

-- ============================================
-- VELOCITY PREDICTION
-- ============================================

local function predictPosition(position, velocity, predictionTime)
    local timeInSeconds = predictionTime / 1000
    return position + (velocity * timeInSeconds)
end

-- ============================================
-- TARGET SELECTION
-- ============================================

local currentTarget = nil

local function getTarget()
    local bestTarget = nil
    local bestValue = math.huge
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local targetChar = player.Character
            local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
            local targetHum = targetChar:FindFirstChild("Humanoid")
            
            if targetRoot and targetHum and targetHum.Health > 0 then
                if isAlly(player) then continue end
                if targetChar:FindFirstChildOfClass("ForceField") then continue end
                
                local distance = (RootPart.Position - targetRoot.Position).Magnitude
                
                if distance > Config.reach then continue end
                if not isVisible(RootPart.Position, targetRoot) then continue end
                
                if Config.targetMode == "Nearest" then
                    if distance < bestValue then
                        bestValue = distance
                        bestTarget = player
                    end
                elseif Config.targetMode == "Lowest" then
                    if targetHum.Health < bestValue then
                        bestValue = targetHum.Health
                        bestTarget = player
                    end
                elseif Config.targetMode == "Highest" then
                    if targetHum.Health > bestValue and distance < 30 then
                        bestValue = targetHum.Health
                        bestTarget = player
                    end
                end
            end
        end
    end
    
    return bestTarget
end

-- ============================================
-- SMOOTH AIM
-- ============================================

local function aimAtTarget(target)
    if not target or not target.Character then return end
    
    local targetRoot = target.Character:FindFirstChild("HumanoidRootPart")
    if not targetRoot then return end
    
    local targetPosition = targetRoot.Position
    
    if Config.predictMovement then
        local targetVelocity = targetRoot.AssemblyVelocity
        targetPosition = predictPosition(targetPosition, targetVelocity, Config.predictionTime)
    end
    
    local newCFrame = CFrame.new(RootPart.Position, targetPosition)
    
    if Config.smoothAim then
        RootPart.CFrame = RootPart.CFrame:Lerp(newCFrame, Config.smoothFactor)
    else
        RootPart.CFrame = newCFrame
    end
end

-- ============================================
-- ATTACK SYSTEM
-- ============================================

local lastAttackTime = 0

local function attackTarget(target)
    if not target or not target.Character then return end
    
    local currentTime = tick()
    local attackCooldown = 1 / (Config.attackSpeed / 60)
    
    if currentTime - lastAttackTime < attackCooldown then return end
    
    if math.random(1, 100) > Config.hitChance then
        lastAttackTime = currentTime
        return
    end
    
    local targetHum = target.Character:FindFirstChild("Humanoid")
    if targetHum and targetHum.Health > 0 then
        local sword = Character:FindFirstChildOfClass("Tool")
        
        if sword and sword:FindFirstChild("Handle") then
            local args = {
                [1] = target.Character,
                [2] = sword.Handle
            }
            
            pcall(function()
                if ReplicatedStorage:FindFirstChild("Events") then
                    local damageEvent = ReplicatedStorage.Events:FindFirstChild("DamagePlayer") or
                                      ReplicatedStorage.Events:FindFirstChild("Combat") or
                                      ReplicatedStorage.Events:FindFirstChild("Hit")
                    
                    if damageEvent then
                        damageEvent:FireServer(unpack(args))
                    end
                end
            end)
            
            lastAttackTime = currentTime
        end
    end
end

-- ============================================
-- MACRO SYSTEM
-- ============================================

local macroRunning = false

local Macros = {
    ["W-Tap"] = function()
        attackTarget(currentTarget)
        task.wait(0.05)
        
        local wPressed = UserInputService:IsKeyDown(Enum.KeyCode.W)
        if wPressed then
            keyrelease(0x57)
            task.wait(0.08)
            keypress(0x57)
        end
        
        task.wait(0.05)
        attackTarget(currentTarget)
        task.wait(0.12)
    end,
    
    ["S-Tap"] = function()
        attackTarget(currentTarget)
        task.wait(0.05)
        
        keypress(0x53)
        task.wait(0.08)
        keyrelease(0x53)
        
        task.wait(0.05)
        attackTarget(currentTarget)
        task.wait(0.12)
    end,
    
    ["Combo Rush"] = function()
        for i = 1, 3 do
            attackTarget(currentTarget)
            task.wait(0.03)
        end
        
        mouse1press()
        task.wait(0.1)
        mouse1release()
        task.wait(0.08)
    end,
    
    ["Butterfly Click"] = function()
        for i = 1, 5 do
            attackTarget(currentTarget)
            task.wait(0.02)
        end
        task.wait(0.15)
    end,
    
    ["Block Hit"] = function()
        mouse1press()
        task.wait(0.05)
        mouse1release()
        
        attackTarget(currentTarget)
        task.wait(0.05)
        
        mouse1press()
        task.wait(0.05)
        mouse1release()
        task.wait(0.1)
    end,
    
    ["Crit Chain"] = function()
        Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        task.wait(0.05)
        
        for i = 1, 3 do
            attackTarget(currentTarget)
            task.wait(0.04)
        end
        task.wait(0.1)
    end
}

local function executeMacro()
    if not Config.macrosEnabled or Config.currentMacro == "None" then return end
    if not currentTarget then return end
    if macroRunning then return end
    
    macroRunning = true
    
    local macro = Macros[Config.currentMacro]
    if macro then
        pcall(macro)
    end
    
    task.wait(Config.actionDelay / 1000)
    macroRunning = false
end

-- ============================================
-- AUTO-EQUIP WEAPON
-- ============================================

local function equipBestWeapon()
    if not Config.autoEquip then return end
    
    local bestWeapon = nil
    
    for _, tool in ipairs(LocalPlayer.Backpack:GetChildren()) do
        if tool:IsA("Tool") then
            local toolName = tool.Name:lower()
            
            if Config.preferSword then
                if toolName:find("sword") or toolName:find("blade") or toolName:find("katana") then
                    bestWeapon = tool
                    break
                end
            end
        end
    end
    
    if bestWeapon and Character:FindFirstChildOfClass("Tool") ~= bestWeapon then
        Humanoid:EquipTool(bestWeapon)
    end
end

-- ============================================
-- MOVEMENT
-- ============================================

local function applyMovementMods()
    if Humanoid then
        Humanoid.WalkSpeed = Config.walkSpeed
        Humanoid.JumpPower = Config.jumpPower
    end
end

UserInputService.JumpRequest:Connect(function()
    if Config.infiniteJump and Humanoid then
        Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

RunService.Heartbeat:Connect(function()
    if Config.noSlowdown and Humanoid then
        Humanoid.WalkSpeed = Config.walkSpeed
    end
end)

-- ============================================
-- TARGET HIGHLIGHT
-- ============================================

local targetHighlight = nil

local function updateHighlight()
    if targetHighlight then
        targetHighlight:Destroy()
        targetHighlight = nil
    end
    
    if Config.highlightTarget and currentTarget and currentTarget.Character then
        targetHighlight = Instance.new("Highlight")
        targetHighlight.Parent = currentTarget.Character
        targetHighlight.FillColor = Color3.fromRGB(255, 0, 0)
        targetHighlight.OutlineColor = Color3.fromRGB(255, 255, 255)
        targetHighlight.FillTransparency = 0.5
        targetHighlight.OutlineTransparency = 0
    end
end

-- ============================================
-- ANTI-VOID
-- ============================================

local antiVoidY = -50

RunService.Heartbeat:Connect(function()
    if Config.antiVoid and RootPart and RootPart.Position.Y < antiVoidY then
        RootPart.CFrame = RootPart.CFrame + Vector3.new(0, 100, 0)
    end
end)

-- ============================================
-- ANTI-AFK
-- ============================================

LocalPlayer.Idled:Connect(function()
    if Config.antiAfk then
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end
end)

-- ============================================
-- MAIN COMBAT LOOP
-- ============================================

RunService.Heartbeat:Connect(function()
    if not Character or not Character.Parent then
        Character = LocalPlayer.Character
        if Character then
            Humanoid = Character:WaitForChild("Humanoid")
            RootPart = Character:WaitForChild("HumanoidRootPart")
        end
        return
    end
    
    applyMovementMods()
    
    if Config.combatEnabled then
        currentTarget = getTarget()
        
        if currentTarget then
            equipBestWeapon()
            
            if Config.autoAim then
                aimAtTarget(currentTarget)
            end
            
            attackTarget(currentTarget)
            
            if Config.macrosEnabled then
                executeMacro()
            end
            
            updateHighlight()
        else
            if targetHighlight then
                targetHighlight:Destroy()
                targetHighlight = nil
            end
        end
    end
end)

-- ============================================
-- CHARACTER RESPAWN
-- ============================================

LocalPlayer.CharacterAdded:Connect(function(char)
    Character = char
    Humanoid = char:WaitForChild("Humanoid")
    RootPart = char:WaitForChild("HumanoidRootPart")
    
    task.wait(1)
    applyMovementMods()
end)

-- ============================================
-- CREAR UI CON BLOXYHUB
-- ============================================

local Window = BloxyHub:CreateWindow({
    Title = "⚔️ SKYWARS ULTIMATE PRO v5.3",
    Theme = "Purple"  -- Dark, Blue, Purple, Green
})

-- ============================================
-- TAB: COMBAT
-- ============================================

local CombatTab = Window:CreateTab("Combat", "⚔️")

CombatTab:CreateToggle({
    Name = "🎯 Enable Combat",
    Default = false,
    Callback = function(value)
        Config.combatEnabled = value
        BloxyHub:Notify("⚔️ Combat", value and "Activado" or "Desactivado", 3, value and "success" or "error")
    end
})

CombatTab:CreateSlider({
    Name = "🎯 Reach",
    Min = 10,
    Max = 30,
    Default = 18,
    Callback = function(value)
        Config.reach = value
    end
})

CombatTab:CreateSlider({
    Name = "⚡ Attack Speed (CPS)",
    Min = 5,
    Max = 30,
    Default = 18,
    Callback = function(value)
        Config.attackSpeed = value
    end
})

CombatTab:CreateSlider({
    Name = "🎲 Hit Chance (%)",
    Min = 70,
    Max = 100,
    Default = 95,
    Callback = function(value)
        Config.hitChance = value
    end
})

CombatTab:CreateDropdown({
    Name = "🎯 Target Mode",
    Options = {"Nearest", "Lowest", "Highest"},
    Default = "Nearest",
    Callback = function(value)
        Config.targetMode = value
        BloxyHub:Notify("🎯 Target", "Modo: " .. value, 2, "success")
    end
})

CombatTab:CreateToggle({
    Name = "🎯 Auto Aim",
    Default = false,
    Callback = function(value)
        Config.autoAim = value
    end
})

CombatTab:CreateToggle({
    Name = "🎨 Smooth Aim",
    Default = false,
    Callback = function(value)
        Config.smoothAim = value
    end
})

CombatTab:CreateSlider({
    Name = "🎨 Smooth Factor",
    Min = 5,
    Max = 50,
    Default = 18,
    Callback = function(value)
        Config.smoothFactor = value / 100
    end
})

CombatTab:CreateToggle({
    Name = "📡 Predict Movement",
    Default = false,
    Callback = function(value)
        Config.predictMovement = value
    end
})

CombatTab:CreateSlider({
    Name = "⏱️ Prediction Time (ms)",
    Min = 50,
    Max = 300,
    Default = 120,
    Callback = function(value)
        Config.predictionTime = value
    end
})

-- ============================================
-- TAB: MACROS
-- ============================================

local MacrosTab = Window:CreateTab("Macros", "🎯")

MacrosTab:CreateToggle({
    Name = "✅ Enable Macros",
    Default = false,
    Callback = function(value)
        Config.macrosEnabled = value
        BloxyHub:Notify("🎯 Macros", value and "Activado" or "Desactivado", 3, value and "success" or "error")
    end
})

MacrosTab:CreateDropdown({
    Name = "🎮 Combo Type",
    Options = {"None", "W-Tap", "S-Tap", "Combo Rush", "Butterfly Click", "Block Hit", "Crit Chain"},
    Default = "None",
    Callback = function(value)
        Config.currentMacro = value
        BloxyHub:Notify("🎯 Macro", value, 2, "success")
    end
})

MacrosTab:CreateSlider({
    Name = "⏱️ Action Delay (ms)",
    Min = 20,
    Max = 200,
    Default = 50,
    Callback = function(value)
        Config.actionDelay = value
    end
})

MacrosTab:CreateButton({
    Name = "ℹ️ W-Tap Info",
    Callback = function()
        BloxyHub:Notify("W-Tap", "Hit → Suelta W → Hit\nClásico PvP", 4, "success")
    end
})

MacrosTab:CreateButton({
    Name = "ℹ️ S-Tap Info",
    Callback = function()
        BloxyHub:Notify("S-Tap", "Hit → Retrocede → Hit\nDefensivo", 4, "success")
    end
})

MacrosTab:CreateButton({
    Name = "ℹ️ Combo Rush Info",
    Callback = function()
        BloxyHub:Notify("Combo Rush", "3 golpes + bloqueo\nAgresivo", 4, "success")
    end
})

-- ============================================
-- TAB: WEAPONS
-- ============================================

local WeaponsTab = Window:CreateTab("Weapons", "🗡️")

WeaponsTab:CreateToggle({
    Name = "⚔️ Auto Equip",
    Default = false,
    Callback = function(value)
        Config.autoEquip = value
    end
})

WeaponsTab:CreateToggle({
    Name = "🗡️ Prefer Sword",
    Default = true,
    Callback = function(value)
        Config.preferSword = value
    end
})

-- ============================================
-- TAB: MOVEMENT
-- ============================================

local MovementTab = Window:CreateTab("Movement", "🏃")

MovementTab:CreateSlider({
    Name = "🏃 Walk Speed",
    Min = 16,
    Max = 50,
    Default = 23,
    Callback = function(value)
        Config.walkSpeed = value
    end
})

MovementTab:CreateSlider({
    Name = "🦘 Jump Power",
    Min = 50,
    Max = 120,
    Default = 50,
    Callback = function(value)
        Config.jumpPower = value
    end
})

MovementTab:CreateToggle({
    Name = "♾️ Infinite Jump",
    Default = false,
    Callback = function(value)
        Config.infiniteJump = value
    end
})

MovementTab:CreateToggle({
    Name = "⚡ No Slowdown",
    Default = false,
    Callback = function(value)
        Config.noSlowdown = value
    end
})

-- ============================================
-- TAB: VISUAL
-- ============================================

local VisualTab = Window:CreateTab("Visual", "👁️")

VisualTab:CreateToggle({
    Name = "🎯 Highlight Target",
    Default = false,
    Callback = function(value)
        Config.highlightTarget = value
        if not value and targetHighlight then
            targetHighlight:Destroy()
            targetHighlight = nil
        end
    end
})

-- ============================================
-- TAB: ALLIES
-- ============================================

local AlliesTab = Window:CreateTab("Allies", "👥")

AlliesTab:CreateInput({
    Name = "Player Name",
    Placeholder = "Enter name...",
    Callback = function(text)
        -- No hace nada, solo guarda el texto
    end
})

AlliesTab:CreateButton({
    Name = "➕ Add Ally",
    Callback = function()
        -- Buscar el textbox
        local name = "test" --  Placeholder, necesitaría mejorar esto
        if name and name ~= "" then
            addAlly(name)
        end
    end
})

AlliesTab:CreateButton({
    Name = "🗑️ Clear All Allies",
    Callback = clearAllies
})

-- ============================================
-- TAB: SAFETY
-- ============================================

local SafetyTab = Window:CreateTab("Safety", "🛡️")

SafetyTab:CreateToggle({
    Name = "🛡️ Anti Void",
    Default = false,
    Callback = function(value)
        Config.antiVoid = value
    end
})

SafetyTab:CreateToggle({
    Name = "⏰ Anti AFK",
    Default = false,
    Callback = function(value)
        Config.antiAfk = value
    end
})

-- ============================================
-- TAB: INFO
-- ============================================

local InfoTab = Window:CreateTab("Info", "ℹ️")

InfoTab:CreateButton({
    Name = "📊 Script Info",
    Callback = function()
        BloxyHub:Notify("ℹ️ Skywars Pro", "Version: " .. CURRENT_VERSION .. "\nBy: 16bitplayer", 5, "success")
    end
})

InfoTab:CreateButton({
    Name = "🎨 Change Theme: Blue",
    Callback = function()
        BloxyHub:Notify("🎨 Theme", "Reinicia el script para cambiar tema", 3, "error")
    end
})

-- ============================================
-- INICIALIZACIÓN
-- ============================================

print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
print("  ✅ SKYWARS ULTIMATE PRO v5.1")
print("  ✅ BloxyHub UI cargada")
print("  ✅ Todos los sistemas listos")
print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

BloxyHub:Notify("✅ Loaded", "Skywars Pro v5.1 iniciado!", 5, "success")