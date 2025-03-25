extends Node

signal achievement_unlocked(achievement: Achievement)
signal achievement_progress_updated(achievement: Achievement)

var achievements: Array[Achievement] = []
var save_path: String = "user://achievements.tres"
var popup_scene: PackedScene
var popup_instance: Control

func _ready():
	load_achievements()
	popup_scene = preload("res://scenes/achievement_popup.tscn")
	popup_instance = popup_scene.instantiate()
	add_child(popup_instance)

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
					achievement_data.icon_path,
					achievement_data.get("max_progress", 0),
					achievement_data.get("progress_type", "")
				)
				achievement.is_unlocked = achievement_data.is_unlocked
				achievement.unlock_date = achievement_data.unlock_date
				achievement.current_progress = achievement_data.get("current_progress", 0)
				achievements.append(achievement)
	else:
		# Initialize default achievements with progress tracking
		achievements = [
			Achievement.new("first_victory", "First Victory", "Complete your first level", "res://assets/achievements/first_victory.png"),
			Achievement.new("perfect_level", "Perfect Level", "Complete a level with 3 stars", "res://assets/achievements/perfect_level.png"),
			Achievement.new("color_master", "Color Master", "Clear 50 dots of the same color", "res://assets/achievements/color_master.png", 50, "dots_cleared"),
			Achievement.new("chain_reaction", "Chain Reaction", "Connect 10 or more dots at once", "res://assets/achievements/chain_reaction.png", 10, "chain_length"),
			Achievement.new("speed_demon", "Speed Demon", "Complete a level in under 30 seconds", "res://assets/achievements/speed_demon.png", 30, "time")
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
			"unlock_date": achievement.unlock_date,
			"max_progress": achievement.max_progress,
			"current_progress": achievement.current_progress,
			"progress_type": achievement.progress_type
		})
	
	var save_file = FileAccess.open(save_path, FileAccess.WRITE)
	save_file.store_string(JSON.stringify(save_data))
	save_file.close()

func update_achievement_progress(achievement_id: String, amount: int) -> bool:
	var achievement = get_achievement(achievement_id)
	if achievement and achievement.max_progress > 0:
		var was_unlocked = achievement.update_progress(amount)
		achievement_progress_updated.emit(achievement)
		if was_unlocked:
			achievement_unlocked.emit(achievement)
			save_achievements()
			show_achievement_popup(achievement)
		else:
			save_achievements()
		return true
	return false

func unlock_achievement(achievement_id: String):
	for achievement in achievements:
		if achievement.id == achievement_id and not achievement.is_unlocked:
			achievement.unlock()
			achievement_unlocked.emit(achievement)
			save_achievements()
			show_achievement_popup(achievement)
			return true
	return false

func show_achievement_popup(achievement: Achievement):
	if popup_instance:
		popup_instance.show_achievement(achievement)

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

func get_achievements_by_progress_type(progress_type: String) -> Array[Achievement]:
	var matching: Array[Achievement] = []
	for achievement in achievements:
		if achievement.progress_type == progress_type:
			matching.append(achievement)
	return matching 