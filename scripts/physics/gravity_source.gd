@tool
extends Node3D
class_name GravitySource

@export_category("physics")
@export
var object_mass: float = 10.0:
	set(value):
		object_mass = value
		update_gizmos()

func _ready() -> void:
	self.add_to_group("gravity_sources")
	print(owner, " has registered a gravity source with a mass of: ", object_mass)

# Calculate the pull this object has on another, and return the vector of that pull
func calculate_acceleration_at(other_position: Vector3) -> Vector3:
	# Calculate the difference between the two vectors
	var difference := global_position - other_position
	# Normalize the difference to get the direction of the force
	var direction := difference.normalized()
	# For the distance squared, square the length of the difference
	var distance_sq = difference.length_squared()
	
	return direction * Constants.G * object_mass / distance_sq
