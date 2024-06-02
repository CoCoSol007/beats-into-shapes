extends AnimationPlayer

func _process(_delta):
	if Input.is_action_just_pressed("action_main"):
		stop()
		play("hit")

func _on_beat_manager_node_pressed(_node, _time, status):
	match status:
		Constants.ActionStatus.TOO_SOON: $Sound.play()
		Constants.ActionStatus.PERFECT: $Sound.play()
		Constants.ActionStatus.TOO_LATE: $Sound.play()

	if status in [Constants.ActionStatus.TOO_SOON, Constants.ActionStatus.PERFECT, Constants.ActionStatus.TOO_LATE]:
		$Sound.play()

