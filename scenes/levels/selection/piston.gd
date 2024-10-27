"""
The piston animation script.
"""

extends AnimationPlayer

@export var side = "right"
var paused := false

var screen_middle = ProjectSettings.get("display/window/size/viewport_width")/2

func push(side):
	# Play the animation and the sound.
	stop()
	play(side+"_push")
	$Sound.play()

func _input(event):
	if !paused:
		if event is InputEventScreenTouch and event.is_pressed():
			if event.position.x > screen_middle:
				if side == "right":
					push("right") 
			else:
				if side == "left":
					push("left")
		elif not DisplayServer.is_touchscreen_available() and event.is_action_pressed("action_"+side):
			push(side)
	
