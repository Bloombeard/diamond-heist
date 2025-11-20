extends CharacterBody3D

@export_group("Movement")
@export var move_speed:= 2.4
var current_speed := move_speed
@export var acceleration := 200.0

var last_movement_direction := Vector3.BACK

@onready var hallway_camera: Camera3D = $"../hallway_camera"
@onready var vault_camera: Camera3D = $"../vault_camera"
@onready var player_skin: Node3D = %player_skin
@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var slasher := $player_skin/Slasher

var active_camera: Camera3D = hallway_camera
var rotation_speed := 12.0

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
	
	if Input.is_action_pressed("block"):
		current_speed = 0
	else:
		current_speed = move_speed
	
	velocity = velocity.move_toward(move_direction * current_speed, acceleration * delta)
	if slasher.current_state == slasher.attack_state.ACTIVE or slasher.current_state == slasher.attack_state.STARTUP:
		velocity = velocity.move_toward(last_movement_direction * current_speed*1.5, acceleration * delta)
	elif slasher.current_state != slasher.attack_state.NONE:
		velocity = Vector3.ZERO
	move_and_slide()

	if velocity.length() > 0.2 and slasher.current_state == slasher.attack_state.NONE:
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


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body == self:
		active_camera = vault_camera
		active_camera.make_current()

func _on_area_3d_body_exited(body: Node3D) -> void:
	if body == self:
		active_camera = hallway_camera
		active_camera.make_current()
