extends Control
## Character selection menu
class_name CharacterSelect

@export var available_characters: Array[CharacterData] = []

var selected_character: CharacterData = null
var character_container: VBoxContainer = null

func _ready() -> void:
	# Get the container for character buttons
	character_container = $PanelContainer/VBoxContainer/ScrollContainer/VBoxContainer

	# Create character buttons
	for i in range(available_characters.size()):
		var char_data = available_characters[i]
		var button = Button.new()
		button.text = char_data.character_name + "\n" + char_data.description
		button.custom_minimum_size = Vector2(0, 120)
		button.pressed.connect(_on_character_selected.bind(char_data))
		character_container.add_child(button)

	# Connect back button
	$PanelContainer/VBoxContainer/BackButton.pressed.connect(_on_back_pressed)

func _on_character_selected(character: CharacterData) -> void:
	selected_character = character
	GameManager.start_new_run(character.get_stats())
	get_tree().change_scene_to_file("res://scenes/game/game_world.tscn")

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/menus/main_menu.tscn")
