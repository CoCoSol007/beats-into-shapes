extends Node

var only_bad := false

func init():
	owner.connect("enter_level", _on_enter_level)
	owner.connect("node_action", _on_action_status)
	owner.connect("finished_level", _on_finished_level)

func _on_enter_level(_level):
	only_bad = true

func _on_action_status(action: Constants.ActionStatus):
	if not (action in Constants.BAD_STATUS):
		only_bad = false

func _on_finished_level(_level, _score):
	if only_bad:
		owner.unlock = true
