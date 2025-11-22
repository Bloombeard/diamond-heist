extends Node3D

enum {IDLE, BLOCKING, RUNNING, JUMPING, ATTACKING, DRAWING, STAGGERED}
enum {ATK_NONE, ATK_STARTUP, ATK_ACTIVE, ATK_RECOVERY}

@onready var state = IDLE
@onready var atk_state = ATK_NONE

func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	pass
