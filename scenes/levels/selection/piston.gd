"""
The piston animation script.
"""

extends AnimationPlayer

@export var side = "right"
var paused := false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	# If the player pushes with a piston.
	if Input.is_action_just_pressed("action_"+side) and !paused:
		# Play the animation and the sound.
		stop()
		play(side+"_push")
		$Sound.play()
