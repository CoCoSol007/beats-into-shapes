""" The main manager of the score system. """

class_name ScoreManager extends Node2D

# Constants for scoring system
const PERFECT_PLUS_TIME: float = 0.05
const MAX_COMBO_BONUS = 8
const PERFECT_PLUS_SCORE = 20
const PERFECT_SCORE = 10
const TOO_SCORE = 5
const FAILED_SCORE = -10

# Reference to the BeatManager node
@onready var beat_manager = get_node("../BeatManager")

# Variables to store the current score and combo count
var score: int = 0
var combo: int = 0
var combo_plus: int = 0

# Called when the node is added to the scene
func _ready():
	# Connect signals for key pressed, key released, and missed press events
	beat_manager.node_pressed.connect(on_node_pressed)
	beat_manager.node_released.connect(on_node_released)
	beat_manager.missed_press.connect(on_missed_press)

	# Handle the end of the game by applying the score and changing the scene
	beat_manager.song_finished.connect(func():
		GlobalScore.apply_score(beat_manager.level, score)
		SceneTransition.change_scene("res://scenes/menu/menu.tscn"))

# Function to display status messages on the screen
func show_status(message: String, color: Color):
	$Status/Label.text = message
	$Status/Label["theme_override_colors/font_color"] = color
	$Status/Animation.stop()
	$Status/Animation.play("show_status")

# Called when a beat event node is pressed
func on_node_pressed(node: BeatEvent, time: float, status: Constants.ActionStatus):
	# Ignore non-scorable nodes or bad nodes with missed status
	if not node.scorable or (node.is_bad and status == Constants.ActionStatus.MISSED):
		return
	# Handle the status based on the timing and status of the press
	handle_status(time - node.press_time, status, node.is_bad)

# Called when a beat event node is released
func on_node_released(node: BeatEvent, time: float, status: Constants.ActionStatus):
	# Ignore non-scorable nodes, nodes with no hold length, or bad nodes
	if not node.scorable or node.hold_length == 0.0 or node.is_bad:
		return
	# Handle the status based on the timing and status of the release
	handle_status(time - node.press_time - node.hold_length, status, false)

# Called when a press is missed
func on_missed_press(time: float, _key: Constants.ActionKey):
	# Handle the missed press status
	handle_status(time, Constants.ActionStatus.MISSED, false)

# Function to handle the status of a press or release
func handle_status(time: float, status: Constants.ActionStatus, is_bad: bool):
	# Handle bad nodes (wrong presses)
	if is_bad:
		score += FAILED_SCORE
		combo = 0
		show_status("Wrong", Color(172 / 255.0, 47 / 255.0, 69 / 255.0))
		return

	# Handle different action statuses
	match status:
		Constants.ActionStatus.VERY_SOON:
			score += FAILED_SCORE
			combo = 0; combo_plus = 0
			show_status("Very Soon", Color(172 / 255.0, 47 / 255.0, 69 / 255.0))
			
		Constants.ActionStatus.TOO_SOON:
			score += TOO_SCORE
			combo = 0; combo_plus = 0
			show_status("Too Soon", Color(230 / 255.0, 120 / 255.0, 57 / 255.0))
			
		Constants.ActionStatus.PERFECT:
			var is_plus = abs(time) <= PERFECT_PLUS_TIME
			var bonus = PERFECT_PLUS_SCORE if is_plus else PERFECT_SCORE
			combo += 1
			score += bonus * min(combo, MAX_COMBO_BONUS)
			if is_plus:
				combo_plus += 1
				if combo >= 2:
					show_status("Perfect+ ×" + str(combo), Color(157 / 255.0, 200 / 255.0, 159 / 255.0))
				else:
					show_status("Perfect+", Color(157 / 255.0, 200 / 255.0, 159 / 255.0))
			else:
				if combo >= 2:
					show_status("Perfect ×" + str(combo), Color(59 / 255.0, 126 / 255.0, 79 / 255.0))
				else:
					show_status("Perfect", Color(59 / 255.0, 126 / 255.0, 79 / 255.0))
					
		Constants.ActionStatus.TOO_LATE:
			score += TOO_SCORE
			combo = 0; combo_plus = 0
			show_status("Too Late", Color(230 / 255.0, 120 / 255.0, 57 / 255.0))
			
		Constants.ActionStatus.MISSED:
			score += FAILED_SCORE
			combo = 0; combo_plus = 0
			show_status("Missed", Color(172 / 255.0, 47 / 255.0, 69 / 255.0))
		
	# Update the score display
	$Score.text = "Score: " + str(score)
