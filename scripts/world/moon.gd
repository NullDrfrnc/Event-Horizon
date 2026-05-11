@tool
extends GravityBody
class_name Moon

func _init() -> void:
	_calculate_orbit_button = _set_stable_orbit

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
