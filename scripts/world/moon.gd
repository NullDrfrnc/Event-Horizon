@tool
extends GravityBody
class_name Moon

@export var height: float = 1.0:
	set(value):
		height = value
		_update_mesh()

@export
var texture: Texture2D:
	set(value):
		texture = value
		_update_mesh()

@onready var mesh: MeshInstance3D = $Mesh

func _init() -> void:
	_calculate_orbit_button = _set_stable_orbit

func _ready() -> void:
	super._ready()
	_update_mesh()

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint(): return;
	
	var parent = get_parent() as GravitySource;
	if parent == null: return;
	
	var acceleration = parent.calculate_gravity_at(global_position)
	
	velocity += acceleration * delta
	global_position += velocity * delta

func _set_stable_orbit() -> void:
	var parent = get_parent() as GravitySource
	if parent == null:
		push_error("Parent is not a GravitySource!")
		return
	initial_velocity = Constants.calculate_stable_orbit_velocity(self, parent)
	update_gizmos()

func _update_mesh() -> void:
	if not is_node_ready():
		return
	if not mesh:
		mesh = $Mesh
	
	mesh.mesh = mesh.mesh.duplicate() as SphereMesh
	
	var mat = StandardMaterial3D.new()
	mat.albedo_texture = texture
	
	mesh.material_override = mat
	
	mesh.mesh.radius = height / 2
	mesh.mesh.height = height
