extends Node

# Tutorial personality for v0.1 - Maximum confidence
enum TutorialState {
	CONFIDENT,  # v0.1 - Everything is perfect!
	CONFUSED,   # v0.2 - Wait, that's not right...
	DEFENSIVE,  # v0.3 - It's a feature!
	DESPERATE,  # v0.4 - Please stop breaking things
	ACCEPTING   # v0.5 - Fine, break everything
}

var current_state: TutorialState = TutorialState.CONFIDENT
var confidence_level: float = 101.0  # Over 100% confident!
var messages_shown: Array = []
var current_message: String = ""
var message_queue: Array = []

# Patronizing messages for v0.1
var confident_messages: Dictionary = {
	"game_start": "Welcome to the PERFECT gaming experience! I've analyzed 14,000,605 possible bugs and eliminated them all!",
	"first_move": "Great job using the WASD keys! Or arrow keys! I support both because I'm thoughtful like that!",
	"first_jump": "WONDERFUL! You pressed SPACE! The jump arc is mathematically optimal for fun!",
	"jump_success": "Perfect jump! Just as my calculations predicted!",
	"death": "Don't worry! Even in a perfect game, practice makes perfect!",
	"level_complete": "FLAWLESS EXECUTION! You're playing exactly as intended!",
	"standing_still": "Taking a moment to appreciate the perfect level design? Excellent choice!",
	"multiple_jumps": "Look at you go! Each jump is precisely calibrated for maximum enjoyment!",
	"near_edge": "Careful near edges! My collision detection is pixel-perfect!",
	"found_secret": "You found the intended path! There are no secrets because everything is intentional!"
}

# Tutorial tips that are overly helpful
var helpful_tips: Array = [
	"TIP: Press SPACE to jump! It's the big key at the bottom of your keyboard!",
	"TIP: Holding SHIFT makes you run faster! (Coming in a future update)",
	"TIP: Gravity pulls you down! That's just physics!",
	"TIP: Avoid falling into pits! They're marked clearly for your convenience!",
	"TIP: The goal is on the right side of the level! Just like reading!",
	"TIP: You can press R to restart if needed! But you won't need it!",
	"TIP: This game has ZERO bugs! I've checked multiple times!",
	"TIP: Having fun is mandatory! Er, I mean, guaranteed!"
]

signal message_displayed(text)
signal confidence_changed(new_level)
signal tutorial_completed

func _ready() -> void:
	print("Tutorial System Online. Confidence: ", confidence_level, "%")
	print("Preparing to deliver optimal gaming guidance...")
	
	# Start with welcome message after short delay
	await get_tree().create_timer(1.0).timeout
	show_message("game_start")

func show_message(message_key: String) -> void:
	if message_key in confident_messages:
		current_message = confident_messages[message_key]
		_display_message(current_message)
		messages_shown.append(message_key)

func show_tip() -> void:
	if helpful_tips.size() > 0:
		var tip = helpful_tips[randi() % helpful_tips.size()]
		_display_message(tip)

func _display_message(text: String) -> void:
	print("[TUTORIAL] ", text)
	emit_signal("message_displayed", text)
	
	# In the actual game, this would update the UI
	# For now, we'll just track it
	current_message = text

func queue_message(text: String, delay: float = 0.0) -> void:
	if delay > 0:
		await get_tree().create_timer(delay).timeout
	
	message_queue.append(text)
	_process_message_queue()

func _process_message_queue() -> void:
	if message_queue.size() > 0:
		var next_message = message_queue.pop_front()
		_display_message(next_message)

func react_to_player_action(action: String) -> void:
	match action:
		"jump":
			if not "first_jump" in messages_shown:
				show_message("first_jump")
			elif randf() < 0.1:  # 10% chance for encouragement
				show_message("jump_success")
		
		"move":
			if not "first_move" in messages_shown:
				show_message("first_move")
		
		"death":
			show_message("death")
			confidence_level -= 0.1  # Tiny confidence drop (we're still perfect!)
			emit_signal("confidence_changed", confidence_level)
		
		"idle":
			if randf() < 0.05:  # 5% chance when idle
				show_message("standing_still")
		
		"level_complete":
			show_message("level_complete")
			show_tip()  # Always give a helpful tip on completion

func force_tutorial_message(text: String) -> void:
	# For special scripted moments
	_display_message(text)

func get_random_encouragement() -> String:
	var encouragements = [
		"You're doing great!",
		"Perfect execution!",
		"Just as I calculated!",
		"Optimal performance detected!",
		"Your skill level is increasing!",
		"Excellent choice!",
		"That's the intended solution!",
		"Flawless!"
	]
	return encouragements[randi() % encouragements.size()]

func complete_tutorial() -> void:
	print("Tutorial completed! Player has achieved PERFECT UNDERSTANDING!")
	emit_signal("tutorial_completed")

# Hidden functions for v0.2+ when glitches start
func _reduce_confidence(amount: float) -> void:
	# This will be used when glitches are discovered
	confidence_level = max(0, confidence_level - amount)
	emit_signal("confidence_changed", confidence_level)

func _enter_panic_mode() -> void:
	# For when things really go wrong in v0.3+
	current_state = TutorialState.CONFUSED
	print("WARNING: Unexpected player behavior detected!")