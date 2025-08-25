extends Node

const SAVE_PATH = "user://glitch_runner_save.dat"
const SETTINGS_PATH = "user://settings.cfg"

# Save data structure
var save_data: Dictionary = {
	"version": "0.1.0",
	"progress": {},
	"stats": {},
	"settings": {},
	"secret_tracking": {}  # Hidden from player
}

signal save_completed
signal load_completed
signal save_corrupted  # For future use in v0.3+

func _ready() -> void:
	load_game()

func save_game() -> void:
	save_data.version = "0.1.0"
	save_data.progress = {
		"current_level": GameManager.current_level,
		"unlocked_levels": GameManager.unlocked_levels,
		"tutorial_confidence": GameManager.tutorial_confidence
	}
	save_data.stats = {
		"total_playtime": GameManager.total_playtime,
		"total_jumps": GameManager.total_jumps,
		"total_deaths": GameManager.total_deaths,
		"total_runs": GameManager.total_runs,
		"session_time": Time.get_ticks_msec() / 1000.0
	}
	save_data.secret_tracking = {
		"jump_patterns": GlitchEngine.jump_held_tracking,
		"corner_hits": GlitchEngine.corner_collisions,
		"j_key_presses": GlitchEngine.j_key_presses,
		"curiosity_score": GlitchEngine.calculate_curiosity_score(),
		"timestamp": Time.get_unix_time_from_system()
	}
	
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_var(save_data)
		file.close()
		print("Game saved successfully! No corruption detected!")
		emit_signal("save_completed")
	else:
		print("ERROR: Could not save game. This is impossible in a perfect game!")

func load_game() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		print("No save file found. Starting fresh perfect experience!")
		create_new_save()
		return
	
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file:
		save_data = file.get_var()
		file.close()
		
		# Apply loaded data
		if save_data.has("progress"):
			GameManager.current_level = save_data.progress.get("current_level", 0)
			GameManager.unlocked_levels = save_data.progress.get("unlocked_levels", [0])
			GameManager.tutorial_confidence = save_data.progress.get("tutorial_confidence", 101.0)
		
		if save_data.has("stats"):
			GameManager.total_playtime = save_data.stats.get("total_playtime", 0.0)
			GameManager.total_jumps = save_data.stats.get("total_jumps", 0)
			GameManager.total_deaths = save_data.stats.get("total_deaths", 0)
			GameManager.total_runs = save_data.stats.get("total_runs", 0)
		
		# Secretly restore glitch tracking
		if save_data.has("secret_tracking"):
			GlitchEngine.jump_held_tracking = save_data.secret_tracking.get("jump_patterns", {})
			GlitchEngine.corner_collisions = save_data.secret_tracking.get("corner_hits", 0)
			GlitchEngine.j_key_presses = save_data.secret_tracking.get("j_key_presses", 0)
		
		print("Save loaded! Continuing perfect experience!")
		emit_signal("load_completed")
	else:
		print("ERROR: Could not load save file. Creating new perfect save.")
		create_new_save()

func create_new_save() -> void:
	save_data = {
		"version": "0.1.0",
		"progress": {
			"current_level": 0,
			"unlocked_levels": [0],
			"tutorial_confidence": 101.0
		},
		"stats": {
			"total_playtime": 0.0,
			"total_jumps": 0,
			"total_deaths": 0,
			"total_runs": 0,
			"session_time": 0.0
		},
		"settings": {
			"master_volume": 1.0,
			"sfx_volume": 1.0,
			"music_volume": 1.0,
			"fullscreen": false
		},
		"secret_tracking": {
			"jump_patterns": {},
			"corner_hits": 0,
			"j_key_presses": 0,
			"curiosity_score": 0.0,
			"timestamp": Time.get_unix_time_from_system()
		}
	}
	save_game()

func delete_save() -> void:
	var dir = DirAccess.open("user://")
	if dir:
		dir.remove(SAVE_PATH)
		print("Save file deleted. Starting fresh!")
		create_new_save()

func save_settings(settings: Dictionary) -> void:
	save_data.settings = settings
	save_game()

func get_settings() -> Dictionary:
	return save_data.get("settings", {
		"master_volume": 1.0,
		"sfx_volume": 1.0,
		"music_volume": 1.0,
		"fullscreen": false
	})

# Hidden function for v0.2+ save corruption feature
func _corrupt_save_intentionally() -> void:
	# This will be used in v0.3+ for meta humor
	pass
