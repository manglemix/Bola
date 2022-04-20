class_name BouncyBall
extends RigidBody2D


const DEATH_DEPTH := 500.0
const SIDE_LIMIT := 1500.0
const HEIGHT_LIMIT := 4500.0
const MAX_SPEED := 1500.0
const RESET_SPEED := 10.0

signal not_landed(angle)
signal landed
signal jumping(direction)
signal jumped
signal fell_out
signal jump_started(to)

export var initial_jump_speed := 400.0
export var jump_acceleration := 900.0
export var jump_duration := 0.5
export var max_jumps := 2
export var max_floor_angle_degrees := 60.0
export var bounce_min_velocity := 90.0

var jumping := false
var jumping_vec: Vector2
var current_jumps := 0
var _current_jump_duration := 0.0


func _physics_process(delta):
	if jumping:
		emit_signal("jumping", jumping_vec.angle())
		
		apply_central_impulse(
			(
				jumping_vec * jump_acceleration * delta
			) * mass
		)
		_current_jump_duration += delta
		if _current_jump_duration > jump_duration:
			jumping = false
			emit_signal("jumped")


func jump_to(to: Vector2):
	if jumping: return
	jumping_vec = (to - global_position).normalized()
	_current_jump_duration = 0
	if current_jumps < max_jumps:
		emit_signal("jump_started", to)
		current_jumps += 1
		jumping = true
		
		var velocity_nullify := Vector2(linear_velocity.x, 0)
		if (linear_velocity.y > 0) != (jumping_vec.y > 0):
			velocity_nullify.y = linear_velocity.y
		
		apply_central_impulse(
			(initial_jump_speed * jumping_vec - velocity_nullify) * mass
		)


func cancel_jump():
	if not jumping: return
	jumping = false
	emit_signal("jumped")


func _integrate_forces(state: Physics2DDirectBodyState):
	var normal_sum := Vector2.ZERO
	var normal_count := state.get_contact_count()
	var failed_landing := false
	var speed := linear_velocity.length()
	
	for i in normal_count:
		var surface_normal: Vector2 = state.get_contact_local_normal(i)
		
		if speed < bounce_min_velocity:
			linear_velocity -= linear_velocity.project(surface_normal)
		
		normal_sum += surface_normal
		var angle := abs(surface_normal.angle_to(Vector2.UP))
		if angle < deg2rad(max_floor_angle_degrees):
			emit_signal("landed")
			current_jumps = 0
			failed_landing = false
			break
		else:
			failed_landing = true
	
	if failed_landing:
		assert(normal_count > 0)
		if normal_count == 1:
			emit_signal("not_landed", abs(normal_sum.angle_to(Vector2.UP)))
		else:
			normal_sum /= normal_count
			var angle := abs(normal_sum.angle_to(Vector2.UP))
			if angle < deg2rad(max_floor_angle_degrees) and speed <= RESET_SPEED:
				emit_signal("landed")
				current_jumps = 0
			else:
				emit_signal("not_landed", angle)
	
	if global_position.y > DEATH_DEPTH or \
	global_position.y < - HEIGHT_LIMIT or \
	abs(global_position.x) > SIDE_LIMIT:
		emit_signal("fell_out")
		return
	
	if speed > MAX_SPEED:
		linear_velocity *= MAX_SPEED / speed
