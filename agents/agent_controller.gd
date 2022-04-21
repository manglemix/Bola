class_name AgentController
extends Node2D


signal try_jump(to)
signal end_jump
signal correct_origin(origin)
signal correct_velocity(vel)

var linear_velocity := Vector2.ZERO
var count := 0


func _ready():
	assert(position == Vector2.ZERO)


func _physics_process(_delta):
	count += 1
	linear_velocity = get_parent().linear_velocity
