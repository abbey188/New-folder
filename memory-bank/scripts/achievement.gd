extends Resource
class_name Achievement

@export var id: String
@export var title: String
@export var description: String
@export var icon_path: String
@export var is_unlocked: bool = false
@export var unlock_date: String = ""
@export var max_progress: int = 0  # 0 means no progress tracking
@export var current_progress: int = 0
@export var progress_type: String = ""  # e.g., "dots_cleared", "time", "stars"

func _init(p_id: String = "", p_title: String = "", p_description: String = "", p_icon_path: String = "", p_max_progress: int = 0, p_progress_type: String = ""):
	id = p_id
	title = p_title
	description = p_description
	icon_path = p_icon_path
	is_unlocked = false
	unlock_date = ""
	max_progress = p_max_progress
	current_progress = 0
	progress_type = p_progress_type

func unlock():
	if not is_unlocked:
		is_unlocked = true
		unlock_date = Time.get_datetime_string_from_system()

func update_progress(amount: int) -> bool:
	if max_progress <= 0:
		return false
		
	current_progress = min(current_progress + amount, max_progress)
	
	# Auto-unlock if progress reaches max
	if current_progress >= max_progress and not is_unlocked:
		unlock()
		return true
	return false

func get_progress_percentage() -> float:
	if max_progress <= 0:
		return 0.0
	return float(current_progress) / float(max_progress) 