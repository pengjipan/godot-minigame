extends Node
## Manages player experience and leveling
class_name ExperienceSystem

var current_experience: int = 0
var current_level: int = 1
var experience_threshold: int = 100

func _ready() -> void:
	EventBus.enemy_died.connect(_on_enemy_died)
	EventBus.experience_updated.emit(current_experience, experience_threshold)

func _process(delta: float) -> void:
	pass

## Called when enemy dies
func _on_enemy_died(enemy: Node, position: Vector2) -> void:
	# Experience gems are picked up by player, not added directly
	pass

## Add experience to player
func add_experience(amount: int) -> void:
	current_experience += amount
	EventBus.experience_updated.emit(current_experience, experience_threshold)
	EventBus.player_experience_gained.emit(amount)

	# Check for level up
	if current_experience >= experience_threshold:
		_level_up()

## Level up player
func _level_up() -> void:
	current_experience = 0
	current_level += 1
	experience_threshold = current_level * 100

	EventBus.player_leveled_up.emit(current_level)
	EventBus.experience_updated.emit(0, experience_threshold)

	# Pause game for upgrade selection
	GameManager.set_state(GameManager.GameState.LEVEL_UP)

## Get current level
func get_level() -> int:
	return current_level

## Get current experience
func get_experience() -> int:
	return current_experience

## Get experience threshold
func get_threshold() -> int:
	return experience_threshold

## Get experience percent (0.0 to 1.0)
func get_experience_percent() -> float:
	return float(current_experience) / float(experience_threshold)
