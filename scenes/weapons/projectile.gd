extends Area2D
## Projectile that damages enemies
class_name Projectile

var direction: Vector2 = Vector2.RIGHT
var speed: float = 400.0
var damage: int = 10
var pierce_count: int = 1
var explosion_radius: float = 0.0
var owner_player: Node = null
var hit_count: int = 0
var debug_timer: float = 0.0
var world_bounds: Rect2 = Rect2(-200, -200, 1480, 2320)  # 会在_ready中动态计算

func _ready() -> void:
	print("[Projectile] ============ Projectile _ready START ============")
	print("[Projectile] Initial global_position: ", global_position)
	print("[Projectile] Parent: ", get_parent().name if get_parent() else "NO PARENT")

	# Calculate dynamic world bounds
	# Use a large margin (300) so projectiles can travel off-screen before being destroyed
	var player_nodes = get_tree().get_nodes_in_group("player")
	if not player_nodes.is_empty() and player_nodes[0].has_node("Camera2D"):
		var camera = player_nodes[0].get_node("Camera2D")
		world_bounds = ScreenUtils.calculate_world_bounds(get_viewport(), camera.zoom, 300.0)
		print("[Projectile] Dynamic world bounds: ", world_bounds)
	else:
		# Fallback: use reference resolution with large margin
		world_bounds = Rect2(-300, -300, REFERENCE_WIDTH + 600, REFERENCE_HEIGHT + 600)
		print("[Projectile] Using fallback world bounds: ", world_bounds)

	# Connect signals
	area_entered.connect(_on_area_entered)
	body_entered.connect(_on_body_entered)

	# Debug collision properties
	print("[Projectile] Monitoring: ", monitoring, " Monitorable: ", monitorable)
	print("[Projectile] Layer: ", collision_layer, " Mask: ", collision_mask)

	# Check collision shape BEFORE set_as_top_level
	if has_node("CollisionShape2D"):
		var shape_node = get_node("CollisionShape2D")
		print("[Projectile] CollisionShape2D found!")
		print("[Projectile]   Disabled: ", shape_node.disabled)
		if shape_node.shape:
			print("[Projectile]   Shape: ", shape_node.shape.get_class())
			if shape_node.shape is CircleShape2D:
				print("[Projectile]   Radius: ", shape_node.shape.radius)
		else:
			print("[Projectile]   ERROR: No shape assigned!")
	else:
		print("[Projectile] ERROR: CollisionShape2D NOT FOUND!")

	# DON'T call set_as_top_level here - do it after position is set in initialize()
	print("[Projectile] ============ Projectile _ready END ============")

const REFERENCE_WIDTH: float = 1080.0
const REFERENCE_HEIGHT: float = 1920.0

func _process(delta: float) -> void:
	# Move projectile
	var old_pos = global_position
	global_position += direction * speed * delta

	# Debug: print position periodically
	debug_timer += delta
	if debug_timer >= 1.0:  # Every 1 second
		debug_timer = 0.0
		print("[Projectile] Alive! Position: ", global_position, " Direction: ", direction, " Speed: ", speed)
		print("[Projectile]   Movement: ", old_pos, " -> ", global_position, " (delta: ", global_position - old_pos, ")")

	# Destroy if off screen - use dynamic world bounds
	if global_position.x < world_bounds.position.x or global_position.x > world_bounds.position.x + world_bounds.size.x or \
	   global_position.y < world_bounds.position.y or global_position.y > world_bounds.position.y + world_bounds.size.y:
		print("[Projectile] *** OFF SCREEN, destroying at ", global_position, " (bounds: ", world_bounds, ")")
		queue_free()

## Initialize projectile
func initialize(start_position: Vector2, proj_direction: Vector2, proj_speed: float = 500.0, proj_damage: int = 10, proj_pierce: int = 1, explosion_rad: float = 0.0) -> void:
	print("[Projectile] ============ Initialize START ============")
	print("[Projectile] Start position: ", start_position)
	print("[Projectile] Direction: ", proj_direction)

	# IMPORTANT: Set as top level FIRST so position is in world space
	set_as_top_level(true)
	print("[Projectile] Set as top level")

	# Now set the position
	global_position = start_position
	print("[Projectile] After setting position, global_position = ", global_position)

	direction = proj_direction.normalized()
	speed = proj_speed
	damage = proj_damage
	pierce_count = proj_pierce
	explosion_radius = explosion_rad
	rotation = direction.angle()

	print("[Projectile] Speed: ", speed)
	print("[Projectile] Damage: ", damage)
	print("[Projectile] Pierce: ", pierce_count)
	print("[Projectile] Explosion radius: ", explosion_radius)
	print("[Projectile] ============ Initialize END ============")

func _on_body_entered(body: Node2D) -> void:
	print("[Projectile] *** HIT BODY: ", body.name)

func _on_area_entered(area: Area2D) -> void:
	print("[Projectile] *** HIT AREA: ", area.name, " (layer:", area.collision_layer, ")")
	var parent = area.get_parent()
	if parent:
		print("[Projectile]     Parent: ", parent.name, " is_enemy:", parent.is_in_group("enemies"))

	# Check if it's an enemy hurtbox
	if area.name == "HurtboxComponent":
		if parent and parent.is_in_group("enemies"):
			print("[Projectile] >>> DAMAGING ENEMY: ", parent.name)
			if area.has_method("take_damage"):
				area.take_damage(damage, global_position)
				print("[Projectile] >>> Damage dealt!")
			elif parent.has_method("take_damage"):
				parent.take_damage(damage)
				print("[Projectile] >>> Damage dealt via parent!")

			# Check for explosion
			if explosion_radius > 0.0:
				_create_explosion()
				return  # Explosion destroys projectile immediately

			hit_count += 1
			if hit_count >= pierce_count:
				print("[Projectile] >>> Destroying projectile")
				queue_free()
		else:
			print("[Projectile] Area is hurtbox but parent not enemy or no parent")
	else:
		print("[Projectile] Area name is ", area.name, " not 'HurtboxComponent'")

func _create_explosion() -> void:
	print("[Projectile] Creating explosion at ", global_position, " with radius ", explosion_radius)
	var explosion_area = Area2D.new()
	explosion_area.global_position = global_position
	explosion_area.collision_layer = 0
	explosion_area.collision_mask = 4  # Enemy layer

	var shape = CircleShape2D.new()
	shape.radius = explosion_radius

	var collision = CollisionShape2D.new()
	collision.shape = shape
	explosion_area.add_child(collision)

	# Add to scene
	get_parent().add_child(explosion_area)

	# Wait for physics frame to detect overlaps
	await get_tree().physics_frame

	# Damage all enemies in radius
	var overlapping = explosion_area.get_overlapping_areas()
	print("[Projectile] Explosion detected ", overlapping.size(), " overlapping areas")
	for area in overlapping:
		if area.name == "HurtboxComponent":
			var enemy_parent = area.get_parent()
			if enemy_parent and enemy_parent.is_in_group("enemies"):
				if area.has_method("take_damage"):
					area.take_damage(damage, global_position)
					print("[Projectile] Explosion hit: %s" % enemy_parent.name)

	# Clean up
	explosion_area.queue_free()
	queue_free()
