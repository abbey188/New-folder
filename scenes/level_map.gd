extends Node2D

@onready var level_manager = $LevelManager
@onready var level_buttons = $LevelButtons

func _ready() -> void:
    # Connect level manager signals
    level_manager.level_completed.connect(_on_level_completed)
    
    # Update button states based on unlocked levels
    _update_level_buttons()

func _update_level_buttons() -> void:
    var unlocked_levels = level_manager.get_unlocked_levels()
    for i in range(1, 4):  # Assuming we have 3 levels
        var button = level_buttons.get_node("Level%d" % i)
        if button:
            button.disabled = i not in unlocked_levels
            # Update visual state (you might want to add a locked icon or change colors)

func _on_level_button_pressed(level_id: int) -> void:
    if level_manager.load_level(level_id):
        # Transition to game scene
        get_tree().change_scene_to_file("res://scenes/game_grid.tscn")
    else:
        print("Failed to load level %d" % level_id)

func _on_level_completed(level_id: int, stars: int, score: int) -> void:
    _update_level_buttons() 