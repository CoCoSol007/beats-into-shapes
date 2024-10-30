"""
The close button script.
"""

extends TextureButton

func _on_pressed():
	# Close the game.
	print("Goodbye friends!")
	get_tree().quit()
