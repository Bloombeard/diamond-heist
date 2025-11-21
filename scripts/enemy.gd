extends CharacterBody3D

@export var player_path: NodePath
@export var move_speed := 4.0

@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D

var player = null

func _ready() -> void:
	player = get_node(player_path)
	
func _physics_process(_delta: float) -> void:
	velocity = Vector3.ZERO
	
	nav_agent.set_target_position(player.global_position)
	var next_nav_point := nav_agent.get_next_path_position()
	
	if global_position.distance_to(player.global_position) < 5:
		next_nav_point.x += 3
	
	velocity = (next_nav_point - global_position).normalized() * move_speed

	move_and_slide()
