extends CanvasLayer
## Main game HUD displaying player stats
class_name GameHUD

@onready var health_bar: ProgressBar = $MarginContainer/TopBar/HealthBar
@onready var experience_bar: ProgressBar = $MarginContainer/TopBar/ExperienceBar
@onready var wave_label: Label = $MarginContainer/TopBar/WaveLabel
@onready var coin_label: Label = $MarginContainer/BottomBar/CoinLabel
@onready var kill_label: Label = $MarginContainer/BottomBar/KillLabel
@onready var virtual_joystick: VirtualJoystick = $MarginContainer/VirtualJoystick

var player: Player = null
var experience_system: ExperienceSystem = null
var current_kills: int = 0
var current_gold: int = 0

func _ready() -> void:
	# Set initial translated text
	wave_label.text = tr("HUD_WAVE") % [1, 60]
	coin_label.text = tr("HUD_GOLD") % 0
	kill_label.text = tr("HUD_KILLS") % 0

	# Connect to signals
	EventBus.health_updated.connect(_on_health_updated)
	EventBus.experience_updated.connect(_on_experience_updated)
	EventBus.wave_time_updated.connect(_on_wave_time_updated)
	EventBus.coin_collected.connect(_on_coin_collected)
	EventBus.enemy_died.connect(_on_enemy_died)

	# Connect joystick to player
	virtual_joystick.input_changed.connect(_on_joystick_input)

func _on_health_updated(current: int, max_val: int) -> void:
	if health_bar:
		health_bar.max_value = max_val
		health_bar.value = current

func _on_experience_updated(current: int, max_val: int) -> void:
	if experience_bar:
		experience_bar.max_value = max_val
		experience_bar.value = current

func _on_wave_time_updated(time_remaining: float) -> void:
	if wave_label:
		var wave = GameManager.current_wave
		wave_label.text = tr("HUD_WAVE") % [wave, time_remaining]

func _on_coin_collected(amount: int) -> void:
	current_gold += amount
	if coin_label:
		coin_label.text = tr("HUD_GOLD") % current_gold

func _on_enemy_died(enemy: Node, position: Vector2) -> void:
	current_kills += 1
	if kill_label:
		kill_label.text = tr("HUD_KILLS") % current_kills

func _on_joystick_input(input_vector: Vector2) -> void:
	# Find player and set input
	if player == null:
		var player_nodes = get_tree().get_nodes_in_group("player")
		if player_nodes.size() > 0:
			player = player_nodes[0]

	if player and player.has_method("set_joystick_input"):
		player.set_joystick_input(input_vector)
