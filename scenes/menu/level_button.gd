extends TextureButton

@export var scene_name: String = "selection"
@export var level: int = 0
@export var min_score: int = 0

func _ready():
	if level == 0 or GlobalScore.get_score(level - 1) >= min_score:
		var scene_path = "res://scenes/levels/" + scene_name + "/" + scene_name + ".tscn"
		pressed.connect(func(): SceneTransition.change_scene(scene_path))
		
		var press_count = 0
		var temp_level: Node2D = load(scene_path).instantiate()
		for beat: BeatEvent in temp_level.find_children("**", "BeatEvent"):
			if not beat.scorable or beat.is_bad: continue
			if beat.hold_length > 0: press_count += 1
			press_count += 1
		var max_score = 0
		for combo in range(1, press_count + 1):
			max_score += ScoreManager.PERFECT_PLUS_SCORE * min(combo, ScoreManager.MAX_COMBO_BONUS)
		$Score.text = str(max(0, GlobalScore.get_score(level))) + "/" + str(max_score)
	else:
		disabled = true
		$Score.text = ">" + str(min_score) + " to unlock"
