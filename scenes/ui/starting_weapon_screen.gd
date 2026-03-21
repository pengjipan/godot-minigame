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

## Get localization key for weapon name
func _get_weapon_name_key(weapon_name: String) -> String:
	match weapon_name:
		"9mm Handgun":
			return "WEAPON_PISTOL_NAME"
		"Vector SMG":
			return "WEAPON_SMG_NAME"
		"Pump Shotgun":
			return "WEAPON_SHOTGUN_NAME"
		"M4 Carbine":
			return "WEAPON_AR_NAME"
		"Bolt-Action Rifle":
			return "WEAPON_SNIPER_NAME"
		"Inferno Projector":
			return "WEAPON_FLAMETHROWER_NAME"
		"40mm Launcher":
			return "WEAPON_GRENADE_NAME"
		"Rotary Cannon":
			return "WEAPON_MINIGUN_NAME"
	return weapon_name  # Fallback to original

## Get localization key for weapon description
func _get_weapon_desc_key(weapon_name: String) -> String:
	match weapon_name:
		"9mm Handgun":
			return "WEAPON_PISTOL_DESC"
		"Vector SMG":
			return "WEAPON_SMG_DESC"
		"Pump Shotgun":
			return "WEAPON_SHOTGUN_DESC"
		"M4 Carbine":
			return "WEAPON_AR_DESC"
		"Bolt-Action Rifle":
			return "WEAPON_SNIPER_DESC"
		"Inferno Projector":
			return "WEAPON_FLAMETHROWER_DESC"
		"40mm Launcher":
			return "WEAPON_GRENADE_DESC"
		"Rotary Cannon":
			return "WEAPON_MINIGUN_DESC"
	return ""  # No description key

## Get localized tag name
func _get_tag_name(tag: String) -> String:
	return tr("TAG_" + tag)

## Show weapon selection for given character
func show_for_character(char_data: CharacterData) -> void:
	character_data = char_data
	character_label.text = tr("WEAPON_SELECT_TITLE")

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
		star_label.text = tr("WEAPON_SELECT_RECOMMENDED")
		card.add_child(star_label)

	# Weapon name (localized)
	var name_label = Label.new()
	name_label.text = tr(_get_weapon_name_key(weapon_data.weapon_name))
	card.add_child(name_label)

	# Weapon description (localized)
	var desc_key = _get_weapon_desc_key(weapon_data.weapon_name)
	if desc_key != "":
		var desc_label = Label.new()
		desc_label.text = tr(desc_key)
		desc_label.add_theme_font_size_override("font_size", 12)
		card.add_child(desc_label)

	# Tags (localized)
	var tags_label = Label.new()
	var localized_tags = []
	for tag in weapon_data.weapon_tags:
		localized_tags.append(_get_tag_name(tag))
	tags_label.text = " | ".join(localized_tags)
	card.add_child(tags_label)
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
	button.text = tr("WEAPON_SELECT_SELECT")
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
		var tag_name = _get_tag_name(tag)

		if bonus > 0.0:
			bonus_texts.append("💡 " + tr("WEAPON_BONUS_FOR") % [bonus * 100, tag_name])
		elif penalty < 0.0:
			bonus_texts.append("⚠️ " + tr("WEAPON_PENALTY_FOR") % [penalty * 100, tag_name])

	return "\n".join(bonus_texts)

func _on_weapon_selected(weapon_data: WeaponData) -> void:
	print("[StartingWeaponScreen] Selected: %s" % weapon_data.weapon_name)

	# Store in GameManager
	GameManager.selected_starting_weapon = weapon_data

	# Load game world scene
	get_tree().change_scene_to_file("res://scenes/game/game_world.tscn")

	hide()
