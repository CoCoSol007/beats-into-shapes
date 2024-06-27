class_name BaseTrophy extends Node

@export var unlock := false:
	get: 
		return unlock
	set(value):
		if value:
			get_parent().unlocked_trophies = true
			unlock = true
@export var descritption: String = "default description"

func init():
	for child in get_children():
		if child.has_method("init"):
			child.init()
