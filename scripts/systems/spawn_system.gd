extends Node
## Manages enemy spawning for waves
class_name SpawnSystem

@export var spawn_parent: Node = null
@export var enemy_scene: PackedScene = null

var wave_number: int = 1
var enemies_spawned_this_wave: int = 0
var spawn_timer: float = 0.0
var spawn_interval: float = 1.5  # Time between spawns
var is_spawning: bool = false
var max_enemies_per_wave: int = 20

func _ready() -> void:
	print("[SpawnSystem] Initializing...")
	EventBus.wave_started.connect(_on_wave_started)
	if spawn_parent == null:
		spawn_parent = get_parent()

	# Load default enemy if not set
	if enemy_scene == null:
		enemy_scene = load("res://scenes/enemies/enemy_base.tscn")
		print("[SpawnSystem] Loaded default enemy scene")

func _process(delta: float) -> void:
	if not is_spawning:
		return

	spawn_timer += delta
	if spawn_timer >= spawn_interval:
		spawn_timer = 0.0
		_spawn_enemy()

## Start spawning for a wave
func start_wave(wave: int) -> void:
	print("[SpawnSystem] Starting wave ", wave)
	wave_number = wave
	enemies_spawned_this_wave = 0
	max_enemies_per_wave = 5 + wave * 3  # Start smaller
	spawn_timer = 0.0
	is_spawning = true

## Stop spawning
func stop_spawning() -> void:
	is_spawning = false
	print("[SpawnSystem] Spawning stopped")

func _on_wave_started(wave: int) -> void:
	start_wave(wave)

## Spawn a single enemy
func _spawn_enemy() -> void:
	if enemies_spawned_this_wave >= max_enemies_per_wave:
		stop_spawning()
		return

	if enemy_scene == null:
		push_error("[SpawnSystem] No enemy scene available!")
		stop_spawning()
		return

	# Get player position
	var player_nodes = get_tree().get_nodes_in_group("player")
	if player_nodes.is_empty():
		print("[SpawnSystem] No player found, skipping spawn")
		return

	var player = player_nodes[0]

	# Get world bounds from player (if available)
	var world_bounds: Rect2
	if player.has_method("get") and "world_bounds" in player:
		world_bounds = player.world_bounds
	else:
		# Fallback to default bounds
		world_bounds = Rect2(-200, -200, 1480, 2320)

	# Spawn around player in a circle (300-500 pixels away for testing)
	var spawn_distance = randf_range(300, 500)
	var spawn_angle = randf_range(0, TAU)
	var spawn_pos = player.global_position + Vector2(
		cos(spawn_angle) * spawn_distance,
		sin(spawn_angle) * spawn_distance
	)

	# Clamp spawn position to world bounds
	spawn_pos.x = clamp(spawn_pos.x, world_bounds.position.x + 50, world_bounds.position.x + world_bounds.size.x - 50)
	spawn_pos.y = clamp(spawn_pos.y, world_bounds.position.y + 50, world_bounds.position.y + world_bounds.size.y - 50)

	# Create enemy
	var enemy = enemy_scene.instantiate()
	if enemy:
		spawn_parent.add_child(enemy)
		enemy.global_position = spawn_pos
		enemies_spawned_this_wave += 1
		print("[SpawnSystem] Spawned enemy #", enemies_spawned_this_wave, " at ", spawn_pos)
	else:
		push_error("[SpawnSystem] Failed to instantiate enemy!")
