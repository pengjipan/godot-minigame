extends Node2D
## Test scene for weapon firing

@onready var player = $Player
@onready var weapon = $Weapon

func _process(delta: float) -> void:
	# Auto-fire for testing
	if weapon:
		weapon.fire(player.global_position, Vector2.RIGHT)
