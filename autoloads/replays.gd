extends Node


const REPLAY_VERSION := 1
const REPLAYS_PATH := "user://replays/"

enum {
	JUMP_START,
	JUMP_STOPPED,
}

var logs := {}
var replays_dir := Directory.new()
var has_replays := false


func _ready():
	if not replays_dir.dir_exists(REPLAYS_PATH):
		if replays_dir.make_dir(REPLAYS_PATH) != OK:
			push_error("Could not make replays path!")
			return
	if replays_dir.open(REPLAYS_PATH) != OK:
		push_error("Could not open replays path!")
		return
		
	# warning-ignore:return_value_discarded
	replays_dir.list_dir_begin(true)
	var replay_name := replays_dir.get_next()
	var to_remove := []
	
	while not (replay_name.empty() or replay_name == "."):
		var file := File.new()
		
		if file.open_compressed(REPLAYS_PATH + replay_name, File.READ, File.COMPRESSION_GZIP) != OK:
			to_remove.append(replay_name)
			replay_name = replays_dir.get_next()
			continue
		if file.get_16() != REPLAY_VERSION:
			to_remove.append(replay_name)
			replay_name = replays_dir.get_next()
			continue
		replay_name = replays_dir.get_next()
		has_replays = true
	
	for file_name in to_remove:
		if replays_dir.remove(file_name) != OK:
			push_error("Could not delete " + REPLAYS_PATH + file_name + "!")


func reset():
	logs.clear()


func load_replay(replay_name: String) -> bool:
	var file := File.new()
	if file.open_compressed(REPLAYS_PATH + replay_name, File.READ, File.COMPRESSION_GZIP) != OK:
		return false
	
	# warning-ignore-all:return_value_discarded
	file.get_16()
	var data: Dictionary = file.get_var()
	file.close()
	logs = data["jumps"]
	GameState.current_seed = data["seed"]
	GameState.tmp_seed = true
	get_tree().change_scene("res://levels/replay.tscn")
	return true


func save_replay() -> bool:
	var file := File.new()
	var idx := 0
	var file_path := REPLAYS_PATH + "replay" + str(idx) + ".log"
	while file.file_exists(file_path):
		idx += 1
		file_path = REPLAYS_PATH + "replay" + str(idx) + ".log"

	if file.open_compressed(file_path, File.WRITE, File.COMPRESSION_GZIP) != OK:
		return false
	file.store_16(REPLAY_VERSION)
	file.store_var(get_replay_dict())
	file.close()
	has_replays = true
	return true


func get_replay_dict() -> Dictionary:
	return {
		"seed": GameState.current_seed,
		"jumps": logs,
		"date": OS.get_datetime()
	}


func log_jump_start(frames: int, to: Vector2, origin: Vector2, velocity: Vector2):
	logs[frames] = [JUMP_START, to, origin, velocity]


func log_jump_end(frames: int, origin: Vector2, velocity: Vector2):
	logs[frames] = [JUMP_STOPPED, origin, velocity]
