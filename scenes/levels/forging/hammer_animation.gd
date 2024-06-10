"""
The hammer animation script.
"""

extends AnimationPlayer

var paused := false

func _process(_delta):
	# If the player is hitting with the hammer.
	if Input.is_action_just_pressed("action_main") and !paused:
		stop()
		play("hit")

func _on_beat_manager_node_pressed(_node, _time, status):

	# If it's a great action.
	if status in Constants.AVAILABLE_STATUS:
		$Sound.play()

