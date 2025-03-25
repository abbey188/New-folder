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
	_load_audio_files()
	
	# Load settings
	load_settings()

func _load_audio_files():
	var dir = DirAccess.open("res://assets/audio")
	if dir:
		# Create default audio files if they don't exist
		if not FileAccess.file_exists("res://assets/audio/menu_music.ogg"):
			create_default_audio_file("res://assets/audio/menu_music.ogg")
		if not FileAccess.file_exists("res://assets/audio/game_music.ogg"):
			create_default_audio_file("res://assets/audio/game_music.ogg")
		if not FileAccess.file_exists("res://assets/audio/dot_connect.ogg"):
			create_default_audio_file("res://assets/audio/dot_connect.ogg")
		if not FileAccess.file_exists("res://assets/audio/level_complete.ogg"):
			create_default_audio_file("res://assets/audio/level_complete.ogg")
		if not FileAccess.file_exists("res://assets/audio/level_fail.ogg"):
			create_default_audio_file("res://assets/audio/level_fail.ogg")
	
	# Load audio files
	menu_music = load("res://assets/audio/menu_music.ogg") if FileAccess.file_exists("res://assets/audio/menu_music.ogg") else null
	game_music = load("res://assets/audio/game_music.ogg") if FileAccess.file_exists("res://assets/audio/game_music.ogg") else null
	dot_connect_sfx = load("res://assets/audio/dot_connect.ogg") if FileAccess.file_exists("res://assets/audio/dot_connect.ogg") else null
	level_complete_sfx = load("res://assets/audio/level_complete.ogg") if FileAccess.file_exists("res://assets/audio/level_complete.ogg") else null
	level_fail_sfx = load("res://assets/audio/level_fail.ogg") if FileAccess.file_exists("res://assets/audio/level_fail.ogg") else null

func create_default_audio_file(path: String):
	var file = FileAccess.open(path, FileAccess.WRITE)
	if file:
		# Create a minimal valid OGG file
		file.store_buffer([0x4F, 0x67, 0x67, 0x53]) # OGG header
		file.close()

func play_menu_music():
	if music_enabled and menu_music:
		music_player.stream = menu_music
		music_player.play()

func play_game_music():
	if music_enabled and game_music:
		music_player.stream = game_music
		music_player.play()

func play_dot_connect():
	if sfx_enabled and dot_connect_sfx:
		sfx_player.stream = dot_connect_sfx
		sfx_player.play()

func play_level_complete():
	if sfx_enabled and level_complete_sfx:
		sfx_player.stream = level_complete_sfx
		sfx_player.play()

func play_level_fail():
	if sfx_enabled and level_fail_sfx:
		sfx_player.stream = level_fail_sfx
		sfx_player.play()

func set_music_volume(volume: float):
	music_volume = volume
	if music_enabled:
		AudioServer.set_bus_volume_db(MUSIC_BUS, linear_to_db(volume))

func set_sfx_volume(volume: float):
	sfx_volume = volume
	if sfx_enabled:
		AudioServer.set_bus_volume_db(SFX_BUS, linear_to_db(volume))

func toggle_music(enabled: bool):
	music_enabled = enabled
	if enabled:
		AudioServer.set_bus_volume_db(MUSIC_BUS, linear_to_db(music_volume))
	else:
		AudioServer.set_bus_volume_db(MUSIC_BUS, -80.0)

func toggle_sfx(enabled: bool):
	sfx_enabled = enabled
	if enabled:
		AudioServer.set_bus_volume_db(SFX_BUS, linear_to_db(sfx_volume))
	else:
		AudioServer.set_bus_volume_db(SFX_BUS, -80.0)

func save_settings():
	var settings = {
		"music_volume": music_volume,
		"sfx_volume": sfx_volume,
		"music_enabled": music_enabled,
		"sfx_enabled": sfx_enabled
	}
	var file = FileAccess.open("user://audio_settings.save", FileAccess.WRITE)
	if file:
		file.store_var(settings)
		file.close()

func load_settings():
	if FileAccess.file_exists("user://audio_settings.save"):
		var file = FileAccess.open("user://audio_settings.save", FileAccess.READ)
		if file:
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