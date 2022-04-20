class_name SuperBouncyBarrier
extends RigidBody2D


const BOUNCE_FACTOR := 5.0

export var dimensions := Vector2.ONE * 20


func calculate_dimensions(from: Vector2, to: Vector2, thickness:=10.0):
	transform.origin = from.linear_interpolate(to, 0.5)
	var rel_vec := to - from
	rotation = rel_vec.angle()
	var length := rel_vec.length()
	dimensions = Vector2(length, thickness)


func _ready():
	modulate.b = 0.5
	modulate.r = 0.5
	var mesh_node := MeshInstance2D.new()
	mesh_node.mesh = QuadMesh.new()
	mesh_node.mesh.size = dimensions
	add_child(mesh_node)
	collision_layer = 0
	contact_monitor = true
	contacts_reported = 1
	collision_mask = 1
	mode = MODE_KINEMATIC
	var shape_node := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.extents = dimensions / 2
	shape_node.shape = shape
	add_child(shape_node)


func _integrate_forces(state):
	for i in state.get_contact_count():
		var node = state.get_contact_collider_object(i)
		yield(get_tree(), "idle_frame")
		node.linear_velocity *= BOUNCE_FACTOR
