extends Node

# Design reference resolution
const DESIGN_WIDTH = 720
const DESIGN_HEIGHT = 1280

# Scale factors
var scale_factor_x: float = 1.0
var scale_factor_y: float = 1.0
var scale_factor: float = 1.0  # The smaller of the two, for uniform scaling

# Margin percentages for safe areas
const TOP_MARGIN_PERCENT = 5
const BOTTOM_MARGIN_PERCENT = 5
const SIDE_MARGIN_PERCENT = 3

# Actual margin sizes in pixels
var top_margin: int = 0
var bottom_margin: int = 0
var left_margin: int = 0
var right_margin: int = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	# Get current viewport size
	var viewport_size = get_viewport().size
	
	# Calculate scale factors
	scale_factor_x = viewport_size.x / DESIGN_WIDTH
	scale_factor_y = viewport_size.y / DESIGN_HEIGHT
	scale_factor = min(scale_factor_x, scale_factor_y)
	
	# Calculate safe area margins
	top_margin = int(viewport_size.y * TOP_MARGIN_PERCENT / 100)
	bottom_margin = int(viewport_size.y * BOTTOM_MARGIN_PERCENT / 100)
	left_margin = int(viewport_size.x * SIDE_MARGIN_PERCENT / 100)
	right_margin = int(viewport_size.x * SIDE_MARGIN_PERCENT / 100)
	
	print("UI Scaling: Scale factor = ", scale_factor)
	print("UI Scaling: Safe margins = ", top_margin, ", ", bottom_margin, ", ", left_margin, ", ", right_margin)

# Scale a size value based on the current scale factor
func scale_value(value: float) -> float:
	return value * scale_factor

# Scale a Vector2 size based on the current scale factor
func scale_vector(vec: Vector2) -> Vector2:
	return Vector2(vec.x * scale_factor_x, vec.y * scale_factor_y)

# Get a Rect2 representing the safe area for UI elements
func get_safe_area() -> Rect2:
	var viewport_size = get_viewport().size
	return Rect2(
		left_margin, 
		top_margin, 
		viewport_size.x - left_margin - right_margin, 
		viewport_size.y - top_margin - bottom_margin
	)

# Apply safe area margins to a Control node
func apply_safe_margins(control: Control) -> void:
	if control:
		# Set margins based on safe area
		control.add_theme_constant_override("margin_top", top_margin)
		control.add_theme_constant_override("margin_bottom", bottom_margin)
		control.add_theme_constant_override("margin_left", left_margin)
		control.add_theme_constant_override("margin_right", right_margin)

# Scale a font size based on viewport
func get_scaled_font_size(base_size: int) -> int:
	return int(base_size * scale_factor)

# Rescale Control nodes
func rescale_control(control: Control, base_size: Vector2) -> void:
	var new_size = scale_vector(base_size)
	control.custom_minimum_size = new_size
	
# Handle viewport size changes
func _on_viewport_size_changed():
	# Recalculate all scaling factors when viewport changes
	_ready() 