"""
An autoload in order to manage the score.
"""

extends Node

var global_score: SavedScore = SavedScore.new()

func _ready():
	# Load the last score in the save files.
	if ResourceLoader.exists("user://scores.res"):
		global_score = ResourceLoader.load("user://scores.res")

func get_score(level: int):
	return global_score.scores[level]

func apply_score(level: int, score: int):
	if score > global_score.scores[level]:
		global_score.scores[level] = score
		# Save the new score
		ResourceSaver.save(global_score, "user://scores.res")
		return true
	return false
