class_name EndPortal
extends Area2D



signal portal_reached

export var _target_node_path: NodePath
export var height_gap := 500.0
export var grav_distance := 300.0
export var grav_factor := 0.001

onready var _target_node: BouncyBall = get_node(_target_node_path)


func _ready():
	global_position.y = - GameState.level_height - height_gap


func _on_Portal_body_entered(body):
	if body == _target_node:
		emit_signal("portal_reached")


func _physics_process(delta: float):
	var vec := global_position - _target_node.global_position
	if vec.length() > grav_distance: return
	_target_node.linear_velocity += vec.normalized() * grav_factor * pow(grav_distance - vec.length(), 2)
