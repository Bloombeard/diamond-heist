extends Node3D

enum {IDLE, BLOCKING, RUNNING, JUMPING, FALLING, ATTACKING, DRAWING, STAGGERED}
enum {ATK_NONE, ATK_STARTUP, ATK_ACTIVE, ATK_RECOVERY}

@onready var state = IDLE
@onready var atk_state = ATK_NONE
@onready var invuln = false

var atk_length := 30
var atk_startup := 1
var atk_active := 10
var atk_recovery := 20
var atk_counter := 0

var stg_length := 60
var stg_counter := 0

var iframes := 40
var icounter := 0

func _physics_process(delta: float) -> void:
	if state == ATTACKING or state == DRAWING:
		atk_counter += 1
		
		if atk_counter == atk_startup:
			atk_state = ATK_STARTUP
		elif atk_counter == atk_active:
			atk_state = ATK_ACTIVE
		elif atk_counter == atk_recovery:
			atk_state = ATK_RECOVERY
		elif atk_counter >= atk_length:
			atk_state = ATK_NONE
			if state == ATTACKING:
				state = IDLE
			elif state == DRAWING:
				state = BLOCKING
	elif state == STAGGERED:
		atk_state = ATK_NONE
		atk_counter = 0
		stg_counter += 1
		if stg_counter >= stg_length:
			stg_counter = 0
			state = IDLE
	
	if invuln == true:
		icounter += 1
		if icounter >= iframes:
			icounter = 0
			invuln = false
