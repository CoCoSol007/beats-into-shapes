// To use this shader, the texture should be fully white with transparency.

shader_type canvas_item;

uniform vec4 color = vec4(0.949, 0.655, 0.529, 0.3); // Base color of the element
uniform vec4 hover_color = vec4(0.949, 0.655, 0.529, 1.0); // Color when the element is hovered
uniform vec4 press_color = vec4(1.0); // Color when the element is pressed

// Hover intensity: 1.0 when hovered, 0.0 in normal state. Controlled by the program.
uniform float hover_intensity = 0.0;

// Press intensity: 1.0 when pressed, 0.0 in normal state. Controlled by the program.
uniform float press_intensity = 0.0;

void fragment() {
    // Blend the base color with the hover color based on hover intensity
    // Then blend the result with the press color based on press intensity
    COLOR *= mix(
        mix(
            color, 
            hover_color, 
            hover_intensity
        ), 
        press_color, 
        press_intensity
    );
}
