extends Node
## Global event bus for all game signals
## Connect to these signals to respond to game events

# Player events
signal player_damaged(damage: int, health_remaining: int)
signal player_healed(amount: int)
signal player_died
signal player_leveled_up(new_level: int)
signal player_experience_gained(amount: int)
signal stat_upgraded(stat_name: String, new_value: float)

# Enemy events
signal enemy_spawned(enemy: Node)
signal enemy_died(enemy: Node, position: Vector2)
signal enemy_damaged(enemy: Node, damage: int)

# Weapon events
signal weapon_fired(weapon: Node, position: Vector2)
signal projectile_hit(projectile: Node, target: Node)

# Item events
signal coin_collected(amount: int)
signal item_picked_up(item_name: String)

# Wave events
signal wave_started(wave_number: int)
signal wave_completed(wave_number: int)
signal wave_time_updated(time_remaining: float)

# Game state events
signal game_paused
signal game_resumed
signal game_started
signal game_over(stats: Dictionary)

# Shop/Upgrade events
signal shop_opened
signal shop_closed
signal upgrade_panel_opened
signal upgrade_panel_closed
signal upgrade_purchased(upgrade_name: String)

# UI events
signal kill_count_updated(count: int)
signal gold_amount_updated(amount: int)
signal health_updated(current: int, max: int)
signal experience_updated(current: int, max: int)

func _ready() -> void:
	pass
