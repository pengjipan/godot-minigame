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
	add_to_group("enemies")

	# Get components
	health_component = $HealthComponent
	hurtbox_component = $HurtboxComponent
	hitbox_component = $HitboxComponent

	# Load enemy data or use default
	if enemy_data == null:
		enemy_data = EnemyData.new()

	# Apply enemy stats
	move_speed = enemy_data.move_speed
	damage = enemy_data.damage
	experience_reward = enemy_data.experience_reward
	gold_reward = enemy_data.gold_reward

	if health_component:
		health_component.max_health = enemy_data.max_health
		health_component.reset()

	if hitbox_component:
		hitbox_component.set_damage(damage)

	# Connect signals
	if health_component:
		health_component.health_depleted.connect(_on_death)

	# Set up AI
	_setup_ai()

	EventBus.enemy_spawned.emit(self)

## Set up AI behavior based on type
func _setup_ai() -> void:
	if ai_component:
		ai_component.queue_free()

	var ai_script
	if enemy_data.ai_type == "ranged":
		ai_script = preload("res://scripts/ai/ranged_ai.gd")
	else:
		ai_script = preload("res://scripts/ai/melee_ai.gd")

	ai_component = Node.new()
	ai_component.set_script(ai_script)
	add_child(ai_component)

func _physics_process(delta: float) -> void:
	if not GameManager.is_game_running:
		return

	# AI updates velocity
	if ai_component and ai_component.has_method("update"):
		ai_component.update(self, delta)

	# Apply velocity
	if velocity.length() > 0:
		move_and_slide()

## Apply knockback
func apply_knockback(force: Vector2) -> void:
	velocity += force

## Called when enemy dies
func _on_death() -> void:
	EventBus.enemy_died.emit(self, global_position)
	GameManager.add_run_stat("enemies_killed", 1)

	# Drop items
	_drop_rewards()

	queue_free()

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
