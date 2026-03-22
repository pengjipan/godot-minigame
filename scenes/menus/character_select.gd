extends Control
## Character selection menu
class_name CharacterSelect

@export var available_characters: Array[CharacterData] = []

var selected_character: CharacterData = null
var character_container: VBoxContainer = null

func _ready() -> void:
	# Set translated text
	$PanelContainer/VBoxContainer/Title.text = tr("CHAR_SELECT_TITLE")
	$PanelContainer/VBoxContainer/BackButton.text = tr("CHAR_BACK")

	# Get the container for character buttons
	character_container = $PanelContainer/VBoxContainer/ScrollContainer/VBoxContainer

	# Create character buttons
	for i in range(available_characters.size()):
		var char_data = available_characters[i]
		var button = Button.new()
		# Translate character name and description
		var char_name = tr(char_data.character_name)
		var char_desc = tr(char_data.description)
		button.text = char_name + "\n" + char_desc
		button.custom_minimum_size = Vector2(0, 200)
		button.add_theme_font_size_override("font_size", 32)
		button.pressed.connect(_on_character_selected.bind(char_data))
		character_container.add_child(button)

	# Connect back button
	$PanelContainer/VBoxContainer/BackButton.pressed.connect(_on_back_pressed)

func _on_character_selected(character: CharacterData) -> void:
	selected_character = character

	# Store character in GameManager
	GameManager.selected_character = character

	# Go to weapon selection
	GameManager.set_state(GameManager.GameState.INITIAL_WEAPON_SELECT)

	# Load weapon selection screen
	var weapon_screen = load("res://scenes/ui/starting_weapon_screen.tscn").instantiate()
	get_tree().root.add_child(weapon_screen)
	weapon_screen.show_for_character(character)

	# Hide character select
	hide()

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/menus/main_menu.tscn")
