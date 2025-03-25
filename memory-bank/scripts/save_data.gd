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
@export var achievement_categories: Dictionary = {
	"level": {
		"name": "Level Achievements",
		"description": "Complete levels and earn stars",
		"icon": "res://assets/icons/level_icon.png"
	},
	"skill": {
		"name": "Skill Achievements",
		"description": "Master game mechanics",
		"icon": "res://assets/icons/skill_icon.png"
	},
	"collection": {
		"name": "Collection Achievements",
		"description": "Gather special items and complete sets",
		"icon": "res://assets/icons/collection_icon.png"
	},
	"general": {
		"name": "General Achievements",
		"description": "Miscellaneous achievements",
		"icon": "res://assets/icons/general_icon.png"
	}
} 