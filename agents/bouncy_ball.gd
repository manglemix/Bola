class_name BouncyBall
extends KinematicBody2D


const MAX_SPEED := 1500.0
const RESET_SPEED := 10.0

signal not_landed(angle)
signal landed
signal jumping(direction)
signal jumped
signal collided_with(body)
signal jump_started(to)

export var initial_jump_speed := 400.0
export var jump_acceleration := 900.0
export var jump_duration := 0.5
export var max_jumps := 2
export var max_floor_angle_degrees := 60.0
export var bounce_min_velocity := 90.0
export var controller_path: NodePath
export var bounce_modifier := 0.8

var jumping := false
var jumping_vec: Vector2
var current_jumps := 0
var _jump_timer: Timer
var linear_velocity := Vector2.ZERO

onready var _controller: AgentController = get_node(controller_path)
onready var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")


func _ready():
	_jump_timer = Timer.new()
	_jump_timer.one_shot = true
	_jump_timer.wait_time = jump_duration
	add_child(_jump_timer)


func jump_to(to: Vector2):
	if jumping or current_jumps >= max_jumps: return
	jumping_vec = (to - global_position).normalized()
	_jump_timer.start()
	emit_signal("jump_started", to)
	current_jumps += 1
	jumping = true
	if linear_velocity.dot(jumping_vec) < 0:
		linear_velocity = Vector2.ZERO
	else:
		linear_velocity = linear_velocity.project(jumping_vec)
	linear_velocity += jumping_vec * initial_jump_speed


func cancel_jump():
	if not jumping: return
	jumping = false
	emit_signal("jumped")


func _physics_process(delta: float):
	linear_velocity += Vector2.DOWN * gravity * delta
	
	if jumping:
		emit_signal("jumping", jumping_vec.angle())
		
		linear_velocity += jumping_vec * jump_acceleration * delta
		
		if _jump_timer.is_stopped():
			jumping = false
			emit_signal("jumped")
#		_controller.linear_velocity = linear_velocity
	
	var in_velocity := linear_velocity
	var travel := linear_velocity.length() * delta
	var landed := false
	var collision_count := 0
	var collision_normal_sum := Vector2.ZERO
	
	while travel > 0:
		var travel_vec := linear_velocity.normalized() * travel
		var result := move_and_collide(travel_vec, false)
		if result == null:
			break
		
		var bounce_vec := linear_velocity.project(result.normal)
		linear_velocity += (- bounce_modifier - 1) * bounce_vec
		
		if linear_velocity.length() < RESET_SPEED:
			linear_velocity = linear_velocity.slide(result.normal)
		
		travel -= result.travel.length()
		if not landed:
			collision_count += 1
			collision_normal_sum += result.normal
			if abs((collision_normal_sum / collision_count).angle_to(Vector2.UP)) < deg2rad(max_floor_angle_degrees):
				current_jumps = 0
				emit_signal("landed")
				landed = true
		
		_on_collision(result.collider)
		emit_signal("collided_with", result.collider)
	
	if collision_count > 0 and not landed:
		emit_signal("not_landed", abs((collision_normal_sum / collision_count).angle_to(Vector2.UP)))
	
	var speed := linear_velocity.length()
	if speed > MAX_SPEED:
		linear_velocity *= MAX_SPEED / speed
	
#	_controller.linear_velocity = linear_velocity


func _on_collision(node: PhysicsBody2D):
	pass
