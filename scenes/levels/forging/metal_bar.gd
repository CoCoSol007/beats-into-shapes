@tool extends BeatEvent

@export var forged_texture: Array[Texture2D]

var pressed_time: float = NAN

func _ready():
	if not Engine.is_editor_hint():
		position.y = 0
		position.x = 5000

func pressed(time: float, status: Constants.ActionStatus):
	if status in [Constants.ActionStatus.TOO_SOON, Constants.ActionStatus.PERFECT, Constants.ActionStatus.TOO_LATE]:
		if is_nan(pressed_time): pressed_time = time

func update(time: float):
	position.x = -time * 200.0
	if not is_nan(pressed_time) and not self.texture in forged_texture:
		self.texture = forged_texture[randi() % len(forged_texture)]
		self.flip_v = false
		$Sparks.emitting = true
		
