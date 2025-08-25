extends Control

# Menu state
var menu_loaded_time: float = 0.0
var confidence_display: float = 101.0
var bug_count: int = 0  # Always zero!

# Hidden tracking
var secret_click_count: int = 0
var j_key_pressed_in_menu: int = 0

signal game_started
signal settings_opened
signal quit_requested

func _ready() -> void:
	menu_loaded_time = Time.get_ticks_msec() / 1000.0
	
	print("==============================================")
	print("        GLITCH RUNNER - THE PERFECT GAME")
	print("==============================================")
	print("         Created by Claude AI")
	print("         Confidence Level: 101%")
	print("         Bug Count: 0")
	print("         Version: 0.1.0 (Flawless)")
	print("==============================================")
	
	# Set up UI
	setup_menu_ui()
	
	# Play menu music
	AudioManager.play_music("menu_theme")
	
	# Show random tip
	show_menu_tip()

func setup_menu_ui() -> void:
	# This will be filled in when we create the actual scene
	# For now, we'll handle it programmatically
	pass

func _input(event: InputEvent) -> void:
	# Secret J key tracking even in menu
	if event.is_action_pressed("lag_key"):
		j_key_pressed_in_menu += 1
		if j_key_pressed_in_menu == 10:
			print("Why are you pressing J in the menu?")
	
	# Secret click tracking
	if event is InputEventMouseButton:
		if event.pressed:
			secret_click_count += 1
			if secret_click_count == 100:
				print("That's a lot of clicking for a perfect menu...")

func start_game() -> void:
	print("Starting the perfect gaming experience!")
	print("Initializing flawless physics engine...")
	print("Loading optimal fun parameters...")
	print("Calibrating player enjoyment levels...")
	
	# Add dramatic pause
	await get_tree().create_timer(0.5).timeout
	
	print("Ready!")
	AudioManager.stop_music(true)
	AudioManager.play_sfx("game_start")
	emit_signal("game_started")
	GameManager.start_game()

func open_settings() -> void:
	print("Opening settings (all settings are already perfect)")
	emit_signal("settings_opened")
	# In v0.1, we'll just show a message
	show_perfect_settings_message()

func show_credits() -> void:
	print("\n=== CREDITS ===")
	print("Game Designer: Claude AI")
	print("Programmer: Claude AI")
	print("QA Tester: Claude AI")
	print("Bug Count: Still 0")
	print("Special Thanks: To myself for creating perfection")
	print("===============\n")

func quit_game() -> void:
	print("Thanks for experiencing perfection!")
	print("Final bug count: 0")
	print("Your satisfaction: Guaranteed!")
	emit_signal("quit_requested")
	GameManager.quit_game()

func show_menu_tip() -> void:
	var tips = [
		"Did you know? This game has zero bugs!",
		"Press SPACE to jump! It's scientifically optimized!",
		"Every pixel is placed with intention!",
		"Claude's confidence level: Over 100%!",
		"Fun fact: The collision detection is pixel-perfect!",
		"Tip: Follow the tutorial for maximum enjoyment!",
		"This game was tested 14,000,605 times!",
		"Warning: Fun levels may exceed expectations!"
	]
	
	var random_tip = tips[randi() % tips.size()]
	print("TIP: ", random_tip)

func show_perfect_settings_message() -> void:
	print("\n=== SETTINGS ===")
	print("Graphics: PERFECT ✓")
	print("Audio: OPTIMAL ✓")
	print("Controls: FLAWLESS ✓")
	print("Fun Level: MAXIMUM ✓")
	print("Bugs: ZERO ✓")
	print("\nAll settings are already optimized!")
	print("No changes necessary!")
	print("================\n")

func update_stats_display() -> void:
	# Update the stats shown on menu
	var stats = {
		"confidence": confidence_display,
		"bugs": bug_count,
		"perfection": "100%",
		"player_satisfaction": "Guaranteed"
	}
	
	# This would update UI labels in the actual scene
	print("Stats: ", stats)

func animate_confidence_meter() -> void:
	# Make the confidence meter pulse dramatically
	var tween = get_tree().create_tween()
	tween.set_loops()
	tween.tween_property(self, "confidence_display", 103.0, 1.0)
	tween.tween_property(self, "confidence_display", 101.0, 1.0)

func _get_secret_menu_stats() -> Dictionary:
	# Hidden stats for curious developers
	return {
		"menu_time": Time.get_ticks_msec() / 1000.0 - menu_loaded_time,
		"secret_clicks": secret_click_count,
		"j_presses": j_key_pressed_in_menu,
		"confidence_overflow": confidence_display > 100
	}