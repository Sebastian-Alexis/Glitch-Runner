extends Node2D

# Level properties
@export var level_id: int = 0
@export var level_name: String = "Tutorial Level"
@export var is_tutorial: bool = true
@export var par_time: float = 30.0  # "Perfect" completion time

# Level state
var level_start_time: float = 0.0
var player_spawn_point: Vector2 = Vector2(100, 300)
var goal_reached: bool = false

# References
var player: CharacterBody2D = null
var tutorial_ui: Control = null
var camera: Camera2D = null

signal level_started
signal level_completed
signal player_respawned

func _ready() -> void:
	level_start_time = Time.get_ticks_msec() / 1000.0
	setup_level()
	spawn_player()
	setup_noise_background()
	
	if is_tutorial:
		show_tutorial_message()
		setup_tutorial_triggers()
	
	# Start speedrun timer (hidden)
	SpeedrunTimer.start_timer()
	
	emit_signal("level_started")
	print("Level started: ", level_name)
	print("Par time: ", par_time, " seconds (Perfectly calculated for fun!)")

func setup_level() -> void:
	# Find spawn point
	var spawn = get_node_or_null("SpawnPoint")
	if spawn:
		player_spawn_point = spawn.global_position
	
	# Connect goal if exists
	var goal = get_node_or_null("Goal")
	if goal and goal.has_signal("body_entered"):
		goal.body_entered.connect(_on_goal_reached)
	
	# Set up death zones
	var death_zones = get_tree().get_nodes_in_group("death_zones")
	for zone in death_zones:
		if zone.has_signal("body_entered"):
			zone.body_entered.connect(_on_death_zone_entered)

func setup_noise_background() -> void:
	# Find the background ColorRect
	var background = get_node_or_null("Background")
	if not background:
		return
	
	# Load the noise shader
	var noise_shader = load("res://shaders/noise_background.gdshader")
	if not noise_shader:
		print("Warning: Could not load noise shader")
		return
	
	# Create shader material
	var shader_material = ShaderMaterial.new()
	shader_material.shader = noise_shader
	
	# Calculate progressive noise settings based on level
	var completed_levels = GameManager.current_level
	
	# Progressive noise intensity and color
	# Level 0 (1-1): Subtle white noise
	# Level 1 (1-2): More visible, slightly green
	# Level 2 (1-3): Even more visible, greener
	# Future levels will be more corrupted
	
	var base_intensity = 0.02  # Starting intensity for level 1-1
	var intensity_increment = 0.015  # How much more intense each level gets
	var noise_intensity = base_intensity + (completed_levels * intensity_increment)
	noise_intensity = min(noise_intensity, 0.3)  # Cap at 30% for v0.1
	
	# Color progression from white to green
	var green_mix = min(completed_levels * 0.25, 1.0)  # 0%, 25%, 50% green for levels 1-1, 1-2, 1-3
	
	# Set shader parameters
	shader_material.set_shader_parameter("noise_intensity", noise_intensity)
	shader_material.set_shader_parameter("noise_scale", 30.0 + completed_levels * 10.0)  # Gets more granular
	shader_material.set_shader_parameter("time_scale", 1.5 + completed_levels * 0.5)  # Speeds up slightly
	shader_material.set_shader_parameter("noise_color", Vector3(0.0, 1.0, 0.0))  # Green color
	shader_material.set_shader_parameter("color_mix", green_mix)
	
	# Apply the material to the background
	background.material = shader_material
	
	# Debug output
	print("Noise background initialized - Level: ", level_id, ", Intensity: ", noise_intensity, ", Green: ", green_mix * 100, "%")

func spawn_player() -> void:
	# Load player scene
	var player_scene = preload("res://scenes/player/player.tscn")
	player = player_scene.instantiate()
	add_child(player)
	player.position = player_spawn_point
	
	# Connect player signals
	player.died.connect(_on_player_died)
	
	# Get the camera that's attached to the player
	camera = player.get_node_or_null("Camera2D")
	if camera:
		setup_camera_limits(camera)
		print("Camera limits configured for player's camera")
	
	emit_signal("player_respawned")

func setup_camera_limits(camera: Camera2D) -> void:
	# Dynamically set camera boundaries based on level size
	var background = get_node_or_null("Background")
	if not background:
		print("Warning: No Background node found for camera limits")
		return
	
	# Get level dimensions from the Background ColorRect
	var level_width = background.size.x if background.has_method("get_size") else background.get_rect().size.x
	var level_height = background.size.y if background.has_method("get_size") else background.get_rect().size.y
	
	# For a Camera2D that's a child of the player, the limits define the world boundaries
	# The camera will automatically calculate what it can show based on its zoom level
	# Set simple world boundaries
	camera.limit_left = 0
	camera.limit_top = 0
	camera.limit_right = level_width
	camera.limit_bottom = level_height
	
	print("Camera limits set to level boundaries:")
	print("  Level size: ", level_width, "x", level_height)
	print("  Limits: Left=", camera.limit_left, " Top=", camera.limit_top, 
		  " Right=", camera.limit_right, " Bottom=", camera.limit_bottom)
	print("  Camera zoom: ", camera.zoom)
	print("  Player spawn: ", player_spawn_point)


func setup_tutorial_triggers() -> void:
	# Set up position-based tutorial triggers for Level 1-1
	if level_id == 0:
		# Create trigger area for Platform 1 double jump tutorial
		var platform1 = get_node_or_null("Platforms/Platform1")
		if platform1:
			var trigger_area = Area2D.new()
			trigger_area.name = "DoubleJumpTrigger"
			trigger_area.collision_layer = 0
			trigger_area.collision_mask = 1  # Only detect player
			
			var trigger_shape = CollisionShape2D.new()
			var rect = RectangleShape2D.new()
			rect.size = Vector2(120, 20)  # Thin area on top of platform
			trigger_shape.shape = rect
			trigger_shape.position = Vector2(0, -26)  # Just above the platform surface
			
			trigger_area.add_child(trigger_shape)
			platform1.add_child(trigger_area)
			
			# Connect the triggers
			trigger_area.body_entered.connect(_on_double_jump_trigger_entered)
			trigger_area.body_exited.connect(_on_double_jump_trigger_exited)

var double_jump_shown: bool = false
var double_jump_timer: float = 0.0
var player_on_platform1: bool = false

func _on_double_jump_trigger_entered(body: Node) -> void:
	if body == player and not double_jump_shown:
		# Check if player is actually on top (not hitting from side)
		var platform1 = get_node_or_null("Platforms/Platform1")
		if platform1 and player:
			var platform_top_y = platform1.global_position.y - 16  # Top of platform
			var player_bottom_y = player.global_position.y + 15  # Bottom of player
			
			# Only trigger if player is above the platform
			if player_bottom_y <= platform_top_y + 5:  # Small tolerance
				player_on_platform1 = true
				# Start timer for delayed popup
				await get_tree().create_timer(0.25).timeout
				
				# Check if still on platform and hasn't shown yet
				if player_on_platform1 and not double_jump_shown:
					double_jump_shown = true
					
					# Show double jump tutorial
					var popup_scene = preload("res://scenes/ui/tutorial/tutorial_popup.tscn")
					var popup = popup_scene.instantiate()
					var canvas_layer = CanvasLayer.new()
					add_child(canvas_layer)
					canvas_layer.add_child(popup)
					
					var message = "TIP: Double Jump!\nPress SPACE again while in the air\nYou'll need it for the next platform"
					popup.show_popup(message, true, 3.0)

func _on_double_jump_trigger_exited(body: Node) -> void:
	if body == player:
		player_on_platform1 = false

func show_tutorial_message() -> void:
	# Create and show popup for level start
	var popup_scene = preload("res://scenes/ui/tutorial/tutorial_popup.tscn")
	var popup = popup_scene.instantiate()
	var canvas_layer = CanvasLayer.new()
	add_child(canvas_layer)
	canvas_layer.add_child(popup)
	
	match level_id:
		0:  # Level 1-1
			var message = "Welcome to GLITCH RUNNER\nThis is a game with 0 bugs\nUse A/D to move, SPACE to jump"
			popup.show_popup(message, true, 3.0)
		1:  # Level 1-2
			var message = "Advanced Jumping Techniques\nDouble jump with SPACE in air\nHold SPACE for higher jumps"
			popup.show_popup(message, true, 3.0)
		2:  # Level 1-3
			var message = "Final Test of Perfection\nCombine all your skills\nClaude is watching with 101% confidence"
			popup.show_popup(message, true, 3.0)

func _on_goal_reached(body: Node) -> void:
	if body == player and not goal_reached:
		goal_reached = true
		level_complete()

func _on_death_zone_entered(body: Node) -> void:
	if body == player:
		player.die()

func _on_player_died() -> void:
	# Respawn player after short delay
	await get_tree().create_timer(1.0).timeout
	respawn_player()

func respawn_player() -> void:
	if player:
		player.position = player_spawn_point
		player.velocity = Vector2.ZERO
		TutorialManager.show_message("death")
		emit_signal("player_respawned")

func level_complete() -> void:
	var completion_time = Time.get_ticks_msec() / 1000.0 - level_start_time
	
	print("LEVEL COMPLETE!")
	print("Time: ", GameManager.format_time(completion_time))
	
	if completion_time <= par_time:
		print("PERFECT TIMING! You completed it exactly as intended!")
		TutorialManager.force_tutorial_message("FLAWLESS! You're playing EXACTLY as designed!")
	else:
		print("Good job! The intended time was ", par_time, " seconds.")
		TutorialManager.force_tutorial_message("Well done! Try to match the perfect time next time!")
	
	# Stop speedrun timer
	SpeedrunTimer.stop_timer()
	
	# Play victory sound
	AudioManager.play_sfx("victory")
	
	emit_signal("level_completed")
	
	# Tell GameManager to load next level
	await get_tree().create_timer(2.0).timeout
	GameManager.complete_level()

func get_completion_percentage() -> float:
	# Calculate how "perfectly" the level was completed
	var time_score = clamp(par_time / (Time.get_ticks_msec() / 1000.0 - level_start_time), 0.0, 1.0)
	var death_penalty = max(0.0, 1.0 - (GameManager.total_deaths * 0.1))
	return (time_score + death_penalty) / 2.0 * 100.0

# Hidden function for detecting glitch usage
func _detect_suspicious_behavior() -> void:
	if player:
		# Check if player is somewhere they shouldn't be
		if player.position.y < -100:  # Above the level?
			MetaNarrative.trigger_meta_event("suspicious_behavior")
		
		# Check if moving too fast (future glitch detection)
		if player.velocity.length() > 1000:
			MetaNarrative.trigger_meta_event("impossible_achievement")
