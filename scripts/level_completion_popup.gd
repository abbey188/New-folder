extends Control

signal continue_pressed

@onready var status_label = $Panel/VBoxContainer/StatusLabel
@onready var score_label = $Panel/VBoxContainer/ScoreLabel
@onready var stars_container = $Panel/VBoxContainer/StarsContainer
@onready var continue_button = $Panel/VBoxContainer/ContinueButton

func _ready():
	continue_button.pressed.connect(_on_continue_button_pressed)
	visible = false

func show_completion(success: bool, final_score: int, moves_left: int):
	status_label.text = "Level Complete!" if success else "Level Failed!"
	score_label.text = "Score: %d" % final_score
	
	# Calculate stars based on moves left
	var stars = 0
	if success:
		if moves_left >= 5:
			stars = 3
		elif moves_left >= 1:
			stars = 2
		else:
			stars = 1
	
	# Clear existing stars
	for child in stars_container.get_children():
		child.queue_free()
	
	# Add star sprites
	for i in range(3):
		var star = TextureRect.new()
		star.modulate = Color(1, 1, 0) if i < stars else Color(0.3, 0.3, 0.3)
		stars_container.add_child(star)
	
	visible = true

func _on_continue_button_pressed():
	visible = false
	emit_signal("continue_pressed") 