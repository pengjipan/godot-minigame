extends Control
## Main menu scene
class_name MainMenu

func _ready() -> void:
	# Manually set translated text
	$CenterContainer/VBoxContainer/Title.text = tr("GAME_TITLE")
	$CenterContainer/VBoxContainer/Subtitle.text = tr("GAME_SUBTITLE")
	$CenterContainer/VBoxContainer/StartButton.text = tr("MENU_START")
	$CenterContainer/VBoxContainer/SettingsButton.text = tr("MENU_SETTINGS")
	$CenterContainer/VBoxContainer/QuitButton.text = tr("MENU_QUIT")

func _on_start_pressed() -> void:
	# Go to character select
	get_tree().change_scene_to_file("res://scenes/menus/character_select.tscn")

func _on_settings_pressed() -> void:
	# Open settings (TODO)
	pass

func _on_quit_pressed() -> void:
	get_tree().quit()
