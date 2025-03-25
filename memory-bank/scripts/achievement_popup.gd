extends Control

@onready var icon: TextureRect = $PanelContainer/VBoxContainer/HBoxContainer/Icon
@onready var title: Label = $PanelContainer/VBoxContainer/HBoxContainer/VBoxContainer/Title
@onready var description: Label = $PanelContainer/VBoxContainer/HBoxContainer/VBoxContainer/Description
@onready var panel: PanelContainer = $PanelContainer
@onready var animation_player: AnimationPlayer = $AnimationPlayer

const POPUP_DURATION: float = 3.0
const SLIDE_DURATION: float = 0.5

func _ready():
	# Start hidden
	modulate.a = 0
	position.x = -size.x

func show_achievement(achievement: Achievement):
	# Set achievement data
	icon.texture = load(achievement.icon_path)
	title.text = achievement.title
	description.text = achievement.description
	
	# Play show animation
	animation_player.play("show_popup")
	
	# Play achievement sound
	AudioManager.play_sfx("achievement_unlock")
	
	# Hide after duration
	await get_tree().create_timer(POPUP_DURATION).timeout
	animation_player.play("hide_popup") 