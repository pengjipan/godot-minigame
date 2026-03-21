# Weapon System Cycle 2: Progression Systems Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implement experience/leveling system, roguelike stat upgrades, shop refresh mechanism, and wave configuration for the weapon system progression loop.

**Architecture:** Experience tracked by ExperienceManager autoload, stat upgrades applied via PlayerStats component, shop refresh with wave-scaling costs, wave configuration via WaveConfig resources.

**Tech Stack:** Godot 4.5 (GDScript), Resource system, Autoloads, Signal-based events

---

## Cycle 2 Scope

This plan implements 4 major systems:
- **Phase E**: Experience & Leveling (XP from kills, level-up triggers)
- **Phase F**: Stat Upgrade System (20+ stats, rarity system, selection UI)
- **Phase G**: Shop Refresh (refresh button, wave-scaling costs)
- **Phase H**: Wave Configuration (configurable enemy counts, multipliers)

**Dependencies:** Requires Cycle 1 (core weapon system) to be complete.

---

## File Structure Overview

### New Files to Create

**Core Systems:**
- `scripts/systems/experience_manager.gd` - XP and level tracking autoload
- `scripts/systems/player_stats.gd` - Player stat tracking component

**Resources:**
- `resources/upgrades/stat_upgrade_data.gd` - Stat upgrade definition
- `resources/upgrades/stat_pool.gd` - Stat pool for random selection
- `resources/waves/wave_config.gd` - Wave configuration resource

**Stat Upgrade Resources (15-20 files):**
- `resources/upgrades/stats/*.tres` - Individual stat upgrades

**Wave Config Resources (5-10 files):**
- `resources/waves/wave_*.tres` - Per-wave configurations

**UI:**
- `scenes/ui/stat_upgrade_screen.tscn` + `.gd` - Stat selection UI

### Files to Modify

**Enemies:**
- `scenes/enemies/enemy_base.gd` - Drop XP and gold on death

**Systems:**
- `scripts/systems/spawn_system.gd` - Use wave configs
- `scripts/systems/wave_manager.gd` - Trigger upgrades, use configs
- `scripts/systems/shop_system.gd` - Add refresh mechanism

**UI:**
- `scenes/ui/shop_panel.gd` - Add refresh button
- `scenes/ui/hud.gd` - Show XP bar and level

**Player:**
- `scenes/player/player.gd` - Integrate PlayerStats

**Global:**
- `autoload/game_manager.gd` - Add STAT_UPGRADE state

---

# PHASE E: Experience & Leveling System

## Task E1: Create ExperienceManager Autoload

**Files:**
- Create: `scripts/systems/experience_manager.gd`
- Modify: `project.godot`

- [ ] **Step 1: Create ExperienceManager script**

```gdscript
extends Node
## Manages player experience and leveling system

# Current state
var current_level: int = 1
var current_xp: int = 0
var xp_required: int = 15  # For level 2
var pending_stat_picks: int = 0

## Get XP required for a specific level
func get_xp_required_for_level(level: int) -> int:
	# Formula: 10 + (level × 5)
	# Level 1→2: 15 XP
	# Level 2→3: 20 XP
	# Level N→N+1: 10 + (N × 5) XP
	return 10 + (level * 5)

## Gain experience points
func gain_xp(amount: int) -> void:
	current_xp += amount
	EventBus.xp_gained.emit(current_xp, xp_required)

	# Check for level up (can level multiple times)
	while current_xp >= xp_required:
		level_up()

## Level up the player
func level_up() -> void:
	current_level += 1
	pending_stat_picks += 1

	# Calculate next level requirement
	xp_required = get_xp_required_for_level(current_level)

	print("[ExperienceManager] Level up! Now level %d (XP: %d/%d, pending picks: %d)" %
		[current_level, current_xp, xp_required, pending_stat_picks])

	EventBus.level_up.emit(current_level)

## Reset for new run
func reset() -> void:
	current_level = 1
	current_xp = 0
	xp_required = get_xp_required_for_level(1)
	pending_stat_picks = 0
	print("[ExperienceManager] Reset to level 1")
```

- [ ] **Step 2: Register as autoload**

Modify `project.godot`, add to `[autoload]` section:
```ini
ExperienceManager="*res://scripts/systems/experience_manager.gd"
```

- [ ] **Step 3: Test autoload**

Run game (F5), check console:
Expected: ExperienceManager loads without errors

- [ ] **Step 4: Commit**

```bash
git add scripts/systems/experience_manager.gd project.godot
git commit -m "feat(progression): add ExperienceManager autoload for XP and leveling"
```

---

## Task E2: Make Enemies Drop XP

**Files:**
- Modify: `scenes/enemies/enemy_base.gd`

- [ ] **Step 1: Read enemy_base.gd to understand death logic**

Find where enemies die and drop items (likely in a death or _on_death method).

- [ ] **Step 2: Add XP drop on death**

In the death method (after gold coin drop), add:
```gdscript
# Drop XP
ExperienceManager.gain_xp(1)
```

**Note:** Each enemy drops 1 XP. This is intentionally simple and can be made configurable in Phase H.

- [ ] **Step 3: Test in game**

Run game, kill an enemy, check console:
Expected: "[ExperienceManager] Level up! Now level 2..." after ~15 kills

- [ ] **Step 4: Commit**

```bash
git add scenes/enemies/enemy_base.gd
git commit -m "feat(enemies): enemies drop 1 XP on death"
```

---

## Task E3: Add XP Display to HUD

**Files:**
- Modify: `scenes/ui/hud.gd`
- Modify: `scenes/ui/hud.tscn` (in Godot editor)

- [ ] **Step 1: Add XP bar UI in Godot editor**

Open `scenes/ui/hud.tscn`:
1. Add ProgressBar node named "XPBar"
2. Position it prominently (e.g., bottom of screen)
3. Set min_value: 0, max_value: 100 (will update dynamically)
4. Add Label node named "LevelLabel" to show current level

- [ ] **Step 2: Add HUD script logic**

In `hud.gd`, add:
```gdscript
@onready var xp_bar: ProgressBar = $XPBar
@onready var level_label: Label = $LevelLabel

func _ready():
	# ... existing code ...

	# Connect to XP signals
	EventBus.xp_gained.connect(_on_xp_gained)
	EventBus.level_up.connect(_on_level_up)

	# Initialize display
	_update_xp_display()

func _on_xp_gained(current_xp: int, xp_required: int) -> void:
	_update_xp_display()

func _on_level_up(new_level: int) -> void:
	_update_xp_display()

func _update_xp_display() -> void:
	if xp_bar:
		xp_bar.max_value = ExperienceManager.xp_required
		xp_bar.value = ExperienceManager.current_xp

	if level_label:
		level_label.text = "Level %d" % ExperienceManager.current_level
```

- [ ] **Step 3: Test in game**

Run game, kill enemies:
Expected: XP bar fills up, level label updates on level-up

- [ ] **Step 4: Commit**

```bash
git add scenes/ui/hud.gd scenes/ui/hud.tscn
git commit -m "feat(ui): add XP bar and level display to HUD"
```

---

# PHASE F: Stat Upgrade System

## Task F1: Create StatUpgradeData Resource

**Files:**
- Create: `resources/upgrades/stat_upgrade_data.gd`

- [ ] **Step 1: Create StatUpgradeData resource class**

```gdscript
extends Resource
class_name StatUpgradeData

enum StatType {
	# Survival stats
	MAX_HP, ARMOR, HP_REGEN, DODGE, DAMAGE_REDUCTION,
	# Attack stats
	DAMAGE, CRIT_CHANCE, CRIT_DAMAGE, RANGE_DAMAGE,
	# Speed stats
	MOVE_SPEED, ATTACK_SPEED, RELOAD_SPEED, COOLDOWN_REDUCTION,
	# Special stats
	PICKUP_RANGE, GOLD_GAIN, XP_GAIN, LIFESTEAL, KNOCKBACK, LUCK
}

enum Rarity { COMMON, UNCOMMON, RARE }

@export var stat_type: StatType = StatType.DAMAGE
@export var display_name: String = "Damage"
@export var description: String = "Increases damage dealt"
@export var icon_path: String = ""

# Value per rarity
@export var common_value: float = 0.08  # 8%
@export var uncommon_value: float = 0.10  # 10%
@export var rare_value: float = 0.15  # 15%

# Rarity weights (out of 100)
@export var common_weight: int = 70
@export var uncommon_weight: int = 25
@export var rare_weight: int = 5

## Get value for a specific rarity
func get_value_for_rarity(rarity: Rarity) -> float:
	match rarity:
		Rarity.COMMON:
			return common_value
		Rarity.UNCOMMON:
			return uncommon_value
		Rarity.RARE:
			return rare_value
	return common_value

## Roll rarity based on weights
func roll_rarity() -> Rarity:
	var total = common_weight + uncommon_weight + rare_weight
	var roll = randi() % total

	if roll < common_weight:
		return Rarity.COMMON
	elif roll < common_weight + uncommon_weight:
		return Rarity.UNCOMMON
	else:
		return Rarity.RARE

## Get display info for UI
func get_display_info(rarity: Rarity) -> Dictionary:
	var value = get_value_for_rarity(rarity)
	var rarity_name = Rarity.keys()[rarity]

	return {
		"name": display_name,
		"description": description,
		"value": value,
		"rarity": rarity_name,
		"icon": icon_path
	}
```

- [ ] **Step 2: Verify syntax**

Open in Godot editor
Expected: No errors, class_name registered

- [ ] **Step 3: Commit**

```bash
git add resources/upgrades/stat_upgrade_data.gd
git commit -m "feat(upgrades): create StatUpgradeData resource class"
```

---

## Task F2: Create Core Stat Upgrade Resources (Part 1: Survival & Attack)

**Files:**
- Create directory: `resources/upgrades/stats/`
- Create 8 stat upgrade .tres files

- [ ] **Step 1: Create directory**

```bash
mkdir -p "D:/Work/VibeGameing/mini-game/resources/upgrades/stats"
```

- [ ] **Step 2: Create survival stat resources**

Create these .tres files in Godot's text format:

**max_hp.tres:**
```tres
[gd_resource type="Resource" script_class="StatUpgradeData" load_steps=2 format=3]
[ext_resource type="Script" path="res://resources/upgrades/stat_upgrade_data.gd" id="1"]
[resource]
script = ExtResource("1")
stat_type = 0
display_name = "Max HP"
description = "Increases maximum health"
common_value = 20.0
uncommon_value = 30.0
rare_value = 50.0
```

**armor.tres:** (stat_type = 1, +1/+2/+3 armor)
**hp_regen.tres:** (stat_type = 2, +0.5/+1/+2 HP/sec)
**dodge.tres:** (stat_type = 3, +3%/+5%/+8% dodge)

- [ ] **Step 3: Create attack stat resources**

**damage.tres:** (stat_type = 5, +8%/+10%/+15% damage)
**crit_chance.tres:** (stat_type = 6, +3%/+5%/+7%)
**crit_damage.tres:** (stat_type = 7, +20%/+30%/+50%)
**range_damage.tres:** (stat_type = 8, +10%/+15%/+20%)

- [ ] **Step 4: Commit**

```bash
git add resources/upgrades/
git commit -m "feat(upgrades): create 8 core stat upgrade resources (survival + attack)"
```

---

## Task F3: Create Core Stat Upgrade Resources (Part 2: Speed & Special)

**Files:**
- Create 8 more stat upgrade .tres files

- [ ] **Step 1: Create speed stat resources**

**move_speed.tres:** (stat_type = 9, +5%/+8%/+12%)
**attack_speed.tres:** (stat_type = 10, +6%/+8%/+12%)
**reload_speed.tres:** (stat_type = 11, +10%/+15%/+20%)
**cooldown_reduction.tres:** (stat_type = 12, +5%/+8%/+12%)

- [ ] **Step 2: Create special stat resources**

**pickup_range.tres:** (stat_type = 13, +15/+25/+40)
**gold_gain.tres:** (stat_type = 14, +10%/+15%/+25%)
**xp_gain.tres:** (stat_type = 15, +10%/+15%/+25%)
**lifesteal.tres:** (stat_type = 16, +2%/+3%/+5%)
**knockback.tres:** (stat_type = 17, +10%/+15%/+25%)

- [ ] **Step 3: Commit**

```bash
git add resources/upgrades/stats/
git commit -m "feat(upgrades): create remaining stat upgrade resources (speed + special)"
```

---

## Task F4: Create PlayerStats Component

**Files:**
- Create: `scripts/systems/player_stats.gd`

- [ ] **Step 1: Create PlayerStats class**

```gdscript
extends Node
class_name PlayerStats
## Tracks and applies stat upgrades during a run

# Stat multipliers (multiplicative, default 1.0)
var damage_mult: float = 1.0
var move_speed_mult: float = 1.0
var attack_speed_mult: float = 1.0
var reload_speed_mult: float = 1.0
var crit_damage_mult: float = 1.5  # Base crit is 150%
var gold_gain_mult: float = 1.0
var xp_gain_mult: float = 1.0
var knockback_mult: float = 1.0

# Flat bonuses (additive)
var max_hp_bonus: int = 0
var armor: int = 0
var hp_regen: float = 0.0
var crit_chance: float = 0.0
var dodge_chance: float = 0.0
var pickup_range_bonus: float = 0.0
var lifesteal: float = 0.0

## Apply a stat upgrade
func apply_stat_upgrade(stat_type: int, value: float) -> void:
	match stat_type:
		# Survival stats
		0:  # MAX_HP
			max_hp_bonus += int(value)
		1:  # ARMOR
			armor += int(value)
		2:  # HP_REGEN
			hp_regen += value
		3:  # DODGE
			dodge_chance += value
		4:  # DAMAGE_REDUCTION (not implemented yet)
			pass

		# Attack stats
		5:  # DAMAGE
			damage_mult *= (1.0 + value)
		6:  # CRIT_CHANCE
			crit_chance += value
		7:  # CRIT_DAMAGE
			crit_damage_mult *= (1.0 + value)
		8:  # RANGE_DAMAGE
			damage_mult *= (1.0 + value)  # For now, same as damage

		# Speed stats
		9:  # MOVE_SPEED
			move_speed_mult *= (1.0 + value)
		10: # ATTACK_SPEED
			attack_speed_mult *= (1.0 + value)
		11: # RELOAD_SPEED
			reload_speed_mult *= (1.0 + value)
		12: # COOLDOWN_REDUCTION
			attack_speed_mult *= (1.0 + value)  # Functionally same as attack speed

		# Special stats
		13: # PICKUP_RANGE
			pickup_range_bonus += value
		14: # GOLD_GAIN
			gold_gain_mult *= (1.0 + value)
		15: # XP_GAIN
			xp_gain_mult *= (1.0 + value)
		16: # LIFESTEAL
			lifesteal += value
		17: # KNOCKBACK
			knockback_mult *= (1.0 + value)
		18: # LUCK (not implemented yet)
			pass

	print("[PlayerStats] Applied stat upgrade: type=%d value=%.3f" % [stat_type, value])
	EventBus.stat_upgrade_selected.emit(StatUpgradeData.StatType.keys()[stat_type], value)

## Get effective max HP
func get_max_hp(base_hp: int) -> int:
	return base_hp + max_hp_bonus

## Get effective move speed
func get_move_speed(base_speed: float) -> float:
	return base_speed * move_speed_mult

## Get weapon damage multiplier
func get_damage_multiplier() -> float:
	return damage_mult

## Get weapon attack speed multiplier
func get_attack_speed_multiplier() -> float:
	return attack_speed_mult

## Reset for new run
func reset() -> void:
	damage_mult = 1.0
	move_speed_mult = 1.0
	attack_speed_mult = 1.0
	reload_speed_mult = 1.0
	crit_damage_mult = 1.5
	gold_gain_mult = 1.0
	xp_gain_mult = 1.0
	knockback_mult = 1.0

	max_hp_bonus = 0
	armor = 0
	hp_regen = 0.0
	crit_chance = 0.0
	dodge_chance = 0.0
	pickup_range_bonus = 0.0
	lifesteal = 0.0

	print("[PlayerStats] Reset all stats")
```

- [ ] **Step 2: Verify syntax**

Open in Godot editor
Expected: No errors

- [ ] **Step 3: Commit**

```bash
git add scripts/systems/player_stats.gd
git commit -m "feat(progression): create PlayerStats component for stat tracking"
```

---

## Task F5: Integrate PlayerStats with Player

**Files:**
- Modify: `scenes/player/player.gd`

- [ ] **Step 1: Read player.gd to understand structure**

- [ ] **Step 2: Add PlayerStats as child**

In `_ready()`, add:
```gdscript
# Add PlayerStats component
var player_stats = PlayerStats.new()
player_stats.name = "PlayerStats"
add_child(player_stats)
```

- [ ] **Step 3: Apply stat multipliers to player**

Create method to apply stats:
```gdscript
func apply_stat_bonuses() -> void:
	var stats = $PlayerStats as PlayerStats
	if not stats:
		return

	# Apply max HP
	if character_data:
		var base_max_hp = character_data.max_health
		max_health = stats.get_max_hp(base_max_hp)
		# Update health if needed
		health = min(health, max_health)

	# Apply move speed
	if character_data:
		var base_speed = character_data.move_speed
		move_speed = stats.get_move_speed(base_speed)
```

Call this method in `_ready()` and when stats change.

- [ ] **Step 4: Apply damage multiplier to weapons**

In player_inventory.gd recalculate_synergies(), apply PlayerStats damage multiplier:
```gdscript
# After applying synergies to weapon
var player = get_parent()
if player and player.has_node("PlayerStats"):
	var player_stats = player.get_node("PlayerStats") as PlayerStats
	var extra_damage_mult = player_stats.get_damage_multiplier()
	# weapon already has synergies applied, multiply further
```

Actually, better approach: modify weapon_base.gd to query PlayerStats.

- [ ] **Step 5: Commit**

```bash
git add scenes/player/player.gd
git commit -m "feat(player): integrate PlayerStats component"
```

---

## Task F6: Create StatUpgradeScreen UI

**Files:**
- Create: `scenes/ui/stat_upgrade_screen.tscn`
- Create: `scenes/ui/stat_upgrade_screen.gd`

- [ ] **Step 1: Create UI scene in Godot**

Create new scene:
1. Root: Control node (full screen)
2. Add ColorRect for background overlay
3. Add VBoxContainer for layout
4. Add Label: "LEVEL UP! Choose 1 stat upgrade:"
5. Add HBoxContainer with 3 containers for options
6. Each option: VBoxContainer with Label (stat name), Label (value), Label (rarity), Button (SELECT)

Save as `stat_upgrade_screen.tscn`

- [ ] **Step 2: Create script logic**

```gdscript
extends Control
## Stat upgrade selection screen shown on level-up

@onready var option_containers = [$Option1, $Option2, $Option3]
var current_options: Array[Dictionary] = []

func _ready():
	hide()
	# Wait to be shown by game manager

func show_upgrade_selection() -> void:
	# Generate 3 random stat options
	current_options = _generate_stat_options(3)

	# Display options
	for i in range(3):
		_display_option(i, current_options[i])

	show()

func _generate_stat_options(count: int) -> Array[Dictionary]:
	# TODO: Load stat pool and select random stats
	# For now, hardcode examples
	var options = []
	var stat_types = [5, 9, 0]  # DAMAGE, MOVE_SPEED, MAX_HP

	for i in range(count):
		var stat_data = {
			"stat_type": stat_types[i],
			"display_name": ["Damage", "Move Speed", "Max HP"][i],
			"rarity": i,  # 0=COMMON, 1=UNCOMMON, 2=RARE
			"value": [0.08, 0.10, 30.0][i]
		}
		options.append(stat_data)

	return options

func _display_option(index: int, option: Dictionary) -> void:
	var container = option_containers[index]
	# Set labels and connect button
	# TODO: Implement full UI logic

func _on_option_selected(index: int) -> void:
	var option = current_options[index]

	# Apply stat to player
	var player = get_tree().get_first_node_in_group("player")
	if player and player.has_node("PlayerStats"):
		var stats = player.get_node("PlayerStats") as PlayerStats
		stats.apply_stat_upgrade(option.stat_type, option.value)

	# Decrement pending picks
	ExperienceManager.pending_stat_picks -= 1

	# Check if more picks needed
	if ExperienceManager.pending_stat_picks > 0:
		show_upgrade_selection()  # Show next selection
	else:
		hide()
		# Continue to shop
		GameManager.set_state(GameManager.GameState.SHOP)
```

- [ ] **Step 3: Commit**

```bash
git add scenes/ui/stat_upgrade_screen.tscn scenes/ui/stat_upgrade_screen.gd
git commit -m "feat(ui): create stat upgrade selection screen"
```

---

# PHASE G: Shop Refresh System

## Task G1: Add Shop Refresh to ShopSystem

**Files:**
- Modify: `scripts/systems/shop_system.gd`

- [ ] **Step 1: Read shop_system.gd structure**

- [ ] **Step 2: Add refresh tracking**

Add these variables:
```gdscript
var refresh_count: int = 0
var weapon_pool: Array[WeaponData] = []
```

- [ ] **Step 3: Add weapon pool loading**

```gdscript
func _ready():
	_load_weapon_pool()
	# ... existing code

func _load_weapon_pool() -> void:
	weapon_pool = [
		load("res://resources/weapons/pistol.tres"),
		load("res://resources/weapons/smg.tres"),
		load("res://resources/weapons/shotgun.tres"),
		load("res://resources/weapons/assault_rifle.tres"),
		load("res://resources/weapons/sniper.tres"),
		load("res://resources/weapons/flamethrower.tres"),
		load("res://resources/weapons/grenade_launcher.tres"),
		load("res://resources/weapons/minigun.tres")
	]
	print("[ShopSystem] Loaded %d weapons" % weapon_pool.size())
```

- [ ] **Step 4: Add refresh cost calculation**

```gdscript
func get_refresh_cost() -> int:
	if refresh_count == 0:
		return 0  # First refresh free

	var wave = GameManager.current_wave
	return wave * 5 * refresh_count
```

- [ ] **Step 5: Add refresh method**

```gdscript
func purchase_refresh(owned_weapons: Array[WeaponData]) -> bool:
	var cost = get_refresh_cost()

	# Check gold (assuming player_gold variable exists)
	if player_gold < cost:
		print("[ShopSystem] Not enough gold for refresh (need %d)" % cost)
		return false

	# Deduct gold
	player_gold -= cost
	refresh_count += 1

	# Refresh shop items
	refresh_shop(owned_weapons)

	print("[ShopSystem] Shop refreshed (cost: %d, count: %d)" % [cost, refresh_count])
	return true

func refresh_shop(owned_weapons: Array[WeaponData]) -> void:
	shop_items.clear()

	# Filter out owned weapons
	var available = []
	for weapon in weapon_pool:
		if not owned_weapons.has(weapon):
			available.append(weapon)

	# Shuffle and pick 4
	available.shuffle()
	for i in range(min(4, available.size())):
		shop_items.append(available[i])

	print("[ShopSystem] Shop refreshed with %d items" % shop_items.size())

func reset_refresh_count() -> void:
	refresh_count = 0
```

- [ ] **Step 6: Commit**

```bash
git add scripts/systems/shop_system.gd
git commit -m "feat(shop): add refresh mechanism with wave-scaling costs"
```

---

## Task G2: Add Refresh Button to Shop UI

**Files:**
- Modify: `scenes/ui/shop_panel.gd`
- Modify: `scenes/ui/shop_panel.tscn`

- [ ] **Step 1: Add refresh button to UI**

In Godot editor, open `shop_panel.tscn`:
1. Add Button node named "RefreshButton"
2. Position it prominently
3. Set text: "Refresh (Free)"
4. Connect pressed signal to script

- [ ] **Step 2: Add script logic**

```gdscript
@onready var refresh_button: Button = $RefreshButton

func _ready():
	# ... existing code
	if refresh_button:
		refresh_button.pressed.connect(_on_refresh_pressed)

func _on_refresh_pressed() -> void:
	var shop = get_node_or_null("/root/ShopSystem")
	if not shop:
		return

	# Get player inventory
	var player = get_tree().get_first_node_in_group("player")
	var owned_weapons = []
	if player and player.has_node("Inventory"):
		var inventory = player.get_node("Inventory")
		if inventory.has("weapon_data_list"):
			owned_weapons = inventory.weapon_data_list

	# Purchase refresh
	if shop.purchase_refresh(owned_weapons):
		_update_shop_display()
		_update_refresh_button()

func _update_refresh_button() -> void:
	if not refresh_button:
		return

	var shop = get_node_or_null("/root/ShopSystem")
	if not shop:
		return

	var cost = shop.get_refresh_cost()
	if cost == 0:
		refresh_button.text = "Refresh (Free)"
	else:
		refresh_button.text = "Refresh (%d gold)" % cost
```

- [ ] **Step 3: Commit**

```bash
git add scenes/ui/shop_panel.gd scenes/ui/shop_panel.tscn
git commit -m "feat(ui): add refresh button to shop panel"
```

---

# PHASE H: Wave Configuration System

## Task H1: Create WaveConfig Resource

**Files:**
- Create: `resources/waves/wave_config.gd`

- [ ] **Step 1: Create WaveConfig resource class**

```gdscript
extends Resource
class_name WaveConfig
## Configuration for a specific wave

@export var wave_number: int = 1
@export var enemy_count: int = 15
@export var spawn_rate: float = 1.5  # Seconds between spawns
@export var spawn_distance_min: float = 300.0
@export var spawn_distance_max: float = 500.0

# Enemy multipliers
@export var enemy_health_mult: float = 1.0
@export var enemy_damage_mult: float = 1.0
@export var enemy_speed_mult: float = 1.0

# Reward multipliers
@export var gold_mult: float = 1.0
@export var xp_mult: float = 1.0

# Shop settings
@export var shop_refresh_cost_increment: int = 5  # Cost per refresh
```

- [ ] **Step 2: Verify syntax**

Open in Godot editor
Expected: No errors

- [ ] **Step 3: Commit**

```bash
git add resources/waves/wave_config.gd
git commit -m "feat(waves): create WaveConfig resource class"
```

---

## Task H2: Create Wave Config Resources

**Files:**
- Create directory: `resources/waves/`
- Create 5 wave config .tres files

- [ ] **Step 1: Create directory**

```bash
mkdir -p "D:/Work/VibeGameing/mini-game/resources/waves"
```

- [ ] **Step 2: Create wave configs**

**wave_1.tres:**
- wave_number: 1
- enemy_count: 15
- enemy_health_mult: 1.0
- gold_mult: 1.0
- xp_mult: 1.0
- shop_refresh_cost_increment: 5

**wave_2.tres:**
- wave_number: 2
- enemy_count: 25
- enemy_health_mult: 1.2
- enemy_damage_mult: 1.1
- gold_mult: 1.2
- xp_mult: 1.0
- shop_refresh_cost_increment: 10

**wave_3.tres:**
- wave_number: 3
- enemy_count: 35
- enemy_health_mult: 1.5
- enemy_damage_mult: 1.2
- gold_mult: 1.5
- xp_mult: 1.0
- shop_refresh_cost_increment: 15

**wave_5.tres:**
- wave_number: 5
- enemy_count: 50
- enemy_health_mult: 2.0
- enemy_damage_mult: 1.5
- enemy_speed_mult: 1.1
- gold_mult: 2.0
- xp_mult: 1.0
- shop_refresh_cost_increment: 25

**wave_10.tres:**
- wave_number: 10
- enemy_count: 100
- enemy_health_mult: 4.0
- enemy_damage_mult: 2.5
- enemy_speed_mult: 1.3
- gold_mult: 3.0
- xp_mult: 1.0
- shop_refresh_cost_increment: 50

- [ ] **Step 3: Commit**

```bash
git add resources/waves/
git commit -m "feat(waves): create wave configuration resources for waves 1-10"
```

---

## Task H3: Integrate WaveConfig with WaveManager

**Files:**
- Modify: `scripts/systems/wave_manager.gd`

- [ ] **Step 1: Add wave config loading**

```gdscript
var wave_configs: Dictionary = {}
var current_wave_config: WaveConfig = null

func _ready():
	_load_wave_configs()
	# ... existing code

func _load_wave_configs() -> void:
	# Load available wave configs
	wave_configs[1] = load("res://resources/waves/wave_1.tres")
	wave_configs[2] = load("res://resources/waves/wave_2.tres")
	wave_configs[3] = load("res://resources/waves/wave_3.tres")
	wave_configs[5] = load("res://resources/waves/wave_5.tres")
	wave_configs[10] = load("res://resources/waves/wave_10.tres")

	print("[WaveManager] Loaded %d wave configs" % wave_configs.size())
```

- [ ] **Step 2: Use config in wave start**

```gdscript
func _start_wave() -> void:
	# Load config for current wave (or closest)
	current_wave_config = _get_wave_config(current_wave)

	if current_wave_config:
		print("[WaveManager] Wave %d config: %d enemies, %.1fx health" %
			[current_wave, current_wave_config.enemy_count, current_wave_config.enemy_health_mult])

	# ... rest of existing code

func _get_wave_config(wave_num: int) -> WaveConfig:
	# Try exact match
	if wave_configs.has(wave_num):
		return wave_configs[wave_num]

	# Find closest lower config
	var closest_wave = 1
	for config_wave in wave_configs.keys():
		if config_wave <= wave_num and config_wave > closest_wave:
			closest_wave = config_wave

	return wave_configs.get(closest_wave, wave_configs[1])
```

- [ ] **Step 3: Pass config to spawn system**

In wave start, pass config to SpawnSystem.

- [ ] **Step 4: Handle stat upgrades in wave end**

```gdscript
func _end_wave() -> void:
	print("[WaveManager] Wave ended")

	# Check for level-ups
	if ExperienceManager.pending_stat_picks > 0:
		GameManager.set_state(GameManager.GameState.STAT_UPGRADE)
		# StatUpgradeScreen will handle picks, then transition to SHOP
	else:
		# Go directly to shop
		GameManager.set_state(GameManager.GameState.SHOP)

	# ... rest of shop opening logic
```

- [ ] **Step 5: Reset shop refresh on wave start**

```gdscript
func _start_wave() -> void:
	# ... existing code

	# Reset shop refresh counter
	var shop = get_node_or_null("/root/ShopSystem")
	if shop and shop.has_method("reset_refresh_count"):
		shop.reset_refresh_count()
```

- [ ] **Step 6: Commit**

```bash
git add scripts/systems/wave_manager.gd
git commit -m "feat(waves): integrate WaveConfig with wave progression"
```

---

## Verification Checklist

After completing Cycle 2:

- [ ] Kill enemy → gain 1 XP
- [ ] XP bar displays and fills correctly
- [ ] Level up after ~15 kills
- [ ] Stat upgrade screen appears on level-up
- [ ] Can select 1 of 3 random stats
- [ ] Stat applies to player (damage, speed, HP visible)
- [ ] Multiple level-ups queue multiple selections
- [ ] Shop opens after stat selection
- [ ] Refresh button shows "Free" first time
- [ ] Refresh button cost increases: wave × 5 × count
- [ ] Refresh regenerates 4 random weapons
- [ ] Wave configs control enemy count
- [ ] Enemy health/damage scale per wave

---

## Notes

- Cycle 2 builds on Cycle 1's foundation
- Each phase is independently testable
- UI creation requires Godot editor
- Balance tuning expected after playtesting
- Estimated time: 10-14 hours

