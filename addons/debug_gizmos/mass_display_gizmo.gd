@tool
extends EditorNode3DGizmoPlugin
class_name MassDispalayGizmo

func _init() -> void:
	var mat = StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.no_depth_test = true
	mat.albedo_color = Color.DARK_GOLDENROD
	add_material("mass_sphere", mat)


func _get_gizmo_name() -> String:
	return "MassDispalayGizmo"

func _has_gizmo(for_node_3d: Node3D) -> bool:
	return for_node_3d is GravitySource

func _redraw(gizmo: EditorNode3DGizmo) -> void:
	gizmo.clear()
	
	var node = gizmo.get_node_3d() as GravitySource
	if not node: 
		return
	
	var sphere = SphereMesh.new()
	sphere.height = max(0.5, (0.5 * (node.object_mass / 1000)))
	sphere.radius = max(0.25, (0.25 * (node.object_mass / 1000)))
	
	gizmo.add_mesh(sphere, get_material("mass_sphere"))
