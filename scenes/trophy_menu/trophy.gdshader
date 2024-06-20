shader_type canvas_item;

// Position of the leftmost displayed trophy
const float min_x = -445.0;
// Position of the rightmost displayed trophy
const float max_x = 445.0;
const float center_x = (min_x + max_x) / 2.0;
const float max_dist = (max_x - min_x) / 2.0;

// Size of the trophy image in pixels
uniform float scale = 150.0;

// Position of the trophy, should be updated when the trophy moves
uniform float x;

// Transparency of the trophy based on its distance from the center (`center_x`)
uniform sampler2D transparency_curve;

// Set to 1.0 if the trophy is locked, otherwise set to 0.0
// When the trophy is locked, it appears in black
uniform float is_locked = 0.0;

// Brightness multiplier when the element is hovered
uniform float hover_brightness = 0.9;

// Scale multiplier when the element is pressed
// This value must be different from 0.0
uniform float press_scale = 0.8;

// Hover intensity: 1.0 when hovered, 0.0 in normal state. Controlled by the program.
uniform float hover_intensity = 0.0;

// Press intensity: 1.0 when pressed, 0.0 in normal state. Controlled by the program.
uniform float press_intensity = 0.0;

void fragment() {
	// Calculate the effect of pressing on the scale
	float scale_effect = mix(1.0, 1.0 / press_scale, press_intensity);
	
	// Adjust the position of the pixel according to the scale effect
	vec2 pos = vec2(UV.x, UV.y) * scale_effect + vec2((1.0 - scale_effect) * 0.5);
	
	// Sample the base texture color
	COLOR = texture(TEXTURE, pos);
	
	// Adjust the alpha channel based on the transparency curve and the trophy's position
	COLOR.a *= texture(
		transparency_curve, 
		vec2(smoothstep(
			0.0, 
			1.0, 
			abs(x + pos.x * scale - center_x) / max_dist
		))
	).r;
	
	// Adjust the color for locked state and hover state
	COLOR.rgb = mix(
		COLOR.rgb, 
		vec3(0.0), 
		is_locked
	) * mix(
		1.0, 
		hover_brightness, 
		hover_intensity
	);
}
