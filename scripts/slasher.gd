extends Node

var max_counter
var counter
var direction: Vector2
var current_hit: Vector2
var last_hit: Vector2
var slash: Vector2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	max_counter = 10
	counter = max_counter
	current_hit = direction
	last_hit = direction


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if counter == 0:
		$hoz.visible = false
		$vert.visible = false
		$botleft.visible = false
		$botright.visible = false
		$topleft.visible = false
		$topright.visible = false
		current_hit = Vector2(0,0)
		last_hit = Vector2(0,0)
		counter = max_counter
	elif counter < max_counter:
		counter -= 1
	
	if counter == max_counter:
		direction = floor(Input.get_vector("slash_left", "slash_right", "slash_up", "slash_down"))
	else:
		direction = Vector2(0,0)
		
	if Input.is_action_pressed("block"):
		$hoz.billboard = true
		$vert.billboard = true
		$botleft.billboard = true
		$botright.billboard = true
		$topleft.billboard = true
		$topright.billboard = true
		direction = floor(Input.get_vector("slash_left", "slash_right", "slash_up", "slash_down"))
		counter = 1
	else:
		$hoz.billboard = false
		$vert.billboard = false
		$botleft.billboard = false
		$botright.billboard = false
		$topleft.billboard = false
		$topright.billboard = false
	
	if direction != current_hit and direction != Vector2(0,0):
		last_hit = current_hit
		current_hit = direction
		if last_hit + current_hit != Vector2(0,0): # vert/hoz slashes register 0,0 always
			slash = last_hit + current_hit
		else:
			slash = current_hit
		counter = max_counter-1
		slash_display()
		#print("last hit: "+str(last_hit))
		#print("current hit: "+str(current_hit))
		#print("total: "+str(slash))

func slash_display() -> void:
	match slash:
		Vector2(1.0,0), Vector2(-1.0,0):
			$hoz.visible = true
		Vector2(0,1.0), Vector2(0,-1.0):
			$vert.visible = true
		Vector2(-1,-1):
			$topleft.visible = true
		Vector2(1,-1):
			$topright.visible = true
		Vector2(1,1):
			$botright.visible = true
		Vector2(-1,1):
			$botleft.visible = true
