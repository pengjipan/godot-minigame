extends Node2D

func _ready():
	print("=== WEAPON SYSTEM TEST ===")

	# Test 1: Load projectile scene
	print("\n[TEST 1] Loading projectile scene...")
	var proj_scene = load("res://scenes/weapons/projectile.tscn")
	if proj_scene:
		print("✓ Projectile scene loaded")
		var proj = proj_scene.instantiate()
		add_child(proj)
		proj.global_position = Vector2(100, 100)
		proj.initialize(Vector2(100, 100), Vector2.RIGHT, 300, 10)
		print("✓ Test projectile created at ", proj.global_position)
	else:
		print("✗ Failed to load projectile scene")

	# Test 2: Load weapon scene
	print("\n[TEST 2] Loading weapon scene...")
	var weapon_scene = load("res://scenes/weapons/weapon_base.tscn")
	if weapon_scene:
		print("✓ Weapon scene loaded")
		var weapon = weapon_scene.instantiate()
		add_child(weapon)
		print("✓ Weapon created")
		print("  - Can auto fire: ", weapon.can_auto_fire)
		print("  - Fire rate: ", weapon.fire_rate)
		print("  - Cooldown: ", weapon.fire_cooldown)
	else:
		print("✗ Failed to load weapon scene")

	print("\n=== TEST COMPLETE ===")
