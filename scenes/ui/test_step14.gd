extends Node2D

func _ready():
	# Test main menu UI
	print("Testing Main Menu UI...")
	
	# Verify main menu elements
	var main_menu = $MainMenu
	assert(main_menu != null, "Main menu scene should be loaded")
	
	var title = main_menu.get_node("VBoxContainer/Title")
	assert(title != null, "Title label should exist")
	assert(title.text == "DOT", "Title should be 'DOT'")
	
	var play_button = main_menu.get_node("VBoxContainer/PlayButton")
	assert(play_button != null, "Play button should exist")
	assert(play_button.text == "Play", "Play button text should be 'Play'")
	
	var settings_button = main_menu.get_node("VBoxContainer/SettingsButton")
	assert(settings_button != null, "Settings button should exist")
	assert(settings_button.text == "Settings", "Settings button text should be 'Settings'")
	
	# Test settings scene
	print("\nTesting Settings Scene...")
	var settings_scene = load("res://scenes/ui/settings.tscn")
	var settings = settings_scene.instantiate()
	add_child(settings)
	
	# Verify settings elements
	var settings_title = settings.get_node("VBoxContainer/Title")
	assert(settings_title != null, "Settings title should exist")
	assert(settings_title.text == "Settings", "Settings title should be 'Settings'")
	
	var music_toggle = settings.get_node("VBoxContainer/MusicToggle/CheckBox")
	assert(music_toggle != null, "Music toggle should exist")
	assert(music_toggle.text == "On", "Music toggle text should be 'On'")
	
	var sound_toggle = settings.get_node("VBoxContainer/SoundToggle/CheckBox")
	assert(sound_toggle != null, "Sound toggle should exist")
	assert(sound_toggle.text == "On", "Sound toggle text should be 'On'")
	
	var back_button = settings.get_node("VBoxContainer/BackButton")
	assert(back_button != null, "Back button should exist")
	assert(back_button.text == "Back", "Back button text should be 'Back'")
	
	# Test settings save/load
	print("\nTesting Settings Save/Load...")
	var settings_script = settings.get_script()
	var config = ConfigFile.new()
	
	# Test saving settings
	settings_script.music_enabled = false
	settings_script.sound_enabled = false
	settings_script._save_settings()
	
	# Test loading settings
	settings_script.music_enabled = true
	settings_script.sound_enabled = true
	settings_script._load_settings()
	
	assert(!settings_script.music_enabled, "Music setting should be false after loading")
	assert(!settings_script.sound_enabled, "Sound setting should be false after loading")
	
	print("\nAll UI tests passed successfully!") 