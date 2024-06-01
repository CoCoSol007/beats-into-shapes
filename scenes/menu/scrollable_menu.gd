extends Control

var target_position_y: float
@export var scroll_speed: int = 75

func _ready() -> void:
	target_position_y = $Control.position.y

func _input(event: InputEvent) -> void:
	if event is InputEventPanGesture:
		target_position_y = $Control.position.y - event.delta.y * 100
		target_position_y = clamp(target_position_y, -648, 0)
	elif event is InputEventMouseButton:
		if event.button_index == 4:
			target_position_y = target_position_y + scroll_speed
			target_position_y = clamp(target_position_y, -648, 0)
		elif event.button_index == 5:
			target_position_y = target_position_y - scroll_speed
			target_position_y = clamp(target_position_y, -648, 0)

func _process(_delta: float) -> void:
	if target_position_y == 0 or target_position_y == -648:
		$Control.position.y = lerp($Control.position.y, target_position_y, 0.125) 
	$Control.position.y = lerp($Control.position.y, target_position_y, 0.1) 
