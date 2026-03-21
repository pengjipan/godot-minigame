extends Node2D
## Base weapon class
class_name Weapon

@export var weapon_data: WeaponData = null

var aim_direction: Vector2 = Vector2.RIGHT
var fire_cooldown: float = 0.0
var time_since_fire: float = 0.0

func _ready() -> void:
	if weapon_data == null:
		weapon_data = WeaponData.new()
	fire_cooldown = weapon_data.get_fire_cooldown()

func _process(delta: float) -> void:
	time_since_fire += delta

## Set weapon data
func set_weapon_data(data: WeaponData) -> void:
	weapon_data = data
	fire_cooldown = weapon_data.get_fire_cooldown()

## Set aiming direction
func set_aim_direction(direction: Vector2) -> void:
	aim_direction = direction.normalized()
	rotation = aim_direction.angle()

## Fire weapon
func fire(fire_position: Vector2, direction: Vector2) -> void:
	if time_since_fire < fire_cooldown:
		return

	time_since_fire = 0.0
	_spawn_projectiles(fire_position, direction)
	EventBus.weapon_fired.emit(self, fire_position)

## Spawn projectiles
func _spawn_projectiles(fire_position: Vector2, direction: Vector2) -> void:
	var spread_angles = weapon_data.get_spread_angles()

	for angle_offset in spread_angles:
		var projectile_direction = direction.rotated(angle_offset)
		_create_projectile(fire_position, projectile_direction)

## Create a single projectile
func _create_projectile(position: Vector2, direction: Vector2) -> void:
	if not ResourceLoader.exists(weapon_data.projectile_scene):
		push_error("Projectile scene not found: ", weapon_data.projectile_scene)
		return

	var projectile = load(weapon_data.projectile_scene).instantiate()
	get_tree().root.add_child(projectile)
	projectile.initialize(position, direction, weapon_data)
