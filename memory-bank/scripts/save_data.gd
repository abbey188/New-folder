extends Resource
class_name SaveData

@export var unlocked_levels: Array[int] = [1]
@export var level_stars: Dictionary = {}
@export var settings: Dictionary = {
	"music_volume": 1.0,
	"sfx_volume": 1.0,
	"music_enabled": true,
	"sfx_enabled": true
} 