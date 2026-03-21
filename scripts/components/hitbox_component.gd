extends Area2D
## Hitbox component for dealing damage on contact
class_name HitboxComponent

signal hit(target: Node)

@export var damage: int = 10
@export var knockback_force: float = 200.0
var owner_node: Node = null

func _ready() -> void:
	owner_node = get_parent()
	area_entered.connect(_on_area_entered)
	print("[Hitbox] ", owner_node.name if owner_node else "Unknown", " hitbox ready")

func _on_area_entered(area: Area2D) -> void:
	print("[Hitbox] Detected collision with: ", area.name, " (", area.get_class(), ")")
	if area.name == "HurtboxComponent" or area is HurtboxComponent:
		print("[Hitbox] Dealing ", damage, " damage to ", area.get_parent().name if area.get_parent() else "Unknown")
		area.take_damage(damage, global_position)
		hit.emit(area.get_parent())

## Set damage value
func set_damage(value: int) -> void:
	damage = value

## Get damage value
func get_damage() -> int:
	return damage
