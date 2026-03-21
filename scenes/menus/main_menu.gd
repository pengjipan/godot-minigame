extends Control
## Main menu scene
class_name MainMenu

func _ready() -> void:
	# Debug: Print current locale and test translation
	print("[MainMenu] Current locale: ", TranslationServer.get_locale())
	print("[MainMenu] Test tr('GAME_TITLE'): ", tr("GAME_TITLE"))

	# Manually set translated text
	$CenterContainer/VBoxContainer/Title.text = tr("GAME_TITLE")
	$CenterContainer/VBoxContainer/Subtitle.text = tr("GAME_SUBTITLE")
	$CenterContainer/VBoxContainer/StartButton.text = tr("MENU_START")
	$CenterContainer/VBoxContainer/SettingsButton.text = tr("MENU_SETTINGS")
	$CenterContainer/VBoxContainer/QuitButton.text = tr("MENU_QUIT")

	# Debug: Print what was actually set
	print("[MainMenu] Title text set to: ", $CenterContainer/VBoxContainer/Title.text)

func _on_start_pressed() -> void:
	# Go to character select
	get_tree().change_scene_to_file("res://scenes/menus/character_select.tscn")

func _on_settings_pressed() -> void:
	# Open settings (TODO)
	pass

func _on_quit_pressed() -> void:
	get_tree().quit()
