extends Resource
## Weapon data definition
class_name WeaponData

@export var weapon_name: String = "Basic Gun"
@export var description: String = ""
@export var damage: int = 10
@export var fire_rate: float = 2.0  # shots per second
@export var projectile_speed: float = 400.0
@export var projectile_count: int = 1  # bullets per shot
@export var spread_angle: float = 0.0  # degrees
@export var pierce_count: int = 1  # how many enemies can one bullet pierce
@export var knockback: float = 200.0
@export var weapon_icon: String = ""
@export var projectile_scene: String = "res://scenes/weapons/projectile.tscn"
@export var weapon_tags: Array[String] = []  # e.g., ["RAPID_FIRE", "BURST"]
@export var shop_price: int = 100
@export var magazine_size: int = 6
@export var reload_time: float = 2.0
@export var is_sustained: bool = false  # true for Flamethrower, Minigun
@export var explosion_radius: float = 0.0  # for Grenade Launcher

## Get fire cooldown in seconds
func get_fire_cooldown() -> float:
	return 1.0 / max(fire_rate, 0.1)

## Get spread angle in radians for each projectile
func get_spread_angles() -> Array:
	var angles: Array = []
	if projectile_count == 1:
		angles.append(0.0)
	else:
		var total_spread = deg_to_rad(spread_angle)
		var angle_step = total_spread / (projectile_count - 1)
		for i in range(projectile_count):
			angles.append(-total_spread / 2.0 + angle_step * i)
	return angles
