extends Node
## Manages player weapons and equipped items
class_name PlayerInventory

var weapons: Array[Node] = []
var weapon_data_list: Array = []  # Stores WeaponData resources
const MAX_WEAPONS: int = 6
var current_weapon_slot: int = 0
var aim_direction: Vector2 = Vector2.RIGHT

@export var starting_weapon_data: WeaponData = null

func _ready() -> void:
	print("[PlayerInventory] Initializing inventory")

## Add default weapon
func add_default_weapon() -> void:
	print("[PlayerInventory] Adding default weapon")
	if not ResourceLoader.exists("res://scenes/weapons/weapon_base.tscn"):
		push_error("[PlayerInventory] Weapon scene not found")
		return

	var weapon_scene = load("res://scenes/weapons/weapon_base.tscn")
	var weapon = weapon_scene.instantiate()
	add_child(weapon)
	weapons.append(weapon)
	weapon_data_list.append(null)  # Keep arrays in sync
	print("[PlayerInventory] Added weapon, total: ", weapons.size())

## Add a weapon to inventory (legacy method, redirects to add_weapon_from_data)
func add_weapon(weapon_data: WeaponData) -> void:
	add_weapon_from_data(weapon_data)

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

		# Skip weapons without data
		if weapon_data == null:
			continue

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


## Set aiming direction for all weapons
func set_aim_direction(direction: Vector2) -> void:
	if direction.length() > 0:
		aim_direction = direction.normalized()
		for weapon in weapons:
			if weapon.has_method("set_aim_direction"):
				weapon.set_aim_direction(aim_direction)
	else:
		print("[PlayerInventory] Warning: Invalid aim direction")

## Fire all weapons
func fire(origin_position: Vector2) -> void:
	for weapon in weapons:
		if weapon.has_method("fire"):
			weapon.fire(origin_position, aim_direction)

## Get weapon in slot
func get_weapon(slot: int) -> Node:
	if slot >= 0 and slot < weapons.size():
		return weapons[slot]
	return null

## Get current weapon
func get_current_weapon() -> Node:
	return get_weapon(current_weapon_slot)

## Remove weapon from inventory
func remove_weapon(slot: int) -> void:
	if slot >= 0 and slot < weapons.size():
		weapons[slot].queue_free()
		weapons.remove_at(slot)
		weapon_data_list.remove_at(slot)

		# Recalculate synergies after removal
		recalculate_synergies()
