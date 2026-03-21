extends CharacterBody2D
## Main player controller
class_name Player

@export var character_data: CharacterData = null
@export var camera_smoothing: float = 0.1

var move_speed: float = 200.0
var current_velocity: Vector2 = Vector2.ZERO
var joystick_input: Vector2 = Vector2.ZERO

var health_component: HealthComponent = null
var hurtbox_component: HurtboxComponent = null
var inventory: Node = null
var camera: Camera2D = null

var nearest_enemy: Node2D = null
var last_damage_time: float = 0.0
var damage_flash_duration: float = 0.1

func _ready() -> void:
	print("[Player] Initializing player...")
	add_to_group("player")

	# Get components
	health_component = $HealthComponent
	hurtbox_component = $HurtboxComponent
	camera = $Camera2D
	inventory = $PlayerInventory

	print("[Player] Components: Health=", health_component != null, " Camera=", camera != null)

	# Load character data or use default
	if character_data == null:
		print("[Player] No character data, using default")
		character_data = CharacterData.new()

	# Apply character stats
	move_speed = character_data.move_speed
	print("[Player] Move speed: ", move_speed)

	if health_component:
		health_component.max_health = character_data.max_health
		health_component.reset()
		print("[Player] Health: ", health_component.current_health, "/", health_component.max_health)

	# Connect signals
	if health_component:
		health_component.health_depleted.connect(_on_death)
		health_component.health_changed.connect(_on_health_changed)

		# Emit initial health
		EventBus.health_updated.emit(health_component.current_health, health_component.max_health)

	# Start targeting system
	set_process(true)

	# Center camera on player
	if camera:
		camera.global_position = global_position

	print("[Player] Player ready at position: ", global_position)

func _process(delta: float) -> void:
	if not GameManager.is_game_running:
		return

	# Find nearest enemy for aiming
	_update_nearest_enemy()

	# Update weapon aiming
	if inventory and nearest_enemy:
		var aim_direction = (nearest_enemy.global_position - global_position).normalized()
		inventory.set_aim_direction(aim_direction)

	# Smooth camera follow
	if camera:
		camera.global_position = camera.global_position.lerp(global_position, camera_smoothing)

func _physics_process(delta: float) -> void:
	if not GameManager.is_game_running:
		return

	# Get input from joystick OR keyboard (for testing)
	var input_dir = joystick_input
	if input_dir.length() == 0:
		# Fallback to keyboard for testing
		input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
		if input_dir.length() > 0:
			print("[Player] Using keyboard input: ", input_dir)

	# Apply velocity and move
	velocity = input_dir * move_speed
	move_and_slide()

## Set joystick input from UI
func set_joystick_input(input_vec: Vector2) -> void:
	joystick_input = input_vec

## Find nearest enemy for auto-aim
func _update_nearest_enemy() -> void:
	var enemies = get_tree().get_nodes_in_group("enemies")
	if enemies.is_empty():
		nearest_enemy = null
		return

	var min_distance = INF
	var closest: Node2D = null

	for enemy in enemies:
		if not is_instance_valid(enemy):
			continue
		var dist = global_position.distance_squared_to(enemy.global_position)
		if dist < min_distance:
			min_distance = dist
			closest = enemy

	nearest_enemy = closest

## Called when player takes damage
func _on_health_changed(current: int, max: int) -> void:
	EventBus.health_updated.emit(current, max)
	EventBus.player_damaged.emit(current, max)
	last_damage_time = Time.get_ticks_msec() / 1000.0

## Called when player dies
func _on_death() -> void:
	EventBus.player_died.emit()
	GameManager.end_run()
	queue_free()

## Apply knockback to player
func apply_knockback(force: Vector2) -> void:
	velocity += force
