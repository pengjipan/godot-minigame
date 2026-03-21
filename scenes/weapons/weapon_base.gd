extends Node2D
## Base weapon class
class_name Weapon

const INFINITE_AMMO: int = -1

@export var damage: int = 10
@export var fire_rate: float = 1.0  # shots per second (1秒1发)
@export var projectile_speed: float = 500.0
@export var projectile_scene: PackedScene = null
@export var magazine_size: int = 6  # 弹匣容量
@export var reload_time: float = 3.0  # 装填时间（秒）
@export var weapon_data: WeaponData = null

# Base stats (stored for recalculation)
var base_damage: int = 10
var base_fire_rate: float = 1.0
var base_reload_time: float = 3.0
var base_pierce_count: int = 1
var base_projectile_count: int = 1
var base_knockback: float = 200.0

var aim_direction: Vector2 = Vector2.RIGHT
var fire_cooldown: float = 1.0
var time_since_fire: float = 0.0
var can_auto_fire: bool = true
var debug_fire_count: int = 0

# Weapon stats
var pierce_count: int = 1
var projectile_count: int = 1
var knockback: float = 200.0

# 弹匣系统
var current_ammo: int = 6
var is_reloading: bool = false
var reload_timer: float = 0.0

func _ready() -> void:
	print("[Weapon] Weapon initialized at ", global_position)
	fire_cooldown = 1.0 / max(fire_rate, 0.1)
	current_ammo = magazine_size  # 初始满弹

	# Load default projectile if not set
	if projectile_scene == null:
		projectile_scene = load("res://scenes/weapons/projectile.tscn")
		print("[Weapon] Loaded default projectile scene")

	# Load stats from weapon_data if present
	if weapon_data:
		base_damage = weapon_data.damage
		base_fire_rate = weapon_data.fire_rate
		base_reload_time = weapon_data.reload_time if "reload_time" in weapon_data else 3.0
		base_pierce_count = weapon_data.pierce_count
		base_projectile_count = weapon_data.projectile_count
		base_knockback = weapon_data.knockback

		# Apply base values
		damage = base_damage
		fire_rate = base_fire_rate
		reload_time = base_reload_time
		pierce_count = base_pierce_count
		projectile_count = base_projectile_count
		knockback = base_knockback

		# Update derived values
		fire_cooldown = 1.0 / max(fire_rate, 0.1)

		# Handle magazine
		if "magazine_size" in weapon_data and weapon_data.magazine_size > 0:
			magazine_size = weapon_data.magazine_size
			current_ammo = magazine_size

		# Handle sustained weapons (no reload)
		if "is_sustained" in weapon_data and weapon_data.is_sustained:
			magazine_size = INFINITE_AMMO
			current_ammo = 999  # Large number for display/UI purposes

	print("[Weapon] Fire rate: ", fire_rate, " cooldown: ", fire_cooldown)
	print("[Weapon] Magazine: ", magazine_size, " Reload time: ", reload_time, "s")

## Apply synergy bonuses to weapon stats
func apply_synergies(synergies: Dictionary) -> void:
	# Apply multiplicative bonuses
	damage = int(base_damage * synergies.get("damage_mult", 1.0))
	fire_rate = base_fire_rate * synergies.get("fire_rate_mult", 1.0)
	reload_time = base_reload_time * synergies.get("reload_speed_mult", 1.0)

	# Apply additive bonuses
	pierce_count = base_pierce_count + synergies.get("pierce_bonus", 0)
	projectile_count = base_projectile_count + synergies.get("projectile_count_bonus", 0)
	knockback = base_knockback * synergies.get("knockback_mult", 1.0)

	# Update fire cooldown
	fire_cooldown = 1.0 / max(fire_rate, 0.1)

	print("[Weapon] Synergies applied: dmg=%d fire_rate=%.2f reload=%.2f pierce=%d proj=%d" %
		[damage, fire_rate, reload_time, pierce_count, projectile_count])

func _process(delta: float) -> void:
	# 处理装填
	if is_reloading:
		reload_timer += delta
		if reload_timer >= reload_time:
			# 装填完成
			is_reloading = false
			reload_timer = 0.0
			current_ammo = magazine_size
			print("[Weapon] *** 装填完成！弹药: ", current_ammo, "/", magazine_size)
			EventBus.weapon_reloaded.emit()
		return  # 装填期间不射击

	time_since_fire += delta

	# Auto fire if enabled, cooldown passed, and has ammo
	if can_auto_fire and time_since_fire >= fire_cooldown and current_ammo > 0:
		# Get player position from inventory parent
		var player = get_parent()
		if player:
			player = player.get_parent()  # PlayerInventory -> Player
			if player and player.is_in_group("player"):
				var fire_pos = player.global_position
				if aim_direction.length() > 0:
					fire(fire_pos, aim_direction)
				else:
					print("[Weapon] No aim direction set")

## Set aiming direction
func set_aim_direction(direction: Vector2) -> void:
	if direction.length() > 0:
		aim_direction = direction.normalized()

## Fire weapon
func fire(fire_position: Vector2, direction: Vector2) -> void:
	if time_since_fire < fire_cooldown:
		return

	# 检查弹药
	if current_ammo <= 0:
		print("[Weapon] 弹药耗尽，开始装填...")
		_start_reload()
		return

	time_since_fire = 0.0
	current_ammo -= 1  # 消耗弹药
	debug_fire_count += 1

	print("[Weapon] FIRING #", debug_fire_count, " from ", fire_position, " 剩余弹药: ", current_ammo, "/", magazine_size)
	_spawn_projectile(fire_position, direction)

	# 发射完最后一发后自动开始装填
	if current_ammo <= 0:
		print("[Weapon] 弹匣打空，开始自动装填...")
		_start_reload()

## 开始装填
func _start_reload() -> void:
	if is_reloading:
		return
	is_reloading = true
	reload_timer = 0.0
	print("[Weapon] *** 开始装填... 需要 ", reload_time, " 秒")

## Create a single projectile
func _spawn_projectile(position: Vector2, direction: Vector2) -> void:
	if projectile_scene == null:
		push_error("[Weapon] No projectile scene!")
		return

	print("[Weapon] Creating projectile at ", position, " with direction ", direction)
	var projectile = projectile_scene.instantiate()

	# Add to current scene (game world)
	var game_world = get_tree().current_scene
	if game_world:
		game_world.add_child(projectile)
		print("[Weapon] Added projectile to ", game_world.name)
	else:
		push_error("[Weapon] No current scene!")
		projectile.queue_free()
		return

	# Initialize projectile
	if projectile.has_method("initialize"):
		projectile.initialize(position, direction, projectile_speed, damage)
		print("[Weapon] Initialized projectile at ", projectile.global_position)
	else:
		projectile.global_position = position
		print("[Weapon] Set projectile position to ", projectile.global_position)

	# Verify it's visible
	if projectile.has_node("Sprite"):
		print("[Weapon] Projectile has visible sprite")
	else:
		print("[Weapon] WARNING: Projectile has no sprite!")
