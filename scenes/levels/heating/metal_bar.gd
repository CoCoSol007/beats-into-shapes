@tool extends BeatEvent

var start_time: float = NAN
var stop_time: float = NAN

func _ready():
	if not Engine.is_editor_hint():
		position.x = 50000
		self_modulate = Color.WHITE
		modulate = Color.WHITE

func pressed(time: float, status: Constants.ActionStatus):
	if status in [Constants.ActionStatus.TOO_SOON, Constants.ActionStatus.PERFECT, Constants.ActionStatus.TOO_LATE]:
		if is_nan(start_time): start_time = time

func released(time: float, _status: Constants.ActionStatus):
	stop_time = time

func update(time: float):
	var used_time = time + 2.5
	
	var move_time = (used_time / 4.0) - 1.0
	if used_time >= 0: move_time = (used_time / 8.0) - 1.0
	if used_time >= 8.0: move_time = (used_time / 4.0) - 2.0
	position.x = -smoothsteps(move_time, 0.1) * 355.0

	var rotation_time = (used_time / 4.0) - 1.0
	if used_time >= 0 and used_time < 8.0: rotation_time = clampf(((used_time / 8.0) - 1.0) * 2.0 + 1.0, -1.0, 0.0)
	var first_ease = -(0.2 - ease(rotation_time - floor(rotation_time), 0.2) * 0.75)
	var second_ease = (0.2 - ease(rotation_time - floor(rotation_time), 0.1) * 0.75)
	rotation = first_ease + second_ease
	
	var new_start_time = min(0.0, time) if Engine.is_editor_hint() else start_time
	var now_stop_time = time if is_nan(stop_time) else stop_time
	var color_scale = (now_stop_time - new_start_time) / hold_length
	if Engine.is_editor_hint(): color_scale = min(1, color_scale)
	if not is_nan(color_scale):
		self_modulate = Color.WHITE.lerp(Color.RED, color_scale / 2.0)
