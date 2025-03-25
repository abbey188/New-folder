extends Control

@onready var margin_container = $MarginContainer

# Base margin values for different device classes
const PHONE_MARGINS = Vector4(15, 15, 15, 15)  # left, top, right, bottom
const TABLET_MARGINS = Vector4(40, 40, 40, 40)
const DESKTOP_MARGINS = Vector4(80, 60, 80, 60)

# Breakpoints for device classification
const TABLET_MIN_WIDTH = 768
const DESKTOP_MIN_WIDTH = 1024

# Get UIScaling singleton
@onready var ui_scaling = get_node("/root/UIScaling")

func _ready():
	# Apply responsive margins based on device size
	apply_responsive_margins()
	
	# Connect to window resize notifications
	get_viewport().size_changed.connect(_on_viewport_size_changed)
	
	print("Responsive container initialized with device class: ", get_device_class())

func apply_responsive_margins():
	# Get current viewport size
	var viewport_size = get_viewport().size
	
	# Determine device class based on screen width
	var device_class = get_device_class()
	
	# Set margins based on device class and apply scaling
	var base_margins = get_base_margins(device_class)
	var scaled_margins = Vector4(
		ui_scaling.scale_value(base_margins.x),
		ui_scaling.scale_value(base_margins.y),
		ui_scaling.scale_value(base_margins.z),
		ui_scaling.scale_value(base_margins.w)
	)
	
	# Apply margins to the container
	margin_container.add_theme_constant_override("margin_left", scaled_margins.x)
	margin_container.add_theme_constant_override("margin_top", scaled_margins.y)
	margin_container.add_theme_constant_override("margin_right", scaled_margins.z)
	margin_container.add_theme_constant_override("margin_bottom", scaled_margins.w)
	
	print("Applied margins: ", scaled_margins)

func get_device_class() -> String:
	var width = get_viewport().size.x
	
	if width >= DESKTOP_MIN_WIDTH:
		return "desktop"
	elif width >= TABLET_MIN_WIDTH:
		return "tablet"
	else:
		return "phone"

func get_base_margins(device_class: String) -> Vector4:
	match device_class:
		"desktop":
			return DESKTOP_MARGINS
		"tablet":
			return TABLET_MARGINS
		_:  # Default to phone
			return PHONE_MARGINS

func _on_viewport_size_changed():
	# Re-apply margins when the viewport size changes
	apply_responsive_margins() 