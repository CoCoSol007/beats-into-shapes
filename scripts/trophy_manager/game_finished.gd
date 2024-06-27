extends Node


func _on_finished_level(level, score):
	if level == 3 and score > 0:
		get_parent().unlock = true
