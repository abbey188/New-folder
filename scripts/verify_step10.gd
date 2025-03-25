extends Node

# Test results
var test_results = {
	"three_stars_test": false,
	"two_stars_test": false,
	"one_star_test": false,
	"animation_test": false
}

# Test configuration
const TEST_MOVES_THREE_STARS = 6
const TEST_MOVES_TWO_STARS = 3
const TEST_MOVES_ONE_STAR = 0

@onready var game_grid = get_node("/root/Main/GameGrid")
@onready var game_ui = get_node("/root/Main/GameUI")
@onready var level_completion_popup = get_node("/root/Main/GameUI/LevelCompletionPopup")
@onready var star1 = get_node("/root/Main/GameUI/LevelCompletionPopup/VBoxContainer/StarsContainer/Star1")
@onready var star2 = get_node("/root/Main/GameUI/LevelCompletionPopup/VBoxContainer/StarsContainer/Star2")
@onready var star3 = get_node("/root/Main/GameUI/LevelCompletionPopup/VBoxContainer/StarsContainer/Star3")

func _ready():
	print("Starting Star Rating System Verification")
	await get_tree().create_timer(0.5).timeout
	
	# Run tests
	await test_star_rating_three_stars()
	await test_star_rating_two_stars()
	await test_star_rating_one_star()
	await test_star_animation()
	
	# Print test results
	print_test_summary()

func test_star_rating_three_stars():
	print("Testing three stars rating...")
	setup_test(TEST_MOVES_THREE_STARS)
	
	await get_tree().create_timer(1.0).timeout
	test_results["three_stars_test"] = star1.visible && star2.visible && star3.visible
	
	if test_results["three_stars_test"]:
		print("✓ Three stars test passed - All stars visible")
	else:
		print("✗ Three stars test failed - Expected all stars visible")
	
	cleanup_test()
	await get_tree().create_timer(0.5).timeout

func test_star_rating_two_stars():
	print("Testing two stars rating...")
	setup_test(TEST_MOVES_TWO_STARS)
	
	await get_tree().create_timer(1.0).timeout
	test_results["two_stars_test"] = star1.visible && star2.visible && !star3.visible
	
	if test_results["two_stars_test"]:
		print("✓ Two stars test passed - Stars 1 and 2 visible, Star 3 hidden")
	else:
		print("✗ Two stars test failed - Expected only stars 1 and 2 visible")
	
	cleanup_test()
	await get_tree().create_timer(0.5).timeout

func test_star_rating_one_star():
	print("Testing one star rating...")
	setup_test(TEST_MOVES_ONE_STAR)
	
	await get_tree().create_timer(1.0).timeout
	test_results["one_star_test"] = star1.visible && !star2.visible && !star3.visible
	
	if test_results["one_star_test"]:
		print("✓ One star test passed - Only Star 1 visible")
	else:
		print("✗ One star test failed - Expected only Star 1 visible")
	
	cleanup_test()
	await get_tree().create_timer(0.5).timeout

func test_star_animation():
	print("Testing star animations...")
	# Reset stars
	level_completion_popup.visible = false
	level_completion_popup._reset_stars()
	
	# Test with 6 moves (3 stars) to check animations
	setup_test(TEST_MOVES_THREE_STARS)
	
	# Check that stars start with scale 0 and animate to scale 1
	var initial_scales = []
	if star1.visible: initial_scales.append(star1.scale.x < 0.5)
	if star2.visible: initial_scales.append(star2.scale.x < 0.5)
	if star3.visible: initial_scales.append(star3.scale.x < 0.5)
	
	# Wait for animation
	await get_tree().create_timer(1.5).timeout
	
	# Check final scales
	var final_scales = []
	if star1.visible: final_scales.append(is_approximately(star1.scale.x, 1.0))
	if star2.visible: final_scales.append(is_approximately(star2.scale.x, 1.0))
	if star3.visible: final_scales.append(is_approximately(star3.scale.x, 1.0))
	
	# All stars should have animated properly
	test_results["animation_test"] = !initial_scales.has(false) && !final_scales.has(false)
	
	if test_results["animation_test"]:
		print("✓ Star animation test passed - Stars animate from scale 0 to 1")
	else:
		print("✗ Star animation test failed - Stars did not animate correctly")
	
	cleanup_test()

func setup_test(moves_left):
	# Configure game UI for test
	game_ui.moves_left = moves_left
	game_ui.update_moves_display()
	
	# Set objective to completed
	game_ui.objective_count = 10
	game_ui.current_progress = 10
	
	# Show completion screen
	game_ui.level_complete = true
	game_ui._show_level_complete()

func cleanup_test():
	# Hide popup and reset UI
	level_completion_popup.visible = false
	game_ui.reset_game()

func print_test_summary():
	print("\n--- STEP 10 VERIFICATION RESULTS ---")
	
	var all_passed = true
	for test in test_results.keys():
		if !test_results[test]:
			all_passed = false
	
	if all_passed:
		print("✓ All Star Rating System tests PASSED!")
	else:
		print("✗ Some Star Rating System tests FAILED!")
	
	print("  Three Stars Test: ", "PASS" if test_results["three_stars_test"] else "FAIL")
	print("  Two Stars Test: ", "PASS" if test_results["two_stars_test"] else "FAIL")
	print("  One Star Test: ", "PASS" if test_results["one_star_test"] else "FAIL")
	print("  Animation Test: ", "PASS" if test_results["animation_test"] else "FAIL")

func is_approximately(value, target, epsilon = 0.1):
	return abs(value - target) < epsilon 