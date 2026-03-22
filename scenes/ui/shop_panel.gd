extends Control
## Shop panel for purchasing items between waves
class_name ShopPanel

@export var shop_system: ShopSystem = null
@export var countdown_duration: float = 30.0

@onready var refresh_button: Button = $PanelContainer/VBoxContainer/RefreshButton

var shop_buttons: Array[Button] = []
var countdown_timer: float = 0.0
var countdown_label: Label = null

func _ready() -> void:
	# Set translated text
	$PanelContainer/VBoxContainer/Title.text = tr("SHOP_TITLE")

	EventBus.shop_opened.connect(_on_shop_opened)
	EventBus.shop_closed.connect(_on_shop_closed)

	# Connect refresh button
	if refresh_button:
		refresh_button.pressed.connect(_on_refresh_pressed)

	# Create shop buttons
	for i in range(6):
		var button = Button.new()
		button.text = "Item %d" % (i + 1)
		button.pressed.connect(_on_item_purchased.bindv([i]))
		add_child(button)
		shop_buttons.append(button)

	# Create countdown label
	countdown_label = Label.new()
	add_child(countdown_label)

	# Hide initially
	visible = false

func _on_shop_opened() -> void:
	visible = true
	countdown_timer = countdown_duration

	if shop_system == null:
		shop_system = get_tree().root.get_node_or_null("ShopSystem")

	# Display shop items
	_update_shop_display()
	_update_refresh_button()

func _update_shop_display() -> void:
	if shop_system:
		var items = shop_system.get_shop_items()
		for i in range(shop_buttons.size()):
			if i < items.size():
				var item = items[i]
				var name = item.get("name", "Item")
				var price = item.get("price", 100)
				shop_buttons[i].text = "%s - %d💰" % [name, price]
				shop_buttons[i].visible = true
			else:
				shop_buttons[i].visible = false

func _process(delta: float) -> void:
	if not visible:
		return

	countdown_timer -= delta
	if countdown_label:
		countdown_label.text = "%.0fs" % max(0, countdown_timer)

	if countdown_timer <= 0:
		_close_shop()

func _on_item_purchased(index: int) -> void:
	if shop_system:
		shop_system.purchase_item(index)

func _on_shop_closed() -> void:
	visible = false

func _close_shop() -> void:
	visible = false
	EventBus.shop_closed.emit()
	GameManager.set_state(GameManager.GameState.PLAYING)

func _on_refresh_pressed() -> void:
	var shop = get_node_or_null("/root/ShopSystem")
	if not shop:
		return

	# Get player inventory
	var player = get_tree().get_first_node_in_group("player")
	var owned_weapons = []
	if player and player.has_node("Inventory"):
		var inventory = player.get_node("Inventory")
		if "weapon_data_list" in inventory:
			owned_weapons = inventory.weapon_data_list

	# Purchase refresh
	if shop.purchase_refresh(owned_weapons):
		_update_shop_display()
		_update_refresh_button()

func _update_refresh_button() -> void:
	if not refresh_button:
		return

	var shop = get_node_or_null("/root/ShopSystem")
	if not shop:
		return

	var cost = shop.get_refresh_cost()
	if cost == 0:
		refresh_button.text = "Refresh (Free)"
	else:
		refresh_button.text = "Refresh (%d gold)" % cost
