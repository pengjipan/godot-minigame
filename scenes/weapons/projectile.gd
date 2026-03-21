extends Area2D
## Projectile that damages enemies
class_name Projectile

var direction: Vector2 = Vector2.RIGHT
var speed: float = 400.0
var damage: int = 10
var pierce_count: int = 1
var owner_player: Node = null
var hit_count: int = 0

func _ready() -> void:
	print("[Projectile] Projectile _ready at ", global_position)
	area_entered.connect(_on_area_entered)
	body_entered.connect(_on_body_entered)
	set_as_top_level(true)

	# Debug info
	print("[Projectile] Monitoring: ", monitoring, " Monitorable: ", monitorable)
	print("[Projectile] Layer: ", collision_layer, " Mask: ", collision_mask)

func _process(delta: float) -> void:
	# Move projectile
	global_position += direction * speed * delta

	# Destroy if off screen
	var viewport_rect = get_viewport_rect()
	if global_position.x < -100 or global_position.x > viewport_rect.size.x + 100 or \
	   global_position.y < -100 or global_position.y > viewport_rect.size.y + 100:
		queue_free()

## Initialize projectile
func initialize(start_position: Vector2, proj_direction: Vector2, proj_speed: float = 500.0, proj_damage: int = 10) -> void:
	global_position = start_position
	direction = proj_direction.normalized()
	speed = proj_speed
	damage = proj_damage
	pierce_count = 1
	owner_player = get_tree().get_nodes_in_group("player")[0] if get_tree().get_nodes_in_group("player").size() > 0 else null
	rotation = direction.angle()
	print("[Projectile] Initialized at pos=", start_position, " dir=", direction)

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
