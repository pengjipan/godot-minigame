extends Node
## Manages player experience, leveling, and stat upgrade tracking

var current_level: int = 1
var current_xp: int = 0
var pending_stat_picks: int = 0

func _ready() -> void:
	print("[ExperienceManager] Initialized - Level: %d, XP: %d" % [current_level, current_xp])

## Calculate XP required for next level
## Formula: 10 + (level × 5)
func get_xp_required_for_level(level: int) -> int:
	return 10 + (level * 5)

## Add XP and handle level-ups
func gain_xp(amount: int) -> void:
	current_xp += amount

	var xp_required := get_xp_required_for_level(current_level)
	EventBus.xp_gained.emit(current_xp, xp_required)

	# Handle multiple level-ups from single XP gain
	while current_xp >= xp_required:
		level_up()
		xp_required = get_xp_required_for_level(current_level)

## Level up the player
func level_up() -> void:
	var xp_required := get_xp_required_for_level(current_level)
	current_xp -= xp_required
	current_level += 1
	pending_stat_picks += 1

	print("[ExperienceManager] Level up! New level: %d, Pending picks: %d" % [current_level, pending_stat_picks])
	EventBus.level_up.emit(current_level)

	# Emit updated XP for UI
	var next_xp_required := get_xp_required_for_level(current_level)
	EventBus.xp_gained.emit(current_xp, next_xp_required)

## Consume a stat pick (called when player selects a stat upgrade)
func consume_stat_pick() -> void:
	if pending_stat_picks > 0:
		pending_stat_picks -= 1
		print("[ExperienceManager] Stat pick consumed. Remaining: %d" % pending_stat_picks)

## Reset for new run
func reset() -> void:
	current_level = 1
	current_xp = 0
	pending_stat_picks = 0
	print("[ExperienceManager] Reset to initial state")
