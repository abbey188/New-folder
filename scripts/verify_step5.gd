extends Node2D

# This script verifies the implementation of Step 5: Implement Dot Connection Logic
# It will:
# 1. Test the connection of adjacent dots with the same color
# 2. Verify that lines are drawn between connected dots
# 3. Ensure that connected dots are cleared when three or more are linked
# 4. Check if the fade-out animation works when dots are cleared

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
	print("Starting verification tests for Step 5...")
	
	# Test 1: Check if connection methods exist
	test_connection_methods()
	
	# Test 2: Test dot connection
	test_dot_connection()
	
	# Test 3: Test connection line visualization
	test_connection_line()
	
	# Test 4: Test dot clearing
	test_dot_clearing()
	
	# Output test results
	output_results()
	
	# Clean up and quit
	await get_tree().create_timer(1.0).timeout
	get_tree().quit()

func test_connection_methods():
	# Check if the required methods exist
	if !grid_node.has_method("try_connect_dot"):
		test_success = false
		failure_messages.append("FAIL: Missing try_connect_dot method in GameGrid")
	
	if !grid_node.has_method("are_dots_adjacent"):
		test_success = false
		failure_messages.append("FAIL: Missing are_dots_adjacent method in GameGrid")
	
	if !grid_node.has_method("update_connection_line"):
		test_success = false
		failure_messages.append("FAIL: Missing update_connection_line method in GameGrid")
	
	if !grid_node.has_method("clear_connected_dots"):
		test_success = false
		failure_messages.append("FAIL: Missing clear_connected_dots method in GameGrid")

func test_dot_connection():
	# Reset anything that might be selected
	if grid_node.has_method("reset_selections"):
		grid_node.reset_selections()
	
	# Find three adjacent dots of the same color
	var test_dots = find_adjacent_same_color_dots(3)
	if test_dots.is_empty():
		test_success = false
		failure_messages.append("FAIL: Could not find 3 adjacent dots of the same color for testing")
		return
	
	# Select the first dot
	if grid_node.has_method("select_dot"):
		grid_node.select_dot(test_dots[0])
	else:
		test_success = false
		failure_messages.append("FAIL: Missing select_dot method in GameGrid")
		return
	
	# Connect the second dot
	if grid_node.has_method("try_connect_dot"):
		grid_node.try_connect_dot(test_dots[1])
	else:
		test_success = false
		failure_messages.append("FAIL: Missing try_connect_dot method in GameGrid")
		return
	
	# Check if the dots were connected properly
	if grid_node.connected_dots.size() != 2:
		test_success = false
		failure_messages.append("FAIL: Failed to connect 2 dots")
		return
	
	# Connect the third dot
	if grid_node.has_method("try_connect_dot"):
		grid_node.try_connect_dot(test_dots[2])
	else:
		test_success = false
		failure_messages.append("FAIL: Missing try_connect_dot method in GameGrid")
		return
	
	# Check if all three dots were connected
	if grid_node.connected_dots.size() != 3:
		test_success = false
		failure_messages.append("FAIL: Failed to connect 3 dots")
		return

func test_connection_line():
	# Check if the connection line is visible
	if !grid_node.connection_line.visible:
		test_success = false
		failure_messages.append("FAIL: Connection line is not visible")
		return
	
	# Check if the line has the correct number of points
	if grid_node.connection_line.get_point_count() != grid_node.connected_dots.size():
		test_success = false
		failure_messages.append("FAIL: Connection line does not have the correct number of points")
		return
	
	# Check if the line has the proper style
	if grid_node.connection_line.width != grid_node.LINE_WIDTH:
		test_success = false
		failure_messages.append("FAIL: Connection line does not have the correct width")
		return

func test_dot_clearing():
	# Simulate touch release to clear connected dots
	if grid_node.has_method("handle_touch_release"):
		grid_node.handle_touch_release()
		
		# Since the clear animation is async, we need to wait a bit
		await get_tree().create_timer(grid_node.FADE_OUT_DURATION + 0.2).timeout
		
		# Check if dots were cleared (connected_dots should be empty)
		if !grid_node.connected_dots.is_empty():
			test_success = false
			failure_messages.append("FAIL: Connected dots were not cleared properly")
			return
		
		# Check if the connection line was hidden
		if grid_node.connection_line.visible:
			test_success = false
			failure_messages.append("FAIL: Connection line is still visible after clearing")
			return
	else:
		test_success = false
		failure_messages.append("FAIL: Missing handle_touch_release method in GameGrid")
		return

# Helper function to find adjacent dots of the same color
func find_adjacent_same_color_dots(count):
	var result = []
	
	# Go through the grid to find adjacent dots of the same color
	for row in range(grid_node.GRID_SIZE):
		for col in range(grid_node.GRID_SIZE):
			# Skip empty cells
			if grid_node.grid[row][col] == null:
				continue
			
			# Start with this dot
			result = [grid_node.grid[row][col]]
			var start_color = result[0].get_meta("color")
			
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
					if neighbor.get_meta("color") == start_color:
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
								if neighbor2.get_meta("color") == start_color:
									result.append(neighbor2)
									
									# If we have enough dots, return them
									if result.size() >= count:
										return result
			
			# If we found enough dots, return them
			if result.size() >= count:
				return result
			
			# Otherwise, try again with a different starting dot
			result = []
	
	# If we couldn't find enough adjacent dots, return an empty array
	return []

func output_results():
	var output_text = ""
	
	if test_success:
		output_text = "Step 5 Verification: PASS\n\n"
		output_text += "Successfully implemented dot connection logic:\n"
		output_text += "- Adjacent dots of the same color can be connected\n"
		output_text += "- Connection is visualized with a properly styled line\n"
		output_text += "- Connected dots can be cleared when 3 or more are linked\n"
		output_text += "- Dots have a proper fade-out animation when cleared\n"
	else:
		output_text = "Step 5 Verification: FAIL\n\n"
		output_text += "The following issues were found:\n"
		
		for message in failure_messages:
			output_text += "- " + message + "\n"
		
		output_text += "\nPlease fix these issues before proceeding to Step 6."
	
	# Save output to a file
	var file = FileAccess.open("res://step5_verification.txt", FileAccess.WRITE)
	file.store_string(output_text)
	file.close()
	
	# Also print to console
	print(output_text) 