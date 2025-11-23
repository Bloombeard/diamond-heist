extends CharacterBody3D

@export var player_path: NodePath
@export var move_speed := 4.0
@export var sight_distance := 20
@export var acceleration := 200.0

@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
@onready var statem = $state_machine
@onready var enemy_skin = $enemy_skin

@onready var player = get_node(player_path)
@onready var idle_distance = randi_range(3,5)
@onready var attack_direction = Vector2(1.0,0)

var direction_to_player := Vector3.ZERO

func _ready() -> void:
	pass
	
func _physics_process(delta: float) -> void:
	velocity = Vector3.ZERO
	var current_speed = move_speed
	var choose_attack = randi_range(0,99)
	
	var target_angle := Vector3.BACK.signed_angle_to(direction_to_player, Vector3.UP)
	var rotation_speed := 12.0
	enemy_skin.global_rotation.y = lerp_angle(enemy_skin.global_rotation.y, target_angle, rotation_speed * delta)
	
	nav_agent.set_target_position(player.global_position)
	var next_nav_point := nav_agent.get_next_path_position()
	
	if statem.state != statem.ATTACKING:
		direction_to_player = self.global_position.direction_to(player.global_position)
		statem.atk_counter = 0
		if self.global_position.distance_to(player.global_position) <= idle_distance:
			if choose_attack == 0:
				statem.state = statem.ATTACKING
			else:
				statem.state = statem.RUNNING
		elif self.global_position.distance_to(player.global_position) <= sight_distance:
			statem.state = statem.RUNNING
		else:
			statem.state = statem.IDLE
	
	# movement
	var move_direction = (next_nav_point - global_position).normalized()
	if statem.state == statem.ATTACKING:
		move_direction = direction_to_player
		if statem.atk_state != statem.ATK_RECOVERY:
			current_speed = move_speed / 6
		else:
			current_speed = 0
	elif statem.state == statem.RUNNING:
		if self.global_position.distance_to(player.global_position) <= idle_distance:
			current_speed = move_speed / 4
			var temp_direction = move_direction
			move_direction.x = temp_direction.z
			move_direction.z = temp_direction.x
			if idle_distance % 2 == 0:
				move_direction.x = -move_direction.x
			else:
				move_direction.z = -move_direction.z
	elif statem.state == statem.IDLE:
		pass
	
	velocity = velocity.move_toward(move_direction * current_speed, acceleration * delta)

	move_and_slide()
