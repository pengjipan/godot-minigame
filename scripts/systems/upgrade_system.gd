extends Node
## Manages upgrade selection and application
class_name UpgradeSystem

@export var available_upgrades: Array[UpgradeData] = []

var selected_upgrades: Array[UpgradeData] = []

func _ready() -> void:
	EventBus.player_leveled_up.connect(_on_player_leveled_up)

## Called when player levels up
func _on_player_leveled_up(level: int) -> void:
	# Select 3-4 random upgrades
	_generate_upgrade_options(3)
	EventBus.upgrade_panel_opened.emit()

## Generate random upgrade options
func _generate_upgrade_options(count: int) -> void:
	selected_upgrades.clear()

	if available_upgrades.is_empty():
		push_warning("No upgrades available")
		return

	# Shuffle and select
	var shuffled = available_upgrades.duplicate()
	shuffled.shuffle()

	for i in range(min(count, shuffled.size())):
		selected_upgrades.append(shuffled[i])

## Get current upgrade options
func get_upgrade_options() -> Array[UpgradeData]:
	return selected_upgrades

## Apply upgrade to player
func apply_upgrade(upgrade: UpgradeData) -> void:
	if upgrade in selected_upgrades:
		upgrade.apply_upgrade(GameManager.player_stats)
		EventBus.upgrade_purchased.emit(upgrade.upgrade_name)
		EventBus.stat_upgraded.emit(upgrade.upgrade_name, 0)

	# Resume game after upgrade selection
	GameManager.set_state(GameManager.GameState.PLAYING)
	EventBus.upgrade_panel_closed.emit()

## Select upgrade by index
func select_upgrade_at_index(index: int) -> void:
	if index >= 0 and index < selected_upgrades.size():
		apply_upgrade(selected_upgrades[index])
