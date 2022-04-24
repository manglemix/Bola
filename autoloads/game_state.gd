extends Node


enum {
	CASUAL,
	AMATEUR,
	PROFESSIONAL,
	GRANDMASTER
}

const MAX_HEIGHT_CHANGE := 300.0
const MOVE_WEIGHT := 0.5

var current_seed: int
var win_streak := 0
var vibrating := OS.has_touchscreen_ui_hint()
var tmp_seed := false
var difficulty := CASUAL


func _ready():
	randomize()


func get_seed():
	if not tmp_seed:
		current_seed = randi()
	tmp_seed = false
	return current_seed


func load_level():
	# warning-ignore-all:return_value_discarded
	if is_equal_approx(difficulty, AMATEUR):
		get_tree().change_scene("res://levels/amateur.tscn")
	elif is_equal_approx(difficulty, PROFESSIONAL):
		get_tree().change_scene("res://levels/professional.tscn")
	elif is_equal_approx(difficulty, GRANDMASTER):
		get_tree().change_scene("res://levels/grandmaster.tscn")
	else:
		get_tree().change_scene("res://levels/casual.tscn")
	yield(get_tree(), "idle_frame")
	Replays.reset()


func lost():
	# warning-ignore:return_value_discarded
	win_streak = 0
	get_tree().change_scene(get_tree().current_scene.filename)
	Replays.reset()


func won():
	# warning-ignore:return_value_discarded
	win_streak += 1
	get_tree().change_scene(get_tree().current_scene.filename)
	# warning-ignore:return_value_discarded
	Replays.save_replay()
	yield(get_tree(), "idle_frame")
	Replays.reset()


func _input(event):
	if event.is_action_pressed("fullscreen"):
		OS.window_fullscreen = not OS.window_fullscreen
