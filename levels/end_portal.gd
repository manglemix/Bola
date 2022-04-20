class_name EndPortal
extends Area2D


signal portal_reached

export var _target_node_path: NodePath
export var height_gap := 500.0

onready var _target_node := get_node(_target_node_path)


func _ready():
	global_position.y = - GameState.level_height - height_gap


func _on_Portal_body_entered(body):
	if body == _target_node:
		emit_signal("portal_reached")
