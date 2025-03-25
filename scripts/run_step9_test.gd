extends Node

# This is a simple script to load and run the Step 9 test scene

func _ready():
	# Load the test scene
	var test_scene = load("res://scenes/test_step9.tscn")
	
	# Check if the test scene loaded successfully
	if test_scene:
		print("Loading test scene for Step 9: Level Completion Logic")
		
		# Create an instance of the scene
		var instance = test_scene.instantiate()
		
		# Add the instance to the scene tree
		get_tree().root.add_child(instance)
		
		# Queue the current scene for deletion
		queue_free()
	else:
		print("ERROR: Failed to load test scene. Please check the file path.") 