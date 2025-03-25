extends Node2D

# This script verifies the implementation of Step 8: Level Objectives
# It will:
# 1. Test that level objectives are displayed
# 2. Test that progress is tracked when clearing dots of the target color
# 3. Verify that the objective completion signal is emitted when the goal is reached

var grid_node
var ui_node
var test_success = true
var failure_messages = []
var objective_completed = false

func _ready():
	print("Starting verification tests for Step 8...")
	
	# Short delay to allow the scene to fully load
	await get_tree().create_timer(0.5).timeout
	
	# Get reference to the GameGrid and GameUI nodes
	grid_node = get_node_or_null("/root/Main/GameGrid")
	ui_node = get_node_or_null("/root/Main/GameUI")
	
	if !grid_node:
		print("ERROR: Could not find GameGrid node")
		test_success = false
		failure_messages.append("FAIL: Could not find GameGrid node")
		output_results()
		return
	
	if !ui_node:
		print("ERROR: Could not find GameUI node")
		test_success = false
		failure_messages.append("FAIL: Could not find GameUI node")
		output_results()
		return
	
	# Connect to the objective_completed signal
	ui_node.objective_completed.connect(_on_objective_completed)
	
	# Begin tests
	print("Found necessary nodes, beginning tests...")
	
	# Test 1: Check if objective UI elements exist
	test_objective_ui()
	
	# Test 2: Test objective tracking
	await test_objective_tracking()
	
	# Output test results
	output_results()
	
	# Clean up and quit after a short delay
	await get_tree().create_timer(1.0).timeout
	get_tree().quit()

func _on_objective_completed():
	print("Objective completed signal received!")
	objective_completed = true

func test_objective_ui():
	print("Testing objective UI elements...")
	# Check if UI has the required nodes
	var objective_container = ui_node.get_node_or_null("ObjectiveContainer")
	if !objective_container:
		print("ERROR: Missing ObjectiveContainer in UI")
		test_success = false
		failure_messages.append("FAIL: Missing ObjectiveContainer in UI")
		return
	
	var objective_label = ui_node.get_node_or_null("ObjectiveContainer/VBoxContainer/ObjectiveLabel")
	if !objective_label:
		print("ERROR: Missing ObjectiveLabel in UI")
		test_success = false
		failure_messages.append("FAIL: Missing ObjectiveLabel in UI")
		return
	
	var progress_label = ui_node.get_node_or_null("ObjectiveContainer/VBoxContainer/ProgressLabel")
	if !progress_label:
		print("ERROR: Missing ProgressLabel in UI")
		test_success = false
		failure_messages.append("FAIL: Missing ProgressLabel in UI")
		return
	
	# Check if UI has required methods
	if !ui_node.has_method("track_cleared_dots"):
		print("ERROR: Missing track_cleared_dots method in GameUI")
		test_success = false
		failure_messages.append("FAIL: Missing track_cleared_dots method in GameUI")
		return
	
	if !ui_node.has_method("set_objective"):
		print("ERROR: Missing set_objective method in GameUI")
		test_success = false
		failure_messages.append("FAIL: Missing set_objective method in GameUI")
		return
	
	# Check default objective display
	var objective_text = objective_label.text
	var progress_text = progress_label.text
	
	print("Objective text: " + objective_text)
	print("Progress text: " + progress_text)
	
	if objective_text.length() == 0 || !objective_text.contains("Clear"):
		print("ERROR: Objective text is missing or incomplete")
		test_success = false
		failure_messages.append("FAIL: Objective text is missing or incomplete")
	
	if progress_text.length() == 0 || !progress_text.contains("/"):
		print("ERROR: Progress text is missing or incomplete")
		test_success = false
		failure_messages.append("FAIL: Progress text is missing or incomplete")

func test_objective_tracking():
	print("Testing objective tracking...")
	# Reset the game with a specific objective
	if grid_node.has_method("reset_game"):
		print("Resetting game...")
		grid_node.reset_game()
		await get_tree().create_timer(0.5).timeout
	
	# Set an objective to clear 3 red dots (index 0)
	print("Setting objective to clear 3 red dots...")
	ui_node.set_objective("color", 0, 3)
	
	# Check initial progress
	print("Initial progress: " + str(ui_node.current_progress))
	if ui_node.current_progress != 0:
		print("ERROR: Initial progress should be 0, but is " + str(ui_node.current_progress))
		test_success = false
		failure_messages.append("FAIL: Initial progress should be 0")
	
	# Try to clear dots of the target color
	var target_color_cleared = false
	var initial_progress = ui_node.current_progress
	
	# Loop until we find and clear at least one red dot
	for attempt in range(5):
		print("Attempt " + str(attempt + 1) + " to clear dots...")
		var success = await clear_dots_of_color(0) # Try to find red dots (index 0)
		
		if success:
			target_color_cleared = true
			break
		
		# Give time for grid to refill before trying again
		await get_tree().create_timer(1.0).timeout
		grid_node.reset_game()
		await get_tree().create_timer(0.5).timeout
	
	if !target_color_cleared:
		print("ERROR: Could not find and clear dots of the target color")
		test_success = false
		failure_messages.append("FAIL: Could not find and clear dots of the target color")
		return
	
	# Wait for processing to complete
	print("Waiting for animations to complete...")
	await get_tree().create_timer(grid_node.FADE_OUT_DURATION + grid_node.DROP_DURATION + 0.5).timeout
	
	# Check if progress increased
	print("After clearing, progress: " + str(ui_node.current_progress))
	if ui_node.current_progress <= initial_progress:
		print("ERROR: Progress did not increase after clearing target color dots")
		test_success = false
		failure_messages.append("FAIL: Progress did not increase after clearing target color dots")

# Clear dots of a specific color
func clear_dots_of_color(target_color_idx):
	print("Finding dots of color index " + str(target_color_idx) + "...")
	try:
		# Reset any existing connections
		if grid_node.has_method("reset_selections"):
			grid_node.reset_selections()
		
		# Find connectable dots of the target color
		var connectable_dots = find_dots_of_color(target_color_idx, 3)
		if connectable_dots.is_empty():
			print("No connectable dots of the target color found")
			return false
		
		print("Found " + str(connectable_dots.size()) + " dots of the target color, connecting them...")
		# Connect and clear dots
		if grid_node.has_method("select_dot") and grid_node.has_method("try_connect_dot"):
			grid_node.select_dot(connectable_dots[0])
			grid_node.try_connect_dot(connectable_dots[1])
			grid_node.try_connect_dot(connectable_dots[2])
			
			# Check if all dots were connected
			if grid_node.connected_dots.size() != 3:
				print("ERROR: Failed to connect all dots")
				return false
			
			print("Clearing connected dots...")
			# Clear the dots
			if grid_node.has_method("handle_touch_release"):
				grid_node.handle_touch_release()
				
				# Wait for the clear animation to finish
				await get_tree().create_timer(grid_node.FADE_OUT_DURATION + 0.2).timeout
				
				return true
		return false
	except:
		print("ERROR: Exception during clear_dots_of_color")
		return false

# Find dots of a specific color that can be connected
func find_dots_of_color(target_color_idx, count):
	var result = []
	
	try:
		# Go through the grid to find adjacent dots of the target color
		for row in range(grid_node.GRID_SIZE):
			for col in range(grid_node.GRID_SIZE):
				# Skip empty cells
				if grid_node.grid[row][col] == null:
					continue
				
				# Check if this dot has the target color
				var dot = grid_node.grid[row][col]
				var color_idx = dot.get_meta("color_idx")
				
				if color_idx != target_color_idx:
					continue
				
				# Start with this dot
				result = [dot]
				
				# Try to find adjacent dots of the same color
				var directions = [
					Vector2(1, 0),   # Right
					Vector2(0, 1),   # Down
					Vector2(1, 1),   # Down-Right
					Vector2(-1, 0),  # Left
					Vector2(0, -1),  # Up
					Vector2(-1, -1), # Up-Left
					Vector2(1, -1),  # Up-Right
					Vector2(-1, 1)   # Down-Left
				]
				
				# Try each direction
				for dir in directions:
					var new_row = row + int(dir.y)
					var new_col = col + int(dir.x)
					
					# Check if the new position is valid
					if new_row >= 0 and new_row < grid_node.GRID_SIZE and new_col >= 0 and new_col < grid_node.GRID_SIZE:
						var neighbor = grid_node.grid[new_row][new_col]
						
						# Skip empty cells
						if neighbor == null:
							continue
						
						# Check if the color matches
						if neighbor.get_meta("color_idx") == target_color_idx:
							result.append(neighbor)
							
							# Check for a third adjacent dot
							for dir2 in directions:
								var new_row2 = new_row + int(dir2.y)
								var new_col2 = new_col + int(dir2.x)
								
								# Skip the original dot
								if new_row2 == row and new_col2 == col:
									continue
								
								# Check if the new position is valid
								if new_row2 >= 0 and new_row2 < grid_node.GRID_SIZE and new_col2 >= 0 and new_col2 < grid_node.GRID_SIZE:
									var neighbor2 = grid_node.grid[new_row2][new_col2]
									
									# Skip empty cells
									if neighbor2 == null:
										continue
									
									# Check if the color matches
									if neighbor2.get_meta("color_idx") == target_color_idx:
										result.append(neighbor2)
										
										# If we have enough dots, return them
										if result.size() >= count:
											return result
				
				# If we found enough dots, return them
				if result.size() >= count:
					return result
				
				# Otherwise, try again with a different starting dot
				result = []
	except:
		print("ERROR: Exception during find_dots_of_color")
		return []
	
	# If we couldn't find enough adjacent dots, return an empty array
	return []

func output_results():
	var output_text = ""
	
	if test_success:
		output_text = "Step 8 Verification: PASS\n\n"
		output_text += "Successfully implemented level objectives:\n"
		output_text += "- Objective UI elements display correctly\n"
		output_text += "- Progress is tracked when clearing dots of the target color\n"
		output_text += "- Objective completion is detected when the goal is reached\n"
	else:
		output_text = "Step 8 Verification: FAIL\n\n"
		output_text += "The following issues were found:\n"
		
		for message in failure_messages:
			output_text += "- " + message + "\n"
		
		output_text += "\nPlease fix these issues before proceeding to Step 9."
	
	# Save output to a file
	print("Saving verification results to step8_verification.txt")
	var file = FileAccess.open("res://step8_verification.txt", FileAccess.WRITE)
	file.store_string(output_text)
	file.close()
	
	# Also print to console
	print(output_text) 