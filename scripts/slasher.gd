extends Node

@onready var slash_effect = $slash_effect
@onready var hitbox_shape = $hitbox/hitbox_shape
enum attack_state {NONE, STARTUP, ACTIVE, RECOVERY}
var current_state := attack_state.NONE
var max_counter := 30
var counter
var direction: Vector2
var current_hit: Vector2
var last_hit: Vector2
var slash: Vector2
var pattern := Dictionary()
var pattern_result := "none"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	counter = max_counter
	current_hit = direction
	last_hit = direction

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	
	# base the attack state on the counter
	if counter == 0:
		current_state = attack_state.NONE
	elif counter < floor(max_counter/2):
		current_state = attack_state.RECOVERY
	elif counter < floor((max_counter/4)*3):
		current_state = attack_state.ACTIVE
	elif counter < max_counter:
		current_state = attack_state.STARTUP
	else:
		current_state = attack_state.NONE
	
	# run the counter
	if counter == 0:
		counter = max_counter
	elif counter < max_counter:
		counter -= 1
	
	# state machinery
	if current_state == attack_state.RECOVERY or current_state == attack_state.NONE:
		direction = floor(Input.get_vector("slash_left", "slash_right", "slash_up", "slash_down"))
	elif current_state == attack_state.STARTUP:
		direction = Vector2(0,0)
	elif current_state == attack_state.ACTIVE:
		hitbox_shape.set_deferred("disabled", false)
		slash_effect.visible = true
	if current_state == attack_state.RECOVERY:
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
		counter = max_counter-1
		slash_display()
	slash_effect.position.z = 1 + (float(counter)/-40)

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
		
