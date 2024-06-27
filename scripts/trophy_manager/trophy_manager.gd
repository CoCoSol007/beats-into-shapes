extends Node

signal enter_level(level: int)
signal finished_level(level: int, score: int)
signal node_action(action_status: Constants.ActionStatus)

var level: int = -1
var unlocked_trophies: SavedTrophy = SavedTrophy.new()

func _ready():
	if ResourceLoader.exists("user://unlocked_trophies.res"):
		unlocked_trophies = ResourceLoader.load("user://unlocked_trophies.res")
		var to_delete: Array[String] = []
		for trophy in unlocked_trophies.unlocked_trophies:
			if not get_node_or_null(trophy):
				to_delete.append(trophy)
		for trophy in to_delete:
			unlocked_trophies.unlocked_trophies.erase(trophy)
		ResourceSaver.save(unlocked_trophies, "user://unlocked_trophies.res")

	for trophy in get_children():
		if not is_instance_of(trophy, BaseTrophy):
			continue
		if not unlocked_trophies.unlocked_trophies.has(trophy.name):
			unlocked_trophies.unlocked_trophies[trophy.name] = false
		trophy.unlock = unlocked_trophies.unlocked_trophies[trophy.name]
		trophy.init()

	var beat_manager = get_node_or_null("../PauseAffectedScript/BeatManager")
	var score_manager = get_node_or_null("../ScoreManager")
	var trophies_node = get_node_or_null("../TrophiesDisplayer")
	# If it is not in a level
	if is_instance_of(beat_manager, BeatManager) and is_instance_of(score_manager, ScoreManager):
		in_level_init(beat_manager, score_manager)
	# If it is in the trophy menu
	elif is_instance_of(trophies_node, TrophiesDisplayer):
		in_trophy_menu_init(trophies_node)

func in_trophy_menu_init(trophies_node):
	for trophy in trophies_node.get_children():
		if not unlocked_trophies.unlocked_trophies.has(trophy.name):
			continue
		if not trophy.has_meta("description"):
			continue
		var child = get_node_or_null(NodePath(trophy.name))
		if not is_instance_of(child, BaseTrophy):
			continue
		trophy.material.set_shader_parameter("is_locked", 0.0 if unlocked_trophies.unlocked_trophies[trophy.name] else 1.0)
		trophy.set_meta("description", child.descritption)

func in_level_init(beat_manager, score_manager):
	level = beat_manager.level
	beat_manager.connect("node_pressed", _on_node_pressed)
	beat_manager.connect("node_released", _on_node_released)
	beat_manager.connect("missed_press", _on_missed_press)
	score_manager.connect("apply_level_score", _on_apply_level_score)
	enter_level.emit(level)


func _on_node_pressed(node: BeatEvent, _time: float, status: Constants.ActionStatus):
	# Ignore non-scorable nodes or bad nodes with missed status
	if not node.scorable or (node.is_bad and status == Constants.ActionStatus.MISSED):
		return
	node_action.emit(status)

func _on_node_released(node: BeatEvent, _time: float, status: Constants.ActionStatus):
	# Ignore non-scorable nodes, nodes with no hold length, or bad nodes
	if not node.scorable or node.hold_length == 0.0 or node.is_bad:
		return
	node_action.emit(status)

func _on_missed_press(_time: float, _key: Constants.ActionKey):
	node_action.emit(Constants.ActionStatus.MISSED)

func _on_apply_level_score(score):
	finished_level.emit(level, score)

func trophy_unlocked(trophy: BaseTrophy):
	unlocked_trophies.unlocked_trophies[trophy.name] = true
	ResourceSaver.save(unlocked_trophies, "user://unlocked_trophies.res")
