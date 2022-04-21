class_name Replayer
extends AgentController


signal invalid_move

var jump_times: Array
var jump_enums: Array
var collisions: Array


func _ready():
	var jump_log := Replays.logs
	jump_times = jump_log.keys()
	jump_enums = jump_log.values()
	collisions = Replays.collision_logs.duplicate()


func _physics_process(_delta):
	if count != jump_times[0]: return
	jump_times.pop_front()
	var jump_data: Array = jump_enums.pop_front()
	
	match jump_data[0]:
		Replays.JUMP_START:
			if origin_check(jump_data[2]):
				emit_signal("invalid_move")
			emit_signal("correct_origin", jump_data[2])

			if velocity_check(jump_data[3]):
				emit_signal("invalid_move")
			emit_signal("correct_velocity", jump_data[3])
			
			emit_signal("try_jump", jump_data[1])
		
		Replays.JUMP_STOPPED:
			if origin_check(jump_data[1]):
				emit_signal("invalid_move")
			emit_signal("correct_origin", jump_data[1])

			if velocity_check(jump_data[2]):
				emit_signal("invalid_move")
			emit_signal("correct_velocity", jump_data[2])
			
			emit_signal("end_jump")
		
	if jump_times.empty():
		set_physics_process(false)


func origin_check(new_origin: Vector2):
	prints("o", new_origin.distance_to(global_position))
	return new_origin.distance_to(global_position) > 0.1


func velocity_check(new_vel: Vector2):
	prints("v", new_vel.distance_to(linear_velocity))
	return new_vel.distance_to(linear_velocity) > 0.1


func _on_body_entered(body):
	yield(get_tree(), "physics_frame")
#	var data: Array = collisions.pop_front()
#	if origin_check(data[0]):
#		emit_signal("invalid_move")
#	emit_signal("correct_origin", data[0])
#
#	if velocity_check(data[1]):
#		emit_signal("invalid_move")
#	emit_signal("correct_velocity", data[1])
