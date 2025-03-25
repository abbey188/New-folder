extends Node

@onready var achievement_manager: AchievementManager = $AchievementManager

func _ready():
	# Test achievement popup after a short delay
	await get_tree().create_timer(1.0).timeout
	test_achievement_popup()

func test_achievement_popup():
	# Test unlocking an achievement
	var achievement = achievement_manager.get_achievement("first_victory")
	if achievement and not achievement.is_unlocked:
		achievement_manager.unlock_achievement("first_victory")
		
		# Wait for popup to finish
		await get_tree().create_timer(4.0).timeout
		
		# Test another achievement
		achievement = achievement_manager.get_achievement("perfect_level")
		if achievement and not achievement.is_unlocked:
			achievement_manager.unlock_achievement("perfect_level") 