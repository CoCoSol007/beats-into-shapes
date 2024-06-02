extends AnimationPlayer

@export var side = "right"

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if Input.is_action_just_pressed("action_"+side):
		stop()
		play(side+"_push")
		$Sound.play()
