extends HSlider

@onready var bus := AudioServer.get_bus_index("Master")
@export var default_value: float = 0.5

func _ready():
	value = default_value

func _on_value_changed(new_value):
	# Set the bus volume to the new value
	AudioServer.set_bus_volume_db(bus, linear_to_db(new_value))
