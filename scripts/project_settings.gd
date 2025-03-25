extends Node

# Singleton for managing project settings
class_name ProjectSettings

# Initialize project settings
func _ready() -> void:
	configure_mobile_settings()
	register_singletons()

# Configure mobile-specific settings
func configure_mobile_settings() -> void:
	# Enable mobile optimizations
	RenderingServer.set_default_clear_color(Color(0.2, 0.2, 0.2, 1.0))
	
	# Configure texture settings
	ProjectSettings.set_setting("rendering/textures/canvas_textures/default_texture_filter", 0)  # Nearest
	ProjectSettings.set_setting("rendering/textures/default_texture_filter", 0)  # Nearest
	
	# Configure physics settings
	ProjectSettings.set_setting("physics/2d/default_gravity", 980)
	ProjectSettings.set_setting("physics/2d/sleep_threshold_linear", 2.0)
	ProjectSettings.set_setting("physics/2d/sleep_threshold_angular", 0.5)
	
	# Configure input settings
	ProjectSettings.set_setting("input_devices/pointing/emulate_touch_from_mouse", true)
	ProjectSettings.set_setting("input_devices/pointing/emulate_mouse_from_touch", false)
	
	# Configure display settings
	ProjectSettings.set_setting("display/window/size/viewport_width", 720)
	ProjectSettings.set_setting("display/window/size/viewport_height", 1280)
	ProjectSettings.set_setting("display/window/size/window_width_override", 720)
	ProjectSettings.set_setting("display/window/size/window_height_override", 1280)
	ProjectSettings.set_setting("display/window/stretch/mode", "canvas_items")
	ProjectSettings.set_setting("display/window/stretch/aspect", "expand")
	
	# Configure memory settings
	ProjectSettings.set_setting("memory/limits/message_queue/max_size_kb", 1024)
	ProjectSettings.set_setting("memory/limits/multithreaded_server/rid_pool_prealloc", 60)
	
	# Configure rendering settings
	ProjectSettings.set_setting("rendering/quality/driver/driver_name", "GLES2")
	ProjectSettings.set_setting("rendering/quality/driver/fallback_to_gles2", true)
	ProjectSettings.set_setting("rendering/quality/filters/msaa", 0)  # Disable MSAA for better performance
	ProjectSettings.set_setting("rendering/quality/filters/screen_space_aa", 0)  # Disable SSAA for better performance
	ProjectSettings.set_setting("rendering/quality/filters/use_fxaa", true)  # Enable FXAA for better performance
	ProjectSettings.set_setting("rendering/quality/filters/use_debanding", false)  # Disable debanding for better performance
	
	# Configure shader settings
	ProjectSettings.set_setting("rendering/quality/shader/use_physical_light_units", false)
	ProjectSettings.set_setting("rendering/quality/shader/use_physical_light_attenuation", false)
	
	# Configure audio settings
	ProjectSettings.set_setting("audio/driver/enable_input", true)
	ProjectSettings.set_setting("audio/driver/mix_rate", 44100)
	ProjectSettings.set_setting("audio/driver/output_latency", 15)
	ProjectSettings.set_setting("audio/driver/output_latency.web", 16384)
	
	# Configure export settings
	ProjectSettings.set_setting("export/android/version/code", 1)
	ProjectSettings.set_setting("export/android/version/name", "1.0")
	ProjectSettings.set_setting("export/android/package/unique_name", "com.yourcompany.dot")
	ProjectSettings.set_setting("export/android/package/name", "Dot")
	ProjectSettings.set_setting("export/android/package/signed", true)
	ProjectSettings.set_setting("export/android/package/release", true)
	ProjectSettings.set_setting("export/android/architecture/arm64-v8a", true)
	ProjectSettings.set_setting("export/android/architecture/armeabi-v7a", true)
	ProjectSettings.set_setting("export/android/architecture/x86", false)
	ProjectSettings.set_setting("export/android/architecture/x86_64", false)
	
	# Configure iOS export settings
	ProjectSettings.set_setting("export/ios/app_icon", "res://assets/icons/ios/icon.png")
	ProjectSettings.set_setting("export/ios/launch_screen", "res://assets/icons/ios/launch_screen.png")
	ProjectSettings.set_setting("export/ios/info_plist_template", "res://export/ios/info.plist")
	ProjectSettings.set_setting("export/ios/provisioning_profile", "res://export/ios/profile.mobileprovision")
	ProjectSettings.set_setting("export/ios/certificate", "res://export/ios/certificate.p12")
	ProjectSettings.set_setting("export/ios/certificate_password", "")

# Register autoload singletons
func register_singletons() -> void:
	# Register SpriteAtlasManager
	if not ProjectSettings.has_autoload("SpriteAtlasManager"):
		ProjectSettings.add_autoload("SpriteAtlasManager", "res://scripts/sprite_atlas_manager.gd")
	
	# Register ObjectPool
	if not ProjectSettings.has_autoload("ObjectPool"):
		ProjectSettings.add_autoload("ObjectPool", "res://scripts/object_pool.gd")
	
	# Register PerformanceMonitor
	if not ProjectSettings.has_autoload("PerformanceMonitor"):
		ProjectSettings.add_autoload("PerformanceMonitor", "res://scripts/performance_monitor.gd")
	
	# Register MobileUIHandler
	if not ProjectSettings.has_autoload("MobileUIHandler"):
		ProjectSettings.add_autoload("MobileUIHandler", "res://scripts/mobile_ui_handler.gd")

# Save project settings
func save_settings() -> void:
	ProjectSettings.save() 