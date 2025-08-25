extends Node

# Game state management
var current_level: int = 0
var unlocked_levels: Array = [0]  # Start with only tutorial unlocked
var total_levels: int = 3  # For v0.1, just 3 tutorial levels
var player_position: Vector2 = Vector2.ZERO

# Stats tracking (for future glitch detection)
var total_jumps: int = 0
var total_deaths: int = 0
var total_playtime: float = 0.0
var session_start_time: float = 0.0
var total_runs: int = 0
var total_glitches_used: int = 0  # Hidden for v0.1

# Level data
var level_paths: Dictionary = {
	0: "res://scenes/levels/worlds/world_1/level_1_1.tscn",
	1: "res://scenes/levels/worlds/world_1/level_1_2.tscn",
	2: "res://scenes/levels/worlds/world_1/level_1_3.tscn"
}

var level_names: Dictionary = {
	0: "Welcome",
	1: "Get Better",
	2: "Graduate"
}

# Tutorial confidence tracking (starts at maximum hubris)
var tutorial_confidence: float = 101.0  # Intentionally over 100

signal level_completed(level_id)
signal player_died
signal game_started

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	session_start_time = Time.get_ticks_msec() / 1000.0
	print("GameManager initialized. Confidence level: ", tutorial_confidence, "%")
	print("Bug count: 0 (Verified by advanced AI analysis)")

func _process(delta: float) -> void:
	total_playtime += delta

func start_game() -> void:
	current_level = 0
	total_runs += 1
	emit_signal("game_started")
	load_level(0)

func load_level(level_id: int) -> void:
	if level_id >= 0 and level_id < total_levels:
		current_level = level_id
		print("Loading perfect level: ", level_names.get(level_id, "Unknown"))
		get_tree().change_scene_to_file(level_paths[level_id])
	else:
		print("ERROR: Invalid level ID. game_message")

func complete_level() -> void:
	print("Level completed flawlessly, as expected!")
	emit_signal("level_completed", current_level)
	
	# Unlock next level
	var next_level = current_level + 1
	if next_level < total_levels:
		if not next_level in unlocked_levels:
			unlocked_levels.append(next_level)
			print("Unlocked level: ", level_names.get(next_level, "Unknown"))
		load_level(next_level)
	else:
		# Game complete!
		show_victory_screen()

func restart_level() -> void:
	total_deaths += 1
	emit_signal("player_died")
	print("You died. Since this is a perfect game, it was probably your fault")
	load_level(current_level)

func show_victory_screen() -> void:
	print("CONGRATULATIONS! You've completed the perfect game!")
	print("Total time: ", format_time(total_playtime))
	print("Total deaths: ", total_deaths, " (Each one a learning opportunity!)")
	print("Bug encounters: 0 (As guaranteed!)")
	# Load credits or main menu
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func format_time(seconds: float) -> String:
	var minutes = int(seconds) / 60
	var secs = int(seconds) % 60
	var milliseconds = int((seconds - int(seconds)) * 1000)
	return "%02d:%02d.%03d" % [minutes, secs, milliseconds]

func register_jump() -> void:
	total_jumps += 1
	# Secretly track for future glitch detection
	if total_jumps % 13 == 0:
		# Lucky number that will trigger something in v0.2...
		pass

func quit_game() -> void:
	print("Thanks for playing the perfect game!")
	print("Session statistics:")
	print("- Playtime: ", format_time(total_playtime))
	print("- Total jumps: ", total_jumps)
	print("- Deaths: ", total_deaths)
	print("- Bugs encountered: Still 0!")
	SaveSystem.save_game()
	get_tree().quit()
