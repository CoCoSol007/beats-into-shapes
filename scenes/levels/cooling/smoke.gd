extends CPUParticles2D


func _on_beat_manager_node_pressed(node, _time, status):
	emitting = false
	position.x = node.position.x
	match status:
		Constants.ActionStatus.TOO_SOON: emitting = true
		Constants.ActionStatus.PERFECT: emitting = true
		Constants.ActionStatus.TOO_LATE: emitting = true

func _on_beat_manager_node_released(_node, _time, _status):
	emitting = false
