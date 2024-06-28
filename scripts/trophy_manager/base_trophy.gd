# This is the base class for trophies.
# It provides a default implementation for the unlocking mechanism.
class_name BaseTrophy extends Node

# Exported variables:
# - unlock: Whether the trophy is unlocked or not.
# - description: The description of the trophy. Defaults to "default description".

# The unlock variable is exported as a boolean and has a getter and setter.
# The setter updates the parent's unlocked_trophies dictionary if the trophy is unlocked.
@export var unlock := false:
	get: 
		return unlock
	set(value):
		if value:
			get_parent().unlocked_trophies = true
			unlock = true

@export var description: String = "default description"

# The init function initializes the children by calling their init function if they have one.
func init():
	for child in get_children():
		if child.has_method("init"):
			child.init()

