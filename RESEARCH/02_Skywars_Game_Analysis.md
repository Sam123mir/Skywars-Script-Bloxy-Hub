# 📚 NOTEBOOK 2: Skywars Game Deep Analysis (CORRECTO)

## Creado por: Samir (16bitplayer)
**Fecha:** 2026-01-04  
**Juego:** ⚔️ SKYWARS 🏹 (ID: 855499080) by 16bitplay Games
**Objetivo:** Análisis profundo del juego CORRECTO para crear el mejor script

---

## 🎮 OVERVIEW DEL JUEGO REAL

**Skywars (16bitplay)** características:
- ✅ Creado por: **16bitplay Games** (¡El mismo grupo!)
- ✅ Modo: Battle Royale en islas
- ✅ Objetivo: Construir base, destruir enemigos, conquistar el cielo
- ✅ Actualizado constantemente (última: Tema Navidad)
- ✅ VIP servers con acceso a actualizaciones tempranas
- ✅ CLÁSICOS SKYWARS HAN VUELTO

---

## ⚔️ SISTEMA DE COMBATE REAL

### A. Armas del Juego

#### **Espadas (Melee):**

| Tier | Material | Daño Estimado | Notas |
|------|----------|---------------|-------|
| 1 | Stone | Bajo | Starter |
| 2 | Iron | Medio | Common |
| 3 | Gold | Medio+ | Uncommon |
| 4 | Diamond | Alto | Raro |
| 5 | **Obsidian** | **MUY ALTO** | TOP tier |

**Código para detectar:**
```lua
local SWORD_PRIORITIES = {
    ["Obsidian Sword"] = 5,
    ["Diamond Sword"] = 4,
    ["Gold Sword"] = 3,
    ["Iron Sword"] = 2,
    ["Stone Sword"] = 1
}
```

#### **Armas Ranged:**

**Bows:**
- Diamond arrows = Daño alto
- Usan raycast (NO proyectiles físicos)
- Critical: **Apuntar al torso** (helmets deflectan flechas)

**Slingshots:**
- Única arma ranged especial
- Muy efectiva en mapas low-gravity
- Diferentes tiers

**Código predicción:**
```lua
function predictBowShot(target)
    -- En este Skywars, los bows usan RAYCAST
    -- NO necesitas predicción, es instantáneo
    local aimPosition = target.Head.Position
    return aimPosition
end
```

---

### B. Sistema de ARMOR (Crucial)

| Material | Protección | Notas |
|----------|-----------|-------|
| Bronze | ~20% | Starter |
| Iron | ~30% | Common |
| Copper | ~35% | Menos común |
| Mithril | ~50% | Raro |
| Diamond | ~60% | Muy raro |
| **Emerald** | **~70%** | TOP tier |

**IMPORTANTE:** 
- **Helmets deflectan arrows** (headshots no funcionan)
- Siempre apuntar al **TORSO**

```lua
function calculateDamageReduction(armorType)
    local protection = {
        ["Emerald"] = 0.7,
        ["Diamond"] = 0.6,
        ["Mithril"] = 0.5,
        ["Copper"] = 0.35,
        ["Iron"] = 0.3,
        ["Bronze"] = 0.2
    }
    return protection[armorType] or 0
end
```

---

### C. Sistema de PICKAXES (Mining)

| Tier | Material | Mining Speed | HP Damage to Blocks |
|------|----------|--------------|---------------------|
| 1 | Stone | Lento | 1 HP/hit |
| 2 | Iron | Medio | 2 HP/hit |
| 3 | Gold | Rápido | 3 HP/hit |
| 4 | Diamond | Muy Rápido | 4 HP/hit (one-shot common blocks) |
| 5 | Ruby | Ultra Rápido | 5+ HP/hit |

**Blocks HP System:**
- Wood blocks: 2 HP
- Copper blocks: 3-5 HP
- Gold blocks: 6-8 HP
- Diamond blocks: 10+ HP
- Obsidian blocks: 15+ HP

---

## 🧪 SISTEMA DE POCIONES (MUY IMPORTANTE)

### Pociones Disponibles:

**1. Speed Potion 🏃**
```lua
-- Aumenta velocidad de movimiento
-- Útil para: Rush mid, escapar, perseguir
Effects = {
    WalkSpeed = +50%, -- aproximadamente
    Duration = 30 segundos
}
```

**2. Healing Potion 💚**
```lua
-- Restaura salud completa
Effects = {
    Health = 100% (instantáneo),
    Cooldown = 5 segundos
}
-- CRÍTICO: Auto-usar en combate
```

**3. Shield Potion 🛡️**
```lua
-- Invincibilidad temporal
Effects = {
    Invincible = true,
    Duration = 5 segundos,
    Restrictions = "No puedes usar items mientras activo"
}
-- Usar para: Escapar, tanquear daño
```

**4. Jump Potion 🦘**
```lua
-- Super salto
Effects = {
    JumpPower = +200%,
    Duration = 30 segundos
}
-- Útil para: High ground rápido, sorprender enemigos
```

**5. Invisible Potion 👻**
```lua
-- Invisibilidad
Effects = {
    Transparency = 0 (invisible),
    Duration = 15 segundos
}
-- CRÍTICO: Stealth attacks, escapar
```

**Código Auto-Potion:**
```lua
function autoUsePotion()
    local player = game.Players.LocalPlayer
    local char = player.Character
    local humanoid = char.Humanoid
    
    -- Auto Healing si HP < 40%
    if humanoid.Health / humanoid.MaxHealth < 0.4 then
        local healingPotion = findPotion("Healing")
        if healingPotion then
            usePotionItem(healingPotion)
        end
    end
    
    -- Auto Shield si en combate y HP < 60%
    if isInCombat() and humanoid.Health / humanoid.MaxHealth < 0.6 then
        local shieldPotion = findPotion("Shield")
        if shieldPotion then
            usePotionItem(shieldPotion)
        end
    end
end
```

---

## 🎯 ESTRATEGIAS PRO

### 1. Early Rush (META Strategy)

```lua
function earlyRush()
    --PRE-GAME TRICK: Tomar poción antes de countdown = 0
    -- Esto te permite moverte ANTES que otros
    
    task.spawn(function()
        -- Esperar countdown: 3, 2, 1...
        repeat task.wait() until isGameStarting()
        
        -- En los últimos 2 segundos, tomar Speed Potion
        if getCountdown() <= 2 then
            local speedPot = findPotion("Speed")
            if speedPot then
                usePotionItem(speedPot)
            end
        end
    end)
    
    -- Cuando empiece, rush directo a mid
    autoRushMid()
end
```

### 2. High Ground Dominance

```lua
function maintainHighGround(enemy)
    local myY = player.Character.HumanoidRootPart.Position.Y
    local enemyY = enemy.HumanoidRootPart.Position.Y
    
    if enemyY > myY then
        -- Enemigo tiene high ground
        -- Opción 1: Jump Potion
        local jumpPot = findPotion("Jump")
        if jumpPot then
            usePotionItem(jumpPot)
            task.wait(0.5)
            -- Saltar encima del enemigo
        end
        
        -- Opción 2: Minar debajo de él
        mineUnderEnemy(enemy)
    end
end
```

### 3. Combat Tactics

**Sword Combat:**
```lua
function swordCombat(enemy)
    -- 1. Shift-lock para mantener cámara en enemigo
    enableShiftLock()
    
    -- 2. Strafe (W+D movement para esquivar)
    strafeMovement()
    
    -- 3. Jump mientras atacas (reduce knockback recibido)
    if shouldAttack() then
        player.Character.Humanoid.Jump = true
        task.wait(0.1)
        attackEnemy(enemy)
    end
end
```

**Bow Combat:**
```lua
function bowCombat(enemy)
    local bow = getBow()
    if not bow then return end
    
    equipTool(bow)
    
    -- Apuntar al TORSO (no head, helmets deflectan)
    local aimPos = enemy.HumanoidRootPart.Position
    
    -- Movimiento: Jumping + shooting = más difícil de hitear
    player.Character.Humanoid.Jump = true
    
    -- Disparar (es raycast, instantáneo)
    aimAt(aimPos)
    shootBow()
end
```

---

## 🏗️ SISTEMA DE BUILDING

### Block System

```lua
-- Diferentes bloques tienen diferente HP
local BLOCK_HP = {
    ["Wood"] = 2,
    ["Copper"] = 4,
    ["Gold"] = 7,
    ["Diamond"] = 10,
    ["Obsidian"] = 15
}

-- Auto-select mejores bloques para construir
function getBestBlocks()
    local inventory = player.Backpack:GetChildren()
    local bestBlocks = nil
    local highestHP = 0
    
    for _, item in ipairs(inventory) do
        if item:IsA("Tool") and BLOCK_HP[item.Name] then
            if BLOCK_HP[item.Name] > highestHP then
                bestBlocks = item
                highestHP = BLOCK_HP[item.Name]
            end
        end
    end
    
    return bestBlocks
end
```

### Mining Enemy Bridges (Tactic PRO)

```lua
function mineEnemyBridge(enemy)
    -- Detectar si enemigo está en un bridge
    local ray = workspace:Raycast(
        enemy.HumanoidRootPart.Position,
        Vector3.new(0, -10, 0)
    )
    
    if ray and ray.Instance.Name:find("Block") then
        -- Hay un bloque debajo, minarlo
        local pickaxe = getBestPickaxe()
        if pickaxe then
            equipTool(pickaxe)
            
            -- Minar bloque
            mineBlock(ray.Instance)
            
            -- Enemigo cae = easy kill
        end
    end
end
```

---

## 📦 LOOT PRIORITY (ACTUALIZADO)

### Priority List para Auto-Farm:

```lua
local LOOT_PRIORITIES = {
    -- Pociones (MUY IMPORTANTE en este juego)
    ["Invisible Potion"] = 100,
    ["Shield Potion"] = 95,
    ["Healing Potion"] = 90,
    ["Speed Potion"] = 85,
    ["Jump Potion"] = 80,
    
    -- Armas
    ["Obsidian Sword"] = 95,
    ["Diamond Sword"] = 85,
    ["Gold Sword"] = 70,
    ["Diamond Bow"] = 75,
    
    -- Armor
    ["Emerald Chestplate"] = 90,
    ["Diamond Chestplate"] = 80,
    ["Emerald Helmet"] = 90,
    ["Diamond Helmet"] = 80,
    
    -- Tools
    ["Ruby Pickaxe"] = 85,
    ["Diamond Pickaxe"] = 75,
    
    -- Blocks
    ["Obsidian Blocks"] = 70,
    ["Diamond Blocks"] = 65
}
```

---

## 🎮 MODOS ESPECIALES

### Low-Gravity Maps

```lua
function detectLowGravity()
    local gravity = workspace.Gravity
    
    if gravity < 196.2 then -- Gravity normal es 196.2
        -- Estamos en low-gravity mode
        return true
    end
    return false
end

function adaptToLowGravity()
    if detectLowGravity() then
        -- Usar slingshots (muy efectivos aquí)
        preferRangedWeapons()
        
        -- Saltos más altos = más aggressive gameplay
        setPlaystyle("aggressive")
    end
end
```

---

## 💎 SISTEMA DE GEMS (Skywars 2)

```lua
-- Gems spawn en el mapa
-- Necesitas 25 wins para acceder a Gem Shop

function autoCollectGems()
    for _, gem in ipairs(workspace:GetDescendants()) do
        if gem.Name == "Gem" and gem:IsA("Part") then
            -- Ir a recoger gem
            walkTo(gem.Position)
        end
    end
end
```

---

## 🛡️ PACKS/VIP FEATURES

### Obsidian Pack (BEST VALUE)
- Obsidian Sword (top tier weapon)
- Obsidian Armor (top tier protection)
- Obsidian Pickaxe (super fast mining)

### Group Benefits
- Group Helmet (deflecta arrows)
- Sala de grupo VIP

---

## 🔍 GAME STRUCTURE (Para el Script)

### Workspace Detection

```lua
workspace/
├── Map/
│   ├── Islands/ (múltiples islas)
│   │   ├── Island_1/
│   │   ├── Island_2/
│   │   └── Middle/ (centro con mejor loot)
│   └── Blocks/ (bloques colocados por jugadores)
├── Players/ (Characters)
└── Items/ (pociones, armas spawneadas)

-- Detectar chests/loot
function findLootChests()
    local chests = {}
    for _, obj in ipairs(workspace.Map:GetDescendants()) do
        if obj.Name:lower():find("chest") or obj.Name:lower():find("loot") then
            table.insert(chests, obj)
        end
    end
    return chests
end
```

---

## 💡 FEATURES PARA NUESTRO SCRIPT

### MUST-HAVE Features:

**Combat:**
- ✅ Auto Aim (torso, NO head)
- ✅ Auto Attack con reach
- ✅ Auto Switch mejor weapon
- ✅ Bow aimbot (raycast detection)
- ✅ Shift-lock auto

**Potions (CRÍTICO):**
- ✅ Auto Healing (HP < 40%)
- ✅ Auto Shield (combate)
- ✅ Speed Potion pre-rush
- ✅ Smart Invisible use

**Movement:**
- ✅ Auto Bridge (minar + colocar)
- ✅ Fly mode
- ✅ Speed boost
- ✅ Auto high ground

**Mining:**
- ✅ Auto equip best pickaxe
- ✅ Fast mine (instant break)
- ✅ Mine enemy bridges
- ✅ Auto-collect blocks

**Visual:**
- ✅ Player ESP (con armor/weapon info)
- ✅ Potion ESP (IMPORTANTE)
- ✅ Chest/Loot ESP
- ✅ Block ESP (diamante, oro, etc)

**Utility:**
- ✅ Auto Rush Mid (con speed potion)
- ✅ Smart Loot (priority list)
- ✅ Auto Gem Collector
- ✅ Kill Aura

---

## 🎓 CONCLUSIÓN

**Meta Game de ESTE Skywars:**
1. **Pociones > Todo** (Shield, Invisibility son game-changers)
2. **Pre-game potion trick** = Primera ventaja
3. **Apuntar TORSO, no head** (helmets deflectan)
4. **Mining enemy bridges** = Táctica PRO
5. **Rush mid con Speed Potion** = Best start

**Script Dominance Strategy:**
- Speed Potion pre-game → Rush mid primero
- Smart auto-potion usage → Nunca morir
- Auto torso aim → Siempre hitear
- Mine bridges → Enemigos caen
- ESP completo → Awareness total

---

**ESTE ES EL ANÁLISIS CORRECTO PARA EL SCRIPT** ✅
