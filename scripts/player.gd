extends CharacterBody3D

@export_group("Movement")
@export var move_speed:= 2.4
@export var acceleration := 200.0

var last_movement_direction := Vector3.BACK

@onready var camera: Camera3D = $"../Camera3D"
@onready var player_skin: Node3D = %player_skin
@onready var animation_player: AnimationPlayer = %AnimationPlayer

var rotation_speed := 12.0

func _physics_process(delta: float) -> void:
	var raw_input := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var forward := camera.global_basis.z
	var right := camera.global_basis.x

	var move_direction := forward * raw_input.y + right * raw_input.x
	move_direction.y = 0.0
	move_direction = move_direction.normalized()

	velocity = velocity.move_toward(move_direction * move_speed, acceleration * delta)
	move_and_slide()

	if move_direction.length() > 0.2:
		last_movement_direction = move_direction
		# TODO: Turn this into a state machine.
		if animation_player.current_animation != "walking":
			animation_player.play("walking")
	else:
		# TODO: Turn this into a state machine.
		if animation_player.current_animation != "idle":
			animation_player.play("idle")

	var target_angle := Vector3.BACK.signed_angle_to(last_movement_direction, Vector3.UP)

	player_skin.global_rotation.y = lerp_angle(player_skin.global_rotation.y, target_angle, rotation_speed * delta)
