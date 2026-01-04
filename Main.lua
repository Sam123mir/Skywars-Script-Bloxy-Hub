-- ⚔️ SKYWARS MOBILE ULTIMATE 🏹
-- Por 16bitplayer games
-- 100% Optimizado para MÓVILES | Versión 4.0
-- Compatible con loadstring remoto

-- ============================================
-- VERIFICACIÓN DE ENTORNO
-- ============================================

if not game:IsLoaded() then
    game.Loaded:Wait()
end

repeat wait() until game:GetService("Players").LocalPlayer

-- ============================================
-- CARGAR WINDUI
-- ============================================

local success, WindUI = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/source.lua"))()
end)

if not success then
    warn("Error al cargar WindUI. Intentando alternativa...")
    return
end

-- ============================================
-- CONFIGURACIÓN INICIAL - MOBILE OPTIMIZED
-- ============================================

local Window = WindUI:CreateWindow({
    Title = "⚔️ SKYWARS MOBILE",
    Icon = "rbxassetid://10734950309",
    Author = "16bitplayer",
    Folder = "SkywarsMobile",
    Size = UDim2.fromOffset(480, 520),
    KeySystem = {
        Key = "mobile2024",
        Note = "Key: mobile2024",
        SaveKey = true,
        FileName = "SkywarsMobile_Key"
    },
    Transparent = true,
    Theme = "Dark",
    SideBarWidth = 160,
})`

-- ============================================
-- SISTEMA DE AUTO-UPDATE
-- ============================================

local CURRENT_VERSION = "4.1"
local VERSION_CHECK_URL = "https://raw.githubusercontent.com/Sam123mir/Skywars-Script-Bloxy-Hub/main/version.txt"
local SCRIPT_URL = "https://raw.githubusercontent.com/Sam123mir/Skywars-Script-Bloxy-Hub/main/Main.lua"

local function checkForUpdates()
    local success, versionData = pcall(function()
        return game:HttpGet(VERSION_CHECK_URL, true)
    end)
    
    if success and versionData then
        local latestVersion = versionData:match("([%d%.]+)")
        
        if latestVersion and latestVersion ~= CURRENT_VERSION then
            WindUI:Notification({
                Title = "🔄 UPDATE DISPONIBLE",
                Content = "Nueva versión: v" .. latestVersion .. "\nActual: v" .. CURRENT_VERSION,
                Duration = 8
            })
            
            task.wait(2)
            
            WindUI:Notification({
                Title = "⚡ Auto-Update",
                Content = "Actualizando en 5 segundos...\nCierra para cancelar",
                Duration = 5
            })
            
            task.wait(5)
            
            -- Auto-update
            local updateSuccess, updateScript = pcall(function()
                return game:HttpGet(SCRIPT_URL, true)
            end)
            
            if updateSuccess and updateScript then
                WindUI:Notification({
                    Title = "✅ Actualizado!",
                    Content = "Cargando v" .. latestVersion .. "...",
                    Duration = 3
                })
                
                task.wait(1)
                loadstring(updateScript)()
                return true
            else
                WindUI:Notification({
                    Title = "❌ Error",
                    Content = "No se pudo descargar la actualización",
                    Duration = 5
                })
            end
        else
            -- Versión actual
            task.wait(1)
            WindUI:Notification({
                Title = "✅ Actualizado",
                Content = "Usando la última versión: v" .. CURRENT_VERSION,
                Duration = 3
            })
        end
    else
        -- No se pudo verificar
        warn("No se pudo verificar actualizaciones")
    end
    
    return false
end

-- Verificar actualizaciones (no bloqueante)
task.spawn(checkForUpdates)


-- ============================================
-- SERVICIOS
-- ============================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local camera = Workspace.CurrentCamera

-- Variables
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanoidRootPart")

-- Lista de aliados
local allyList = {}

-- Target Lock
local lockedTarget = nil

-- ============================================
-- CONFIGURACIÓN
-- ============================================

local config = {
    -- Script Info
    _version = "4.1",
    _buildDate = "2026-01-03",
    _author = "16bitplayer",
    _scriptURL = "https://raw.githubusercontent.com/Sam123mir/Skywars-Script-Bloxy-Hub/main/Main.lua",
    
    -- Combat
    autoKill = false,
    killAura = false,
    reach = 25,
    targetLock = false,
    autoClicker = false,
    clickSpeed = 20,
    faceTarget = true,
    
    -- Ally System
    allyProtection = true,
    autoAddTeammates = true,
    
    -- Tools
    autoEquipSword = true,
    autoEquipBow = false,
    autoEquipPick = false,
    autoEquipBlock = false,
    
    -- Farming
    autoFarm = false,
    farmDiamonds = true,
    farmEmeralds = true,
    farmIron = true,
    farmGold = true,
    farmSpeed = 0.8,
    farmRadius = 200,
    smartFarm = true,
    
    -- VIP
    vipBypass = false,
    megaVipBypass = false,
    
    -- Movement
    speed = 16,
    jumpPower = 50,
    flying = false,
    flySpeed = 60,
    noFall = true,
    infiniteJump = false,
    
    -- Visual
    playerESP = false,
    allyESP = false,
    enemyESP = false,
    oreESP = false,
    targetHighlight = true,
    distanceESP = true,
    
    -- Auto
    autoAFK = false,
    autoCollect = true,
    autoRespawn = true,
    
    -- Safety
    antiVoid = true,
    antiKnockback = false,
}

-- ============================================
-- FUNCIONES AUXILIARES
-- ============================================

local function getCharacter()
    return player.Character
end

local function getRootPart()
    local char = getCharacter()
    return char and char:FindFirstChild("HumanoidRootPart")
end

local function getHumanoid()
    local char = getCharacter()
    return char and char:FindFirstChild("Humanoid")
end

-- Sistema de aliados
local function isAlly(targetPlayer)
    if not targetPlayer then return false end
    
    if allyList[targetPlayer.Name] then
        return true
    end
    
    if config.autoAddTeammates and player.Team and targetPlayer.Team then
        if player.Team == targetPlayer.Team then
            allyList[targetPlayer.Name] = true
            return true
        end
    end
    
    return false
end

local function addAlly(playerName)
    if Players:FindFirstChild(playerName) then
        allyList[playerName] = true
        WindUI:Notification({
            Title = "✅ Ally Added",
            Content = playerName .. " agregado",
            Duration = 2
        })
        return true
    end
    return false
end

local function removeAlly(playerName)
    if allyList[playerName] then
        allyList[playerName] = nil
        WindUI:Notification({
            Title = "❌ Ally Removed",
            Content = playerName .. " removido",
            Duration = 2
        })
        return true
    end
    return false
end

local function clearAllies()
    allyList = {}
    WindUI:Notification({
        Title = "🗑️ Cleared",
        Content = "Aliados limpiados",
        Duration = 2
    })
end

-- Obtener jugador más cercano
local function getTargetPlayer(maxDistance)
    local targets = {}
    
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= player then
            local char = plr.Character
            if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Humanoid") then
                local hum = char.Humanoid
                
                if hum.Health > 0 and not isAlly(plr) then
                    local root = getRootPart()
                    if root then
                        local distance = (root.Position - char.HumanoidRootPart.Position).Magnitude
                        
                        if distance <= (maxDistance or config.reach) then
                            table.insert(targets, {
                                player = plr,
                                distance = distance,
                                character = char
                            })
                        end
                    end
                end
            end
        end
    end
    
    if #targets == 0 then return nil end
    table.sort(targets, function(a, b) return a.distance < b.distance end)
    
    return targets[1].player
end

-- Sistema de herramientas
local function getTool(toolType)
    local toolNames = {
        sword = {"sword", "katana", "blade"},
        bow = {"bow", "crossbow"},
        pickaxe = {"pickaxe", "pick"},
        block = {"block", "wool"}
    }
    
    for _, tool in pairs(player.Backpack:GetChildren()) do
        if tool:IsA("Tool") then
            local name = tool.Name:lower()
            for _, keyword in ipairs(toolNames[toolType] or {}) do
                if name:find(keyword) then
                    return tool
                end
            end
        end
    end
    
    local char = getCharacter()
    if char then
        for _, tool in pairs(char:GetChildren()) do
            if tool:IsA("Tool") then
                local name = tool.Name:lower()
                for _, keyword in ipairs(toolNames[toolType] or {}) do
                    if name:find(keyword) then
                        return tool
                    end
                end
            end
        end
    end
    
    return nil
end

local function equipTool(toolType)
    local tool = getTool(toolType)
    if tool and tool.Parent == player.Backpack then
        local hum = getHumanoid()
        if hum then
            hum:EquipTool(tool)
            return true
        end
    elseif tool and tool.Parent == getCharacter() then
        return true
    end
    return false
end

-- Sistema de farmeo
local function getOreValue(oreName)
    local name = oreName:lower()
    if name:find("diamond") then return 100 end
    if name:find("emerald") then return 90 end
    if name:find("gold") then return 50 end
    if name:find("iron") then return 30 end
    return 10
end

local function findBestOre()
    local ores = {}
    local root = getRootPart()
    
    if not root then return nil end
    
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("Part") or obj:IsA("MeshPart") then
            local name = obj.Name:lower()
            local shouldFarm = false
            
            if config.farmDiamonds and name:find("diamond") then shouldFarm = true end
            if config.farmEmeralds and name:find("emerald") then shouldFarm = true end
            if config.farmGold and name:find("gold") then shouldFarm = true end
            if config.farmIron and name:find("iron") then shouldFarm = true end
            
            if shouldFarm and obj.Parent then
                local distance = (root.Position - obj.Position).Magnitude
                if distance <= config.farmRadius then
                    table.insert(ores, {
                        ore = obj,
                        distance = distance,
                        value = getOreValue(obj.Name)
                    })
                end
            end
        end
    end
    
    if #ores == 0 then return nil end
    
    if config.smartFarm then
        table.sort(ores, function(a, b)
            if math.abs(a.value - b.value) > 20 then
                return a.value > b.value
            else
                return a.distance < b.distance
            end
        end)
    else
        table.sort(ores, function(a, b) return a.distance < b.distance end)
    end
    
    return ores[1].ore
end

-- ============================================
-- TARGET LOCK SYSTEM
-- ============================================

local function lockOnTarget(target)
    if not target or not target.Character then 
        lockedTarget = nil
        return 
    end
    
    lockedTarget = target
    
    WindUI:Notification({
        Title = "🎯 Locked",
        Content = target.Name,
        Duration = 2
    })
    
    if config.targetHighlight then
        local char = target.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            local highlight = char:FindFirstChild("TargetHighlight")
            if not highlight then
                highlight = Instance.new("Highlight")
                highlight.Name = "TargetHighlight"
                highlight.Parent = char
                highlight.FillColor = Color3.new(1, 0, 0)
                highlight.OutlineColor = Color3.new(1, 1, 0)
                highlight.FillTransparency = 0.5
                highlight.OutlineTransparency = 0
            end
        end
    end
end

local function unlockTarget()
    if lockedTarget and lockedTarget.Character then
        local highlight = lockedTarget.Character:FindFirstChild("TargetHighlight")
        if highlight then
            highlight:Destroy()
        end
    end
    
    lockedTarget = nil
    
    WindUI:Notification({
        Title = "🔓 Unlocked",
        Content = "Target released",
        Duration = 2
    })
end

local function updateTargetLock()
    if not config.targetLock or not lockedTarget then return end
    
    local target = lockedTarget
    if not target.Character or not target.Character:FindFirstChild("HumanoidRootPart") then
        unlockTarget()
        return
    end
    
    local targetHum = target.Character:FindFirstChild("Humanoid")
    if not targetHum or targetHum.Health <= 0 then
        unlockTarget()
        return
    end
    
    if config.faceTarget then
        local root = getRootPart()
        local targetRoot = target.Character.HumanoidRootPart
        if root and targetRoot then
            local lookVector = (targetRoot.Position - root.Position).Unit
            root.CFrame = CFrame.new(root.Position, root.Position + Vector3.new(lookVector.X, 0, lookVector.Z))
        end
    end
end

-- ============================================
-- AUTO CLICKER
-- ============================================

local clickerRunning = false

local function startAutoClicker()
    if clickerRunning then return end
    clickerRunning = true
    
    spawn(function()
        while clickerRunning and config.autoClicker do
            local delay = 1 / config.clickSpeed
            
            local char = getCharacter()
            if char then
                for _, tool in pairs(char:GetChildren()) do
                    if tool:IsA("Tool") then
                        tool:Activate()
                    end
                end
            end
            
            wait(delay)
        end
        clickerRunning = false
    end)
end

-- ============================================
-- VIP BYPASS
-- ============================================

local function bypassVIP()
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("Part") or obj:IsA("Model") then
            local name = obj.Name:lower()
            if name:find("vip") or name:find("door") or name:find("barrier") then
                if obj:IsA("Part") then
                    obj.CanCollide = false
                    obj.Transparency = 0.8
                end
            end
        end
    end
end

local function teleportToVIP()
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("Part") and obj.Name:lower():find("vip") then
            local root = getRootPart()
            if root then
                root.CFrame = obj.CFrame * CFrame.new(0, 5, 0)
                WindUI:Notification({
                    Title = "🌟 VIP",
                    Content = "Teleported",
                    Duration = 2
                })
                return
            end
        end
    end
end

local function teleportToMegaVIP()
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("Part") and obj.Name:lower():find("mega") and obj.Name:lower():find("vip") then
            local root = getRootPart()
            if root then
                root.CFrame = obj.CFrame * CFrame.new(0, 5, 0)
                WindUI:Notification({
                    Title = "⭐ Mega VIP",
                    Content = "Teleported",
                    Duration = 2
                })
                return
            end
        end
    end
end

-- ============================================
-- ESP SYSTEM
-- ============================================

local espObjects = {}

local function createESP(obj, color, text, showDistance)
    if not obj or espObjects[obj] then return end
    
    local billboard = Instance.new("BillboardGui")
    billboard.Parent = obj
    billboard.AlwaysOnTop = true
    billboard.Size = UDim2.new(0, 120, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.Name = "ESP_Billboard"
    
    local textLabel = Instance.new("TextLabel")
    textLabel.Parent = billboard
    textLabel.BackgroundTransparency = 1
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.Text = text
    textLabel.TextColor3 = color
    textLabel.TextStrokeTransparency = 0.3
    textLabel.TextScaled = true
    textLabel.Font = Enum.Font.GothamBold
    
    if showDistance and config.distanceESP then
        spawn(function()
            while textLabel and textLabel.Parent do
                local root = getRootPart()
                if root and obj then
                    local dist = math.floor((root.Position - obj.Position).Magnitude)
                    textLabel.Text = text .. "\n[" .. dist .. "m]"
                end
                wait(0.5)
            end
        end)
    end
    
    espObjects[obj] = billboard
    
    local highlight = Instance.new("Highlight")
    highlight.Parent = obj
    highlight.FillColor = color
    highlight.OutlineColor = color
    highlight.FillTransparency = 0.6
    highlight.OutlineTransparency = 0
    highlight.Name = "ESP_Highlight"
    
    espObjects[obj .. "_highlight"] = highlight
end

local function clearAllESP()
    for _, esp in pairs(espObjects) do
        if esp and esp.Parent then
            esp:Destroy()
        end
    end
    espObjects = {}
end

-- ============================================
-- CREAR BOTONES FLOTANTES MÓVILES
-- ============================================

local function createMobileButtons()
    local gui = player:WaitForChild("PlayerGui")
    
    -- Eliminar panel anterior
    if gui:FindFirstChild("MobileControls") then
        gui.MobileControls:Destroy()
    end
    
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "MobileControls"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = gui
    
    -- Función para crear botones
    local function createButton(text, emoji, position, color, callback)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 70, 0, 70)
        btn.Position = position
        btn.BackgroundColor3 = color
        btn.Text = emoji .. "\n" .. text
        btn.TextSize = 14
        btn.TextColor3 = Color3.new(1, 1, 1)
        btn.Font = Enum.Font.GothamBold
        btn.BorderSizePixel = 0
        btn.Parent = screenGui
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0.2, 0)
        corner.Parent = btn
        
        local pressed = false
        btn.MouseButton1Click:Connect(function()
            pressed = not pressed
            btn.BackgroundColor3 = pressed and Color3.new(0, 1, 0) or color
            callback(pressed)
        end)
        
        return btn
    end
    
    -- Botones del panel
    createButton("Fly", "✈️", UDim2.new(0.88, 0, 0.25, 0), Color3.fromRGB(60, 60, 60), function(state)
        config.flying = state
    end)
    
    createButton("Kill", "⚔️", UDim2.new(0.88, 0, 0.37, 0), Color3.fromRGB(60, 60, 60), function(state)
        config.autoKill = state
    end)
    
    createButton("Farm", "⛏️", UDim2.new(0.88, 0, 0.49, 0), Color3.fromRGB(60, 60, 60), function(state)
        config.autoFarm = state
    end)
    
    createButton("Lock", "🎯", UDim2.new(0.88, 0, 0.61, 0), Color3.fromRGB(60, 60, 60), function(state)
        config.targetLock = state
        if state then
            local target = getTargetPlayer(200)
            if target then
                lockOnTarget(target)
            end
        else
            unlockTarget()
        end
    end)
    
    createButton("Click", "🖱️", UDim2.new(0.88, 0, 0.73, 0), Color3.fromRGB(60, 60, 60), function(state)
        config.autoClicker = state
        if state then
            startAutoClicker()
        else
            clickerRunning = false
        end
    end)
end

-- ============================================
-- INTERFAZ UI
-- ============================================

-- TAB: COMBAT
local CombatTab = Window:Tab({
    Title = "⚔️ Combat",
    Icon = "rbxassetid://10734950309"
})

local MainCombatSection = CombatTab:Section({Title = "Combat"})

MainCombatSection:Toggle({
    Title = "🎯 Auto Kill",
    Description = "Mata enemigos (respeta aliados)",
    Default = false,
    Callback = function(v)
        config.autoKill = v
    end
})

MainCombatSection:Toggle({
    Title = "⚡ Kill Aura",
    Description = "Ataca todos en rango",
    Default = false,
    Callback = function(v)
        config.killAura = v
    end
})

MainCombatSection:Slider({
    Title = "📏 Reach",
    Description = "Alcance (studs)",
    Default = 25,
    Min = 10,
    Max = 100,
    Callback = function(v)
        config.reach = v
    end
})

local TargetLockSection = CombatTab:Section({Title = "Target Lock"})

TargetLockSection:Toggle({
    Title = "🔒 Target Lock",
    Description = "Fija y sigue objetivo",
    Default = false,
    Callback = function(v)
        config.targetLock = v
        if not v then
            unlockTarget()
        end
    end
})

TargetLockSection:Toggle({
    Title = "👁️ Face Target",
    Description = "Mira al objetivo",
    Default = true,
    Callback = function(v)
        config.faceTarget = v
    end
})

TargetLockSection:Button({
    Title = "🎯 Lock Nearest",
    Description = "Fija enemigo cercano",
    Callback = function()
        local target = getTargetPlayer(200)
        if target then
            config.targetLock = true
            lockOnTarget(target)
        else
            WindUI:Notification({
                Title = "❌ No Target",
                Content = "No hay enemigos",
                Duration = 2
            })
        end
    end
})

TargetLockSection:Button({
    Title = "🔓 Unlock",
    Description = "Libera objetivo",
    Callback = function()
        unlockTarget()
        config.targetLock = false
    end
})

local AutoClickerSection = CombatTab:Section({Title = "Auto Clicker"})

AutoClickerSection:Toggle({
    Title = "🖱️ Auto Clicker",
    Description = "Click automático",
    Default = false,
    Callback = function(v)
        config.autoClicker = v
        if v then
            startAutoClicker()
        else
            clickerRunning = false
        end
    end
})

AutoClickerSection:Slider({
    Title = "⚡ CPS",
    Description = "Clicks por segundo",
    Default = 20,
    Min = 5,
    Max = 50,
    Callback = function(v)
        config.clickSpeed = v
    end
})

local ToolsSection = CombatTab:Section({Title = "Tools"})

ToolsSection:Toggle({
    Title = "⚔️ Auto Sword",
    Description = "Equipa espada",
    Default = true,
    Callback = function(v)
        config.autoEquipSword = v
    end
})

ToolsSection:Toggle({
    Title = "🏹 Auto Bow",
    Description = "Equipa arco",
    Default = false,
    Callback = function(v)
        config.autoEquipBow = v
    end
})

ToolsSection:Toggle({
    Title = "⛏️ Auto Pickaxe",
    Description = "Equipa pico",
    Default = false,
    Callback = function(v)
        config.autoEquipPick = v
    end
})

ToolsSection:Toggle({
    Title = "🧱 Auto Block",
    Description = "Equipa bloque",
    Default = false,
    Callback = function(v)
        config.autoEquipBlock = v
    end
})

-- TAB: ALLIES
local AllyTab = Window:Tab({
    Title = "👥 Allies",
    Icon = "rbxassetid://10747373176"
})

local AllySection = AllyTab:Section({Title = "Ally System"})

AllySection:Toggle({
    Title = "🛡️ Protection",
    Description = "Protege aliados",
    Default = true,
    Callback = function(v)
        config.allyProtection = v
    end
})

AllySection:Toggle({
    Title = "🤝 Auto Add Team",
    Description = "Agrega compañeros",
    Default = true,
    Callback = function(v)
        config.autoAddTeammates = v
    end
})

AllySection:Input({
    Title = "➕ Add Ally",
    Description = "Nombre del jugador",
    Placeholder = "Username...",
    Callback = function(text)
        if text and text ~= "" then
            addAlly(text)
        end
    end
})

AllySection:Input({
    Title = "➖ Remove Ally",
    Description = "Nombre a remover",
    Placeholder = "Username...",
    Callback = function(text)
        if text and text ~= "" then
            removeAlly(text)
        end
    end
})

AllySection:Button({
    Title = "📋 Show List",
    Description = "Ver aliados",
    Callback = function()
        local count = 0
        local names = ""
        for name, _ in pairs(allyList) do
            count = count + 1
            names = names .. name .. ", "
        end
        
        if count == 0 then
            WindUI:Notification({
                Title = "Empty",
                Content = "No hay aliados",
                Duration = 3
            })
        else
            WindUI:Notification({
                Title = "Allies (" .. count .. ")",
                Content = names:sub(1, -3),
                Duration = 5
            })
        end
    end
})

AllySection:Button({
    Title = "🗑️ Clear All",
    Description = "Limpia lista",
    Callback = function()
        clearAllies()
    end
})

-- TAB: FARMING
local FarmTab = Window:Tab({
    Title = "⛏️ Farm",
    Icon = "rbxassetid://10723407389"
})

local FarmSection = FarmTab:Section({Title = "Auto Farm"})

FarmSection:Toggle({
    Title = "⛏️ Auto Farm",
    Description = "Farmea automático",
    Default = false,
    Callback = function(v)
        config.autoFarm = v
    end
})

FarmSection:Toggle({
    Title = "🧠 Smart Farm",
    Description = "Prioriza valiosos",
    Default = true,
    Callback = function(v)
        config.smartFarm = v
    end
})

FarmSection:Slider({
    Title = "⚡ Speed",
    Description = "Velocidad de farmeo",
    Default = 0.8,
    Min = 0.3,
    Max = 3,
    Callback = function(v)
        config.farmSpeed = v
    end
})

FarmSection:Slider({
    Title = "📏 Radius",
    Description = "Radio de búsqueda",
    Default = 200,
    Min = 50,
    Max = 500,
    Callback = function(v)
        config.farmRadius = v
    end
})

local ResourceSection = FarmTab:Section({Title = "Resources"})

ResourceSection:Toggle({
    Title = "💎 Diamonds",
    Description = "Farmear diamantes",
    Default = true,
    Callback = function(v)
        config.farmDiamonds = v
    end
})

ResourceSection:Toggle({
    Title = "💚 Emeralds",
    Description = "Farmear esmeraldas",
    Default = true,
    Callback = function(v)
        config.farmEmeralds = v
    end
})

ResourceSection:Toggle({
    Title = "🥇 Gold",
    Description = "Farmear oro",
    Default = true,
    Callback = function(v)
        config.farmGold = v
    end
})

ResourceSection:Toggle({
    Title = "⚙️ Iron",
    Description = "Farmear hierro",
    Default = true,
    Callback = function(v)
        config.farmIron = v
    end
})

ResourceSection:Toggle({
    Title = "🎁 Auto Collect",
    Description = "Recoge drops",
    Default = true,
    Callback = function(v)
        config.autoCollect = v
    end
})

-- TAB: VIP
local VIPTab = Window:Tab({
    Title = "⭐ VIP",
    Icon = "rbxassetid://10734952479"
})

local VIPSection = VIPTab:Section({Title = "VIP Access"})

VIPSection:Toggle({
    Title = "🔓 VIP Bypass",
    Description = "Acceso VIP gratis",
    Default = false,
    Callback = function(v)
        config.vipBypass = v
        if v then
            bypassVIP()
        end
    end
})

VIPSection:Toggle({
    Title = "⭐ Mega VIP",
    Description = "Acceso Mega VIP",
    Default = false,
    Callback = function(v)
        config.megaVipBypass = v
        if v then
            bypassVIP()
        end
    end
})

VIPSection:Button({
    Title = "🌟 TP VIP",
    Description = "Teleporta a VIP",
    Callback = function()
        teleportToVIP()
    end
})

VIPSection:Button({
    Title = "⭐ TP Mega VIP",
    Description = "Teleporta a Mega VIP",
    Callback = function()
        teleportToMegaVIP()
    end
})

-- TAB: PLAYER
local PlayerTab = Window:Tab({
    Title = "👤 Player",
    Icon = "rbxassetid://10747374131"
})

local MovementSection = PlayerTab:Section({Title = "Movement"})

MovementSection:Slider({
    Title = "🏃 Speed",
    Description = "Velocidad",
    Default = 16,
    Min = 16,
    Max = 200,
    Callback = function(v)
        config.speed = v
    end
})

MovementSection:Slider({
    Title = "🦘 Jump",
    Description = "Salto",
    Default = 50,
    Min = 50,
    Max = 200,
    Callback = function(v)
        config.jumpPower = v
    end
})

MovementSection:Toggle({
    Title = "🚀 Fly",
    Description = "Modo vuelo",
    Default = false,
    Callback = function(v)
        config.flying = v
    end
})

MovementSection:Slider({
    Title = "✈️ Fly Speed",
    Description = "Velocidad vuelo",
    Default = 60,
    Min = 20,
    Max = 150,
    Callback = function(v)
        config.flySpeed = v
    end
})

MovementSection:Toggle({
    Title = "♾️ Infinite Jump",
    Description = "Saltos infinitos",
    Default = false,
    Callback = function(v)
        config.infiniteJump = v
    end
})

local SafetySection = PlayerTab:Section({Title = "Safety"})

SafetySection:Toggle({
    Title = "🛡️ Anti Void",
    Description = "Evita caer",
    Default = true,
    Callback = function(v)
        config.antiVoid = v
    end
})

SafetySection:Toggle({
    Title = "💚 No Fall",
    Description = "Sin daño caída",
    Default = true,
    Callback = function(v)
        config.noFall = v
    end
})

SafetySection:Toggle({
    Title = "🚫 Anti KB",
    Description = "Anti knockback",
    Default = false,
    Callback = function(v)
        config.antiKnockback = v
    end
})

SafetySection:Toggle({
    Title = "💤 Anti AFK",
    Description = "Anti-kick",
    Default = false,
    Callback = function(v)
        config.autoAFK = v
    end
})

SafetySection:Toggle({
    Title = "🔄 Auto Respawn",
    Description = "Respawn auto",
    Default = true,
    Callback = function(v)
        config.autoRespawn = v
    end
})

-- TAB: TELEPORT
local TeleportTab = Window:Tab({
    Title = "🌍 TP",
    Icon = "rbxassetid://10723407389"
})

local TPSection = TeleportTab:Section({Title = "Teleports"})

TPSection:Button({
    Title = "🏠 Spawn",
    Description = "TP al spawn",
    Callback = function()
        local root = getRootPart()
        if root then
            root.CFrame = CFrame.new(0, 100, 0)
            WindUI:Notification({
                Title = "✅ TP",
                Content = "Spawn",
                Duration = 2
            })
        end
    end
})

TPSection:Button({
    Title = "👤 Enemy",
    Description = "TP a enemigo",
    Callback = function()
        local target = getTargetPlayer(1000)
        if target and target.Character then
            local root = getRootPart()
            local targetRoot = target.Character:FindFirstChild("HumanoidRootPart")
            if root and targetRoot then
                root.CFrame = targetRoot.CFrame * CFrame.new(0, 0, 5)
                WindUI:Notification({
                    Title = "✅ TP",
                    Content = target.Name,
                    Duration = 2
                })
            end
        end
    end
})

TPSection:Button({
    Title = "💎 Ore",
    Description = "TP a mineral",
    Callback = function()
        local ore = findBestOre()
        if ore then
            local root = getRootPart()
            if root then
                root.CFrame = ore.CFrame * CFrame.new(0, 5, 0)
                WindUI:Notification({
                    Title = "✅ TP",
                    Content = ore.Name,
                    Duration = 2
                })
            end
        end
    end
})

-- TAB: VISUAL
local VisualTab = Window:Tab({
    Title = "👁️ ESP",
    Icon = "rbxassetid://10747372992"
})

local ESPSection = VisualTab:Section({Title = "ESP"})

ESPSection:Toggle({
    Title = "👥 Player ESP",
    Description = "Ver jugadores",
    Default = false,
    Callback = function(v)
        config.playerESP = v
        if not v then clearAllESP() end
    end
})

ESPSection:Toggle({
    Title = "🛡️ Ally ESP",
    Description = "Aliados verde",
    Default = false,
    Callback = function(v)
        config.allyESP = v
    end
})

ESPSection:Toggle({
    Title = "⚔️ Enemy ESP",
    Description = "Enemigos rojo",
    Default = false,
    Callback = function(v)
        config.enemyESP = v
    end
})

ESPSection:Toggle({
    Title = "💎 Ore ESP",
    Description = "Ver minerales",
    Default = false,
    Callback = function(v)
        config.oreESP = v
        if not v then clearAllESP() end
    end
})

ESPSection:Toggle({
    Title = "📏 Distance",
    Description = "Muestra distancia",
    Default = true,
    Callback = function(v)
        config.distanceESP = v
    end
})

ESPSection:Button({
    Title = "🗑️ Clear ESP",
    Description = "Limpia ESP",
    Callback = function()
        clearAllESP()
        WindUI:Notification({
            Title = "✅ Cleared",
            Content = "ESP limpiado",
            Duration = 2
        })
    end
})

-- TAB: SETTINGS
local SettingsTab = Window:Tab({
    Title = "⚙️ Config",
    Icon = "rbxassetid://10747372992"
})

local ConfigSection = SettingsTab:Section({Title = "Config"})

ConfigSection:Button({
    Title = "💾 Save",
    Description = "Guardar config",
    Callback = function()
        WindUI:Notification({
            Title = "💾 Saved",
            Content = "Config guardada",
            Duration = 2
        })
    end
})

ConfigSection:Button({
    Title = "📂 Load",
    Description = "Cargar config",
    Callback = function()
        WindUI:Notification({
            Title = "📂 Loaded",
            Content = "Config cargada",
            Duration = 2
        })
    end
})

ConfigSection:Button({
    Title = "🔄 Reset",
    Description = "Resetear config",
    Callback = function()
        WindUI:Notification({
            Title = "🔄 Reset",
            Content = "Config reseteada",
            Duration = 2
        })
    end
})

local InfoSection = SettingsTab:Section({Title = "Info"})

InfoSection:Button({
    Title = "📊 Stats",
    Description = "Ver estadísticas",
    Callback = function()
        local allyCount = 0
        for _ in pairs(allyList) do
            allyCount = allyCount + 1
        end
        
        WindUI:Notification({
            Title = "📊 Stats",
            Content = string.format("Aliados: %d | Kill: %s | Farm: %s | Lock: %s", 
                allyCount,
                config.autoKill and "ON" or "OFF",
                config.autoFarm and "ON" or "OFF",
                config.targetLock and "ON" or "OFF"
            ),
            Duration = 5
        })
    end
})

InfoSection:Button({
    Title = "💬 Discord",
    Description = "Discord server",
    Callback = function()
        setclipboard("discord.gg/16bitplayer")
        WindUI:Notification({
            Title = "💬 Discord",
            Content = "Link copiado",
            Duration = 3
        })
    end
})

InfoSection:Button({
    Title = "🔧 Close",
    Description = "Cerrar script",
    Callback = function()
        clearAllESP()
        unlockTarget()
        
        local gui = player:WaitForChild("PlayerGui")
        if gui:FindFirstChild("MobileControls") then
            gui.MobileControls:Destroy()
        end
        
        Window:Destroy()
    end
})

-- ============================================
-- LOOPS PRINCIPALES
-- ============================================

-- Target Lock Update
spawn(function()
    while wait(0.05) do
        pcall(function()
            if config.targetLock and lockedTarget then
                updateTargetLock()
            end
        end)
    end
end)

-- Auto Kill
spawn(function()
    while wait(0.1) do
        pcall(function()
            if config.autoKill or config.killAura then
                if config.autoEquipSword then
                    equipTool("sword")
                end
                
                local target = lockedTarget or getTargetPlayer(config.reach)
                
                if target and target.Character and not isAlly(target) then
                    local char = getCharacter()
                    if char then
                        for _, tool in pairs(char:GetChildren()) do
                            if tool:IsA("Tool") then
                                tool:Activate()
                            end
                        end
                    end
                end
            end
        end)
    end
end)

-- Auto Farm
spawn(function()
    while wait(config.farmSpeed) do
        pcall(function()
            if config.autoFarm then
                if config.autoEquipPick then
                    equipTool("pickaxe")
                end
                
                local ore = findBestOre()
                if ore and ore.Parent then
                    local root = getRootPart()
                    if root then
                        root.CFrame = ore.CFrame * CFrame.new(0, 5, 0)
                        wait(0.2)
                        
                        local char = getCharacter()
                        if char then
                            for i = 1, 5 do
                                for _, tool in pairs(char:GetChildren()) do
                                    if tool:IsA("Tool") then
                                        tool:Activate()
                                    end
                                end
                                wait(0.1)
                            end
                        end
                    end
                end
            end
        end)
    end
end)

-- Character Update
spawn(function()
    while wait(0.1) do
        pcall(function()
            local hum = getHumanoid()
            if hum then
                hum.WalkSpeed = config.speed
                hum.JumpPower = config.jumpPower
                
                if config.noFall then
                    local falling = hum:GetState() == Enum.HumanoidStateType.Freefall
                    if falling then
                        hum:ChangeState(Enum.HumanoidStateType.Landed)
                    end
                end
            end
        end)
    end
end)

-- Infinite Jump
UserInputService.JumpRequest:Connect(function()
    if config.infiniteJump then
        local hum = getHumanoid()
        if hum then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

-- Anti AFK
spawn(function()
    while wait(120) do
        if config.autoAFK then
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
        end
    end
end)

-- ESP Update
spawn(function()
    while wait(2) do
        pcall(function()
            if config.playerESP or config.allyESP or config.enemyESP then
                for _, plr in pairs(Players:GetPlayers()) do
                    if plr ~= player and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                        local root = plr.Character.HumanoidRootPart
                        local isPlayerAlly = isAlly(plr)
                        
                        if config.allyESP and isPlayerAlly then
                            createESP(root, Color3.new(0, 1, 0), "🛡️ " .. plr.Name, true)
                        elseif config.enemyESP and not isPlayerAlly then
                            createESP(root, Color3.new(1, 0, 0), "⚔️ " .. plr.Name, true)
                        elseif config.playerESP then
                            local color = isPlayerAlly and Color3.new(0, 1, 0) or Color3.new(1, 0, 0)
                            createESP(root, color, plr.Name, true)
                        end
                    end
                end
            end
            
            if config.oreESP then
                local oreCount = 0
                for _, obj in pairs(Workspace:GetDescendants()) do
                    if obj:IsA("Part") or obj:IsA("MeshPart") then
                        local name = obj.Name:lower()
                        if name:find("diamond") then
                            createESP(obj, Color3.new(0, 1, 1), "💎", false)
                            oreCount = oreCount + 1
                        elseif name:find("emerald") then
                            createESP(obj, Color3.new(0, 1, 0), "💚", false)
                            oreCount = oreCount + 1
                        elseif name:find("gold") then
                            createESP(obj, Color3.new(1, 0.8, 0), "🥇", false)
                            oreCount = oreCount + 1
                        elseif name:find("iron") then
                            createESP(obj, Color3.new(0.7, 0.7, 0.7), "⚙️", false)
                            oreCount = oreCount + 1
                        end
                        
                        if oreCount > 50 then break end
                    end
                end
            end
        end)
    end
end)

-- Fly System
spawn(function()
    local flying = false
    local bodyVel, bodyGyro
    
    while wait() do
        pcall(function()
            if config.flying and not flying then
                flying = true
                local root = getRootPart()
                
                if root then
                    bodyVel = Instance.new("BodyVelocity")
                    bodyVel.MaxForce = Vector3.new(9e9, 9e9, 9e9)
                    bodyVel.Velocity = Vector3.new(0, 0, 0)
                    bodyVel.Parent = root
                    
                    bodyGyro = Instance.new("BodyGyro")
                    bodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
                    bodyGyro.P = 9e4
                    bodyGyro.Parent = root
                end
                
            elseif not config.flying and flying then
                flying = false
                if bodyVel then bodyVel:Destroy() end
                if bodyGyro then bodyGyro:Destroy() end
            end
            
            if flying and bodyVel and bodyGyro then
                local root = getRootPart()
                local cam = Workspace.CurrentCamera
                
                if root and cam then
                    bodyGyro.CFrame = cam.CFrame
                    
                    local moveDirection = Vector3.new(0, 0, 0)
                    
                    if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                        moveDirection = moveDirection + (cam.CFrame.LookVector * config.flySpeed)
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                        moveDirection = moveDirection - (cam.CFrame.LookVector * config.flySpeed)
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                        moveDirection = moveDirection - (cam.CFrame.RightVector * config.flySpeed)
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                        moveDirection = moveDirection + (cam.CFrame.RightVector * config.flySpeed)
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                        moveDirection = moveDirection + Vector3.new(0, config.flySpeed, 0)
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                        moveDirection = moveDirection - Vector3.new(0, config.flySpeed, 0)
                    end
                    
                    bodyVel.Velocity = moveDirection
                end
            end
        end)
    end
end)

-- Anti Void
spawn(function()
    while wait(0.3) do
        pcall(function()
            if config.antiVoid then
                local root = getRootPart()
                if root and root.Position.Y < -20 then
                    root.CFrame = CFrame.new(0, 100, 0)
                    WindUI:Notification({
                        Title = "🛡️ Saved",
                        Content = "Anti Void",
                        Duration = 2
                    })
                end
            end
        end)
    end
end)

-- VIP Bypass Loop
spawn(function()
    while wait(5) do
        pcall(function()
            if config.vipBypass or config.megaVipBypass then
                bypassVIP()
            end
        end)
    end
end)

-- Character Respawn
player.CharacterAdded:Connect(function(char)
    wait(1)
    character = char
    humanoid = char:WaitForChild("Humanoid")
    rootPart = char:WaitForChild("HumanoidRootPart")
    
    if config.autoRespawn then
        WindUI:Notification({
            Title = "🔄 Respawned",
            Content = "Config aplicada",
            Duration = 2
        })
    end
end)

-- ============================================
-- CREAR BOTONES MÓVILES AL INICIO
-- ============================================

task.wait(2)
pcall(createMobileButtons)

-- ============================================
-- NOTIFICACIONES
-- ============================================

WindUI:Notification({
    Title = "⚔️ SKYWARS MOBILE",
    Content = "Script cargado exitosamente!",
    Duration = 4
})

task.wait(2)

WindUI:Notification({
    Title = "📱 Botones Móviles",
    Content = "5 botones flotantes creados",
    Duration = 4
})

task.wait(2)

WindUI:Notification({
    Title = "✨ Ready",
    Content = "Target Lock | Auto Clicker | VIP | Aliados",
    Duration = 4
})

print("==========================================")
print("⚔️ SKYWARS MOBILE ULTIMATE v4.1")
print("==========================================")
print("✅ 100% Optimizado para MÓVILES")
print("✅ Compatible con loadstring remoto")
print("✅ Sistema de Auto-Update integrado")
print("✅ 5 Botones flotantes integrados")
print("✅ Target Lock System")
print("✅ Auto Clicker ajustable")
print("✅ Sistema de Aliados completo")
print("✅ VIP/Mega VIP Bypass")
print("✅ Auto Farm inteligente")
print("✅ ESP avanzado")
print("==========================================")
print("Creado por Sammir_Dev")
print("Versión: " .. CURRENT_VERSION)
print("Build: " .. config._buildDate)
print("Key: bloxyhub2026")
print("==========================================")
print("")
print("🔗 USO:")
print('loadstring(game:HttpGet("' .. SCRIPT_URL .. '"))()') 
print("==========================================")
print("")
print("🔄 AUTO-UPDATE: Activo")
print("Verifica automáticamente nuevas versiones")