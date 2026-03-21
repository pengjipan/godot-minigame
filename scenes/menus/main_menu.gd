extends Control
## Main menu scene
class_name MainMenu

func _ready() -> void:
	pass

func _on_start_pressed() -> void:
	# Go to character select
	get_tree().change_scene_to_file("res://scenes/menus/character_select.tscn")

func _on_settings_pressed() -> void:
	# Open settings (TODO)
	pass

func _on_quit_pressed() -> void:
	get_tree().quit()
