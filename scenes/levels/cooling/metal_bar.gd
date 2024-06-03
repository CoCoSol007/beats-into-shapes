"""
The metal bar script for the cooling level.
"""

@tool extends BeatEvent

var start_time: float = NAN
var stop_time: float = NAN

enum Directions {LEFT=1, RIGHT=-1}
@export var direction : Directions = Directions.LEFT

# A list of textures that will be used to forge the metal bar randomly.
@export var forged_texture: Array[Texture2D]

func _ready():
	if not Engine.is_editor_hint():
		# Set a random texture.
		self.texture = forged_texture[randi() % len(forged_texture)]


func pressed(time: float, status: Constants.ActionStatus):
	# If it's a great action.
	if status in Constants.AVAILABLE_STATUS:
		# If the bar is not already being cooling.
		if is_nan(start_time): 
			# Set the start time.
			start_time = time		


func released(time: float, _status: Constants.ActionStatus):
	stop_time = time


func update(time: float):

	# While it's arriving.
	if is_nan(start_time):
		position.x = time * direction * 300 
		return

	# While it's cooling.
	if is_nan(stop_time):
		
		# Dipping annimation.
		position.y = -324 + ease(time-start_time, 0.1) * 100.

		# Cooling annimation.
		self_modulate = Color(1.0, 0.5, 0.5, 1.0).lerp(Color.WHITE, (time-start_time)/hold_length)

		# Animation when metal is too cold
		if time-start_time > hold_length:
			self_modulate = Color.WHITE.lerp(Color(0.62, 0.83, 1.0, 1.0), min((time-start_time-hold_length)*4, 1.0))
		return
	
	# While it's leaving.
	position.x = (time - (stop_time-start_time)) * direction * 300 
	position.y = -224 + ease(time-stop_time, 0.05) * -100.

