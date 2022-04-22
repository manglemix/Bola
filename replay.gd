class_name Replay
extends Reference


var name: String
var icon: ImageTexture
var logs: Dictionary
var level_seed: int


func parse_replay(replay_name: String) -> int:
	var file := File.new()
	var err := file.open_compressed(Replays.REPLAYS_PATH + replay_name, File.READ, File.COMPRESSION_GZIP)
	if err != OK:
		return err
	# warning-ignore:return_value_discarded
	file.get_16()
	var data: Dictionary = file.get_var()
	logs = data["jumps"]
	level_seed = data["seed"]
	var date: Dictionary = data["date"]
	
	name = str(date["day"]) + "-" + str(date["month"]) + "-" + str(date["year"]).right(2) + "  " + str(date["hour"]) + ":" + str(date["minute"])
	
	var img := Image.new()
	err = img.load_png_from_buffer(data["thumbnail"])
	if err != OK:
		return err
	icon = ImageTexture.new()
	icon.create_from_image(img)
	return OK
