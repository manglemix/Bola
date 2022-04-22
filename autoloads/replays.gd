extends Node


const REPLAY_VERSION := 1
const REPLAYS_PATH := "user://replays/"
const ICON_SIZE := 200

enum {
	JUMP_START,
	JUMP_STOPPED,
}

var logs := {}
var replays_dir := Directory.new()
var has_replays := false
var thumbnail: PoolByteArray


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


func capture_thumbnail():
	var img := get_viewport().get_texture().get_data()
	var img_size := img.get_size()
	# warning-ignore-all:narrowing_conversion
	if img_size.x > img_size.y:
		img.resize(round(img_size.x * ICON_SIZE / img_size.y), ICON_SIZE, Image.INTERPOLATE_NEAREST)
	else:
		img.resize(ICON_SIZE, round(img_size.y * ICON_SIZE / img_size.x), Image.INTERPOLATE_NEAREST)
	
	img_size = img.get_size()
	var tex := ImageTexture.new()
	tex.create_from_image(img)
	var atlas := AtlasTexture.new()
	
	atlas.atlas = tex
	atlas.region = Rect2((img_size - Vector2.ONE * ICON_SIZE) / 2, Vector2.ONE * ICON_SIZE)
	img = atlas.get_data()
	img.flip_y()
	thumbnail = img.save_png_to_buffer()


func load_replay(replay: Replay):
	GameState.current_seed = replay.level_seed
	logs = replay.logs
	GameState.tmp_seed = true
	# warning-ignore:return_value_discarded
	get_tree().change_scene("res://levels/replay.tscn")


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
		"date": OS.get_datetime(),
		"thumbnail": thumbnail
	}


func log_jump_start(frames: int, to: Vector2, origin: Vector2, velocity: Vector2):
	logs[frames] = [JUMP_START, to, origin, velocity]


func log_jump_end(frames: int, origin: Vector2, velocity: Vector2):
	logs[frames] = [JUMP_STOPPED, origin, velocity]
