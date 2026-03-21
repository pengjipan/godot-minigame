extends Resource
class_name WaveConfig
## Configuration for a specific wave

@export var wave_number: int = 1
@export var enemy_count: int = 15
@export var spawn_rate: float = 1.5  # Seconds between spawns
@export var spawn_distance_min: float = 300.0
@export var spawn_distance_max: float = 500.0

# Enemy multipliers
@export var enemy_health_mult: float = 1.0
@export var enemy_damage_mult: float = 1.0
@export var enemy_speed_mult: float = 1.0

# Reward multipliers
@export var gold_mult: float = 1.0
@export var xp_mult: float = 1.0

# Shop settings
@export var shop_refresh_cost_increment: int = 5  # Cost per refresh
