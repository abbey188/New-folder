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

# Calculate actual distance between dot centers
var dot_distance = DOT_DIAMETER + DOT_SPACING

# Holds references to all dots
var grid = []

# Current selected dot
var selected_dot = null

func _ready():
	# Seed the random number generator
	randomize()
	
	# Create the 6x6 grid
	generate_grid()
	
	# Center the grid on screen
	center_grid()

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
	var random_color = DOT_COLORS[randi() % DOT_COLORS.size()]
	
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
	if event is InputEventScreenTouch and event.pressed:
		handle_touch(event.position)

# Process touch input
func handle_touch(touch_position):
	# Convert global touch position to local grid position
	var local_position = to_local(touch_position)
	
	# Check if touch is within any dot
	for row in grid:
		for dot in row:
			# Calculate distance from touch to dot center
			var distance = local_position.distance_to(dot.position)
			
			# If touch is within dot radius, select it
			if distance <= DOT_DIAMETER / 2:
				toggle_dot_selection(dot)
				return

# Toggle selection of a dot
func toggle_dot_selection(dot):
	var is_selected = dot.get_meta("selected")
	
	# If dot is already selected, deselect it
	if is_selected:
		dot.scale = Vector2(1, 1)  # Reset scale
		dot.modulate = Color(1, 1, 1)  # Reset modulate
		dot.set_meta("selected", false)
	# Otherwise, select it
	else:
		dot.scale = Vector2(SELECTION_SCALE, SELECTION_SCALE)  # Increase size by 10%
		dot.modulate = GLOW_COLOR  # Add glow effect
		dot.set_meta("selected", true) 