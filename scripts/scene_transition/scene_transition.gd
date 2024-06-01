"""
The script to launch smooth scene transitions.
"""

extends CanvasLayer

func change_scene(target: String):
	# play the animation.
	$Animation.play("hit")
	await $Animation.animation_finished

	# Change the scene.
	get_tree().change_scene_to_file(target)

	$Animation.play("remove")
