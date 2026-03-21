extends Node
## Global game manager handling game state, progression, and runs

enum GameState {
	MAIN_MENU,
	CHARACTER_SELECT,
	PLAYING,
	PAUSED,
	WAVE_BREAK,
	LEVEL_UP,
	SHOP,
	GAME_OVER
}

var current_state: GameState = GameState.MAIN_MENU
var current_wave: int = 1
var player_stats: Dictionary = {}
var run_stats: Dictionary = {
	"waves_survived": 0,
	"enemies_killed": 0,
	"gold_collected": 0,
	"damage_taken": 0,
	"damage_dealt": 0
}

var player_instance: Node = null
var is_game_running: bool = false

func _ready() -> void:
	pass

## Start a new game run with selected character
func start_new_run(character_data: Dictionary) -> void:
	player_stats = character_data.duplicate()
	current_wave = 1
	run_stats = {
		"waves_survived": 0,
		"enemies_killed": 0,
		"gold_collected": 0,
		"damage_taken": 0,
		"damage_dealt": 0
	}
	set_state(GameState.PLAYING)
	is_game_running = true
	EventBus.game_started.emit()

## Change game state
func set_state(new_state: GameState) -> void:
	current_state = new_state
	match new_state:
		GameState.PLAYING:
			get_tree().paused = false
		GameState.PAUSED:
			get_tree().paused = true
		GameState.LEVEL_UP:
			get_tree().paused = true
			EventBus.upgrade_panel_opened.emit()
		GameState.SHOP:
			get_tree().paused = true
			EventBus.shop_opened.emit()
		GameState.WAVE_BREAK:
			get_tree().paused = true
			EventBus.shop_opened.emit()
		GameState.GAME_OVER:
			get_tree().paused = true
			is_game_running = false
			EventBus.game_over.emit(run_stats)

## Add to run statistics
func add_run_stat(stat_name: String, value: float) -> void:
	if stat_name in run_stats:
		run_stats[stat_name] += value

## Get current player stat value
func get_player_stat(stat_name: String, default_value: float = 0.0) -> float:
	return player_stats.get(stat_name, default_value)

## Update player stat (for upgrades)
func set_player_stat(stat_name: String, value: float) -> void:
	player_stats[stat_name] = value

## Multiply player stat (for percentage upgrades)
func multiply_player_stat(stat_name: String, multiplier: float) -> void:
	if stat_name in player_stats:
		player_stats[stat_name] *= multiplier
	else:
		player_stats[stat_name] = multiplier

## End current game run
func end_run() -> void:
	set_state(GameState.GAME_OVER)
	SaveManager.save_run_stats(run_stats)

## Pause/Resume game
func toggle_pause() -> void:
	if current_state == GameState.PLAYING:
		set_state(GameState.PAUSED)
		EventBus.game_paused.emit()
	elif current_state == GameState.PAUSED:
		set_state(GameState.PLAYING)
		EventBus.game_resumed.emit()
