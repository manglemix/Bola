class_name RandomBarrierGrid
extends Node2D


export var max_barrier_count := 50
export var grid_step := 50.0
export var grid_width = 1000.0
export var max_barrier_steps_bounds := 3
export var breakable_frac := 0.1
export var rotatable_frac := 0.10
export var bouncy_frac := 0.1
export var player_path: NodePath = "Player"
export var barrier_thickness := 10.0
export(Array, PoolVector2Array) var _existing_barrier_points := []

var _rng := RandomNumberGenerator.new()
var _rng_counter := 0.0


func _ready():
	GameState.player = get_node(player_path)
	_rng.seed = GameState.get_seed()
	if GameState.loading_from_disk:
		_rng.seed = GameState.current_seed
		GameState.player.transform.origin = GameState.player_position
		GameState.player.linear_velocity = GameState.player_velocity
		GameState.player.current_jumps = GameState.player_jumps
	
	prints("Using seed:", _rng.seed)
	var barrier_transforms := []
	var barrier_count := 0
	var barrier_points := _existing_barrier_points.duplicate()
	
	for i in range(max_barrier_count):
		var origin := Vector2(
			stepify(_rng.randf_range(- grid_width / 2, grid_width / 2), grid_step),
			stepify(_rng.randf_range(0, - GameState.level_height), grid_step)
		)
		
		var barrier
		
		if _rng.randf() < breakable_frac:
			barrier = BreakableBarrier.new()
			barrier.connect("broken", GameState, "add_idx_to_skip", [i])
			
		elif _rng.randf() < rotatable_frac:
			barrier = RotatableBarrier.new()
			if GameState.loading_from_disk:
				get_tree().connect("idle_frame", barrier, "set_rotation", [GameState.rotatables_rotation[i]], CONNECT_ONESHOT)
			
		elif _rng.randf() < bouncy_frac:
			barrier = SuperBouncyBarrier.new()
			
		else:
			barrier = Barrier.new()
		
		var extents := Vector2.ZERO
		
		while extents.length_squared() == 0:
			extents =  Vector2(
				round(_rng.randf_range(-max_barrier_steps_bounds, max_barrier_steps_bounds)),
				round(_rng.randf_range(- max_barrier_steps_bounds, max_barrier_steps_bounds))
			)
		
		if is_point_between_array(origin, barrier_points) and is_point_between_array(extents, barrier_points):
			barrier.free()
			continue
		
		if GameState.loading_from_disk and i in GameState.idx_to_skip:
			barrier.free()
			continue
		
		if barrier is RotatableBarrier:
			GameState.add_rotatable(barrier, i)
		
		barrier_points.append([origin, extents])
		var barrier_transform: Transform2D = Barrier.calculate_dimensions(
			origin,
			origin + extents * grid_step
		)
		var barrier_length := extents.length() * grid_step
		barrier.dimensions = Vector2(barrier_length, barrier_thickness)
		barrier.transform = barrier_transform
		
		if barrier is Barrier:
			barrier.make_mesh = false
			barrier_transform.x *= barrier_length / barrier_thickness
			barrier_transforms.append(barrier_transform)
			barrier_count += 1
		
		add_child(barrier)
	
	var barrier_meshes := MultiMesh.new()
	barrier_meshes.mesh = QuadMesh.new()
	barrier_meshes.instance_count = barrier_count
	barrier_meshes.mesh.size = Vector2(barrier_thickness, barrier_thickness)
	
	for i in range(barrier_transforms.size()):
		barrier_meshes.set_instance_transform_2d(i, barrier_transforms[i])
	
	var barrier_meshes_node := MultiMeshInstance2D.new()
	barrier_meshes_node.multimesh = barrier_meshes
	add_child(barrier_meshes_node)
	
#	if not GameState.loading_from_disk: GameState.save()


func portal_reached():
	GameState.won()


static func is_point_between(point: Vector2, from: Vector2, to: Vector2) -> bool:
	if from.distance_squared_to(to) < from.distance_squared_to(point): return false
	if not is_equal_approx(from.angle_to(to), from.angle_to(point)): return false
	return true


static func is_point_between_array(point: Vector2, array: Array) -> bool:
	for arr in array:
		if is_point_between(point, arr[0], arr[1]):
			return true
	return false