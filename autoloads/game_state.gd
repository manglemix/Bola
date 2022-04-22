extends Node


const MAX_HEIGHT_CHANGE := 300.0
const MOVE_WEIGHT := 0.5

var level_height := 2000.0
var _start_time := OS.get_system_time_secs()
var current_seed: int
var player: BouncyBall
var started := false

var rotatables_rotation := {}
var player_velocity: Vector2
var player_jumps: int
var win_streak := 0
var player_position: Vector2
var vibrating := OS.has_touchscreen_ui_hint()
var tmp_seed := false


func _ready():
	randomize()


func get_seed():
	if not tmp_seed:
		current_seed = randi()
	tmp_seed = false
	return current_seed


func lost():
	# warning-ignore:return_value_discarded
	get_tree().change_scene(get_tree().current_scene.filename)
	if not started: return
	win_streak = 0
	var current_time := OS.get_system_time_secs()
	_start_time = current_time
	Replays.reset()


func won():
	# warning-ignore:return_value_discarded
	get_tree().change_scene(get_tree().current_scene.filename)
	if not started: return
	win_streak += 1
	var current_time := OS.get_system_time_secs()
	_start_time = current_time
	# warning-ignore:return_value_discarded
	Replays.save_replay()
	yield(get_tree(), "idle_frame")
	Replays.reset()


func _input(event):
	if event.is_action_pressed("fullscreen"):
		OS.window_fullscreen = not OS.window_fullscreen
