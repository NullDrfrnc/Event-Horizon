@tool
extends EditorPlugin

var gravity_body_orbit_gizmo: GravityBodyOrbitGizmo
var gravity_reciever_gizmo: GravityRecieverGizmo
var mass_display_gizmo: MassDispalayGizmo

func _enter_tree() -> void:
	gravity_body_orbit_gizmo = GravityBodyOrbitGizmo.new()
	add_node_3d_gizmo_plugin(gravity_body_orbit_gizmo)
	
	gravity_reciever_gizmo = GravityRecieverGizmo.new()
	add_node_3d_gizmo_plugin(gravity_reciever_gizmo)
	
	mass_display_gizmo = MassDispalayGizmo.new()
	add_node_3d_gizmo_plugin(mass_display_gizmo)

func _exit_tree() -> void:
	remove_node_3d_gizmo_plugin(gravity_body_orbit_gizmo)
	remove_node_3d_gizmo_plugin(gravity_reciever_gizmo)
	remove_node_3d_gizmo_plugin(mass_display_gizmo)
