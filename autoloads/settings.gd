extends Node


const MAX_MUSIC_VOLUME := 5.0
const MIN_MUSIC_VOLUME := -15.0


func get_music_volume() -> float:
	return AudioServer.get_bus_volume_db(1)


func set_music_volume(volume: float):
	AudioServer.set_bus_volume_db(1, volume)
