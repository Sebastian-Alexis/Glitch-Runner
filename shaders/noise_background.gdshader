shader_type canvas_item;

// Uniforms for controlling the noise effect
uniform float noise_intensity : hint_range(0.0, 1.0) = 0.05; // How visible the noise is
uniform float noise_scale : hint_range(1.0, 100.0) = 50.0; // Scale of the noise pattern
uniform float time_scale : hint_range(0.0, 10.0) = 2.0; // Speed of animation
uniform vec3 noise_color = vec3(1.0, 1.0, 1.0); // Color of the noise (white to green)
uniform float color_mix : hint_range(0.0, 1.0) = 0.0; // Mix between base and noise color

// Simple pseudo-random function
float random(vec2 st) {
    return fract(sin(dot(st.xy, vec2(12.9898, 78.233))) * 43758.5453123);
}

// 2D noise function
float noise(vec2 st) {
    vec2 i = floor(st);
    vec2 f = fract(st);
    
    // Four corners in 2D of a tile
    float a = random(i);
    float b = random(i + vec2(1.0, 0.0));
    float c = random(i + vec2(0.0, 1.0));
    float d = random(i + vec2(1.0, 1.0));
    
    // Smooth interpolation
    vec2 u = f * f * (3.0 - 2.0 * f);
    
    // Mix the four corners
    return mix(a, b, u.x) +
            (c - a) * u.y * (1.0 - u.x) +
            (d - b) * u.x * u.y;
}

void fragment() {
    // Get the base color (should be dark background)
    vec4 base_color = texture(TEXTURE, UV);
    
    // Calculate animated noise
    vec2 st = UV * noise_scale;
    st.x += TIME * time_scale * 0.1;
    st.y += TIME * time_scale * 0.15;
    
    // Generate multi-octave noise for more organic look
    float n = 0.0;
    n += noise(st) * 0.5;
    n += noise(st * 2.0) * 0.25;
    n += noise(st * 4.0) * 0.125;
    n += noise(st * 8.0) * 0.0625;
    
    // Add some flickering
    n *= (1.0 + sin(TIME * 10.0) * 0.1);
    
    // Mix the noise color
    vec3 final_noise_color = mix(vec3(1.0), noise_color, color_mix);
    
    // Apply noise to the base color
    vec3 final_color = base_color.rgb + (final_noise_color * n * noise_intensity);
    
    // Output
    COLOR = vec4(final_color, base_color.a);
}