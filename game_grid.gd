extends Node2D

signal level_completed(level: int, stars: int)

var level_index: int = 0
var level_data: Dictionary = {
	"moves": 16,
	"objective": {
		"type": "color",
		"color": "red",
		"count": 10
	}
}

func _ready() -> void:
	# Load level-specific data
	load_level_data()
	
	# Initialize the grid with level data
	initialize_grid()

func load_level_data() -> void:
	# In a real implementation, this would load from a JSON file
	# For now, we'll use hardcoded data for testing
	pass

func initialize_grid() -> void:
	# ... existing grid initialization code ...
	
	# Update UI with level-specific data
	update_ui()

func update_ui() -> void:
	# Update moves counter
	$UI/MovesLabel.text = "Moves: %d" % level_data.moves
	
	# Update objective
	var objective = level_data.objective
	$UI/ObjectiveLabel.text = "Clear %d %s dots" % [objective.count, objective.color]

func on_level_complete(stars: int) -> void:
	# Emit completion signal
	level_completed.emit(level_index, stars)
	
	# Show completion popup
	show_completion_popup(stars)

func show_completion_popup(stars: int) -> void:
	var popup = $UI/CompletionPopup
	popup.show()
	
	# Update popup content
	popup.get_node("TitleLabel").text = "Level Complete!"
	popup.get_node("StarsLabel").text = "%d Stars" % stars
	
	# Show appropriate number of stars
	for i in range(3):
		var star = popup.get_node("Star%d" % (i + 1))
		star.visible = i < stars
		if i < stars:
			star.modulate = Color(1, 1, 1, 1)
		else:
			star.modulate = Color(0.5, 0.5, 0.5, 1)

func _on_continue_button_pressed() -> void:
	# Return to level map
	var level_map = preload("res://level_map.tscn").instantiate()
	get_tree().root.add_child(level_map)
	queue_free()

# ... rest of existing code ... 