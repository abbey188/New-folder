extends Control

@onready var level_1_button = $SafeArea/VBoxContainer/LevelsContainer/Level1
@onready var level_2_button = $SafeArea/VBoxContainer/LevelsContainer/Level2
@onready var level_3_button = $SafeArea/VBoxContainer/LevelsContainer/Level3
@onready var back_button = $SafeArea/VBoxContainer/BackButton
@onready var safe_area = $SafeArea

func _ready():
	# Apply safe area margins based on device
	var ui_scaling = get_node("/root/UIScaling")
	if ui_scaling and safe_area:
		var margins = Vector4(
			ui_scaling.left_margin,
			ui_scaling.top_margin,
			ui_scaling.right_margin,
			ui_scaling.bottom_margin
		)
		
		safe_area.add_theme_constant_override("margin_left", margins.x)
		safe_area.add_theme_constant_override("margin_top", margins.y)
		safe_area.add_theme_constant_override("margin_right", margins.z)
		safe_area.add_theme_constant_override("margin_bottom", margins.w)
		
	# Connect button signals
	level_1_button.pressed.connect(_on_level_1_button_pressed)
	level_2_button.pressed.connect(_on_level_2_button_pressed)
	level_3_button.pressed.connect(_on_level_3_button_pressed)
	back_button.pressed.connect(_on_back_button_pressed)
	
	# Connect to viewport size changes
	get_viewport().size_changed.connect(_on_viewport_size_changed)
	
	# Start game music
	var audio_manager = get_node("/root/AudioManager")
	if audio_manager:
		audio_manager.play_game_music()
	
	# Update button states based on level progress
	update_level_states()

func _on_viewport_size_changed():
	# Re-apply the safe area margins
	if get_node_or_null("/root/UIScaling") and safe_area:
		var ui_scaling = get_node("/root/UIScaling")
		
		# Recalculate because UIScaling would have updated its values
		var margins = Vector4(
			ui_scaling.left_margin,
			ui_scaling.top_margin,
			ui_scaling.right_margin,
			ui_scaling.bottom_margin
		)
		
		safe_area.add_theme_constant_override("margin_left", margins.x)
		safe_area.add_theme_constant_override("margin_top", margins.y)
		safe_area.add_theme_constant_override("margin_right", margins.z)
		safe_area.add_theme_constant_override("margin_bottom", margins.w)

func update_level_states():
	# Load level progress
	if FileAccess.file_exists("user://level_progress.save"):
		var file = FileAccess.open("user://level_progress.save", FileAccess.READ)
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
	get_tree().change_scene_to_file("res://scenes/game_grid.tscn")

func _on_level_2_button_pressed():
	# Change to game scene with level 2 data
	get_tree().change_scene_to_file("res://scenes/game_grid.tscn")

func _on_level_3_button_pressed():
	# Change to game scene with level 3 data
	get_tree().change_scene_to_file("res://scenes/game_grid.tscn")

func _on_back_button_pressed():
	# Return to main menu
	get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn") 
