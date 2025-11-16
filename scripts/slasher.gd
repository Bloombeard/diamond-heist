extends Node

const max_counter = 10
var counter
var direction
var last_direction

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	counter = max_counter
	direction = "center"


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if counter == 0:
		$hoz.visible = false
		$vert.visible = false
		$botleft.visible = false
		$botright.visible = false
		$topleft.visible = false
		$topright.visible = false
		counter = max_counter
	elif counter < max_counter:
		counter -= 1
	
	if Input.is_action_just_pressed("slash_left"):
		last_direction = direction
		direction = "left"
		direction_calculation()
		counter = max_counter - 1
	if Input.is_action_just_pressed("slash_right"):
		last_direction = direction
		direction = "right"
		direction_calculation()
		counter = max_counter - 1
	if Input.is_action_just_pressed("slash_up"):
		last_direction = direction
		direction = "up"
		direction_calculation()
		counter = max_counter - 1
	if Input.is_action_just_pressed("slash_down"):
		last_direction = direction
		direction = "down"
		direction_calculation()
		counter = max_counter - 1

func direction_calculation() -> void:
	$hoz.visible = false
	$vert.visible = false
	$botleft.visible = false
	$botright.visible = false
	$topleft.visible = false
	$topright.visible = false
	match last_direction:
		"left":
			match direction:
				"left", "right": 
					$hoz.visible = true
				"up":
					$topleft.visible = true
				"down":
					$botleft.visible = true
		"right":
			match direction:
				"left", "right": 
					$hoz.visible = true
				"up":
					$topright.visible = true
				"down":
					$botright.visible = true
		"up":
			match direction:
				"up", "down": 
					$vert.visible = true
				"left":
					$topleft.visible = true
				"right":
					$topright.visible = true
		"down":
			match direction:
				"up", "down": 
					$vert.visible = true
				"left":
					$botleft.visible = true
				"right":
					$botright.visible = true
		"center":
			match direction:
				"up", "down": 
					$vert.visible = true
				"left", "right":
					$hoz.visible = true
