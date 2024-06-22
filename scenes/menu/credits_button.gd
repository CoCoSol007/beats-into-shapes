"""
The credits button script.
"""

extends TextureButton

func _on_pressed():
	# Go to the credits menu.
	SceneTransition.change_scene("res://scenes/credit_menu/credit_menu.tscn")
