# Weapon System with Class Bonuses and Tag-Based Synergies

**Date:** 2026-03-21
**Game:** MiniGame (Godot 4.5)
**Design Goal:** Create a deep weapon system with 8 modern firearms, tag-based synergies, and class-specific bonuses

---

## Problem Statement

The game currently has three distinct character classes (Potato, Speedy, Tank) but only one default weapon. This severely limits:
- Build diversity and strategic depth
- Replay value and player experimentation
- Class identity and meaningful choice between characters

Players need a rich weapon system that encourages strategic composition while maintaining accessibility and fun.

---

## Design Goals

1. **Build Diversity**: Enable distinct playstyles through weapon combination
2. **Strategic Depth**: Reward thoughtful weapon selection via tag synergies
3. **Class Identity**: Reinforce character archetypes through meaningful bonuses
4. **Accessibility**: Keep core mechanics simple and intuitive
5. **Scalability**: Support future weapon additions with minimal code changes

---

## Core Design Principles

### Principle 1: Shared Weapon Pool with Class Flavor

All classes access the same weapon pool, but class-specific bonuses guide optimal builds:
- **Maintains freedom**: Players can experiment with any combination
- **Creates identity**: Each class has "best-in-slot" weapon types
- **Enables variety**: Same weapon feels different on different classes

**Example:** SMG is usable by all classes, but Speedy's +20% fire rate bonus makes it exceptional for that character.

### Principle 2: Tag-Based Synergy Accumulation

Inspired by Brotato's elegant design:
- Each weapon has 1-3 tags (e.g., RAPID_FIRE, PRECISION, AREA)
- Equipping multiple weapons with the same tag = cumulative bonus
- Simple to understand, deep to optimize

**Example:**
- 1 RAPID_FIRE weapon = +8% attack speed
- 3 RAPID_FIRE weapons = +24% attack speed

### Principle 3: Multiplicative Scaling

Tag synergies and class bonuses multiply together, creating powerful endgame builds without being overwhelming early:

```
Final Stat = Base × (1 + Tag Synergy) × (1 + Class Bonus)
```

**Example:** Speedy with 3 RAPID_FIRE weapons:
- Base fire rate: 5.0
- Tag synergy: +24% (3 × 8%)
- Class bonus: +20%
- Final: 5.0 × 1.24 × 1.20 = 7.44 shots/sec (+49% total)

---

## Weapon Catalog

### Modern Firearms Theme

We chose modern firearms for:
- **Universal familiarity**: Players understand pistols, shotguns, etc.
- **Clear archetypes**: Each weapon type has expected behavior
- **Visual clarity**: Distinct silhouettes and firing patterns

### The 8 Weapons

#### 1. Pistol - "9mm Handgun"
**Role:** Reliable starter, precision weapon
**Tags:** PRECISION, BURST
**Stats:**
- Damage: 12
- Fire Rate: 3.0/sec
- Magazine: 12 rounds
- Reload: 2.0s
- Price: 150 gold

**Design Rationale:** Affordable entry point. Fast reload encourages BURST tag synergies. Accurate for PRECISION builds.

---

#### 2. SMG - "Vector SMG"
**Role:** High fire rate spray weapon
**Tags:** RAPID_FIRE, BURST
**Stats:**
- Damage: 7 (lower per-shot, high DPS)
- Fire Rate: 8.0/sec
- Magazine: 30 rounds
- Reload: 2.5s
- Spread: 5° (slight inaccuracy)
- Price: 200 gold

**Design Rationale:** Core RAPID_FIRE weapon. Lower damage balanced by volume of fire. Speedy's best friend.

---

#### 3. Shotgun - "Pump Shotgun"
**Role:** Close-range crowd control
**Tags:** AREA, HEAVY, BURST
**Stats:**
- Damage: 10 per pellet
- Fire Rate: 1.2/sec
- Projectiles: 6 pellets per shot
- Spread: 30°
- Magazine: 6 rounds
- Reload: 3.0s
- Knockback: 300
- Price: 250 gold

**Design Rationale:** Multi-projectile creates AREA synergy value. High knockback reinforces HEAVY identity. Devastating for Tank.

---

#### 4. Assault Rifle - "M4 Carbine"
**Role:** Versatile all-rounder
**Tags:** RAPID_FIRE, PRECISION, BURST
**Stats:**
- Damage: 15
- Fire Rate: 5.0/sec
- Magazine: 20 rounds
- Reload: 2.2s
- Price: 300 gold

**Design Rationale:** Three tags make it flexible. Fits into multiple builds. Good mid-game purchase.

---

#### 5. Sniper Rifle - "Bolt-Action Rifle"
**Role:** High damage elimination
**Tags:** PRECISION, HEAVY, PIERCING
**Stats:**
- Damage: 50 (highest single-shot)
- Fire Rate: 0.8/sec (slow)
- Magazine: 5 rounds
- Reload: 3.5s
- Pierce: 3 enemies
- Projectile Speed: 1000 (fastest)
- Knockback: 400
- Price: 400 gold

**Design Rationale:** Extreme damage-per-shot. Natural pierce rewards positioning. Cornerstone of PRECISION builds.

---

#### 6. Flamethrower - "Inferno Projector"
**Role:** Continuous close-range area damage
**Tags:** AREA, SUSTAINED
**Stats:**
- Damage: 5 (but 10 ticks/sec = 50 DPS)
- Fire Rate: 10.0 ticks/sec
- Projectiles: 3 streams
- Spread: 20°
- Range: Short (speed 300)
- No magazine/reload (infinite ammo)
- Price: 350 gold

**Design Rationale:** Introduces SUSTAINED tag. No reload creates distinct rhythm. AREA tag scales with Tank bonus.

---

#### 7. Grenade Launcher - "40mm Launcher"
**Role:** Explosive AoE control
**Tags:** AREA, HEAVY, BURST
**Stats:**
- Damage: 35 (splash damage)
- Fire Rate: 1.0/sec
- Magazine: 4 rounds
- Reload: 4.0s (longest)
- Explosion Radius: 80 units
- Pierce: 999 (hits all in radius)
- Knockback: 500 (massive)
- Price: 450 gold

**Design Rationale:** Ultimate AREA weapon. Explosion mechanic is satisfying and visually clear. High price reflects power.

---

#### 8. Minigun - "Rotary Cannon"
**Role:** Sustained high fire rate
**Tags:** RAPID_FIRE, SUSTAINED, PIERCING
**Stats:**
- Damage: 8
- Fire Rate: 12.0/sec (highest)
- No magazine/reload (infinite)
- Pierce: 2 enemies
- Spread: 3°
- Price: 500 gold

**Design Rationale:** Most expensive weapon. Three tags create synergy flexibility. Never stopping creates unique gameplay feel.

---

## Tag System

### The 7 Tags

| Tag | Effect | Bonus per Weapon | Best For |
|-----|--------|------------------|----------|
| RAPID_FIRE | Attack speed | +8% fire rate | Speedy builds, spray weapons |
| PRECISION | Single-target damage | +12% damage | Potato builds, accuracy |
| AREA | Multi-target damage | +10% projectile count | Tank builds, crowd control |
| HEAVY | High impact | +15% damage, +20% knockback | Tank builds, control |
| BURST | Magazine efficiency | -10% reload time | All builds with magazines |
| SUSTAINED | Continuous fire | +5% fire rate | Flamethrower, Minigun |
| PIERCING | Penetration | +0.5 pierce per 2 weapons | Positioning-focused builds |

### Tag Distribution

Tags are distributed to create distinct weapon identities while enabling synergies:

- **1 Tag:** None (too weak)
- **2 Tags:** Pistol, SMG, Flamethrower, Minigun
- **3 Tags:** Shotgun, Assault Rifle, Sniper, Grenade Launcher

Weapons with 3 tags are more flexible but may not specialize as hard.

### Synergy Scaling

Synergies scale linearly to keep math simple:

**RAPID_FIRE Example:**
- 1 weapon: +8%
- 2 weapons: +16%
- 3 weapons: +24%
- 6 weapons (max): +48%

**Balance Consideration:** Even 6 identical weapons = ~50% bonus (not exponential). Keeps power level reasonable.

---

## Class Bonus System

### Design Philosophy

Class bonuses reinforce existing stat profiles:
- **Speedy** is already fast → bonus to fast weapons
- **Tank** has high HP → bonus to defensive/AoE weapons
- **Potato** is balanced → small bonuses to balanced weapons

Penalties discourage anti-synergistic builds (e.g., Tank with spray weapons).

### Potato (Balanced Fighter)

**Base Stats:**
- HP: 100
- Speed: 200
- Attack Speed: 1.0

**Bonuses:**
- PRECISION: +10% damage
- BURST: +10% reload speed

**Philosophy:** Small bonuses to reliable, consistent weapons. No penalties. Jack-of-all-trades.

**Best Weapons:** Pistol, Assault Rifle, Sniper

---

### Speedy (Glass Cannon)

**Base Stats:**
- HP: 70 (lowest)
- Speed: 280 (fastest)
- Attack Speed: 1.3 (fastest)

**Bonuses:**
- RAPID_FIRE: +20% fire rate
- SUSTAINED: +15% fire rate

**Penalties:**
- HEAVY: -15% damage

**Philosophy:** Kiting playstyle. High mobility + high fire rate. Penalized for slow, heavy weapons that don't match mobility.

**Best Weapons:** SMG, Minigun, Flamethrower

---

### Tank (Survivability)

**Base Stats:**
- HP: 150 (highest)
- Speed: 150 (slowest)
- Attack Speed: 0.8 (slowest)

**Bonuses:**
- AREA: +25% projectile count
- HEAVY: +20% damage, +30% knockback

**Penalties:**
- RAPID_FIRE: -10% fire rate

**Philosophy:** Stand-and-deliver. High HP enables close-range fighting. AoE clears crowds. Knockback creates space. Penalized for spray weapons that don't match tanky playstyle.

**Best Weapons:** Shotgun, Grenade Launcher, Flamethrower, Sniper

---

## Example Builds

### Build 1: Speedy RAPID_FIRE Build

**Weapons:** SMG, Assault Rifle, Minigun
**Tags:** RAPID_FIRE x3, SUSTAINED x1, BURST x2, PRECISION x1, PIERCING x1

**Synergies:**
- RAPID_FIRE: +24% fire rate (all weapons)
- SUSTAINED: +5% fire rate (Minigun)
- BURST: -20% reload time (SMG, Assault Rifle)

**Class Bonuses:**
- RAPID_FIRE: +20% fire rate (all 3 weapons)
- SUSTAINED: +15% fire rate (Minigun)

**Final SMG Fire Rate:**
- Base: 8.0/sec
- RAPID_FIRE synergy: 8.0 × 1.24 = 9.92
- Speedy class bonus: 9.92 × 1.20 = 11.9/sec
- **+49% faster!**

**Gameplay:** Constant bullet stream. Kite around enemies. Never stop shooting.

---

### Build 2: Tank AREA Build

**Weapons:** Shotgun, Grenade Launcher, Flamethrower
**Tags:** AREA x3, HEAVY x2, BURST x2, SUSTAINED x1

**Synergies:**
- AREA: +30% projectile count
- HEAVY: +30% damage, +40% knockback
- BURST: -20% reload time

**Class Bonuses:**
- AREA: +25% projectile count (all 3 weapons)
- HEAVY: +20% damage, +30% knockback (Shotgun, Grenade Launcher)

**Final Shotgun Stats:**
- Base pellets: 6
- AREA synergy: 6 × 1.30 = 7.8 → 8 pellets
- Tank class bonus: 8 × 1.25 = 10 pellets
- Base damage: 10 per pellet
- HEAVY synergy: 10 × 1.30 = 13
- Tank class bonus: 13 × 1.20 = 15.6 → 16/pellet
- **Total: 160 damage per shot (vs 60 base)**

**Gameplay:** Facetank enemies. Massive damage and knockback. Control space.

---

### Build 3: Potato PRECISION Build

**Weapons:** Pistol, Sniper, Assault Rifle
**Tags:** PRECISION x3, BURST x3, HEAVY x1, RAPID_FIRE x1, PIERCING x1

**Synergies:**
- PRECISION: +36% damage (all weapons)
- BURST: -30% reload time (all weapons)
- HEAVY: +15% damage (Sniper)

**Class Bonuses:**
- PRECISION: +10% damage (all 3 weapons)
- BURST: +10% reload speed (all 3 weapons)

**Final Sniper Damage:**
- Base: 50
- PRECISION synergy: 50 × 1.36 = 68
- Potato class bonus: 68 × 1.10 = 74.8 → 75
- HEAVY synergy: 75 × 1.15 = 86.25 → 86
- **+72% damage!**

**Final Sniper Reload:**
- Base: 3.5s
- BURST synergy: 3.5 × 0.70 = 2.45s
- Potato class bonus: 2.45 × 0.90 = 2.2s
- **37% faster reload**

**Gameplay:** Precise shots eliminate targets. Fast reloads maintain pressure. Balanced and effective.

---

## Technical Architecture

### Data Flow

```
Player equips weapons
      ↓
PlayerInventory.add_weapon_from_data(WeaponData)
      ↓
weapon_data_list updated
      ↓
recalculate_synergies() called
      ↓
SynergyCalculator.count_tags(weapon_data_list)
      ↓
SynergyCalculator.calculate_synergies(tag_counts)
      ↓
For each weapon:
  SynergyCalculator.apply_class_bonuses(synergies, character_data, weapon.tags)
      ↓
weapon_base.apply_synergies(calculated_synergies)
      ↓
Weapon stats updated
      ↓
EventBus.synergy_updated emitted
      ↓
UI updates to show new bonuses
```

### Key Systems

**1. SynergyCalculator (Autoload)**
- **Purpose:** Centralized synergy math
- **Responsibility:** Count tags, calculate bonuses, apply class multipliers
- **Why singleton:** Needs to be accessed from multiple places (inventory, UI, weapons)

**2. WeaponData (Resource)**
- **Purpose:** Declarative weapon definition
- **Responsibility:** Store all weapon properties (stats, tags, price)
- **Why resource:** Easy to create new weapons in editor, reusable, serializable

**3. PlayerInventory (Node)**
- **Purpose:** Weapon collection management
- **Responsibility:** Track equipped weapons, trigger synergy recalculation
- **Why on player:** Needs access to character_data, manages weapon nodes

**4. WeaponBase (Node)**
- **Purpose:** Weapon behavior and firing
- **Responsibility:** Fire projectiles, apply synergy-modified stats
- **Why scene:** Needs _process() for cooldowns, instantiates projectiles

### Special Mechanics

**Grenade Launcher Explosions:**
```
Projectile hits enemy
      ↓
Check explosion_radius > 0
      ↓
Create temporary Area2D at impact point
      ↓
Add CircleShape2D with explosion_radius
      ↓
await get_tree().process_frame
      ↓
Query overlapping_areas()
      ↓
Filter for HurtboxComponents
      ↓
Deal damage to all
      ↓
Free explosion and projectile
```

**Sustained Fire (Flamethrower, Minigun):**
```
weapon_data.is_sustained == true
      ↓
Skip magazine tracking
      ↓
Skip reload logic
      ↓
Fire every frame if cooldown passed
```

---

## Shop Integration

### Flow

```
Wave ends (all enemies killed or timer expires)
      ↓
WaveManager._end_wave() called
      ↓
Set GameManager.state = SHOP
      ↓
Get player's weapon_data_list
      ↓
ShopSystem.refresh_shop(owned_weapons)
      ↓
Filter weapon_pool (exclude owned)
      ↓
Shuffle and pick 4 random weapons
      ↓
Display in ShopPanel UI
      ↓
Player clicks weapon
      ↓
Check gold >= price
      ↓
Check inventory < 6 weapons
      ↓
Deduct gold
      ↓
ShopSystem.purchase_weapon() returns WeaponData
      ↓
PlayerInventory.add_weapon_from_data()
      ↓
Synergies recalculate automatically
      ↓
UI updates
```

### UI Design

**Weapon Card:**
```
┌─────────────────────────┐
│ [Icon]  9mm Handgun     │
│                         │
│ ◇ PRECISION  ◇ BURST   │
│                         │
│ ⚔ 12   ⚡ 3.0/s        │
│                         │
│          [150 🪙]       │
└─────────────────────────┘
```

**Synergy Preview (on hover):**
```
Equipping this weapon will add:
  +1 PRECISION (total: 2 → +24% damage)
  +1 BURST (total: 1 → -10% reload)
```

---

## Balance Considerations

### Weapon Pricing

Prices reflect power and flexibility:
- **150-200:** Early game weapons (Pistol, SMG)
- **250-350:** Mid-game weapons (Shotgun, Assault Rifle, Flamethrower)
- **400-500:** Late game weapons (Sniper, Grenade Launcher, Minigun)

**Gold income:** Enemies drop ~10-20 gold. Wave 1 = ~100 gold total. This allows 1-2 weapon purchases per wave.

### Synergy Scaling

**Why linear?**
- Easy to calculate mentally
- No exponential power spikes
- Still feels impactful (+48% at 6 weapons is strong)

**Alternative considered:** Exponential (1.08^n)
- Rejected: Too punishing for mixed builds, too rewarding for stacking

### Class Penalties

**Why include penalties?**
- Discourage anti-synergy picks (Tank with SMG is suboptimal)
- Reinforce class identity
- Create meaningful tradeoffs

**Penalty magnitude:** -10% to -15% (not harsh, but noticeable)

---

## Future Expansion

### Easy Additions

**New Weapons:**
Just create new WeaponData .tres files. System supports unlimited weapons.

**Example:** Dual Pistols
- Tags: RAPID_FIRE, PRECISION
- Fills gap between Pistol and Assault Rifle

**New Tags:**
Just add to SynergyCalculator logic. Existing weapons unchanged.

**Example:** ELEMENTAL tag
- Could add fire/ice effects later

### Moderate Additions

**Weapon Rarity:**
- Common/Rare/Epic/Legendary tiers
- Higher rarity = better base stats + more tags
- Add `rarity` field to WeaponData

**Weapon Upgrades:**
- In-shop upgrade button
- Increase tier (Bronze → Silver → Gold)
- Add `upgrade_level` field to WeaponData

### Complex Additions

**Conditional Synergies:**
- "If 2+ RAPID_FIRE AND 2+ PIERCING, unlock Shredder bonus"
- Requires new SynergyDefinition resource
- Adds significant complexity

**Character-Specific Weapons:**
- Weapons that only certain classes can equip
- Requires class restriction logic
- Changes "shared pool" philosophy

---

## Success Criteria

This design succeeds if:

1. ✓ **Players understand it quickly** - Tags are self-explanatory, synergies are intuitive
2. ✓ **Builds feel distinct** - RAPID_FIRE plays different from AREA plays different from PRECISION
3. ✓ **Classes have identity** - Each class has clear "best" weapons
4. ✓ **Choices matter** - Weapon selection impacts power level significantly
5. ✓ **System scales** - Can add weapons/tags without refactoring
6. ✓ **Implementation is feasible** - Uses existing Godot patterns, ~20 hours work

---

## Open Questions

None - design is complete and ready for implementation.

---

## Conclusion

This weapon system creates strategic depth through simple, cumulative mechanics. Tag synergies encourage specialization while class bonuses reinforce character identity. The modern firearms theme provides clear archetypes, and the shared weapon pool with class flavoring balances freedom and identity.

The system is built on Godot's resource system for easy data authoring, uses an autoload calculator for centralized logic, and integrates cleanly with existing shop and wave systems.

Expected outcome: Players experiment with different builds, discover powerful synergies, and feel meaningful differences between character classes—all while keeping the core gameplay loop intact.
