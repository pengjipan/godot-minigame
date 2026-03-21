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
var debug_fire_count: int = 0

func _ready() -> void:
	print("[Weapon] Weapon initialized at ", global_position)
	fire_cooldown = 1.0 / fire_rate
	# Load default projectile if not set
	if projectile_scene == null:
		projectile_scene = load("res://scenes/weapons/projectile.tscn")
		print("[Weapon] Loaded default projectile scene")
	print("[Weapon] Fire rate: ", fire_rate, " cooldown: ", fire_cooldown)

func _process(delta: float) -> void:
	time_since_fire += delta

	# Auto fire if enabled and cooldown passed
	if can_auto_fire and time_since_fire >= fire_cooldown:
		# Get player position from inventory parent
		var player = get_parent()
		if player:
			player = player.get_parent()  # PlayerInventory -> Player
			if player and player.is_in_group("player"):
				var fire_pos = player.global_position
				if aim_direction.length() > 0:
					fire(fire_pos, aim_direction)
				else:
					print("[Weapon] No aim direction set")

## Set aiming direction
func set_aim_direction(direction: Vector2) -> void:
	if direction.length() > 0:
		aim_direction = direction.normalized()

## Fire weapon
func fire(fire_position: Vector2, direction: Vector2) -> void:
	if time_since_fire < fire_cooldown:
		return

	time_since_fire = 0.0
	debug_fire_count += 1
	print("[Weapon] FIRING #", debug_fire_count, " from ", fire_position, " direction: ", direction)
	_spawn_projectile(fire_position, direction)

## Create a single projectile
func _spawn_projectile(position: Vector2, direction: Vector2) -> void:
	if projectile_scene == null:
		push_error("[Weapon] No projectile scene!")
		return

	print("[Weapon] Creating projectile at ", position, " with direction ", direction)
	var projectile = projectile_scene.instantiate()

	# Add to current scene (game world)
	var game_world = get_tree().current_scene
	if game_world:
		game_world.add_child(projectile)
		print("[Weapon] Added projectile to ", game_world.name)
	else:
		push_error("[Weapon] No current scene!")
		projectile.queue_free()
		return

	# Initialize projectile
	if projectile.has_method("initialize"):
		projectile.initialize(position, direction, projectile_speed, damage)
		print("[Weapon] Initialized projectile at ", projectile.global_position)
	else:
		projectile.global_position = position
		print("[Weapon] Set projectile position to ", projectile.global_position)

	# Verify it's visible
	if projectile.has_node("Sprite"):
		print("[Weapon] Projectile has visible sprite")
	else:
		print("[Weapon] WARNING: Projectile has no sprite!")
