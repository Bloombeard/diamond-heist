extends Path3D

@export var target: CharacterBody3D

@onready var follower = $PathFollow3D
@onready var camera = $PathFollow3D/Camera3D

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var target_position = target.global_transform.origin
	var closest_point_on_path = curve.get_closest_point(to_local(target_position))
	follower.global_transform.origin = global_transform.origin + closest_point_on_path
	camera.look_at(target.position)
