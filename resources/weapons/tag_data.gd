extends Resource
class_name TagData
## Defines properties and synergy bonuses for weapon tags
## Weapon tags (like RAPID_FIRE, PRECISION) provide bonuses when multiple weapons share the same tag

@export var tag_name: String = ""
@export var display_name: String = ""
@export var description: String = ""
@export var icon_path: String = ""

# Synergy bonuses per weapon with this tag
@export var damage_bonus_per_tag: float = 0.0
@export var fire_rate_bonus_per_tag: float = 0.0
@export var reload_speed_bonus_per_tag: float = 0.0
@export var projectile_count_bonus_per_tag: float = 0.0
@export var pierce_bonus_per_tag: float = 0.0
@export var knockback_bonus_per_tag: float = 0.0

## Get bonus dictionary for given tag count
## Returns multiplicative and additive bonuses based on tag synergy
## Note: reload_speed uses subtraction (positive bonus = faster reload)
func get_bonus(tag_count: int) -> Dictionary:
	if tag_count < 0:
		push_warning("TagData.get_bonus: tag_count cannot be negative")
		tag_count = 0

	return {
		"damage_mult": 1.0 + (damage_bonus_per_tag * tag_count),
		"fire_rate_mult": 1.0 + (fire_rate_bonus_per_tag * tag_count),
		"reload_speed_mult": max(0.1, 1.0 - (reload_speed_bonus_per_tag * tag_count)),
		"projectile_count_bonus": floor(projectile_count_bonus_per_tag * tag_count),
		"pierce_bonus": floor(pierce_bonus_per_tag * tag_count),
		"knockback_mult": 1.0 + (knockback_bonus_per_tag * tag_count)
	}
