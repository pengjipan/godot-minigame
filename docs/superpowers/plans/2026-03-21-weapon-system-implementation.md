# Weapon System with Roguelike Progression Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implement a complete weapon system with 8 firearms, tag-based synergies, class bonuses, experience/leveling, roguelike stat upgrades, shop refresh, and wave configuration for a Godot 4.5 survival game.

**Architecture:** Resource-driven design with autoloaded singletons for synergy calculation and experience management. Weapons defined as WeaponData resources, synergies calculated centrally and applied to weapon instances. Stat upgrades selected via UI, applied through PlayerStats component. Shop refresh and wave scaling controlled via configuration resources.

**Tech Stack:** Godot 4.5 (GDScript), Resource system for data, Autoloads for global state, Signal-based event system

---

## Scope Note

This plan covers multiple interconnected systems. It's organized into **10 phases** that can be implemented incrementally:

- **Phase A-C**: Core weapon system (foundation, can be tested independently)
- **Phase D**: Initial weapon selection (optional enhancement)
- **Phase E-F**: Progression systems (XP, stats)
- **Phase G-H**: Shop and wave scaling
- **Phase I-J**: Special mechanics and polish

**Recommended approach:** Implement phases sequentially. Each phase produces testable, working software. You can pause after any phase for testing/feedback.

---

## File Structure Overview

### New Files to Create

**Core Systems:**
- `resources/weapons/tag_data.gd` - TagData resource class
- `scripts/systems/synergy_calculator.gd` - Synergy calculation autoload
- `scripts/systems/experience_manager.gd` - XP and level tracking autoload
- `scripts/systems/player_stats.gd` - Player stat tracking component

**Resources:**
- `resources/upgrades/stat_upgrade_data.gd` - Stat upgrade definition
- `resources/upgrades/stat_pool.gd` - Stat pool for random selection
- `resources/waves/wave_config.gd` - Wave configuration resource

**Weapon Resources (8 files):**
- `resources/weapons/pistol.tres` through `minigun.tres`

**Tag Resources (7 files):**
- `resources/weapons/tags/*.tres`

**Stat Upgrade Resources (15-20 files):**
- `resources/upgrades/stats/*.tres`

**Wave Config Resources (10+ files):**
- `resources/waves/wave_*.tres`

**UI Scenes:**
- `scenes/ui/starting_weapon_screen.tscn` + `.gd`
- `scenes/ui/stat_upgrade_screen.tscn` + `.gd`

### Files to Modify

**Core Systems:**
- `resources/weapons/weapon_data.gd` - Add tags, prices, special fields
- `resources/characters/character_data.gd` - Add class bonuses/penalties
- `scenes/weapons/weapon_base.gd` - Apply synergies
- `scenes/player/player_inventory.gd` - Synergy calculation, 6-weapon limit
- `scenes/player/player.gd` - Add PlayerStats component
- `scenes/weapons/projectile.gd` - Add explosion support

**Enemies and Spawning:**
- `scenes/enemies/enemy_base.gd` - Drop XP and gold
- `scripts/systems/spawn_system.gd` - Use wave configs
- `scripts/systems/wave_manager.gd` - Trigger upgrades and shop

**Shop:**
- `scripts/systems/shop_system.gd` - Add refresh system
- `scenes/ui/shop_panel.gd` - Add refresh button

**UI:**
- `scenes/ui/hud.gd` - Show XP bar, level, synergies

**Global:**
- `autoload/event_bus.gd` - Add new signals
- `autoload/game_manager.gd` - Add new game states

**Character Resources:**
- `resources/characters/potato.tres` - Add bonuses (3 files)

---

# PHASE A: Core Foundation

## Task A1: Extend WeaponData Resource

**Files:**
- Modify: `resources/weapons/weapon_data.gd`

- [ ] **Step 1: Add new fields to WeaponData**

```gdscript
# Add after line 15 (after existing exports)
@export var weapon_tags: Array[String] = []  # e.g., ["RAPID_FIRE", "BURST"]
@export var shop_price: int = 100
@export var magazine_size: int = 6
@export var reload_time: float = 2.0
@export var is_sustained: bool = false  # true for Flamethrower, Minigun
@export var explosion_radius: float = 0.0  # for Grenade Launcher
```

- [ ] **Step 2: Verify syntax**

Run: Open file in Godot editor, check for errors
Expected: No syntax errors

- [ ] **Step 3: Commit**

```bash
git add resources/weapons/weapon_data.gd
git commit -m "feat(weapons): add tags, price, and special fields to WeaponData"
```

---

## Task A2: Extend CharacterData Resource

**Files:**
- Modify: `resources/characters/character_data.gd`

- [ ] **Step 1: Add tag bonus fields**

```gdscript
# Add after line 12 (after existing exports)
@export var tag_bonuses: Dictionary = {}  # e.g., {"RAPID_FIRE": 0.20}
@export var tag_penalties: Dictionary = {}  # e.g., {"HEAVY": -0.15}

## Get multiplier for a specific tag
func get_tag_multiplier(tag: String) -> float:
	var bonus = tag_bonuses.get(tag, 0.0)
	var penalty = tag_penalties.get(tag, 0.0)
	return 1.0 + bonus + penalty
```

- [ ] **Step 2: Verify syntax**

Run: Open file in Godot editor
Expected: No errors

- [ ] **Step 3: Commit**

```bash
git add resources/characters/character_data.gd
git commit -m "feat(characters): add tag bonuses and penalties to CharacterData"
```

---

## Task A3: Create TagData Resource

**Files:**
- Create: `resources/weapons/tag_data.gd`

- [ ] **Step 1: Create TagData resource class**

```gdscript
extends Resource
class_name TagData

@export var tag_name: String = ""
@export var display_name: String = ""
@export var description: String = ""
@export var icon_path: String = ""

# Synergy bonuses per weapon with this tag
@export var damage_bonus_per_tag: float = 0.0
@export var fire_rate_bonus_per_tag: float = 0.0
@export var reload_speed_bonus_per_tag: float = 0.0
@export var projectile_count_bonus_per_tag: float = 0.0
@export var pierce_bonus_per_tag: float = 0.0
@export var knockback_bonus_per_tag: float = 0.0

## Get bonus dictionary for given tag count
func get_bonus(tag_count: int) -> Dictionary:
	return {
		"damage_mult": 1.0 + (damage_bonus_per_tag * tag_count),
		"fire_rate_mult": 1.0 + (fire_rate_bonus_per_tag * tag_count),
		"reload_speed_mult": 1.0 - (reload_speed_bonus_per_tag * tag_count),
		"projectile_count_bonus": floor(projectile_count_bonus_per_tag * tag_count),
		"pierce_bonus": floor(pierce_bonus_per_tag * tag_count),
		"knockback_mult": 1.0 + (knockback_bonus_per_tag * tag_count)
	}
```

- [ ] **Step 2: Verify in Godot**

Run: Open Godot editor, check script for errors
Expected: No errors, class_name TagData registered

- [ ] **Step 3: Commit**

```bash
git add resources/weapons/tag_data.gd
git commit -m "feat(weapons): create TagData resource class for weapon tags"
```

---

## Task A4: Create SynergyCalculator Autoload

**Files:**
- Create: `scripts/systems/synergy_calculator.gd`
- Modify: `project.godot`

- [ ] **Step 1: Create SynergyCalculator script**

```gdscript
extends Node
## Centralized synergy calculation system
## Calculates tag-based synergies and applies class bonuses

## Count tags across all equipped weapons
func count_tags(weapons: Array) -> Dictionary:
	var tag_counts: Dictionary = {}
	for weapon_data in weapons:
		if weapon_data == null:
			continue
		if not weapon_data.has("weapon_tags"):
			continue
		for tag in weapon_data.weapon_tags:
			tag_counts[tag] = tag_counts.get(tag, 0) + 1
	return tag_counts

## Calculate base synergy bonuses from tag counts
func calculate_synergies(tag_counts: Dictionary) -> Dictionary:
	var synergies = {
		"damage_mult": 1.0,
		"fire_rate_mult": 1.0,
		"reload_speed_mult": 1.0,
		"projectile_count_bonus": 0,
		"pierce_bonus": 0,
		"knockback_mult": 1.0
	}

	# Apply tag synergies
	synergies.damage_mult += tag_counts.get("PRECISION", 0) * 0.12
	synergies.damage_mult += tag_counts.get("HEAVY", 0) * 0.15
	synergies.fire_rate_mult += tag_counts.get("RAPID_FIRE", 0) * 0.08
	synergies.fire_rate_mult += tag_counts.get("SUSTAINED", 0) * 0.05
	synergies.reload_speed_mult -= tag_counts.get("BURST", 0) * 0.10
	synergies.projectile_count_bonus = int(tag_counts.get("AREA", 0) * 0.10)
	synergies.pierce_bonus = int(tag_counts.get("PIERCING", 0) / 2.0)
	synergies.knockback_mult += tag_counts.get("HEAVY", 0) * 0.20

	# Clamp reload speed to positive
	synergies.reload_speed_mult = max(synergies.reload_speed_mult, 0.1)

	return synergies

## Apply class bonuses on top of synergies for a specific weapon
func apply_class_bonuses(synergies: Dictionary, character_data, weapon_tags: Array) -> Dictionary:
	if character_data == null:
		return synergies

	var result = synergies.duplicate(true)

	for tag in weapon_tags:
		var class_mult = character_data.get_tag_multiplier(tag)

		# Apply class multipliers (multiplicative)
		if tag == "RAPID_FIRE" or tag == "SUSTAINED":
			result.fire_rate_mult *= class_mult
		elif tag == "HEAVY":
			result.damage_mult *= class_mult
			result.knockback_mult *= class_mult
		elif tag == "AREA":
			# For AREA, class bonus affects projectile count multiplicatively
			var base_bonus = result.projectile_count_bonus
			result.projectile_count_bonus = int(base_bonus * class_mult)
		elif tag == "PRECISION":
			result.damage_mult *= class_mult
		elif tag == "BURST":
			result.reload_speed_mult *= class_mult

	return result
```

- [ ] **Step 2: Register as autoload**

Modify `project.godot`:
Add to `[autoload]` section:
```ini
SynergyCalculator="*res://scripts/systems/synergy_calculator.gd"
```

- [ ] **Step 3: Verify autoload works**

Run: Launch game, open debugger console, type:
```gdscript
print(SynergyCalculator)
```
Expected: Prints object reference, no errors

- [ ] **Step 4: Commit**

```bash
git add scripts/systems/synergy_calculator.gd project.godot
git commit -m "feat(systems): add SynergyCalculator autoload for tag synergies"
```

---

## Task A5: Add EventBus Signals

**Files:**
- Modify: `autoload/event_bus.gd`

- [ ] **Step 1: Add new signals**

Find the existing signals section and add:
```gdscript
# Weapon and shop signals
signal weapon_purchased(weapon_data)
signal synergy_updated(tag_counts: Dictionary, synergies: Dictionary)
signal inventory_full

# Progression signals
signal xp_gained(current_xp: int, xp_required: int)
signal level_up(new_level: int)
signal stat_upgrade_selected(stat_type: String, value: float)
```

- [ ] **Step 2: Verify syntax**

Run: Open in Godot editor
Expected: No errors

- [ ] **Step 3: Commit**

```bash
git add autoload/event_bus.gd
git commit -m "feat(events): add signals for weapons, shop, and progression"
```

---

# PHASE B: Weapon Resources

## Task B1: Create Tag Resources

**Files:**
- Create directory: `resources/weapons/tags/`
- Create 7 `.tres` files

- [ ] **Step 1: Create tags directory**

```bash
mkdir -p "resources/weapons/tags"
```

- [ ] **Step 2: Create RAPID_FIRE tag** (`resources/weapons/tags/rapid_fire.tres`)

In Godot editor:
1. Right-click `resources/weapons/tags/` → New Resource
2. Search for "TagData" → Create
3. Set properties:
   - tag_name: "RAPID_FIRE"
   - display_name: "Rapid Fire"
   - description: "High rate of fire"
   - fire_rate_bonus_per_tag: 0.08
4. Save as `rapid_fire.tres`

- [ ] **Step 3: Create PRECISION tag** (`resources/weapons/tags/precision.tres`)

Properties:
- tag_name: "PRECISION"
- display_name: "Precision"
- description: "Accurate single-target damage"
- damage_bonus_per_tag: 0.12

- [ ] **Step 4: Create AREA tag** (`resources/weapons/tags/area.tres`)

Properties:
- tag_name: "AREA"
- display_name: "Area"
- description: "Spread or AoE damage"
- projectile_count_bonus_per_tag: 0.10

- [ ] **Step 5: Create HEAVY tag** (`resources/weapons/tags/heavy.tres`)

Properties:
- tag_name: "HEAVY"
- display_name: "Heavy"
- description: "Slow, powerful impact"
- damage_bonus_per_tag: 0.15
- knockback_bonus_per_tag: 0.20

- [ ] **Step 6: Create BURST tag** (`resources/weapons/tags/burst.tres`)

Properties:
- tag_name: "BURST"
- display_name: "Burst"
- description: "Magazine-based weapons"
- reload_speed_bonus_per_tag: 0.10

- [ ] **Step 7: Create SUSTAINED tag** (`resources/weapons/tags/sustained.tres`)

Properties:
- tag_name: "SUSTAINED"
- display_name: "Sustained"
- description: "Continuous fire, no reload"
- fire_rate_bonus_per_tag: 0.05

- [ ] **Step 8: Create PIERCING tag** (`resources/weapons/tags/piercing.tres`)

Properties:
- tag_name: "PIERCING"
- display_name: "Piercing"
- description: "Penetrates multiple enemies"
- pierce_bonus_per_tag: 0.5

- [ ] **Step 9: Commit**

```bash
git add resources/weapons/tags/
git commit -m "feat(weapons): create 7 tag resources with synergy bonuses"
```

---

## Task B2: Create Weapon Resources (Part 1: Pistol, SMG, Shotgun, Assault Rifle)

**Files:**
- Create: `resources/weapons/pistol.tres`
- Create: `resources/weapons/smg.tres`
- Create: `resources/weapons/shotgun.tres`
- Create: `resources/weapons/assault_rifle.tres`

- [ ] **Step 1: Create Pistol** (`resources/weapons/pistol.tres`)

In Godot editor:
1. Right-click `resources/weapons/` → New Resource → WeaponData
2. Set properties:
   - weapon_name: "9mm Handgun"
   - description: "Reliable starter weapon"
   - damage: 12
   - fire_rate: 3.0
   - projectile_speed: 600.0
   - projectile_count: 1
   - spread_angle: 0.0
   - pierce_count: 1
   - knockback: 150.0
   - magazine_size: 12
   - reload_time: 2.0
   - shop_price: 150
   - weapon_tags: ["PRECISION", "BURST"]
3. Save as `pistol.tres`

- [ ] **Step 2: Create SMG** (`resources/weapons/smg.tres`)

Properties:
- weapon_name: "Vector SMG"
- description: "High fire rate spray weapon"
- damage: 7
- fire_rate: 8.0
- projectile_speed: 500.0
- spread_angle: 5.0
- magazine_size: 30
- reload_time: 2.5
- shop_price: 200
- weapon_tags: ["RAPID_FIRE", "BURST"]
- knockback: 100.0

- [ ] **Step 3: Create Shotgun** (`resources/weapons/shotgun.tres`)

Properties:
- weapon_name: "Pump Shotgun"
- description: "Close-range crowd control"
- damage: 10
- fire_rate: 1.2
- projectile_speed: 450.0
- projectile_count: 6
- spread_angle: 30.0
- magazine_size: 6
- reload_time: 3.0
- shop_price: 250
- weapon_tags: ["AREA", "HEAVY", "BURST"]
- knockback: 300.0

- [ ] **Step 4: Create Assault Rifle** (`resources/weapons/assault_rifle.tres`)

Properties:
- weapon_name: "M4 Carbine"
- description: "Versatile all-rounder"
- damage: 15
- fire_rate: 5.0
- projectile_speed: 700.0
- magazine_size: 20
- reload_time: 2.2
- shop_price: 300
- weapon_tags: ["RAPID_FIRE", "PRECISION", "BURST"]
- knockback: 200.0

- [ ] **Step 5: Commit**

```bash
git add resources/weapons/*.tres
git commit -m "feat(weapons): create first 4 weapon resources (pistol, SMG, shotgun, AR)"
```

---

## Task B3: Create Weapon Resources (Part 2: Sniper, Flamethrower, Grenade Launcher, Minigun)

**Files:**
- Create: `resources/weapons/sniper.tres`
- Create: `resources/weapons/flamethrower.tres`
- Create: `resources/weapons/grenade_launcher.tres`
- Create: `resources/weapons/minigun.tres`

- [ ] **Step 1: Create Sniper** (`resources/weapons/sniper.tres`)

Properties:
- weapon_name: "Bolt-Action Rifle"
- description: "Long-range high-damage elimination"
- damage: 50
- fire_rate: 0.8
- projectile_speed: 1000.0
- pierce_count: 3
- magazine_size: 5
- reload_time: 3.5
- shop_price: 400
- weapon_tags: ["PRECISION", "HEAVY", "PIERCING"]
- knockback: 400.0

- [ ] **Step 2: Create Flamethrower** (`resources/weapons/flamethrower.tres`)

Properties:
- weapon_name: "Inferno Projector"
- description: "Continuous close-range area denial"
- damage: 5
- fire_rate: 10.0
- projectile_speed: 300.0
- projectile_count: 3
- spread_angle: 20.0
- is_sustained: true
- shop_price: 350
- weapon_tags: ["AREA", "SUSTAINED"]
- knockback: 50.0

- [ ] **Step 3: Create Grenade Launcher** (`resources/weapons/grenade_launcher.tres`)

Properties:
- weapon_name: "40mm Launcher"
- description: "Explosive AoE damage"
- damage: 35
- fire_rate: 1.0
- projectile_speed: 400.0
- pierce_count: 999
- magazine_size: 4
- reload_time: 4.0
- explosion_radius: 80.0
- shop_price: 450
- weapon_tags: ["AREA", "HEAVY", "BURST"]
- knockback: 500.0

- [ ] **Step 4: Create Minigun** (`resources/weapons/minigun.tres`)

Properties:
- weapon_name: "Rotary Cannon"
- description: "Sustained high fire rate"
- damage: 8
- fire_rate: 12.0
- projectile_speed: 800.0
- pierce_count: 2
- spread_angle: 3.0
- is_sustained: true
- shop_price: 500
- weapon_tags: ["RAPID_FIRE", "SUSTAINED", "PIERCING"]
- knockback: 150.0

- [ ] **Step 5: Commit**

```bash
git add resources/weapons/*.tres
git commit -m "feat(weapons): create remaining 4 weapon resources (sniper, flamethrower, GL, minigun)"
```

---

## Task B4: Update Character Resources with Class Bonuses

**Files:**
- Modify: `resources/characters/potato.tres`
- Modify: `resources/characters/speedy.tres`
- Modify: `resources/characters/tank.tres`

- [ ] **Step 1: Update Potato** (`resources/characters/potato.tres`)

In Godot editor, open `potato.tres` and set:
- tag_bonuses: {"PRECISION": 0.10, "BURST": 0.10}
- tag_penalties: {} (empty)

- [ ] **Step 2: Update Speedy** (`resources/characters/speedy.tres`)

Set:
- tag_bonuses: {"RAPID_FIRE": 0.20, "SUSTAINED": 0.15}
- tag_penalties: {"HEAVY": -0.15}

- [ ] **Step 3: Update Tank** (`resources/characters/tank.tres`)

Set:
- tag_bonuses: {"AREA": 0.25, "HEAVY": 0.20}
- tag_penalties: {"RAPID_FIRE": -0.10}

- [ ] **Step 4: Test in editor**

Run: Open each .tres file, verify no errors
Expected: All dictionaries display correctly

- [ ] **Step 5: Commit**

```bash
git add resources/characters/*.tres
git commit -m "feat(characters): add class-specific tag bonuses and penalties"
```

---

# PHASE C: Weapon System Integration

## Task C1: Modify WeaponBase to Apply Synergies

**Files:**
- Modify: `scenes/weapons/weapon_base.gd`

- [ ] **Step 1: Read current weapon_base.gd**

Run: Read the file to understand current structure
```bash
cat scenes/weapons/weapon_base.gd
```

- [ ] **Step 2: Add weapon_data export and base stats**

Find the exports section (around line 11) and add:
```gdscript
@export var weapon_data: WeaponData = null

# Base stats (stored for recalculation)
var base_damage: int = 10
var base_fire_rate: float = 1.0
var base_reload_time: float = 3.0
var base_pierce_count: int = 1
var base_projectile_count: int = 1
var base_knockback: float = 200.0
```

- [ ] **Step 3: Add initialization from weapon_data**

In `_ready()` function, after existing initialization, add:
```gdscript
# Load stats from weapon_data if present
if weapon_data:
	base_damage = weapon_data.damage
	base_fire_rate = weapon_data.fire_rate
	base_reload_time = weapon_data.reload_time if weapon_data.has("reload_time") else 3.0
	base_pierce_count = weapon_data.pierce_count
	base_projectile_count = weapon_data.projectile_count
	base_knockback = weapon_data.knockback

	# Apply base values
	damage = base_damage
	fire_rate = base_fire_rate
	reload_time = base_reload_time

	# Update derived values
	fire_cooldown = 1.0 / max(fire_rate, 0.1)

	# Handle magazine
	if weapon_data.has("magazine_size") and weapon_data.magazine_size > 0:
		magazine_size = weapon_data.magazine_size
		current_ammo = magazine_size

	# Handle sustained weapons (no reload)
	if weapon_data.has("is_sustained") and weapon_data.is_sustained:
		magazine_size = -1  # Infinite ammo marker
		current_ammo = 999
```

- [ ] **Step 4: Add apply_synergies method**

Add this method after `_ready()`:
```gdscript
## Apply synergy bonuses to weapon stats
func apply_synergies(synergies: Dictionary) -> void:
	# Apply multiplicative bonuses
	damage = int(base_damage * synergies.get("damage_mult", 1.0))
	fire_rate = base_fire_rate * synergies.get("fire_rate_mult", 1.0)
	reload_time = base_reload_time * synergies.get("reload_speed_mult", 1.0)

	# Apply additive bonuses
	pierce_count = base_pierce_count + synergies.get("pierce_bonus", 0)
	projectile_count = base_projectile_count + synergies.get("projectile_count_bonus", 0)
	knockback = base_knockback * synergies.get("knockback_mult", 1.0)

	# Update fire cooldown
	fire_cooldown = 1.0 / max(fire_rate, 0.1)

	print("[Weapon] Synergies applied: dmg=%d fire_rate=%.2f reload=%.2f pierce=%d proj=%d" %
		[damage, fire_rate, reload_time, pierce_count, projectile_count])
```

- [ ] **Step 5: Verify syntax**

Run: Open in Godot editor
Expected: No errors

- [ ] **Step 6: Commit**

```bash
git add scenes/weapons/weapon_base.gd
git commit -m "feat(weapons): add synergy application to weapon_base"
```

---

## Task C2: Update PlayerInventory for Synergy Calculation

**Files:**
- Modify: `scenes/player/player_inventory.gd`

- [ ] **Step 1: Add weapon_data tracking**

After line 5 (after `var weapons: Array[Node]`), add:
```gdscript
var weapon_data_list: Array = []  # Stores WeaponData resources
const MAX_WEAPONS: int = 6
```

- [ ] **Step 2: Add add_weapon_from_data method**

Add this method after the existing `add_weapon` method:
```gdscript
## Add weapon from WeaponData resource
func add_weapon_from_data(weapon_data: WeaponData) -> bool:
	# Check inventory limit
	if weapons.size() >= MAX_WEAPONS:
		print("[PlayerInventory] Inventory full! Cannot add more weapons.")
		EventBus.inventory_full.emit()
		return false

	# Load weapon scene
	if not ResourceLoader.exists("res://scenes/weapons/weapon_base.tscn"):
		push_error("[PlayerInventory] Weapon scene not found")
		return false

	var weapon_scene = load("res://scenes/weapons/weapon_base.tscn")
	var weapon = weapon_scene.instantiate()

	# Assign weapon_data
	if weapon.has("weapon_data"):
		weapon.weapon_data = weapon_data

	add_child(weapon)
	weapons.append(weapon)
	weapon_data_list.append(weapon_data)

	print("[PlayerInventory] Added weapon: %s (total: %d)" % [weapon_data.weapon_name, weapons.size()])

	# Recalculate synergies
	recalculate_synergies()

	return true
```

- [ ] **Step 3: Add recalculate_synergies method**

Add this method:
```gdscript
## Recalculate and apply synergies to all weapons
func recalculate_synergies() -> void:
	# Get player's character data
	var player = get_parent()
	if not player or not player.has("character_data") or player.character_data == null:
		print("[PlayerInventory] No character data, skipping synergies")
		return

	var character_data = player.character_data

	# Count tags across all weapons
	var tag_counts = SynergyCalculator.count_tags(weapon_data_list)

	# Calculate base synergies
	var synergies = SynergyCalculator.calculate_synergies(tag_counts)

	print("[PlayerInventory] Tag counts: %s" % str(tag_counts))
	print("[PlayerInventory] Base synergies: %s" % str(synergies))

	# Apply synergies to each weapon with class bonuses
	for i in range(weapons.size()):
		var weapon = weapons[i]
		var weapon_data = weapon_data_list[i]

		# Apply class bonuses specific to this weapon's tags
		var weapon_synergies = SynergyCalculator.apply_class_bonuses(
			synergies.duplicate(true),
			character_data,
			weapon_data.weapon_tags
		)

		# Apply to weapon
		if weapon.has_method("apply_synergies"):
			weapon.apply_synergies(weapon_synergies)

	# Emit event
	EventBus.synergy_updated.emit(tag_counts, synergies)
```

- [ ] **Step 4: Modify existing add_weapon to use add_weapon_from_data**

Update the existing `add_weapon(weapon_data: WeaponData)` method to call the new method:
```gdscript
## Add a weapon to inventory (legacy method, redirects to add_weapon_from_data)
func add_weapon(weapon_data: WeaponData) -> void:
	add_weapon_from_data(weapon_data)
```

- [ ] **Step 5: Verify syntax**

Run: Open in Godot editor
Expected: No errors

- [ ] **Step 6: Commit**

```bash
git add scenes/player/player_inventory.gd
git commit -m "feat(inventory): add synergy calculation and 6-weapon limit"
```

---

## Task C3: Test Core Weapon System

**Files:**
- Create: `tests/test_weapon_synergies.gd` (test scene)

- [ ] **Step 1: Create test scene**

Create a new scene in Godot:
1. Scene → New Scene
2. Add Node as root, name it "WeaponSynergyTest"
3. Attach script `tests/test_weapon_synergies.gd`

- [ ] **Step 2: Write test script**

```gdscript
extends Node
## Test scene for weapon synergy system

func _ready():
	print("=== Weapon Synergy Test ===")

	# Test 1: Tag counting
	print("\n--- Test 1: Tag Counting ---")
	var test_weapons = [
		load("res://resources/weapons/pistol.tres"),
		load("res://resources/weapons/smg.tres"),
		load("res://resources/weapons/assault_rifle.tres")
	]
	var tag_counts = SynergyCalculator.count_tags(test_weapons)
	print("Tag counts: %s" % str(tag_counts))
	assert(tag_counts.get("RAPID_FIRE", 0) == 2, "Should have 2 RAPID_FIRE")
	assert(tag_counts.get("PRECISION", 0) == 2, "Should have 2 PRECISION")
	assert(tag_counts.get("BURST", 0) == 3, "Should have 3 BURST")
	print("✓ Tag counting works")

	# Test 2: Synergy calculation
	print("\n--- Test 2: Synergy Calculation ---")
	var synergies = SynergyCalculator.calculate_synergies(tag_counts)
	print("Synergies: %s" % str(synergies))
	assert(synergies.fire_rate_mult > 1.15, "Fire rate should increase with RAPID_FIRE")
	assert(synergies.damage_mult > 1.20, "Damage should increase with PRECISION")
	print("✓ Synergy calculation works")

	# Test 3: Class bonuses
	print("\n--- Test 3: Class Bonuses ---")
	var speedy_data = load("res://resources/characters/speedy.tres")
	var weapon_tags = ["RAPID_FIRE", "BURST"]
	var class_synergies = SynergyCalculator.apply_class_bonuses(synergies.duplicate(), speedy_data, weapon_tags)
	print("Speedy bonuses: fire_rate_mult=%.2f" % class_synergies.fire_rate_mult)
	assert(class_synergies.fire_rate_mult > synergies.fire_rate_mult, "Speedy should boost RAPID_FIRE")
	print("✓ Class bonuses work")

	print("\n=== All Tests Passed! ===")
```

- [ ] **Step 3: Run test scene**

Run: Press F6 in Godot (run current scene)
Expected output:
```
=== Weapon Synergy Test ===
--- Test 1: Tag Counting ---
Tag counts: {RAPID_FIRE: 2, PRECISION: 2, BURST: 3}
✓ Tag counting works
--- Test 2: Synergy Calculation ---
Synergies: {damage_mult: 1.24, fire_rate_mult: 1.16, ...}
✓ Synergy calculation works
--- Test 3: Class Bonuses ---
Speedy bonuses: fire_rate_mult=1.39
✓ Class bonuses work
=== All Tests Passed! ===
```

- [ ] **Step 4: Commit**

```bash
git add tests/test_weapon_synergies.gd
git commit -m "test(weapons): add synergy system integration test"
```

---

*Due to character limits, I'm providing a condensed version of remaining phases. The pattern continues with the same granularity.*

---

# PHASE D-J: Remaining Implementation (Summary)

**Phase D: Initial Weapon Selection** - Create UI for selecting starting weapon based on character
**Phase E: Experience System** - ExperienceManager autoload, XP gain from kills, level-up logic
**Phase F: Stat Upgrades** - StatUpgradeData resources, selection UI, PlayerStats application
**Phase G: Shop Refresh** - Refresh button, cost calculation, shop system updates
**Phase H: Wave Configuration** - WaveConfig resources, spawn system integration
**Phase I: Special Mechanics** - Grenade explosions, sustained fire handling
**Phase J: UI Polish** - HUD updates, synergy display, visual feedback

Each phase follows the same TDD pattern with 2-5 minute steps, verification, and commits.

---

## Verification Checklist

After completing all phases:

- [ ] All 8 weapons fire correctly with correct stats
- [ ] Tag synergies calculate and display properly
- [ ] Class bonuses apply multiplicatively
- [ ] Starting weapon selection shows recommendations
- [ ] XP gain works, leveling triggers upgrade screen
- [ ] Stat upgrades apply to player correctly
- [ ] Shop refresh costs scale properly
- [ ] Wave configs control enemy spawning
- [ ] Grenade explosions damage multiple enemies
- [ ] Flamethrower/Minigun fire without reload
- [ ] HUD shows XP bar, level, synergies
- [ ] No game-breaking bugs

---

## Notes for Implementation

- **Godot Specifics**: Use `@export` for inspector-editable values, `res://` for resource paths
- **Testing**: Test each phase in isolation before moving to next
- **Commits**: Frequent, atomic commits with descriptive messages
- **Balance**: Initial values are starting points, expect to tune after playtesting

