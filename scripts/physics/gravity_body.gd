@tool
extends GravitySource
class_name GravityBody

@export
var initial_velocity: Vector3 = Vector3.ZERO:
	set(value):
		initial_velocity = value
		update_gizmos()
