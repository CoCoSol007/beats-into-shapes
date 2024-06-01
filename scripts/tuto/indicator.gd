class_name Indicator extends Sprite2D

@export var press_key: Constants.ActionKey = Constants.ActionKey.UNBOUND
@export var unpressed_texture: Texture2D
@export var pressed_texture: Texture2D
@export var direction: Vector2 = Vector2.UP
@export var line_offset: Vector2 = Vector2(0, 25)
@export var line_scale: float = 300

var bonus_line_length: float = 0.0

var pressed:
	get: return null
	set(value):
		if value: texture = pressed_texture
		else: texture = unpressed_texture

var remaining_time:
	get: return null
	set(value):
		$Line2D.set_point_position(1, direction * max(0.0, value) * line_scale + line_offset)
		$Line2D2.set_point_position(1, direction * max(0.0, value + bonus_line_length) * line_scale + line_offset)
		if value < 0.0: value = max(0.0, bonus_line_length + value)
		if value == 0.0: $Label.text = ""
		else: $Label.text = "%.1f" % value
