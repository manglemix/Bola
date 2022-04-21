class_name BreakableBarrier
extends RigidBody2D


const DENSITY := 1.0 / 500
const MIN_WAKE_UP_ACCEL := 150.0

signal broken

export var dimensions := Vector2.ONE * 20


func _ready():
	set_physics_process(false)
	mass = DENSITY * dimensions.x * dimensions.y
	modulate.g = 0.5
	modulate.b = 0.5
	var mesh_node := MeshInstance2D.new()
	mesh_node.mesh = QuadMesh.new()
	mesh_node.mesh.size = dimensions
	add_child(mesh_node)
	collision_layer = 0
#	contact_monitor = true
#	contacts_reported = 1
	collision_mask = 1
	mode = MODE_STATIC
	var shape_node := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.extents = dimensions / 2
	shape_node.shape = shape
	add_child(shape_node)


func apply_impulse(offset: Vector2, impulse: Vector2):
	if impulse.length() / mass > MIN_WAKE_UP_ACCEL:
		emit_signal("broken")
		contact_monitor = false
		mode = MODE_RIGID
		set_physics_process(true)
		yield(get_tree(), "idle_frame")
		.apply_impulse(offset, impulse)


func _physics_process(_delta):
	if global_position.y > 500:
		queue_free()
