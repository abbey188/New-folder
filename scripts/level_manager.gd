extends Node

signal level_loaded(level_data)
signal level_completed(level_id, stars, score)

var current_level_id: int = 1
var current_level_data: Dictionary = {}
var unlocked_levels: Array = [1]

func _ready() -> void:
    # Initialize level manager
    pass

func load_level(level_id: int) -> bool:
    if level_id not in unlocked_levels:
        return false
        
    var file = FileAccess.open("res://levels/level_%d.json" % level_id, FileAccess.READ)
    if not file:
        print("Error: Could not open level file for level %d" % level_id)
        return false
        
    var json_string = file.get_as_text()
    file.close()
    
    var json = JSON.new()
    var parse_result = json.parse(json_string)
    
    if parse_result != OK:
        print("Error: Could not parse level JSON for level %d" % level_id)
        return false
        
    current_level_data = json.get_data()
    current_level_id = level_id
    emit_signal("level_loaded", current_level_data)
    return true

func complete_level(stars: int, score: int) -> void:
    emit_signal("level_completed", current_level_id, stars, score)
    
    # Unlock next level if it exists
    if current_level_data.has("next_level_id"):
        var next_level = current_level_data["next_level_id"]
        if next_level not in unlocked_levels:
            unlocked_levels.append(next_level)

func is_level_unlocked(level_id: int) -> bool:
    return level_id in unlocked_levels

func get_current_level_data() -> Dictionary:
    return current_level_data

func get_unlocked_levels() -> Array:
    return unlocked_levels 