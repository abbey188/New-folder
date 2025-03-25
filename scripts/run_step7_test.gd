extends SceneTree

# This script runs the Step 7 verification test independently
# It can be executed from the command line with:
# godot --script scripts/run_step7_test.gd

func _init():
	print("Running Step 7 Verification Test...")
	
	# Load the main scene first (which contains the GameGrid and GameUI)
	var main_scene = load("res://main.tscn").instantiate()
	root.add_child(main_scene)
	
	# Then add our test script to verify Step 7
	var test_scene = load("res://scenes/test_step7.tscn").instantiate()
	root.add_child(test_scene)
	
	# The test script will handle quitting after it finishes 