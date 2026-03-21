extends Node
## Manages shop and item purchasing
class_name ShopSystem

@export var shop_items: Array[Dictionary] = []  # {item: UpgradeData, price: int}

var player_gold: int = 0
var current_gold: int = 0
var refresh_count: int = 0
var weapon_pool: Array[WeaponData] = []

func _ready() -> void:
	_load_weapon_pool()
	EventBus.coin_collected.connect(_on_coin_collected)
	EventBus.shop_opened.connect(_on_shop_opened)
	EventBus.shop_closed.connect(_on_shop_closed)

func _load_weapon_pool() -> void:
	weapon_pool = [
		load("res://resources/weapons/pistol.tres"),
		load("res://resources/weapons/smg.tres"),
		load("res://resources/weapons/shotgun.tres"),
		load("res://resources/weapons/assault_rifle.tres"),
		load("res://resources/weapons/sniper.tres"),
		load("res://resources/weapons/flamethrower.tres"),
		load("res://resources/weapons/grenade_launcher.tres"),
		load("res://resources/weapons/minigun.tres")
	]
	print("[ShopSystem] Loaded %d weapons" % weapon_pool.size())

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

## Get refresh cost (first refresh free, then scales with wave)
func get_refresh_cost() -> int:
	if refresh_count == 0:
		return 0  # First refresh free

	var wave = GameManager.current_wave
	return wave * 5 * refresh_count

## Purchase refresh
func purchase_refresh(owned_weapons: Array[WeaponData]) -> bool:
	var cost = get_refresh_cost()

	# Check gold
	if player_gold < cost:
		print("[ShopSystem] Not enough gold for refresh (need %d)" % cost)
		return false

	# Deduct gold
	player_gold -= cost
	refresh_count += 1
	EventBus.gold_amount_updated.emit(player_gold)

	# Refresh shop items
	refresh_shop(owned_weapons)

	print("[ShopSystem] Shop refreshed (cost: %d, count: %d)" % [cost, refresh_count])
	return true

## Refresh shop with new items
func refresh_shop(owned_weapons: Array[WeaponData]) -> void:
	shop_items.clear()

	# Filter out owned weapons
	var available = []
	for weapon in weapon_pool:
		if not owned_weapons.has(weapon):
			available.append(weapon)

	# Shuffle and pick 4
	available.shuffle()
	for i in range(min(4, available.size())):
		shop_items.append(available[i])

	print("[ShopSystem] Shop refreshed with %d items" % shop_items.size())

## Reset refresh counter (called at wave start)
func reset_refresh_count() -> void:
	refresh_count = 0
