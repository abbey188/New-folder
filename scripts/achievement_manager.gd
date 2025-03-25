extends Node

# Achievement data structure
var achievements = {
	"first_victory": {
		"id": "first_victory",
		"title": "First Victory",
		"description": "Complete your first level",
		"icon": "res://assets/icons/achievements/first_victory.png",
		"unlocked": false
	},
	"perfect_level": {
		"id": "perfect_level",
		"title": "Perfect Level",
		"description": "Complete a level with 3 stars",
		"icon": "res://assets/icons/achievements/perfect_level.png",
		"unlocked": false
	},
	"color_master": {
		"id": "color_master",
		"title": "Color Master",
		"description": "Clear 50 dots of the same color in one level",
		"icon": "res://assets/icons/achievements/color_master.png",
		"unlocked": false
	}
}

# Signal for achievement unlocked
signal achievement_unlocked(achievement_id: String)

# Singleton instance
var _instance = null

func _ready():
	# Load achievement data from save
	load_achievements()

func get_instance():
	if _instance == null:
		_instance = self
	return _instance

# Check and unlock an achievement
func check_achievement(achievement_id: String) -> bool:
	if achievement_id in achievements and not achievements[achievement_id]["unlocked"]:
		unlock_achievement(achievement_id)
		return true
	return false

# Unlock an achievement
func unlock_achievement(achievement_id: String) -> void:
	if achievement_id in achievements:
		achievements[achievement_id]["unlocked"] = true
		emit_signal("achievement_unlocked", achievement_id)
		save_achievements()

# Check if an achievement is unlocked
func is_achievement_unlocked(achievement_id: String) -> bool:
	return achievements.get(achievement_id, {}).get("unlocked", false)

# Get achievement data
func get_achievement(achievement_id: String) -> Dictionary:
	return achievements.get(achievement_id, {})

# Get all achievements
func get_all_achievements() -> Dictionary:
	return achievements

# Save achievement data
func save_achievements() -> void:
	var save_data = {}
	for id in achievements:
		save_data[id] = achievements[id]["unlocked"]
	
	var file = FileAccess.open("user://achievements.json", FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(save_data))
		file.close()

# Load achievement data
func load_achievements() -> void:
	if not FileAccess.file_exists("user://achievements.json"):
		return
		
	var file = FileAccess.open("user://achievements.json", FileAccess.READ)
	if file:
		var data = JSON.parse_string(file.get_as_text())
		file.close()
		
		if data:
			for id in data:
				if id in achievements:
					achievements[id]["unlocked"] = data[id] 