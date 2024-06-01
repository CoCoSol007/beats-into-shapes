extends AudioStreamPlayer

@onready var last_time = Time.get_ticks_usec() / 1000000.0

func _process(_d):
	var now := Time.get_ticks_usec() / 1000000.0
	var delta = now - last_time
	last_time = now
	
	var in_menu = false
	for node in get_tree().get_nodes_in_group("menu"):
		if node.visible:
			in_menu = true
			break
	var target = 1.0 if in_menu else 0.0
	var volume = db_to_linear(volume_db)
	volume = lerp(volume, target, 1 - pow(0.1, delta))
	volume_db = linear_to_db(volume)
