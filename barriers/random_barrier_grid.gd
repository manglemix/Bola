class_name RandomBarrierGrid
extends Node2D


export var max_barrier_count := 65
export var grid_start_height := 200.0
export var grid_end_height := 2000.0
export var grid_step := 25.0
export var grid_width = 1500.0
export var max_barrier_steps_bounds := 6
export var breakable_frac := 0.1
export var rotatable_frac := 0.1
export var bouncy_frac := 0.1
export var barrier_thickness := 10.0
export var verticality := 1.0
export(Array, PoolVector2Array) var _existing_barrier_points := []

var _rng := RandomNumberGenerator.new()
var _rng_counter := 0.0


func _ready():
	_rng.seed = GameState.get_seed()
	prints("Using seed:", _rng.seed)
	var barrier_transforms := []
	var barrier_count := 0
	var barrier_points := _existing_barrier_points.duplicate()
	var i := 0
	
	while i < max_barrier_count:
		var origin := Vector2(
			stepify(_rng.randf_range(- grid_width / 2, grid_width / 2), grid_step),
			stepify(_rng.randf_range(-grid_start_height, - grid_end_height), grid_step)
		)
		
		var barrier
		
		if _rng.randf() < breakable_frac:
			barrier = BreakableBarrier.new()
			
		elif _rng.randf() < rotatable_frac:
			barrier = RotatableBarrier.new()
			
		elif _rng.randf() < bouncy_frac:
			barrier = SuperBouncyBarrier.new()
			
		else:
			barrier = Barrier.new()
		
		var extents := Vector2.ZERO
		
		while extents.length_squared() == 0 or origin.y + extents.y > - grid_start_height:
			extents =  Vector2(
				round(_rng.randf_range(-max_barrier_steps_bounds, max_barrier_steps_bounds) / verticality),
				round(_rng.randf_range(-max_barrier_steps_bounds, max_barrier_steps_bounds) * verticality)
			) * grid_step
		
		extents += origin
		var origin_result := is_point_between_array(origin, barrier_points)
		var extent_result := is_point_between_array(extents, barrier_points)
		
		if origin_result[0] and extent_result[0]:
			barrier.free()
			continue
		
		if origin_result[0] != extent_result[0]:
			if origin_result[0]:
				if is_point_between(origin_result[1], origin, extents) or is_point_between(origin_result[2], origin, extents):
					barrier.free()
					continue
			elif is_point_between(extent_result[1], origin, extents) or is_point_between(extent_result[2], origin, extents):
				barrier.free()
				continue
		
		i += 1
		barrier_points.append([origin, extents])
		var barrier_transform: Transform2D = Barrier.calculate_dimensions(
			origin,
			extents
		)
		var barrier_length := origin.distance_to(extents)
		barrier.dimensions = Vector2(barrier_length, barrier_thickness)
		barrier.transform = barrier_transform
		
		if barrier is Barrier and not barrier is SuperBouncyBarrier:
			barrier.make_mesh = false
			barrier_transform.x *= barrier_length / barrier_thickness
			barrier_transforms.append(barrier_transform)
			barrier_count += 1
		
		add_child(barrier)
	
	var barrier_meshes := MultiMesh.new()
	barrier_meshes.mesh = QuadMesh.new()
	barrier_meshes.instance_count = barrier_count
	barrier_meshes.mesh.size = Vector2(barrier_thickness, barrier_thickness)
	
	for j in range(barrier_transforms.size()):
		barrier_meshes.set_instance_transform_2d(j, barrier_transforms[j])
	
	var barrier_meshes_node := MultiMeshInstance2D.new()
	barrier_meshes_node.multimesh = barrier_meshes
	add_child(barrier_meshes_node)


static func is_point_between(point: Vector2, from: Vector2, to: Vector2) -> bool:
	if from.distance_squared_to(to) < from.distance_squared_to(point): return false
	if not is_equal_approx(from.angle_to(to), from.angle_to(point)): return false
	return true


static func is_point_between_array(point: Vector2, array: Array) -> Array:
	for arr in array:
		if is_point_between(point, arr[0], arr[1]):
			return [true, arr[0], arr[1]]
	return [false]
