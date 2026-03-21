extends Node
## Melee AI - charges directly at player
class_name MeleeAI

func update(enemy: CharacterBody2D, delta: float) -> void:
	var player_nodes = get_tree().get_nodes_in_group("player")
	if player_nodes.is_empty():
		return

	var player = player_nodes[0]
	var direction = (player.global_position - enemy.global_position).normalized()

	# Get enemy speed
	var speed = 100.0
	if enemy.has_meta("move_speed"):
		speed = enemy.get_meta("move_speed")

	enemy.velocity = direction * speed
