extends Node

# Singleton instance
var _instance = null

# Save data structure
var save_data: SaveData = SaveData.new()

# Save file path
const SAVE_FILE = "user://dot_save.res"

func _ready():
	# Load save data on startup
	load_save()

func get_instance():
	if _instance == null:
		_instance = self
	return _instance

# Save the current game state
func save_game():
	var error = ResourceSaver.save(save_data, SAVE_FILE)
	if error != OK:
		push_error("Failed to save game: " + str(error))
		return false
	return true

# Load the saved game state
func load_save():
	if not FileAccess.file_exists(SAVE_FILE):
		return false
		
	var loaded_data = ResourceLoader.load(SAVE_FILE)
	if loaded_data and loaded_data is SaveData:
		save_data = loaded_data
		return true
	return false

# Check if a level is unlocked
func is_level_unlocked(level_number: int) -> bool:
	return level_number in save_data.unlocked_levels

# Unlock a level
func unlock_level(level_number: int):
	if not is_level_unlocked(level_number):
		save_data.unlocked_levels.append(level_number)
		save_game()

# Get star rating for a level
func get_level_stars(level_number: int) -> int:
	return save_data.level_stars.get(level_number, 0)

# Set star rating for a level
func set_level_stars(level_number: int, stars: int):
	save_data.level_stars[level_number] = stars
	save_game()

# Get settings
func get_settings() -> Dictionary:
	return save_data.settings

# Update settings
func update_settings(new_settings: Dictionary):
	save_data.settings = new_settings
	save_game() 