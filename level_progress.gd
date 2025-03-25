extends Resource
class_name LevelProgress

@export var unlocked_levels: Array[bool] = [true, false, false]  # Level 1 starts unlocked
@export var level_stars: Array[int] = [0, 0, 0]  # Store stars earned for each level

const SAVE_PATH = "user://level_progress.tres"

static func load_progress() -> LevelProgress:
	var progress = LevelProgress.new()
	
	if FileAccess.file_exists(SAVE_PATH):
		var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
		var data = file.get_var()
		file.close()
		
		if data is LevelProgress:
			progress = data
	
	return progress

func save_progress() -> void:
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	file.store_var(self)
	file.close()

func unlock_next_level(current_level: int) -> void:
	if current_level < unlocked_levels.size() - 1:
		unlocked_levels[current_level + 1] = true
		save_progress()

func set_level_stars(level: int, stars: int) -> void:
	if level < level_stars.size():
		level_stars[level] = stars
		save_progress()

func is_level_unlocked(level: int) -> bool:
	if level < unlocked_levels.size():
		return unlocked_levels[level]
	return false

func get_level_stars(level: int) -> int:
	if level < level_stars.size():
		return level_stars[level]
	return 0 