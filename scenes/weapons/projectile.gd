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
	area_entered.connect(_on_area_entered)
	set_as_top_level(true)

func _process(delta: float) -> void:
	# Move projectile
	global_position += direction * speed * delta

	# Destroy if off screen
	if not get_viewport().get_visible_rect().has_point(global_position):
		queue_free()

## Initialize projectile
func initialize(start_position: Vector2, proj_direction: Vector2, weapon_data: WeaponData) -> void:
	global_position = start_position
	direction = proj_direction.normalized()
	speed = weapon_data.projectile_speed
	damage = weapon_data.damage
	pierce_count = weapon_data.pierce_count
	owner_player = get_tree().get_nodes_in_group("player")[0] if get_tree().get_nodes_in_group("player") else null
	rotation = direction.angle()

func _on_area_entered(area: Area2D) -> void:
	# Check if it's an enemy hurtbox
	if area is HurtboxComponent:
		var parent = area.get_parent()
		if parent and parent != owner_player:
			area.take_damage(damage, global_position)
			EventBus.projectile_hit.emit(self, parent)
			hit_count += 1

			if hit_count >= pierce_count:
				queue_free()

## Reset projectile for object pool
func reset() -> void:
	direction = Vector2.RIGHT
	speed = 400.0
	damage = 10
	pierce_count = 1
	owner_player = null
	hit_count = 0
