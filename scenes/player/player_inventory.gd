extends Node
## Manages player weapons and equipped items
class_name PlayerInventory

var weapons: Array[Node] = []
var current_weapon_slot: int = 0
var aim_direction: Vector2 = Vector2.RIGHT

@export var starting_weapon_data: WeaponData = null

func _ready() -> void:
	# Equip starting weapon
	if starting_weapon_data:
		add_weapon(starting_weapon_data)

## Add a weapon to inventory
func add_weapon(weapon_data: WeaponData) -> void:
	if not ResourceLoader.exists(weapon_data.weapon_data.weapon_data):
		push_error("Weapon scene not found: ", weapon_data.weapon_scene)
		return

	var weapon_scene = load("res://scenes/weapons/weapon_base.tscn")
	var weapon = weapon_scene.instantiate()
	weapon.set_weapon_data(weapon_data)
	add_child(weapon)
	weapons.append(weapon)

## Set aiming direction for all weapons
func set_aim_direction(direction: Vector2) -> void:
	aim_direction = direction.normalized()
	for weapon in weapons:
		if weapon.has_method("set_aim_direction"):
			weapon.set_aim_direction(aim_direction)

## Fire all weapons
func fire() -> void:
	for weapon in weapons:
		if weapon.has_method("fire"):
			weapon.fire(global_position, aim_direction)

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
