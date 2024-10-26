"""
The level button script.
"""

extends TextureButton

@export var scene_name: String = "selection"
@export var level: int = 0
@export var min_score: int = 0

func _ready():
	# If the level is unlocked or the player has enough score
	if level == 0 or GlobalScore.get_score(level - 1) >= min_score:
		# Generate the scene path
		var scene_path = "res://scenes/levels/" + scene_name + "/" + scene_name + ".tscn"
		# Connect the pressed signal to change the scene
		pressed.connect(func(): SceneTransition.change_scene(scene_path))
		
		# Count the number of pressable beats in the level
		var press_count = 0
		# Instantiate the level temporarily to count the beats
		var temp_level: Node2D = load(scene_path).instantiate()
		for beat: BeatEvent in temp_level.find_children("**", "BeatEvent"):
			# Skip non-scorable or bad beats
			if not beat.scorable or beat.is_bad: continue
			# Add 1 for non-hold beats and 2 for hold beats
			if beat.hold_length > 0: press_count += 1
			press_count += 1
		# Calculate the maximum score for the level
		var max_score = 0
		for combo in range(1, press_count + 1):
			# Add the score for a perfect combo
			max_score += ScoreManager.PERFECT_PLUS_SCORE * min(combo, ScoreManager.MAX_COMBO_BONUS)
		# Set the score display
		$Score.text = str(max(0, GlobalScore.get_score(level))) + "/" + str(max_score)
	else:
		# Disable the button if the level is locked
		disabled = true
		# Set the score display to indicate the minimum score required
		$Score.text = ">" + str(min_score) + " to unlock"

func _on_mouse_entered():
	# Button sound design
	$AudioStreamPlayer.play()
