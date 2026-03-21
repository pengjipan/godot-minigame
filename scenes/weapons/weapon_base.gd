extends Node2D
## Base weapon class
class_name Weapon

@export var damage: int = 10
@export var fire_rate: float = 2.0  # shots per second
@export var projectile_speed: float = 500.0
@export var projectile_scene: PackedScene = null

var aim_direction: Vector2 = Vector2.RIGHT
var fire_cooldown: float = 0.5
var time_since_fire: float = 0.0
var can_auto_fire: bool = true

func _ready() -> void:
	print("[Weapon] Weapon initialized")
	fire_cooldown = 1.0 / fire_rate
	# Load default projectile if not set
	if projectile_scene == null:
		projectile_scene = load("res://scenes/weapons/projectile.tscn")
		print("[Weapon] Loaded default projectile scene")

func _process(delta: float) -> void:
	time_since_fire += delta

	# Auto fire if enabled and cooldown passed
	if can_auto_fire and time_since_fire >= fire_cooldown:
		# Get player position from inventory parent
		var player = get_parent()
		if player:
			player = player.get_parent()  # PlayerInventory -> Player
			if player and player.has_method("get_global_position"):
				var fire_pos = player.global_position
				fire(fire_pos, aim_direction)
			else:
				print("[Weapon] Warning: Could not get player position")

## Set aiming direction
func set_aim_direction(direction: Vector2) -> void:
	if direction.length() > 0:
		aim_direction = direction.normalized()

## Fire weapon
func fire(fire_position: Vector2, direction: Vector2) -> void:
	if time_since_fire < fire_cooldown:
		return

	time_since_fire = 0.0
	_spawn_projectile(fire_position, direction)
	print("[Weapon] Fired projectile from ", fire_position, " in direction ", direction)

## Create a single projectile
func _spawn_projectile(position: Vector2, direction: Vector2) -> void:
	if projectile_scene == null:
		push_error("[Weapon] No projectile scene!")
		return

	var projectile = projectile_scene.instantiate()
	get_tree().current_scene.add_child(projectile)

	# Initialize projectile
	if projectile.has_method("initialize"):
		projectile.initialize(position, direction, projectile_speed, damage)
	else:
		projectile.global_position = position
		if projectile.has_method("set_direction"):
			projectile.set_direction(direction)

	print("[Weapon] Spawned projectile at ", position)
