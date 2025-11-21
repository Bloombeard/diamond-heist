extends CharacterBody3D

@export_group("Movement")
@export var walk_speed := 2.4
@export var run_speed := 5
@export var acceleration := 200.0

var last_movement_direction := Vector3.BACK

@onready var player_skin: Node3D = %player_skin
@onready var animation_player: AnimationPlayer = %AnimationPlayer

var active_movement_camera: Camera3D
var rotation_speed := 12.0
var move_speed := walk_speed
var walk_animation_name := "walking"
var run_animation_name := "running"
var current_move_animation := "walking"
	
func _input(event) -> void:
	if event.is_action_pressed("run"):
		move_speed = run_speed
		current_move_animation = run_animation_name
	
	if event.is_action_released("run"):
		move_speed = walk_speed
		current_move_animation = walk_animation_name

func _physics_process(delta: float) -> void:	
	var raw_input := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var forward := active_movement_camera.global_basis.z
	var right := active_movement_camera.global_basis.x

	var move_direction := forward * raw_input.y + right * raw_input.x
	move_direction.y = 0.0
	move_direction = move_direction.normalized()

	velocity = velocity.move_toward(move_direction * move_speed, acceleration * delta)
	move_and_slide()

	if move_direction.length() > 0.2:
		last_movement_direction = move_direction
		# TODO: Turn this into a state machine.
		if animation_player.current_animation != "walking" || animation_player.current_animation != "running":
			animation_player.play(current_move_animation)
	else:
		# TODO: Turn this into a state machine.
		if animation_player.current_animation != "idle":
			animation_player.play("idle")

	var target_angle := Vector3.BACK.signed_angle_to(last_movement_direction, Vector3.UP)

	player_skin.global_rotation.y = lerp_angle(player_skin.global_rotation.y, target_angle, rotation_speed * delta)
