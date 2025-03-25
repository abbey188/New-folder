extends Node2D

# Node references
@onready var music_volume_slider = $UI/MusicVolumeSlider
@onready var sfx_volume_slider = $UI/SFXVolumeSlider
@onready var music_toggle = $UI/MusicToggle
@onready var sfx_toggle = $UI/SFXToggle
@onready var back_button = $UI/BackButton

func _ready():
	# Load saved settings
	load_settings()
	
	# Connect signals
	music_volume_slider.value_changed.connect(_on_music_volume_changed)
	sfx_volume_slider.value_changed.connect(_on_sfx_volume_changed)
	music_toggle.toggled.connect(_on_music_toggled)
	sfx_toggle.toggled.connect(_on_sfx_toggled)
	back_button.pressed.connect(_on_back_pressed)

func load_settings():
	var settings = SaveManager.get_instance().get_settings()
	
	# Update UI with saved settings
	music_volume_slider.value = settings.music_volume
	sfx_volume_slider.value = settings.sfx_volume
	music_toggle.button_pressed = settings.music_enabled
	sfx_toggle.button_pressed = settings.sfx_enabled
	
	# Apply settings to audio system
	apply_settings(settings)

func apply_settings(settings: Dictionary):
	# Apply music settings
	if settings.music_enabled:
		AudioServer.set_bus_volume_db(
			AudioServer.get_bus_index("Music"),
			linear_to_db(settings.music_volume)
		)
	else:
		AudioServer.set_bus_volume_db(
			AudioServer.get_bus_index("Music"),
			-80.0  # Effectively mute
		)
	
	# Apply SFX settings
	if settings.sfx_enabled:
		AudioServer.set_bus_volume_db(
			AudioServer.get_bus_index("SFX"),
			linear_to_db(settings.sfx_volume)
		)
	else:
		AudioServer.set_bus_volume_db(
			AudioServer.get_bus_index("SFX"),
			-80.0  # Effectively mute
		)

func _on_music_volume_changed(value: float):
	var settings = SaveManager.get_instance().get_settings()
	settings.music_volume = value
	SaveManager.get_instance().update_settings(settings)
	apply_settings(settings)

func _on_sfx_volume_changed(value: float):
	var settings = SaveManager.get_instance().get_settings()
	settings.sfx_volume = value
	SaveManager.get_instance().update_settings(settings)
	apply_settings(settings)

func _on_music_toggled(enabled: bool):
	var settings = SaveManager.get_instance().get_settings()
	settings.music_enabled = enabled
	SaveManager.get_instance().update_settings(settings)
	apply_settings(settings)

func _on_sfx_toggled(enabled: bool):
	var settings = SaveManager.get_instance().get_settings()
	settings.sfx_enabled = enabled
	SaveManager.get_instance().update_settings(settings)
	apply_settings(settings)

func _on_back_pressed():
	# Return to main menu
	var main_menu = preload("res://scenes/main_menu.tscn").instantiate()
	get_tree().root.add_child(main_menu)
	queue_free() 