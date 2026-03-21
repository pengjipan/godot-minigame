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
@export var tag_bonuses: Dictionary = {}  # e.g., {"RAPID_FIRE": 0.20}
@export var tag_penalties: Dictionary = {}  # e.g., {"HEAVY": -0.15}

## Get multiplier for a specific tag
func get_tag_multiplier(tag: String) -> float:
	var bonus = tag_bonuses.get(tag, 0.0)
	var penalty = tag_penalties.get(tag, 0.0)
	return 1.0 + bonus + penalty

## Get all stats as dictionary
func get_stats() -> Dictionary:
	return {
		"character_name": character_name,
		"max_health": max_health,
		"move_speed": move_speed,
		"attack_speed": attack_speed,
		"weapon_damage": weapon_damage
	}
