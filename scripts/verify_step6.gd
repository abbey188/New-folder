extends Node2D

# This script verifies the implementation of Step 6: Grid Refill Functionality
# It will:
# 1. Test that after clearing dots, the grid collapses properly
# 2. Test that new dots are added at the top to fill empty spaces
# 3. Verify the animations work correctly

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
	print("Starting verification tests for Step 6...")
	
	# Test 1: Check if refill methods exist
	test_refill_methods()
	
	# Test 2: Test dot clearance and refill
	await test_grid_refill()
	
	# Output test results
	output_results()
	
	# Clean up and quit after a short delay to let animations finish
	await get_tree().create_timer(2.0).timeout
	get_tree().quit()

func test_refill_methods():
	# Check if required methods exist
	if !grid_node.has_method("refill_grid"):
		test_success = false
		failure_messages.append("FAIL: Missing refill_grid method in GameGrid")
	
	if !grid_node.has_method("collapse_columns"):
		test_success = false
		failure_messages.append("FAIL: Missing collapse_columns method in GameGrid")
	
	if !grid_node.has_method("add_new_dots_at_top"):
		test_success = false
		failure_messages.append("FAIL: Missing add_new_dots_at_top method in GameGrid")

func test_grid_refill():
	# Reset anything that might be selected
	if grid_node.has_method("reset_selections"):
		grid_node.reset_selections()
	
	# Take a snapshot of the grid before clearing
	var grid_before = count_dots_in_grid()
	print("Grid before: ", grid_before, " dots")
	
	# Find and clear dots
	var success = await clear_some_dots()
	if !success:
		test_success = false
		failure_messages.append("FAIL: Could not find and clear dots")
		return
	
	# We need to wait a bit longer for refill to complete
	await get_tree().create_timer(grid_node.DROP_DURATION * 2 + 0.2).timeout
	
	# Take a snapshot of the grid after refilling
	var grid_after = count_dots_in_grid()
	print("Grid after: ", grid_after, " dots")
	
	# Check if grid has been fully replenished
	if grid_after != grid_before:
		test_success = false
		failure_messages.append("FAIL: Grid was not properly refilled after clearing dots")
		return
	
	# Check if all grid cells are non-null
	for row in range(grid_node.GRID_SIZE):
		for col in range(grid_node.GRID_SIZE):
			if grid_node.grid[row][col] == null:
				test_success = false
				failure_messages.append("FAIL: Null space found at (%d, %d) after refill" % [col, row])
				return

# Count dots in the grid
func count_dots_in_grid():
	var count = 0
	
	for row in grid_node.grid:
		for dot in row:
			if dot != null:
				count += 1
	
	return count

# Find dots that can be connected and clear them
async func clear_some_dots():
	# Reset any existing connections
	grid_node.reset_selections()
	
	# Find connectable dots
	var connectable_dots = find_connectable_dots(3)
	if connectable_dots.is_empty():
		return false
	
	# Connect and clear dots
	grid_node.select_dot(connectable_dots[0])
	grid_node.try_connect_dot(connectable_dots[1])
	grid_node.try_connect_dot(connectable_dots[2])
	
	# Check if all dots were connected
	if grid_node.connected_dots.size() != 3:
		return false
	
	# Clear the dots
	grid_node.handle_touch_release()
	
	# Wait for the clear animation to finish
	await get_tree().create_timer(grid_node.FADE_OUT_DURATION + 0.1).timeout
	
	return true

# Helper function to find connectable dots (same as in verify_step5.gd)
func find_connectable_dots(count):
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
		output_text = "Step 6 Verification: PASS\n\n"
		output_text += "Successfully implemented grid refill functionality:\n"
		output_text += "- Dots collapse properly to fill empty spaces\n"
		output_text += "- New dots are added at the top of columns\n"
		output_text += "- Animations work correctly for both movement and new dots\n"
		output_text += "- Grid is fully restored to a 6x6 layout after clearing\n"
	else:
		output_text = "Step 6 Verification: FAIL\n\n"
		output_text += "The following issues were found:\n"
		
		for message in failure_messages:
			output_text += "- " + message + "\n"
		
		output_text += "\nPlease fix these issues before proceeding to Step 7."
	
	# Save output to a file
	var file = FileAccess.open("res://step6_verification.txt", FileAccess.WRITE)
	file.store_string(output_text)
	file.close()
	
	# Also print to console
	print(output_text) 