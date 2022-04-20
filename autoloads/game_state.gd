extends Node


const MAX_HEIGHT_CHANGE := 300.0
const MOVE_WEIGHT := 0.5
const _SAVEFILE_NAME := "user://savefile.save"
const SAVE_SYSTEM_VERSION := 1

var level_height := 2000.0
var _start_time := OS.get_system_time_secs()
var current_seed: int
var idx_to_skip := []
var _rotatables := {}
var loading_from_disk := false
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


func add_idx_to_skip(idx: int):
	idx_to_skip.append(idx)


func add_rotatable(node: RotatableBarrier, idx: int):
	_rotatables[idx] = node


func save_exists() -> bool:
	var file := File.new()
	var err := file.open(_SAVEFILE_NAME, File.READ)
	if err == ERR_FILE_NOT_FOUND or file.get_16() != SAVE_SYSTEM_VERSION: return false
	return true


func lost():
	get_tree().change_scene(get_tree().current_scene.filename)
	if not started: return
	reset_data()
	win_streak = 0
	var current_time := OS.get_system_time_secs()
	var loss := _height_change(current_time, true)
	level_height -= loss
	_start_time = current_time
	Replays.reset()


func won():
	get_tree().change_scene(get_tree().current_scene.filename)
	if not started: return
	win_streak += 1
	reset_data()
	var current_time := OS.get_system_time_secs()
	var gain := _height_change(current_time, false)
	level_height += gain
	_start_time = current_time
	Replays.save_replay()
	yield(get_tree(), "idle_frame")
	Replays.reset()


func _height_change(current_time: int, forgiving: bool) -> float:
	var diff := current_time - _start_time
	if forgiving:
		return MAX_HEIGHT_CHANGE * exp(- 0.01 * diff) * clamp(diff / 60.0, 0, 1)
	return MAX_HEIGHT_CHANGE * exp(- 0.01 * diff)


func reset_data():
	_rotatables.clear()
	idx_to_skip.clear()
	loading_from_disk = false


func try_load_save():
	var save := File.new()
	if OK != save.open(_SAVEFILE_NAME, File.READ): return
	save.get_16()		# advance the reader
	player_velocity = save.get_var()
	player_position = save.get_var()
	player_jumps = save.get_8()
	_start_time = OS.get_system_time_secs() - save.get_64()
	level_height = save.get_float()
	current_seed = save.get_32()
	idx_to_skip = save.get_var()
	rotatables_rotation = save.get_var()
	loading_from_disk = true


func _exit_tree():
	if started: save()


func save():
	var save := File.new()
	if OK != save.open(_SAVEFILE_NAME, File.WRITE): return
	save.store_16(SAVE_SYSTEM_VERSION)
	save.store_var(player.linear_velocity)
	save.store_var(player.transform.origin)
	save.store_8(player.current_jumps)
	save.store_64(OS.get_system_time_secs() - _start_time)
	save.store_float(level_height)
	save.store_32(current_seed)
	save.store_var(idx_to_skip)
	
	for i in _rotatables:
		rotatables_rotation[i] = _rotatables[i].rotation
	
	save.store_var(rotatables_rotation)
	save.close()


func _input(event):
	if event.is_action_pressed("fullscreen"):
		OS.window_fullscreen = not OS.window_fullscreen
