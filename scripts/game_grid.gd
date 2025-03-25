extends Node2D

# Grid dimensions
const GRID_SIZE = 6  # 6x6 grid
const DOT_DIAMETER = 85  # Dot size in pixels
const DOT_SPACING = 47  # Space between dots (edge to edge)
const DOT_COLOR = Color(0.7, 0.7, 0.7)  # Default gray color (used as fallback)

# Define dot colors
const DOT_COLORS = [
	Color(0.95, 0.3, 0.3),  # Red
	Color(0.3, 0.6, 0.95),  # Blue
	Color(0.3, 0.9, 0.4),   # Green
	Color(0.95, 0.8, 0.3),  # Yellow
	Color(0.8, 0.4, 0.9)    # Purple
]

# Selection properties
const SELECTION_SCALE = 1.1  # 10% size increase when selected
const GLOW_COLOR = Color(1, 1, 1, 0.7)  # White glow with transparency
const GLOW_SIZE = 5  # Size of the glow in pixels

# Connection properties
const LINE_WIDTH = 8  # Line thickness (about 1/10th of dot diameter)
const LINE_OPACITY = 0.8  # Line opacity
const MIN_DOTS_TO_CLEAR = 3  # Minimum connected dots required to clear
const FADE_OUT_DURATION = 0.4  # Fade-out animation duration when cleared

# Refill properties
const REFILL_DELAY = 0.05  # Short delay before refilling (seconds)
const DROP_DURATION = 0.2  # Duration of the drop animation (seconds)
const DROP_EASING = Tween.EASE_IN_OUT  # Easing curve for the drop animation

# Calculate actual distance between dot centers
var dot_distance = DOT_DIAMETER + DOT_SPACING

# Holds references to all dots
var grid = []

# Connection variables
var connected_dots = []  # Dots currently connected
var connection_line = Line2D.new()  # Line for visualizing connections
var last_selected_dot = null  # Last dot that was selected

# Game state
var is_processing = false  # Flag to prevent input during animations
var game_ui = null  # Reference to the UI layer

# Audio manager reference
var audio_manager = null

# Achievement variables
var level_number = 1  # Assuming a default level number
var current_objective_progress = 0  # Assuming a default objective progress

func _ready():
	# Seed the random number generator
	randomize()
	
	# Create the 6x6 grid
	generate_grid()
	
	# Center the grid on screen
	center_grid()
	
	# Set up the connection line
	setup_connection_line()
	
	# Get reference to UI
	game_ui = $GameUI
	
	# Get reference to audio manager
	audio_manager = get_node("/root/AudioManager")
	
	# Connect signals for game state
	if game_ui:
		game_ui.no_moves_left.connect(_on_no_moves_left)
		game_ui.objective_completed.connect(_on_objective_completed)

func _on_no_moves_left():
	# Handle game over state
	print("Game Over: No moves left!")
	
	# Play level fail sound
	if audio_manager:
		audio_manager.play_level_fail()
	
	# Processing will be handled by the UI now
	is_processing = true  # Prevent further input

func _on_objective_completed():
	# Handle level completion
	print("Level Complete: Objective achieved!")
	# Processing will be handled by the UI now
	is_processing = true  # Prevent further input

func reset_game():
	# Clear the grid
	for row in grid:
		for dot in row:
			if dot != null:
				dot.queue_free()
	
	grid.clear()
	
	# Regenerate the grid
	generate_grid()
	
	# Reset UI
	if game_ui:
		game_ui.reset_game()
	
	# Re-enable input
	is_processing = false

func setup_connection_line():
	# Add the Line2D node for connections
	connection_line.width = LINE_WIDTH
	connection_line.default_color = Color(1, 1, 1, LINE_OPACITY)
	connection_line.joint_mode = Line2D.LINE_JOINT_ROUND
	connection_line.begin_cap_mode = Line2D.LINE_CAP_ROUND
	connection_line.end_cap_mode = Line2D.LINE_CAP_ROUND
	add_child(connection_line)
	connection_line.visible = false

func generate_grid():
	# Loop through rows and columns to create dots
	for row in range(GRID_SIZE):
		var row_dots = []
		for col in range(GRID_SIZE):
			var dot = create_dot()
			
			# Position dot based on row and column
			dot.position.x = col * dot_distance
			dot.position.y = row * dot_distance
			
			# Store grid position as metadata
			dot.set_meta("grid_pos", Vector2(col, row))
			
			add_child(dot)
			row_dots.append(dot)
		
		grid.append(row_dots)

func create_dot():
	# Create a new Sprite2D node for the dot
	var dot = Sprite2D.new()
	
	# Get a random color from the DOT_COLORS array
	var color_idx = randi() % DOT_COLORS.size()
	var random_color = DOT_COLORS[color_idx]
	
	# Create a circle texture for the dot
	var image = Image.create(DOT_DIAMETER, DOT_DIAMETER, false, Image.FORMAT_RGBA8)
	image.fill(Color(0, 0, 0, 0))  # Start with transparent image
	
	# Draw circle in the image
	for x in range(DOT_DIAMETER):
		for y in range(DOT_DIAMETER):
			var dx = x - DOT_DIAMETER / 2
			var dy = y - DOT_DIAMETER / 2
			var distance = sqrt(dx * dx + dy * dy)
			
			if distance <= DOT_DIAMETER / 2:
				image.set_pixel(x, y, random_color)
	
	# Create texture from image
	var texture = ImageTexture.create_from_image(image)
	dot.texture = texture
	
	# Store the dot's color for future game logic
	dot.set_meta("color", random_color)
	dot.set_meta("color_idx", color_idx)  # Store the color index
	dot.set_meta("selected", false)
	
	return dot

func center_grid():
	# Get viewport size
	var viewport_size = get_viewport_rect().size
	
	# Calculate grid total size
	var grid_width = GRID_SIZE * dot_distance - DOT_SPACING  # Subtract last spacing
	var grid_height = GRID_SIZE * dot_distance - DOT_SPACING  # Subtract last spacing
	
	# Center position
	var centered_x = (viewport_size.x - grid_width) / 2
	var centered_y = (viewport_size.y - grid_height) / 2
	
	# Set grid position
	position = Vector2(centered_x, centered_y)

# Handle input events
func _input(event):
	# Ignore input while processing animations
	if is_processing:
		return
		
	if event is InputEventScreenTouch:
		if event.pressed:
			handle_touch(event.position)
		else:
			# On touch release, check if we have enough dots connected
			handle_touch_release()

# Handle touch release (finger lifted from screen)
func handle_touch_release():
	# If we have enough dots connected, clear them
	if connected_dots.size() >= MIN_DOTS_TO_CLEAR:
		clear_connected_dots()
		
		# Use a move in the UI when a valid connection is made
		if game_ui:
			game_ui.use_move()
	else:
		# Reset all selections and connections
		reset_selections()

# Process touch input
func handle_touch(touch_position):
	# Convert global touch position to local grid position
	var local_position = to_local(touch_position)
	
	# Check if touch is within any dot
	for row in grid:
		for dot in row:
			# Skip empty grid spaces
			if dot == null:
				continue
				
			# Calculate distance from touch to dot center
			var distance = local_position.distance_to(dot.position)
			
			# If touch is within dot radius, try to select it or connect it
			if distance <= DOT_DIAMETER / 2:
				if connected_dots.is_empty():
					# First dot selection
					select_dot(dot)
				else:
					# Try to connect to the previously selected dot
					try_connect_dot(dot)
				return

# Check if dots form a square (for bonus points)
func is_square_shape(dots):
	# Need at least 4 dots to form a square
	if dots.size() < 4:
		return false
	
	# Simple square detection: check if there are exactly 4 dots forming corners
	var positions = []
	for dot in dots:
		positions.append(dot.get_meta("grid_pos"))
	
	# Get min and max coordinates
	var min_x = INF
	var min_y = INF
	var max_x = -INF
	var max_y = -INF
	
	for pos in positions:
		min_x = min(min_x, pos.x)
		min_y = min(min_y, pos.y)
		max_x = max(max_x, pos.x)
		max_y = max(max_y, pos.y)
	
	# Check if it's a square/rectangle (width and height > 0)
	var width = max_x - min_x
	var height = max_y - min_y
	
	if width <= 0 or height <= 0:
		return false
	
	# For a perfect square, all 4 corners must be present
	var corners = [
		Vector2(min_x, min_y),
		Vector2(max_x, min_y),
		Vector2(min_x, max_y),
		Vector2(max_x, max_y)
	]
	
	var corner_count = 0
	for corner in corners:
		if corner in positions:
			corner_count += 1
	
	return corner_count == 4

# Select a dot (first dot in a chain)
func select_dot(dot):
	# Only select if not already selected
	if not dot.get_meta("selected"):
		# Add to connected dots
		connected_dots.append(dot)
		
		# Mark as selected
		dot.set_meta("selected", true)
		
		# Visual feedback
		dot.scale = Vector2(SELECTION_SCALE, SELECTION_SCALE)
		dot.modulate = GLOW_COLOR
		
		# Update connection line
		update_connection_line()
		
		# Play dot selection sound
		if audio_manager:
			audio_manager.play_dot_connect()

# Try to connect a dot to the current chain
func try_connect_dot(dot):
	# Don't connect if dot is already connected
	if dot in connected_dots:
		# If it's the previous dot, allow backtracking
		if connected_dots.size() > 1 and dot == connected_dots[connected_dots.size() - 2]:
			# Remove the last dot (backtracking)
			var last_dot = connected_dots.pop_back()
			last_dot.modulate = Color(1, 1, 1)  # Reset appearance
			last_dot.scale = Vector2(1, 1)
			last_dot.set_meta("selected", false)
			
			# Update the last selected dot
			last_selected_dot = connected_dots[connected_dots.size() - 1]
			
			# Update the connection line
			update_connection_line()
		return
	
	# Check if the dot is the same color
	if dot.get_meta("color") != connected_dots[0].get_meta("color"):
		return
	
	# Check if dots are adjacent
	if not are_dots_adjacent(last_selected_dot, dot):
		return
	
	# Connect the dot
	dot.scale = Vector2(SELECTION_SCALE, SELECTION_SCALE)  # Increase size by 10%
	dot.modulate = GLOW_COLOR  # Add glow effect 
	dot.set_meta("selected", false)  # We use this metadata for individual dot selection
	
	# Add to connected dots list
	connected_dots.append(dot)
	last_selected_dot = dot
	
	# Update the connection line
	update_connection_line()

# Check if two dots are adjacent (orthogonally or diagonally)
func are_dots_adjacent(dot1, dot2):
	var pos1 = dot1.get_meta("grid_pos")
	var pos2 = dot2.get_meta("grid_pos")
	
	# Calculate the distance between the dots
	var dx = abs(pos1.x - pos2.x)
	var dy = abs(pos1.y - pos2.y)
	
	# Dots are adjacent if they're 1 step away (including diagonals)
	return dx <= 1 and dy <= 1 and (dx + dy > 0)

# Update the visual connection line
func update_connection_line():
	connection_line.clear_points()
	
	# Add each dot's position to the line
	for dot in connected_dots:
		connection_line.add_point(dot.position)

# Reset all selections and connections
func reset_selections():
	# Reset all connected dots
	for dot in connected_dots:
		dot.scale = Vector2(1, 1)
		dot.modulate = Color(1, 1, 1)
		dot.set_meta("selected", false)
	
	# Clear the connection line
	connection_line.clear_points()
	connection_line.visible = false
	
	# Clear the connected dots list
	connected_dots.clear()
	last_selected_dot = null

# Clear the connected dots (when there are 3+ in a chain)
func clear_connected_dots():
	# Play level completion sound if objective is met
	if game_ui and game_ui.is_objective_completed():
		if audio_manager:
			audio_manager.play_level_complete()
	
	# Create a tween for the fade-out animation
	var tween = create_tween()
	
	# Animate each connected dot
	for dot in connected_dots:
		# Get grid position
		var grid_pos = dot.get_meta("grid_pos")
		
		# Animate scale and opacity
		tween.parallel().tween_property(dot, "scale", Vector2(1.2, 1.2), FADE_OUT_DURATION)
		tween.parallel().tween_property(dot, "modulate:a", 0.0, FADE_OUT_DURATION)
		
		# Clear the grid position
		grid[grid_pos.y][grid_pos.x] = null
	
	# Wait for animation to complete before refilling
	tween.tween_callback(refill_grid)
	
	# Clear the connection line
	connection_line.visible = false
	
	# Reset connected dots array
	connected_dots.clear()

# Refill the grid with new dots
func refill_grid():
	# First, collapse columns to fill empty spaces
	await collapse_columns()
	
	# Then add new dots at the top
	await add_new_dots_at_top()

# Collapse columns to fill empty spaces
func collapse_columns():
	var tween = create_tween()
	var dots_moved = false
	
	# Process each column
	for col in range(GRID_SIZE):
		# Start from the bottom of the column and move upward
		var empty_row = -1
		
		# Process from bottom to top
		for row in range(GRID_SIZE - 1, -1, -1):
			# If this is an empty position, mark it
			if grid[row][col] == null:
				if empty_row == -1:
					empty_row = row
			# If we have an empty position below and this position has a dot
			elif empty_row != -1:
				# Move this dot down to the empty position
				var dot = grid[row][col]
				
				# Update grid references
				grid[empty_row][col] = dot
				grid[row][col] = null
				
				# Update dot's internal position metadata
				dot.set_meta("grid_pos", Vector2(col, empty_row))
				
				# Animate the dot moving down
				var new_position = Vector2(col * dot_distance, empty_row * dot_distance)
				tween.parallel().tween_property(dot, "position", new_position, DROP_DURATION).set_ease(DROP_EASING)
				
				# Mark that we moved a dot
				dots_moved = true
				
				# Now the current position is empty, and we need to find the next empty position
				empty_row -= 1
	
	# Wait for all dots to finish moving
	if dots_moved:
		await tween.finished

# Add new dots at the top where needed
func add_new_dots_at_top():
	var tween = create_tween()
	var new_dots_added = false
	
	# Check each column for empty spaces at the top
	for col in range(GRID_SIZE):
		var empty_count = 0
		
		# Count empty spaces in this column
		for row in range(GRID_SIZE):
			if grid[row][col] == null:
				empty_count += 1
		
		# If there are empty spaces, add new dots
		if empty_count > 0:
			for i in range(empty_count):
				# Create a new dot
				var new_dot = create_dot()
				
				# Position dot at the top of the column, above the grid
				var target_row = empty_count - 1 - i
				new_dot.position.x = col * dot_distance
				new_dot.position.y = -dot_distance * (i + 1)  # Start above the grid
				
				# Update grid reference
				grid[target_row][col] = new_dot
				
				# Update dot's internal position metadata
				new_dot.set_meta("grid_pos", Vector2(col, target_row))
				
				# Add to scene
				add_child(new_dot)
				
				# Animate the dot falling down
				var target_position = Vector2(col * dot_distance, target_row * dot_distance)
				tween.parallel().tween_property(new_dot, "position", target_position, DROP_DURATION).set_ease(DROP_EASING)
				
				# Mark that we added a new dot
				new_dots_added = true
	
	# Wait for all new dots to finish falling
	if new_dots_added:
		await tween.finished

# Legacy toggle function (kept for backwards compatibility)
func toggle_dot_selection(dot):
	# If we're already in connection mode, ignore individual toggles
	if not connected_dots.is_empty():
		return
		
	var is_selected = dot.get_meta("selected")
	
	# If dot is already selected, deselect it
	if is_selected:
		dot.scale = Vector2(1, 1)  # Reset scale
		dot.modulate = Color(1, 1, 1)  # Reset modulate
		dot.set_meta("selected", false)
	# Otherwise, select it
	else:
		select_dot(dot) 

func _show_completion_popup(stars: int):
	# Get references
	var popup = get_node("CompletionPopup")
	var effects = get_node("VisualEffects")
	
	# Show completion popup
	if popup:
		popup.show()
		popup.call("set_stars", stars)
	
	# Create celebratory effect
	if effects:
		var particles = effects.call("create_level_complete_effect", [self])
		if particles:
			add_child(particles)
	
	# Save progress
	var current_level = get_level_number()
	
	# Save progress using FileAccess since SaveManager isn't implemented yet
	var save_data = {
		"level_stars": stars,
		"level_number": current_level
	}
	
	var file = FileAccess.open("user://level_progress.save", FileAccess.WRITE)
	if file:
		file.store_var(save_data)
		file.close()
	
	# Unlock next level
	var next_level = current_level + 1
	if next_level <= 3:  # Assuming we have 3 levels
		var progress_file = FileAccess.open("user://level_progress.save", FileAccess.READ_WRITE)
		if progress_file:
			var data = progress_file.get_var()
			data["level_" + str(next_level) + "_unlocked"] = true
			progress_file.store_var(data)
			progress_file.close()

func check_level_completion_achievements(stars: int) -> void:
	# Store achievement progress locally since AchievementManager isn't implemented yet
	var achievements = {}
	if FileAccess.file_exists("user://achievements.save"):
		var file = FileAccess.open("user://achievements.save", FileAccess.READ)
		if file:
			achievements = file.get_var()
			file.close()
	
	# Update achievements
	var current_level = get_level_number()
	if current_level == 1:
		achievements["first_victory"] = true
	if stars == 3:
		achievements["perfect_level"] = true
	if get_objective_progress() >= 50:
		achievements["color_master"] = true
	
	# Save achievements
	var file = FileAccess.open("user://achievements.save", FileAccess.WRITE)
	if file:
		file.store_var(achievements)
		file.close()

func calculate_stars():
	# Implementation of calculate_stars function
	# This function should return the calculated number of stars based on the game's logic
	return 3  # Placeholder return, actual implementation needed

func completion_popup():
	# Implementation of completion_popup function
	# This function should return the reference to the completion popup
	return $CompletionPopup  # Placeholder return, actual implementation needed

func visual_effects():
	# Implementation of visual_effects function
	# This function should return the reference to the visual effects manager
	return $VisualEffects  # Placeholder return, actual implementation needed

func get_level_number():
	# Implementation of get_level_number function
	# This function should return the current level number
	return 1  # Placeholder return, actual implementation needed

func get_objective_progress():
	# Implementation of get_objective_progress function
	# This function should return the current objective progress
	return 50  # Placeholder return, actual implementation needed 
