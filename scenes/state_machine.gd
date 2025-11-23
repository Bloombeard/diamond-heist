extends Node3D

enum {IDLE, BLOCKING, RUNNING, JUMPING, ATTACKING, DRAWING, STAGGERED}
enum {ATK_NONE, ATK_STARTUP, ATK_ACTIVE, ATK_RECOVERY}

@onready var state = IDLE
@onready var atk_state = ATK_NONE

var atk_length := 30
var atk_startup := 1
var atk_active := 10
var atk_recovery := 20
var atk_counter = 0

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
			atk_counter = 0
			state = IDLE
