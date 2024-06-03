"""
The volume button script.
"""

extends TextureButton


@export var normal_texture: Texture2D
@export var disabled_texture: Texture2D
var last_value = 1

# Function called when the button is pressed
func _on_pressed():
	# If the slider value is 0.0, set it to the last value and set the texture to normal
	if $HSlider.value == 0.0:
		$HSlider.value = last_value
	else:
		# Otherwise, set the last value to the current value and set the slider value to 0.0
		last_value = $HSlider.value
		$HSlider.value = 0.0

# Function called when the value of the slider changes
func _on_h_slider_value_changed(value):
	# If the value is 0.0, set the texture to disabled
	if value == 0.0:
		texture_normal = disabled_texture
	else:
		# Otherwise, set the texture to normal
		texture_normal = normal_texture

