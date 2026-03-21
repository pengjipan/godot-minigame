extends Node
## Centralized synergy calculation system
## Calculates tag-based synergies and applies class bonuses

## Count tags across all equipped weapons
func count_tags(weapons: Array) -> Dictionary:
	var tag_counts: Dictionary = {}
	for weapon_data in weapons:
		if weapon_data == null:
			continue
		if not weapon_data.has("weapon_tags"):
			continue
		for tag in weapon_data.weapon_tags:
			tag_counts[tag] = tag_counts.get(tag, 0) + 1
	return tag_counts

## Calculate base synergy bonuses from tag counts
func calculate_synergies(tag_counts: Dictionary) -> Dictionary:
	var synergies = {
		"damage_mult": 1.0,
		"fire_rate_mult": 1.0,
		"reload_speed_mult": 1.0,
		"projectile_count_bonus": 0,
		"pierce_bonus": 0,
		"knockback_mult": 1.0
	}

	# Apply tag synergies
	synergies.damage_mult += tag_counts.get("PRECISION", 0) * 0.12
	synergies.damage_mult += tag_counts.get("HEAVY", 0) * 0.15
	synergies.fire_rate_mult += tag_counts.get("RAPID_FIRE", 0) * 0.08
	synergies.fire_rate_mult += tag_counts.get("SUSTAINED", 0) * 0.05
	synergies.reload_speed_mult -= tag_counts.get("BURST", 0) * 0.10
	synergies.projectile_count_bonus = int(tag_counts.get("AREA", 0) * 0.10)
	synergies.pierce_bonus = int(tag_counts.get("PIERCING", 0) / 2.0)
	synergies.knockback_mult += tag_counts.get("HEAVY", 0) * 0.20

	# Clamp reload speed to positive
	synergies.reload_speed_mult = max(synergies.reload_speed_mult, 0.1)

	return synergies

## Apply class bonuses on top of synergies for a specific weapon
func apply_class_bonuses(synergies: Dictionary, character_data, weapon_tags: Array) -> Dictionary:
	if character_data == null:
		return synergies

	var result = synergies.duplicate(true)

	for tag in weapon_tags:
		var class_mult = character_data.get_tag_multiplier(tag)

		# Apply class multipliers (multiplicative)
		if tag == "RAPID_FIRE" or tag == "SUSTAINED":
			result.fire_rate_mult *= class_mult
		elif tag == "HEAVY":
			result.damage_mult *= class_mult
			result.knockback_mult *= class_mult
		elif tag == "AREA":
			# For AREA, class bonus affects projectile count multiplicatively
			var base_bonus = result.projectile_count_bonus
			result.projectile_count_bonus = int(base_bonus * class_mult)
		elif tag == "PRECISION":
			result.damage_mult *= class_mult
		elif tag == "BURST":
			result.reload_speed_mult *= class_mult

	return result
