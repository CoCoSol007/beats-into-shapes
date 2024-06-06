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

func _on_viewport_resize():
	# Adjusts the width clamping parameter of the background texture
	# to ensure the background matches the width of the window.
	# This alignment allows the fire effect to be displayed correctly at the borders.
   
	var window: Window = get_window()
	if background.texture is CompressedTexture2D:
		shader_material.set_shader_parameter( 
			"width_clamping", 
			clamp(
				0.5 - window.size.x / (
					background.texture.get_size().x * background.transform.get_scale().x # Actual size of the background
					* window.get_screen_transform().x.x # Scale factor of the window
				) * 0.5,
				0.0,
				0.5
			)
		)


# Called when the node enters the scene tree for the first time.
func _ready():
	shader_material = background.material as ShaderMaterial
	noise_texture = shader_material.get_shader_parameter("distortion_texture").noise
	flame_noise_texture = shader_material.get_shader_parameter("flame_distortion_texture").noise
	get_viewport().connect("size_changed", _on_viewport_resize)
	_on_viewport_resize()
	


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
