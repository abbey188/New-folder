extends Node2D

# Grid dimensions
const GRID_SIZE = 6  # 6x6 grid
const DOT_DIAMETER = 85  # Dot size in pixels
const DOT_SPACING = 47  # Space between dots (edge to edge)
const DOT_COLOR = Color(0.7, 0.7, 0.7)  # Default gray color

# Calculate actual distance between dot centers
var dot_distance = DOT_DIAMETER + DOT_SPACING

# Holds references to all dots
var grid = []

func _ready():
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
			
			add_child(dot)
			row_dots.append(dot)
		
		grid.append(row_dots)

func create_dot():
	# Create a new Sprite2D node for the dot
	var dot = Sprite2D.new()
	
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
				image.set_pixel(x, y, DOT_COLOR)
	
	# Create texture from image
	var texture = ImageTexture.create_from_image(image)
	dot.texture = texture
	
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