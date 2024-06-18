extends Node

@onready var title = $"../Title"
@onready var description = $"../Description"


const DIST_BETWEEN_TROPHIES = 185.0
const PAN_SENSIBILITY = 1.0
const HALF_TROPHY_SIZE = 75.0

var target := 0
var trophy_position := 0.0

func _ready():
	var i: int = 0
	for trophy in get_children():
		trophy.set_meta("base_x_position", i * DIST_BETWEEN_TROPHIES)
		var _on_trophy_pressed = func():
			trophy_pressed(i)
		trophy.connect("pressed", _on_trophy_pressed)
		trophy.position.y = -HALF_TROPHY_SIZE
		trophy.position.x = i * DIST_BETWEEN_TROPHIES  - HALF_TROPHY_SIZE
		i += 1
	_on_position_update()
	update_label()


var scrolled_last_up := false
var scrolled_last_down := false
func _input(event: InputEvent):
	if event is InputEventKey:
		if event.is_action_pressed("action_right"):
			_on_arrow_right_pressed()
		if event.is_action_pressed("action_left"):
			_on_arrow_left_pressed()
	# Handle mouse button input
	if event is InputEventMouseButton:
		# Handle scrolling down with the mouse wheel
		if event.button_index == 5:
			if !scrolled_last_up:
				change_target(true)
			scrolled_last_up = !scrolled_last_up
		# Handle scrolling up with the mouse wheel
		elif event.button_index == 4:
			if !scrolled_last_down:
				change_target(false)
			scrolled_last_down = !scrolled_last_down

func _on_arrow_right_pressed():
	change_target(false)

func _on_arrow_left_pressed():
	change_target(true)

func trophy_pressed(trophy_index: int):
	if abs(trophy_position - trophy_index) < 2.5:
		target = trophy_index

func change_target(is_movement_right: bool):
	if target > trophy_position and !is_movement_right:
		target = floor(trophy_position)
	elif target < trophy_position and is_movement_right:
		target = ceil(trophy_position)
	else:
		target += 1 if is_movement_right else -1
	target = clamp(target, 0, len(get_children()) - 1)


func _process(delta: float):
	var previous_trophy_position: float = trophy_position
	update_trohy_position(delta, target)
	if previous_trophy_position == trophy_position:
		return
	if round(previous_trophy_position) != round(trophy_position):
		update_label()
	for trophy in get_children():
		trophy.position.x = trophy.get_meta("base_x_position") - trophy_position * DIST_BETWEEN_TROPHIES - HALF_TROPHY_SIZE
	_on_position_update()

func _on_position_update():
	for trophy in get_children():
		trophy.material.set_shader_parameter("x", trophy.position.x)

func update_label():
	var child = get_child(round(trophy_position))
	if child:
		title.text = child.get_meta("title", "error").to_upper()
		description.text = child.get_meta("description", "Error")
	else:
		title.text = "ERROR"
		description.text = "Error"
		

# For more information about the formulas used here, see:
# https://www.youtube.com/watch?v=KPoeNZZ6H4s

const CONSIDER_AS_ZERO = 0.001

const f = 1.0
const z = 0.7
const r = 0.0

const k1 = z / (PI * f)
const k2 = pow(2 * PI * f, -2)
const k3 = r * z / (2 * PI * f)

var previous_target := 0.0
var trophy_pos_derivative := 0.0

func update_trohy_position(delta: float, target: float):
	var target_derivative: float = (target - previous_target) / delta
	previous_target = target
	trophy_position = trophy_position + delta * trophy_pos_derivative
	if abs(trophy_position - target) < CONSIDER_AS_ZERO and abs(trophy_pos_derivative) < CONSIDER_AS_ZERO:
		trophy_position = target
		trophy_pos_derivative = 0.0
	else:
		trophy_pos_derivative = trophy_pos_derivative + delta * (
			target + k3 * target_derivative - trophy_position - k1*trophy_pos_derivative
		) / k2


