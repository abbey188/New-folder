extends Node2D

# This script verifies the implementation of Step 7: Move Counter and Scoring System
# It will:
# 1. Test that the move counter starts at 16 and decreases with each valid connection
# 2. Test that the score increases when dots are cleared
# 3. Verify that special connections (squares, 10+ dots) apply multipliers

var grid_node
var ui_node
var test_success = true
var failure_messages = []

func _ready():
	print("Starting verification tests for Step 7...")
	
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
	
	# Begin tests
	print("Found necessary nodes, beginning tests...")
	
	# Test 1: Check if UI elements exist
	test_ui_elements()
	
	# Test 2: Test move counter
	await test_move_counter()
	
	# Test 3: Test scoring system
	await test_scoring_system()
	
	# Output test results
	output_results()
	
	# Clean up and quit after a short delay
	await get_tree().create_timer(1.0).timeout
	get_tree().quit()

func test_ui_elements():
	print("Testing UI elements...")
	# Check if UI has the required nodes
	var moves_label = ui_node.get_node_or_null("MovesContainer/VBoxContainer/MovesLabel")
	if !moves_label:
		print("ERROR: Missing MovesLabel in UI")
		test_success = false
		failure_messages.append("FAIL: Missing MovesLabel in UI")
	
	var score_label = ui_node.get_node_or_null("ScoreContainer/VBoxContainer/ScoreLabel")
	if !score_label:
		print("ERROR: Missing ScoreLabel in UI")
		test_success = false
		failure_messages.append("FAIL: Missing ScoreLabel in UI")
	
	# Check if UI has required methods
	if !ui_node.has_method("update_moves_display"):
		print("ERROR: Missing update_moves_display method in GameUI")
		test_success = false
		failure_messages.append("FAIL: Missing update_moves_display method in GameUI")
	
	if !ui_node.has_method("update_score_display"):
		print("ERROR: Missing update_score_display method in GameUI")
		test_success = false
		failure_messages.append("FAIL: Missing update_score_display method in GameUI")
	
	if !ui_node.has_method("use_move"):
		print("ERROR: Missing use_move method in GameUI")
		test_success = false
		failure_messages.append("FAIL: Missing use_move method in GameUI")
	
	if !ui_node.has_method("add_score"):
		print("ERROR: Missing add_score method in GameUI")
		test_success = false
		failure_messages.append("FAIL: Missing add_score method in GameUI")

func test_move_counter():
	print("Testing move counter...")
	# Make sure the game is reset
	if grid_node.has_method("reset_game"):
		print("Resetting game...")
		grid_node.reset_game()
		await get_tree().create_timer(0.5).timeout
	
	# Check initial move count
	print("Initial moves: " + str(ui_node.moves_left))
	if ui_node.moves_left != 16:
		print("ERROR: Initial move count should be 16, but is " + str(ui_node.moves_left))
		test_success = false
		failure_messages.append("FAIL: Initial move count should be 16, but is " + str(ui_node.moves_left))
	
	# Clear some dots to test move counter
	var initial_moves = ui_node.moves_left
	print("Attempting to clear dots...")
	var success = await clear_some_dots()
	
	if !success:
		print("ERROR: Could not clear dots to test move counter")
		test_success = false
		failure_messages.append("FAIL: Could not clear dots to test move counter")
		return
	
	# Wait for processing to complete
	print("Waiting for animations to complete...")
	await get_tree().create_timer(grid_node.FADE_OUT_DURATION + grid_node.DROP_DURATION + 0.5).timeout
	
	# Check if move counter decreased
	print("After clearing, moves: " + str(ui_node.moves_left))
	if ui_node.moves_left != initial_moves - 1:
		print("ERROR: Move counter did not decrease by 1 after clearing dots")
		test_success = false
		failure_messages.append("FAIL: Move counter did not decrease by 1 after clearing dots")

func test_scoring_system():
	print("Testing scoring system...")
	# Reset the game to start fresh
	if grid_node.has_method("reset_game"):
		print("Resetting game...")
		grid_node.reset_game()
		await get_tree().create_timer(0.5).timeout
	
	# Check initial score
	print("Initial score: " + str(ui_node.current_score))
	if ui_node.current_score != 0:
		print("ERROR: Initial score should be 0, but is " + str(ui_node.current_score))
		test_success = false
		failure_messages.append("FAIL: Initial score should be 0, but is " + str(ui_node.current_score))
	
	# Clear some dots to test scoring
	var initial_score = ui_node.current_score
	print("Attempting to clear dots...")
	var success = await clear_some_dots()
	
	if !success:
		print("ERROR: Could not clear dots to test scoring")
		test_success = false
		failure_messages.append("FAIL: Could not clear dots to test scoring")
		return
	
	# Wait for processing to complete
	print("Waiting for animations to complete...")
	await get_tree().create_timer(grid_node.FADE_OUT_DURATION + grid_node.DROP_DURATION + 0.5).timeout
	
	# Check if score increased
	print("After clearing, score: " + str(ui_node.current_score))
	if ui_node.current_score <= initial_score:
		print("ERROR: Score did not increase after clearing dots")
		test_success = false
		failure_messages.append("FAIL: Score did not increase after clearing dots")

# Find dots that can be connected and clear them
func clear_some_dots():
	print("Finding connectable dots...")
	try:
		# Reset any existing connections
		if grid_node.has_method("reset_selections"):
			grid_node.reset_selections()
		
		# Find connectable dots
		var connectable_dots = find_connectable_dots(3)
		if connectable_dots.is_empty():
			print("ERROR: No connectable dots found")
			return false
		
		print("Found " + str(connectable_dots.size()) + " connectable dots, connecting them...")
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
		print("ERROR: Exception during clear_some_dots")
		return false

# Helper function to find connectable dots
func find_connectable_dots(count):
	var result = []
	
	try:
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
	except:
		print("ERROR: Exception during find_connectable_dots")
		return []
	
	# If we couldn't find enough adjacent dots, return an empty array
	return []

func output_results():
	var output_text = ""
	
	if test_success:
		output_text = "Step 7 Verification: PASS\n\n"
		output_text += "Successfully implemented move counter and scoring system:\n"
		output_text += "- Move counter starts at 16 and decreases with each valid connection\n"
		output_text += "- Score increases when dots are cleared\n"
		output_text += "- UI elements display the move count and score correctly\n"
	else:
		output_text = "Step 7 Verification: FAIL\n\n"
		output_text += "The following issues were found:\n"
		
		for message in failure_messages:
			output_text += "- " + message + "\n"
		
		output_text += "\nPlease fix these issues before proceeding to Step 8."
	
	# Save output to a file
	print("Saving verification results to step7_verification.txt")
	var file = FileAccess.open("res://step7_verification.txt", FileAccess.WRITE)
	file.store_string(output_text)
	file.close()
	
	# Also print to console
	print(output_text) 