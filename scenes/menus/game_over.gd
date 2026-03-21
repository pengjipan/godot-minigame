extends Control
## Game over screen
class_name GameOverScreen

var stats: Dictionary = {}

func _ready() -> void:
	EventBus.game_over.connect(_on_game_over)

func _on_game_over(run_stats: Dictionary) -> void:
	stats = run_stats
	_display_stats()

func _display_stats() -> void:
	# Create labels displaying stats
	var stats_text = "Game Over!\n\n"
	stats_text += "Waves Survived: %d\n" % stats.get("waves_survived", 0)
	stats_text += "Enemies Killed: %d\n" % stats.get("enemies_killed", 0)
	stats_text += "Gold Collected: %d\n" % stats.get("gold_collected", 0)
	stats_text += "Damage Taken: %d\n" % stats.get("damage_taken", 0)

	var label = Label.new()
	label.text = stats_text
	add_child(label)

func _on_restart_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/menus/character_select.tscn")

func _on_main_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/menus/main_menu.tscn")
