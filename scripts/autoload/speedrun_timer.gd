extends Node

# Timer state
var timer_active: bool = false
var elapsed_time: float = 0.0
var start_time: float = 0.0
var splits: Array = []
var current_split: int = 0

# Hidden tracking for v0.1 (preparing for speedrun features)
var frame_count: int = 0
var input_buffer: Array = []
var state_timeline: Array = []

# Best times (will be important in v0.2+)
var best_times: Dictionary = {
	"any%": -1.0,
	"glitchless": -1.0,  # Will be impossible in v0.2+
	"100%": -1.0
}

signal timer_started
signal timer_stopped
signal split_time(time)
signal new_record(category, time)

func _ready() -> void:
	set_process(false)  # Disabled by default in v0.1
	print("Speedrun timer initialized (hidden feature)")

func _process(delta: float) -> void:
	if timer_active:
		elapsed_time += delta
		frame_count += 1
		
		# Secret frame data recording
		if frame_count % 60 == 0:  # Every second
			_record_state()

func start_timer() -> void:
	timer_active = true
	elapsed_time = 0.0
	frame_count = 0
	start_time = Time.get_ticks_msec() / 1000.0
	splits.clear()
	input_buffer.clear()
	state_timeline.clear()
	set_process(true)
	emit_signal("timer_started")
	print("Timer started (secret speedrun mode activated)")

func stop_timer() -> void:
	if timer_active:
		timer_active = false
		set_process(false)
		emit_signal("timer_stopped")
		
		# Check for records (hidden in v0.1)
		_check_record("any%", elapsed_time)
		
		print("Final time: ", format_time(elapsed_time))

func split() -> void:
	if timer_active:
		splits.append(elapsed_time)
		emit_signal("split_time", elapsed_time)
		current_split += 1

func reset_timer() -> void:
	timer_active = false
	elapsed_time = 0.0
	frame_count = 0
	splits.clear()
	current_split = 0
	set_process(false)

func format_time(time: float) -> String:
	var minutes = int(time) / 60
	var seconds = int(time) % 60
	var milliseconds = int((time - int(time)) * 1000)
	return "%02d:%02d.%03d" % [minutes, seconds, milliseconds]

func get_current_time() -> float:
	return elapsed_time

func get_frame_count() -> int:
	return frame_count

func _record_state() -> void:
	# Secretly record game state for replay validation
	var state = {
		"time": elapsed_time,
		"frame": frame_count,
		"level": GameManager.current_level,
		"jumps": GameManager.total_jumps,
		"deaths": GameManager.total_deaths
	}
	state_timeline.append(state)

func _check_record(category: String, time: float) -> void:
	if best_times.has(category):
		if best_times[category] < 0 or time < best_times[category]:
			best_times[category] = time
			emit_signal("new_record", category, time)
			print("NEW RECORD! Category: ", category, " Time: ", format_time(time))
			
			# Save to file (hidden)
			_save_record(category, time)

func _save_record(category: String, time: float) -> void:
	# Hidden speedrun data
	var speedrun_data = {
		"category": category,
		"time": time,
		"date": Time.get_datetime_string_from_system(),
		"frame_count": frame_count,
		"version": "0.1.0"
	}
	
	# This will be revealed in v0.2 when speedrun mode activates
	pass

func get_best_time(category: String) -> float:
	return best_times.get(category, -1.0)

# Secret function to detect speedrun attempts
func detect_speedrun_behavior() -> bool:
	# Check if player is trying to go fast
	if elapsed_time > 0 and elapsed_time < 180:  # Under 3 minutes
		if GameManager.total_deaths < 3:  # Low death count
			return true
	return false
