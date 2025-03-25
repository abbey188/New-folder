extends Control

# Audio settings
var music_enabled = true
var sound_enabled = true

func _ready():
	# Connect signals
	$VBoxContainer/MusicToggle/CheckBox.toggled.connect(_on_music_toggled)
	$VBoxContainer/SoundToggle/CheckBox.toggled.connect(_on_sound_toggled)
	$VBoxContainer/BackButton.pressed.connect(_on_back_button_pressed)
	
	# Load saved settings
	_load_settings()

func _load_settings():
	# Load settings from config file
	var config = ConfigFile.new()
	var err = config.load("user://settings.cfg")
	if err == OK:
		music_enabled = config.get_value("audio", "music_enabled", true)
		sound_enabled = config.get_value("audio", "sound_enabled", true)
	
	# Update UI
	$VBoxContainer/MusicToggle/CheckBox.button_pressed = music_enabled
	$VBoxContainer/SoundToggle/CheckBox.button_pressed = sound_enabled

func _save_settings():
	# Save settings to config file
	var config = ConfigFile.new()
	config.set_value("audio", "music_enabled", music_enabled)
	config.set_value("audio", "sound_enabled", sound_enabled)
	config.save("user://settings.cfg")

func _on_music_toggled(button_pressed):
	music_enabled = button_pressed
	_save_settings()
	# TODO: Implement actual music toggle when audio system is added

func _on_sound_toggled(button_pressed):
	sound_enabled = button_pressed
	_save_settings()
	# TODO: Implement actual sound toggle when audio system is added

func _on_back_button_pressed():
	# Return to main menu
	get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn") 