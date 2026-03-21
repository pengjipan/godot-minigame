extends Resource
## Enemy data definition
class_name EnemyData

@export var enemy_name: String = "Basic Enemy"
@export var description: String = ""
@export var max_health: int = 20
@export var move_speed: float = 100.0
@export var damage: int = 5
@export var experience_reward: int = 10
@export var gold_reward: int = 5
@export var enemy_scene: String = "res://scenes/enemies/enemy_base.tscn"
@export var sprite_path: String = ""
@export var ai_type: String = "melee"  # melee or ranged

## Create instance with stats applied
func create_instance() -> CharacterBody2D:
	if not ResourceLoader.exists(enemy_scene):
		push_error("Enemy scene not found: ", enemy_scene)
		return null

	var enemy = load(enemy_scene).instantiate() as CharacterBody2D
	return enemy
