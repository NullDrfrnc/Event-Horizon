@tool
extends EditorNode3DGizmoPlugin
class_name GravityBodyOrbitGizmo

func _init() -> void:
	var mat = StandardMaterial3D.new()
	mat.albedo_color = Color.FOREST_GREEN
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.no_depth_test = true
	add_material("orbit", mat)


func _get_gizmo_name() -> String:
	return "GravityBodyOrbitGizmo"

func _has_gizmo(for_node_3d: Node3D) -> bool:
	return for_node_3d is GravityBody

func _redraw(gizmo: EditorNode3DGizmo) -> void:
	gizmo.clear()
	
	var node = gizmo.get_node_3d() as GravityBody
	if not node: 
		return
	
	var points: PackedVector3Array;
	
	if node is Moon:
		points = _predict_lunar_orbit(node)
	else:
		points = _predict_orbit(node)
	
	var lines := PackedVector3Array()
	for i in points.size() - 1:
		lines.append(node.to_local(points[i]))
		lines.append(node.to_local(points[i + 1]))
	
	gizmo.add_lines(lines, get_material("orbit", gizmo))

func _predict_lunar_orbit(node: GravityBody, steps: int = 20000, delta: float = 0.1) -> PackedVector3Array:
	var points := PackedVector3Array()
	var position := node.global_position
	var velocity := node.initial_velocity
	
	var source = node.get_parent_node_3d() as GravitySource
	
	for i in steps:
		var acceleration = Vector3.ZERO
		acceleration = source.calculate_gravity_at(position)
		
		velocity += acceleration * delta
		position += velocity * delta
		points.append(position)
	
	return points;

func _predict_orbit(node: GravityBody, steps: int = 20000, delta: float = 0.1) -> PackedVector3Array:
	var points := PackedVector3Array()
	var position := node.global_position
	var velocity := node.initial_velocity
	
	# Get all sources of gravity
	var sources = node.get_tree().get_nodes_in_group(Groups.gravity_sources)
	
	for i in steps:
		var acceleration = Vector3.ZERO
		for source in sources:
			if source == node: continue;
			# Still hate doing this
			source = source as GravitySource
			acceleration += source.calculate_gravity_at(position)
		
		velocity += acceleration * delta
		position += velocity * delta
		points.append(position)
	
	return points;
