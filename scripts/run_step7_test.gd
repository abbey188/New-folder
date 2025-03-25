extends SceneTree

# This script runs the Step 7 verification test independently
# It can be executed from the command line with:
# godot --script scripts/run_step7_test.gd

func _init():
	print("Running Step 7 Verification Test...")
	
	# Set up error handling
	print("Setting up error handlers...")
	get_root().set_auto_accept_quit(false)
	
	# Attempt to load the main scene
	print("Loading main scene...")
	var main_scene
	
	try:
		main_scene = load("res://main.tscn")
		if main_scene == null:
			print("ERROR: Failed to load main scene!")
			quit(1)
			return
			
		main_scene = main_scene.instantiate()
		root.add_child(main_scene)
		print("Main scene loaded successfully")
	except:
		print("ERROR: Exception while loading main scene!")
		quit(1)
		return
	
	# Then add our test script to verify Step 7
	print("Loading test scene...")
	var test_scene
	
	try:
		test_scene = load("res://scenes/test_step7.tscn")
		if test_scene == null:
			print("ERROR: Failed to load test scene!")
			quit(1)
			return
			
		test_scene = test_scene.instantiate()
		root.add_child(test_scene)
		print("Test scene loaded successfully")
	except:
		print("ERROR: Exception while loading test scene!")
		quit(1)
		return
	
	print("Test setup complete. Test script will handle verification and quitting.") 