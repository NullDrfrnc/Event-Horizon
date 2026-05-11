@tool
extends Node3D
class_name GravitySource

@export_category("physics")
@export var object_mass: float = 10.0:
	set(value):
		object_mass = value
		update_gizmos()

func _ready() -> void:
	self.add_to_group(Groups.gravity_sources)
	set_notify_transform(true)

# Calculate the pull this object has on another, and return the vector of that pull
func calculate_gravity_at(other_position: Vector3) -> Vector3:
	# Calculate the difference between the two vectors
	var difference := global_position - other_position
	# Normalize the difference to get the direction of the force
	var direction := difference.normalized()
	# For the distance squared, square the length of the difference
	var distance_sq = max(0.01, difference.length_squared())
	
	return direction * Constants.G * (object_mass / 1000) / distance_sq

func _notification(what: int) -> void:
	if what == NOTIFICATION_TRANSFORM_CHANGED:
		update_gizmos();
		
		for body in get_tree().get_nodes_in_group(Groups.gravity_bodies):
			body.update_gizmos()
