@tool
extends GravityBody
class_name Planet

@export var planet_size: float = 1.0:
	set(value):
		planet_size = value
		_update_mesh()

@export
var planet_texture: Texture2D:
	set(value):
		planet_texture = value
		_update_mesh()

@export var planet_radial_segments: int = 16:
	set(value):
		planet_radial_segments = value
		_update_mesh()

@export_category("atmosphere")
@export var atmosphere_size: float = 1.0:
	set(value):
		atmosphere_size = value
		_update_mesh()

@export var scale_height: float = 0.08

@export var scatter_strength: float = 1.0

@export var atmosphere_color: Color = Color(0.18, 0.42, 1.0)

@export var mie_color: Color = Color(1.0, 0.8, 0.6)

@export var mie_anisotropy: float = 0.76;

@export var ambient: float = 0.0015;

@export var depth_color_shift: float = 2.0

@onready var atmosphere: MeshInstance3D = $Atmosphere

@onready var ground: MeshInstance3D = $Ground

func _process(_delta: float) -> void:
	var star = get_tree().get_first_node_in_group("stars") as Star
	
	if star and atmosphere and atmosphere.material_override:
		var shader_material = (atmosphere.material_override as ShaderMaterial)
		
		shader_material.set_shader_parameter("planet_position", global_position)
		shader_material.set_shader_parameter("light_dir", (star.global_position - global_position).normalized())
		shader_material.set_shader_parameter("atmosphere_radius", (planet_size + atmosphere_size) / 2)
		shader_material.set_shader_parameter("planet_radius", planet_size / 2)
		shader_material.set_shader_parameter("scale_height", scale_height)
		shader_material.set_shader_parameter("scatter_coeffs", Vector3(atmosphere_color.r, atmosphere_color.g, atmosphere_color.b))
		shader_material.set_shader_parameter("scatter_strength", scatter_strength)
		shader_material.set_shader_parameter("mie_coeffs", Vector3(mie_color.r, mie_color.g, mie_color.b))
		shader_material.set_shader_parameter("mie_anisotropy", mie_anisotropy)
		shader_material.set_shader_parameter("depth_color_shift", depth_color_shift)
		shader_material.set_shader_parameter("ambient", ambient)
		


func _ready() -> void:
	super._ready()
	print("shadering :3")
	var mat := ShaderMaterial.new()
	mat.shader = preload("res://evil_shaders/world/atmosphere.gdshader")
	atmosphere.material_override = mat
	
	print("planet_radius: ", planet_size / 2)
	print("atmosphere_radius: ", (planet_size + atmosphere_size) / 2)
	print("scale_height: ", scale_height)
	
	_update_mesh()

func _update_mesh() -> void:
	if not is_node_ready():
		return
	if not ground:
		ground = $Ground
	if not atmosphere:
		atmosphere = $Atmosphere
	
	ground.mesh = ground.mesh.duplicate() as SphereMesh
	atmosphere.mesh = ground.mesh.duplicate() as SphereMesh
	
	var mat = StandardMaterial3D.new()
	mat.albedo_texture = planet_texture
	
	ground.material_override = mat
	
	ground.mesh.radial_segments = planet_radial_segments
	ground.mesh.rings = int(ceil(planet_radial_segments / 2))
	
	atmosphere.mesh.radial_segments = planet_radial_segments
	atmosphere.mesh.rings = int(ceil(planet_radial_segments / 2))
	
	ground.mesh.radius = planet_size / 2
	ground.mesh.height = planet_size
	
	atmosphere.mesh.radius = (planet_size + atmosphere_size) / 2
	atmosphere.mesh.height = planet_size + atmosphere_size
