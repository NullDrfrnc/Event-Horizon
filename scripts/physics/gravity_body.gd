@tool
extends GravitySource
class_name GravityBody

@export var initial_velocity: Vector3 = Vector3.ZERO:
	set(value):
		initial_velocity = value
		update_gizmos()

var velocity: Vector3 = Vector3.ZERO

var prev_position: Vector3 = Vector3.ZERO

@export_tool_button("Calculate Stable Orbit")
var _calculate_orbit_button = _set_stable_orbit

@export_category("orbit")
@export var orbit_target: NodePath

func _ready() -> void:
	super._ready()
	velocity = initial_velocity
	prev_position = global_position
	add_to_group(Groups.gravity_bodies)
	set_notify_transform(true)

func _physics_process(delta: float) -> void:
	if !Engine.is_editor_hint():
		# Default is no acceleration
		var acceleration = Vector3.ZERO;
		prev_position = global_position;
		
		for source in get_tree().get_nodes_in_group(Groups.gravity_sources):
			if source == self: continue
			# Godot didn't want to make the nodes GravitySources, but we can fix that!
			source = source as GravitySource
			# Add acceleration from the gravity to the total
			acceleration += source.calculate_gravity_at(global_position)
		
		# Leapfrog :D (no clue how it works tbh)
		velocity += acceleration * delta
		global_position += velocity * delta

func _process(delta: float) -> void:
	if !Engine.is_editor_hint():
		if Constants.debug:
			Constants.draw_debug_line(global_position, global_position + velocity, Color.WEB_PURPLE)
			Constants.draw_dot(global_position, Color.AQUA)

func _set_stable_orbit() -> void:
	if orbit_target.is_empty(): 
		push_error("No orbit target set!")
		return
	
	var target = get_node(orbit_target) as GravitySource
	if target == null:
		push_error("Orbit target is not a GravitySource!")
		return
	
	initial_velocity = Constants.calculate_stable_orbit_velocity(self, target)
	update_gizmos()

func _notification(what: int) -> void:
	if what == NOTIFICATION_TRANSFORM_CHANGED:
		update_gizmos();
