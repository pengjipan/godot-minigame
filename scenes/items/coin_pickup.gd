extends Area2D
## Gold coin that player can pick up
class_name CoinPickup

@export var float_speed: float = 3.0
@export var float_height: float = 20.0
@export var collection_speed: float = 0.15

var value: int = 5
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
	global_position.y = start_position.y + sin(float_time * float_speed) * float_height

	# Move toward player
	var player_nodes = get_tree().get_nodes_in_group("player")
	if player_nodes.size() > 0:
		var player = player_nodes[0]
		var distance = global_position.distance_to(player.global_position)

		# Auto-attract when close
		if distance < 200:
			global_position = global_position.lerp(player.global_position, collection_speed)
			if distance < 10:
				_collect()

## Set coin value
func set_value(amount: int) -> void:
	value = amount

## Called when player touches the coin
func _on_area_entered(area: Area2D) -> void:
	var parent = area.get_parent()
	if parent and parent.is_in_group("player"):
		_collect()

## Collect the coin
func _collect() -> void:
	if collected:
		return

	collected = true
	EventBus.coin_collected.emit(value)
	GameManager.add_run_stat("gold_collected", value)
	queue_free()
