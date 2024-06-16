shader_type canvas_item;

// Position of the leftmost displayed trophy
const float min_x = -445.0;
// Position of the rightmost displayed trophy
const float max_x = 445.0;
const float center_x = (min_x + max_x) / 2.0;
const float max_dist = (max_x - min_x) / 2.0;
// Size of the trophy image in pixels
uniform float scale = 150.0;
// Position of the trophy
uniform float x;
// Set to 1.0 if the trophy is locked, otherwise set to 0.0
// When the trophy is locked, it appears in black
uniform float is_lock = 0.0;
uniform sampler2D transparency_curve;


void fragment() {
	// Adjust the alpha channel based on the transparency curve
	COLOR.a *= step(1.5, COLOR.r + COLOR.g + COLOR.b)
		 * texture(
			transparency_curve, 
			vec2(smoothstep(
				0.0, 
				1.0, 
				abs(x + (UV.x - 0.5) * scale - center_x) / max_dist
			))
		).r;
	COLOR.rgb = mix(
		COLOR.rgb,
		vec3(0.0),
		is_lock
	);
}
