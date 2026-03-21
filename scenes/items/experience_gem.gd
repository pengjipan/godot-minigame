extends Area2D
## Experience gem that player can pick up
class_name ExperienceGem

@export var float_speed: float = 2.0
@export var float_height: float = 30.0

var value: int = 10
var start_position: Vector2 = Vector2.ZERO
var float_time: float = 0.0
var collected: bool = false

func _ready() -> void:
	area_entered.connect(_on_area_entered)
	start_position = global_position

func _process(delta: float) -> void:
	if collected:
		return

	# Float effect
	float_time += delta
	global_position.y = start_position.y - sin(float_time * float_speed) * float_height

	# Move toward player
	var player_nodes = get_tree().get_nodes_in_group("player")
	if player_nodes.size() > 0:
		var player = player_nodes[0]
		var distance = global_position.distance_to(player.global_position)

		# Auto-attract when close
		if distance < 150:
			global_position = global_position.lerp(player.global_position, 0.1)

## Set gem value
func set_value(amount: int) -> void:
	value = amount

## Called when player touches the gem
func _on_area_entered(area: Area2D) -> void:
	var parent = area.get_parent()
	if parent and parent.is_in_group("player"):
		_collect()

## Collect the gem
func _collect() -> void:
	if collected:
		return

	collected = true

	# Add experience to player
	var exp_system = get_tree().root.get_node_or_null("ExperienceSystem")
	if exp_system and exp_system.has_method("add_experience"):
		exp_system.add_experience(value)
	else:
		# Fallback: emit signal
		EventBus.player_experience_gained.emit(value)

	queue_free()
