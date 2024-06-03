"""
The metal bar script for the heating level.
"""

@tool extends BeatEvent

var start_time: float = NAN
var stop_time: float = NAN

func _ready():
	if not Engine.is_editor_hint():
		# Set the default color.
		self_modulate = Color.WHITE

func pressed(time: float, status: Constants.ActionStatus):
	# If it's a great action.
	if status in Constants.AVAILABLE_STATUS:
		# If the bar is not already being heated.
		if is_nan(start_time): 
			# Set the start time. 
			start_time = time

func released(time: float, _status: Constants.ActionStatus):
	stop_time = time

func update(time: float):
	# Fix the offset of the animation.
	var used_time = time + 2.5
	
	# Move animation.
	var move_time = (used_time / 4.0) - 1.0
	# Before heating
	if used_time >= 0: move_time = (used_time / 8.0) - 1.0
	# After heating
	if used_time >= 8.0: move_time = (used_time / 4.0) - 2.0
	# Update the position
	position.x = -smoothsteps(move_time, 0.1) * 355.0

	# Calculate the rotation time based on the used time.
	var rotation_time = (used_time / 4.0) - 1.0
	# If the bar is moving, calculate the rotation time.
	if used_time >= 0 and used_time < 8.0:
		rotation_time = clampf(((used_time / 8.0) - 1.0) * 2.0 + 1.0, -1.0, 0.0)
	# Calculate the first ease value.
	var first_ease = -(0.2 - ease(rotation_time - floor(rotation_time), 0.2) * 0.75)
	# Calculate the second ease value.
	var second_ease = (0.2 - ease(rotation_time - floor(rotation_time), 0.1) * 0.75)
	# Calculate the final rotation by adding the first and second ease values.
	rotation = first_ease + second_ease
	
	# Update the color.
	# If it's in the editor, limit the color_scale to 1.
	# If it's not in the editor, calculate the color_scale based on the time.
	var new_start_time = min(0.0, time) if Engine.is_editor_hint() else start_time
	var now_stop_time = time if is_nan(stop_time) else stop_time
	var color_scale = (now_stop_time - new_start_time) / hold_length
	if Engine.is_editor_hint(): color_scale = min(1, color_scale)
	if not is_nan(color_scale):
		# Calculate the new color by interpolating between white and red based on the color_scale.
		self_modulate = Color.WHITE.lerp(Color.RED, color_scale / 2.0)

