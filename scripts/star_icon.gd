extends Control

@export var fill_color: Color = Color(1, 0.9, 0.1, 1)  # Yellow star
@export var outline_color: Color = Color(0.9, 0.5, 0, 1)  # Orange outline
@export var outline_width: float = 2.0

# Number of points in the star
const POINTS = 5
const INNER_RADIUS_RATIO = 0.4

func _draw():
	var center = size / 2
	var outer_radius = min(center.x, center.y)
	var inner_radius = outer_radius * INNER_RADIUS_RATIO
	
	# Calculate points of the star
	var points = []
	var angle_step = 2 * PI / (2 * POINTS)
	
	for i in range(2 * POINTS):
		var radius = outer_radius if i % 2 == 0 else inner_radius
		var angle = -PI / 2 + i * angle_step
		var point = center + Vector2(radius * cos(angle), radius * sin(angle))
		points.append(point)
	
	# Draw the star
	draw_colored_polygon(points, fill_color)
	
	# Draw the outline
	if outline_width > 0:
		for i in range(points.size()):
			var next_i = (i + 1) % points.size()
			draw_line(points[i], points[next_i], outline_color, outline_width)

func _notification(what):
	if what == NOTIFICATION_RESIZED:
		queue_redraw() 