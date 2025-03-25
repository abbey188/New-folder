extends SceneTree

# This script runs the Step 8 verification test independently
# It can be executed from the command line with:
# godot --script scripts/run_step8_test.gd

func _init():
	print("Running Step 8 Verification Test...")
	
	# Set up error handling
	print("Setting up error handlers...")
	get_root().set_auto_accept_quit(false)
	
	# Load the main scene first (which contains the GameGrid)
	print("Loading main scene...")
	var main_scene = load("res://main.tscn").instantiate()
	root.add_child(main_scene)
	print("Main scene loaded successfully")
	
	# Then add our test script to verify Step 8
	print("Loading test scene...")
	var test_scene = load("res://scenes/test_step8.tscn").instantiate()
	root.add_child(test_scene)
	print("Test scene loaded successfully")
	
	print("Test setup complete. Test script will handle quitting after it finishes") 