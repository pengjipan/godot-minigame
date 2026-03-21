extends Node
## Manages all game audio - background music and sound effects

var music_player: AudioStreamPlayer = null
var sfx_players: Array[AudioStreamPlayer] = []
var master_volume: float = 1.0
var music_volume: float = 0.8
var sfx_volume: float = 1.0

func _ready() -> void:
	# Create music player
	music_player = AudioStreamPlayer.new()
	music_player.bus = &"Master"
	add_child(music_player)

	# Pre-create SFX players (pool of 16)
	for i in range(16):
		var player = AudioStreamPlayer.new()
		player.bus = &"Master"
		add_child(player)
		sfx_players.append(player)

## Play background music (loops)
func play_music(audio_path: String, fade_in: float = 0.0) -> void:
	if not ResourceLoader.exists(audio_path):
		push_warning("Music file not found: ", audio_path)
		return

	var audio = load(audio_path) as AudioStream
	if audio:
		music_player.stream = audio
		music_player.volume_db = linear2db(music_volume * master_volume)
		music_player.play()
		if fade_in > 0:
			var tween = create_tween()
			tween.tween_property(music_player, "volume_db",
				linear2db(music_volume * master_volume), fade_in)

## Stop background music
func stop_music(fade_out: float = 0.0) -> void:
	if fade_out > 0:
		var tween = create_tween()
		tween.tween_property(music_player, "volume_db", -80.0, fade_out)
		await tween.finished
		music_player.stop()
	else:
		music_player.stop()

## Play sound effect
func play_sfx(audio_path: String, volume: float = 1.0) -> void:
	if not ResourceLoader.exists(audio_path):
		push_warning("SFX file not found: ", audio_path)
		return

	var audio = load(audio_path) as AudioStream
	if audio:
		# Find an available player
		for player in sfx_players:
			if not player.playing:
				player.stream = audio
				player.volume_db = linear2db(volume * sfx_volume * master_volume)
				player.play()
				return
		push_warning("All SFX players are busy")

## Set master volume (0.0 to 1.0)
func set_master_volume(volume: float) -> void:
	master_volume = clamp(volume, 0.0, 1.0)
	if music_player:
		music_player.volume_db = linear2db(music_volume * master_volume)
	for player in sfx_players:
		player.volume_db = linear2db(sfx_volume * master_volume)

## Set music volume (0.0 to 1.0)
func set_music_volume(volume: float) -> void:
	music_volume = clamp(volume, 0.0, 1.0)
	if music_player:
		music_player.volume_db = linear2db(music_volume * master_volume)

## Set SFX volume (0.0 to 1.0)
func set_sfx_volume(volume: float) -> void:
	sfx_volume = clamp(volume, 0.0, 1.0)
	for player in sfx_players:
		player.volume_db = linear2db(sfx_volume * master_volume)

## Get master volume
func get_master_volume() -> float:
	return master_volume

## Get music volume
func get_music_volume() -> float:
	return music_volume

## Get SFX volume
func get_sfx_volume() -> float:
	return sfx_volume

## Stop all audio
func stop_all() -> void:
	music_player.stop()
	for player in sfx_players:
		player.stop()
