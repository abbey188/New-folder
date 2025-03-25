extends Node2D

# Level button references
@onready var level_buttons = {
	1: $Level1Button,
	2: $Level2Button,
	3: $Level3Button
}

# Star display references
@onready var star_displays = {
	1: $Level1Stars,
	2: $Level2Stars,
	3: $Level3Stars
}

func _ready():
	# Update level button states based on save data
	update_level_states()
	
	# Connect level completion signals
	for level_num in level_buttons.keys():
		level_buttons[level_num].pressed.connect(_on_level_button_pressed.bind(level_num))

func update_level_states():
	for level_num in level_buttons.keys():
		var button = level_buttons[level_num]
		var stars = star_displays[level_num]
		
		if SaveManager.get_instance().is_level_unlocked(level_num):
			button.disabled = false
			button.modulate = Color(1, 1, 1, 1)
			
			# Update star display
			var star_count = SaveManager.get_instance().get_level_stars(level_num)
			update_star_display(stars, star_count)
		else:
			button.disabled = true
			button.modulate = Color(0.5, 0.5, 0.5, 1)
			update_star_display(stars, 0)

func update_star_display(star_display: Node, count: int):
	# Assuming star_display has 3 star sprites as children
	for i in range(3):
		var star = star_display.get_child(i)
		if star:
			star.visible = i < count

func _on_level_button_pressed(level_number: int):
	# Load the game scene with the selected level
	var game_scene = preload("res://scenes/game_grid.tscn").instantiate()
	game_scene.level_number = level_number
	
	# Replace current scene with game scene
	get_tree().root.add_child(game_scene)
	queue_free()

# Called when a level is completed
func on_level_completed(level_number: int, stars: int):
	# Update save data
	SaveManager.get_instance().set_level_stars(level_number, stars)
	
	# Unlock next level if it exists
	var next_level = level_number + 1
	if next_level <= 3:  # Assuming we have 3 levels
		SaveManager.get_instance().unlock_level(next_level)
	
	# Update UI
	update_level_states() 