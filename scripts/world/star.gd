@tool
extends GravitySource
class_name Star

@export var height: float = 1.0:
	set(value):
		height = value
		_update()

@export var star_color: Color = Color.GOLD:
	set(value):
		star_color = value
		_update()

@export_category("Lighting")
@export var light_color: Color = Color.LIGHT_GOLDENROD:
	set(value):
		light_color = value
		_update()

# Responsible for brightness
@export var light_energy: float = 5.0:
	set(value):
		light_energy = value
		_update()

# Distance the "sunrays" will reach (value * 1000)
@export var light_range: float = 15:
	set(value):
		light_range = value
		_update()

@export var light_attenuation: float = 0.25:
	set(value):
		light_attenuation = value
		_update()

@onready var mesh: MeshInstance3D = $Mesh

@onready var light: OmniLight3D = $Light

func _ready() -> void:
	super._ready()
	add_to_group("stars")
	_update()

func _update() -> void:
	if not is_node_ready():
		return
	if not mesh:
		mesh = $Mesh
	if not light:
		light = $Light
	
	mesh.mesh = mesh.mesh.duplicate() as SphereMesh
	var mat = StandardMaterial3D.new()
	mat.albedo_color = star_color
	mat.emission_enabled = true
	mat.emission_energy_multiplier = light_energy
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	
	mesh.material_override = mat
	
	mesh.mesh.radius = height / 2
	mesh.mesh.height = height
	
	light.light_color = light_color
	light.light_energy = light_energy
	light.omni_range = light_range * 1000
	light.omni_attenuation = light_attenuation
