extends Control
## Initial weapon selection screen after character selection

@onready var weapon_grid = $Panel/VBoxContainer/WeaponGrid
@onready var character_label = $Panel/VBoxContainer/CharacterLabel

var all_weapons: Array[WeaponData] = []
var recommended_weapons: Array[WeaponData] = []
var character_data: CharacterData = null

func _ready():
	hide()
	_load_all_weapons()

func _load_all_weapons() -> void:
	all_weapons = [
		load("res://resources/weapons/pistol.tres"),
		load("res://resources/weapons/smg.tres"),
		load("res://resources/weapons/shotgun.tres"),
		load("res://resources/weapons/assault_rifle.tres"),
		load("res://resources/weapons/sniper.tres"),
		load("res://resources/weapons/flamethrower.tres"),
		load("res://resources/weapons/grenade_launcher.tres"),
		load("res://resources/weapons/minigun.tres")
	]

## Show weapon selection for given character
func show_for_character(char_data: CharacterData) -> void:
	character_data = char_data
	character_label.text = "Choose Starting Weapon for %s" % char_data.character_name

	# Calculate recommendations
	recommended_weapons = _get_recommended_weapons(char_data)

	# Display weapons
	_display_weapons()

	show()

## Calculate recommended weapons based on class bonuses
func _get_recommended_weapons(char_data: CharacterData) -> Array[WeaponData]:
	var scored_weapons = []

	# Score each weapon based on tag bonuses/penalties
	for weapon in all_weapons:
		var score = 0.0
		for tag in weapon.weapon_tags:
			var bonus = char_data.tag_bonuses.get(tag, 0.0)
			var penalty = char_data.tag_penalties.get(tag, 0.0)
			score += bonus + penalty

		scored_weapons.append({"weapon": weapon, "score": score})

	# Sort by score (highest first)
	scored_weapons.sort_custom(func(a, b): return a.score > b.score)

	# Return top 3
	var recommendations: Array[WeaponData] = []
	for i in range(min(3, scored_weapons.size())):
		recommendations.append(scored_weapons[i].weapon)

	return recommendations

func _display_weapons() -> void:
	# Clear existing children
	for child in weapon_grid.get_children():
		child.queue_free()

	# Display recommended weapons first (highlighted)
	for weapon in recommended_weapons:
		_create_weapon_card(weapon, true)

	# Display other weapons
	for weapon in all_weapons:
		if not recommended_weapons.has(weapon):
			_create_weapon_card(weapon, false)

func _create_weapon_card(weapon_data: WeaponData, is_recommended: bool) -> void:
	var card = VBoxContainer.new()

	# Add recommended indicator
	if is_recommended:
		var star_label = Label.new()
		star_label.text = "⭐ RECOMMENDED"
		card.add_child(star_label)

	# Weapon name
	var name_label = Label.new()
	name_label.text = weapon_data.weapon_name
	card.add_child(name_label)

	# Tags
	var tags_label = Label.new()
	tags_label.text = " ".join(weapon_data.weapon_tags)
	card.add_child(tags_label)

	# Stats
	var stats_label = Label.new()
	stats_label.text = "DMG: %d  Fire Rate: %.1f/s" % [weapon_data.damage, weapon_data.fire_rate]
	card.add_child(stats_label)

	# Show class bonus/penalty
	if character_data:
		var bonus_text = _get_class_bonus_text(weapon_data)
		if bonus_text != "":
			var bonus_label = Label.new()
			bonus_label.text = bonus_text
			card.add_child(bonus_label)

	# Select button
	var button = Button.new()
	button.text = "SELECT"
	button.pressed.connect(_on_weapon_selected.bind(weapon_data))
	card.add_child(button)

	weapon_grid.add_child(card)

func _get_class_bonus_text(weapon_data: WeaponData) -> String:
	if not character_data:
		return ""

	var bonus_texts = []
	for tag in weapon_data.weapon_tags:
		var bonus = character_data.tag_bonuses.get(tag, 0.0)
		var penalty = character_data.tag_penalties.get(tag, 0.0)

		if bonus > 0.0:
			bonus_texts.append("💡 +%.0f%% for %s" % [bonus * 100, tag])
		elif penalty < 0.0:
			bonus_texts.append("⚠️ %.0f%% for %s" % [penalty * 100, tag])

	return "\n".join(bonus_texts)

func _on_weapon_selected(weapon_data: WeaponData) -> void:
	print("[StartingWeaponScreen] Selected: %s" % weapon_data.weapon_name)

	# Store in GameManager
	GameManager.selected_starting_weapon = weapon_data

	# Transition to game
	GameManager.set_state(GameManager.GameState.PLAYING)

	hide()
