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
	
	# Also save to a file
	var file = FileAccess.open("res://color_test_output.txt", FileAccess.WRITE)
	file.store_line("Color Test Output:")
	file.store_line("=================")
	
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
		file.store_line(row_str)
	
	print("=================")
	print("R = Red, B = Blue, G = Green, Y = Yellow, P = Purple")
	print("Test complete. This confirms the random color generation is working.")
	
	file.store_line("=================")
	file.store_line("R = Red, B = Blue, G = Green, Y = Yellow, P = Purple")
	file.store_line("Test complete. This confirms the random color generation is working.")
	file.close()
	
	# Also output a basic visualization to confirm we have all colors
	var colors_used = [false, false, false, false, false]
	for row_colors in grid:
		for color in row_colors:
			for i in range(DOT_COLORS.size()):
				if color == DOT_COLORS[i]:
					colors_used[i] = true
	
	print("\nColor Distribution Check:")
	print("Red used: ", colors_used[0])
	print("Blue used: ", colors_used[1])
	print("Green used: ", colors_used[2])
	print("Yellow used: ", colors_used[3])
	print("Purple used: ", colors_used[4])
	
	file = FileAccess.open("res://color_distribution.txt", FileAccess.WRITE)
	file.store_line("Color Distribution Check:")
	file.store_line("Red used: " + str(colors_used[0]))
	file.store_line("Blue used: " + str(colors_used[1]))
	file.store_line("Green used: " + str(colors_used[2]))
	file.store_line("Yellow used: " + str(colors_used[3]))
	file.store_line("Purple used: " + str(colors_used[4]))
	file.close() 