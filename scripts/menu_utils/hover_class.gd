class_name HoverButton

var button: BaseButton

var hover_change_speed = 3.0
var press_change_speed = 4.0

var _is_hover_changing := false
var _is_hover_increasing := true # Default value that will always be overwritten
var _hover_advancement := 0.0

var _is_press_changing := false
var _pressed := false
# Ranges from 0.0 to 1.0
var press_advancement := 0.0

func init():
	button.connect("mouse_entered", _on_mouse_entered)
	button.connect("mouse_exited", _on_mouse_exited)
	button.connect("button_down", _on_button_down)
	button.connect("button_up", _on_button_up)

func process(delta):
	# Update hover effect if changing
	if _is_hover_changing:
		_hover_advancement += delta * hover_change_speed * (1.0 if _is_hover_increasing else -1.0)
		if _hover_advancement > 1.0:
			_is_hover_changing = false
			_hover_advancement = 1.0
		elif _hover_advancement < 0.0:
			_is_hover_changing = false
			_hover_advancement = 0.0
		button.material.set_shader_parameter("hover_intensity", _hover_advancement)
	
	# Update press effect if changing
	if _is_press_changing:
		press_advancement += delta * press_change_speed
		if _pressed:
			# The press advancement should be at most 0.5 when the button is _pressed
			press_advancement = min(press_advancement, 0.5)
		button.material.set_shader_parameter("press_intensity", press_intensity(press_advancement))
		if press_advancement >= 1.0:
			_is_press_changing = false

func _on_mouse_entered():
	# Start hover increasing effect
	_is_hover_changing = true
	_is_hover_increasing = true

func _on_mouse_exited():
	# Start hover decreasing effect
	_is_hover_changing = true
	_is_hover_increasing = false

func _on_button_down():
	# Start press effect
	press_advancement = 0.0
	_is_press_changing = true
	_pressed = true

func _on_button_up():
	# Stop press effect
	_pressed = false

func press_intensity(x: float):
	# Calculate the press intensity based on the press advancement
	return 1.0 - smoothstep(0.0, 1.0, 2.0 * abs(x - 0.5))
