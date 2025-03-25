extends Control

@onready var grid_container = $ScrollContainer/GridContainer
@onready var achievement_template = $ScrollContainer/GridContainer/AchievementTemplate

var achievement_manager: AchievementManager

func _ready():
	achievement_manager = get_node("/root/AchievementManager")
	achievement_template.hide()
	populate_gallery()

func populate_gallery():
	# Clear existing items except template
	for child in grid_container.get_children():
		if child != achievement_template:
			child.queue_free()
	
	# Get all achievements
	var achievements = achievement_manager.get_all_achievements()
	
	# Create achievement cards
	for achievement in achievements:
		var card = achievement_template.duplicate()
		card.show()
		
		# Set achievement data
		card.get_node("Icon").texture = load(achievement.icon_path)
		card.get_node("Title").text = achievement.title
		card.get_node("Description").text = achievement.description
		
		# Set locked/unlocked state
		var lock_icon = card.get_node("LockIcon")
		lock_icon.visible = not achievement.is_unlocked
		
		# Set unlock date if available
		var date_label = card.get_node("UnlockDate")
		if achievement.is_unlocked and achievement.unlock_date != "":
			date_label.text = "Unlocked: " + achievement.unlock_date
		else:
			date_label.text = "Locked"
		
		grid_container.add_child(card) 