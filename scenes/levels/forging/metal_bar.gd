"""
The metal bar script for the forging level.
"""

@tool extends BeatEvent

# A list of textures that will be used to forge the metal bar randomly.
@export var forged_texture: Array[Texture2D]

var pressed_time: float = NAN

func _ready():
	if not Engine.is_editor_hint():
		# Set the position as default.
		position.y = 0

func pressed(time: float, status: Constants.ActionStatus):
	# If it's a great action.
	if status in Constants.AVAILABLE_STATUS:
		# If the bar is not already being forged.
		if is_nan(pressed_time): 
			# Set the start time.
			pressed_time = time

func update(time: float):

	# Move it to the left.
	position.x = -time * 200.0

	# If it's not being forged.
	if not is_nan(pressed_time) and not self.texture in forged_texture:

		# Set a random texture.
		self.texture = forged_texture[randi() % len(forged_texture)]
		self.flip_v = false
		$Sparks.emitting = true
		
