extends Node

@onready var slash_effect = $slash_effect
@onready var hitbox_shape = $hitbox/hitbox_shape
@onready var statem = $"../../state_machine"

@export_group("Fast Attack Properties")
@export var fast_attack_length := 30
@export var fast_first_startup_frame := 1
@export var fast_first_active_frame := 10
@export var fast_first_recovery_frame := 20

@export_group("Slow Attack Properties")
@export var slow_attack_length := 50
@export var slow_first_startup_frame := 1
@export var slow_first_active_frame := 20
@export var slow_first_recovery_frame := 30

var input_direction: Vector2
var input_buffer: Vector2
var current_hit := Vector2.ZERO
var last_hit := Vector2.ZERO
var slash: Vector2
var pattern := Dictionary()
var pattern_result := "none"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if floor(Input.get_vector("slash_left", "slash_right", "slash_up", "slash_down")) != Vector2.ZERO:
		input_buffer = floor(Input.get_vector("slash_left", "slash_right", "slash_up", "slash_down"))
	
	# only pull from the buffer when idle or in recovery
	if statem.atk_state == statem.ATK_NONE or statem.atk_state == statem.ATK_RECOVERY:
		input_direction = input_buffer
		input_buffer = Vector2.ZERO
	else:
		input_direction = Vector2.ZERO
	
	if input_direction != Vector2.ZERO:
		if statem.state == statem.BLOCKING:
			statem.state = statem.DRAWING
		else:
			statem.state = statem.ATTACKING
	
	# do the hitbox (and slash effects)
	if statem.atk_state == statem.ATK_ACTIVE and statem.state == statem.ATTACKING:
		hitbox_shape.set_deferred("disabled", false)
		slash_effect.visible = true
		slash_effect.position.z = 1 + (float(statem.atk_counter)/40)
	elif statem.atk_state == statem.ATK_RECOVERY or statem.atk_state == statem.ATK_STARTUP  and statem.state == statem.ATTACKING:
		hitbox_shape.set_deferred("disabled", true)
		slash_effect.visible = false
	
	# slash direction when attacking
	if statem.state == statem.ATTACKING and statem.atk_state == statem.ATK_NONE:
		last_hit = current_hit
		current_hit = input_direction
		if last_hit != current_hit:
			statem.atk_length = fast_attack_length
			statem.atk_startup = fast_first_startup_frame
			statem.atk_active = fast_first_active_frame
			statem.atk_recovery = fast_first_recovery_frame
		else:
			statem.atk_length = slow_attack_length
			statem.atk_startup = slow_first_startup_frame
			statem.atk_active = slow_first_active_frame
			statem.atk_recovery = slow_first_recovery_frame
		
		if last_hit + current_hit != Vector2.ZERO: # vert/hoz slashes register 0,0 always
			slash = last_hit + current_hit
		else:
			slash = current_hit
		attack_display()
	# slash direction when blocking
	elif statem.state == statem.DRAWING and statem.atk_state == statem.ATK_NONE:
		last_hit = current_hit
		current_hit = input_direction
		statem.atk_length = fast_attack_length
		statem.atk_startup = fast_first_startup_frame
		statem.atk_active = fast_first_active_frame
		statem.atk_recovery = fast_first_recovery_frame
		if last_hit == current_hit:
			statem.state = statem.STAGGERED
		
		if last_hit + current_hit != Vector2.ZERO: # vert/hoz slashes register 0,0 always
			slash = last_hit + current_hit
		else:
			slash = current_hit
		draw_display()
	
	if statem.state == statem.BLOCKING:
		pass
	
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
	

func attack_display() -> void:
	match slash:
		Vector2(1.0,0), Vector2(-1.0,0):
			slash_effect.rotation_degrees.x = 0
		Vector2(0,1.0), Vector2(0,-1.0):
			slash_effect.rotation_degrees.x = 90
		Vector2(-1,-1), Vector2(1,1):
			slash_effect.rotation_degrees.x = -45
		Vector2(1,-1), Vector2(-1,1):
			slash_effect.rotation_degrees.x = 45
		Vector2(2.0,0), Vector2(-2.0,0):
			slash_effect.rotation_degrees.x = 0
		Vector2(0,2.0), Vector2(0,-2.0):
			slash_effect.rotation_degrees.x = 90

func draw_display() -> void:
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
