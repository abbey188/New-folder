extends Control

signal continue_pressed

# References to UI elements
@onready var title_label = $VBoxContainer/TitleLabel
@onready var score_label = $VBoxContainer/ScoreContainer/ScoreValue
@onready var stars_container = $VBoxContainer/StarsContainer
@onready var continue_button = $VBoxContainer/ContinueButton

# Star nodes references
@onready var star1 = $VBoxContainer/StarsContainer/Star1
@onready var star2 = $VBoxContainer/StarsContainer/Star2
@onready var star3 = $VBoxContainer/StarsContainer/Star3

# Star rating thresholds
const THREE_STARS_THRESHOLD = 5  # 5+ moves left
const TWO_STARS_THRESHOLD = 1    # 1-4 moves left
# 1 star for 0 moves left

# Animation constants
const STAR_APPEAR_DURATION = 0.3
const STAR_DELAY = 0.2

func _ready():
	# Hide popup initially
	visible = false
	
	# Connect button signal
	continue_button.pressed.connect(_on_continue_button_pressed)
	
	# Ensure stars are hidden initially
	_reset_stars()

# Show the completion popup with appropriate status
func show_completion(is_success, score, moves_left):
	# Set the title based on whether the level was completed
	if is_success:
		title_label.text = "LEVEL COMPLETE"
	else:
		title_label.text = "LEVEL FAILED"
	
	# Set the score
	score_label.text = str(score)
	
	# Show stars based on moves left (only if level completed)
	if is_success:
		_show_stars(moves_left)
	else:
		_reset_stars()
	
	# Make the popup visible
	visible = true

# Calculate and show stars based on moves left
func _show_stars(moves_left):
	# Reset stars first
	_reset_stars()
	
	# Determine how many stars to show
	var star_count = 1  # Minimum 1 star for completing
	if moves_left >= THREE_STARS_THRESHOLD:
		star_count = 3
	elif moves_left >= TWO_STARS_THRESHOLD:
		star_count = 2
	
	# Show the stars with animation
	var tween = create_tween()
	
	# Show appropriate number of stars with animation
	if star_count >= 1:
		star1.visible = true
		star1.scale = Vector2.ZERO
		tween.tween_property(star1, "scale", Vector2.ONE, STAR_APPEAR_DURATION).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	
	if star_count >= 2:
		star2.visible = true
		star2.scale = Vector2.ZERO
		tween.tween_interval(STAR_DELAY)
		tween.tween_property(star2, "scale", Vector2.ONE, STAR_APPEAR_DURATION).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	
	if star_count >= 3:
		star3.visible = true
		star3.scale = Vector2.ZERO
		tween.tween_interval(STAR_DELAY)
		tween.tween_property(star3, "scale", Vector2.ONE, STAR_APPEAR_DURATION).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)

# Reset stars to hidden state
func _reset_stars():
	star1.visible = false
	star2.visible = false
	star3.visible = false
	
	star1.scale = Vector2.ONE
	star2.scale = Vector2.ONE
	star3.scale = Vector2.ONE

# Handle continue button press
func _on_continue_button_pressed():
	# Hide the popup
	visible = false
	
	# Emit signal
	emit_signal("continue_pressed") 