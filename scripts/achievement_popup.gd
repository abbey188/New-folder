extends Control

@onready var icon = $Panel/VBoxContainer/Icon
@onready var title_label = $Panel/VBoxContainer/TitleLabel
@onready var description_label = $Panel/VBoxContainer/DescriptionLabel

var tween: Tween

func _ready():
	# Hide popup initially
	modulate.a = 0
	visible = false

func show_achievement(achievement_id: String) -> void:
	var achievement = AchievementManager.get_instance().get_achievement(achievement_id)
	if achievement.is_empty():
		return
	
	# Set achievement data
	icon.texture = load(achievement["icon"])
	title_label.text = achievement["title"]
	description_label.text = achievement["description"]
	
	# Show popup with animation
	visible = true
	if tween:
		tween.kill()
	
	tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 0.5).set_ease(Tween.EASE_OUT)
	tween.tween_interval(2.0)
	tween.tween_property(self, "modulate:a", 0.0, 0.5).set_ease(Tween.EASE_IN)
	tween.tween_callback(func(): visible = false) 