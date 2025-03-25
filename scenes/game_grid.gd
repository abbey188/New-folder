extends Node2D

@onready var level_manager = $LevelManager
@onready var grid_container = $GridContainer
@onready var moves_label = $UI/MovesLabel
@onready var score_label = $UI/ScoreLabel
@onready var objective_label = $UI/ObjectiveLabel

var level_data: Dictionary = {}
var current_moves: int = 0
var current_score: int = 0
var selected_dots: Array = []
var is_processing: bool = false

func _ready() -> void:
    # Get level data from manager
    level_data = level_manager.get_current_level_data()
    
    # Initialize game state
    current_moves = level_data["move_limit"]
    _update_ui()
    
    # Create grid based on level data
    _create_grid()
    
    # Connect signals
    level_manager.level_loaded.connect(_on_level_loaded)

func _create_grid() -> void:
    var grid_size = level_data["grid_size"]
    var colors = level_data["available_colors"]
    
    # Clear existing grid
    for child in grid_container.get_children():
        child.queue_free()
    
    # Create new grid
    for row in range(grid_size["rows"]):
        for col in range(grid_size["columns"]):
            var dot = preload("res://scenes/dot.tscn").instantiate()
            grid_container.add_child(dot)
            dot.position = Vector2(col * 132, row * 132)  # 85 + 47 spacing
            dot.color = colors[randi() % colors.size()]
            dot.grid_position = Vector2(col, row)
            dot.selected.connect(_on_dot_selected.bind(dot))

func _update_ui() -> void:
    moves_label.text = "Moves: %d" % current_moves
    score_label.text = "Score: %d" % current_score
    
    var objective = level_data["objectives"][0]
    objective_label.text = "Clear %d %s dots" % [objective["amount"], objective["target_color"]]

func _on_dot_selected(dot: Node2D) -> void:
    if is_processing:
        return
        
    if dot in selected_dots:
        selected_dots.erase(dot)
        dot.deselect()
    else:
        selected_dots.append(dot)
        dot.select()
    
    if selected_dots.size() >= 3:
        _process_selection()

func _process_selection() -> void:
    is_processing = true
    
    # Check if dots form a valid connection
    if _is_valid_connection():
        # Clear dots and update score
        current_moves -= 1
        current_score += selected_dots.size()
        
        # Animate dot clearing
        for dot in selected_dots:
            dot.clear()
        
        # Check level completion
        if current_moves <= 0 or _check_objective_completion():
            _end_level()
    else:
        # Deselect all dots
        for dot in selected_dots:
            dot.deselect()
    
    selected_dots.clear()
    _update_ui()
    is_processing = false

func _is_valid_connection() -> bool:
    # Check if all dots are the same color
    var first_color = selected_dots[0].color
    for dot in selected_dots:
        if dot.color != first_color:
            return false
    
    # Check if dots are adjacent
    for i in range(selected_dots.size() - 1):
        var pos1 = selected_dots[i].grid_position
        var pos2 = selected_dots[i + 1].grid_position
        if not _are_positions_adjacent(pos1, pos2):
            return false
    
    return true

func _are_positions_adjacent(pos1: Vector2, pos2: Vector2) -> bool:
    var diff = pos2 - pos1
    return abs(diff.x) <= 1 and abs(diff.y) <= 1

func _check_objective_completion() -> bool:
    var objective = level_data["objectives"][0]
    var target_color = objective["target_color"]
    var target_amount = objective["amount"]
    
    # Count cleared dots of target color
    var cleared_count = 0
    for dot in grid_container.get_children():
        if dot.color == target_color and dot.is_cleared:
            cleared_count += 1
    
    return cleared_count >= target_amount

func _end_level() -> void:
    var stars = 1
    if current_moves >= level_data["score_targets"]["three_stars"]:
        stars = 3
    elif current_moves >= level_data["score_targets"]["two_stars"]:
        stars = 2
    
    level_manager.complete_level(stars, current_score)
    # Show level completion popup
    $LevelCompletePopup.show_completion(stars, current_score)

func _on_level_loaded(new_level_data: Dictionary) -> void:
    level_data = new_level_data
    _create_grid()
    current_moves = level_data["move_limit"]
    current_score = 0
    _update_ui() 