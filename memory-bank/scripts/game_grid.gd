extends Node2D

# Level configuration
var level_number: int = 1
var moves_remaining: int = 16
var score: int = 0
var objective_progress: int = 0
var objective_target: int = 10  # Default target, should be loaded from level data
var start_time: float = 0.0
var achievement_manager: AchievementManager

# Node references
@onready var dots_container = $DotsContainer
@onready var moves_label = $UI/MovesLabel
@onready var score_label = $UI/ScoreLabel
@onready var objective_label = $UI/ObjectiveLabel
@onready var completion_popup = $UI/CompletionPopup
@onready var visual_effects = $VisualEffects

# Grid configuration
const GRID_SIZE = 6
const DOT_SIZE = 85
const DOT_SPACING = 47
const COLORS = [
	Color(1, 0, 0),  # Red
	Color(0, 0, 1),  # Blue
	Color(0, 1, 0),  # Green
	Color(1, 1, 0),  # Yellow
	Color(1, 0, 1)   # Purple
]

# Game state
var selected_dots = []
var is_processing = false
var color_clear_counts = {}  # Track dots cleared by color

func _ready():
	# Initialize the grid
	create_grid()
	update_ui()
	
	# Connect signals
	completion_popup.continue_button.pressed.connect(_on_continue_pressed)
	
	# Get achievement manager
	achievement_manager = get_node("/root/AchievementManager")
	
	# Start timing
	start_time = Time.get_ticks_msec()

func create_grid():
	# Clear existing dots
	for child in dots_container.get_children():
		child.queue_free()
	
	# Create new grid
	for row in range(GRID_SIZE):
		for col in range(GRID_SIZE):
			var dot = create_dot(row, col)
			dots_container.add_child(dot)

func create_dot(row: int, col: int) -> Node2D:
	var dot = Sprite2D.new()
	dot.texture = preload("res://assets/dot.png")  # Assuming we have a dot texture
	dot.scale = Vector2(DOT_SIZE / dot.texture.get_width(), DOT_SIZE / dot.texture.get_height())
	
	# Position the dot
	var x = col * (DOT_SIZE + DOT_SPACING)
	var y = row * (DOT_SIZE + DOT_SPACING)
	dot.position = Vector2(x, y)
	
	# Set random color with slight transparency
	var color = COLORS[randi() % COLORS.size()]
	dot.modulate = Color(color.r, color.g, color.b, 0.8)
	
	# Add metadata
	dot.set_meta("row", row)
	dot.set_meta("col", col)
	dot.set_meta("color", dot.modulate)
	
	# Connect input
	dot.input_event.connect(_on_dot_input.bind(dot))
	
	return dot

func _on_dot_input(event: InputEvent, dot: Node2D):
	if is_processing or event is not InputEventMouseButton:
		return
		
	if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		toggle_dot_selection(dot)

func toggle_dot_selection(dot: Node2D):
	if dot in selected_dots:
		# Deselect dot
		selected_dots.erase(dot)
		visual_effects.animate_dot_selection(dot, false)
	else:
		# Select dot
		if can_select_dot(dot):
			selected_dots.append(dot)
			visual_effects.animate_dot_selection(dot, true)
			
			# Check for valid connection
			if selected_dots.size() >= 3:
				check_connection()

func can_select_dot(dot: Node2D) -> bool:
	if selected_dots.size() == 0:
		return true
		
	var last_dot = selected_dots.back()
	var last_row = last_dot.get_meta("row")
	var last_col = last_dot.get_meta("col")
	var dot_row = dot.get_meta("row")
	var dot_col = dot.get_meta("col")
	
	# Check if dots are adjacent (including diagonals)
	var row_diff = abs(dot_row - last_row)
	var col_diff = abs(dot_col - last_col)
	
	return row_diff <= 1 and col_diff <= 1 and dot.get_meta("color") == last_dot.get_meta("color")

func check_connection():
	var color = selected_dots[0].get_meta("color")
	var all_same_color = true
	
	for dot in selected_dots:
		if dot.get_meta("color") != color:
			all_same_color = false
			break
	
	if all_same_color:
		clear_connected_dots()
	else:
		# Deselect all dots
		for dot in selected_dots:
			visual_effects.animate_dot_selection(dot, false)
		selected_dots.clear()

func clear_connected_dots():
	is_processing = true
	
	# Update score and moves
	score += selected_dots.size()
	moves_remaining -= 1
	
	# Update objective progress
	objective_progress += selected_dots.size()
	
	# Track color clear counts
	if not color_clear_counts.has(color):
		color_clear_counts[color] = 0
	color_clear_counts[color] += selected_dots.size()
	
	# Check for Chain Reaction achievement
	if selected_dots.size() >= 10:
		achievement_manager.unlock_achievement("chain_reaction")
	
	# Check for Color Master achievement
	if color_clear_counts[color] >= 50:
		achievement_manager.unlock_achievement("color_master")
	
	# Animate and remove dots with particle effects
	for dot in selected_dots:
		# Create particle effect
		var particles = visual_effects.create_dot_clear_effect(dot)
		dots_container.add_child(particles)
		
		# Animate dot clearing
		visual_effects.animate_dot_clear(dot)
	
	selected_dots.clear()
	
	# Update UI
	update_ui()
	
	# Check for level completion
	if moves_remaining <= 0 or objective_progress >= objective_target:
		handle_level_completion()
	
	is_processing = false

func update_ui():
	moves_label.text = "Moves: %d" % moves_remaining
	score_label.text = "Score: %d" % score
	objective_label.text = "Objective: %d/%d" % [objective_progress, objective_target]

func handle_level_completion():
	var stars = calculate_stars()
	
	# Show completion popup
	completion_popup.show()
	completion_popup.set_stars(stars)
	
	# Create celebratory effect
	var particles = visual_effects.create_level_complete_effect(self)
	add_child(particles)
	
	# Save progress
	SaveManager.get_instance().set_level_stars(level_number, stars)
	
	# Unlock next level
	var next_level = level_number + 1
	if next_level <= 3:  # Assuming we have 3 levels
		SaveManager.get_instance().unlock_level(next_level)
	
	# Check for achievements
	if level_number == 1:
		achievement_manager.unlock_achievement("first_victory")
	
	if stars == 3:
		achievement_manager.unlock_achievement("perfect_level")
	
	# Check for Speed Demon achievement
	var completion_time = (Time.get_ticks_msec() - start_time) / 1000.0  # Convert to seconds
	if completion_time <= 30:
		achievement_manager.unlock_achievement("speed_demon")

func calculate_stars() -> int:
	if moves_remaining >= 5:
		return 3
	elif moves_remaining >= 1:
		return 2
	else:
		return 1

func _on_continue_pressed():
	# Return to level map
	var level_map = preload("res://scenes/level_map.tscn").instantiate()
	get_tree().root.add_child(level_map)
	queue_free() 