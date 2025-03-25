extends Control

@onready var grid_container = $ScrollContainer/GridContainer
@onready var achievement_template = $ScrollContainer/GridContainer/AchievementTemplate
@onready var category_container = $CategoryContainer
@onready var category_template = $CategoryContainer/CategoryTemplate

var achievement_manager: AchievementManager
var save_manager: SaveManager
var current_category: String = "all"

func _ready():
	achievement_manager = get_node("/root/AchievementManager")
	save_manager = get_node("/root/SaveManager")
	achievement_template.hide()
	category_template.hide()
	
	# Set up categories
	setup_categories()
	
	# Populate gallery
	populate_gallery()
	
	# Connect to progress updates
	achievement_manager.achievement_progress_updated.connect(_on_achievement_progress_updated)

func setup_categories():
	# Add "All" category
	var all_category = category_template.duplicate()
	all_category.show()
	all_category.get_node("Icon").texture = preload("res://assets/icons/all_icon.png")
	all_category.get_node("Title").text = "All Achievements"
	all_category.get_node("Description").text = "View all achievements"
	all_category.pressed.connect(_on_category_selected.bind("all"))
	
	# Add other categories
	var categories = save_manager.save_data.achievement_categories
	for category_id in categories:
		var category_data = categories[category_id]
		var category_button = category_template.duplicate()
		category_button.show()
		category_button.get_node("Icon").texture = load(category_data.icon)
		category_button.get_node("Title").text = category_data.name
		category_button.get_node("Description").text = category_data.description
		category_button.pressed.connect(_on_category_selected.bind(category_id))

func _on_category_selected(category: String):
	current_category = category
	populate_gallery()
	
	# Update category button states
	for child in category_container.get_children():
		if child != category_template:
			child.modulate = Color(1, 1, 1, 1) if child.get_meta("category") == category else Color(0.5, 0.5, 0.5, 1)

func populate_gallery():
	# Clear existing items except template
	for child in grid_container.get_children():
		if child != achievement_template:
			child.queue_free()
	
	# Get all achievements
	var achievements = achievement_manager.get_all_achievements()
	
	# Filter by category if needed
	if current_category != "all":
		achievements = achievements.filter(func(achievement): return achievement.category == current_category)
	
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
			date_label.text = ""
		
		# Set progress if applicable
		var progress_bar = card.get_node("ProgressBar")
		var progress_label = card.get_node("ProgressLabel")
		if achievement.max_progress > 0:
			progress_bar.show()
			progress_label.show()
			progress_bar.max_value = achievement.max_progress
			progress_bar.value = achievement.current_progress
			progress_label.text = "%d/%d" % [achievement.current_progress, achievement.max_progress]
		else:
			progress_bar.hide()
			progress_label.hide()

func _on_achievement_progress_updated(achievement_id: String):
	populate_gallery() 