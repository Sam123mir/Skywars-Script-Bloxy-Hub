# 📝 SKYWARS PRECISE DATA (From Wiki & Community)

## ⚔️ **WEAPONS - EXACT DAMAGE**

### Swords
| Weapon | Damage | Cost/Unlock | Notes |
|--------|--------|-------------|-------|
| **Obsidian Sword** | 24 HP | 400 Robux (Pack) | STRONGEST non-exclusive |
| Diamond Sword | ~15-18 HP | 4,000 coins | Best F2P option |
| Stone Sword | ~12-14 HP | 1,600 coins | Early game |
| Wood/Group Sword | ~10 HP | Free/Group | 10 hits to kill (100HP) |

### Pickaxes
| Pickaxe | Mining Speed | Special |
|---------|--------------|---------|
| Diamond Pickaxe | Ultra Fast | One-shots regular blocks |
| Iron Pickaxe | Fast | Good balance |
| Stone Pickaxe | Medium | F2P starter |

---

## 🛡️ **ARMOR - HEALTH BONUS SYSTEM**

**IMPORTANT:** Armor doesn't reduce damage, it **ADDS MAX HEALTH**

| Armor | Health Bonus | Unlock | Total HP |
|-------|--------------|--------|----------|
| **Emerald Armor** | ~+60-70 HP | 240 Robux / High wins | **~160-170 HP** |
| **Diamond Armor** | ~+40-50 HP | 120 wins / Robux | **~140-150 HP** |
| **Iron Armor** | +30 HP | 80 wins | **130 HP** |
| No Armor | 0 | - | **100 HP** |

**Formula para script:**
```lua
function getEffectiveHP(player)
    local baseHP = 100
    local armorBonus = 0
    
    -- Detectar armor
    if hasEmeraldArmor(player) then
        armorBonus = 65
    elseif hasDiamondArmor(player) then
        armorBonus = 45
    elseif hasIronArmor(player) then
        armorBonus = 30
    end
    
    return baseHP + armorBonus
end
```

---

## 🧪 **POTIONS - EXACT EFFECTS**

### Healing Potion
- **Effect:** Restores 100% Health (FULL HP)
- **Cost:** 800 coins (620 in group area)
- **Duration:** Instant
- **Cooldown:** ~5 seconds
- **Use:** Emergency heal in combat

### Speed Potion
- **Effect:** +10% Speed
- **Duration:** **ENTIRE ROUND** (hasta que mueras)
- **Use:** Rush mid, escape, chase

### Jump Potion (High Jump)
- **Effect:** Much higher jumps
- **Duration:** **ENTIRE ROUND**
- **Use:** High ground, surprise attacks

### Invisibility Potion
- **Effect:** Complete invisibility
- **Duration:** "few seconds" (~10-15s estimated)
- **Use:** Stealth kills, escape

### Shield
- **Effect:** Total invincibility
- **Duration:** 5 seconds
- **Restrictions:** Cannot use other items while active
- **Recharge:** Required after use
- **Use:** Tank damage, escape guaranteed

**Codigo actualizado:**
```lua
-- Potions duran TODO EL ROUND (no 30s como pensé)
local POTION_DURATIONS = {
    Healing = 0, -- Instant
    Speed = math.huge, -- Whole round
    Jump = math.huge, -- Whole round
    Invisible = 12, -- ~12 seconds estimated
    Shield = 5 -- Exact: 5 seconds
}
```

---

## 💎 **PAY-TO-WIN MECHANICS**

**CRUCIAL INFO:** Game has significant P2W

### VIP Tiers
1. **Regular VIP** - Stronger items than F2P
2. **Mega VIP** - Even stronger than VIP
3. **Obsidian Pack** - 400 Robux (Top tier weapon)

**Obsidian Pack includes:**
- Obsidian Sword (24 dmg)
- Obsidian Armor (best protection)
- Obsidian Pickaxe (fastest mining)

**For script:**
- Prioritize targeting F2P players (easier kills)
- Avoid Obsidian Pack users if low HP
- Use ESP to show player's gear tier

---

## 🎯 **META STRATEGIES (Updated)**

### Early Game Rush (CONFIRMED)
```lua
1. Speed Potion ASAP (lasts whole round!)
2. Rush to mid immediately
3. Target: Diamond Sword + Diamond Armor
4. Dominate with gear advantage
```

### F2P Max Loadout
- Diamond Sword (4,000 coins)
- Diamond Armor (120 wins)
- Diamond Pickaxe (800 coins)
- Healing Potions (multiple)

### Combat Math
```lua
-- Obsidian Sword vs Iron Armor:
-- Damage: 24 HP/hit
-- Enemy HP: 130 HP (100 + 30)
-- Hits to kill: 130 / 24 = 5.4 hits → 6 hits

-- Diamond Sword vs No Armor:
-- Damage: ~18 HP/hit  
-- Enemy HP: 100 HP
-- Hits to kill: 100 / 18 = 5.5 hits → 6 hits

-- Wood Sword vs Emerald Armor:
-- Damage: 10 HP/hit
-- Enemy HP: ~165 HP (100 + 65)
-- Hits to kill: 165 / 10 = 16.5 hits → 17 hits
```

---

## 🔧 **SCRIPT OPTIMIZATION IDEAS**

### Auto-Potion Priority
```lua
-- CRITICAL: Potions last WHOLE ROUND
-- Take Speed + Jump at START, not during combat

function autoOptimalPotions()
    if isRoundStart() then
        -- Pre-game phase
        local speedPot = findPotion("Speed")
        if speedPot then usePotionItem(speedPot) end
        
        local jumpPot = findPotion("Jump")
        if jumpPot then usePotionItem(jumpPot) end
    end
    
    if inCombat() then
        if getHP() < 50 then
            usePotion("Healing") -- Instant full HP
        end
        
        if getHP() < 30 and canUseShield() then
            usePotion("Shield") -- 5s invincibility
        end
    end
end
```

### Smart Target Selection
```lua
function getTargetPriority(entity)
    local priority = 100
    
    -- Detect their gear
    if hasObsidianPack(entity) then
        priority -= 50 -- Avoid P2W players
    end
    
    if hasEmeraldArmor(entity) then
        priority -= 30 -- High HP
    elseif hasNoArmor(entity) then
        priority += 40 -- Easy kill
    end
    
    -- Factor distance
    priority -= entity.Distance / 10
    
    return priority
end
```

---

## ✅ **CONFIRMED FACTS**

1. ✅ Obsidian Sword = 24 damage (confirmed)
2. ✅ Armor adds HP, doesn't reduce damage
3. ✅ Iron Armor = +30 HP
4. ✅ Healing Potion = 100% HP restore
5. ✅ Shield = Exactly 5 seconds invincibility
6. ✅ Speed/Jump potions = WHOLE ROUND duration
7. ✅ Diamond Pickaxe = One-shot regular blocks
8. ✅ Pay-to-win mechanics are significant

---

**ESTE ES EL ANÁLISIS MÁS PRECISO POSIBLE** 🎯
