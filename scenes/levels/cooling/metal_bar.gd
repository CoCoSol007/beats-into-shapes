@tool extends BeatEvent

var start_time: float = NAN
var stop_time: float = NAN

enum Directions {LEFT=1, RIGHT=-1}
@export var direction : Directions = Directions.LEFT
@export var forged_texture: Array[Texture2D]

func _ready():
	if not Engine.is_editor_hint():
		position.x = 50000
		modulate = Color.WHITE
		self.texture = forged_texture[randi() % len(forged_texture)]

func pressed(time: float, status: Constants.ActionStatus):
	if status in [Constants.ActionStatus.TOO_SOON, Constants.ActionStatus.PERFECT, Constants.ActionStatus.TOO_LATE]:
		if is_nan(start_time): start_time = time
		

func released(time: float, _status: Constants.ActionStatus):
	stop_time = time

func update(time: float):
		
	if is_nan(start_time):
		position.x = time * direction * 300 
	else:
		if is_nan(stop_time):
			position.y = -324 + ease(time-start_time, 0.1) * 100.
			self_modulate = Color(1.0, 0.5, 0.5, 1.0).lerp(Color.WHITE, (time-start_time)/hold_length)
			if time-start_time > hold_length:
				self_modulate = Color.WHITE.lerp(Color(0.62, 0.83, 1.0, 1.0), min((time-start_time-hold_length)*4, 1.0))
		else :	
			position.x = (time - (stop_time-start_time)) * direction * 300 
			position.y = -224 + ease(time-stop_time, 0.05) * -100.

