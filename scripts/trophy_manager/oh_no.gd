# This script checks if the player has done a full bad run on a level.
# If so, it unlocks the trophy.

extends Node

var only_bad := false # Flag to keep track of whether a full bad has been done

func init():
	# Skip if the parent is not a BaseTrophy or if the trophy is already unlocked.
	var parent = get_parent()
	if (not is_instance_of(parent, BaseTrophy)) or parent.unlock:
		return
	# Connect the signals
	owner.connect("enter_level", _on_enter_level)
	owner.connect("node_action", _on_action_status)
	owner.connect("finished_level", _on_finished_level)

func _on_enter_level(_level):
	# Set only_bad to true when entering a new level
	only_bad = true

func _on_action_status(action: Constants.ActionStatus):
	# If an action that is not bad is pressed, set only_bad to false
	if not (action in Constants.BAD_STATUS):
		only_bad = false

func _on_finished_level(_level, _score):
	# If only_bad is true, unlock the trophy
	if only_bad:
		get_parent().unlock = true

