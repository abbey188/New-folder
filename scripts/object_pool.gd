extends Node

# Singleton for managing object pools
class_name ObjectPool

# Pool configurations
const POOL_SIZES = {
	"connection_line": 20,
	"particle": 50,
	"ui_animation": 10
}

# Active pools
var pools: Dictionary = {}
var active_objects: Dictionary = {}

# Initialize the object pool
func _ready() -> void:
	create_pools()

# Create all object pools
func create_pools() -> void:
	# Create connection line pool
	var connection_line_scene = preload("res://scenes/connection_line.tscn")
	pools["connection_line"] = []
	for i in range(POOL_SIZES["connection_line"]):
		var line = connection_line_scene.instantiate()
		line.visible = false
		add_child(line)
		pools["connection_line"].append(line)
	
	# Create particle pool
	var particle_scene = preload("res://scenes/particle.tscn")
	pools["particle"] = []
	for i in range(POOL_SIZES["particle"]):
		var particle = particle_scene.instantiate()
		particle.visible = false
		add_child(particle)
		pools["particle"].append(particle)
	
	# Create UI animation pool
	var ui_animation_scene = preload("res://scenes/ui_animation.tscn")
	pools["ui_animation"] = []
	for i in range(POOL_SIZES["ui_animation"]):
		var animation = ui_animation_scene.instantiate()
		animation.visible = false
		add_child(animation)
		pools["ui_animation"].append(animation)

# Get an object from the pool
func get_object(pool_name: String) -> Node:
	if not pools.has(pool_name):
		push_error("Pool %s does not exist" % pool_name)
		return null
	
	var pool = pools[pool_name]
	if pool.is_empty():
		push_warning("Pool %s is empty" % pool_name)
		return null
	
	var obj = pool.pop_back()
	obj.visible = true
	active_objects[obj] = pool_name
	return obj

# Return an object to the pool
func return_object(obj: Node) -> void:
	if not active_objects.has(obj):
		push_error("Object not found in active objects")
		return
	
	var pool_name = active_objects[obj]
	obj.visible = false
	obj.position = Vector2.ZERO
	obj.rotation = 0
	obj.scale = Vector2.ONE
	
	# Reset any specific properties based on object type
	match pool_name:
		"connection_line":
			obj.clear_points()
		"particle":
			obj.reset()
		"ui_animation":
			obj.stop()
	
	pools[pool_name].append(obj)
	active_objects.erase(obj)

# Get pool statistics
func get_pool_stats() -> Dictionary:
	var stats = {}
	for pool_name in pools:
		stats[pool_name] = {
			"total": POOL_SIZES[pool_name],
			"available": pools[pool_name].size(),
			"in_use": POOL_SIZES[pool_name] - pools[pool_name].size()
		}
	return stats

# Clean up all pools
func _exit_tree() -> void:
	for pool in pools.values():
		for obj in pool:
			obj.queue_free()
	pools.clear()
	active_objects.clear() 