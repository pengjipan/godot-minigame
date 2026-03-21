extends CharacterBody2D
## Base enemy class
class_name Enemy

@export var enemy_data: EnemyData = null

var health_component: HealthComponent = null
var hurtbox_component: HurtboxComponent = null
var hitbox_component: HitboxComponent = null
var ai_component: Node = null

var move_speed: float = 100.0
var damage: int = 5
var experience_reward: int = 10
var gold_reward: int = 5

func _ready() -> void:
	print("[Enemy] Spawning enemy at ", global_position)
	add_to_group("enemies")

	# Get components
	health_component = $HealthComponent
	hurtbox_component = $HurtboxComponent
	hitbox_component = $HitboxComponent

	# Use default values for now
	move_speed = 100.0
	damage = 5
	experience_reward = 10
	gold_reward = 5

	# Set up health
	if health_component:
		health_component.max_health = 20
		health_component.reset()
		health_component.health_depleted.connect(_on_death)
		print("[Enemy] Health component initialized")
	else:
		push_error("[Enemy] HealthComponent not found!")

	if hitbox_component:
		hitbox_component.set_damage(damage)

	# Verify hurtbox collision shape
	if hurtbox_component and hurtbox_component.has_node("HurtboxCollisionShape"):
		var shape_node = hurtbox_component.get_node("HurtboxCollisionShape")
		print("[Enemy] Hurtbox collision shape exists, disabled=", shape_node.disabled)
		if shape_node.shape:
			print("[Enemy] Hurtbox shape: ", shape_node.shape.get_class())
		else:
			print("[Enemy] WARNING: Hurtbox has no shape!")
	else:
		print("[Enemy] WARNING: No hurtbox collision shape!")

	# Set up simple AI
	_setup_simple_ai()

	print("[Enemy] Enemy ready at ", global_position, ", health: ", health_component.current_health if health_component else "N/A")

## Set up simple AI that chases player
func _setup_simple_ai() -> void:
	# Simple built-in AI - chase player
	set_physics_process(true)

## Set up AI behavior based on type
func _setup_ai() -> void:
	if ai_component:
		ai_component.queue_free()

	var ai_script
	if enemy_data and enemy_data.ai_type == "ranged":
		ai_script = preload("res://scripts/ai/ranged_ai.gd")
	else:
		ai_script = preload("res://scripts/ai/melee_ai.gd")

	ai_component = Node.new()
	ai_component.set_script(ai_script)
	add_child(ai_component)

func _physics_process(delta: float) -> void:
	if not GameManager.is_game_running:
		return

	# Simple AI: chase player
	var player_nodes = get_tree().get_nodes_in_group("player")
	if player_nodes.is_empty():
		return

	var player = player_nodes[0]
	var direction = (player.global_position - global_position).normalized()
	velocity = direction * move_speed
	move_and_slide()

## Apply knockback
func apply_knockback(force: Vector2) -> void:
	velocity += force

## Called when enemy dies
func _on_death() -> void:
	print("[Enemy] Enemy died at ", global_position)
	EventBus.enemy_died.emit(self, global_position)
	GameManager.add_run_stat("enemies_killed", 1)

	# Drop items
	_drop_rewards()

	queue_free()

## Take damage (for direct damage calls)
func take_damage(amount: int) -> void:
	if health_component:
		health_component.take_damage(amount)
		# Flash red when damaged
		if has_node("Sprite"):
			var sprite = get_node("Sprite")
			sprite.modulate = Color(1, 0.5, 0.5)
			await get_tree().create_timer(0.1).timeout
			if is_instance_valid(sprite):
				sprite.modulate = Color(1, 1, 1)

## Drop experience and gold
func _drop_rewards() -> void:
	# Drop experience gem
	if ResourceLoader.exists("res://scenes/items/experience_gem.tscn"):
		var exp_gem = load("res://scenes/items/experience_gem.tscn").instantiate()
		get_parent().add_child(exp_gem)
		exp_gem.global_position = global_position
		exp_gem.set_value(experience_reward)

	# Drop gold
	if ResourceLoader.exists("res://scenes/items/coin_pickup.tscn"):
		var coin = load("res://scenes/items/coin_pickup.tscn").instantiate()
		get_parent().add_child(coin)
		coin.global_position = global_position
		coin.set_value(gold_reward)
