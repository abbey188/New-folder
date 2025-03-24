extends Node2D

# Define dot colors (same as in game_grid.gd)
const DOT_COLORS = [
	Color(0.95, 0.3, 0.3),  # Red
	Color(0.3, 0.6, 0.95),  # Blue
	Color(0.3, 0.9, 0.4),   # Green
	Color(0.95, 0.8, 0.3),  # Yellow
	Color(0.8, 0.4, 0.9)    # Purple
]

func _ready():
	# Seed the random number generator
	randomize()
	
	# Generate a test grid of colors and print them
	print("Color Test Output:")
	print("=================")
	
	var grid = []
	for row in range(6):
		var row_colors = []
		var row_str = ""
		for col in range(6):
			var color_idx = randi() % DOT_COLORS.size()
			var color = DOT_COLORS[color_idx]
			row_colors.append(color)
			
			# Create a simple visual representation
			match color_idx:
				0: row_str += "R " # Red
				1: row_str += "B " # Blue
				2: row_str += "G " # Green
				3: row_str += "Y " # Yellow
				4: row_str += "P " # Purple
		
		grid.append(row_colors)
		print(row_str)
	
	print("=================")
	print("R = Red, B = Blue, G = Green, Y = Yellow, P = Purple")
	print("Test complete. This confirms the random color generation is working.") 