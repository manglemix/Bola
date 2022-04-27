class_name BouncyBall
extends KinematicBody2D


const MAX_COLLISIONS := 5
const MAX_SPEED := 1500.0

signal not_landed(angle)
signal landed
signal jumping(direction)
signal jumped
signal collided_with(body)
signal jump_started(to)

export var jump_height := 300.0
export var jump_duration := 0.5
export var max_jumps := 2
export var max_floor_angle_degrees := 60.0
export var bounce_min_velocity := 90.0
export var controller_path: NodePath
export var bounce_modifier := 0.6
export var drag_modifier := 0.00001
export var mass := 1.0
export var gravity_scale := 1.0
export var friction_decel := 500.0

var jumping := false
var jumping_vec: Vector2
var current_jumps := 0
var _jump_timer: Timer
var linear_velocity := Vector2.ZERO

onready var _controller: AgentController = get_node(controller_path)
onready var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity") * gravity_scale
onready var initial_jump_speed := sqrt(gravity * jump_height)
onready var jump_acceleration := (sqrt(gravity) * sqrt(gravity * jump_duration * jump_duration + 8 * jump_height - 4 * jump_duration * initial_jump_speed) + gravity * jump_duration - 2 * initial_jump_speed) / 2 / jump_duration


func set_linear_velocity(velocity: Vector2):
	linear_velocity = velocity


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


func snap_all(snap_size:=0.1):
	var snap := Vector2.ONE * snap_size
	linear_velocity = linear_velocity.snapped(snap)
	global_position = global_position.snapped(snap)


func _physics_process(delta: float):
	linear_velocity += Vector2.DOWN * gravity * delta
#	linear_velocity -= linear_velocity * linear_velocity * drag_modifier * delta
	
	_controller.poll_mutation(delta, self)
	
	if jumping:
		emit_signal("jumping", jumping_vec.angle())
		
		linear_velocity += jumping_vec * jump_acceleration * delta
		
		if _jump_timer.is_stopped():
			jumping = false
			emit_signal("jumped")
	
	var travel := linear_velocity.length() * delta
	var landed := false
	var collision_count := 0
	var collision_normal_sum := Vector2.ZERO
	
	while travel > 0 and collision_count < MAX_COLLISIONS:
		var travel_vec := linear_velocity.normalized() * travel
		var result := move_and_collide(travel_vec, false)
		if result == null:
			break
		
		collision_count += 1
		collision_normal_sum += result.normal
		
		var cancel_vec := linear_velocity.project(result.normal)
		var bounce_vec := cancel_vec * bounce_modifier
		
		if result.collider is SuperBouncyBarrier:
			bounce_vec *= SuperBouncyBarrier.BOUNCE_FACTOR
		if result.collider is RigidBody2D:
			var factor := exp(- result.position.distance_to(result.collider.global_position) / 100)
			bounce_vec *= factor
			cancel_vec *= factor
			
			result.collider.apply_impulse(result.position - result.collider.global_position, (cancel_vec + bounce_vec) * mass)
		
		linear_velocity -= bounce_vec + cancel_vec
		
		if not landed:
			if abs((collision_normal_sum / collision_count).angle_to(Vector2.UP)) < deg2rad(max_floor_angle_degrees):
				current_jumps = 0
				emit_signal("landed")
				landed = true
		
		snap_all()
		_on_collision(result.collider)
		emit_signal("collided_with", result.collider)
		
		travel -= result.travel.length()
	
	if landed:
		linear_velocity -= linear_velocity.normalized() * friction_decel * delta
	elif collision_count > 0:
		emit_signal("not_landed", abs((collision_normal_sum / collision_count).angle_to(Vector2.UP)))
	
	var speed := linear_velocity.length()
	if speed > MAX_SPEED:
		linear_velocity *= MAX_SPEED / speed


func _on_collision(_node: PhysicsBody2D):
	pass
