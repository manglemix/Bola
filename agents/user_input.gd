class_name UserInput
extends AgentController


export var record_input := false


func poll_mutation(_delta, ball) -> void:
	if Input.is_action_just_pressed("jump"):
		var to: Vector2 = ball.get_global_mouse_position().snapped(Vector2.ONE * 0.1)
		ball.snap_all()
		
		if record_input:
			Replays.log_jump_start(_frame_counter, to, ball.global_position, ball.linear_velocity)
		
		ball.jump_to(to)
		ball.snap_all()
	
	elif Input.is_action_just_released("jump"):
		ball.snap_all()
		if record_input:
			Replays.log_jump_end(_frame_counter, ball.global_position, ball.linear_velocity)
		ball.cancel_jump()
	
	_increment_counter()
