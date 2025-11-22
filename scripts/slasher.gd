extends Node

@onready var slash_effect = $slash_effect
@onready var hitbox_shape = $hitbox/hitbox_shape
@onready var statem = $"../../state_machine"

@export var attack_length := 30
var attack_counter = attack_length

var direction: Vector2
var current_hit: Vector2
var last_hit: Vector2
var slash: Vector2
var pattern := Dictionary()
var pattern_result := "none"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	current_hit = direction
	last_hit = direction

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	
	# base the attack state on the counter
	if attack_counter == 0:
		statem.atk_state = statem.ATK_NONE
	elif attack_counter < floor(attack_length/2):
		statem.atk_state = statem.ATK_RECOVERY
	elif attack_counter < floor((attack_length/4)*3):
		statem.atk_state = statem.ATK_ACTIVE
	elif attack_counter < attack_length:
		statem.atk_state = statem.ATK_STARTUP
	else:
		statem.atk_state = statem.ATK_NONE
	
	# run the counter
	if attack_counter == 0:
		attack_counter = attack_length
	elif attack_counter < attack_length:
		attack_counter -= 1
	
	# state machinery
	if statem.atk_state == statem.ATK_RECOVERY or statem.atk_state == statem.ATK_NONE:
		direction = floor(Input.get_vector("slash_left", "slash_right", "slash_up", "slash_down"))
	elif statem.atk_state == statem.ATK_STARTUP:
		direction = Vector2(0,0)
	elif statem.atk_state == statem.ATK_ACTIVE:
		hitbox_shape.set_deferred("disabled", false)
		slash_effect.visible = true
	if statem.atk_state == statem.ATK_RECOVERY:
		hitbox_shape.set_deferred("disabled", true)
		slash_effect.visible = false
	
	# rune pattern processing
	if Input.is_action_just_released("block") or Input.is_action_just_pressed("block"):
		if pattern.size() == 4 and pattern.has_all(["vert", "topleft", "topright", "hoz"]):
			pattern_result = "launch"
			print("LAUNCH")
		pattern.clear()
		current_hit = Vector2(0,0)
		last_hit = Vector2(0,0)
		$hoz.visible = false
		$vert.visible = false
		$botleft.visible = false
		$botright.visible = false
		$topleft.visible = false
		$topright.visible = false
	
	# slash direction processing
	if direction != current_hit and direction != Vector2(0,0):
		last_hit = current_hit
		current_hit = direction
		if last_hit + current_hit != Vector2(0,0): # vert/hoz slashes register 0,0 always
			slash = last_hit + current_hit
		else:
			slash = current_hit
		attack_counter = attack_length-1
		slash_display()
	slash_effect.position.z = 1 + (float(attack_counter)/-40)

func slash_display() -> void:
	match slash:
		Vector2(1.0,0), Vector2(-1.0,0):
			slash_effect.rotation_degrees.x = 0
		Vector2(0,1.0), Vector2(0,-1.0):
			slash_effect.rotation_degrees.x = 90
		Vector2(-1,-1), Vector2(1,1):
			slash_effect.rotation_degrees.x = -45
		Vector2(1,-1), Vector2(-1,1):
			slash_effect.rotation_degrees.x = 45
	slash_effect.visible = true
	
	if Input.is_action_pressed("block"):
		match slash:
			Vector2(1.0,0), Vector2(-1.0,0):
				pattern.set("vert", true)
				$hoz.visible = true
			Vector2(0,1.0), Vector2(0,-1.0):
				pattern.set("hoz", true)
				$vert.visible = true
			Vector2(-1,-1):
				pattern.set("topleft",true)
				$topleft.visible = true
			Vector2(1,-1):
				pattern.set("topright",true)
				$topright.visible = true
			Vector2(1,1):
				pattern.set("botright",true)
				$botright.visible = true
			Vector2(-1,1):
				pattern.set("botleft",true)
				$botleft.visible = true
