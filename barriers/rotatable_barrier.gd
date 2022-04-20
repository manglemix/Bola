class_name RotatableBarrier
extends RigidBody2D


const DENSITY := 1.0 / 500
const MIN_WAKE_UP_ACCEL := 150.0

export var dimensions := Vector2.ONE * 20


func _ready():
	mass = DENSITY * dimensions.x * dimensions.y
	modulate.g = 0.5
	modulate.r = 0.5
	var mesh_node := MeshInstance2D.new()
	mesh_node.mesh = QuadMesh.new()
	mesh_node.mesh.size = dimensions
	add_child(mesh_node)
	collision_layer = 0
	collision_mask = 1
	gravity_scale = 0
	sleeping = true
	can_sleep = true
	var shape_node := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.extents = dimensions / 2
	shape_node.shape = shape
	add_child(shape_node)


func _integrate_forces(_state):
	linear_velocity = Vector2.ZERO
