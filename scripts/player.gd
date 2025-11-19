extends CharacterBody3D

@export_group("Movement")
@export var walk_speed := 2.4
@export var run_speed := 5
@export var acceleration := 200.0
@export var camera_switch_input_change_delay := 0.3

@export_group("Jump")
@export var jump_impulse := 12.0

@export_group("Jump")

var last_movement_direction := Vector3.BACK

@onready var hallway_camera: Camera3D = $"../hallway_camera"
@onready var vault_camera: Camera3D = $"../vault_camera"
@onready var outside_follow_camera: Camera3D = $"../outside_follow_camera/PathFollow3D/Camera3D"
@onready var player_skin: Node3D = %player_skin
@onready var animation_player: AnimationPlayer = %AnimationPlayer

var active_view_camera: Camera3D = hallway_camera
var active_movement_camera: Camera3D = hallway_camera
var rotation_speed := 12.0
var move_speed := walk_speed
var walk_animation_name := "walking"
var run_animation_name := "running"
var current_move_animation := "walking"
var target_velocity = Vector3.ZERO
var gravity := -30.0

func _ready() -> void:
	hallway_camera.make_current()
	active_view_camera = hallway_camera
	active_movement_camera = hallway_camera
	
func _input(event) -> void:
	if event.is_action_pressed("run"):
		move_speed = run_speed
		current_move_animation = run_animation_name
	
	if event.is_action_released("run"):
		move_speed = walk_speed
		current_move_animation = walk_animation_name

func _physics_process(delta: float) -> void:	
	# JUMP

	
	# MOVEMENT, relative to camera
	var raw_input := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var forward := active_movement_camera.global_basis.z
	var right := active_movement_camera.global_basis.x

	var move_direction := forward * raw_input.y + right * raw_input.x
	move_direction.y = 0.0
	move_direction = move_direction.normalized()
	
	var y_velocity := velocity.y
	velocity.y = 0.0
	velocity.move_toward
	velocity = velocity.move_toward(move_direction * move_speed, acceleration * delta)
	velocity.y = y_velocity + gravity * delta
	
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y += jump_impulse
	
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

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body == self:
		active_view_camera = vault_camera
		active_view_camera.make_current()
		# switch which camera movement relates to at a delay to account for player reaction time.
		await get_tree().create_timer(camera_switch_input_change_delay).timeout
		active_movement_camera = vault_camera

func _on_hallway_area_body_entered(body: Node3D) -> void:
	if body == self:
		active_view_camera = hallway_camera
		active_view_camera.make_current()
		# switch which camera movement relates to at a delay to account for player reaction time.
		await get_tree().create_timer(camera_switch_input_change_delay).timeout
		active_movement_camera = hallway_camera


func _on_outside_area_body_entered(body: Node3D) -> void:
	if body == self:
		active_view_camera = outside_follow_camera
		active_view_camera.make_current()
		# switch which camera movement relates to at a delay to account for player reaction time.
		await get_tree().create_timer(camera_switch_input_change_delay).timeout
		active_movement_camera = outside_follow_camera
