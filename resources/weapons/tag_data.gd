extends Resource
class_name TagData

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
func get_bonus(tag_count: int) -> Dictionary:
	return {
		"damage_mult": 1.0 + (damage_bonus_per_tag * tag_count),
		"fire_rate_mult": 1.0 + (fire_rate_bonus_per_tag * tag_count),
		"reload_speed_mult": 1.0 - (reload_speed_bonus_per_tag * tag_count),
		"projectile_count_bonus": floor(projectile_count_bonus_per_tag * tag_count),
		"pierce_bonus": floor(pierce_bonus_per_tag * tag_count),
		"knockback_mult": 1.0 + (knockback_bonus_per_tag * tag_count)
	}
