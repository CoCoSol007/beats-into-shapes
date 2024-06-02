extends CPUParticles2D

const TARGET_VOLUME = 24
const SPEED = 0.5

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if $Sound.is_playing():
		$Sound.volume_db = min($Sound.volume_db + SPEED, TARGET_VOLUME)
	else :
		$Sound.volume_db = 0
		
	if Input.is_action_just_pressed("action_main"):
		set_emitting(true)
		$Sound.play()
	elif Input.is_action_just_released("action_main"):
		set_emitting(false)
		$Sound.stop()

