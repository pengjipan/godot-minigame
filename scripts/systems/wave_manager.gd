extends Node
## Manages game waves and progression
class_name WaveManager

enum WaveState { FIGHTING, COUNTDOWN, SHOPPING }

var current_wave: int = 1
var wave_state: WaveState = WaveState.FIGHTING
var wave_duration: float = 60.0  # seconds
var wave_time_remaining: float = 0.0
var countdown_duration: float = 30.0
var countdown_remaining: float = 0.0
var wave_initialized: bool = false
var wave_initialization_time: float = 0.0
var MIN_WAVE_DURATION: float = 2.0  # Minimum time a wave must run before checking for completion
var wave_enemy_count: int = 0  # Total enemies configured for this wave

var spawn_system: SpawnSystem = null
var wave_configs: Dictionary = {}
var current_wave_config: WaveConfig = null
var all_enemies_spawned: bool = false  # Flag when all enemies are spawned for the wave

func _ready() -> void:
	_load_wave_configs()
	spawn_system = get_node_or_null("SpawnSystem")
	if spawn_system == null:
		push_warning("WaveManager requires a SpawnSystem child node")

	EventBus.game_started.connect(_on_game_started)
	EventBus.all_enemies_spawned.connect(_on_all_enemies_spawned)

func _load_wave_configs() -> void:
	# Load available wave configs
	wave_configs[1] = load("res://resources/waves/wave_1.tres")
	wave_configs[2] = load("res://resources/waves/wave_2.tres")
	wave_configs[3] = load("res://resources/waves/wave_3.tres")
	wave_configs[5] = load("res://resources/waves/wave_5.tres")
	wave_configs[10] = load("res://resources/waves/wave_10.tres")

	print("[WaveManager] Loaded %d wave configs" % wave_configs.size())

func _process(delta: float) -> void:
	if not GameManager.is_game_running:
		return

	match wave_state:
		WaveState.FIGHTING:
			_update_fighting(delta)
		WaveState.COUNTDOWN:
			_update_countdown(delta)
		WaveState.SHOPPING:
			_update_shopping(delta)

## Start a new wave
func _start_wave() -> void:
	current_wave = GameManager.current_wave
	wave_state = WaveState.FIGHTING
	wave_time_remaining = wave_duration
	countdown_remaining = countdown_duration
	wave_initialized = true
	wave_initialization_time = Time.get_ticks_msec() / 1000.0
	all_enemies_spawned = false

	# Load config for current wave (or closest)
	current_wave_config = _get_wave_config(current_wave)

	if current_wave_config:
		wave_enemy_count = current_wave_config.enemy_count
		print("[WaveManager] Wave %d config: %d enemies, %.1fx health" %
			[current_wave, current_wave_config.enemy_count, current_wave_config.enemy_health_mult])
	else:
		wave_enemy_count = 0
		print("[WaveManager] Wave %d config: Using default settings" % current_wave)

	# Reset shop refresh counter
	var shop = get_node_or_null("/root/ShopSystem")
	if shop and shop.has_method("reset_refresh_count"):
		shop.reset_refresh_count()

	if spawn_system:
		# Pass the configured enemy count to spawn system
		if current_wave_config:
			spawn_system.max_enemies_per_wave = current_wave_config.enemy_count
		spawn_system.start_wave(current_wave)

	EventBus.wave_started.emit(current_wave)

## Handle when all enemies for this wave have been spawned
func _on_all_enemies_spawned(wave_number: int, enemy_count: int) -> void:
	if wave_number == current_wave:
		all_enemies_spawned = true
		print("[WaveManager] All %d enemies spawned for wave %d" % [enemy_count, wave_number])

## Update fighting state
func _update_fighting(delta: float) -> void:
	wave_time_remaining -= delta
	EventBus.wave_time_updated.emit(max(0, wave_time_remaining))

	# Check if wave is complete
	var enemies = get_tree().get_nodes_in_group("enemies")
	var current_time = Time.get_ticks_msec() / 1000.0
	var wave_running_time = current_time - wave_initialization_time

	# Check wave completion conditions:
	# 1. All enemies have been spawned
	# 2. No enemies are left alive
	# 3. The minimum wave duration has been met
	var wave_completion_conditions_met = all_enemies_spawned and enemies.is_empty() and (wave_running_time >= MIN_WAVE_DURATION)

	# Wave completion logic
	if wave_completion_conditions_met:
		print("[WaveManager] 敌人全灭！波次 ", current_wave, " 完成 (运行时间: %.1f秒)" % wave_running_time)
		_end_wave()
	elif wave_time_remaining <= 0:
		print("[WaveManager] 时间到！波次 ", current_wave, " 完成")
		_end_wave()

## Update countdown (between waves)
func _update_countdown(delta: float) -> void:
	countdown_remaining -= delta
	EventBus.wave_time_updated.emit(max(0, countdown_remaining))

	if countdown_remaining <= 0:
		print("[WaveManager] 倒计时结束，开始下一波！")
		_start_wave()

## Update shopping state
func _update_shopping(delta: float) -> void:
	# Shopping logic here
	pass

## End current wave
func _end_wave() -> void:
	print("[WaveManager] 波次 ", current_wave, " 结束...")

	# Check for level-ups (stat upgrade screen)
	if ExperienceManager.pending_stat_picks > 0:
		print("[WaveManager] Pending stat picks: ", ExperienceManager.pending_stat_picks)
		# Enter level up state to show stat upgrade panel
		GameManager.set_state(GameManager.GameState.LEVEL_UP)
		# Load stat upgrade screen
		var stat_upgrade_screen = load("res://scenes/ui/stat_upgrade_screen.tscn").instantiate()
		get_tree().root.add_child(stat_upgrade_screen)
		stat_upgrade_screen.show_upgrade_selection()
	else:
		# Go to countdown for next wave if no level-ups
		wave_state = WaveState.COUNTDOWN
		EventBus.wave_completed.emit(current_wave)
		countdown_remaining = countdown_duration

	current_wave += 1
	GameManager.current_wave += 1
	print("[WaveManager] 下一波将是: ", current_wave)

## Start shopping phase
func _start_shopping() -> void:
	wave_state = WaveState.SHOPPING
	GameManager.set_state(GameManager.GameState.SHOP)

## Called when game starts
func _on_game_started() -> void:
	_start_wave()

## Get wave config for a specific wave (finds closest available)
func _get_wave_config(wave_num: int) -> WaveConfig:
	# Try exact match
	if wave_configs.has(wave_num):
		return wave_configs[wave_num]

	# Find closest lower config
	var closest_wave = 1
	for config_wave in wave_configs.keys():
		if config_wave <= wave_num and config_wave > closest_wave:
			closest_wave = config_wave

	return wave_configs.get(closest_wave, wave_configs[1])
