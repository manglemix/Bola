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
		if dir.make_dir(REPLAYS_PATH) != OK:
			push_error("Could not make replays path!")
			return
	dir.open(REPLAYS_PATH)
	dir.list_dir_begin()
	var replay_name = dir.get_next()
	var to_remove := []
	
	while not (replay_name.empty() or replay_name == "."):
		var file := File.new()
		if file.open(REPLAYS_PATH + replay_name, File.READ) != OK:
			to_remove.append(replay_name)
			continue
		if file.get_16() != REPLAY_VERSION:
			to_remove.append(replay_name)
			continue
	
	for file_name in to_remove:
		if dir.remove(file_name) != OK:
			push_error("Could not delete " + REPLAYS_PATH + file_name + "!")


func reset():
	logs.clear()


func load_replay(replay_name: String):
	var file := File.new()
	file.open(REPLAYS_PATH + replay_name, File.READ)
	file.get_16()
	var data: Dictionary = file.get_var()
	file.close()
	logs = data["jumps"]
	GameState.current_seed = data["seed"]
	GameState.tmp_seed = true
	get_tree().change_scene("res://levels/replay.tscn")


func save_replay():
	var file := File.new()
	var idx := 0
	var file_path := REPLAYS_PATH + "replay" + str(idx) + ".log"
	while file.file_exists(file_path):
		idx += 1
		file_path = REPLAYS_PATH + "replay" + str(idx) + ".log"

	file.open(file_path, File.WRITE)
	file.store_16(REPLAY_VERSION)
	file.store_var(get_replay_dict())
	file.close()


func get_replay_dict() -> Dictionary:
	return {
		"save_version": GameState.SAVE_SYSTEM_VERSION,
		"seed": GameState.current_seed,
		"jumps": logs
	}


func log_jump_start(frames: int, origin: Vector2):
	logs[frames] = [JUMP_START, origin]


func log_jump_end(frames: int):
	logs[frames] = JUMP_STOPPED
