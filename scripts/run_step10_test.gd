extends Node

# This script is used to test the star rating system
# It simulates level completion with different numbers of remaining moves
# to verify stars are awarded correctly

@onready var game_grid = $GameGrid
@onready var game_ui = $GameUI

func _ready():
	# Wait a moment to let the scene initialize
	await get_tree().create_timer(0.5).timeout
	
	print("Running Step 10 Test: Star Rating System")
	
	# Test case 1: 6 moves left (3 stars)
	test_star_rating(6, 3)
	
	# Test case 2: 3 moves left (2 stars)
	test_star_rating(3, 2)
	
	# Test case 3: 0 moves left (1 star)
	test_star_rating(0, 1)
	
	print("Step 10 Tests Completed")

func test_star_rating(moves_left, expected_stars):
	# Set up the test
	game_ui.moves_left = moves_left
	game_ui.update_moves_display()
	
	# Set test objective to be already completed
	game_ui.objective_count = 10
	game_ui.current_progress = 10
	
	# Simulate level completion
	game_ui.level_complete = true
	game_ui._show_level_complete()
	
	# Wait a moment for animations
	await get_tree().create_timer(1.0).timeout
	
	# Reset for next test
	game_ui.reset_game()
	
	# Wait before next test
	await get_tree().create_timer(0.5).timeout 