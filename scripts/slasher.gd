extends Node

@onready var slash_effect = $slash_effect
@onready var hurtbox_shape = $hurtbox/hurtbox_shape
@onready var hurtbox = $hurtbox
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

var current_hit := Vector2.ZERO
var last_hit := Vector2.ZERO
var slash: Vector2
var pattern := Dictionary()
var pattern_result := "none"
var rune_target

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	
	var attack_direction = $"../..".attack_direction
	
	# do the hurbox (and slash effects)
	if statem.atk_state == statem.ATK_ACTIVE:
		hurtbox_shape.set_deferred("disabled", false)
		slash_effect.visible = true
		slash_effect.position.z = 1 + (float(statem.atk_counter)/40)
	elif statem.atk_state == statem.ATK_RECOVERY or statem.atk_state <= statem.ATK_STARTUP:
		hurtbox_shape.set_deferred("disabled", true)
		slash_effect.visible = false
	
	# slash direction when attacking
	if statem.state == statem.ATTACKING and statem.atk_counter == 1:
		last_hit = current_hit
		current_hit = attack_direction
		
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
	elif statem.state == statem.DRAWING and statem.atk_counter == 1:
		last_hit = current_hit
		current_hit = attack_direction
		statem.atk_length = fast_attack_length
		statem.atk_startup = fast_first_startup_frame
		statem.atk_active = fast_first_active_frame
		statem.atk_recovery = fast_first_recovery_frame
		if last_hit == current_hit:
			pass # this should break the rune probably?
		
		if last_hit + current_hit != Vector2.ZERO: # vert/hoz slashes register 0,0 always
			slash = last_hit + current_hit
		else:
			slash = current_hit
	# draw on active frames
	elif statem.state == statem.DRAWING and statem.atk_counter == statem.atk_active + 1:
		if hurtbox.has_overlapping_areas():
			rune_target = hurtbox.get_overlapping_areas()[0].get_parent()
			if rune_target.statem.state == rune_target.statem.STAGGERED:
				draw_display()
	
	# rune pattern processing
	if Input.is_action_just_released("block") or Input.is_action_just_pressed("block") or last_hit == current_hit:
		if pattern.size() == 4 and pattern.has_all(["vert", "topleft", "topright", "hoz"]):
			pattern_result = "bubble"
			rune_target.statem.state = rune_target.statem.DEAD
			rune_target.statem.ded_state = rune_target.statem.DED_BUBBLE
		elif pattern.size() == 4 and pattern.has_all(["hoz", "vert", "topleft", "botright"]):
			pattern_result = "bomb"
			rune_target.statem.state = rune_target.statem.DEAD
			rune_target.statem.ded_state = rune_target.statem.DED_BOMB
		elif pattern.size() == 4 and pattern.has_all(["hoz", "botleft", "topright", "botright"]):
			pattern_result = "cube"
			rune_target.statem.state = rune_target.statem.DEAD
			rune_target.statem.ded_state = rune_target.statem.DED_CUBE
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
			pattern.set("hoz", true)
			$hoz.visible = true
		Vector2(0,1.0), Vector2(0,-1.0):
			pattern.set("vert", true)
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
