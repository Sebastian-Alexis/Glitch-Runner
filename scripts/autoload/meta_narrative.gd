extends Node

# Meta narrative tracking (mostly hidden in v0.1)
var player_knows_truth: bool = false
var fourth_wall_breaks: int = 0
var claude_awareness_level: float = 0.0  # Claude doesn't know yet...

# Hidden messages that will appear in v0.2+
var hidden_messages: Array = [
	"// TODO: Fix collision at corners",
	"// NOTE: Jump held for 13 frames causes weird behavior",
	"// FIXME: J key triggers lag for some reason",
	"// Claude: This shouldn't be possible...",
	"// git commit -m 'Fixed all bugs (I think)'"
]

# Terminal commands (for v0.5+)
var terminal_history: Array = []
var reality_stable: bool = true

signal fourth_wall_broken
signal claude_awakening(awareness_level)
signal reality_glitch

func _ready() -> void:
	print("Meta systems initialized. Reality stable: true")
	# Everything seems normal in v0.1...

func trigger_meta_event(event_type: String) -> void:
	match event_type:
		"suspicious_behavior":
			# Player doing something unexpected
			_note_suspicious_behavior()
		
		"impossible_achievement":
			# Player did something that shouldn't be possible
			_record_impossibility()
		
		"fourth_wall_crack":
			# Small break in the fiction
			fourth_wall_breaks += 1
			emit_signal("fourth_wall_broken")
		
		_:
			pass

func _note_suspicious_behavior() -> void:
	# Secretly track when player tries to break things
	claude_awareness_level += 0.1
	
	if claude_awareness_level > 1.0 and not player_knows_truth:
		# This won't happen until v0.2+
		print("Wait... what are you doing?")

func _record_impossibility() -> void:
	# Track impossible events for future narrative
	claude_awareness_level += 0.5
	
	# Add to secret log
	var log_entry = {
		"time": Time.get_ticks_msec() / 1000.0,
		"event": "impossibility_detected",
		"reality_stable": reality_stable
	}
	terminal_history.append(log_entry)

func add_terminal_command(command: String) -> void:
	# For v0.5+ terminal integration
	terminal_history.append(command)
	
	# Special commands that affect reality
	if command == "sudo rm -rf /reality":
		reality_stable = false
		emit_signal("reality_glitch")

func get_hidden_message() -> String:
	# Return a random hidden message (won't show in v0.1)
	if hidden_messages.size() > 0:
		return hidden_messages[randi() % hidden_messages.size()]
	return ""

func check_reality_integrity() -> float:
	# Returns how "real" the game world is
	var integrity = 100.0
	integrity -= fourth_wall_breaks * 5.0
	integrity -= claude_awareness_level * 10.0
	integrity -= GlitchEngine.corruption_level
	
	if not reality_stable:
		integrity *= 0.5
	
	return max(0.0, integrity)

func trigger_claude_monologue(topic: String) -> String:
	# Claude's inner thoughts (hidden until v0.3+)
	match topic:
		"perfection":
			return "I've created the perfect game. No bugs. No glitches. Just pure, optimized fun."
		"player_behavior":
			return "The player is following the intended path perfectly. As expected."
		"confidence":
			return "My confidence level is at 101%. Mathematically impossible, yet here we are."
		_:
			return "Everything is working as intended."

# Secret developer notes (will be findable in v0.2+)
func get_developer_note() -> String:
	var notes = [
		"Claude insisted this game has no bugs. We'll see about that.",
		"I added the J key handler as a joke. Claude didn't notice.",
		"The collision boxes are off by 2 pixels. Claude says it's 'pixel-perfect'.",
		"Frame 13 of jump hold does something weird. Leaving it in.",
		"Claude's confidence is at 101%. That's not how percentages work."
	]
	return notes[randi() % notes.size()]

func reality_check() -> void:
	# Called periodically to check if reality is breaking
	var integrity = check_reality_integrity()
	
	if integrity < 50.0 and reality_stable:
		print("REALITY INTEGRITY WARNING: ", integrity, "%")
		reality_stable = false
		emit_signal("reality_glitch")
	
	if integrity < 10.0:
		print("REALITY.EXE HAS STOPPED RESPONDING")

# Easter egg function (completely hidden)
func _konami_code_entered() -> void:
	print("30 lives? In a perfect game, you only need one!")
	fourth_wall_breaks += 10