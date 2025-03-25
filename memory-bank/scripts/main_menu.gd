extends Control

@onready var play_button = $VBoxContainer/PlayButton
@onready var gallery_button = $VBoxContainer/GalleryButton
@onready var settings_button = $VBoxContainer/SettingsButton

func _ready():
	play_button.pressed.connect(_on_play_pressed)
	gallery_button.pressed.connect(_on_gallery_pressed)
	settings_button.pressed.connect(_on_settings_pressed)

func _on_play_pressed():
	get_tree().change_scene_to_file("res://scenes/level_map.tscn")

func _on_gallery_pressed():
	get_tree().change_scene_to_file("res://scenes/gallery.tscn")

func _on_settings_pressed():
	get_tree().change_scene_to_file("res://scenes/settings.tscn") 