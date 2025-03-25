extends Node

# Audio bus indices
const MASTER_BUS = 0
const MUSIC_BUS = 1
const SFX_BUS = 2

# Audio players
var music_player: AudioStreamPlayer
var sfx_player: AudioStreamPlayer

# Audio streams
var menu_music: AudioStream
var game_music: AudioStream
var dot_connect_sfx: AudioStream
var level_complete_sfx: AudioStream
var level_fail_sfx: AudioStream

# Settings
var music_volume: float = 1.0
var sfx_volume: float = 1.0
var music_enabled: bool = true
var sfx_enabled: bool = true

func _ready():
	# Create audio players
	music_player = AudioStreamPlayer.new()
	sfx_player = AudioStreamPlayer.new()
	
	# Set up audio buses
	music_player.bus = "Music"
	sfx_player.bus = "SFX"
	
	# Add players to scene
	add_child(music_player)
	add_child(sfx_player)
	
	# Load audio files
	menu_music = preload("res://assets/audio/menu_music.ogg")
	game_music = preload("res://assets/audio/game_music.ogg")
	dot_connect_sfx = preload("res://assets/audio/dot_connect.ogg")
	level_complete_sfx = preload("res://assets/audio/level_complete.ogg")
	level_fail_sfx = preload("res://assets/audio/level_fail.ogg")
	
	# Load settings
	load_settings()

func play_menu_music():
	if music_enabled:
		music_player.stream = menu_music
		music_player.play()

func play_game_music():
	if music_enabled:
		music_player.stream = game_music
		music_player.play()

func play_dot_connect():
	if sfx_enabled:
		sfx_player.stream = dot_connect_sfx
		sfx_player.play()

func play_level_complete():
	if sfx_enabled:
		sfx_player.stream = level_complete_sfx
		sfx_player.play()

func play_level_fail():
	if sfx_enabled:
		sfx_player.stream = level_fail_sfx
		sfx_player.play()

func set_music_volume(volume: float):
	music_volume = volume
	if music_enabled:
		AudioServer.set_bus_volume_db(MUSIC_BUS, linear2db(volume))

func set_sfx_volume(volume: float):
	sfx_volume = volume
	if sfx_enabled:
		AudioServer.set_bus_volume_db(SFX_BUS, linear2db(volume))

func toggle_music(enabled: bool):
	music_enabled = enabled
	if enabled:
		AudioServer.set_bus_volume_db(MUSIC_BUS, linear2db(music_volume))
	else:
		AudioServer.set_bus_volume_db(MUSIC_BUS, -80.0)

func toggle_sfx(enabled: bool):
	sfx_enabled = enabled
	if enabled:
		AudioServer.set_bus_volume_db(SFX_BUS, linear2db(sfx_volume))
	else:
		AudioServer.set_bus_volume_db(SFX_BUS, -80.0)

func save_settings():
	var settings = {
		"music_volume": music_volume,
		"sfx_volume": sfx_volume,
		"music_enabled": music_enabled,
		"sfx_enabled": sfx_enabled
	}
	var file = File.new()
	file.open("user://audio_settings.save", File.WRITE)
	file.store_var(settings)
	file.close()

func load_settings():
	var file = File.new()
	if file.file_exists("user://audio_settings.save"):
		file.open("user://audio_settings.save", File.READ)
		var settings = file.get_var()
		file.close()
		
		music_volume = settings.get("music_volume", 1.0)
		sfx_volume = settings.get("sfx_volume", 1.0)
		music_enabled = settings.get("music_enabled", true)
		sfx_enabled = settings.get("sfx_enabled", true)
		
		set_music_volume(music_volume)
		set_sfx_volume(sfx_volume)
		toggle_music(music_enabled)
		toggle_sfx(sfx_enabled) 