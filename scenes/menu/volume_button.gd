extends TextureButton

@export var normal_texture: Texture2D
@export var disabled_texture: Texture2D
var last_value = 1

func _on_pressed():
	if $HSlider.value == 0.0:
		$HSlider.value = last_value
	else:
		last_value = $HSlider.value
		$HSlider.value = 0.0

func _on_h_slider_value_changed(value):
	if value == 0.0: texture_normal = disabled_texture
	else: texture_normal = normal_texture
