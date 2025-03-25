extends Node

signal achievement_unlocked(achievement: Achievement)

var achievements: Array[Achievement] = []
var save_path: String = "user://achievements.tres"

func _ready():
	load_achievements()

func load_achievements():
	if FileAccess.file_exists(save_path):
		var save_file = FileAccess.open(save_path, FileAccess.READ)
		var json_data = JSON.parse_string(save_file.get_as_text())
		save_file.close()
		
		if json_data:
			for achievement_data in json_data:
				var achievement = Achievement.new(
					achievement_data.id,
					achievement_data.title,
					achievement_data.description,
					achievement_data.icon_path
				)
				achievement.is_unlocked = achievement_data.is_unlocked
				achievement.unlock_date = achievement_data.unlock_date
				achievements.append(achievement)
	else:
		# Initialize default achievements
		achievements = [
			Achievement.new("first_victory", "First Victory", "Complete your first level", "res://assets/achievements/first_victory.png"),
			Achievement.new("perfect_level", "Perfect Level", "Complete a level with 3 stars", "res://assets/achievements/perfect_level.png"),
			Achievement.new("color_master", "Color Master", "Clear 50 dots of the same color", "res://assets/achievements/color_master.png"),
			Achievement.new("chain_reaction", "Chain Reaction", "Connect 10 or more dots at once", "res://assets/achievements/chain_reaction.png"),
			Achievement.new("speed_demon", "Speed Demon", "Complete a level in under 30 seconds", "res://assets/achievements/speed_demon.png")
		]
		save_achievements()

func save_achievements():
	var save_data = []
	for achievement in achievements:
		save_data.append({
			"id": achievement.id,
			"title": achievement.title,
			"description": achievement.description,
			"icon_path": achievement.icon_path,
			"is_unlocked": achievement.is_unlocked,
			"unlock_date": achievement.unlock_date
		})
	
	var save_file = FileAccess.open(save_path, FileAccess.WRITE)
	save_file.store_string(JSON.stringify(save_data))
	save_file.close()

func unlock_achievement(achievement_id: String):
	for achievement in achievements:
		if achievement.id == achievement_id and not achievement.is_unlocked:
			achievement.unlock()
			achievement_unlocked.emit(achievement)
			save_achievements()
			return true
	return false

func get_achievement(achievement_id: String) -> Achievement:
	for achievement in achievements:
		if achievement.id == achievement_id:
			return achievement
	return null

func get_all_achievements() -> Array[Achievement]:
	return achievements

func get_unlocked_achievements() -> Array[Achievement]:
	var unlocked: Array[Achievement] = []
	for achievement in achievements:
		if achievement.is_unlocked:
			unlocked.append(achievement)
	return unlocked 