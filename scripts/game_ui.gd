extends CanvasLayer

signal no_moves_left
signal objective_completed

# Game state variables
var moves_left = 16
var current_score = 0

# Level objective variables
var objective_type = "color" # can be "color", "shape", etc.
var objective_color = 0 # color index from GameGrid.DOT_COLORS
var objective_count = 10 # number of dots to clear
var current_progress = 0 # current progress towards objective

# Level completion variables
var level_complete = false
var level_failed = false

# UI nodes
@onready var moves_label = $MovesContainer/VBoxContainer/MovesLabel
@onready var score_label = $ScoreContainer/VBoxContainer/ScoreLabel
@onready var objective_label = $ObjectiveContainer/VBoxContainer/ObjectiveLabel
@onready var progress_label = $ObjectiveContainer/VBoxContainer/ProgressLabel
@onready var level_completion_popup = $LevelCompletionPopup

# Constants
const SQUARE_MULTIPLIER = 0.5
const LARGE_CHAIN_MULTIPLIER = 0.5
const LARGE_CHAIN_THRESHOLD = 10
const LEVEL_COMPLETION_SCORE = 60  # Base points for completing a level

# Color names for objective display
const COLOR_NAMES = ["red", "blue", "green", "yellow", "purple"]

func _ready():
	# Initialize UI elements
	update_moves_display()
	update_score_display()
	update_objective_display()
	
	# Connect signals for level completion popup
	if level_completion_popup:
		level_completion_popup.continue_pressed.connect(_on_continue_pressed)
		level_completion_popup.visible = false
	
	# Print debug info to verify nodes are found
	print("UI initialized - Moves Label: ", moves_label != null)
	print("UI initialized - Score Label: ", score_label != null)
	print("UI initialized - Objective Label: ", objective_label != null)
	print("UI initialized - Progress Label: ", progress_label != null)
	print("UI initialized - Level Completion Popup: ", level_completion_popup != null)

# Update the moves display
func update_moves_display():
	if moves_label:
		moves_label.text = str(moves_left)
	else:
		print("ERROR: Moves label not found")

# Update the score display
func update_score_display():
	if score_label:
		score_label.text = str(current_score)
	else:
		print("ERROR: Score label not found")

# Update the objective display
func update_objective_display():
	if objective_label and progress_label:
		var objective_text = "Clear " + str(objective_count) + " " + COLOR_NAMES[objective_color] + " dots"
		objective_label.text = objective_text
		
		var progress_text = str(current_progress) + "/" + str(objective_count)
		progress_label.text = progress_text
	else:
		print("ERROR: Objective or progress label not found")

# Decrease moves by 1 and update display
func use_move():
	moves_left -= 1
	update_moves_display()
	
	# Check if player has no moves left
	if moves_left <= 0 and !level_complete:
		level_failed = true
		_show_level_failed()
		emit_signal("no_moves_left")

# Add to the score based on dots cleared
func add_score(dots_cleared, is_square_shape = false):
	var points = dots_cleared
	var multiplier = 1.0
	
	# Apply multiplier for square shapes
	if is_square_shape:
		multiplier += SQUARE_MULTIPLIER
	
	# Apply multiplier for large chains (10+ dots)
	if dots_cleared >= LARGE_CHAIN_THRESHOLD:
		multiplier += LARGE_CHAIN_MULTIPLIER
	
	# Calculate final score
	var points_to_add = int(points * multiplier)
	current_score += points_to_add
	
	# Update the score display
	update_score_display()
	
	return points_to_add

# Track progress for specific color objectives
func track_cleared_dots(dots_array, dot_colors):
	# Check if we're tracking color-based objectives
	if objective_type != "color":
		return
		
	# Count dots of the target color
	var cleared_target_dots = 0
	
	for i in range(dots_array.size()):
		var dot = dots_array[i]
		var color_idx = dot_colors[i]
		
		# If the dot matches our objective color
		if color_idx == objective_color:
			cleared_target_dots += 1
	
	# Update progress
	current_progress += cleared_target_dots
	update_objective_display()
	
	# Check if objective is completed
	if current_progress >= objective_count and !level_complete and !level_failed:
		level_complete = true
		_show_level_complete()
		emit_signal("objective_completed")

# Show level complete screen
func _show_level_complete():
	# Add completion bonus to the score
	var final_score = current_score + LEVEL_COMPLETION_SCORE
	current_score = final_score
	update_score_display()
	
	# Show the completion popup with success
	if level_completion_popup:
		level_completion_popup.show_completion(true, final_score, moves_left)

# Show level failed screen
func _show_level_failed():
	# Show the completion popup with failure
	if level_completion_popup:
		level_completion_popup.show_completion(false, current_score, 0)

# Handle continue button press on completion popup
func _on_continue_pressed():
	# Here you would typically return to the level map
	# For now, we'll just reset the game
	reset_game()

# Reset the game state
func reset_game():
	moves_left = 16
	current_score = 0
	current_progress = 0
	level_complete = false
	level_failed = false
	update_moves_display()
	update_score_display()
	update_objective_display()

# Set a new objective
func set_objective(type, target, count):
	objective_type = type
	
	if type == "color":
		objective_color = target
	
	objective_count = count
	current_progress = 0
	update_objective_display() 
