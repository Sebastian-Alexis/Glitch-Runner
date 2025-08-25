extends Node

# Audio buses
const MASTER_BUS = "Master"
const SFX_BUS = "SFX"
const MUSIC_BUS = "Music"

# Currently playing music
var current_music: AudioStreamPlayer = null
var music_integrity: float = 100.0  # Will degrade in v0.2+

# Sound effect pool
var sfx_pool: Dictionary = {}

# Volume settings
var master_volume: float = 1.0
var sfx_volume: float = 1.0
var music_volume: float = 1.0

signal music_started(track_name)
signal music_stopped
signal integrity_degraded(amount)  # For future glitch effects

func _ready() -> void:
	# Initialize audio buses
	setup_audio_buses()
	
	# Load volume settings
	var settings = SaveSystem.get_settings()
	master_volume = settings.get("master_volume", 1.0)
	sfx_volume = settings.get("sfx_volume", 1.0)
	music_volume = settings.get("music_volume", 1.0)
	apply_volume_settings()
	
	print("Audio system initialized. Quality: PRISTINE")

func setup_audio_buses() -> void:
	# Ensure buses exist
	if not AudioServer.get_bus_index(MASTER_BUS) >= 0:
		AudioServer.add_bus()
		AudioServer.set_bus_name(AudioServer.bus_count - 1, MASTER_BUS)
	
	if not AudioServer.get_bus_index(SFX_BUS) >= 0:
		AudioServer.add_bus()
		AudioServer.set_bus_name(AudioServer.bus_count - 1, SFX_BUS)
		var sfx_idx = AudioServer.get_bus_index(SFX_BUS)
		AudioServer.set_bus_send(sfx_idx, MASTER_BUS)
	
	if not AudioServer.get_bus_index(MUSIC_BUS) >= 0:
		AudioServer.add_bus()
		AudioServer.set_bus_name(AudioServer.bus_count - 1, MUSIC_BUS)
		var music_idx = AudioServer.get_bus_index(MUSIC_BUS)
		AudioServer.set_bus_send(music_idx, MASTER_BUS)

func play_sfx(sfx_name: String, volume_offset: float = 0.0) -> void:
	# Create a simple beep sound for v0.1
	var player = AudioStreamPlayer.new()
	add_child(player)
	player.bus = SFX_BUS
	player.volume_db = linear_to_db(sfx_volume) + volume_offset
	
	# Generate simple sound based on name
	match sfx_name:
		"jump":
			_play_jump_sound(player)
		"land":
			_play_land_sound(player)
		"collect":
			_play_collect_sound(player)
		"death":
			_play_death_sound(player)
		"victory":
			_play_victory_sound(player)
		_:
			_play_generic_beep(player)
	
	# Clean up after playing
	player.finished.connect(func(): player.queue_free())

func _play_generic_beep(player: AudioStreamPlayer) -> void:
	# For v0.1, we'll use simple generated tones
	# In production, you'd load actual audio files
	print("Playing sound effect (perfectly crisp audio!)")
	# Note: Actual audio implementation would require audio files
	player.queue_free()  # For now, just clean up

func _play_jump_sound(player: AudioStreamPlayer) -> void:
	print("Jump sound! (Optimized frequency: 440Hz)")
	player.queue_free()

func _play_land_sound(player: AudioStreamPlayer) -> void:
	print("Landing sound! (Perfect impact detection)")
	player.queue_free()

func _play_collect_sound(player: AudioStreamPlayer) -> void:
	print("Collection sound! (Dopamine-optimized chime)")
	player.queue_free()

func _play_death_sound(player: AudioStreamPlayer) -> void:
	print("Death sound... (But don't worry, you're learning!)")
	player.queue_free()

func _play_victory_sound(player: AudioStreamPlayer) -> void:
	print("VICTORY! (Triumphant fanfare at maximum quality!)")
	player.queue_free()

func play_music(track_name: String, fade_in: bool = true) -> void:
	stop_music(fade_in)
	
	# Create music player
	current_music = AudioStreamPlayer.new()
	add_child(current_music)
	current_music.bus = MUSIC_BUS
	current_music.volume_db = linear_to_db(music_volume)
	
	print("Now playing: ", track_name, " (No compression artifacts detected!)")
	emit_signal("music_started", track_name)
	
	# For v0.1, we'll just print
	# In production, you'd load and play actual music files

func stop_music(fade_out: bool = true) -> void:
	if current_music and is_instance_valid(current_music):
		if fade_out:
			# Simple fade out
			var tween = get_tree().create_tween()
			tween.tween_property(current_music, "volume_db", -80.0, 0.5)
			tween.tween_callback(func(): 
				if is_instance_valid(current_music):
					current_music.queue_free()
					current_music = null
			)
		else:
			current_music.queue_free()
			current_music = null
		
		emit_signal("music_stopped")
	else:
		current_music = null

func apply_volume_settings() -> void:
	var master_idx = AudioServer.get_bus_index(MASTER_BUS)
	var sfx_idx = AudioServer.get_bus_index(SFX_BUS)
	var music_idx = AudioServer.get_bus_index(MUSIC_BUS)
	
	if master_idx >= 0:
		AudioServer.set_bus_volume_db(master_idx, linear_to_db(master_volume))
	if sfx_idx >= 0:
		AudioServer.set_bus_volume_db(sfx_idx, linear_to_db(sfx_volume))
	if music_idx >= 0:
		AudioServer.set_bus_volume_db(music_idx, linear_to_db(music_volume))

func set_master_volume(value: float) -> void:
	master_volume = clamp(value, 0.0, 1.0)
	apply_volume_settings()
	SaveSystem.save_settings({
		"master_volume": master_volume,
		"sfx_volume": sfx_volume,
		"music_volume": music_volume
	})

func set_sfx_volume(value: float) -> void:
	sfx_volume = clamp(value, 0.0, 1.0)
	apply_volume_settings()
	SaveSystem.save_settings({
		"master_volume": master_volume,
		"sfx_volume": sfx_volume,
		"music_volume": music_volume
	})

func set_music_volume(value: float) -> void:
	music_volume = clamp(value, 0.0, 1.0)
	apply_volume_settings()
	SaveSystem.save_settings({
		"master_volume": master_volume,
		"sfx_volume": sfx_volume,
		"music_volume": music_volume
	})

# Hidden function for future audio glitches
func _degrade_audio_quality(amount: float) -> void:
	music_integrity -= amount
	# In v0.2+, this will cause audio glitches
	emit_signal("integrity_degraded", amount)
