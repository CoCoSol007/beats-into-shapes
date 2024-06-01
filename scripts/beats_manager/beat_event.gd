"""
A simple template of a beats event.
"""

@tool class_name BeatEvent extends Node2D

@export var press_key: Constants.ActionKey = Constants.ActionKey.UNBOUND
@export var press_time: float = 0.0
@export var hold_length: float = 0.0
@export var scorable: bool = true
@export var is_bad: bool = false
@export var hard_key: bool = false

func pressed(_time: float, _status: Constants.ActionStatus):
	pass

func released(_time: float, _status: Constants.ActionStatus):
	pass

func update(_time: float):
	pass

func global(time: float) -> float:
	return time + press_time

func smoothsteps(time: float, curve: float) -> float:
	return floor(time) + ease(time - floor(time), curve)
