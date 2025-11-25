extends CharacterBody3D

@export var player_path: NodePath
@export var move_speed := 4.0
@export var sight_distance := 20
@export var acceleration := 200.0

@export_group("Combat")
@export var armor_value := 1
@export var stagger_length := 30
@export var stun_length := 600
@export var invulnerability_frames := 10

@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
@onready var slasher_hurtbox := $enemy_skin/Slasher/hurtbox
@onready var statem = $state_machine
@onready var enemy_skin = $enemy_skin
@onready var hitbox = $hitbox

@onready var player = get_node(player_path)
@onready var idle_distance = randi_range(3,4)
@onready var attack_direction = Vector2(1.0,0)

var direction_to_player := Vector3.ZERO

func _ready() -> void:
	slasher_hurtbox.set_collision_layer_value(2, true)
	slasher_hurtbox.set_collision_mask_value(2, true)
	statem.stg_length = stagger_length
	statem.iframes = invulnerability_frames
	
func _physics_process(delta: float) -> void:
	velocity = Vector3.ZERO
	var current_speed = move_speed
	var choose_attack = randi_range(0,300)
	
	var target_angle := Vector3.BACK.signed_angle_to(direction_to_player, Vector3.UP)
	var rotation_speed := 12.0
	enemy_skin.global_rotation.y = lerp_angle(enemy_skin.global_rotation.y, target_angle, rotation_speed * delta)
	
	nav_agent.set_target_position(player.global_position)
	var next_nav_point := nav_agent.get_next_path_position()
	
	if statem.state < statem.ATTACKING:
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
	
	if statem.invuln:
		hitbox.monitoring = false
	else:
		hitbox.monitoring = true
	
	if hitbox.has_overlapping_areas() and statem.state != statem.DEAD:
		statem.invuln = true
		if armor_value == 0:
			statem.stg_length = stun_length
			print("enemy: eech!")
		else:
			armor_value -= 1
			print("enemy: ", armor_value)
			statem.stg_length = stagger_length
		statem.state = statem.STAGGERED
	
	# movement
	var move_direction = (next_nav_point - global_position).normalized()
	if statem.state >= statem.STAGGERED:
		if statem.stg_counter < 10:
			current_speed = move_speed / 6
			direction_to_player = self.global_position.direction_to(player.global_position)
			move_direction = -direction_to_player
			move_direction.y = 0
		else:
			current_speed = 0
	elif statem.state == statem.ATTACKING:
		move_direction = direction_to_player
		move_direction.y = 0
		if statem.atk_state != statem.ATK_RECOVERY:
			current_speed = move_speed / 6
		else:
			current_speed = 0
		if statem.atk_counter == 1:
			if idle_distance % 2 == 0:
				idle_distance += 1
			else:
				idle_distance -= 1
	elif statem.state == statem.RUNNING:
		var distance_to_player = self.global_position.distance_to(player.global_position)
		if distance_to_player <= idle_distance + 1:
			current_speed = move_speed / 4
		
		if distance_to_player <= idle_distance - 1:
			move_direction = -direction_to_player
			move_direction.y = 0
		elif distance_to_player <= idle_distance:
			var temp_direction = move_direction
			move_direction.x = temp_direction.z
			move_direction.z = temp_direction.x
			if idle_distance % 2 == 0:
				move_direction.x = -move_direction.x
			else:
				move_direction.z = -move_direction.z
	elif statem.state == statem.IDLE:
		pass
	
	if statem.state != statem.DEAD:
		velocity = velocity.move_toward(move_direction * current_speed, acceleration * delta)
	else:
		var bubble = $Bubble
		match statem.ded_state:
			statem.DED_BOMB:
				statem.ded_length = 180
				if statem.ded_counter == statem.ded_length - 1:
					# spawn explosion! its a hurtbox
					# explosion should set targets stagger length to its survival length
					pass
			statem.DED_FORCE:
				statem.ded_length = 6
				velocity.y = 20
			statem.DED_BUBBLE:
				bubble.set_deferred("disabled", false)
				bubble.visible = true
				statem.ded_length = 600
				velocity.y = 0.5
			statem.DED_CUBE:
				# spawn cube! it has collision like bubble
				# apply velocity using move_direction = -direction_to_player
				# hurtbox while moving
				# reeeally long ded_length! but cut it short on wall collision
				pass
			statem.DED_LINK:
				# check for closest nearby target
				# draw line between this and them
				# hit them
				pass
			statem.DED_NONE:
				if is_on_floor():
					bubble.set_deferred("disabled", true)
					bubble.visible = false
					velocity = velocity.move_toward(Vector3.ZERO, acceleration * delta)
				else:
					velocity = velocity.move_toward(Vector3(0,-20,0), acceleration * delta)

	move_and_slide()
