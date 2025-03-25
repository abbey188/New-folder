extends Node2D

# This script verifies the implementation of Step 4: Touch Input for Dot Selection
# It will:
# 1. Create a test grid similar to the game grid
# 2. Simulate touch input (since we can't actually test touch in the editor)
# 3. Verify that dots are selected with proper visual feedback
# 4. Output results to step4_verification.txt

const GRID_SIZE = 6
var grid_node
var test_success = true
var failure_messages = []

func _ready():
	# Short delay to allow the scene to fully load
	await get_tree().create_timer(0.5).timeout
	
	# Get reference to the GameGrid node
	grid_node = get_node("/root/Main/GameGrid")
	if !grid_node:
		test_success = false
		failure_messages.append("FAIL: Could not find GameGrid node")
		output_results()
		return
	
	# Begin tests
	print("Starting verification tests for Step 4...")
	
	# Test 1: Check if input handling methods exist
	test_input_methods()
	
	# Test 2: Simulate dot selection
	test_dot_selection()
	
	# Output test results
	output_results()
	
	# Clean up and quit
	await get_tree().create_timer(1.0).timeout
	get_tree().quit()

func test_input_methods():
	# Check if the required methods exist
	if !grid_node.has_method("_input"):
		test_success = false
		failure_messages.append("FAIL: Missing _input method in GameGrid")
	
	if !grid_node.has_method("handle_touch"):
		test_success = false
		failure_messages.append("FAIL: Missing handle_touch method in GameGrid")
	
	if !grid_node.has_method("toggle_dot_selection"):
		test_success = false
		failure_messages.append("FAIL: Missing toggle_dot_selection method in GameGrid")

func test_dot_selection():
	# Get a random dot from the grid
	if grid_node.grid.size() == 0 || grid_node.grid[0].size() == 0:
		test_success = false
		failure_messages.append("FAIL: Grid is empty")
		return
	
	# Get a dot in the middle of the grid
	var test_dot = grid_node.grid[2][2]
	
	# Get dot's global position
	var dot_global_pos = test_dot.global_position
	
	# Store original state
	var original_scale = test_dot.scale
	var original_modulate = test_dot.modulate
	var original_selected = test_dot.get_meta("selected") if test_dot.has_meta("selected") else false
	
	# Create a touch event at the dot's position
	var touch_event = InputEventScreenTouch.new()
	touch_event.pressed = true
	touch_event.position = dot_global_pos
	
	# Send the event to the grid
	grid_node._input(touch_event)
	
	# Verify the dot was selected
	await get_tree().create_timer(0.2).timeout
	
	# Check if the dot was marked as selected
	if !test_dot.has_meta("selected") || !test_dot.get_meta("selected"):
		test_success = false
		failure_messages.append("FAIL: Dot was not marked as selected")
	
	# Check if the dot's scale was increased
	if test_dot.scale.x <= original_scale.x || test_dot.scale.y <= original_scale.y:
		test_success = false
		failure_messages.append("FAIL: Dot scale was not increased")
	
	# Check if the dot's appearance changed (modulate or other visual effect)
	if test_dot.modulate == original_modulate:
		test_success = false
		failure_messages.append("FAIL: Dot appearance did not change (no visual feedback)")
	
	# Now test deselection
	touch_event.position = dot_global_pos
	grid_node._input(touch_event)
	
	# Verify the dot was deselected
	await get_tree().create_timer(0.2).timeout
	
	# Check if the dot was marked as not selected
	if test_dot.has_meta("selected") && test_dot.get_meta("selected"):
		test_success = false
		failure_messages.append("FAIL: Dot was not deselected on second tap")
	
	# Check if the dot's scale was reset
	if test_dot.scale != Vector2(1, 1):
		test_success = false
		failure_messages.append("FAIL: Dot scale was not reset when deselected")

func output_results():
	var output_text = ""
	
	if test_success:
		output_text = "Step 4 Verification: PASS\n\n"
		output_text += "Successfully implemented dot selection with touch input:\n"
		output_text += "- Input detection is working\n"
		output_text += "- Dots can be selected by tapping\n"
		output_text += "- Selected dots show visual feedback (scale increase and glow)\n"
		output_text += "- Dots can be deselected by tapping again\n"
	else:
		output_text = "Step 4 Verification: FAIL\n\n"
		output_text += "The following issues were found:\n"
		
		for message in failure_messages:
			output_text += "- " + message + "\n"
		
		output_text += "\nPlease fix these issues before proceeding to Step 5."
	
	# Save output to a file
	var file = FileAccess.open("res://step4_verification.txt", FileAccess.WRITE)
	file.store_string(output_text)
	file.close()
	
	# Also print to console
	print(output_text) 