@tool
extends GravityBody
class_name Planet

@export var height: float = 1.0:
	set(value):
		height = value
		_update_mesh()

@export
var texture: Texture2D:
	set(value):
		texture = value
		_update_mesh()

@onready var mesh: MeshInstance3D = $mesh

func _ready() -> void:
	_update_mesh()

func _update_mesh() -> void:
	if not is_node_ready():
		return
	if not mesh:
		mesh = $mesh
	
	mesh.mesh = mesh.mesh.duplicate()
	
	var mat = StandardMaterial3D.new()
	mat.albedo_texture = texture
	
	mesh.material_override = mat
	
	mesh.mesh.radius = height / 2
	mesh.mesh.height = height
