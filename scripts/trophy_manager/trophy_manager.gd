extends Node

# Signal to be emitted when entering a level
signal enter_level(level: int)
# Signal to be emitted when finishing a level
signal finished_level(level: int, score: int)
# Signal to be emitted when a node action is triggered
signal node_action(action_status: Constants.ActionStatus)

# Current level being played. -1 means no level is being played
var level: int = -1
var unlocked_trophies: SavedTrophy = SavedTrophy.new()

func _ready():
	# Load unlocked trophies from save file if it exists
	if ResourceLoader.exists("user://unlocked_trophies.res"):
		unlocked_trophies = ResourceLoader.load("user://unlocked_trophies.res")
		print(unlocked_trophies.unlocked_trophies)
		# Remove trophies that do not exist
		var to_delete: Array[String] = []
		for trophy in unlocked_trophies.unlocked_trophies:
			if not get_node_or_null(trophy):
				to_delete.append(trophy)
		for trophy in to_delete:
			unlocked_trophies.unlocked_trophies.erase(trophy)
		# Save the updated unlocked trophies
		ResourceSaver.save(unlocked_trophies, "user://unlocked_trophies.res")

	# Initialize trophies
	for trophy in get_children():
		if not is_instance_of(trophy, BaseTrophy):
			continue
		# If trophy is not registered in the unlocked trophies, 
		# register it and set its unlocked status to false
		if not unlocked_trophies.unlocked_trophies.has(trophy.name):
			unlocked_trophies.unlocked_trophies[trophy.name] = false
		# Set the trophy's unlocked status based on the saved unlocked trophies
		trophy.unlock = unlocked_trophies.unlocked_trophies[trophy.name]
		trophy.init()

	# Check if the TrophyManager is in a level or in the trophy menu
	var beat_manager = get_node_or_null("../PauseAffectedScript/BeatManager")
	var score_manager = get_node_or_null("../ScoreManager")
	var trophies_displayer = get_node_or_null("../TrophiesDisplayer")
	if is_instance_of(beat_manager, BeatManager) and is_instance_of(score_manager, ScoreManager):
		in_level_init(beat_manager, score_manager)
	elif is_instance_of(trophies_displayer, TrophiesDisplayer):
		in_trophy_menu_init(trophies_displayer)

# Initialize trophies in the trophy menu
func in_trophy_menu_init(trophies_displayer):
	for displayed_trophy in trophies_displayer.get_children():
		if not unlocked_trophies.unlocked_trophies.has(displayed_trophy.name):
			continue
		if not displayed_trophy.has_meta("description"):
			continue
		var child = get_node_or_null(NodePath(displayed_trophy.name))
		if not is_instance_of(child, BaseTrophy):
			continue
		displayed_trophy.material.set_shader_parameter("is_locked", 0.0 if unlocked_trophies.unlocked_trophies[displayed_trophy.name] else 1.0)
		displayed_trophy.set_meta("description", child.description)

# Initialize trophies in a level
func in_level_init(beat_manager, score_manager):
	# Set the current level
	level = beat_manager.level
	# Connect signals
	beat_manager.connect("node_pressed", _on_node_pressed)
	beat_manager.connect("node_released", _on_node_released)
	beat_manager.connect("missed_press", _on_missed_press)
	score_manager.connect("apply_level_score", _on_apply_level_score)
	# Emit the enter_level signal
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
