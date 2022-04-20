class_name Replayer
extends Node


signal try_jump(origin)
signal end_jump

var jump_times: Array
var jump_enums: Array

var count := 0


func _ready():
	var jump_log := Replays.logs
	jump_times = jump_log.keys()
	jump_enums = jump_log.values()


func _physics_process(_delta):
	count += 1
	if count - 1 != jump_times[0]: return
	jump_times.pop_front()
	var jump_data = jump_enums.pop_front()
	if jump_data is Array:
		assert(jump_data[0] == Replays.JUMP_START)
		emit_signal("try_jump", jump_data[1])
	else:
		assert(jump_data == Replays.JUMP_STOPPED)
		emit_signal("end_jump")
	if jump_times.empty():
		set_physics_process(false)
