"""
The code related to the pause in the game.
"""

extends Node2D

@onready var pause_affected_script = $"../PauseAffectedScript"
@export var camera_effects = true;

var paused: bool = false

func _process(_delta):
	if Input.is_action_just_pressed("pause"): pause()

func pause():
	if not $Animation.is_playing():
		paused = !paused
		if paused:
			for child in get_children(): 
				if child.name != "Animation":
					child.show()
			$Animation.play("Spawn")
		else:
			$Animation.play("Despawn")
			await $Animation.animation_finished
			for child in get_children(): 
				if child.name != "Animation":
					child.hide()
		for child in pause_affected_script.get_children():
			if child.paused != null: 
				child.paused = paused
 
func _on_quit_pressed():
	SceneTransition.change_scene("res://scenes/menu/menu.tscn")

func _on_check_box_toggled(toggled_on):
	camera_effects = toggled_on
	
