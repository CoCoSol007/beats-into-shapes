extends HSlider

@onready var bus := AudioServer.get_bus_index("Master")

func _ready():
	value = 0.5

func _on_value_changed(new_value):
	AudioServer.set_bus_volume_db(bus, linear_to_db(new_value))
