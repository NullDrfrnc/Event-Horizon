@tool
extends EditorPlugin

var gizmo_plugin: GravityRecieverGizmo

func _enter_tree() -> void:
	gizmo_plugin = GravityRecieverGizmo.new()
	add_node_3d_gizmo_plugin(gizmo_plugin)

func _exit_tree() -> void:
	remove_node_3d_gizmo_plugin(gizmo_plugin)
