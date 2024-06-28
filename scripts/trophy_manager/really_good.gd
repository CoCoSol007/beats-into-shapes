# A script that checks if `needed_perfect` perfect plus actions have been done in a row.
# If so, it unlocks the trophy.

extends Node

# The number of perfect plus actions needed to unlock the trophy.
@export var needed_perfect := 10

# The number of perfect plus actions done in a row.
var perfect_done := 0

func init():
	# Skip if the parent is not a BaseTrophy or if the trophy is already unlocked.
	var parent = get_parent()
	if (not is_instance_of(parent, BaseTrophy)) or parent.unlock:
		return
	
	# Connect the signals.
	owner.connect("enter_level", _on_enter_level)
	owner.connect("node_action", _on_action_status)

func _on_enter_level(_level):
	# Reset the number of perfect plus actions done when entering a new level.
	perfect_done = 0

func _on_action_status(action: Constants.ActionStatus):
	# Reset the number of perfect plus actions done if a non-perfect plus action is pressed.
	if action != Constants.ActionStatus.PERFECT_PLUS:
		perfect_done = 0
		return
	
	# Increment the number of perfect plus actions done.
	perfect_done += 1
	
	# Unlock the trophy if `needed_perfect` perfect plus actions have been done.
	if perfect_done >= needed_perfect:
		get_parent().unlock = true

