# 📚 NOTEBOOK 1: Professional Roblox Scripting Techniques (2026)

## Creado por: Samir (16bitplayer)
**Fecha:** 2026-01-04  
**Objetivo:** Documentar técnicas de VERDADEROS desarrolladores profesionales

---

## 🎯 PRINCIPIOS FUNDAMENTALES

### 1. **"Never Trust The Client"**
> El principio MÁS importante en scripting avanzado

```lua
-- ❌ MAL (Código amateur):
game.ReplicatedStorage.DamagePlayer:FireServer(target, 9999)

-- ✅ BIEN (Código profesional):
-- SERVER SIDE:
game.ReplicatedStorage.DamagePlayer.OnServerEvent:Connect(function(player, target)
    -- Validar TODO en el servidor
    if not target or not target:IsA("Player") then return end
    if (player.Character.HumanoidRootPart.Position - target.Character.HumanoidRootPart.Position).Magnitude > 50 then
        return -- Anti-cheat: demasiado lejos
    end
    
    local damage = 10 -- El servidor DECIDE el daño, no el cliente
    target.Character.Humanoid:TakeDamage(damage)
end)
```

**Por qué esto importa:**
- Los exploiters tienen CONTROL TOTAL sobre su cliente
- Cualquier validación client-side puede ser bypasseada
- El servidor es la ÚNICA fuente de verdad

---

## ⚡ TÉCNICA 1: Performance Optimization

### A. Targeting 60 FPS Constante

```lua
-- Sistema de Profiling Profesional
local RunService = game:GetService("RunService")
local PerformanceTracker = {}

function PerformanceTracker:Start(label)
    local startTime = tick()
    return function()
        local elapsed = (tick() - startTime) * 1000 -- ms
        if elapsed > 16.67 then -- >16.67ms = <60 FPS
            warn(string.format("[PERF] %s took %.2fms (SLOW!)", label, elapsed))
        end
    end
end

-- Uso:
local finish = PerformanceTracker:Start("Combat Logic")
-- ... tu código aquí ...
finish()
```

### B. Debouncing & Throttling

```lua
-- Debounce Pattern (prevenir spam)
local debounce = false
button.MouseButton1Click:Connect(function()
    if debounce then return end
    debounce = true
    
    -- Acción
    print("Clicked!")
    
    task.wait(0.5) -- Cooldown
    debounce = false
end)

-- Throttle Pattern (limitar frecuencia)
local lastCall = 0
local THROTTLE_INTERVAL = 0.1

RunService.Heartbeat:Connect(function()
    if tick() - lastCall < THROTTLE_INTERVAL then return end
    lastCall = tick()
    
    -- Acción que se ejecuta máximo 10 veces por segundo
    updateESP()
end)
```

### C. Efficient Data Structures

```lua
-- ❌ LENTO: Buscar en array
local players = {player1, player2, player3, ...}
for _, p in ipairs(players) do
    if p.UserId == targetId then
        -- Encontrado
    end
end

-- ✅ RÁPIDO: Dictionary lookup O(1)
local playersByUserId = {
    [12345] = player1,
    [67890] = player2
}
local target = playersByUserId[targetId] -- Instantáneo
```

---

## 🏗️ TÉCNICA 2: Object-Oriented Programming (OOP)

### Patrón Profesional: Class System

```lua
-- EntityClass.lua (Module)
local Entity = {}
Entity.__index = Entity

-- Constructor
function Entity.new(character)
    local self = setmetatable({}, Entity)
    
    self.Character = character
    self.HumanoidRootPart = character:WaitForChild("HumanoidRootPart")
    self.Humanoid = character:WaitForChild("Humanoid")
    self.IsAlive = true
    
    -- Auto-cleanup on death
    self.Humanoid.Died:Connect(function()
        self:Destroy()
    end)
    
    return self
end

-- Methods
function Entity:GetDistance(otherEntity)
    return (self.HumanoidRootPart.Position - otherEntity.HumanoidRootPart.Position).Magnitude
end

function Entity:IsInRange(range)
    local localPlayer = game.Players.LocalPlayer
    if not localPlayer.Character then return false end
    
    local distance = (self.HumanoidRootPart.Position - localPlayer.Character.HumanoidRootPart.Position).Magnitude
    return distance <= range
end

function Entity:Destroy()
    self.IsAlive = false
    self.Character = nil
    -- Limpieza
end

return Entity

-- USO:
local EntityClass = require(script.EntityClass)
local enemy = EntityClass.new(workspace.Enemy)
print(enemy:GetDistance(player))
```

**Ventajas:**
- Código reusable
- Fácil de mantener
- Escalable para proyectos grandes

---

## 🔄 TÉCNICA 3: State Management

### Pattern: Redux-style (como los pros)

```lua
local StateManager = {}
local currentState = {}
local listeners = {}

-- Reducer pattern
function StateManager:dispatch(action)
    local newState = table.clone(currentState)
    
    if action.type == "UPDATE_TARGET" then
        newState.currentTarget = action.payload
    elseif action.type == "SET_COMBAT_MODE" then
        newState.combatEnabled = action.payload
    end
    
    currentState = newState
    
    -- Notificar listeners
    for _, listener in ipairs(listeners) do
        listener(currentState)
    end
end

-- Subscribe pattern
function StateManager:subscribe(callback)
    table.insert(listeners, callback)
end

-- Uso:
StateManager:subscribe(function(state)
    if state.combatEnabled then
        startCombat(state.currentTarget)
    end
end)

StateManager:dispatch({
    type = "UPDATE_TARGET",
    payload = enemyEntity
})
```

---

## 🛡️ TÉCNICA 4: Server-Client Architecture

### A. RemoteEvents Pattern

```lua
-- Shared Module (ReplicatedStorage)
local Events = {
    Combat = Instance.new("RemoteEvent"),
    Movement = Instance.new("RemoteEvent"),
    RequestData = Instance.new("RemoteFunction")
}

for name, event in pairs(Events) do
    event.Name = name
    event.Parent = game.ReplicatedStorage.Events
end

return Events

-- Server Script:
local Events = require(game.ReplicatedStorage.Events)

Events.Combat.OnServerEvent:Connect(function(player, action, target)
    -- SIEMPRE validar en servidor
    if action == "Attack" then
        validateAndDamage(player, target)
    end
end)

-- Client Script (Exploit):
local Events = require(game.ReplicatedStorage.Events)
Events.Combat:FireServer("Attack", targetPlayer)
```

### B. Anti-Cheat Evasion

```lua
-- Técnica: Humanizar acciones (no perfectas)
local function humanizedWait(duration)
    local variance = math.random(-50, 50) / 1000 -- ±50ms
    task.wait(duration + variance)
end

-- Técnica: Randomizar valores
local function getRandomizedDamage(baseDamage)
    return baseDamage + math.random(-2, 2)
end

-- Técnica: Simular input delays
local lastAction = tick()
function performAction()
    local timeSinceLastAction = tick() - lastAction
    if timeSinceLastAction < 0.1 then
        -- Demasiado rápido, esperar un poco
        humanizedWait(0.1 - timeSinceLastAction)
    end
    
    -- Acción
    lastAction = tick()
end
```

---

## 🧠 TÉCNICA 5: Advanced Patterns

### A. Event Bus Pattern

```lua
local EventBus = {}
local events = {}

function EventBus:on(eventName, callback)
    if not events[eventName] then
        events[eventName] = {}
    end
    table.insert(events[eventName], callback)
end

function EventBus:emit(eventName, ...)
    if events[eventName] then
        for _, callback in ipairs(events[eventName]) do
            task.spawn(callback, ...)
        end
    end
end

-- Uso:
EventBus:on("PlayerKilled", function(killer, victim)
    print(killer.Name .. " killed " .. victim.Name)
end)

EventBus:emit("PlayerKilled", player1, player2)
```

### B. Singleton Pattern

```lua
-- CombatManager.lua
local CombatManager = {}
local instance = nil

function CombatManager:GetInstance()
    if not instance then
        instance = {
            enabled = false,
            currentTarget = nil,
            -- ... otros campos
        }
    end
    return instance
end

-- Uso (siempre la misma instancia):
local manager = CombatManager:GetInstance()
```

---

## 🔬 TÉCNICA 6: Modular Architecture

### Estructura de Carpetas Profesional

```
MyScript/
├── Core/
│   ├── EntityManager.lua
│   ├── UpdateLoop.lua
│   └── Config.lua
├── Features/
│   ├── Combat/
│   │   ├── Aimbot.lua
│   │   ├── Reach.lua
│   │   └── Hitbox.lua
│   ├── Movement/
│   │   ├── Speed.lua
│   │   └── Flight.lua
│   └── Visual/
│       ├── ESP.lua
│       └── Tracers.lua
├── UI/
│   └── MainWindow.lua
└── Main.lua (Entry point)
```

### Module Pattern

```lua
-- Combat/Aimbot.lua
local Aimbot = {}

local enabled = false
local config = {
    fov = 90,
    smoothing = 0.3
}

function Aimbot:SetEnabled(value)
    enabled = value
end

function Aimbot:SetConfig(newConfig)
    for key, value in pairs(newConfig) do
        config[key] = value
    end
end

function Aimbot:Update(deltaTime)
    if not enabled then return end
    -- Lógica de aimbot...
end

return Aimbot

-- Main.lua
local Aimbot = require(script.Features.Combat.Aimbot)
Aimbot:SetEnabled(true)
```

---

## 💡 TÉCNICAS AVANZADAS DE PROS

### 1. Memory Management

```lua
-- Cleanup Pattern
local connections = {}
local instances = {}

function addConnection(conn)
    table.insert(connections, conn)
end

function cleanup()
    for _, conn in ipairs(connections) do
        conn:Disconnect()
    end
    for _, inst in ipairs(instances) do
        inst:Destroy()
    end
    connections = {}
    instances = {}
end

-- Auto-cleanup on script unload
game:GetService("Players").LocalPlayer.CharacterRemoving:Connect(cleanup)
```

### 2. Lazy Loading

```lua
-- No cargar todo al inicio (más rápido)
local modules = {
    Combat = nil,
    ESP = nil
}

function getModule(name)
    if not modules[name] then
        modules[name] = require(script.Features[name])
    end
    return modules[name]
end

-- Solo carga cuando se necesita
local Combat = getModule("Combat")
```

### 3. Caching Inteligente

```lua
local cache = {}
local CACHE_DURATION = 1 -- segundo

function getCachedPlayers()
    if cache.players and (tick() - cache.timestamp) < CACHE_DURATION then
        return cache.players -- Usar cache
    end
    
    -- Actualizar cache
    cache.players = game.Players:GetPlayers()
    cache.timestamp = tick()
    return cache.players
end
```

---

## 📊 MÉTRICAS DE CÓDIGO PROFESIONAL

### Checklist de Calidad:

- ✅ **Performance:** <16.67ms por frame (60 FPS)
- ✅ **Error Handling:** Todos los pcall importantes
- ✅ **Memory Leaks:** Cleanup de connections
- ✅ **Modularity:** Código dividido en módulos
- ✅ **Comments:** Funciones complejas documentadas
- ✅ **Naming:** Variables descriptivas (no `x`, `y`, `z`)
- ✅ **Testing:** Probado en múltiples escenarios

---

## 🎓 CONCLUSIÓN

**Lo que separa a un AMATEUR de un PRO:**

| Amateur | Profesional |
|---------|-------------|
| Todo en 1 archivo | Arquitectura modular |
| Variables `a`, `b`, `c` | Nombres descriptivos |
| Sin error handling | pcall en todo |
| Confía en el cliente | "Never trust client" |
| Código lineal | OOP + Patterns |
| No mide performance | Profiling constante |
| Reinventa la rueda | Reutiliza código |

---

**Siguiente Notebook:** Skywars Game Analysis
