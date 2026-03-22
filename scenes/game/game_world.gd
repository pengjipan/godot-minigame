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
	
	spawn_system = SpawnSystem.new()
	spawn_system.name = "SpawnSystem"
	spawn_system.spawn_parent = self
	
	# Set spawn_system reference before adding to scene tree
	wave_manager.spawn_system = spawn_system
	
	# Add systems to scene tree
	wave_manager.add_child(spawn_system)
	add_child(wave_manager)

	experience_system = ExperienceSystem.new()
	add_child(experience_system)

	print("[GameWorld] Systems created. Starting game...")

	# Initialize with selected starting weapon
	if GameManager.selected_starting_weapon:
		if player and player.has_node("PlayerInventory"):
			var inventory = player.get_node("PlayerInventory")
			if inventory.has_method("add_weapon_from_data"):
				inventory.add_weapon_from_data(GameManager.selected_starting_weapon)
				print("[GameWorld] Started with weapon: %s" % GameManager.selected_starting_weapon.weapon_name)

		# Clear selection for next run
		GameManager.selected_starting_weapon = null

	# Start game
	GameManager.set_state(GameManager.GameState.PLAYING)
	GameManager.is_game_running = true
	print("[GameWorld] Game is running: ", GameManager.is_game_running)

	# Start the game immediately after all systems are ready
	print("[GameWorld] Starting wave 1 immediately...")
	# Directly start the first wave instead of using event
	if wave_manager:
		wave_manager._start_wave()

func _process(delta: float) -> void:
	pass
