extends HSlider

@onready var bus := AudioServer.get_bus_index("Master")
@export var default_value: float = 0.5

var sound_volume: SavedVolume = SavedVolume.new()

func _ready():
	""" Load the last volume in the save files. """
	if ResourceLoader.exists("user://volume.res"):
		sound_volume = ResourceLoader.load("user://volume.res")
	value = sound_volume.volume

func _on_value_changed(new_value):
	# Set the bus volume to the new value
	AudioServer.set_bus_volume_db(bus, linear_to_db(new_value))
	sound_volume.volume = value
	ResourceSaver.save(sound_volume, "user://volume.res")
