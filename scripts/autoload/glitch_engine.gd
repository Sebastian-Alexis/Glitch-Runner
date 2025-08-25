extends Node

# Hidden glitch tracking for v0.1 (not visible to players yet)
var jump_held_tracking: Dictionary = {}  # Track how long jump is held
var corner_collisions: int = 0  # Track suspicious corner hits
var rapid_inputs: int = 0  # Track button mashing
var j_key_presses: int = 0  # Secret tracking of J key

# These will be important in v0.2+
var glitch_catalog: Dictionary = {
	"mega_jump": {
		"discovered": false,
		"trigger_frame": 13,
		"multiplier": 3.0
	},
	"lag_storage": {
		"discovered": false,
		"trigger_key": "J",
		"effect": "momentum_boost"
	},
	"collision_offset": {
		"discovered": false,
		"trigger": "quick_respawn",
		"offset": Vector2(4, 0)
	}
}

# Physics modifications (inactive in v0.1, but ready)
var gravity_modifier: float = 1.0
var speed_modifier: float = 1.0
var jump_modifier: float = 1.0

# Hidden corruption level (starts at 0 for v0.1)
var corruption_level: float = 0.0
var reality_stability: float = 100.0

signal glitch_discovered(glitch_name: String)  # Won't fire in v0.1
signal reality_breaking(amount: float)  # For future use

func _ready() -> void:
	set_process(true)
	# Silently initialize glitch detection
	print("Physics engine initialized. Stability: PERFECT")

func track_jump_hold(frames: int) -> void:
	# Secretly track jump holds for future mega jump
	if not jump_held_tracking.has("current_session"):
		jump_held_tracking["current_session"] = []
	
	jump_held_tracking["current_session"].append(frames)
	
	# Check for the magic number (but don't activate in v0.1)
	if frames == 13:
		# In v0.2, this will trigger mega jump
		# For now, just silently note it
		if not jump_held_tracking.has("thirteen_frame_jumps"):
			jump_held_tracking["thirteen_frame_jumps"] = 0
		jump_held_tracking["thirteen_frame_jumps"] += 1

func track_corner_collision(position: Vector2) -> void:
	# Track when player hits corners (future wall clip detection)
	corner_collisions += 1
	
	# In v0.2, specific corners will allow clipping
	# For now, just count them
	if corner_collisions > 10:
		# Player is definitely trying to break things
		pass

func track_j_key() -> void:
	# Secret J key tracking (will cause lag in v0.2)
	j_key_presses += 1
	
	# After 100 J presses, they're definitely looking for secrets
	if j_key_presses == 100:
		print("Interesting keyboard usage patterns detected...")

func track_rapid_input(input_type: String) -> void:
	# Track button mashing
	rapid_inputs += 1
	
	# Future use: spam detection for glitches
	if rapid_inputs > 50:
		# Player is trying to break the game
		pass

func get_gravity_modifier() -> float:
	# Always return 1.0 in v0.1 (normal gravity)
	return gravity_modifier

func get_speed_modifier() -> float:
	# Always return 1.0 in v0.1 (normal speed)
	return speed_modifier

func get_jump_modifier() -> float:
	# Always return 1.0 in v0.1 (normal jump)
	return jump_modifier

func apply_glitch_effect(glitch_name: String) -> void:
	# This won't actually do anything in v0.1
	# But it's ready for v0.2 when glitches activate
	pass

func reset_reality() -> void:
	# Future use: reset all glitch states
	gravity_modifier = 1.0
	speed_modifier = 1.0
	jump_modifier = 1.0
	corruption_level = 0.0
	reality_stability = 100.0

# Secret analytics for developer curiosity
func get_secret_stats() -> Dictionary:
	return {
		"jump_holds": jump_held_tracking,
		"corner_hits": corner_collisions,
		"j_presses": j_key_presses,
		"rapid_inputs": rapid_inputs,
		"player_curiosity_score": calculate_curiosity_score()
	}

func calculate_curiosity_score() -> float:
	# Hidden metric to see if players are trying to break things
	var score = 0.0
	score += jump_held_tracking.get("thirteen_frame_jumps", 0) * 10
	score += corner_collisions * 2
	score += j_key_presses * 0.5
	score += rapid_inputs * 0.1
	return score