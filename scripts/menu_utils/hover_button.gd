extends Node

var child: BaseButton

var is_hover_changing := false
var is_hover_increasing := true # Default value that will always be overwritten
var hover_advancement := 0.0
@export var hover_change_speed = 3.0

var is_press_changing := false
var pressed := false
# Ranges from 0.0 to 1.0
var press_advancement := 0.0
@export var press_change_speed = 4.0

func _ready():
	child = get_child(0)
	child.connect("mouse_entered", _on_mouse_entered)
	child.connect("mouse_exited", _on_mouse_exited)
	child.connect("button_down", _on_button_down)
	child.connect("button_up", _on_button_up)

func _process(delta):
	# Update hover effect if changing
	if is_hover_changing:
		hover_advancement += delta * hover_change_speed * (1.0 if is_hover_increasing else -1.0)
		child.material.set_shader_parameter("hover_intensity", smoothstep(0.0, 1.0, hover_advancement))
		if hover_advancement > 1.0:
			is_hover_changing = false
			hover_advancement = 1.0
		elif hover_advancement < 0.0:
			is_hover_changing = false
			hover_advancement = 0.0
	
	# Update press effect if changing
	if is_press_changing:
		press_advancement += delta * press_change_speed
		if pressed:
			# The press advancement should be at most 0.5 when the button is pressed
			press_advancement = min(press_advancement, 0.5)
		child.material.set_shader_parameter("press_intensity", press_intensity(press_advancement))
		if press_advancement >= 1.0:
			is_press_changing = false

func _on_mouse_entered():
	# Start hover increasing effect
	is_hover_changing = true
	is_hover_increasing = true

func _on_mouse_exited():
	# Start hover decreasing effect
	is_hover_changing = true
	is_hover_increasing = false

func _on_button_down():
	# Start press effect
	press_advancement = 0.0
	is_press_changing = true
	pressed = true

func _on_button_up():
	# Stop press effect
	pressed = false

func press_intensity(x: float):
	# Calculate the press intensity based on the press advancement
	return 1.0 - smoothstep(0.0, 1.0, 2.0 * abs(x - 0.5))
