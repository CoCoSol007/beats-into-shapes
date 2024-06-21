"""
The programme that show the speedup animation.
"""

extends Node2D

@onready var beat_manager = $"../PauseAffectedScript/BeatManager"


func _ready():
	beat_manager.speedup_started.connect(on_speedup_started)

func on_speedup_started(_time: float):
	$Animation.play("show")
