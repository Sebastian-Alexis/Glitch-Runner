extends CharacterBody2D

# Movement constants (perfectly tuned for optimal fun!)
const WALK_SPEED = 300.0
const RUN_SPEED = 450.0  # For future use
const JUMP_VELOCITY = -500.0  # Increased for better height
const DOUBLE_JUMP_VELOCITY = -450.0  # Also increased
const GRAVITY = 980.0
const TERMINAL_VELOCITY = 600.0
const AIR_CONTROL = 0.5  # 50% control in air
const COYOTE_TIME = 0.1  # Frames after leaving platform where jump still works
const JUMP_BUFFER_TIME = 0.1  # Frames before landing where jump input is remembered

# State tracking
var can_double_jump: bool = false
var coyote_timer: float = 0.0
var jump_buffer_timer: float = 0.0
var is_running: bool = false

# Hidden tracking for future glitches
var jump_held_frames: int = 0  # This will be important in v0.2!
var total_jump_frames: int = 0  # Total frames jump has been held ever
var corner_collision_count: int = 0  # Track corner hits
var j_key_held_frames: int = 0  # Secret J key tracking
var last_position: Vector2 = Vector2.ZERO  # For position tracking
var position_history: Array = []  # Track last 60 frames of position

# Visual elements (will be added via scene)
@onready var sprite: Sprite2D = $Sprite2D if has_node("Sprite2D") else null
@onready var collision_shape: CollisionShape2D = $CollisionShape2D if has_node("CollisionShape2D") else null

signal jumped
signal landed
signal died

func _ready() -> void:
	add_to_group("player")
	TutorialManager.show_message("first_move")
	print("Player controller initialized. Physics: FLAWLESS")

func _physics_process(delta: float) -> void:
	# Store position history (for future glitch detection)
	position_history.append(position)
	if position_history.size() > 60:
		position_history.pop_front()
	
	# Apply gravity
	if not is_on_floor():
		velocity.y += GRAVITY * delta
		velocity.y = min(velocity.y, TERMINAL_VELOCITY)
		
		# Reduce coyote time
		if coyote_timer > 0:
			coyote_timer -= delta
	else:
		# On ground - reset states
		if velocity.y > 0:  # Just landed
			emit_signal("landed")
			AudioManager.play_sfx("land")
		
		can_double_jump = true
		coyote_timer = COYOTE_TIME
	
	# Handle jump buffer
	if jump_buffer_timer > 0:
		jump_buffer_timer -= delta
	
	# Get input
	var direction = Input.get_axis("move_left", "move_right")
	
	# Check for run (for future use)
	is_running = Input.is_action_pressed("run")
	
	# Movement
	if direction != 0:
		var target_speed = WALK_SPEED
		if is_running:
			target_speed = RUN_SPEED  # Won't actually be faster in v0.1
			
		if is_on_floor():
			velocity.x = direction * target_speed
		else:
			# Air control
			velocity.x = lerp(velocity.x, direction * target_speed, AIR_CONTROL * delta)
		
		# Flip sprite if we have one
		if sprite:
			sprite.flip_h = direction < 0
		
		# Tell tutorial we moved
		if position_history.size() > 2:
			if position_history[-2].distance_to(position) > 1:
				TutorialManager.react_to_player_action("move")
	else:
		# Friction
		velocity.x = move_toward(velocity.x, 0, WALK_SPEED * delta * 2)
		
		# Check if idle
		if is_on_floor() and abs(velocity.x) < 10:
			TutorialManager.react_to_player_action("idle")
	
	# Jump input detection
	if Input.is_action_just_pressed("jump"):
		jump_buffer_timer = JUMP_BUFFER_TIME
		attempt_jump()
	
	# SECRET: Track jump hold duration (for mega jump in v0.2)
	if Input.is_action_pressed("jump"):
		jump_held_frames += 1
		total_jump_frames += 1
		
		# Magic frame 13 detection (but don't activate yet)
		if jump_held_frames == 13:
			GlitchEngine.track_jump_hold(13)
			# In v0.2, this will trigger mega jump!
			print("DEBUG: Jump held for exactly 13 frames... interesting")
		
		# Variable jump height (barely noticeable in v0.1)
		if velocity.y < 0 and jump_held_frames < 10:
			velocity.y *= 0.98  # Tiny bit more height
	else:
		if jump_held_frames > 0:
			# Jump was released, track the duration
			GlitchEngine.track_jump_hold(jump_held_frames)
		jump_held_frames = 0
	
	# SECRET: Track J key (will cause lag in v0.2)
	if Input.is_action_pressed("lag_key"):
		j_key_held_frames += 1
		GlitchEngine.track_j_key()
		
		# After holding J for 60 frames, something might happen...
		if j_key_held_frames == 60:
			print("DEBUG: J key held for a full second. Curious...")
	else:
		j_key_held_frames = 0
	
	# Check for corner collisions (future wall clip spots)
	if is_on_wall() and not is_on_floor():
		corner_collision_count += 1
		GlitchEngine.track_corner_collision(position)
	
	# Apply movement
	move_and_slide()
	
	# Check if fell off the world
	if position.y > 1000:
		die()
	
	# Track stats
	last_position = position

func attempt_jump() -> void:
	# Check if we can jump
	if is_on_floor() or coyote_timer > 0:
		perform_jump()
	elif can_double_jump:
		perform_double_jump()

func perform_jump() -> void:
	velocity.y = JUMP_VELOCITY
	jump_buffer_timer = 0
	coyote_timer = 0
	emit_signal("jumped")
	AudioManager.play_sfx("jump")
	TutorialManager.react_to_player_action("jump")
	GameManager.register_jump()
	
	# Create jump particles if we have them
	create_jump_effect()

func perform_double_jump() -> void:
	velocity.y = DOUBLE_JUMP_VELOCITY
	can_double_jump = false
	jump_buffer_timer = 0
	emit_signal("jumped")
	AudioManager.play_sfx("jump", 2.0)  # Slightly higher pitched
	TutorialManager.show_tip()  # Give a helpful tip on double jump
	GameManager.register_jump()
	
	# Create double jump effect
	create_double_jump_effect()

func create_jump_effect() -> void:
	# Visual feedback for jumping
	if sprite:
		var tween = get_tree().create_tween()
		tween.tween_property(sprite, "scale", Vector2(0.8, 1.2), 0.1)
		tween.tween_property(sprite, "scale", Vector2.ONE, 0.1)

func create_double_jump_effect() -> void:
	# Extra visual feedback for double jump
	if sprite:
		var tween = get_tree().create_tween()
		tween.tween_property(sprite, "scale", Vector2(0.7, 1.3), 0.1)
		tween.tween_property(sprite, "scale", Vector2(1.1, 0.9), 0.1)
		tween.tween_property(sprite, "scale", Vector2.ONE, 0.1)

func die() -> void:
	emit_signal("died")
	AudioManager.play_sfx("death")
	TutorialManager.react_to_player_action("death")
	
	# Reset position (for now, just restart level)
	GameManager.restart_level()

func get_speed() -> float:
	return abs(velocity.x)

func get_height() -> float:
	return abs(position.y)

# Hidden function for future use
func _apply_glitch_modifier(type: String, value: float) -> void:
	# This will be activated in v0.2+
	match type:
		"mega_jump":
			velocity.y *= value
		"speed_boost":
			velocity.x *= value
		"gravity_mod":
			# Will modify gravity in v0.2
			pass
		_:
			pass

# Debug function (hidden from player)
func _get_secret_stats() -> Dictionary:
	return {
		"total_jump_frames": total_jump_frames,
		"max_jump_hold": jump_held_frames,
		"corner_hits": corner_collision_count,
		"j_key_presses": GlitchEngine.j_key_presses,
		"curiosity_score": GlitchEngine.calculate_curiosity_score()
	}