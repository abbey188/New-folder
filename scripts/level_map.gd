extends Control

@onready var level_1_button = $VBoxContainer/Level1Button
@onready var level_2_button = $VBoxContainer/Level2Button
@onready var level_3_button = $VBoxContainer/Level3Button
@onready var back_button = $VBoxContainer/BackButton

func _ready():
	# Connect button signals
	level_1_button.pressed.connect(_on_level_1_button_pressed)
	level_2_button.pressed.connect(_on_level_2_button_pressed)
	level_3_button.pressed.connect(_on_level_3_button_pressed)
	back_button.pressed.connect(_on_back_button_pressed)
	
	# Start game music
	var audio_manager = get_node("/root/AudioManager")
	if audio_manager:
		audio_manager.play_game_music()
	
	# Update button states based on level progress
	update_level_states()

func update_level_states():
	# Load level progress
	var file = File.new()
	if file.file_exists("user://level_progress.save"):
		file.open("user://level_progress.save", File.READ)
		var progress = file.get_var()
		file.close()
		
		# Update button states based on progress
		level_2_button.disabled = not progress.get("level_2_unlocked", false)
		level_3_button.disabled = not progress.get("level_3_unlocked", false)
	else:
		# Initial state: only level 1 unlocked
		level_2_button.disabled = true
		level_3_button.disabled = true

func _on_level_1_button_pressed():
	# Change to game scene
	get_tree().change_scene_to_file("res://scenes/game.tscn")

func _on_level_2_button_pressed():
	# Change to game scene with level 2 data
	get_tree().change_scene_to_file("res://scenes/game.tscn")

func _on_level_3_button_pressed():
	# Change to game scene with level 3 data
	get_tree().change_scene_to_file("res://scenes/game.tscn")

func _on_back_button_pressed():
	# Return to main menu
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn") 