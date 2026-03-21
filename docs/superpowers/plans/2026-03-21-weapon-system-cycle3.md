# Weapon System Cycle 3: Initial Weapon Selection & Special Mechanics Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implement initial weapon selection screen with class recommendations, grenade launcher explosion mechanics, and sustained fire optimization for flamethrower/minigun.

**Architecture:** Recommendation system scores weapons by class bonuses, explosion system uses Area2D collision detection on impact, sustained weapons use infinite ammo logic already in weapon_base.

**Tech Stack:** Godot 4.5 (GDScript), UI scenes, Area2D physics, Signal-based events

---

## Cycle 3 Scope

This plan completes the weapon system with:
- **Phase I**: Initial Weapon Selection (UI after character select)
- **Phase J**: Grenade Launcher Explosions (Area damage on impact)
- **Phase K**: Sustained Fire Verification (Ensure Flamethrower/Minigun work correctly)

**Dependencies:** Requires Cycles 1 & 2 complete.

---

## File Structure Overview

### New Files to Create

**UI:**
- `scenes/ui/starting_weapon_screen.tscn` + `.gd` - Initial weapon selection
- `scenes/weapons/explosion.tscn` + `.gd` - Explosion effect (optional scene)

### Files to Modify

**Menus:**
- `scenes/menus/character_select.gd` - Redirect to weapon selection
- `autoload/game_manager.gd` - Add INITIAL_WEAPON_SELECT state

**Weapons:**
- `scenes/weapons/projectile.gd` - Add explosion logic
- `scenes/weapons/weapon_base.gd` - Verify sustained fire logic

**Game:**
- `scenes/game/game_world.gd` - Initialize with selected weapon

---

# PHASE I: Initial Weapon Selection

## Task I1: Add INITIAL_WEAPON_SELECT Game State

**Files:**
- Modify: `autoload/game_manager.gd`

- [ ] **Step 1: Read game_manager.gd to find GameState enum**

- [ ] **Step 2: Add new state to enum**

In the GameState enum, add:
```gdscript
INITIAL_WEAPON_SELECT,  # After character selection, before game start
```

- [ ] **Step 3: Add selected weapon tracking**

Add these variables:
```gdscript
var selected_starting_weapon: WeaponData = null
var selected_character: CharacterData = null
```

- [ ] **Step 4: Verify syntax**

Open in Godot editor
Expected: No errors

- [ ] **Step 5: Commit**

```bash
git add autoload/game_manager.gd
git commit -m "feat(game): add INITIAL_WEAPON_SELECT state and weapon selection tracking"
```

---

## Task I2: Create StartingWeaponScreen UI

**Files:**
- Create: `scenes/ui/starting_weapon_screen.tscn`
- Create: `scenes/ui/starting_weapon_screen.gd`

- [ ] **Step 1: Create StartingWeaponScreen script**

```gdscript
extends Control
## Initial weapon selection screen after character selection

@onready var weapon_grid = $Panel/VBoxContainer/WeaponGrid
@onready var character_label = $Panel/VBoxContainer/CharacterLabel

var all_weapons: Array[WeaponData] = []
var recommended_weapons: Array[WeaponData] = []
var character_data: CharacterData = null

func _ready():
	hide()
	_load_all_weapons()

func _load_all_weapons() -> void:
	all_weapons = [
		load("res://resources/weapons/pistol.tres"),
		load("res://resources/weapons/smg.tres"),
		load("res://resources/weapons/shotgun.tres"),
		load("res://resources/weapons/assault_rifle.tres"),
		load("res://resources/weapons/sniper.tres"),
		load("res://resources/weapons/flamethrower.tres"),
		load("res://resources/weapons/grenade_launcher.tres"),
		load("res://resources/weapons/minigun.tres")
	]

## Show weapon selection for given character
func show_for_character(char_data: CharacterData) -> void:
	character_data = char_data
	character_label.text = "Choose Starting Weapon for %s" % char_data.character_name

	# Calculate recommendations
	recommended_weapons = _get_recommended_weapons(char_data)

	# Display weapons
	_display_weapons()

	show()

## Calculate recommended weapons based on class bonuses
func _get_recommended_weapons(char_data: CharacterData) -> Array[WeaponData]:
	var scored_weapons = []

	# Score each weapon based on tag bonuses/penalties
	for weapon in all_weapons:
		var score = 0.0
		for tag in weapon.weapon_tags:
			var bonus = char_data.tag_bonuses.get(tag, 0.0)
			var penalty = char_data.tag_penalties.get(tag, 0.0)
			score += bonus + penalty

		scored_weapons.append({"weapon": weapon, "score": score})

	# Sort by score (highest first)
	scored_weapons.sort_custom(func(a, b): return a.score > b.score)

	# Return top 3
	var recommendations: Array[WeaponData] = []
	for i in range(min(3, scored_weapons.size())):
		recommendations.append(scored_weapons[i].weapon)

	return recommendations

func _display_weapons() -> void:
	# Clear existing children
	for child in weapon_grid.get_children():
		child.queue_free()

	# Display recommended weapons first (highlighted)
	for weapon in recommended_weapons:
		_create_weapon_card(weapon, true)

	# Display other weapons
	for weapon in all_weapons:
		if not recommended_weapons.has(weapon):
			_create_weapon_card(weapon, false)

func _create_weapon_card(weapon_data: WeaponData, is_recommended: bool) -> void:
	var card = VBoxContainer.new()

	# Add recommended indicator
	if is_recommended:
		var star_label = Label.new()
		star_label.text = "⭐ RECOMMENDED"
		card.add_child(star_label)

	# Weapon name
	var name_label = Label.new()
	name_label.text = weapon_data.weapon_name
	card.add_child(name_label)

	# Tags
	var tags_label = Label.new()
	tags_label.text = " ".join(weapon_data.weapon_tags)
	card.add_child(tags_label)

	# Stats
	var stats_label = Label.new()
	stats_label.text = "DMG: %d  Fire Rate: %.1f/s" % [weapon_data.damage, weapon_data.fire_rate]
	card.add_child(stats_label)

	# Show class bonus/penalty
	if character_data:
		var bonus_text = _get_class_bonus_text(weapon_data)
		if bonus_text != "":
			var bonus_label = Label.new()
			bonus_label.text = bonus_text
			card.add_child(bonus_label)

	# Select button
	var button = Button.new()
	button.text = "SELECT"
	button.pressed.connect(_on_weapon_selected.bind(weapon_data))
	card.add_child(button)

	weapon_grid.add_child(card)

func _get_class_bonus_text(weapon_data: WeaponData) -> String:
	if not character_data:
		return ""

	var bonus_texts = []
	for tag in weapon_data.weapon_tags:
		var bonus = character_data.tag_bonuses.get(tag, 0.0)
		var penalty = character_data.tag_penalties.get(tag, 0.0)

		if bonus > 0.0:
			bonus_texts.append("💡 +%.0f%% for %s" % [bonus * 100, tag])
		elif penalty < 0.0:
			bonus_texts.append("⚠️ %.0f%% for %s" % [penalty * 100, tag])

	return "\n".join(bonus_texts)

func _on_weapon_selected(weapon_data: WeaponData) -> void:
	print("[StartingWeaponScreen] Selected: %s" % weapon_data.weapon_name)

	# Store in GameManager
	GameManager.selected_starting_weapon = weapon_data

	# Transition to game
	GameManager.set_state(GameManager.GameState.PLAYING)

	hide()
```

- [ ] **Step 2: Create scene file**

Create `starting_weapon_screen.tscn` as a full-screen Control with:
- Panel container
- VBoxContainer with CharacterLabel
- GridContainer for weapon cards (named "WeaponGrid")

Use Godot text format for .tscn file.

- [ ] **Step 3: Commit**

```bash
git add scenes/ui/starting_weapon_screen.tscn scenes/ui/starting_weapon_screen.gd
git commit -m "feat(ui): create initial weapon selection screen with recommendations"
```

---

## Task I3: Update Character Select Flow

**Files:**
- Modify: `scenes/menus/character_select.gd` (or wherever character selection happens)

- [ ] **Step 1: Find where character is selected**

Look for character selection logic (likely a button click handler).

- [ ] **Step 2: Redirect to weapon selection**

Instead of going directly to game, transition to weapon selection:
```gdscript
func _on_character_selected(char_data: CharacterData) -> void:
	# Store character
	GameManager.selected_character = char_data

	# Go to weapon selection
	GameManager.set_state(GameManager.GameState.INITIAL_WEAPON_SELECT)

	# Load weapon selection screen
	var weapon_screen = load("res://scenes/ui/starting_weapon_screen.tscn").instantiate()
	get_tree().root.add_child(weapon_screen)
	weapon_screen.show_for_character(char_data)
```

- [ ] **Step 3: Commit**

```bash
git add scenes/menus/character_select.gd
git commit -m "feat(menus): redirect character select to weapon selection screen"
```

---

## Task I4: Initialize Game with Selected Weapon

**Files:**
- Modify: `scenes/game/game_world.gd`

- [ ] **Step 1: Read game_world.gd initialization**

Find where player/inventory is initialized.

- [ ] **Step 2: Add selected weapon initialization**

After player spawns, add:
```gdscript
func _ready():
	# ... existing code ...

	# Initialize with selected starting weapon
	if GameManager.selected_starting_weapon:
		var player = get_tree().get_first_node_in_group("player")
		if player and player.has_node("Inventory"):
			var inventory = player.get_node("Inventory")
			if inventory.has_method("add_weapon_from_data"):
				inventory.add_weapon_from_data(GameManager.selected_starting_weapon)
				print("[GameWorld] Started with weapon: %s" % GameManager.selected_starting_weapon.weapon_name)

		# Clear selection for next run
		GameManager.selected_starting_weapon = null
```

- [ ] **Step 3: Commit**

```bash
git add scenes/game/game_world.gd
git commit -m "feat(game): initialize player with selected starting weapon"
```

---

# PHASE J: Grenade Launcher Explosions

## Task J1: Add Explosion Logic to Projectile

**Files:**
- Modify: `scenes/weapons/projectile.gd`

- [ ] **Step 1: Add explosion_radius field**

Add to projectile variables:
```gdscript
var explosion_radius: float = 0.0
```

- [ ] **Step 2: Update initialize method**

Add explosion_radius parameter:
```gdscript
func initialize(dir: Vector2, spd: float, dmg: int, pierce: int = 1, knockback_force: float = 200.0, explosion_rad: float = 0.0) -> void:
	# ... existing code ...
	explosion_radius = explosion_rad
```

- [ ] **Step 3: Add explosion on collision**

In `_on_area_entered()`, after dealing damage, check for explosion:
```gdscript
func _on_area_entered(area: Area2D) -> void:
	# ... existing damage code ...

	# Check for explosion
	if explosion_radius > 0.0:
		_create_explosion()
		return  # Explosion destroys projectile immediately

func _create_explosion() -> void:
	var explosion_area = Area2D.new()
	explosion_area.global_position = global_position
	explosion_area.collision_layer = 0
	explosion_area.collision_mask = 4  # Enemy layer

	var shape = CircleShape2D.new()
	shape.radius = explosion_radius

	var collision = CollisionShape2D.new()
	collision.shape = shape
	explosion_area.add_child(collision)

	# Add to scene
	get_parent().add_child(explosion_area)

	# Wait for physics frame to detect overlaps
	await get_tree().physics_frame

	# Damage all enemies in radius
	var overlapping = explosion_area.get_overlapping_areas()
	for area in overlapping:
		if area.name == "HurtboxComponent":
			var parent = area.get_parent()
			if parent and parent.is_in_group("enemies"):
				if area.has_method("take_damage"):
					area.take_damage(damage, global_position)
					print("[Projectile] Explosion hit: %s" % parent.name)

	# Clean up
	explosion_area.queue_free()
	queue_free()
```

- [ ] **Step 4: Update weapon_base to pass explosion_radius**

In `weapon_base.gd`, find where projectile.initialize() is called and add explosion_radius parameter from weapon_data.

- [ ] **Step 5: Test grenades**

Equip grenade launcher, fire, verify explosion hits multiple enemies.

- [ ] **Step 6: Commit**

```bash
git add scenes/weapons/projectile.gd scenes/weapons/weapon_base.gd
git commit -m "feat(weapons): add explosion mechanics for grenade launcher"
```

---

# PHASE K: Sustained Fire Verification

## Task K1: Verify Sustained Weapons Work Correctly

**Files:**
- Read: `scenes/weapons/weapon_base.gd`

- [ ] **Step 1: Verify sustained fire logic exists**

Check that weapon_base.gd handles is_sustained:
- Magazine_size set to INFINITE_AMMO (-1)
- current_ammo set to large number
- Reload logic skipped for sustained weapons

Expected: Logic already exists from Cycle 1 (lines 73-75 after weapon_data loading).

- [ ] **Step 2: Test Flamethrower**

In game:
1. Get flamethrower (is_sustained = true)
2. Fire continuously
3. Verify: Never reloads, fires 3 projectiles at 20° spread

Expected: Continuous fire with no reload interruptions.

- [ ] **Step 3: Test Minigun**

In game:
1. Get minigun (is_sustained = true)
2. Fire continuously at 12 shots/sec
3. Verify: Never reloads, fires with slight 3° spread

Expected: Extremely fast continuous fire.

- [ ] **Step 4: Document findings**

If issues found, fix them. If working correctly, document in code comment:
```gdscript
# Sustained weapons (Flamethrower, Minigun) use magazine_size = INFINITE_AMMO
# This skips reload logic and allows continuous fire
```

- [ ] **Step 5: Commit (if changes made)**

```bash
git add scenes/weapons/weapon_base.gd
git commit -m "docs(weapons): document sustained fire mechanics"
```

---

## Task K2: Add Visual Effect for Grenade Explosions (Optional Polish)

**Files:**
- Create: `scenes/weapons/explosion_effect.tscn` (optional)

- [ ] **Step 1: Create simple explosion visual**

In Godot editor:
1. Create new scene with Node2D root
2. Add Sprite2D or AnimatedSprite2D for explosion visual
3. Add Timer to auto-destroy after 0.5 seconds
4. Save as `explosion_effect.tscn`

- [ ] **Step 2: Spawn effect in projectile**

In `projectile.gd` `_create_explosion()`, add:
```gdscript
# Spawn visual effect (optional)
if ResourceLoader.exists("res://scenes/weapons/explosion_effect.tscn"):
	var effect = load("res://scenes/weapons/explosion_effect.tscn").instantiate()
	effect.global_position = global_position
	get_parent().add_child(effect)
```

- [ ] **Step 3: Commit**

```bash
git add scenes/weapons/explosion_effect.tscn scenes/weapons/projectile.gd
git commit -m "feat(vfx): add visual effect for grenade explosions"
```

---

## Verification Checklist

After completing Cycle 3:

- [ ] Character selection → weapon selection → game start flow works
- [ ] Weapon selection shows all 8 weapons
- [ ] Recommended weapons highlighted (top 3 by class bonus)
- [ ] Class bonuses displayed on weapon cards
- [ ] Selected weapon equipped at game start
- [ ] Grenade launcher creates explosions on impact
- [ ] Explosions damage all enemies in 80-unit radius
- [ ] Flamethrower fires 3 streams continuously with no reload
- [ ] Minigun fires at 12/sec continuously with no reload
- [ ] No crashes or errors

---

## Notes

- Cycle 3 completes the full weapon system
- Initial weapon selection gives players immediate class feedback
- Explosion mechanics make grenade launcher feel impactful
- Sustained fire verification ensures special weapons work as designed
- Estimated time: 4-6 hours

