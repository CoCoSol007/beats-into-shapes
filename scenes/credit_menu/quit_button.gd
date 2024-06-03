"""
The quit button script.
"""

extends Button

func _on_pressed():
	# Go back to the menu.
	SceneTransition.change_scene("res://scenes/menu/menu.tscn")
