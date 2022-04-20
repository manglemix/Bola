class_name UserInput
extends Node2D


signal try_jump(to)
signal end_jump
signal correct_origin(origin)
signal correct_vel(vel)

export var record_input := false

var count := 0


func _ready():
	assert(position == Vector2.ZERO)


func _physics_process(_delta):
	var origin := global_position.snapped(Vector2.ONE * 0.1)
	var vel: Vector2 = get_parent().linear_velocity.snapped(Vector2.ONE * 0.1)
	
	if Input.is_action_just_pressed("jump"):
		emit_signal("correct_origin", origin)
		var to := get_global_mouse_position().snapped(Vector2.ONE * 0.1)
		
		emit_signal("correct_vel", vel)
		emit_signal("try_jump", to)
		if record_input:
			Replays.log_jump_start(count, to, origin, vel)
	
	elif Input.is_action_just_released("jump"):
		emit_signal("correct_origin", origin)
		emit_signal("correct_vel", vel)
		emit_signal("end_jump")
		if record_input:
			Replays.log_jump_end(count, origin, vel)
	
	count += 1
