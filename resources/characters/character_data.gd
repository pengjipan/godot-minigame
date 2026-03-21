extends Resource
## Character data definition
class_name CharacterData

@export var character_name: String = "Potato"
@export var description: String = "A brave potato"
@export var max_health: int = 100
@export var move_speed: float = 200.0
@export var attack_speed: float = 1.0
@export var weapon_damage: int = 10
@export var starting_weapon: String = "res://scenes/weapons/weapon_base.tscn"
@export var icon_path: String = ""

## Get all stats as dictionary
func get_stats() -> Dictionary:
	return {
		"character_name": character_name,
		"max_health": max_health,
		"move_speed": move_speed,
		"attack_speed": attack_speed,
		"weapon_damage": weapon_damage
	}
