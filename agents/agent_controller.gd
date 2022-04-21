class_name AgentController
extends Node


var _frame_counter := 0


func _increment_counter():
	_frame_counter += 1


# Called after gravity and drag but before collisions
func poll_mutation(delta: float, ball) -> void:
	_increment_counter()


# Called at the very end of the physics frame
func poll_observe(ball) -> void:
	return
