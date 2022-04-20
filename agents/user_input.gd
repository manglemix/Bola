class_name UserInput
extends Node2D


signal try_jump(origin)
signal end_jump

export var record_input := false

var start_count := 0


func _physics_process(_delta):
	if Input.is_action_just_pressed("jump"):
		var viewport := get_viewport()
		var origin := get_global_mouse_position().snapped(Vector2.ONE * 0.1)
		emit_signal("try_jump", origin)
		if record_input:
			Replays.log_jump_start(start_count, origin)
	
	elif Input.is_action_just_released("jump"):
		emit_signal("end_jump")
		if record_input:
			Replays.log_jump_end(start_count)
	
	start_count += 1
