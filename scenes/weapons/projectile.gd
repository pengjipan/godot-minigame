extends Area2D
## Projectile that damages enemies
class_name Projectile

var direction: Vector2 = Vector2.RIGHT
var speed: float = 400.0
var damage: int = 10
var pierce_count: int = 1
var owner_player: Node = null
var hit_count: int = 0
var debug_timer: float = 0.0

func _ready() -> void:
	print("[Projectile] ============ Projectile _ready START ============")
	print("[Projectile] Initial global_position: ", global_position)
	print("[Projectile] Parent: ", get_parent().name if get_parent() else "NO PARENT")

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

	# Destroy if off screen
	var viewport_rect = get_viewport_rect()
	if global_position.x < -100 or global_position.x > viewport_rect.size.x + 100 or \
	   global_position.y < -100 or global_position.y > viewport_rect.size.y + 100:
		print("[Projectile] *** OFF SCREEN, destroying at ", global_position)
		print("[Projectile]   Viewport size: ", viewport_rect.size)
		queue_free()

## Initialize projectile
func initialize(start_position: Vector2, proj_direction: Vector2, proj_speed: float = 500.0, proj_damage: int = 10) -> void:
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
	pierce_count = 1
	rotation = direction.angle()

	print("[Projectile] Speed: ", speed)
	print("[Projectile] Damage: ", damage)
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

			hit_count += 1
			if hit_count >= pierce_count:
				print("[Projectile] >>> Destroying projectile")
				queue_free()
		else:
			print("[Projectile] Area is hurtbox but parent not enemy or no parent")
	else:
		print("[Projectile] Area name is ", area.name, " not 'HurtboxComponent'")
