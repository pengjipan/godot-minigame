extends Control
## Level up panel for selecting upgrades
class_name LevelUpPanel

@export var upgrade_system: UpgradeSystem = null

var upgrade_buttons: Array[Button] = []
var upgrade_labels: Array[Label] = []

func _ready() -> void:
	EventBus.upgrade_panel_opened.connect(_on_upgrade_panel_opened)
	EventBus.upgrade_panel_closed.connect(_on_upgrade_panel_closed)

	# Create upgrade option buttons
	for i in range(4):
		var button = Button.new()
		button.text = "Upgrade %d" % (i + 1)
		button.pressed.connect(_on_upgrade_selected.bindv([i]))
		add_child(button)
		upgrade_buttons.append(button)

	# Hide initially
	visible = false

func _on_upgrade_panel_opened() -> void:
	visible = true

	# Get upgrades from system
	if upgrade_system == null:
		upgrade_system = get_tree().root.get_node_or_null("UpgradeSystem")

	if upgrade_system:
		var options = upgrade_system.get_upgrade_options()
		for i in range(upgrade_buttons.size()):
			if i < options.size():
				var upgrade = options[i]
				upgrade_buttons[i].text = upgrade.upgrade_name
				upgrade_buttons[i].visible = true
			else:
				upgrade_buttons[i].visible = false

func _on_upgrade_panel_closed() -> void:
	visible = false

func _on_upgrade_selected(index: int) -> void:
	if upgrade_system:
		upgrade_system.select_upgrade_at_index(index)
