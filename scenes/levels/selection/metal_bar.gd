"""
The metal bar script for the selection level.
"""

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
		base_scale = scale.x
		# Randomize the rotation direction between -1.0 and 1.0.
		rotation_direction = randi_range(0, 1) * 2.0 - 1.0

func pressed(time: float, status: Constants.ActionStatus):
	# If it's a great action.
	if status in Constants.AVAILABLE_STATUS:
		# If the bar is not already being selected.
		if is_nan(pressed_time): 
			# Set the start time.
			pressed_time = time

func update(time: float):
	# Determine the time to be used based on whether the bar is being selected or not.
	var used_time = time if is_nan(pressed_time) else pressed_time
	
	# Calculate the new position of the bar based on the used time.
	# If the bar is linear, the position.y is calculated directly.
	# Otherwise, a smoothstep function is used to calculate the position.y.
	if is_linear:
		position.y = (used_time) * conveyor_spacing + 200.0
	else:
		position.y = smoothsteps((used_time + 0.125 * conveyor_timing) / conveyor_timing, 0.2) * conveyor_spacing - (conveyor_spacing / 2.0) + 200.0
	
	# Set the position.x of the bar based on the conveyor_side.
	match conveyor_side:
		ConveyorSide.LEFT: position.x = -180
		ConveyorSide.RIGHT: position.x = 180
	
	# If the bar is being selected, update its position, rotation, and scale.
	if not is_nan(pressed_time) and time - pressed_time > -10.0:
		# Calculate the new position.y of the bar.
		position.y = lerp(position.y, 198.0, min(1, (time - pressed_time) * 2.0))
		
		# Calculate the new position.x of the bar.
		position.x += (ease(time - pressed_time, 0.25) * sign(position.x)) * 227.0
		
		# Calculate the new rotation of the bar.
		rotation = (time - pressed_time) * rotation_direction
		
		# Calculate the new scale.x of the bar.
		scale.x = clamp(base_scale - (time - pressed_time) / 5.0, 0.0, 1.0)
		
		# Set the scale.y of the bar to the same value as scale.x.
		scale.y = scale.x
		
		# Set the z_index of the bar based on its scale.x.
		z_index = max(RenderingServer.CANVAS_ITEM_Z_MIN, -int(1.0 / scale.x))

