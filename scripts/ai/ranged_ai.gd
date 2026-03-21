extends Node
## Ranged AI - maintains distance and shoots
class_name RangedAI

var maintain_distance: float = 300.0
var can_fire: bool = true
var fire_cooldown: float = 1.0
var fire_timer: float = 0.0

func update(enemy: CharacterBody2D, delta: float) -> void:
	var player_nodes = get_tree().get_nodes_in_group("player")
	if player_nodes.is_empty():
		return

	var player = player_nodes[0]
	var direction = (player.global_position - enemy.global_position)
	var distance = direction.length()

	# Get enemy speed
	var speed = 80.0
	if enemy.has_meta("move_speed"):
		speed = enemy.get_meta("move_speed")

	# Keep distance
	if distance > maintain_distance:
		enemy.velocity = direction.normalized() * speed
	elif distance < maintain_distance - 50:
		enemy.velocity = -direction.normalized() * speed * 0.5
	else:
		enemy.velocity = enemy.velocity.lerp(Vector2.ZERO, 0.1)

	# Fire periodically
	fire_timer += delta
	if fire_timer >= fire_cooldown:
		fire_timer = 0.0
		# Fire at player (implementation depends on weapon system)
