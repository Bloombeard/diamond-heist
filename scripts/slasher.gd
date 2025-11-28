extends Node

@onready var slash_effect = $slash_effect
@onready var hurtbox_shape = $hurtbox/hurtbox_shape
@onready var hurtbox = $hurtbox
@onready var statem = $"../../state_machine"

@export_group("Fast Attack Properties")
@export var fast_damage := 1
@export var fast_attack_length := 30
@export var fast_first_startup_frame := 1
@export var fast_first_active_frame := 10
@export var fast_first_recovery_frame := 20

@export_group("Slow Attack Properties")
@export var slow_damage := 1
@export var slow_attack_length := 50
@export var slow_first_startup_frame := 1
@export var slow_first_active_frame := 20
@export var slow_first_recovery_frame := 30

@export_group("combo properties")
@export var combo_length := 120 # set to 0 for enemies
@export var base_damage := 1
var combo_timer := 0
var combo_counter := 0
var damage: int

var current_hit := Vector2.ZERO
var last_hit := Vector2.ZERO
var slash: Vector2
var rune_target

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	var attack_direction = $"../..".attack_direction
	
	if combo_timer > combo_length:
		combo_timer = 0
		combo_counter = 0
	elif combo_timer > 0:
		combo_timer += 1
	
	if hurtbox.has_overlapping_areas():
		if PlayerVariables.has_sword:
			combo_timer = 1
	
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
			damage = fast_damage + combo_counter
			statem.atk_length = fast_attack_length
			statem.atk_startup = fast_first_startup_frame
			statem.atk_active = fast_first_active_frame
			statem.atk_recovery = fast_first_recovery_frame
		else:
			combo_timer = 0
			damage = slow_damage + combo_counter
			statem.atk_length = slow_attack_length
			statem.atk_startup = slow_first_startup_frame
			statem.atk_active = slow_first_active_frame
			statem.atk_recovery = slow_first_recovery_frame
		
		if combo_timer == 0 or not PlayerVariables.has_sword:
			last_hit = Vector2.ZERO
		
		if last_hit + current_hit != Vector2.ZERO: # vert/hoz slashes register 0,0 always
			slash = last_hit + current_hit
		else:
			slash = current_hit
		attack_display()
	
	# draw on active frames
	elif statem.atk_counter == statem.atk_active + 1:
		if hurtbox.has_overlapping_areas():
			combo_counter += 1
	

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
