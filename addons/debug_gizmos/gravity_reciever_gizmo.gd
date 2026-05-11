@tool
extends EditorNode3DGizmoPlugin
class_name GravityRecieverGizmo

func _init() -> void:
	var mat = StandardMaterial3D.new()
	mat.albedo_color = Color.GOLDENROD
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.no_depth_test = true
	add_material("velocity_line", mat)
	
	mat.albedo_color = Color.DARK_GOLDENROD
	add_material("mass_sphere", mat)
	
	create_handle_material("handles")


func _get_gizmo_name() -> String:
	return "GravityReceiverGizmo"

func _has_gizmo(for_node_3d: Node3D) -> bool:
	return for_node_3d is GravityBody

func _redraw(gizmo: EditorNode3DGizmo) -> void:
	gizmo.clear()
	
	var node = gizmo.get_node_3d() as GravityBody
	if not node: 
		return
	
	var sphere = SphereMesh.new()
	sphere.height = max(0.5, (0.5 * (node.object_mass / 1000)))
	sphere.radius = max(0.25, (0.25 * (node.object_mass / 1000)))
	
	gizmo.add_mesh(sphere, get_material("mass_sphere"))
	
	var lines = PackedVector3Array([
		Vector3.ZERO, node.initial_velocity,
	])
	
	gizmo.add_lines(lines, get_material("velocity_line", gizmo))
