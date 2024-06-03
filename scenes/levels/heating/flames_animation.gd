"""
All code related to the "flames" particles and sound.
"""

extends Node

@onready var background := $Background
@onready var animation_flames = $AnimationFlames
@onready var camera_2d = $"../Camera2D"

var noise_texture: FastNoiseLite
var flame_noise_texture: FastNoiseLite
var shader_material: ShaderMaterial

const DISTORTION_SPEED = 75.0
const FLAME_DISTORTION_SPEED = 75.0
const TARGET_VOLUME = 24
const VOLUME_SPEED = 30.

# Called when the node enters the scene tree for the first time.
func _ready():
	shader_material = background.material as ShaderMaterial
	noise_texture = shader_material.get_shader_parameter("distortion_texture").noise
	flame_noise_texture = shader_material.get_shader_parameter("flame_distortion_texture").noise


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# Smoothly increase the volume of the sound.
	if $Sound.is_playing():
		$Sound.volume_db = min($Sound.volume_db + VOLUME_SPEED * delta, TARGET_VOLUME)
	else :
		$Sound.volume_db = 0

	if Input.is_action_just_pressed("action_main"):
		# Activate the flames in the border
		animation_flames.play("press")
		# Emit the particles.
		$Particles.set_emitting(true)
		# Play the sound.
		$Sound.play()
	elif Input.is_action_just_released("action_main"):
		# Disable the flames in the border
		animation_flames.play("release")
		# Stop emmiting the particles.
		$Particles.set_emitting(false)
		# Stop the sound.
		$Sound.stop()
	# change smoothly the noise texture
	noise_texture.offset.z += delta * DISTORTION_SPEED
	flame_noise_texture.offset.z += delta * FLAME_DISTORTION_SPEED
