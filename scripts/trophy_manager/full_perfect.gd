extends Node

var only_perfect := false

func init():
	owner.owner.connect("enter_level", _on_enter_level)
	owner.owner.connect("node_action", _on_action_status)
	owner.owner.connect("finished_level", _on_finished_level)

func _on_enter_level(level):
	if level == get_parent().get_meta("level"):
		only_perfect = true

func _on_action_status(action: Constants.ActionStatus):
	if action != Constants.ActionStatus.PERFECT:
		only_perfect = false

func _on_finished_level(level, _score):
	if level == get_parent().get_meta("level") and only_perfect:
		get_parent().unlock = true
