extends AudioStreamPlayer


func _on_beat_manager_node_pressed(_node, _time, status):
	if status in [Constants.ActionStatus.TOO_SOON, Constants.ActionStatus.PERFECT, Constants.ActionStatus.TOO_LATE]:
		stop()
		play()

func _on_beat_manager_node_released(_node, _time, _status):
	stop()
