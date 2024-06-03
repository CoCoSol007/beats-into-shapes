"""
All code related to the "flames" particles and sound.
"""

extends CPUParticles2D

const TARGET_VOLUME = 24
const SPEED = 0.5

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	# Smoothly increase the volume of the sound.
	if $Sound.is_playing():
		$Sound.volume_db = min($Sound.volume_db + SPEED, TARGET_VOLUME)
	else :
		$Sound.volume_db = 0
	
	# If the player is hitting with the hammer.
	if Input.is_action_just_pressed("action_main"):
		# Emit the particles.
		set_emitting(true)
		# Play the sound.
		$Sound.play()
	elif Input.is_action_just_released("action_main"):
		# Stop the particles.
		set_emitting(false)
		# Stop the sound.
		$Sound.stop()

