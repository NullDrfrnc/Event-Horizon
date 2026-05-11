extends CharacterBody3D
class_name Freecam

@export var speed: float = 1.0
@export var mouse_sensitivity: float = 1

@onready var camera: Camera3D = $Camera3D

@onready var actual_sens: float;

func _ready() -> void:
	actual_sens = mouse_sensitivity / 1000

func _physics_process(delta: float) -> void:
	var input_dir = Input.get_vector("left","right","foreward","backward");
	
	velocity = camera.global_transform.basis * Vector3(input_dir.x, 0.0, input_dir.y) * speed
	
	if Input.is_action_pressed("up"):
		velocity.y += 1.0 * speed
	if Input.is_action_pressed("down"):
		velocity.y -= 1.0 * speed
	
	if Input.is_action_just_pressed("ui_cancel"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	move_and_slide()

func _input(event):
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * actual_sens)
		$Camera3D.rotate_x(-event.relative.y * actual_sens)
		$Camera3D.rotation.x = clampf($Camera3D.rotation.x, -deg_to_rad(70), deg_to_rad(70))
