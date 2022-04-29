extends AudioStreamPlayer


const SONG_FOLDER := "res://songs/"

var songs := [
	preload("res://songs/Goldberg Variations, BWV 988 - 10 - Variatio 9 a 1 Clav. Canone alla Terza.mp3"),
	preload("res://songs/Goldberg Variations, BWV 988 - 17 - Variatio 16 a 1 Clav. Ouverture.mp3"),
	preload("res://songs/Goldberg Variations, BWV 988 - 22 - Variatio 21 Canone alla Settima.mp3"),
	preload("res://songs/Goldberg Variations, BWV 988 - 26 - Variatio 25 a 2 Clav.mp3"),
	preload("res://songs/Goldberg Variations, BWV. 988 - Variation 22.mp3"),
]
var song_index := 0


func _ready():
	bus = "Music"
	randomize()
	songs.shuffle()
	_on_finished()
	# warning-ignore:return_value_discarded
	connect("finished", self, "_on_finished")


func _on_finished():
	if songs.size() == song_index:
		song_index = 0
		songs.shuffle()
	stream = songs[song_index]
	song_index += 1
	play()
