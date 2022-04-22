extends AudioStreamPlayer


const SONG_FOLDER := "res://songs/"

var songs := []
var song_index := 0


func _ready():
	var dir := Directory.new()
	if dir.open(SONG_FOLDER) != OK:
		return
	if dir.list_dir_begin(true) != OK:
		return
	
	var song_name := dir.get_next()
	while not song_name.empty():
		if song_name.ends_with(".import"):
			song_name = dir.get_next()
			continue
		var song = load(SONG_FOLDER + song_name)
		if not song is AudioStream:
			push_error(song_name + " is not an audio file!")
			song_name = dir.get_next()
			continue
		songs.append(song)
		song_name = dir.get_next()
	
	songs.shuffle()
	stream = songs[0]
	song_index = 1
	play()
	# warning-ignore:return_value_discarded
	connect("finished", self, "_on_finished")


func _on_finished():
	song_index += 1
	if songs.size() == song_index:
		song_index = 1
		songs.shuffle()
		stream = songs[0]
		return
	stream = songs[song_index]
	play()
