extends Node3D

enum {IDLE, RUNNING, JUMPING, DASHING, FALLING, ATTACKING, STAGGERED, DEAD}
enum {ATK_NONE, ATK_STARTUP, ATK_ACTIVE, ATK_RECOVERY}
enum {DED_NONE, DED_FORCE, DED_BOMB, DED_BUBBLE, DED_CUBE, DED_LINK}

@onready var state = IDLE
@onready var atk_state = ATK_NONE
@onready var ded_state = DED_NONE
@onready var invuln = false

var atk_length := 30
var atk_startup := 1
var atk_active := 10
var atk_recovery := 20
var atk_counter := 0

var ded_length := 10
var ded_counter := 0

var stg_length := 60
var stg_counter := 0

var iframes := 40
var icounter := 0

func _physics_process(delta: float) -> void:
	if state == ATTACKING:
		atk_counter += 1
		
		if atk_counter == atk_startup:
			atk_state = ATK_STARTUP
		elif atk_counter == atk_active:
			atk_state = ATK_ACTIVE
		elif atk_counter == atk_recovery:
			atk_state = ATK_RECOVERY
		elif atk_counter >= atk_length:
			atk_state = ATK_NONE
			state = IDLE
	elif state == STAGGERED:
		atk_state = ATK_NONE
		atk_counter = 0
		stg_counter += 1
		if stg_counter >= stg_length:
			stg_counter = 0
			state = IDLE
	elif state == DEAD:
		atk_state = ATK_NONE
		atk_counter = 0
		stg_counter = 0
		if ded_counter <= ded_length:
			ded_counter += 1
		if ded_counter == ded_length:
			ded_state = DED_NONE
	
	if invuln == true:
		icounter += 1
		if icounter >= iframes:
			icounter = 0
			invuln = false
