extends CharacterBody3D

@export_group("Movement")
@export var walk_speed := 2.4
@export var run_speed := 5
@export var acceleration := 200.0
var stagger_timer := 120

@export_group("Jump")
@export var jump_height := 3.5
@export var jump_time_to_peak := 0.5
@export var jump_time_to_descend := 0.4
@export var coyote_time := 0.1
@export var jump_buffer_time := 0.1

@export_group("Combat")
@export var stagger_length := 60
@export var invulnerability_frames := 40

var last_movement_direction := Vector3.BACK

@onready var player_skin: Node3D = %player_skin
@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var slasher := $player_skin/Slasher
@onready var slasher_hurtbox := $player_skin/Slasher/hurtbox
@onready var attack_direction: Vector2
@onready var attack_buffer := Vector2.ZERO
@onready var statem = $state_machine
@onready var hitbox = $hitbox

@onready var jump_velocity : float = ((2.0 * jump_height) / jump_time_to_peak)
@onready var jump_gravity : float = ((-2.0 * jump_height) / (jump_time_to_peak * jump_time_to_peak))
@onready var fall_gravity : float = ((-2.0 * jump_height) / (jump_time_to_descend * jump_time_to_descend))
@onready var coyote_timer_node: Timer = $Coyote_Timer

var active_movement_camera: Camera3D
var rotation_speed := 12.0
var move_speed := run_speed
var walk_animation_name := "walking"
var run_animation_name := "running"
var idle_animation_name := "idle"
var current_animation := "idle"
var target_velocity = Vector3.ZERO
var gravity := -30.0
var is_jump_available := true
var jump_buffer := false

func get_player_gravity() -> float:
	if velocity.y > 0.0:
		return jump_gravity
	else:
		return fall_gravity
	
func jump() -> void:
	jump_buffer = false
	velocity.y = jump_velocity
	is_jump_available = false
	
func coyote_timeout() -> void:
	is_jump_available = false

func on_jump_buffer_timeout() -> void:
	jump_buffer = false

func _ready() -> void:
	slasher_hurtbox.set_collision_layer_value(3, true)
	slasher_hurtbox.set_collision_mask_value(3, true)
	statem.stg_length = stagger_length
	statem.iframes = invulnerability_frames

func _physics_process(delta: float) -> void:	
	# MOVEMENT, relative to camera
	var raw_input := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var forward := active_movement_camera.global_basis.z
	var right := active_movement_camera.global_basis.x
	
	var move_direction := forward * raw_input.y + right * raw_input.x
	move_direction.y = 0.0
	move_direction = move_direction.normalized()
	
	if move_direction != Vector3.ZERO and statem.atk_state != statem.ATK_RECOVERY:
		last_movement_direction = move_direction
	
	# ATTACKING
	if Input.is_action_just_pressed("slash_left") or Input.is_action_just_pressed("slash_right") or Input.is_action_just_pressed("slash_up") or Input.is_action_just_pressed("slash_down"):
		var current_attack = floor(Input.get_vector("slash_left", "slash_right", "slash_up", "slash_down"))
		if current_attack != Vector2.ZERO:
			attack_buffer = current_attack
	
	if statem.atk_state == statem.ATK_NONE or statem.atk_state == statem.ATK_RECOVERY:
		attack_direction = attack_buffer
		attack_buffer = Vector2.ZERO
	else:
		attack_direction = Vector2.ZERO

	# coyote time
	if not is_on_floor():
		if is_jump_available:
			if coyote_timer_node.is_stopped():
				coyote_timer_node.start(coyote_time)
	elif statem.atk_state == statem.ATK_RECOVERY:
		if coyote_timer_node.is_stopped():
			coyote_timer_node.start(coyote_time)
	else:
		is_jump_available = true
		coyote_timer_node.stop()
	
	# assign states n stuff
	if statem.state < statem.ATTACKING:
		if not is_on_floor() and velocity.y < 0.0:
			statem.state = statem.FALLING
		elif is_on_floor() and Input.is_action_pressed("block"):
			statem.state = statem.BLOCKING
		elif is_on_floor() and raw_input != Vector2.ZERO:
			statem.state = statem.RUNNING
		else:
			statem.state = statem.IDLE
		if Input.is_action_just_pressed("jump"):
			jump_buffer = true
			get_tree().create_timer(jump_buffer_time).timeout.connect(on_jump_buffer_timeout)
	
	if is_jump_available and jump_buffer and PlayerVariables.has_jump:
		statem.state = statem.JUMPING
		jump()
		
	if attack_direction != Vector2.ZERO and statem.state != statem.STAGGERED:
		statem.atk_counter = 0
		if statem.state == statem.BLOCKING or statem.state == statem.DRAWING:
			statem.state = statem.DRAWING
		else:
			statem.state = statem.ATTACKING
	
	if statem.invuln:
		hitbox.monitoring = false
	else:
		hitbox.monitoring = true
	
	if hitbox.has_overlapping_areas():
		statem.invuln = true
		if PlayerVariables.armor == 0:
			slasher.combo_counter = 0
			slasher.combo_timer = 0
			print("player: ow!")
			statem.state = statem.STAGGERED
		else:
			PlayerVariables.armor -= 1
			print("player: ", PlayerVariables.armor)
			statem.stg_counter == statem.stg_length

	# states!
	if statem.state == statem.STAGGERED:
		statem.invuln = true
		statem.icounter = 1
		move_speed = 0
		# current_animation = stagger_animation_name
	elif statem.state == statem.ATTACKING:
		move_speed = walk_speed
		if not is_on_floor():
			move_speed = 0
		move_direction = last_movement_direction
		current_animation = walk_animation_name
	elif statem.state == statem.JUMPING:
		move_speed = run_speed
		current_animation = idle_animation_name
		# current_animation = jump_animation_name
	elif statem.state == statem.BLOCKING:
		move_speed = 0
		current_animation = idle_animation_name
		#current_animation = block_animation_name
	elif statem.state == statem.DRAWING:
		current_animation = walk_animation_name
	elif statem.state == statem.RUNNING:
		move_speed = run_speed
		current_animation = run_animation_name
	elif statem.state == statem.FALLING:
		move_speed = run_speed
		current_animation = walk_animation_name
	else:
		current_animation = idle_animation_name
		move_speed = run_speed
	
	# final movement
	var y_velocity := velocity.y
	velocity.y = 0.0
	velocity = velocity.move_toward(move_direction * move_speed, acceleration * delta)
	if statem.state != statem.ATTACKING:
		velocity.y = y_velocity + get_player_gravity() * delta
	move_and_slide()

	animation_player.play(current_animation)
	var target_angle := Vector3.BACK.signed_angle_to(last_movement_direction, Vector3.UP)
	player_skin.global_rotation.y = lerp_angle(player_skin.global_rotation.y, target_angle, rotation_speed * delta)
