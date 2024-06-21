"""
All code related to the "flames" particles and sound.
"""

extends Node

@onready var background := $Background
@onready var animation_flames = $AnimationFlames
@onready var sound = $Sound
@onready var particles = $Particles


var noise_texture: FastNoiseLite
var flame_noise_texture: FastNoiseLite
var shader_material: ShaderMaterial

const DISTORTION_SPEED = 75.0
const FLAME_DISTORTION_SPEED = 75.0
const TARGET_VOLUME = 24
const VOLUME_SPEED = 30.

var is_running := false

var paused := false:
	set(value):
		# Entering pause mode
		if value and !paused:
			sound.stop()
		# Exiting pause mode
		if !value and paused:
			var action_main_press := Input.is_action_pressed("action_main")
			# User pressed action_main during pause mode
			if action_main_press and !is_running:
				animation_start()
			# User released action_main during pause mode
			elif !action_main_press and is_running:
				animation_end()
			# User kept action_main pressed during pause mode
			if action_main_press and is_running:
				sound.play()
		paused = value


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
	animation_flames.play("RESET")



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# exit if is in pause mode
	if paused:
		return

	# Smoothly increase the volume of the sound.
	if sound.is_playing():
		sound.volume_db = min(sound.volume_db + VOLUME_SPEED * delta, TARGET_VOLUME)
	else :
		sound.volume_db = 0
	
	if Input.is_action_just_pressed("action_main"):
		animation_start()
	elif Input.is_action_just_released("action_main"):
		animation_end()
	# change smoothly the noise texture
	noise_texture.offset.z += delta * DISTORTION_SPEED
	flame_noise_texture.offset.z += delta * FLAME_DISTORTION_SPEED

func animation_start():
	is_running = true
	# Activate the flames in the border
	animation_flames.play("press")
	# Emit the particles.
	particles.set_emitting(true)
	# Play the sound.
	sound.play()

func animation_end():
	is_running = false
	# Disable the flames in the border
	animation_flames.play("release")
	# Stop emmiting the particles.
	particles.set_emitting(false)
	# Stop the sound.
	sound.stop()
