extends Control

# Popup state
var is_typing: bool = false
var current_text: String = ""
var target_text: String = ""
var char_index: int = 0
var typing_speed: float = 0.05  # Seconds per character
var typing_timer: float = 0.0

# References
@onready var background_panel: Panel = $BackgroundPanel
@onready var text_label: RichTextLabel = $BackgroundPanel/MarginContainer/TextLabel
@onready var noise_overlay: ColorRect = $NoiseOverlay

signal typing_complete
signal popup_closed

func _ready() -> void:
	visible = false
	modulate.a = 0.0
	
	# Set up the noise shader if we have one
	setup_noise_effect()

func _process(delta: float) -> void:
	if is_typing:
		typing_timer += delta
		if typing_timer >= typing_speed:
			typing_timer = 0.0
			add_next_character()
	
	# Animate noise
	if visible and noise_overlay:
		var mat = noise_overlay.material
		if mat and mat is ShaderMaterial:
			mat.set_shader_parameter("time", Time.get_ticks_msec() / 1000.0)

func show_popup(text: String, auto_close: bool = false, close_delay: float = 3.0) -> void:
	target_text = text
	current_text = ""
	char_index = 0
	is_typing = true
	
	# Clear text and show popup
	text_label.text = ""
	visible = true
	
	# Fade in
	var tween = get_tree().create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 0.3)
	
	if auto_close:
		await typing_complete
		await get_tree().create_timer(close_delay).timeout
		close_popup()

func add_next_character() -> void:
	if char_index < target_text.length():
		var next_char = target_text[char_index]
		current_text += next_char
		
		# Format with green terminal color
		text_label.clear()
		text_label.append_text("[color=#00ff00]")
		text_label.append_text(current_text)
		
		# Add blinking cursor
		if char_index < target_text.length() - 1:
			text_label.append_text("_")
		text_label.append_text("[/color]")
		
		char_index += 1
		
		# Play typing sound (if we have audio)
		if char_index % 3 == 0:  # Play sound every 3rd character
			AudioManager.play_sfx("type")
	else:
		is_typing = false
		emit_signal("typing_complete")

func close_popup() -> void:
	var tween = get_tree().create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.3)
	tween.tween_callback(func(): visible = false)
	emit_signal("popup_closed")

func setup_noise_effect() -> void:
	# Create a simple noise shader
	if noise_overlay:
		var shader = Shader.new()
		shader.code = """
shader_type canvas_item;

uniform float time = 0.0;
uniform float noise_strength = 0.1;

float random(vec2 st) {
    return fract(sin(dot(st.xy, vec2(12.9898,78.233))) * 43758.5453123);
}

void fragment() {
    vec2 st = FRAGCOORD.xy / vec2(1920.0, 720.0);
    
    // Create animated noise
    float noise = random(st + vec2(time * 0.1, time * 0.15));
    noise *= random(st + vec2(time * 0.15, time * 0.1));
    
    // Apply noise with transparency
    COLOR = vec4(0.5, 0.5, 0.5, noise * noise_strength);
}
"""
		var mat = ShaderMaterial.new()
		mat.shader = shader
		mat.set_shader_parameter("time", 0.0)
		mat.set_shader_parameter("noise_strength", 0.15)
		noise_overlay.material = mat

func skip_typing() -> void:
	if is_typing:
		current_text = target_text
		text_label.clear()
		text_label.append_text("[color=#00ff00]")
		text_label.append_text(current_text)
		text_label.append_text("[/color]")
		is_typing = false
		emit_signal("typing_complete")

func _input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("ui_accept"):
		if is_typing:
			skip_typing()
		else:
			close_popup()