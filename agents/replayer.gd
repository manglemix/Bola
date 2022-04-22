class_name Replayer
extends AgentController


signal invalid_move

var jump_times: Array
var jump_enums: Array

var global_position: Vector2
var linear_velocity: Vector2


func _ready():
	var jump_log := Replays.logs
	jump_times = jump_log.keys()
	jump_enums = jump_log.values()


func poll_mutation(_delta: float, ball):
	if jump_times.empty(): return
	if _frame_counter != jump_times[0]:
		_increment_counter()
		return
	
	jump_times.pop_front()
	var jump_data: Array = jump_enums.pop_front()
	global_position = ball.global_position
	linear_velocity = ball.linear_velocity
	
	match jump_data[0]:
		Replays.JUMP_START:
			if origin_check(jump_data[2]):
				emit_signal("invalid_move")
			ball.global_position = jump_data[2]

			if velocity_check(jump_data[3]):
				emit_signal("invalid_move")
			ball.linear_velocity = jump_data[3]
			
			ball.jump_to(jump_data[1])
			ball.snap_all()
		
		Replays.JUMP_STOPPED:
			if origin_check(jump_data[1]):
				emit_signal("invalid_move")
			ball.global_position = jump_data[1]

			if velocity_check(jump_data[2]):
				emit_signal("invalid_move")
			ball.linear_velocity = jump_data[2]
			
			ball.cancel_jump()
		
	_increment_counter()


func origin_check(new_origin: Vector2):
#	prints("o", new_origin.distance_to(global_position))
	return new_origin.distance_to(global_position) > 0.15


func velocity_check(new_vel: Vector2):
#	prints("v", new_vel.distance_to(linear_velocity))
	return new_vel.distance_to(linear_velocity) > 0.15
