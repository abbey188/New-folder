extends Node

# Singleton for handling mobile-specific UI
class_name MobileUIHandler

# UI scaling factors
var base_scale: float = 1.0
var safe_area_insets: Dictionary = {}

# Reference to the main UI container
var main_container: Control

# Initialize the mobile UI handler
func _ready() -> void:
	# Set process mode to always to ensure UI updates even when game is paused
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	# Get safe area insets
	update_safe_area_insets()
	
	# Connect to window size changed signal
	get_tree().root.content_scale_size_changed.connect(_on_window_size_changed)
	
	# Initial UI setup
	setup_mobile_ui()

# Update safe area insets based on device
func update_safe_area_insets() -> void:
	var display = DisplayServer.window_get_current_screen()
	var safe_area = DisplayServer.window_get_safe_title_area()
	
	safe_area_insets = {
		"left": safe_area.position.x,
		"top": safe_area.position.y,
		"right": safe_area.size.x,
		"bottom": safe_area.size.y
	}

# Setup mobile-specific UI
func setup_mobile_ui() -> void:
	# Create main container with safe area handling
	main_container = Control.new()
	main_container.name = "MobileUIContainer"
	main_container.set_anchors_preset(Control.PRESET_FULL_RECT)
	main_container.position = Vector2(safe_area_insets["left"], safe_area_insets["top"])
	main_container.size = Vector2(safe_area_insets["right"], safe_area_insets["bottom"])
	add_child(main_container)
	
	# Calculate base scale based on screen size
	calculate_base_scale()
	
	# Apply scaling to all UI elements
	scale_ui_elements()

# Calculate base scale factor based on screen size
func calculate_base_scale() -> void:
	var screen_size = DisplayServer.window_get_size()
	var target_width = 720  # Base width from project settings
	var target_height = 1280  # Base height from project settings
	
	var width_scale = screen_size.x / target_width
	var height_scale = screen_size.y / target_height
	
	# Use the smaller scale to ensure UI fits on screen
	base_scale = min(width_scale, height_scale)

# Scale all UI elements
func scale_ui_elements() -> void:
	if not main_container:
		return
	
	# Scale all direct children of main container
	for child in main_container.get_children():
		scale_control(child)

# Scale a control and its children recursively
func scale_control(control: Control) -> void:
	# Scale font sizes if they exist
	if control is Label:
		var label = control as Label
		if label.theme_override_font_sizes:
			for size_name in label.theme_override_font_sizes:
				var original_size = label.theme_override_font_sizes[size_name]
				label.theme_override_font_sizes[size_name] = original_size * base_scale
	
	# Scale margins and padding if they exist
	if control.theme_override_constants:
		for constant_name in control.theme_override_constants:
			if constant_name.ends_with("margin") or constant_name.ends_with("padding"):
				var original_value = control.theme_override_constants[constant_name]
				control.theme_override_constants[constant_name] = original_value * base_scale
	
	# Scale icon sizes if they exist
	if control.theme_override_icons:
		for icon_name in control.theme_override_icons:
			var icon = control.theme_override_icons[icon_name]
			if icon:
				control.theme_override_icons[icon_name] = scale_icon(icon)
	
	# Recursively scale children
	for child in control.get_children():
		scale_control(child)

# Scale an icon texture
func scale_icon(icon: Texture2D) -> Texture2D:
	if not icon:
		return null
	
	var scaled_size = icon.get_size() * base_scale
	var scaled_image = Image.create(scaled_size.x, scaled_size.y, false, Image.FORMAT_RGBA8)
	scaled_image.blend_rect(icon.get_image(), Rect2i(Vector2i.ZERO, icon.get_size()), Vector2i.ZERO)
	
	return ImageTexture.create_from_image(scaled_image)

# Handle window size changes
func _on_window_size_changed() -> void:
	update_safe_area_insets()
	calculate_base_scale()
	scale_ui_elements()
	
	# Update main container position and size
	if main_container:
		main_container.position = Vector2(safe_area_insets["left"], safe_area_insets["top"])
		main_container.size = Vector2(safe_area_insets["right"], safe_area_insets["bottom"])

# Get the current base scale
func get_base_scale() -> float:
	return base_scale

# Get safe area insets
func get_safe_area_insets() -> Dictionary:
	return safe_area_insets

# Add a control to the mobile UI container
func add_control(control: Control) -> void:
	if main_container:
		main_container.add_child(control)
		scale_control(control)

# Remove a control from the mobile UI container
func remove_control(control: Control) -> void:
	if main_container and control.get_parent() == main_container:
		main_container.remove_child(control) 