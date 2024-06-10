"""
The code related to the pause in the game.
"""

extends Node2D

@onready var pause_affected_script = $"../PauseAffectedScript"

var paused: bool = false

func _process(_delta):
	if Input.is_action_just_pressed("pause"): pause()

func pause():
	paused = !paused
	if paused:
		for child in get_children(): child.show()
		Engine.time_scale = 0
	else:
		for child in get_children(): child.hide()
		Engine.time_scale = 1
	for child in pause_affected_script.get_children():
		if child.paused != null: 
			child.paused = paused
 
func _on_quit_pressed():
	SceneTransition.change_scene("res://scenes/menu/menu.tscn")
	Engine.time_scale = 1
