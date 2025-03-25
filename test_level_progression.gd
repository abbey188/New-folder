extends Node

func _ready() -> void:
	print("Starting Level Progression Tests...")
	run_tests()

func run_tests() -> void:
	# Test 1: Initial Progress State
	print("\nTest 1: Initial Progress State")
	var progress = LevelProgress.new()
	assert(progress.unlocked_levels[0] == true, "Level 1 should be unlocked by default")
	assert(progress.unlocked_levels[1] == false, "Level 2 should be locked by default")
	assert(progress.unlocked_levels[2] == false, "Level 3 should be locked by default")
	print("✓ Initial progress state verified")

	# Test 2: Level Unlocking
	print("\nTest 2: Level Unlocking")
	progress.unlock_next_level(0)
	assert(progress.unlocked_levels[1] == true, "Level 2 should be unlocked after completing Level 1")
	assert(progress.unlocked_levels[2] == false, "Level 3 should remain locked")
	print("✓ Level unlocking verified")

	# Test 3: Star Rating System
	print("\nTest 3: Star Rating System")
	progress.set_level_stars(0, 3)
	assert(progress.get_level_stars(0) == 3, "Level 1 should have 3 stars")
	assert(progress.get_level_stars(1) == 0, "Level 2 should have 0 stars")
	print("✓ Star rating system verified")

	# Test 4: Save and Load
	print("\nTest 4: Save and Load")
	progress.save_progress()
	var loaded_progress = LevelProgress.load_progress()
	assert(loaded_progress.unlocked_levels[1] == true, "Loaded progress should have Level 2 unlocked")
	assert(loaded_progress.get_level_stars(0) == 3, "Loaded progress should have correct star count")
	print("✓ Save and load functionality verified")

	# Test 5: Level Map Button States
	print("\nTest 5: Level Map Button States")
	var level_map = preload("res://scenes/level_map.tscn").instantiate()
	add_child(level_map)
	
	# Wait for _ready to complete
	await get_tree().process_frame
	
	var buttons = level_map.level_buttons
	assert(buttons[0].disabled == false, "Level 1 button should be enabled")
	assert(buttons[1].disabled == false, "Level 2 button should be enabled")
	assert(buttons[2].disabled == true, "Level 3 button should be disabled")
	print("✓ Level map button states verified")

	# Test 6: Level Completion Signal
	print("\nTest 6: Level Completion Signal")
	var game_grid = preload("res://scenes/game_grid.tscn").instantiate()
	add_child(game_grid)
	
	# Connect to signal
	var signal_received = false
	game_grid.level_completed.connect(func(level, stars): signal_received = true)
	
	# Trigger level completion
	game_grid.on_level_complete(3)
	assert(signal_received, "Level completion signal should be emitted")
	print("✓ Level completion signal verified")

	print("\nAll tests completed successfully!")
	queue_free() 
