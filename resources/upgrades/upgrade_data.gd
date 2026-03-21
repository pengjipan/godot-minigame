extends Resource
## Upgrade/power-up data definition
class_name UpgradeData

enum RarityLevel { COMMON, UNCOMMON, RARE, LEGENDARY }

@export var upgrade_name: String = "Health Boost"
@export var description: String = ""
@export var rarity: RarityLevel = RarityLevel.COMMON
@export var icon_path: String = ""

# Stat modifiers - can be additive or multiplicative
# Format: {"stat_name": {"type": "add"|"multiply", "value": amount}}
@export var stat_modifiers: Dictionary = {}

## Apply upgrade to player stats
func apply_upgrade(player_stats: Dictionary) -> void:
	for stat_name in stat_modifiers.keys():
		var modifier = stat_modifiers[stat_name]
		var mod_type = modifier.get("type", "add")
		var mod_value = modifier.get("value", 0)

		if mod_type == "add":
			if stat_name in player_stats:
				player_stats[stat_name] += mod_value
			else:
				player_stats[stat_name] = mod_value
		elif mod_type == "multiply":
			if stat_name in player_stats:
				player_stats[stat_name] *= mod_value
			else:
				player_stats[stat_name] = mod_value

## Get rarity color for UI
func get_rarity_color() -> Color:
	match rarity:
		RarityLevel.COMMON:
			return Color.WHITE
		RarityLevel.UNCOMMON:
			return Color.GREEN
		RarityLevel.RARE:
			return Color.BLUE
		RarityLevel.LEGENDARY:
			return Color.YELLOW
	return Color.WHITE

## Get rarity name
func get_rarity_name() -> String:
	match rarity:
		RarityLevel.COMMON:
			return "Common"
		RarityLevel.UNCOMMON:
			return "Uncommon"
		RarityLevel.RARE:
			return "Rare"
		RarityLevel.LEGENDARY:
			return "Legendary"
	return "Unknown"
