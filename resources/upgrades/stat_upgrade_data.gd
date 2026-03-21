extends Resource
class_name StatUpgradeData

enum StatType {
	# Survival stats
	MAX_HP, ARMOR, HP_REGEN, DODGE, DAMAGE_REDUCTION,
	# Attack stats
	DAMAGE, CRIT_CHANCE, CRIT_DAMAGE, RANGE_DAMAGE,
	# Speed stats
	MOVE_SPEED, ATTACK_SPEED, RELOAD_SPEED, COOLDOWN_REDUCTION,
	# Special stats
	PICKUP_RANGE, GOLD_GAIN, XP_GAIN, LIFESTEAL, KNOCKBACK, LUCK
}

enum Rarity { COMMON, UNCOMMON, RARE }

@export var stat_type: StatType = StatType.DAMAGE
@export var display_name: String = "Damage"
@export var description: String = "Increases damage dealt"
@export var icon_path: String = ""

# Value per rarity
@export var common_value: float = 0.08  # 8%
@export var uncommon_value: float = 0.10  # 10%
@export var rare_value: float = 0.15  # 15%

# Rarity weights (out of 100)
@export var common_weight: int = 70
@export var uncommon_weight: int = 25
@export var rare_weight: int = 5

## Get value for a specific rarity
func get_value_for_rarity(rarity: Rarity) -> float:
	match rarity:
		Rarity.COMMON:
			return common_value
		Rarity.UNCOMMON:
			return uncommon_value
		Rarity.RARE:
			return rare_value
	return common_value

## Roll rarity based on weights
func roll_rarity() -> Rarity:
	var total = common_weight + uncommon_weight + rare_weight
	var roll = randi() % total

	if roll < common_weight:
		return Rarity.COMMON
	elif roll < common_weight + uncommon_weight:
		return Rarity.UNCOMMON
	else:
		return Rarity.RARE

## Get display info for UI
func get_display_info(rarity: Rarity) -> Dictionary:
	var value = get_value_for_rarity(rarity)
	var rarity_name = Rarity.keys()[rarity]

	return {
		"name": display_name,
		"description": description,
		"value": value,
		"rarity": rarity_name,
		"icon": icon_path
	}
