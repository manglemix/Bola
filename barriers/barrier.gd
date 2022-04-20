class_name Barrier
extends StaticBody2D


export var dimensions := Vector2.ONE * 20
export var make_mesh := true


static func calculate_dimensions(from: Vector2, to: Vector2) -> Transform2D:
	var rel_vec := to - from
	return Transform2D(rel_vec.angle(), from.linear_interpolate(to, 0.5))


func _ready():
	if make_mesh:
		var mesh_node := MeshInstance2D.new()
		mesh_node.mesh = QuadMesh.new()
		mesh_node.mesh.size = dimensions
		add_child(mesh_node)
	
	collision_layer = 0
	collision_mask = 1
	var shape_node := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.extents = dimensions / 2
	shape_node.shape = shape
	add_child(shape_node)
