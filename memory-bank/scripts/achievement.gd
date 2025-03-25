extends Resource
class_name Achievement

@export var id: String
@export var title: String
@export var description: String
@export var icon_path: String
@export var is_unlocked: bool = false
@export var unlock_date: String = ""

func _init(p_id: String = "", p_title: String = "", p_description: String = "", p_icon_path: String = ""):
	id = p_id
	title = p_title
	description = p_description
	icon_path = p_icon_path
	is_unlocked = false
	unlock_date = ""

func unlock():
	if not is_unlocked:
		is_unlocked = true
		unlock_date = Time.get_datetime_string_from_system() 