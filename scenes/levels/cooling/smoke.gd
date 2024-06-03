"""
All code related to the "smoke" particles.
"""

extends CPUParticles2D


func _on_beat_manager_node_pressed(node, _time, status):
	# Set the position under the metal bar.
	position.x = node.position.x

	# If it's a great action.
	if status in Constants.AVAILABLE_STATUS:
		emitting = true

func _on_beat_manager_node_released(_node, _time, _status):
	emitting = false
