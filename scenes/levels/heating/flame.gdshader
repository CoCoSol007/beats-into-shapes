shader_type canvas_item;


uniform float flame_level: hint_range(0.0, 1.0, 0.05) = 0.0; // Control how much the flames are visible
uniform sampler2D flame_gradient; // flame_color of the fire (you can use the alpha value)

// The brightness is used to have 2 different colors for the fire and mix them
// It is made for animation
// The `brightness` correspond to the mix value between the normal flame gradient and the bright flame gradient
uniform float brightness: hint_range(0.0, 1.0, 0.1) = 0.;  
uniform sampler2D bright_flame_gradient;

// The flame distortion control the shape of the flames
// The flame_color of the flame is normally linear: 
//   it depends of the radius of the squircle with center the point (0.5, 0.5)
// however with flame distortion you can move each pixel to give them the value that an other pixel would have
uniform sampler2D flame_distortion_texture; // gray correpond to a 0 movement, white to a positive movement and black to a negative movement (you can use both red and green value independantly if you want)
uniform sampler2D flame_distortion_strength; // use a curve 1D. Control how much the distortion texture will have effect according to the radius of the squircle with centern the point (0.5, 0.5) (it is almost equal to the distance from the center) 
uniform float flame_distortion_factor: hint_range(0.0, 2.0, 0.1) = 0.0; // multiply the `flame_distortion_strength` by this value

// It is the same that the flame distortion but it applies on the original canvas image
uniform sampler2D distortion_texture; 
uniform sampler2D distortion_strength;
uniform float distortion_factor: hint_range(0.0, 1.0, 0.01) = 0.0;


// `width_clamping` change the width of this texture so that the right and left borders of the fire
// match the right and left borders of the window.
// It correpond to the proportion of the border that is not take account
// Look at the image in the doc folder for a schedule (name: width_clamping.svg)
uniform float width_clamping: hint_range(0.0, 0.5, 0.01) = 0.0;


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
	
	
	// 0.5946 is used to clamp the value between 0 and 1
	// 0.5946 is the maximum radius that can have a pixel 
	// 0.5946 = sqrt(sqrt((0.5 - 1) ^ 4  + (0.5 - 1) ^ 4)
	return (sqrt(sqrt(pow(0.5 - x, 4) + pow(0.5 - y, 4)))) / 0.5946;
}

// Called for every pixel the material is visible on.
void fragment() {
	// Check if we are respecting the width clamping condition
	if (UV.x > width_clamping && UV.x < 1.0 - width_clamping) {
		// We change the value of x so that for the selected part of the image, x is between 0.0 and 1.0
		float x = (UV.x - width_clamping) / (1. - width_clamping * 2.);
		vec2 position = vec2(x, UV.y);

		// distortion effect apply according to the radius of the squircle
		// more the radius is high, more the distortion effect will be high
		vec4 flame_distortion = texture(flame_distortion_texture, position);
		//vec4 flame_distortion = vec4(.5);
		float radius = squircle_radius(position);
		// To better understand this calculus look at what each param does
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

		// To make it more convenient for users (0 is the border and 1 the center)
		vec2 flame_gradient_level = vec2(1. - squircle_radius(distorted_UV));
		vec4 flame_color = mix(
				texture(flame_gradient, flame_gradient_level), 
				texture(bright_flame_gradient, flame_gradient_level),
				brightness
			);

		vec4 distortion = texture(distortion_texture, UV);
		// Apply the distortion on the background
		// To better understand this calculus look at what each param does
		vec4 background_color = texture(
				TEXTURE,
				UV + texture(distortion_strength, vec2(radius)).r
				* distortion_factor
				* vec2(distortion.x-0.5, distortion.y-0.5)
		);
		COLOR = mix(
			background_color,
			vec4(flame_color.r, flame_color.g, flame_color.b, 1), 
			flame_color.a * flame_level
		);
	} else {
		COLOR = vec4(0.);
	}
}