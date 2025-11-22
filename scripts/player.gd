extends CharacterBody3D

@export_group("Movement")
@export var walk_speed := 2.4
@export var run_speed := 5
@export var acceleration := 200.0

@export_group("Jump")
@export var jump_height := 3.5
@export var jump_time_to_peak := 0.5
@export var jump_time_to_descend := 0.4
@export var coyote_time := 0.1
@export var jump_buffer_time := 0.1

var last_movement_direction := Vector3.BACK

@onready var player_skin: Node3D = %player_skin
@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var jump_velocity : float = ((2.0 * jump_height) / jump_time_to_peak)
@onready var jump_gravity : float = ((-2.0 * jump_height) / (jump_time_to_peak * jump_time_to_peak))
@onready var fall_gravity : float = ((-2.0 * jump_height) / (jump_time_to_descend * jump_time_to_descend))
@onready var coyote_timer_node: Timer = $Coyote_Timer

var active_movement_camera: Camera3D
var rotation_speed := 12.0
var move_speed := walk_speed
var walk_animation_name := "walking"
var run_animation_name := "running"
var current_move_animation := "walking"
var target_velocity = Vector3.ZERO
var gravity := -30.0
var is_jump_available := true
var jump_buffer := false
	
func _input(event) -> void:
	if event.is_action_pressed("run"):
		move_speed = run_speed
		current_move_animation = run_animation_name
	
	if event.is_action_released("run"):
		move_speed = walk_speed
		current_move_animation = walk_animation_name

func get_player_gravity() -> float:
	if velocity.y > 0.0:
		return jump_gravity
	else:
		return fall_gravity
	
func jump() -> void:
	velocity.y = jump_velocity
	is_jump_available = false
	
func coyote_timeout() -> void:
	is_jump_available = false

func on_jump_buffer_timeout() -> void:
	jump_buffer = false

func _physics_process(delta: float) -> void:	
	# MOVEMENT, relative to camera
	var raw_input := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var forward := active_movement_camera.global_basis.z
	var right := active_movement_camera.global_basis.x

	var move_direction := forward * raw_input.y + right * raw_input.x
	move_direction.y = 0.0
	move_direction = move_direction.normalized()
	
	var y_velocity := velocity.y
	velocity.y = 0.0
	velocity = velocity.move_toward(move_direction * move_speed, acceleration * delta)
	velocity.y = y_velocity + get_player_gravity() * delta
	
	if not is_on_floor():
		if is_jump_available:
			if coyote_timer_node.is_stopped():
				coyote_timer_node.start(coyote_time)
	else:
		is_jump_available = true
		coyote_timer_node.stop()
		if jump_buffer:
			jump()
			jump_buffer = false
	
	if Input.is_action_just_pressed("jump"):
		if is_jump_available:
			jump()
		else:
			jump_buffer = true
			get_tree().create_timer(jump_buffer_time).timeout.connect(on_jump_buffer_timeout)
	
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
