shader_type canvas_item;

uniform float flame_level: hint_range(0.0, 1.0, 0.05) = 0.0;
uniform sampler2D flame_gradient; // color ramp
uniform float width_clamping: hint_range(0.0, 0.5, 0.01) = 0.0; 
uniform sampler2D flame_distortion_texture; // texture
uniform float flame_distortion_factor: hint_range(0.0, 2.0, 0.1) = 0.0;
uniform sampler2D flame_distortion_strength; // curve

uniform float brightness: hint_range(0.0, 1.0, 0.1); // it can be use for hotness
uniform sampler2D bright_flame_gradient; // color ramp for hot fire 

uniform sampler2D distortion_texture; // texture
uniform sampler2D distortion_strength; // curve
uniform float distortion_factor: hint_range(0.0, 1.0, 0.01) = 0.0;

/// result between 0.0 and 1.0
float squircle_radius(vec2 uv) {
	// We perform a symmetry of the coordinates on the two central axes 
	// (the ordinate and abscissa lines) so that x and y are both less than 0.5.
	// All the points are therefore in the same corner
	float x = 0.5 - abs(uv.x - 0.5);
	float y = 0.5 - abs(uv.y - 0.5);
	// Draw a squircle (x^4 + y^4 = 1)
	// The strength of the flame effect depends on the quircle radius
	// For more information, see https://en.wikipedia.org/wiki/Squircle
	
	
	// 0.5946 is the maximum radius that can have a pixel 
	// 0.5946 = sqrt(sqrt(0.5^4 * 2)
	return (sqrt(sqrt(pow(0.5 - x, 4) + pow(0.5 - y, 4)))) / 0.5946;
}

// Called for every pixel the material is visible on.
void fragment() {
	if (UV.x > width_clamping && UV.x < 1.0 - width_clamping) {
		// We change the value of x so that for the selected part of the image, x is between 0.0 and 1.0
		float x = (UV.x - width_clamping) / (1. - width_clamping * 2.);
		vec2 position = vec2(x, UV.y);
		
		// distortion effect apply according to the radius of the squircle
		// more the radius is high, more the distortion effect will be high
		vec4 flame_distortion = texture(flame_distortion_texture, position);
		//vec4 flame_distortion = vec4(.5);
		float radius = squircle_radius(position);
		vec2 distorted_UV = (position
			+ flame_distortion_factor
			* texture(
				flame_distortion_strength, 
				vec2(radius)
			).r
			* 2.
			* vec2(flame_distortion.x-0.5, flame_distortion.y-0.5)
			+ vec2(flame_distortion_factor))
			/ vec2(1. + 2. * flame_distortion_factor);
		
		vec2 flame_gradient_level = vec2(1. - squircle_radius(distorted_UV));
		vec4 color = mix(
				texture(flame_gradient, flame_gradient_level), 
				texture(bright_flame_gradient, flame_gradient_level),
				brightness
			);
		vec4 distortion = texture(distortion_texture, UV);
		COLOR = mix(
			texture(
				TEXTURE,
				UV + texture(distortion_strength, vec2(radius)).r
				* distortion_factor
				* vec2(distortion.x-0.5, distortion.y-0.5)
			),
			vec4(color.r, color.g, color.b, 1), 
			color.a * flame_level
		);
		if (flame_gradient_level.x < 0.) {
			COLOR = vec4(0.);
		}
	} else {
		COLOR = vec4(0.);
	}
}