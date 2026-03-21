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

var spawn_system: SpawnSystem = null

func _ready() -> void:
	spawn_system = get_node_or_null("SpawnSystem")
	if spawn_system == null:
		push_warning("WaveManager requires a SpawnSystem child node")

	EventBus.game_started.connect(_on_game_started)
	_start_wave()

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

	if spawn_system:
		spawn_system.start_wave(current_wave)

	EventBus.wave_started.emit(current_wave)

## Update fighting state
func _update_fighting(delta: float) -> void:
	wave_time_remaining -= delta
	EventBus.wave_time_updated.emit(max(0, wave_time_remaining))

	# Check if wave is complete
	var enemies = get_tree().get_nodes_in_group("enemies")
	if wave_time_remaining <= 0 and enemies.is_empty():
		_end_wave()

## Update countdown (between waves)
func _update_countdown(delta: float) -> void:
	countdown_remaining -= delta
	EventBus.wave_time_updated.emit(max(0, countdown_remaining))

	if countdown_remaining <= 0:
		_start_shopping()

## Update shopping state
func _update_shopping(delta: float) -> void:
	# Shopping logic here
	pass

## End current wave
func _end_wave() -> void:
	wave_state = WaveState.COUNTDOWN
	EventBus.wave_completed.emit(current_wave)
	GameManager.current_wave += 1
	countdown_remaining = countdown_duration

## Start shopping phase
func _start_shopping() -> void:
	wave_state = WaveState.SHOPPING
	GameManager.set_state(GameManager.GameState.SHOP)

## Called when game starts
func _on_game_started() -> void:
	_start_wave()
