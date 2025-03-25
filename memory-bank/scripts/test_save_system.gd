extends Node

# Test results
var test_results = {
	"save_load": false,
	"level_unlocking": false,
	"star_ratings": false,
	"settings": false
}

func _ready():
	run_tests()

func run_tests():
	print("Starting Save System Tests...")
	
	# Test 1: Save and Load
	test_save_load()
	
	# Test 2: Level Unlocking
	test_level_unlocking()
	
	# Test 3: Star Ratings
	test_star_ratings()
	
	# Test 4: Settings
	test_settings()
	
	# Print results
	print("\nTest Results:")
	for test in test_results:
		print("%s: %s" % [test, "PASS" if test_results[test] else "FAIL"])
	
	# Clean up test save file
	cleanup_test_save()

func test_save_load():
	print("\nTesting Save and Load...")
	
	# Create test data
	var test_data = SaveData.new()
	test_data.unlocked_levels = [1, 2]
	test_data.level_stars = {1: 3, 2: 2}
	test_data.settings = {
		"music_volume": 0.8,
		"sfx_volume": 0.7,
		"music_enabled": true,
		"sfx_enabled": false
	}
	
	# Save test data
	var save_manager = SaveManager.get_instance()
	save_manager.save_data = test_data
	var save_success = save_manager.save_game()
	
	# Load test data
	var load_success = save_manager.load_save()
	
	# Verify loaded data matches test data
	var loaded_data = save_manager.save_data
	var data_matches = (
		loaded_data.unlocked_levels == test_data.unlocked_levels and
		loaded_data.level_stars == test_data.level_stars and
		loaded_data.settings == test_data.settings
	)
	
	test_results["save_load"] = save_success and load_success and data_matches
	print("Save and Load Test: %s" % ["PASS" if test_results["save_load"] else "FAIL"])

func test_level_unlocking():
	print("\nTesting Level Unlocking...")
	
	var save_manager = SaveManager.get_instance()
	
	# Test initial state
	var initial_state = save_manager.is_level_unlocked(1)
	
	# Test unlocking a level
	save_manager.unlock_level(2)
	var level2_unlocked = save_manager.is_level_unlocked(2)
	
	# Test unlocking an already unlocked level
	save_manager.unlock_level(1)
	var level1_still_unlocked = save_manager.is_level_unlocked(1)
	
	test_results["level_unlocking"] = initial_state and level2_unlocked and level1_still_unlocked
	print("Level Unlocking Test: %s" % ["PASS" if test_results["level_unlocking"] else "FAIL"])

func test_star_ratings():
	print("\nTesting Star Ratings...")
	
	var save_manager = SaveManager.get_instance()
	
	# Test setting and getting star ratings
	save_manager.set_level_stars(1, 3)
	var stars1 = save_manager.get_level_stars(1)
	
	save_manager.set_level_stars(2, 2)
	var stars2 = save_manager.get_level_stars(2)
	
	var non_existent_stars = save_manager.get_level_stars(999)
	
	test_results["star_ratings"] = (
		stars1 == 3 and
		stars2 == 2 and
		non_existent_stars == 0
	)
	print("Star Ratings Test: %s" % ["PASS" if test_results["star_ratings"] else "FAIL"])

func test_settings():
	print("\nTesting Settings...")
	
	var save_manager = SaveManager.get_instance()
	
	# Test initial settings
	var initial_settings = save_manager.get_settings()
	
	# Test updating settings
	var new_settings = {
		"music_volume": 0.5,
		"sfx_volume": 0.6,
		"music_enabled": false,
		"sfx_enabled": true
	}
	save_manager.update_settings(new_settings)
	
	var updated_settings = save_manager.get_settings()
	
	test_results["settings"] = (
		initial_settings != null and
		updated_settings == new_settings
	)
	print("Settings Test: %s" % ["PASS" if test_results["settings"] else "FAIL"])

func cleanup_test_save():
	# Remove test save file
	var dir = DirAccess.open("user://")
	if dir:
		dir.remove("dot_save.res") 