# Trophy unlock script
# Check if the player has done a full perfect run on a level
# If so, unlock the trophy

extends Node

# Flag to keep track of whether a full perfect has been done
var only_perfect := false

# Initialize the connections
func init():	# Skip if the parent is not a BaseTrophy or if the trophy is already unlocked.
	var parent = get_parent()
	if (not is_instance_of(parent, BaseTrophy)) or parent.unlock:
		return
	# Connect the signals
	owner.owner.connect("enter_level", _on_enter_level)
	owner.owner.connect("node_action", _on_action_status)
	owner.owner.connect("finished_level", _on_finished_level)

func _on_enter_level(level):
	# If the level matches the current level, set only_perfect to true
	if level == get_parent().get_meta("level"):
		only_perfect = true

func _on_action_status(action: Constants.ActionStatus):
	# If an action that is not perfect is pressed, set only_perfect to false
	if action != Constants.ActionStatus.PERFECT:
		only_perfect = false

func _on_finished_level(level, _score):
	# If the level matches the current level and only_perfect is true, unlock the trophy
	if level == get_parent().get_meta("level") and only_perfect:
		get_parent().unlock = true

