"""
The trophies button script.
"""

extends TextureButton

func _on_pressed():
	SceneTransition.change_scene("res://scenes/trophy_menu/trophy_menu.tscn")

func _ready():	
	material.set_shader_parameter("is_hover", false)

func _on_mouse_entered():
	material.set_shader_parameter("is_hover", true)

func _on_mouse_exited():
	material.set_shader_parameter("is_hover", false)
