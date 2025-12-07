extends CharacterBody3D

@export var player_path: NodePath
@export var music_path: NodePath
@export var move_speed := 4.0
@export var sight_distance := 20
@export var acceleration := 200.0

@export_group("Combat")
@export var armor_value := 20
@export var stagger_length := 30
@export var stun_length := 120
@export var invulnerability_frames := 10
@export var aggression := 66

var pattern := Dictionary()
var slasher: Node3D
var combo_counter: int

@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
@onready var slasher_hurtbox := $enemy_skin/Slasher/hurtbox
@onready var statem = $state_machine
@onready var enemy_skin = $enemy_skin
@onready var hitbox = $hitbox

@onready var player = get_node(player_path)
@onready var music = get_node(music_path)
@onready var idle_distance = randi_range(2,3)
@onready var attack_direction = Vector2(1.0,0)

var direction_to_player := Vector3.ZERO
var move_direction := Vector3.ZERO
var last_movement_direction: Vector3

func _ready() -> void:
	slasher_hurtbox.set_collision_layer_value(2, true)
	slasher_hurtbox.set_collision_mask_value(2, true)
	statem.stg_length = stagger_length
	statem.iframes = invulnerability_frames
	
func _physics_process(delta: float) -> void:
	velocity = Vector3.ZERO
	var current_speed = move_speed
	var choose_attack = randi_range(0,aggression)
	
	var target_angle := Vector3.BACK.signed_angle_to(direction_to_player, Vector3.UP)
	var rotation_speed := 12.0
	enemy_skin.global_rotation.y = lerp_angle(enemy_skin.global_rotation.y, target_angle, rotation_speed * delta)
	
	nav_agent.set_target_position(player.global_position)
	var next_nav_point := nav_agent.get_next_path_position()
	
	if combo_counter == 0:
		pattern.clear()
		rune_clear()
	elif combo_counter == 60:
		combo_counter = 0
		music.rune_off()
	else:
		combo_counter += 1
	
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
	
	# movement
	if statem.state == statem.DEAD:
		current_speed = move_speed
		direction_to_player = self.global_position.direction_to(player.global_position)
	elif statem.state == statem.STAGGERED:
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
		current_speed = move_speed / 4
		if statem.atk_counter == 1:
			if idle_distance % 2 == 0:
				idle_distance += 1
			else:
				idle_distance -= 1
	elif statem.state == statem.RUNNING:
		move_direction = (next_nav_point - global_position).normalized()
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
		var bomb = $Bomb
		var cube = $Cube
		var cube_area = $Cube/CubeArea
		# var link = A Little Purple Indicator
		match statem.ded_state:
			statem.DED_BOMB:
				statem.ded_length = 200
				if statem.ded_counter == statem.ded_length - 20:
					bomb.monitoring = true
					bomb.monitorable = true
					bomb.visible = true
			statem.DED_FORCE:
				statem.ded_length = 6
				velocity.y = 20
			statem.DED_BUBBLE:
				bubble.set_deferred("disabled", false)
				bubble.visible = true
				statem.ded_length = 600
			statem.DED_CUBE:
				statem.ded_length = 600
				cube_area.monitoring = true
				cube_area.monitorable = true
				cube.set_deferred("disabled", false)
				cube.visible = true
				if cube_area.has_overlapping_areas():
					var collision = cube_area.get_overlapping_areas()
					for collision_object in collision:
						if collision_object.get_collision_layer_value(5):
							statem.ded_state = statem.DED_NONE
				if statem.ded_counter == 1:
					move_direction = -direction_to_player
				elif is_on_wall():
					move_direction = move_direction.bounce(get_wall_normal())
				velocity = velocity.move_toward(move_direction * current_speed, acceleration * delta)
				velocity.y = 0
			statem.DED_LINK:
				# check for closest nearby target
				# draw line between this and them
				# hit them
				pass
			statem.DED_NONE:
				bomb.monitoring = false
				bomb.monitorable = false
				bomb.visible = false
				bubble.set_deferred("disabled", true)
				bubble.visible = false
				cube_area.monitoring = false
				cube_area.monitorable = false
				cube.set_deferred("disabled", true)
				cube.visible = false
				rune_clear()
				statem.ded_counter = 0
				statem.state = statem.STAGGERED

	if not is_on_floor() and statem.ded_state != statem.DED_BUBBLE:
		velocity.y = -20

	move_and_slide()
	if statem.ded_state == statem.DED_BUBBLE and statem.ded_counter > 60:
					global_position.y = global_position.y + 0.07

func _on_hitbox_area_entered(area: Area3D) -> void:
	slasher = area.get_parent()
	combo_counter = 1
	
	if statem.state != statem.DEAD:
		statem.invuln = true
		
		if armor_value <= 0:
			$body_hit_sound.play()
			statem.stg_length = stun_length
			print("enemy: eech!")
		else:
			$armor_hit_sound.play()
			armor_value -= slasher.damage
			print("enemy: ", armor_value)
			statem.stg_length = stagger_length
		statem.state = statem.STAGGERED
	
		if armor_value <= 0 and PlayerVariables.has_sword:
			var slash = slasher.slash
			match slash:
				Vector2(1.0,0), Vector2(-1.0,0):
					pattern.set("we", true)
					$Rune/WE.visible = true
				Vector2(0,1.0), Vector2(0,-1.0):
					pattern.set("ns", true)
					$Rune/NS.visible = true
				Vector2(-1,-1):
					pattern.set("nw",true)
					$Rune/NW.visible = true
				Vector2(1,-1):
					pattern.set("ne",true)
					$Rune/NE.visible = true
				Vector2(1,1):
					pattern.set("se",true)
					$Rune/SE.visible = true
				Vector2(-1,1):
					pattern.set("sw",true)
					$Rune/SW.visible = true
			rune_handling(slasher)

func rune_handling(slasher) -> void:
	# rune pattern processing
	if pattern.size() == 1:
		music.rune_on()
	
	if pattern.size() == 4:
		if pattern.has_all(["ns", "nw", "ne", "we"]) and PlayerVariables.has_bubble:
			statem.state = statem.DEAD
			statem.ded_state = statem.DED_BUBBLE
			slasher.combo_counter = 0
			pattern.clear()
		elif pattern.has_all(["we", "ns", "nw", "se"]) and PlayerVariables.has_bomb:
			statem.state = statem.DEAD
			statem.ded_state = statem.DED_BOMB
			slasher.combo_counter = 0
			pattern.clear()
		elif pattern.has_all(["we", "sw", "ne", "se"]) and PlayerVariables.has_cube:
			statem.state = statem.DEAD
			statem.ded_state = statem.DED_CUBE
			slasher.combo_counter = 0
			pattern.clear()

func rune_clear() -> void:
	$Rune/WE.visible = false
	$Rune/NS.visible = false
	$Rune/SW.visible = false
	$Rune/SE.visible = false
	$Rune/NW.visible = false
	$Rune/NE.visible = false
