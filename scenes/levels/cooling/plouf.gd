"""
sripts related to the "plouf" sound effect.
"""

extends AudioStreamPlayer

func _on_beat_manager_node_pressed(_node, _time, status):
	# If it's a great action.
	if status in Constants.AVAILABLE_STATUS:
		play()

func _on_beat_manager_node_released(_node, _time, _status):
	stop()
