extends Node

var achievement_manager
var achievement_popup
var test_success = true
var failure_messages = []

func _ready():
	print("Starting verification tests for Step 19...")
	
	# Short delay to allow the scene to fully load
	await get_tree().create_timer(0.5).timeout
	
	# Get references to required nodes
	achievement_manager = AchievementManager.get_instance()
	achievement_popup = get_node_or_null("/root/Main/AchievementPopup")
	
	if !achievement_manager:
		print("ERROR: Could not find AchievementManager")
		test_success = false
		failure_messages.append("FAIL: Could not find AchievementManager")
		output_results()
		return
	
	if !achievement_popup:
		print("ERROR: Could not find AchievementPopup")
		test_success = false
		failure_messages.append("FAIL: Could not find AchievementPopup")
		output_results()
		return
	
	# Begin tests
	print("Found necessary nodes, beginning tests...")
	
	# Test 1: Check initial achievement state
	test_initial_state()
	
	# Test 2: Test achievement unlocking
	await test_achievement_unlocking()
	
	# Test 3: Test achievement persistence
	await test_achievement_persistence()
	
	# Output test results
	output_results()
	
	# Clean up and quit after a short delay
	await get_tree().create_timer(1.0).timeout
	get_tree().quit()

func test_initial_state():
	print("\nTesting initial achievement state...")
	
	# Check if all achievements start locked
	var all_achievements = achievement_manager.get_all_achievements()
	for id in all_achievements:
		if all_achievements[id]["unlocked"]:
			print("ERROR: Achievement %s should start locked" % id)
			test_success = false
			failure_messages.append("FAIL: Achievement %s should start locked" % id)

func test_achievement_unlocking():
	print("\nTesting achievement unlocking...")
	
	# Test unlocking first victory achievement
	achievement_manager.check_achievement("first_victory")
	await get_tree().create_timer(0.5).timeout
	
	if !achievement_manager.is_achievement_unlocked("first_victory"):
		print("ERROR: First victory achievement should be unlocked")
		test_success = false
		failure_messages.append("FAIL: First victory achievement not unlocked")
	
	# Test unlocking perfect level achievement
	achievement_manager.check_achievement("perfect_level")
	await get_tree().create_timer(0.5).timeout
	
	if !achievement_manager.is_achievement_unlocked("perfect_level"):
		print("ERROR: Perfect level achievement should be unlocked")
		test_success = false
		failure_messages.append("FAIL: Perfect level achievement not unlocked")
	
	# Test unlocking color master achievement
	achievement_manager.check_achievement("color_master")
	await get_tree().create_timer(0.5).timeout
	
	if !achievement_manager.is_achievement_unlocked("color_master"):
		print("ERROR: Color master achievement should be unlocked")
		test_success = false
		failure_messages.append("FAIL: Color master achievement not unlocked")

func test_achievement_persistence():
	print("\nTesting achievement persistence...")
	
	# Save achievements
	achievement_manager.save_achievements()
	
	# Create new instance to simulate game restart
	var new_manager = AchievementManager.new()
	new_manager.load_achievements()
	
	# Check if achievements are still unlocked
	if !new_manager.is_achievement_unlocked("first_victory"):
		print("ERROR: First victory achievement not persisted")
		test_success = false
		failure_messages.append("FAIL: Achievement persistence failed")

func output_results():
	var output_text = ""
	
	if test_success:
		output_text = "Step 19 Verification: PASS\n\n"
		output_text += "Successfully implemented achievement system:\n"
		output_text += "- Achievement manager properly tracks achievements\n"
		output_text += "- Achievements unlock correctly\n"
		output_text += "- Achievement data persists between sessions\n"
	else:
		output_text = "Step 19 Verification: FAIL\n\n"
		output_text += "The following issues were found:\n"
		
		for message in failure_messages:
			output_text += "- " + message + "\n"
		
		output_text += "\nPlease fix these issues before proceeding to Step 20."
	
	# Save output to a file
	print("Saving verification results to step19_verification.txt")
	var file = FileAccess.open("res://step19_verification.txt", FileAccess.WRITE)
	file.store_string(output_text)
	file.close()
	
	# Also print to console
	print(output_text) 