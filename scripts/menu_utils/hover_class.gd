class_name HoverButton

var button: BaseButton # The button this hover effect is applied to

var hover_change_speed = 3.0 # Speed at which the hover effect changes
var press_change_speed = 4.0 # Speed at which the press effect changes

var _is_hover_changing := false # Flag indicating if the hover effect is changing
var _is_hover_increasing := true # Direction of the hover effect change; default value that will be overwritten
var _hover_advancement := 0.0 # Progress of the hover effect

var _is_press_changing := false # Flag indicating if the press effect is changing
var _pressed := false # Flag indicating if the button is pressed
# Progress of the press effect, ranges from 0.0 to 1.0
var press_advancement := 0.0

func init():
	# Connect button signals to the corresponding handlers
	button.connect("mouse_entered", _on_mouse_entered)
	button.connect("mouse_exited", _on_mouse_exited)
	button.connect("button_down", _on_button_down)
	button.connect("button_up", _on_button_up)

func process(delta):
	# Update hover effect if it is changing
	if _is_hover_changing:
		_hover_advancement += delta * hover_change_speed * (1.0 if _is_hover_increasing else -1.0)
		if _hover_advancement > 1.0:
			_is_hover_changing = false
			_hover_advancement = 1.0
		elif _hover_advancement < 0.0:
			_is_hover_changing = false
			_hover_advancement = 0.0
		button.material.set_shader_parameter("hover_intensity", _hover_advancement)
	
	# Update press effect if it is changing
	if _is_press_changing:
		press_advancement += delta * press_change_speed
		if _pressed:
			# Limit the press advancement to 0.5 when the button is pressed
			press_advancement = min(press_advancement, 0.5)
		button.material.set_shader_parameter("press_intensity", press_intensity(press_advancement))
		if press_advancement >= 1.0:
			_is_press_changing = false

func _on_mouse_entered():
	# Start increasing the hover effect
	_is_hover_changing = true
	_is_hover_increasing = true

func _on_mouse_exited():
	# Start decreasing the hover effect
	if _hover_advancement == 0.0:
		return
	_is_hover_changing = true
	_is_hover_increasing = false

func _on_button_down():
	# Start the press effect
	press_advancement = 0.0
	_is_press_changing = true
	_pressed = true

func _on_button_up():
	# Stop the press effect
	_pressed = false

func press_intensity(x: float):
	# Calculate the press intensity based on the press advancement
	return 1.0 - smoothstep(0.0, 1.0, 2.0 * abs(x - 0.5))
