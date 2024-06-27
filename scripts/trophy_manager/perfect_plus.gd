# Check if `needed_pefect` perfect plus have been done in a row

extends Node

@export var needed_pefect := 10
var perfect_done := 0

func init():
	owner.connect("enter_level", _on_enter_level)
	owner.connect("node_action", _on_action_status)

func _on_enter_level(_level):
	perfect_done = 0

func _on_action_status(action: Constants.ActionStatus):
	if action != Constants.ActionStatus.PERFECT_PLUS:
		perfect_done = 0
		return
	perfect_done += 1
	if perfect_done >= needed_pefect:
		get_parent().unlock = true
