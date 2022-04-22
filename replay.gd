class_name Replay
extends Reference


var name: String
var icon: ImageTexture
var logs: Dictionary
var level_seed: int


func parse_replay(replay_name: String):
	var file := File.new()
	file.open_compressed(Replays.REPLAYS_PATH + replay_name, File.READ, File.COMPRESSION_GZIP)
	# warning-ignore:return_value_discarded
	file.get_16()
	var data: Dictionary = file.get_var()
	logs = data["jumps"]
	level_seed = data["seed"]
	var date: Dictionary = data["date"]
	
	name = str(date["day"]) + "-" + str(date["month"]) + "-" + str(date["year"]).right(2) + "  " + str(date["hour"]) + ":" + str(date["minute"])
	
	var img := Image.new()
	img.load_png_from_buffer(data["thumbnail"])
	icon = ImageTexture.new()
	icon.create_from_image(img)
