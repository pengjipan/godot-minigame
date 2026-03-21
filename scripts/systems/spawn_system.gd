extends Node
## Manages enemy spawning for waves
class_name SpawnSystem

@export var spawn_parent: Node = null
@export var enemy_types: Array[EnemyData] = []

var wave_number: int = 1
var enemies_spawned_this_wave: int = 0
var spawn_timer: float = 0.0
var spawn_interval: float = 0.5  # Time between spawns
var is_spawning: bool = false
var max_enemies_per_wave: int = 20

func _ready() -> void:
	EventBus.wave_started.connect(_on_wave_started)
	if spawn_parent == null:
		spawn_parent = get_parent()

func _process(delta: float) -> void:
	if not is_spawning:
		return

	spawn_timer += delta
	if spawn_timer >= spawn_interval:
		spawn_timer = 0.0
		_spawn_enemy()

## Start spawning for a wave
func start_wave(wave: int) -> void:
	wave_number = wave
	enemies_spawned_this_wave = 0
	max_enemies_per_wave = 10 + wave * 5
	spawn_timer = 0.0
	is_spawning = true

## Stop spawning
func stop_spawning() -> void:
	is_spawning = false

func _on_wave_started(wave: int) -> void:
	start_wave(wave)

## Spawn a single enemy
func _spawn_enemy() -> void:
	if enemies_spawned_this_wave >= max_enemies_per_wave:
		stop_spawning()
		return

	if enemy_types.is_empty():
		push_warning("No enemy types available for spawning")
		return

	# Select random enemy type
	var enemy_data = enemy_types[randi() % enemy_types.size()]

	# Get player position
	var player_nodes = get_tree().get_nodes_in_group("player")
	if player_nodes.is_empty():
		return

	var player = player_nodes[0]

	# Spawn around player in a circle (600-800 pixels away)
	var spawn_distance = randf_range(600, 800)
	var spawn_angle = randf_range(0, TAU)
	var spawn_pos = player.global_position + Vector2(
		cos(spawn_angle) * spawn_distance,
		sin(spawn_angle) * spawn_distance
	)

	# Create enemy
	var enemy = enemy_data.create_instance()
	if enemy:
		spawn_parent.add_child(enemy)
		enemy.global_position = spawn_pos
		enemy.enemy_data = enemy_data
		enemy._ready()  # Initialize enemy

		enemies_spawned_this_wave += 1
