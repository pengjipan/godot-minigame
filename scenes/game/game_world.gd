extends Node2D
## Main game world scene
class_name GameWorld

@export var player_scene: String = "res://scenes/player/player.tscn"
@export var hud_scene: String = "res://scenes/ui/game_hud.tscn"
@export var level_up_panel_scene: String = "res://scenes/ui/level_up_panel.tscn"
@export var shop_panel_scene: String = "res://scenes/ui/shop_panel.tscn"

var player: Player = null
var wave_manager: WaveManager = null
var spawn_system: SpawnSystem = null
var experience_system: ExperienceSystem = null
var upgrade_system: UpgradeSystem = null
var shop_system: ShopSystem = null

func _ready() -> void:
	# Instantiate player
	if ResourceLoader.exists(player_scene):
		var player_inst = load(player_scene).instantiate()
		add_child(player_inst)
		player = player_inst
		player.position = Vector2(540, 960)  # Center of portrait screen

	# Create UI layers
	if ResourceLoader.exists(hud_scene):
		var hud = load(hud_scene).instantiate()
		add_child(hud)

	if ResourceLoader.exists(level_up_panel_scene):
		var panel = load(level_up_panel_scene).instantiate()
		add_child(panel)

	if ResourceLoader.exists(shop_panel_scene):
		var shop = load(shop_panel_scene).instantiate()
		add_child(shop)

	# Create game systems as nodes
	wave_manager = WaveManager.new()
	add_child(wave_manager)

	spawn_system = SpawnSystem.new()
	wave_manager.add_child(spawn_system)

	experience_system = ExperienceSystem.new()
	add_child(experience_system)

	upgrade_system = UpgradeSystem.new()
	add_child(upgrade_system)

	shop_system = ShopSystem.new()
	add_child(shop_system)

	# Start game
	GameManager.set_state(GameManager.GameState.PLAYING)

func _process(delta: float) -> void:
	pass
