extends Control

@onready var icon: TextureRect = $PanelContainer/VBoxContainer/HBoxContainer/Icon
@onready var title: Label = $PanelContainer/VBoxContainer/HBoxContainer/VBoxContainer/Title
@onready var description: Label = $PanelContainer/VBoxContainer/HBoxContainer/VBoxContainer/Description
@onready var progress_bar: ProgressBar = $PanelContainer/VBoxContainer/HBoxContainer/VBoxContainer/ProgressBar
@onready var progress_label: Label = $PanelContainer/VBoxContainer/HBoxContainer/VBoxContainer/ProgressLabel
@onready var panel: PanelContainer = $PanelContainer
@onready var animation_player: AnimationPlayer = $AnimationPlayer

const POPUP_DURATION: float = 3.0
const SLIDE_DURATION: float = 0.5

func _ready():
	# Start hidden
	modulate.a = 0
	position.x = -size.x
	
	# Hide progress elements by default
	progress_bar.hide()
	progress_label.hide()

func show_achievement(achievement: Achievement):
	# Set achievement data
	icon.texture = load(achievement.icon_path)
	title.text = achievement.title
	description.text = achievement.description
	
	# Show progress if applicable
	if achievement.max_progress > 0:
		progress_bar.show()
		progress_label.show()
		progress_bar.value = achievement.get_progress_percentage() * 100
		progress_label.text = "%d/%d" % [achievement.current_progress, achievement.max_progress]
	else:
		progress_bar.hide()
		progress_label.hide()
	
	# Play show animation
	animation_player.play("show_popup")
	
	# Play achievement sound
	AudioManager.play_sfx("achievement_unlock")
	
	# Hide after duration
	await get_tree().create_timer(POPUP_DURATION).timeout
	animation_player.play("hide_popup") 