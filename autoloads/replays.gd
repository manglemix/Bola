extends Node


const REPLAY_VERSION := 1
const REPLAYS_PATH := "user://replays/"

enum {
	JUMP_START,
	JUMP_STOPPED
}

var logs := {}


func _ready():
	var dir := Directory.new()
	if not dir.dir_exists(REPLAYS_PATH):
		dir.make_dir(REPLAYS_PATH)


func reset():
	logs.clear()


func load_replay(replay_name: String):
	var file := File.new()
	file.open(REPLAYS_PATH + replay_name, File.READ)
	var data: Dictionary = file.get_var()
	file.close()
	logs = data["jumps"]
	GameState.current_seed = data["seed"]
	GameState.tmp_seed = true
	get_tree().change_scene("res://levels/replay.tscn")


func send_replay():
	var file := File.new()
	
	var idx := 0
	var file_path := REPLAYS_PATH + "replay" + str(idx) + ".log"
	while file.file_exists(file_path):
		idx += 1
		file_path = REPLAYS_PATH + "replay" + str(idx) + ".log"

	file.open(file_path, File.WRITE)
	file.store_var({
		"replay_version": REPLAY_VERSION,
		"save_version": GameState.SAVE_SYSTEM_VERSION,
		"seed": GameState.current_seed,
		"jumps": logs
	})
	file.close()


func log_jump_start(frames: int, origin: Vector2):
	logs[frames] = [JUMP_START, origin]


func log_jump_end(frames: int):
	logs[frames] = JUMP_STOPPED
