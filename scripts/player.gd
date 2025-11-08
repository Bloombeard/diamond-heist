extends CharacterBody3D

@export_group("Movement")
@export var move_speed:= 8.0
@export var acceleration := 20.0

@onready var hallway_camera: Camera3D = $"../hallway_camera"
@onready var vault_camera: Camera3D = $"../vault_camera"

var active_camera: Camera3D = hallway_camera

func _ready() -> void:
	hallway_camera.make_current()
	active_camera = hallway_camera

func _physics_process(delta: float) -> void:
	var raw_input := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var forward := active_camera.global_basis.z
	var right := active_camera.global_basis.x

	var move_direction := forward * raw_input.y + right * raw_input.x
	move_direction.y = 0.0
	move_direction = move_direction.normalized()

	velocity = velocity.move_toward(move_direction * move_speed, acceleration * delta)
	move_and_slide()


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body == self:
		active_camera = vault_camera
		active_camera.make_current()

func _on_area_3d_body_exited(body: Node3D) -> void:
	if body == self:
		active_camera = hallway_camera
		active_camera.make_current()
