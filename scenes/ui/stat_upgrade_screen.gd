extends Control
## Displays 3 random stat upgrade options when player levels up
class_name StatUpgradeScreen

# References to UI elements (will be set from scene tree)
@onready var option_1_container: VBoxContainer = %Option1Container
@onready var option_2_container: VBoxContainer = %Option2Container
@onready var option_3_container: VBoxContainer = %Option3Container
@onready var option_1_name: Label = %Option1Name
@onready var option_2_name: Label = %Option2Name
@onready var option_3_name: Label = %Option3Name
@onready var option_1_value: Label = %Option1Value
@onready var option_2_value: Label = %Option2Value
@onready var option_3_value: Label = %Option3Value
@onready var option_1_rarity: Label = %Option1Rarity
@onready var option_2_rarity: Label = %Option2Rarity
@onready var option_3_rarity: Label = %Option3Rarity
@onready var option_1_button: Button = %Option1Button
@onready var option_2_button: Button = %Option2Button
@onready var option_3_button: Button = %Option3Button

# Current stat options
var current_options: Array[Dictionary] = []
var stat_pool: Array[StatUpgradeData] = []

# Reference to player stats
var player_stats: PlayerStats = null

# Rarity colors
const RARITY_COLORS := {
	"COMMON": Color.WHITE,
	"UNCOMMON": Color.LIGHT_GREEN,
	"RARE": Color.GOLD
}

func _ready() -> void:
	# Load all stat upgrade resources
	_load_stat_pool()

	# Get player stats reference
	var player = get_tree().get_first_node_in_group("player")
	if player and player.has_node("PlayerStats"):
		player_stats = player.get_node("PlayerStats")

	# Connect button signals
	option_1_button.pressed.connect(_on_option_selected.bind(0))
	option_2_button.pressed.connect(_on_option_selected.bind(1))
	option_3_button.pressed.connect(_on_option_selected.bind(2))

	# Connect to level up event
	EventBus.level_up.connect(_on_level_up)

	# Hide initially
	visible = false

## Load all stat upgrade resources from disk
func _load_stat_pool() -> void:
	var stat_paths := [
		"res://resources/upgrades/stats/max_hp.tres",
		"res://resources/upgrades/stats/armor.tres",
		"res://resources/upgrades/stats/hp_regen.tres",
		"res://resources/upgrades/stats/dodge.tres",
		"res://resources/upgrades/stats/damage.tres",
		"res://resources/upgrades/stats/crit_chance.tres",
		"res://resources/upgrades/stats/crit_damage.tres",
		"res://resources/upgrades/stats/range_damage.tres",
		"res://resources/upgrades/stats/move_speed.tres",
		"res://resources/upgrades/stats/attack_speed.tres",
		"res://resources/upgrades/stats/reload_speed.tres",
		"res://resources/upgrades/stats/cooldown_reduction.tres",
		"res://resources/upgrades/stats/pickup_range.tres",
		"res://resources/upgrades/stats/gold_gain.tres",
		"res://resources/upgrades/stats/xp_gain.tres",
		"res://resources/upgrades/stats/lifesteal.tres",
		"res://resources/upgrades/stats/knockback.tres"
	]

	for path in stat_paths:
		var stat: StatUpgradeData = load(path)
		if stat:
			stat_pool.append(stat)

	print("[StatUpgradeScreen] Loaded %d stat upgrades" % stat_pool.size())

## Called when player levels up
func _on_level_up(new_level: int) -> void:
	if ExperienceManager.pending_stat_picks > 0:
		show_upgrade_selection()

## Show the upgrade screen with 3 random options
func show_upgrade_selection() -> void:
	if stat_pool.is_empty():
		push_warning("[StatUpgradeScreen] No stats in pool!")
		return

	# Generate 3 random stat options
	current_options = _generate_random_options(3)

	# Display options in UI
	_display_option(0, current_options[0])
	_display_option(1, current_options[1])
	_display_option(2, current_options[2])

	# Show panel and pause game
	visible = true
	get_tree().paused = true
	print("[StatUpgradeScreen] Showing upgrade selection")

## Generate random stat options with rarity rolling
func _generate_random_options(count: int) -> Array[Dictionary]:
	var options: Array[Dictionary] = []
	var available_stats := stat_pool.duplicate()

	# Shuffle to ensure variety
	available_stats.shuffle()

	for i in range(min(count, available_stats.size())):
		var stat: StatUpgradeData = available_stats[i]
		var rarity := stat.roll_rarity()
		var value := stat.get_value_for_rarity(rarity)

		options.append({
			"stat": stat,
			"rarity": rarity,
			"value": value
		})

	return options

## Display an option in the UI
func _display_option(index: int, option: Dictionary) -> void:
	var stat: StatUpgradeData = option.stat
	var rarity: int = option.rarity
	var value: float = option.value

	var rarity_name: String = StatUpgradeData.Rarity.keys()[rarity]
	var rarity_color: Color = RARITY_COLORS.get(rarity_name, Color.WHITE)

	# Format value as percentage (0.08 -> "+8%")
	var value_text := "+%.1f%%" % (value * 100)

	match index:
		0:
			option_1_name.text = stat.display_name
			option_1_value.text = value_text
			option_1_rarity.text = rarity_name
			option_1_rarity.add_theme_color_override("font_color", rarity_color)
		1:
			option_2_name.text = stat.display_name
			option_2_value.text = value_text
			option_2_rarity.text = rarity_name
			option_2_rarity.add_theme_color_override("font_color", rarity_color)
		2:
			option_3_name.text = stat.display_name
			option_3_value.text = value_text
			option_3_rarity.text = rarity_name
			option_3_rarity.add_theme_color_override("font_color", rarity_color)

## Called when player selects an option
func _on_option_selected(index: int) -> void:
	if index < 0 or index >= current_options.size():
		return

	var option: Dictionary = current_options[index]
	var stat: StatUpgradeData = option.stat
	var value: float = option.value

	# Apply stat upgrade to player
	if player_stats:
		player_stats.apply_stat_upgrade(stat.stat_type, value)
		print("[StatUpgradeScreen] Applied %s: +%.1f%%" % [stat.display_name, value * 100])
	else:
		push_warning("[StatUpgradeScreen] No PlayerStats reference!")

	# Consume the stat pick
	ExperienceManager.consume_stat_pick()

	# Hide panel
	visible = false

	# Check if more stat picks are pending
	if ExperienceManager.pending_stat_picks > 0:
		# Show selection again for next pick
		await get_tree().create_timer(0.1).timeout
		show_upgrade_selection()
	else:
		# All picks done, transition to shop
		get_tree().paused = false
		GameManager.set_state(GameManager.GameState.SHOP)
		print("[StatUpgradeScreen] All picks done, transitioning to shop")
