extends Control

func _ready():
	# Connect button signals
	$VBoxContainer/PlayButton.pressed.connect(_on_play_button_pressed)
	$VBoxContainer/SettingsButton.pressed.connect(_on_settings_button_pressed)

func _on_play_button_pressed():
	# Transition to level map scene
	get_tree().change_scene_to_file("res://scenes/level_map.tscn")

func _on_settings_button_pressed():
	# Transition to settings scene
	get_tree().change_scene_to_file("res://scenes/ui/settings.tscn") 