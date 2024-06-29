
@tool class_name BeatManager extends Node2D

const CALCULATION_TIME: float = 16

signal node_pressed(node: BeatEvent, time: float, status: Constants.ActionStatus)
signal node_released(node: BeatEvent, time: float, status: Constants.ActionStatus)
signal missed_press(time: float, key: Constants.ActionKey)
signal speedup_started(time: float)
signal song_finished()

@onready var camera = $"../../Camera2D"

@export var stream: AudioStreamMP3
@export var perfect_time: float = 0.1
@export var perfect_plus_time: float = 0.05
@export var too_time: float = 0.3
@export var speedup_time: float = 20.0
@export var speedup_scale: float = 0.25
@export var speedup_length: float = 3.0
@export var tutorial_stop_time: float = 36.5
@export var zoom_duration: float = 0.08
@export var zoom_intensity: float = 0.02
@export var level: int = 0
@export var level_name: String = ""

var used_keys = {}
var unhandled_nodes: Array[BeatEvent] = []
var calculation_index: int = 0
var pressed_nodes: Array[BeatEvent] = []
var handled_nodes: Array[BeatEvent] = []
var tutorial: bool = false

var is_speedup: bool = false
var paused:
	get: return $MusicPlayer.stream_paused
	set(value): $MusicPlayer.stream_paused = value


func beat_steps(time: float) -> float:
	time = fmod(time, 1)
	if 0.5 - zoom_duration < time and time < 0.5 + zoom_duration: 
		time = (time - 0.5 + zoom_duration) / zoom_duration
		return (sin(PI * (time - 0.5)) + 1) / 2
	return 0

func _ready():
	if Engine.is_editor_hint(): return
	tutorial = GlobalScore.get_score(level) == 0
	$MusicPlayer.stream = stream
	$MusicPlayer.play()
	for node: BeatEvent in get_tree().get_nodes_in_group("beat_event"):
		if tutorial and node.hard_key: continue
		unhandled_nodes.append(node)
		used_keys[node.press_key] = true
	unhandled_nodes.sort_custom(func(a: BeatEvent, b: BeatEvent): return a.press_time >= b.press_time)
	calculation_index = len(unhandled_nodes)
	($MusicPlayer as AudioStreamPlayer).finished.connect(func(): song_finished.emit())
	if not tutorial:
		for indicator: Indicator in get_tree().get_nodes_in_group("indicator"):
			indicator.queue_free()
		for text in get_tree().get_nodes_in_group("tutorial_text"):
			text.queue_free()

func _process(_delta):
	if Engine.is_editor_hint():
		var time_seconds_editor = position.x - AudioServer.get_output_latency()
		var time_editor = time_seconds_editor * (stream.bpm / 60.0)
		for node: BeatEvent in get_tree().get_nodes_in_group("beat_event"):
			node.update(time_editor - node.press_time)
		return
	
	if paused: return
	
	var time_seconds = $MusicPlayer.get_playback_position() + AudioServer.get_time_since_last_mix() - AudioServer.get_output_latency()
	var time = time_seconds * (stream.bpm / 60.0)
	
	if calculation_index > 0:
		if unhandled_nodes[calculation_index - 1].press_time - time <= CALCULATION_TIME:
			calculation_index -= 1
	
	var pressed_keys: Array[Constants.ActionKey] = []
	if Constants.ActionKey.LEFT in used_keys and Input.is_action_just_pressed("action_left"): pressed_keys.append(Constants.ActionKey.LEFT)
	if Constants.ActionKey.MAIN in used_keys and Input.is_action_just_pressed("action_main"): pressed_keys.append(Constants.ActionKey.MAIN)
	if Constants.ActionKey.RIGHT in used_keys and Input.is_action_just_pressed("action_right"): pressed_keys.append(Constants.ActionKey.RIGHT)
	var unhandled_keys = pressed_keys.duplicate()
	for i in range(len(unhandled_nodes) - 1, calculation_index - 1, -1):
		var node: BeatEvent = unhandled_nodes[i]
		var distance_to_press = (node.press_time - time) / (stream.bpm / 60.0)
		if distance_to_press > too_time: continue
		elif distance_to_press < -too_time:
			node.pressed(time - node.press_time, Constants.ActionStatus.MISSED)
			node_pressed.emit(node, time, Constants.ActionStatus.MISSED)
			handled_nodes.append(unhandled_nodes.pop_at(i))
		elif node.press_key in pressed_keys:
			if abs(distance_to_press) <= perfect_plus_time:
				node.pressed(time - node.press_time, Constants.ActionStatus.PERFECT_PLUS)
				node_pressed.emit(node, time, Constants.ActionStatus.PERFECT_PLUS)
			elif abs(distance_to_press) <= perfect_time:
				node.pressed(time - node.press_time, Constants.ActionStatus.PERFECT)
				node_pressed.emit(node, time, Constants.ActionStatus.PERFECT)
			else:
				var status = Constants.ActionStatus.TOO_SOON if distance_to_press > 0 else Constants.ActionStatus.TOO_LATE
				node.pressed(time - node.press_time, status)
				node_pressed.emit(node, time, status)
			pressed_nodes.append(unhandled_nodes.pop_at(i))
			unhandled_keys.erase(node.press_key)
	
	for unhandled_key in unhandled_keys:
		missed_press.emit(time, unhandled_key)
	
	var released_keys: Array[Constants.ActionKey] = []
	if Input.is_action_just_released("action_left"): released_keys.append(Constants.ActionKey.LEFT)
	if Input.is_action_just_released("action_main"): released_keys.append(Constants.ActionKey.MAIN)
	if Input.is_action_just_released("action_right"): released_keys.append(Constants.ActionKey.RIGHT)
	for i in range(len(pressed_nodes) - 1, -1, -1):
		var node: BeatEvent = pressed_nodes[i]
		var distance_to_release = (node.press_time + node.hold_length - time) / (stream.bpm / 60.0)
		if distance_to_release < -too_time:
			node.released(time - node.press_time, Constants.ActionStatus.MISSED)
			node_released.emit(node, time, Constants.ActionStatus.MISSED)
			handled_nodes.append(pressed_nodes.pop_at(i))
		elif node.press_key in released_keys:
			if distance_to_release > too_time:
				node.released(time - node.press_time, Constants.ActionStatus.VERY_SOON)
				node_released.emit(node, time, Constants.ActionStatus.VERY_SOON)
			elif abs(distance_to_release) <= perfect_plus_time:
				node.released(time - node.press_time, Constants.ActionStatus.PERFECT_PLUS)
				node_released.emit(node, time, Constants.ActionStatus.PERFECT_PLUS)
			elif abs(distance_to_release) <= perfect_time:
				node.released(time - node.press_time, Constants.ActionStatus.PERFECT)
				node_released.emit(node, time, Constants.ActionStatus.PERFECT)
			else:
				var status = Constants.ActionStatus.TOO_SOON if distance_to_release > 0 else Constants.ActionStatus.TOO_LATE
				node.released(time - node.press_time, status)
				node_released.emit(node, time, status)
			handled_nodes.append(pressed_nodes.pop_at(i))

	for i in range(len(unhandled_nodes) - 1, calculation_index - 1, -1):
		var node: BeatEvent = unhandled_nodes[i]
		node.update(time - node.press_time)
	
	for node: BeatEvent in pressed_nodes:
		node.update(time - node.press_time)
		
	# update camera
	if owner.get_node("PauseMenu").camera_effects:
		var zoom_level = beat_steps(time / 2.0)
		var zoom = 1 + zoom_level * zoom_intensity
		camera.zoom.y = zoom
		camera.zoom.x = zoom
	 
	
	for i in range(len(handled_nodes) - 1, -1, -1):
		var node: BeatEvent = handled_nodes[i]
		if time - node.press_time - node.hold_length > CALCULATION_TIME:
			handled_nodes.remove_at(i)
		else: node.update(time - node.press_time)
	
	if tutorial:
		var next_beat_times = {
			Constants.ActionKey.LEFT: 10000000,
			Constants.ActionKey.MAIN: 10000000,
			Constants.ActionKey.RIGHT: 10000000,
		}
		var next_beat_nodes = {
			Constants.ActionKey.LEFT: null,
			Constants.ActionKey.MAIN: null,
			Constants.ActionKey.RIGHT: null,
		}
		for i in range(len(unhandled_nodes) - 1, calculation_index - 1, -1):
			var node: BeatEvent = unhandled_nodes[i]
			if node.is_bad: continue
			var key = node.press_key
			if next_beat_nodes[key] == null or node.press_time < next_beat_times[key]:
				next_beat_nodes[key] = node
				next_beat_times[key] = node.press_time
		for node: BeatEvent in pressed_nodes:
			if node.hold_length == 0 or node.is_bad: continue
			var key = node.press_key
			if next_beat_nodes[key] == null or node.press_time + node.hold_length < next_beat_times[key]:
				next_beat_nodes[key] = node
				next_beat_times[key] = node.press_time + node.hold_length
		for indicator: Indicator in get_tree().get_nodes_in_group("indicator"):
			var node: BeatEvent = next_beat_nodes[indicator.press_key]
			if node == null:
				indicator.pressed = false
				indicator.remaining_time = 0.0
				indicator.bonus_line_length = 0.0
				continue
			var next_time = next_beat_times[indicator.press_key]
			indicator.bonus_line_length = node.hold_length  / (stream.bpm / 60.0)
			if node.press_time != next_time:
				indicator.pressed = time < next_time
				indicator.remaining_time = ((next_time - node.hold_length) / (stream.bpm / 60.0)) - time_seconds
			else:
				indicator.pressed = time >= next_time
				var remaining_time = (next_time / (stream.bpm / 60.0)) - time_seconds
				if remaining_time <= 0.0: indicator.bonus_line_length += remaining_time
				indicator.remaining_time = max(0.0, remaining_time)

		($MusicPlayer as AudioStreamPlayer).volume_db = min(0, (tutorial_stop_time - time) * 8.0)
		if tutorial_stop_time - time <= -2:
			GlobalScore.global_score.scores[level] = -1
			SceneTransition.change_scene("res://scenes/levels/" + level_name + "/" + level_name + ".tscn")
	else:
		if not is_speedup and time >= speedup_time:
			is_speedup = true
			speedup_started.emit(speedup_time)
		($MusicPlayer as AudioStreamPlayer).pitch_scale =  1.0 + smoothstep(0.0, speedup_length, time - speedup_time) * speedup_scale
