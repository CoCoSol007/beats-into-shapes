"""
Scrollable menu control
Allows scrolling through the menu with input events
"""

extends Control

const PAN_SENSIBILITY = 100.0
var target_position_y: float
@export var scroll_speed: int = 75

# Called when the node enters the scene tree for the first time.
func _ready() :
	# Set the target position to the current position of the menu
	target_position_y = $Control.position.y

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float):
	# Smoothly scroll the menu to the target position
	if target_position_y == 0 or target_position_y == -648:
		$Control.position.y = lerp($Control.position.y, target_position_y, 0.125) 
	$Control.position.y = lerp($Control.position.y, target_position_y, 0.1) 

# Called when an input event is received.
func _input(event: InputEvent):
	# Handle pan gesture input
	if event is InputEventPanGesture:
		# Update the target position based on the pan gesture
		target_position_y = $Control.position.y - event.delta.y * PAN_SENSIBILITY
		# Clamp the target position to the scrollable range
		target_position_y = clamp(target_position_y, -648, 0)
	# Handle mouse button input
	elif event is InputEventMouseButton:
		# Handle scrolling up with the mouse wheel
		if event.button_index == 4:
			target_position_y = target_position_y + scroll_speed
			target_position_y = clamp(target_position_y, -648, 0)
		# Handle scrolling down with the mouse wheel
		elif event.button_index == 5:
			target_position_y = target_position_y - scroll_speed
			target_position_y = clamp(target_position_y, -648, 0)

