extends Node
## Centralized synergy calculation system
## Calculates tag-based synergies and applies class bonuses

# Tag synergy multipliers (per tag)
const PRECISION_DAMAGE_PER_TAG: float = 0.12
const HEAVY_DAMAGE_PER_TAG: float = 0.15
const HEAVY_KNOCKBACK_PER_TAG: float = 0.20
const RAPID_FIRE_RATE_PER_TAG: float = 0.08
const SUSTAINED_FIRE_RATE_PER_TAG: float = 0.05
const BURST_RELOAD_SPEED_PER_TAG: float = 0.10
const AREA_PROJECTILE_PER_TAG: float = 0.10
const PIERCING_BONUS_PER_TAG: float = 0.5
const MIN_RELOAD_SPEED_MULT: float = 0.1

## Count tags across all equipped weapons
func count_tags(weapons: Array) -> Dictionary:
	var tag_counts: Dictionary = {}
	for weapon_data in weapons:
		if weapon_data == null:
			continue
		if not "weapon_tags" in weapon_data:
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
		"projectile_count_bonus": 0.0,  # Float to store percentage bonus (e.g., 0.30 = +30%)
		"pierce_bonus": 0,
		"knockback_mult": 1.0
	}

	# Apply tag synergies
	synergies.damage_mult += tag_counts.get("PRECISION", 0) * PRECISION_DAMAGE_PER_TAG
	synergies.damage_mult += tag_counts.get("HEAVY", 0) * HEAVY_DAMAGE_PER_TAG
	synergies.fire_rate_mult += tag_counts.get("RAPID_FIRE", 0) * RAPID_FIRE_RATE_PER_TAG
	synergies.fire_rate_mult += tag_counts.get("SUSTAINED", 0) * SUSTAINED_FIRE_RATE_PER_TAG
	synergies.reload_speed_mult -= tag_counts.get("BURST", 0) * BURST_RELOAD_SPEED_PER_TAG
	# Fixed: Store as percentage multiplier (0.10 per tag), not rounded integer
	# Example: 3 AREA tags = 0.30 = +30% projectiles
	synergies.projectile_count_bonus = tag_counts.get("AREA", 0) * AREA_PROJECTILE_PER_TAG
	synergies.pierce_bonus = int(tag_counts.get("PIERCING", 0) * PIERCING_BONUS_PER_TAG)
	synergies.knockback_mult += tag_counts.get("HEAVY", 0) * HEAVY_KNOCKBACK_PER_TAG

	# Clamp reload speed to positive minimum
	synergies.reload_speed_mult = max(synergies.reload_speed_mult, MIN_RELOAD_SPEED_MULT)

	return synergies

## Apply class bonuses on top of synergies for a specific weapon
func apply_class_bonuses(synergies: Dictionary, character_data, weapon_tags: Array) -> Dictionary:
	if character_data == null:
		return synergies

	# Type safety check
	if not character_data.has_method("get_tag_multiplier"):
		push_warning("SynergyCalculator: character_data missing get_tag_multiplier method")
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
			# For AREA, class bonus affects projectile count percentage multiplicatively
			# Example: 30% base bonus * 1.2 class mult = 36% final bonus
			result.projectile_count_bonus *= class_mult
		elif tag == "PRECISION":
			result.damage_mult *= class_mult
		elif tag == "BURST":
			result.reload_speed_mult *= class_mult

	return result
