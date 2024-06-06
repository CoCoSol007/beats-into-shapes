shader_type canvas_item;

uniform bool is_hover = false;
uniform vec3 hover_color = vec3(0.7);

// Called for every pixel the material is visible on.
void fragment() {
	if (is_hover) {
		COLOR.rgb = hover_color;
	}
}
