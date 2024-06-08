shader_type canvas_item;

uniform float flame_level: hint_range(0.0, 1.0, 0.05) = 0.0; // Controls the visibility of the flames
uniform sampler2D flame_gradient; // Specifies the color gradient of the flames (alpha channel can be used)

// Controls the brightness for the flame animation, mixing between the normal and bright flame gradients
uniform float brightness: hint_range(0.0, 1.0, 0.1) = 0.0;  
uniform sampler2D bright_flame_gradient;

// Controls the shape of the flames using distortion textures
// The flame color is usually continue based on the radius from the center (0.5, 0.5)
// Flame distortion modifies each pixel's coordinates to modifie its squircle radius value
uniform sampler2D flame_distortion_texture; // Gray indicates no movement, white positive, and black negative (red and green channels can be used independently)
uniform sampler2D flame_distortion_strength; // 1D curve controlling the effect of the distortion texture based on the radius from the center
uniform float flame_distortion_factor: hint_range(0.0, 2.0, 0.1) = 0.0; // Multiplies the effect of `flame_distortion_strength`

// Similar to flame distortion but applied to the original canvas image
uniform sampler2D distortion_texture; 
uniform sampler2D distortion_strength;
uniform float distortion_factor: hint_range(0.0, 1.0, 0.01) = 0.0;

// Adjusts the width of the texture so the fire's edges match the window's edges
// Proportion of the border not taken into account
// See the image in the doc folder (width_clamping.svg) for reference
uniform float width_clamping: hint_range(0.0, 0.5, 0.01) = 0.0;

/// Returns a value between 0.0 and 1.0 representing the squircle radius.
/// The squircle is centered at (0.5, 0.5) and the radius is calculated to the given point.
float squircle_radius(vec2 point) {
    // Symmetrizes coordinates around the center axes to keep x and y within [0, 0.5]
    float x = 0.5 - abs(point.x - 0.5);
    float y = 0.5 - abs(point.y - 0.5);
    // Calculates the squircle radius (x^4 + y^4 = 1)
    // More details: https://en.wikipedia.org/wiki/Squircle
    
    // 0.5946 normalizes the radius value to between 0 and 1
	// 0.5946 = sqrt(sqrt((0.5 - 1) ^ 4  + (0.5 - 1) ^ 4)
    return (sqrt(sqrt(pow(0.5 - x, 4) + pow(0.5 - y, 4)))) / 0.5946;
}

// Called for every pixel the material is visible on
void fragment() {
    // Check if the pixel is within the clamped width
    if (UV.x > width_clamping && UV.x < 1.0 - width_clamping) {
        // Normalize x to the range [0.0, 1.0] within the clamped width
        float x = (UV.x - width_clamping) / (1.0 - 2.0 * width_clamping);
        vec2 position = vec2(x, UV.y);

        // Apply flame distortion based on the squircle radius
        vec4 flame_distortion = texture(flame_distortion_texture, position);
        float radius = squircle_radius(position);
        vec2 distorted_UV = (position
            + flame_distortion_factor
            * texture(
                flame_distortion_strength, 
                vec2(radius)
            ).r
            * 2.0
            * vec2(flame_distortion.x - 0.5, flame_distortion.y - 0.5)
            + vec2(flame_distortion_factor))
            / vec2(1.0 + 2.0 * flame_distortion_factor);

        // Adjust for user convenience (0.0 is the border, 1.0 is the center)
        vec2 flame_gradient_level = vec2(1.0 - squircle_radius(distorted_UV));
        vec4 flame_color = mix(
                texture(flame_gradient, flame_gradient_level), 
                texture(bright_flame_gradient, flame_gradient_level),
                brightness
            );

        vec4 distortion = texture(distortion_texture, UV);
        // Apply distortion to the background based on the radius
        vec4 background_color = texture(
                TEXTURE,
                UV + texture(distortion_strength, vec2(radius)).r
                * distortion_factor
                * vec2(distortion.x - 0.5, distortion.y - 0.5)
        );
        // Mix background color with flame color based on flame level and alpha
        COLOR = mix(
            background_color,
            vec4(flame_color.r, flame_color.g, flame_color.b, 1.0), 
            flame_color.a * flame_level
        );
    } else {
        // Set color to transparent if outside clamped width
        COLOR = vec4(0.0);
    }
}