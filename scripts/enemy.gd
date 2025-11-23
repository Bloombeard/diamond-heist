extends CharacterBody3D

@export var player_path: NodePath
@export var move_speed := 4.0

@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
@onready var statem = $state_machine

@onready var player = get_node(player_path)
@onready var idle_distance = randi_range(3,5)

func _ready() -> void:
	pass
	
func _physics_process(_delta: float) -> void:
	velocity = Vector3.ZERO
	var current_speed = move_speed
	
	nav_agent.set_target_position(player.global_position)
	var next_nav_point := nav_agent.get_next_path_position()
	
	if true:
		statem.state = statem.RUNNING
	
	if statem.state == statem.RUNNING:
		velocity = (next_nav_point - global_position).normalized()
		if self.global_position.distance_to(player.global_position) < idle_distance:
			current_speed = move_speed / 4
			var tempvelocity = velocity
			velocity.x = tempvelocity.z
			velocity.z = tempvelocity.x
			if idle_distance % 2 == 0:
				velocity.x = -velocity.x
			else:
				velocity.z = -velocity.z
		velocity = velocity *  current_speed

	move_and_slide()
