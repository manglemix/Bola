class_name UserInput
extends AgentController


export var record_input := false


func _on_body_entered(_node: Node):
	if not record_input: return
	yield(get_tree(), "physics_frame")
	var origin := global_position.snapped(Vector2.ONE * 0.1)
	var vel: Vector2 = linear_velocity.snapped(Vector2.ONE * 0.1)
	emit_signal("correct_origin", origin)
	emit_signal("correct_velocity", vel)
	Replays.log_collision(origin, vel)


func _physics_process(_delta):
	var origin := global_position.snapped(Vector2.ONE * 0.1)
	var vel: Vector2 = linear_velocity.snapped(Vector2.ONE * 0.1)
	
	if Input.is_action_just_pressed("jump"):
		emit_signal("correct_origin", origin)
		var to := get_global_mouse_position().snapped(Vector2.ONE * 0.1)
		
		emit_signal("correct_velocity", vel)
		emit_signal("try_jump", to)
		if record_input:
			Replays.log_jump_start(count, to, origin, vel)
	
	elif Input.is_action_just_released("jump"):
		emit_signal("correct_origin", origin)
		emit_signal("correct_velocity", vel)
		emit_signal("end_jump")
		if record_input:
			Replays.log_jump_end(count, origin, vel)
