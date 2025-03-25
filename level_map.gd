extends Node2D

var level_progress: LevelProgress
var level_buttons: Array[Button] = []

func _ready() -> void:
	# Load saved progress
	level_progress = LevelProgress.load_progress()
	
	# Get all level buttons
	level_buttons = [
		$Level1Button,
		$Level2Button,
		$Level3Button
	]
	
	# Update button states based on progress
	update_level_buttons()

func update_level_buttons() -> void:
	for i in range(level_buttons.size()):
		var button = level_buttons[i]
		var is_unlocked = level_progress.is_level_unlocked(i)
		
		# Update button appearance
		button.disabled = !is_unlocked
		button.modulate = Color(1, 1, 1, 1) if is_unlocked else Color(0.5, 0.5, 0.5, 1)
		
		# Show stars if level is completed
		var stars = level_progress.get_level_stars(i)
		if stars > 0:
			button.text = "Level %d (%d★)" % [i + 1, stars]
		else:
			button.text = "Level %d" % [i + 1]

func _on_level_completed(level: int, stars: int) -> void:
	# Update progress
	level_progress.set_level_stars(level, stars)
	level_progress.unlock_next_level(level)
	
	# Update UI
	update_level_buttons()

# Button signal handlers
func _on_level_1_button_pressed() -> void:
	start_level(0)

func _on_level_2_button_pressed() -> void:
	start_level(1)

func _on_level_3_button_pressed() -> void:
	start_level(2)

func start_level(level_index: int) -> void:
	# Load the game scene with level data
	var game_scene = preload("res://game_grid.tscn").instantiate()
	game_scene.level_index = level_index
	
	# Connect to level completion signal
	game_scene.level_completed.connect(_on_level_completed.bind(level_index))
	
	# Replace current scene with game scene
	get_tree().root.add_child(game_scene)
	queue_free() 