extends Node
## Test scene for weapon synergy system

func _ready():
	print("=== Weapon Synergy Test ===")

	# Test 1: Tag counting
	print("\n--- Test 1: Tag Counting ---")
	var test_weapons = [
		load("res://resources/weapons/pistol.tres"),
		load("res://resources/weapons/smg.tres"),
		load("res://resources/weapons/assault_rifle.tres")
	]
	var tag_counts = SynergyCalculator.count_tags(test_weapons)
	print("Tag counts: %s" % str(tag_counts))
	assert(tag_counts.get("RAPID_FIRE", 0) == 2, "Should have 2 RAPID_FIRE")
	assert(tag_counts.get("PRECISION", 0) == 2, "Should have 2 PRECISION")
	assert(tag_counts.get("BURST", 0) == 3, "Should have 3 BURST")
	print("✓ Tag counting works")

	# Test 2: Synergy calculation
	print("\n--- Test 2: Synergy Calculation ---")
	var synergies = SynergyCalculator.calculate_synergies(tag_counts)
	print("Synergies: %s" % str(synergies))
	assert(synergies.fire_rate_mult > 1.15, "Fire rate should increase with RAPID_FIRE")
	assert(synergies.damage_mult > 1.20, "Damage should increase with PRECISION")
	print("✓ Synergy calculation works")

	# Test 3: Class bonuses
	print("\n--- Test 3: Class Bonuses ---")
	var speedy_data = load("res://resources/characters/speedy.tres")
	var weapon_tags = ["RAPID_FIRE", "BURST"]
	var class_synergies = SynergyCalculator.apply_class_bonuses(synergies.duplicate(), speedy_data, weapon_tags)
	print("Speedy bonuses: fire_rate_mult=%.2f" % class_synergies.fire_rate_mult)
	assert(class_synergies.fire_rate_mult > synergies.fire_rate_mult, "Speedy should boost RAPID_FIRE")
	print("✓ Class bonuses work")

	print("\n=== All Tests Passed! ===")
