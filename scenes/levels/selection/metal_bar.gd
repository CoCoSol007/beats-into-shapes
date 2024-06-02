@tool extends BeatEvent

enum ConveyorSide {LEFT, RIGHT}

@export var conveyor_side: ConveyorSide = ConveyorSide.LEFT
@export var conveyor_timing: float = 2.0
@export var conveyor_spacing: float = 200.0
@export var is_linear: bool = false

var base_scale: float = 1.0
var rotation_direction: float = 0.0
var pressed_time: float = NAN

func _ready():
	if not Engine.is_editor_hint():
		position.y = -5000
		base_scale = scale.x
		rotation_direction = randi_range(0, 1)
		if rotation_direction == 0: rotation_direction = -1

func pressed(time: float, status: Constants.ActionStatus):
	if status in [Constants.ActionStatus.TOO_SOON, Constants.ActionStatus.PERFECT, Constants.ActionStatus.TOO_LATE]:
		if is_nan(pressed_time): pressed_time = time

func update(time: float):
	var used_time = time if is_nan(pressed_time) else pressed_time
	if is_linear:
		position.y = (used_time) * conveyor_spacing + 200.0
	else:
		position.y = smoothsteps((used_time + 0.125 * conveyor_timing) / conveyor_timing, 0.2) * conveyor_spacing - (conveyor_spacing / 2.0) + 200.0
	match conveyor_side:
		ConveyorSide.LEFT: position.x = -180
		ConveyorSide.RIGHT: position.x = 180
	if not is_nan(pressed_time) and time - pressed_time > -10.0:
		position.y = lerp(position.y, 198.0, min(1, (time - pressed_time) * 2.0))
		position.x += (ease(time - pressed_time, 0.25) * sign(position.x)) * 227.0
		rotation = (time - pressed_time) * rotation_direction
		scale.x = clamp(base_scale - (time - pressed_time) / 5.0, 0.0, 1.0)
		scale.y = scale.x
		z_index = max(RenderingServer.CANVAS_ITEM_Z_MIN, -int(1.0 / scale.x))
