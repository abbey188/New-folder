extends Node2D

func _ready():
	# Connect button signals
	$LevelsContainer/Level1.pressed.connect(_on_level1_pressed)

func _on_level1_pressed():
	# Load the game grid scene
	get_tree().change_scene_to_file("res://scenes/game_grid.tscn") 