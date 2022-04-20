class_name BreakableBarrier
extends RigidBody2D


const DENSITY := 1.0 / 500
const MIN_WAKE_UP_ACCEL := 150.0

signal broken

export var dimensions := Vector2.ONE * 20


func _ready():
	mass = DENSITY * dimensions.x * dimensions.y
	modulate.g = 0.5
	modulate.b = 0.5
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
		var impulse_vec: Vector2 = state.get_contact_collider_object(i).mass * state.get_contact_collider_velocity_at_position(i)
		if impulse_vec.length() / mass > MIN_WAKE_UP_ACCEL:
			emit_signal("broken")
			contact_monitor = false
			var rel_vec: Vector2 = state.get_contact_collider_position(i) - global_position
			set_deferred("mode", MODE_RIGID)
			yield(get_tree(), "idle_frame")
			call_deferred("apply_impulse", rel_vec, impulse_vec)
	
	if sleeping: return
	if global_position.y > 500:
		queue_free()
