extends Node

# Singleton for monitoring performance metrics
class_name PerformanceMonitor

# Performance metrics
var fps_history: Array[float] = []
var draw_calls_history: Array[int] = []
var memory_history: Array[int] = []
const HISTORY_SIZE = 60  # Store last 60 frames

# UI elements
var fps_label: Label
var draw_calls_label: Label
var memory_label: Label
var stats_container: Control

# Initialize the performance monitor
func _ready() -> void:
	create_ui()
	# Set process mode to always to ensure monitoring even when game is paused
	process_mode = Node.PROCESS_MODE_ALWAYS

# Create the performance monitoring UI
func create_ui() -> void:
	stats_container = Control.new()
	stats_container.name = "PerformanceStats"
	stats_container.set_anchors_preset(Control.PRESET_TOP_LEFT)
	stats_container.position = Vector2(10, 10)
	add_child(stats_container)
	
	fps_label = Label.new()
	fps_label.name = "FPSLabel"
	fps_label.position = Vector2(0, 0)
	stats_container.add_child(fps_label)
	
	draw_calls_label = Label.new()
	draw_calls_label.name = "DrawCallsLabel"
	draw_calls_label.position = Vector2(0, 20)
	stats_container.add_child(draw_calls_label)
	
	memory_label = Label.new()
	memory_label.name = "MemoryLabel"
	memory_label.position = Vector2(0, 40)
	stats_container.add_child(memory_label)
	
	# Set initial visibility to false (toggle with F3)
	stats_container.visible = false

# Update performance metrics every frame
func _process(_delta: float) -> void:
	# Update FPS
	var current_fps = Engine.get_frames_per_second()
	fps_history.append(current_fps)
	if fps_history.size() > HISTORY_SIZE:
		fps_history.pop_front()
	
	# Update draw calls
	var current_draw_calls = RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_DRAW_CALLS_IN_FRAME)
	draw_calls_history.append(current_draw_calls)
	if draw_calls_history.size() > HISTORY_SIZE:
		draw_calls_history.pop_front()
	
	# Update memory usage
	var current_memory = OS.get_static_memory_usage()
	memory_history.append(current_memory)
	if memory_history.size() > HISTORY_SIZE:
		memory_history.pop_front()
	
	# Update UI if visible
	if stats_container.visible:
		update_ui()

# Update the performance monitoring UI
func update_ui() -> void:
	# Calculate average FPS
	var avg_fps = 0.0
	for fps in fps_history:
		avg_fps += fps
	avg_fps /= fps_history.size()
	
	# Calculate average draw calls
	var avg_draw_calls = 0
	for calls in draw_calls_history:
		avg_draw_calls += calls
	avg_draw_calls /= draw_calls_history.size()
	
	# Get current memory usage
	var current_memory = memory_history.back()
	
	# Update labels
	fps_label.text = "FPS: %.1f" % avg_fps
	draw_calls_label.text = "Draw Calls: %d" % avg_draw_calls
	memory_label.text = "Memory: %.1f MB" % (current_memory / 1024.0 / 1024.0)

# Toggle performance stats visibility
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_f3"):  # F3 key
		stats_container.visible = !stats_container.visible

# Get performance statistics
func get_stats() -> Dictionary:
	return {
		"fps": {
			"current": fps_history.back() if fps_history.size() > 0 else 0.0,
			"average": calculate_average(fps_history),
			"min": fps_history.min() if fps_history.size() > 0 else 0.0,
			"max": fps_history.max() if fps_history.size() > 0 else 0.0
		},
		"draw_calls": {
			"current": draw_calls_history.back() if draw_calls_history.size() > 0 else 0,
			"average": calculate_average(draw_calls_history),
			"min": draw_calls_history.min() if draw_calls_history.size() > 0 else 0,
			"max": draw_calls_history.max() if draw_calls_history.size() > 0 else 0
		},
		"memory": {
			"current": memory_history.back() if memory_history.size() > 0 else 0,
			"average": calculate_average(memory_history),
			"min": memory_history.min() if memory_history.size() > 0 else 0,
			"max": memory_history.max() if memory_history.size() > 0 else 0
		}
	}

# Calculate average of an array of numbers
func calculate_average(array: Array) -> float:
	if array.is_empty():
		return 0.0
	var sum = 0.0
	for value in array:
		sum += value
	return sum / array.size()

# Log performance data to file
func log_performance_data() -> void:
	var stats = get_stats()
	var log_file = FileAccess.open("user://performance_log.txt", FileAccess.WRITE)
	if log_file:
		log_file.store_string(JSON.stringify(stats, "\t"))
		log_file.close() 