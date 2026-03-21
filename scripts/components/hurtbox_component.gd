extends Area2D
## Hurtbox component for receiving damage
class_name HurtboxComponent

signal damaged(damage: int, source_position: Vector2)

var health_component: HealthComponent = null

func _ready() -> void:
	health_component = get_parent().get_node_or_null("HealthComponent")
	if not health_component:
		push_warning("HurtboxComponent parent missing HealthComponent: ", get_parent().name)

## Take damage from a hitbox or projectile
func take_damage(damage: int, source_position: Vector2 = Vector2.ZERO) -> void:
	if health_component:
		health_component.take_damage(damage)
		damaged.emit(damage, source_position)

		# Apply knockback
		var parent = get_parent()
		if parent and parent.has_method("apply_knockback"):
			var knockback_dir = (parent.global_position - source_position).normalized()
			parent.apply_knockback(knockback_dir * 300.0)

## Check if parent is dead
func is_dead() -> bool:
	if health_component:
		return health_component.is_dead()
	return false
