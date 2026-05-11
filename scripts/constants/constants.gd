@tool
extends Node

const G: float = 100;

var debug: bool = false;

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("enable_debug"):
		debug = !debug;
		print("debug ", debug)

func draw_debug_line(point_1: Vector3, point_2: Vector3, color: Color = Color.WHITE) -> void:
	var mesh_instance := MeshInstance3D.new()
	var immidiate_mesh := ImmediateMesh.new()
	var material := StandardMaterial3D.new()
	
	mesh_instance.mesh = immidiate_mesh
	mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	
	immidiate_mesh.surface_begin(Mesh.PRIMITIVE_LINES, material)
	immidiate_mesh.surface_add_vertex(point_1)
	immidiate_mesh.surface_add_vertex(point_2)
	immidiate_mesh.surface_end()
	
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = color
	material.no_depth_test = true
	
	add_child(mesh_instance)
	
	await get_tree().process_frame
	mesh_instance.queue_free()

func draw_dot(position: Vector3, color: Color = Color.WHITE) -> void:
	var mesh_instance := MeshInstance3D.new()
	var sphere_mesh := SphereMesh.new()
	var material := StandardMaterial3D.new()
	
	mesh_instance.mesh = sphere_mesh
	mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	mesh_instance.position = position
	
	sphere_mesh.surface_set_material(0, material)
	sphere_mesh.height = 0.5
	sphere_mesh.radius = 0.25
	
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = color
	material.no_depth_test = true
	
	add_child(mesh_instance)

func calculate_stable_orbit_velocity(body: GravityBody, target: GravitySource) -> Vector3:
	var to_target = target.global_position - body.global_position
	var distance = to_target.length()
	
	var speed = sqrt(Constants.G * (target.object_mass / 1000.0) / distance)
	
	# Loodrecht op de richting naar het doelobject
	var direction = to_target.normalized().cross(Vector3.UP).normalized()
	
	return direction * speed
