extends CanvasLayer

signal no_moves_left

# Game state variables
var moves_left = 16
var current_score = 0

# UI nodes
@onready var moves_label = $MovesContainer/MovesLabel
@onready var score_label = $ScoreContainer/ScoreLabel

# Constants
const SQUARE_MULTIPLIER = 0.5
const LARGE_CHAIN_MULTIPLIER = 0.5
const LARGE_CHAIN_THRESHOLD = 10

func _ready():
	# Initialize UI elements
	update_moves_display()
	update_score_display()

# Update the moves display
func update_moves_display():
	moves_label.text = str(moves_left)

# Update the score display
func update_score_display():
	score_label.text = str(current_score)

# Decrease moves by 1 and update display
func use_move():
	moves_left -= 1
	update_moves_display()
	
	# Check if player has no moves left
	if moves_left <= 0:
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

# Reset the game state
func reset_game():
	moves_left = 16
	current_score = 0
	update_moves_display()
	update_score_display() 
