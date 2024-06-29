class_name TrophiesDisplayer extends Control

@onready var title = $"../Title" # Reference to the title label
@onready var description = $"../Description" # Reference to the description label

const DIST_BETWEEN_TROPHIES = 185.0 # Distance between the center of each trophy
const TROPHY_SIZE = 150 # Size of each trophy in pixels
const HALF_TROPHY_SIZE = TROPHY_SIZE / 2.0

var hover_manager = HoverManager.new() # Instance of the HoverManager class to manage hover effects

var target := 0 # Target index for the trophy position
var trophy_position := 0.0 # Current position of the trophy

func _ready():
	# Initialize the trophies and set their positions
	var i: int = 0
	for trophy in get_children():
		trophy.set_meta("base_x_position", i * DIST_BETWEEN_TROPHIES)
		var _on_trophy_pressed = func():
			trophy_pressed(i)
		trophy.connect("pressed", _on_trophy_pressed)
		trophy.position.y = -HALF_TROPHY_SIZE
		trophy.position.x = i * DIST_BETWEEN_TROPHIES - HALF_TROPHY_SIZE
		i += 1
	_on_position_update()
	update_label()
	hover_manager.self_ = self
	hover_manager._ready()

var scrolled_last_up := false # Track the last scroll direction up
var scrolled_last_down := false # Track the last scroll direction down

func _input(event: InputEvent):
	# Handle keyboard input for right and left arrow keys
	if event is InputEventKey:
		if event.is_action_pressed("action_right"):
			_on_arrow_right_pressed()
		if event.is_action_pressed("action_left"):
			_on_arrow_left_pressed()
	# Handle mouse button input for scrolling
	if event is InputEventMouseButton:
		if event.button_index == 5: # Mouse wheel scrolled down
			if !scrolled_last_up:
				change_target(true)
			scrolled_last_up = !scrolled_last_up
		elif event.button_index == 4: # Mouse wheel scrolled up
			if !scrolled_last_down:
				change_target(false)
			scrolled_last_down = !scrolled_last_down

func _on_arrow_right_pressed():
	# Change target to the right
	change_target(true)

func _on_arrow_left_pressed():
	# Change target to the left
	change_target(false)

func trophy_pressed(trophy_index: int):
	# Set the target to the pressed trophy if it is visible (close enough to the current position)
	if abs(trophy_position - trophy_index) < 2.5:
		target = trophy_index

func change_target(is_movement_right: bool):
	# Adjust the target index based on the direction of movement
	if target > trophy_position and !is_movement_right:
		target = floor(trophy_position)
	elif target < trophy_position and is_movement_right:
		target = ceil(trophy_position)
	else:
		target += 1 if is_movement_right else -1
	target = clamp(target, 0, len(get_children()) - 1) # Clamp the target within the valid range

func _process(delta: float):
	# Process hover effects and update trophy positions
	hover_manager._process(delta)

	var previous_trophy_position: float = trophy_position
	update_trohy_position(delta, target)
	if previous_trophy_position == trophy_position:
		return
	if round(previous_trophy_position) != round(trophy_position):
		update_label()
	var mouse_position = get_viewport().get_mouse_position()
	for trophy in get_children():
		var new_x_position: float = trophy.get_meta("base_x_position") - trophy_position * DIST_BETWEEN_TROPHIES - HALF_TROPHY_SIZE
		trophy.position.x = new_x_position
		# Check if the mouse is hovering over the trophy
		if position.y - HALF_TROPHY_SIZE < mouse_position.y and mouse_position.y < position.y + HALF_TROPHY_SIZE and (
			new_x_position + position.x < mouse_position.x and mouse_position.x < new_x_position + TROPHY_SIZE + position.x
		):
			trophy.emit_signal("mouse_entered")
		else:
			trophy.emit_signal("mouse_exited")
	_on_position_update()

func _on_position_update():
	# Update the x position shader parameter for each trophy
	for trophy in get_children():
		trophy.material.set_shader_parameter("x", trophy.position.x)

func update_label():
	# Update the title and description labels based on the current trophy
	var child = get_child(round(trophy_position))
	if child:
		title.text = child.name.to_upper()
		description.text = child.get_meta("description", "Error")
	else:
		title.text = "ERROR"
		description.text = "Error"


# For more information about the formulas used here, see:
# https://www.youtube.com/watch?v=KPoeNZZ6H4s

const CONSIDER_AS_ZERO = 0.001 # Threshold to consider a value as zero

const f = 1.0 # Natural frequency
const z = 0.7 # Damping ratio
const r = 0.0 # Resonance

const k1 = z / (PI * f)
const k2 = pow(2 * PI * f, -2)
const k3 = r * z / (2 * PI * f)

var previous_target := 0.0 # Previous target position
var trophy_pos_derivative := 0.0 # Derivative of the trophy position

func update_trohy_position(delta: float, target: float):
	# Update the position of the trophy using a spring-damper system
	var target_derivative: float = (target - previous_target) / delta
	previous_target = target
	trophy_position = trophy_position + delta * trophy_pos_derivative
	if abs(trophy_position - target) < CONSIDER_AS_ZERO and abs(trophy_pos_derivative) < CONSIDER_AS_ZERO:
		trophy_position = target
		trophy_pos_derivative = 0.0
	else:
		trophy_pos_derivative = trophy_pos_derivative + delta * (
			target + k3 * target_derivative - trophy_position - k1 * trophy_pos_derivative
		) / k2
