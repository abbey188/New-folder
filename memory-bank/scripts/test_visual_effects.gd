extends Node

# Test scene references
var test_scene: Node2D
var visual_effects: Node
var test_dot: Sprite2D

func _ready():
	# Create test scene
	test_scene = Node2D.new()
	add_child(test_scene)
	
	# Create visual effects node
	visual_effects = load("res://scripts/visual_effects.gd").new()
	test_scene.add_child(visual_effects)
	
	# Create test dot
	test_dot = Sprite2D.new()
	test_dot.texture = preload("res://assets/dot.png")
	test_dot.position = Vector2(100, 100)
	test_dot.modulate = Color(1, 0, 0, 0.8)  # Red dot with 80% opacity
	test_scene.add_child(test_dot)
	
	# Run tests
	run_tests()

func run_tests():
	print("Starting Visual Effects Tests...")
	
	# Test dot selection animation
	print("\nTesting dot selection animation...")
	visual_effects.animate_dot_selection(test_dot, true)
	await get_tree().create_timer(0.2).timeout
	visual_effects.animate_dot_selection(test_dot, false)
	await get_tree().create_timer(0.2).timeout
	
	# Test dot clear effect
	print("\nTesting dot clear effect...")
	var particles = visual_effects.create_dot_clear_effect(test_dot)
	test_scene.add_child(particles)
	visual_effects.animate_dot_clear(test_dot)
	await get_tree().create_timer(0.3).timeout
	
	# Test level complete effect
	print("\nTesting level complete effect...")
	var level_particles = visual_effects.create_level_complete_effect(test_scene)
	test_scene.add_child(level_particles)
	await get_tree().create_timer(1.1).timeout
	
	print("\nAll visual effects tests completed!")
	queue_free() 