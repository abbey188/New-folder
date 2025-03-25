extends Control

@onready var music_toggle = $VBoxContainer/MusicSection/MusicToggle
@onready var music_volume = $VBoxContainer/MusicSection/MusicVolume
@onready var sfx_toggle = $VBoxContainer/SFXSection/SFXToggle
@onready var sfx_volume = $VBoxContainer/SFXSection/SFXVolume
@onready var back_button = $VBoxContainer/BackButton

func _ready():
	# Connect signals
	music_toggle.toggled.connect(_on_music_toggle_toggled)
	music_volume.value_changed.connect(_on_music_volume_changed)
	sfx_toggle.toggled.connect(_on_sfx_toggle_toggled)
	sfx_volume.value_changed.connect(_on_sfx_volume_changed)
	back_button.pressed.connect(_on_back_button_pressed)
	
	# Load current settings
	var audio_manager = get_node("/root/AudioManager")
	music_toggle.button_pressed = audio_manager.music_enabled
	music_volume.value = audio_manager.music_volume
	sfx_toggle.button_pressed = audio_manager.sfx_enabled
	sfx_volume.value = audio_manager.sfx_volume

func _on_music_toggle_toggled(enabled: bool):
	var audio_manager = get_node("/root/AudioManager")
	audio_manager.toggle_music(enabled)
	audio_manager.save_settings()

func _on_music_volume_changed(value: float):
	var audio_manager = get_node("/root/AudioManager")
	audio_manager.set_music_volume(value)
	audio_manager.save_settings()

func _on_sfx_toggle_toggled(enabled: bool):
	var audio_manager = get_node("/root/AudioManager")
	audio_manager.toggle_sfx(enabled)
	audio_manager.save_settings()

func _on_sfx_volume_changed(value: float):
	var audio_manager = get_node("/root/AudioManager")
	audio_manager.set_sfx_volume(value)
	audio_manager.save_settings()

func _on_back_button_pressed():
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn") 