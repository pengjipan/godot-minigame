extends Node
## Generic health component for any entity (player, enemies, etc.)
class_name HealthComponent

signal health_changed(current: int, max: int)
signal health_depleted

@export var max_health: int = 100
var current_health: int

func _ready() -> void:
	current_health = max_health

## Take damage
func take_damage(damage: int) -> void:
	current_health = max(0, current_health - damage)
	health_changed.emit(current_health, max_health)

	if current_health <= 0:
		health_depleted.emit()

## Heal
func heal(amount: int) -> void:
	current_health = min(max_health, current_health + amount)
	health_changed.emit(current_health, max_health)

## Set health directly
func set_health(amount: int) -> void:
	current_health = clamp(amount, 0, max_health)
	health_changed.emit(current_health, max_health)

## Get health percentage (0.0 to 1.0)
func get_health_percent() -> float:
	return float(current_health) / float(max_health)

## Check if dead
func is_dead() -> bool:
	return current_health <= 0

## Reset to max health
func reset() -> void:
	set_health(max_health)
