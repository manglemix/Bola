class_name Replay
extends Reference


var name: String
var icon: ImageTexture
var logs: Dictionary
var difficulty: int
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
	difficulty = data["difficulty"]
	var date: Dictionary = data["date"]
	
	var minute_str: String
	if date["minute"] < 10:
		minute_str = "0" + str(date["minute"])
	else:
		minute_str = str(date["minute"])
	
	var is_pm := false
	if date["hour"] > 12:
		date["hour"] -= 12
		is_pm = true
	
	name = str(date["day"]) + "-" + str(date["month"]) + "-" + str(date["year"]).right(2) + "  " + str(date["hour"]) + ":" + minute_str
	
	if is_pm:
		name += " PM"
	else:
		name += " AM"
	
	name += "\n"
	
	if is_equal_approx(difficulty, GameState.GRANDMASTER):
		name += "GRANDMASTER"
	elif is_equal_approx(difficulty, GameState.PROFESSIONAL):
		name += "PROFESSIONAL"
	elif is_equal_approx(difficulty, GameState.AMATEUR):
		name += "AMATEUR"
	else:
		name += "CASUAL"
	
	var img := Image.new()
	err = img.load_png_from_buffer(data["thumbnail"])
	if err != OK:
		return err
	icon = ImageTexture.new()
	icon.create_from_image(img)
	return OK
