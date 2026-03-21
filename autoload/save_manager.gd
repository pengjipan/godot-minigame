extends Node
## Manages game saves and run statistics in JSON format

const SAVE_PATH = "user://save_data.json"
const STATS_PATH = "user://run_stats.json"

var save_data: Dictionary = {
	"version": 1,
	"high_score": 0,
	"total_runs": 0,
	"characters_unlocked": []
}

var run_history: Array = []

func _ready() -> void:
	load_save_data()

## Load save data from file
func load_save_data() -> void:
	if ResourceLoader.exists(SAVE_PATH):
		var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
		if file:
			var json = JSON.new()
			var error = json.parse(file.get_as_text())
			if error == OK:
				save_data = json.data
			else:
				push_error("Failed to parse save data JSON")
	else:
		save_save_data()

## Save data to file
func save_save_data() -> void:
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(save_data))
	else:
		push_error("Failed to save game data to ", SAVE_PATH)

## Save run statistics
func save_run_stats(stats: Dictionary) -> void:
	# Update high score
	if stats.get("waves_survived", 0) > save_data.get("high_score", 0):
		save_data["high_score"] = stats["waves_survived"]

	save_data["total_runs"] += 1

	# Add to run history (keep last 100)
	run_history.append({
		"timestamp": Time.get_ticks_msec(),
		"stats": stats
	})
	if run_history.size() > 100:
		run_history.pop_front()

	save_save_data()

## Get high score
func get_high_score() -> int:
	return save_data.get("high_score", 0)

## Get total runs
func get_total_runs() -> int:
	return save_data.get("total_runs", 0)

## Unlock character
func unlock_character(character_name: String) -> void:
	if character_name not in save_data.get("characters_unlocked", []):
		save_data["characters_unlocked"].append(character_name)
		save_save_data()

## Get unlocked characters
func get_unlocked_characters() -> Array:
	return save_data.get("characters_unlocked", [])

## Clear all save data (for testing)
func reset_save_data() -> void:
	save_data = {
		"version": 1,
		"high_score": 0,
		"total_runs": 0,
		"characters_unlocked": []
	}
	run_history.clear()
	save_save_data()
