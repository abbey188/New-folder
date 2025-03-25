extends CanvasLayer

signal no_moves_left
signal objective_completed
signal restart_requested
signal home_requested

# Game state variables
var moves_left = 16
var score = 0

# Level objective variables
var objective_type = "color" # can be "color", "shape", etc.
var objective_color = "red" # color index from GameGrid.DOT_COLORS
var objective_target = 10 # number of dots to clear
var objective_progress = 0 # current progress towards objective

# Level completion variables
var level_complete = false
var level_failed = false

# UI nodes
@onready var moves_label = $UI/SafeArea/VBoxContainer/TopBar/HBoxContainer/MovesContainer/MovesLabel
@onready var score_label = $UI/SafeArea/VBoxContainer/TopBar/HBoxContainer/ScoreContainer/ScoreLabel
@onready var objective_label = $UI/SafeArea/VBoxContainer/TopBar/HBoxContainer/ObjectiveContainer/ObjectiveLabel
@onready var progress_label = $UI/SafeArea/VBoxContainer/TopBar/HBoxContainer/ObjectiveContainer/ProgressLabel
@onready var restart_button = $UI/SafeArea/VBoxContainer/BottomBar/HBoxContainer/RestartButton
@onready var home_button = $UI/SafeArea/VBoxContainer/BottomBar/HBoxContainer/HomeButton
@onready var level_completion_popup = $LevelCompletionPopup
@onready var safe_area = $UI/SafeArea

# Constants
const SQUARE_MULTIPLIER = 0.5
const LARGE_CHAIN_MULTIPLIER = 0.5
const LARGE_CHAIN_THRESHOLD = 10
const LEVEL_COMPLETION_SCORE = 60  # Base points for completing a level

# Color names for objective display
const COLOR_NAMES = ["red", "blue", "green", "yellow", "purple"]

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
	
	# Initialize UI elements
	update_ui()
	
	# Connect signals for buttons
	if restart_button:
		restart_button.pressed.connect(_on_restart_button_pressed)
	
	if home_button:
		home_button.pressed.connect(_on_home_button_pressed)
	
	# Connect signals for level completion popup
	if level_completion_popup:
		level_completion_popup.continue_pressed.connect(_on_continue_pressed)
		level_completion_popup.visible = false
	
	# Connect to viewport size changes
	get_viewport().size_changed.connect(_on_viewport_size_changed)
	
	print("UI initialized - Moves Label: ", moves_label != null)
	print("UI initialized - Score Label: ", score_label != null)
	print("UI initialized - Objective Label: ", objective_label != null)
	print("UI initialized - Progress Label: ", progress_label != null)
	print("UI initialized - Level Completion Popup: ", level_completion_popup != null)

# Handle viewport size changes
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

# Update the UI elements
func update_ui():
	if moves_label:
		moves_label.text = "Moves: %d" % moves_left
	else:
		print("ERROR: Moves label not found")
	
	if score_label:
		score_label.text = "Score: %d" % score
	else:
		print("ERROR: Score label not found")
	
	if objective_label and progress_label:
		var objective_text = "Clear %d %s dots" % [objective_target, objective_color]
		objective_label.text = objective_text
		
		var progress_text = "%d/%d" % [objective_progress, objective_target]
		progress_label.text = progress_text
	else:
		print("ERROR: Objective or progress label not found")

# Decrease moves by 1 and update display
func use_move():
	moves_left -= 1
	update_ui()
	
	if moves_left <= 0 and !level_complete:
		level_failed = true
		_show_level_failed()
		emit_signal("no_moves_left")

# Add to the score based on dots cleared
func add_score(points):
	score += points
	update_ui()

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
	objective_progress += cleared_target_dots
	update_ui()
	
	# Check if objective is completed
	if objective_progress >= objective_target and !level_complete and !level_failed:
		level_complete = true
		_show_level_complete()
		emit_signal("objective_completed")

# Show level complete screen
func _show_level_complete():
	# Add completion bonus to the score
	var final_score = score + LEVEL_COMPLETION_SCORE
	score = final_score
	update_ui()
	
	# Show the completion popup with success
	if level_completion_popup:
		level_completion_popup.show_completion(true, final_score, moves_left)

# Show level failed screen
func _show_level_failed():
	# Show the completion popup with failure
	if level_completion_popup:
		level_completion_popup.show_completion(false, score, 0)

# Handle continue button press on completion popup
func _on_continue_pressed():
	# Return to the level map
	emit_signal("home_requested")

# Handle restart button press
func _on_restart_button_pressed():
	emit_signal("restart_requested")

# Handle home button press
func _on_home_button_pressed():
	emit_signal("home_requested")

# Reset the game state
func reset_game():
	moves_left = 16
	score = 0
	objective_progress = 0
	level_complete = false
	level_failed = false
	update_ui()

# Set a new objective
func set_objective(type, target, count):
	objective_type = type
	
	if type == "color":
		objective_color = target
	
	objective_target = count
	objective_progress = 0
	update_ui() 
