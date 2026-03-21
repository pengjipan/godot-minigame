extends Node2D
## Main game world scene
class_name GameWorld

var player: Player = null
var hud: GameHUD = null
var wave_manager: WaveManager = null
var spawn_system: SpawnSystem = null
var experience_system: ExperienceSystem = null

func _ready() -> void:
	print("[GameWorld] Initializing game world...")

	# Get existing nodes from scene
	player = $Player
	hud = $GameHUD

	if player:
		print("[GameWorld] Player found at position: ", player.position)
		# Make sure player has character data
		if player.character_data == null:
			print("[GameWorld] Creating default character data for player")
			player.character_data = CharacterData.new()
	else:
		push_error("[GameWorld] Player node not found!")

	if hud:
		print("[GameWorld] HUD found")
	else:
		push_error("[GameWorld] HUD node not found!")

	# Create game systems
	print("[GameWorld] Creating game systems...")

	wave_manager = WaveManager.new()
	add_child(wave_manager)

	spawn_system = SpawnSystem.new()
	spawn_system.name = "SpawnSystem"
	spawn_system.spawn_parent = self
	wave_manager.add_child(spawn_system)

	experience_system = ExperienceSystem.new()
	add_child(experience_system)

	print("[GameWorld] Systems created. Starting game...")

	# Start game
	GameManager.set_state(GameManager.GameState.PLAYING)
	GameManager.is_game_running = true
	print("[GameWorld] Game is running: ", GameManager.is_game_running)

	# Manually trigger wave start if needed
	await get_tree().create_timer(0.5).timeout
	print("[GameWorld] Triggering wave start...")
	EventBus.wave_started.emit(1)

func _process(delta: float) -> void:
	pass
