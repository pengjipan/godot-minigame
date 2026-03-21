extends Node
## Manages shop and item purchasing
class_name ShopSystem

@export var shop_items: Array[Dictionary] = []  # {item: UpgradeData, price: int}

var player_gold: int = 0
var current_gold: int = 0

func _ready() -> void:
	EventBus.coin_collected.connect(_on_coin_collected)
	EventBus.shop_opened.connect(_on_shop_opened)
	EventBus.shop_closed.connect(_on_shop_closed)

## Called when coins are collected
func _on_coin_collected(amount: int) -> void:
	player_gold += amount
	current_gold = player_gold
	EventBus.gold_amount_updated.emit(player_gold)

## Called when shop opens
func _on_shop_opened() -> void:
	# Randomize available items
	pass

## Called when shop closes
func _on_shop_closed() -> void:
	pass

## Purchase an item
func purchase_item(index: int) -> bool:
	if index < 0 or index >= shop_items.size():
		return false

	var item_data = shop_items[index]
	var price = item_data.get("price", 100)

	if player_gold < price:
		return false

	# Deduct gold
	player_gold -= price
	EventBus.gold_amount_updated.emit(player_gold)
	EventBus.item_picked_up.emit(item_data.get("name", "Item"))

	# Apply item effect
	var upgrade = item_data.get("upgrade")
	if upgrade and upgrade is UpgradeData:
		upgrade.apply_upgrade(GameManager.player_stats)
		EventBus.stat_upgraded.emit(upgrade.upgrade_name, 0)

	return true

## Get current gold
func get_gold() -> int:
	return player_gold

## Get shop items
func get_shop_items() -> Array[Dictionary]:
	return shop_items

## Get item price
func get_item_price(index: int) -> int:
	if index >= 0 and index < shop_items.size():
		return shop_items[index].get("price", 100)
	return 0

## Can afford item
func can_afford(index: int) -> bool:
	return player_gold >= get_item_price(index)
