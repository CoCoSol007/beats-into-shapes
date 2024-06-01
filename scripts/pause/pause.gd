"""
The code related to the pause in the game.
"""

extends Node2D

@onready var beat_manager: BeatManager = $"../BeatManager"
var paused: bool = false;

func _process(_delta):
	if Input.is_action_just_pressed("pause"): pause()

func pause():
	if paused:
		for child in get_children(): child.hide()
		Engine.time_scale = 1
		beat_manager.paused = false
	else:
		for child in get_children(): child.show()
		Engine.time_scale = 0
		beat_manager.paused = true
	paused = !paused

func _on_quit_pressed():
	SceneTransition.change_scene("res://scenes/menu/menu.tscn")
	Engine.time_scale = 1
