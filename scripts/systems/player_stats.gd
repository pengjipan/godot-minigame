extends Node
class_name PlayerStats
## Tracks and applies stat upgrades during a run

# Stat multipliers (multiplicative, default 1.0)
var damage_mult: float = 1.0
var move_speed_mult: float = 1.0
var attack_speed_mult: float = 1.0
var reload_speed_mult: float = 1.0
var crit_damage_mult: float = 1.5  # Base crit is 150%
var gold_gain_mult: float = 1.0
var xp_gain_mult: float = 1.0
var knockback_mult: float = 1.0

# Flat bonuses (additive)
var max_hp_bonus: int = 0
var armor: int = 0
var hp_regen: float = 0.0
var crit_chance: float = 0.0
var dodge_chance: float = 0.0
var pickup_range_bonus: float = 0.0
var lifesteal: float = 0.0

## Apply a stat upgrade
func apply_stat_upgrade(stat_type: int, value: float) -> void:
	match stat_type:
		# Survival stats
		0:  # MAX_HP
			max_hp_bonus += int(value)
		1:  # ARMOR
			armor += int(value)
		2:  # HP_REGEN
			hp_regen += value
		3:  # DODGE
			dodge_chance += value
		4:  # DAMAGE_REDUCTION (not implemented yet)
			pass

		# Attack stats
		5:  # DAMAGE
			damage_mult *= (1.0 + value)
		6:  # CRIT_CHANCE
			crit_chance += value
		7:  # CRIT_DAMAGE
			crit_damage_mult *= (1.0 + value)
		8:  # RANGE_DAMAGE
			damage_mult *= (1.0 + value)  # For now, same as damage

		# Speed stats
		9:  # MOVE_SPEED
			move_speed_mult *= (1.0 + value)
		10: # ATTACK_SPEED
			attack_speed_mult *= (1.0 + value)
		11: # RELOAD_SPEED
			reload_speed_mult *= (1.0 + value)
		12: # COOLDOWN_REDUCTION
			attack_speed_mult *= (1.0 + value)  # Functionally same as attack speed

		# Special stats
		13: # PICKUP_RANGE
			pickup_range_bonus += value
		14: # GOLD_GAIN
			gold_gain_mult *= (1.0 + value)
		15: # XP_GAIN
			xp_gain_mult *= (1.0 + value)
		16: # LIFESTEAL
			lifesteal += value
		17: # KNOCKBACK
			knockback_mult *= (1.0 + value)
		18: # LUCK (not implemented yet)
			pass

	print("[PlayerStats] Applied stat upgrade: type=%d value=%.3f" % [stat_type, value])
	EventBus.stat_upgrade_selected.emit(StatUpgradeData.StatType.keys()[stat_type], value)

## Get effective max HP
func get_max_hp(base_hp: int) -> int:
	return base_hp + max_hp_bonus

## Get effective move speed
func get_move_speed(base_speed: float) -> float:
	return base_speed * move_speed_mult

## Get weapon damage multiplier
func get_damage_multiplier() -> float:
	return damage_mult

## Get weapon attack speed multiplier
func get_attack_speed_multiplier() -> float:
	return attack_speed_mult

## Reset for new run
func reset() -> void:
	damage_mult = 1.0
	move_speed_mult = 1.0
	attack_speed_mult = 1.0
	reload_speed_mult = 1.0
	crit_damage_mult = 1.5
	gold_gain_mult = 1.0
	xp_gain_mult = 1.0
	knockback_mult = 1.0

	max_hp_bonus = 0
	armor = 0
	hp_regen = 0.0
	crit_chance = 0.0
	dodge_chance = 0.0
	pickup_range_bonus = 0.0
	lifesteal = 0.0

	print("[PlayerStats] Reset all stats")
