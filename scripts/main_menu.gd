extends Control

@onready var play_button = $VBoxContainer/PlayButton
@onready var settings_button = $VBoxContainer/SettingsButton

func _ready():
	# Connect button signals
	play_button.pressed.connect(_on_play_button_pressed)
	settings_button.pressed.connect(_on_settings_button_pressed)
	
	# Start menu music
	var audio_manager = get_node("/root/AudioManager")
	if audio_manager:
		audio_manager.play_menu_music()

func _on_play_button_pressed():
	# Change to level map scene
	get_tree().change_scene_to_file("res://scenes/level_map.tscn")

func _on_settings_button_pressed():
	# Change to settings scene
	get_tree().change_scene_to_file("res://scenes/settings.tscn") 