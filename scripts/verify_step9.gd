extends Node2D

# Reference to game grid and UI
var game_grid
var game_ui
var completion_popup

func _ready():
	print("=== STEP 9 VERIFICATION: Level Completion Logic ===")
	
	# Get references to game components
	game_grid = get_node("/root/Main/GameGrid")
	game_ui = get_node("/root/Main/GameUI")
	completion_popup = game_ui.get_node("LevelCompletionPopup")
	
	# Verify components exist
	print("GameGrid found: ", game_grid != null)
	print("GameUI found: ", game_ui != null)
	print("Completion Popup found: ", completion_popup != null)
	
	# Verify popup components
	if completion_popup:
		var title_label = completion_popup.get_node("VBoxContainer/TitleLabel")
		var score_label = completion_popup.get_node("VBoxContainer/ScoreContainer/ScoreValue")
		var stars = completion_popup.get_node("VBoxContainer/StarsContainer")
		var continue_button = completion_popup.get_node("VBoxContainer/ContinueButton")
		
		print("Popup Title Label found: ", title_label != null)
		print("Popup Score Label found: ", score_label != null)
		print("Stars Container found: ", stars != null)
		print("Continue Button found: ", continue_button != null)
		
		# Verify star nodes
		var star1 = stars.get_node("Star1")
		var star2 = stars.get_node("Star2") 
		var star3 = stars.get_node("Star3")
		
		print("Star1 found: ", star1 != null)
		print("Star2 found: ", star2 != null)
		print("Star3 found: ", star3 != null)
	
	# Test level completion and failure scenarios
	test_level_completion()

func test_level_completion():
	print("\n=== Testing Level Completion Logic ===")
	
	# First test: Level completion
	print("\n1. Testing Level Complete scenario:")
	game_ui.current_progress = game_ui.objective_count - 1  # One away from completing
	game_ui.moves_left = 5  # Should result in 3 stars
	
	# Simulate final dot clear to trigger completion
	game_ui.track_cleared_dots([null], [game_ui.objective_color])
	
	# Allow time for the completion to process
	await get_tree().create_timer(0.5).timeout
	
	# Check if popup is visible and shows correct information
	print("Level Complete popup visible: ", completion_popup.visible)
	if completion_popup.visible:
		print("Popup title: ", completion_popup.get_node("VBoxContainer/TitleLabel").text)
		print("Stars shown: ", count_visible_stars())
		print("Expected 3 stars (>=5 moves left)")
	
	# Hide popup and reset for next test
	completion_popup.visible = false
	game_ui.reset_game()
	game_grid.reset_game()
	
	# Second test: Level failure
	print("\n2. Testing Level Failed scenario:")
	game_ui.current_progress = game_ui.objective_count - 5  # Far from completing
	game_ui.moves_left = 1  # Only one move left
	
	# Simulate using the last move
	game_ui.use_move()
	
	# Allow time for the failure to process
	await get_tree().create_timer(0.5).timeout
	
	# Check if popup is visible and shows correct information
	print("Level Failed popup visible: ", completion_popup.visible)
	if completion_popup.visible:
		print("Popup title: ", completion_popup.get_node("VBoxContainer/TitleLabel").text)
		print("Stars shown: ", count_visible_stars())
		print("Expected 0 stars (level failed)")
	
	# Third test: Test with different move counts
	print("\n3. Testing different star ratings:")
	
	# Reset and test with 2 moves left (2 stars)
	completion_popup.visible = false
	game_ui.reset_game()
	game_grid.reset_game()
	
	game_ui.current_progress = game_ui.objective_count - 1
	game_ui.moves_left = 3  # Should result in 2 stars
	
	# Simulate final dot clear to trigger completion
	game_ui.track_cleared_dots([null], [game_ui.objective_color])
	
	# Allow time for the completion to process
	await get_tree().create_timer(0.5).timeout
	
	print("Level Complete with 3 moves left:")
	print("Stars shown: ", count_visible_stars())
	print("Expected 2 stars (1-4 moves left)")
	
	# Final reset
	completion_popup.visible = false
	game_ui.reset_game()
	game_grid.reset_game()
	
	print("\n=== STEP 9 VERIFICATION COMPLETE ===")

# Helper function to count visible stars
func count_visible_stars():
	var count = 0
	var stars = completion_popup.get_node("VBoxContainer/StarsContainer")
	
	if stars.get_node("Star1").visible:
		count += 1
	if stars.get_node("Star2").visible:
		count += 1
	if stars.get_node("Star3").visible:
		count += 1
	
	return count 