extends Node
## Manages enemy spawning for waves
class_name SpawnSystem

@export var spawn_parent: Node = null
@export var enemy_scene: PackedScene = null

var wave_number: int = 1
var enemies_spawned_this_wave: int = 0
var spawn_timer: float = 0.0
var spawn_interval: float = 0.5  # Time between spawns - reduced for faster testing
var is_spawning: bool = false
var max_enemies_per_wave: int = 20
var all_enemies_spawned: bool = false  # Flag when all enemies are spawned for the wave

func _ready() -> void:
	print("[SpawnSystem] Initializing...")
	# Enable process functions explicitly
	set_process(true)
	set_physics_process(true)
	print("[SpawnSystem] Process functions enabled")
	
	EventBus.wave_started.connect(_on_wave_started)
	if spawn_parent == null:
		spawn_parent = get_parent()
		print("[SpawnSystem] Set spawn_parent to: ", spawn_parent.name)
	else:
		print("[SpawnSystem] spawn_parent already set to: ", spawn_parent.name)

	# Load default enemy if not set
	if enemy_scene == null:
		enemy_scene = load("res://scenes/enemies/enemy_base.tscn")
		print("[SpawnSystem] Loaded default enemy scene: ", enemy_scene if enemy_scene else "FAILED")
	else:
		print("[SpawnSystem] enemy_scene already set: ", enemy_scene)
		
	# Scene tree status check removed due to compatibility issues

func _process(delta: float) -> void:
	# Debug: Log process calls frequently
	if Engine.get_frames_drawn() % 30 == 0:  # Log every 0.5 seconds
		print("[SpawnSystem] _process called - is_spawning: ", is_spawning, " timer: ", spawn_timer, " enemies_spawned: ", enemies_spawned_this_wave, " max_enemies: ", max_enemies_per_wave)

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
	all_enemies_spawned = true
	print("[SpawnSystem] Spawning stopped - all enemies spawned for this wave")
	EventBus.all_enemies_spawned.emit(wave_number, max_enemies_per_wave)

func _on_wave_started(wave: int) -> void:
	print("[SpawnSystem] Received wave_started event for wave: ", wave)
	start_wave(wave)
	print("[SpawnSystem] After start_wave - is_spawning: ", is_spawning, " max_enemies: ", max_enemies_per_wave)

## Spawn a single enemy
func _spawn_enemy() -> void:
	print("[SpawnSystem] Attempting to spawn enemy...")
	
	if enemies_spawned_this_wave >= max_enemies_per_wave:
		stop_spawning()
		print("[SpawnSystem] Wave complete, reached max enemies: ", max_enemies_per_wave)
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
	print("[SpawnSystem] Found player at position: ", player.global_position)

	# Get world bounds from player (if available)
	var world_bounds: Rect2
	if player.has_method("get") and "world_bounds" in player:
		world_bounds = player.world_bounds
		print("[SpawnSystem] Using player world bounds: ", world_bounds)
	else:
		# Fallback to default bounds
		world_bounds = Rect2(-200, -200, 1480, 2320)
		print("[SpawnSystem] Using default world bounds: ", world_bounds)

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
	print("[SpawnSystem] Calculated spawn position: ", spawn_pos)

	# Create enemy
	var enemy = enemy_scene.instantiate()
	if enemy:
		print("[SpawnSystem] Successfully instantiated enemy")
		spawn_parent.add_child(enemy)
		enemy.global_position = spawn_pos
		enemies_spawned_this_wave += 1
		print("[SpawnSystem] Spawned enemy #", enemies_spawned_this_wave, " at ", spawn_pos)
		
		# Debug: Check if enemy is in correct group
		if enemy.is_in_group("enemies"):
			print("[SpawnSystem] Enemy correctly added to 'enemies' group")
		else:
			print("[SpawnSystem] WARNING: Enemy NOT in 'enemies' group")
	else:
		push_error("[SpawnSystem] Failed to instantiate enemy!")
