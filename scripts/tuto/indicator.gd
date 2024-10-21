class_name Indicator extends Sprite2D

@export var press_key: Constants.ActionKey = Constants.ActionKey.UNBOUND
@export var unpressed_texture: Texture2D
@export var pressed_texture: Texture2D
@export var direction: Vector2 = Vector2.UP
@export var line_offset: Vector2 = Vector2(0, 25)
@export var line_scale: float = 300

var bonus_line_length: float = 0.0

# The current state of the indicator.
var pressed:
	get: return null
	# Sets the state of the indicator to pressed or unpressed.
	set(value):
		# If the indicator is pressed, use the pressed texture,
		# otherwise use the unpressed texture.
		if value: texture = pressed_texture
		else: texture = unpressed_texture

# The remaining time of the indicator.
var remaining_time:
	get: return null
	# Sets the remaining time of the indicator.
	set(value):
		# Updates the first line of the indicator.
		$Line2D.set_point_position(1, direction * max(0.0, value) * line_scale + line_offset)
		# Updates the second line of the indicator.
		$Line2D2.set_point_position(1, direction * max(0.0, value + bonus_line_length) * line_scale + line_offset)
		
		# If the remaining time is negative, the bonus line is added to the remaining time.
		# If the remaining time is zero, the label is set to an empty string.
		# Otherwise, the label is set to the remaining time rounded to one decimal place.
		if value < 0.0: value = max(0.0, bonus_line_length + value)
		if value == 0.0: $Label.text = ""
		else: $Label.text = "%.1f" % value
