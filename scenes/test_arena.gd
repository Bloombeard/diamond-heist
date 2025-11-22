extends Node3D

@export var camera_switch_input_change_delay := 0.3

@onready var center_camera: Camera3D = $center_camera
@onready var orbit_camera: Camera3D = $orbit_camera/PathFollow3D/Camera3D
@onready var player: CharacterBody3D = $Player

func _ready() -> void:
	center_camera.make_current()
	player.active_movement_camera = center_camera


func _on_area_3d_body_entered(body: Node3D) -> void:
	center_camera.make_current()
	await get_tree().create_timer(camera_switch_input_change_delay).timeout
	player.active_movement_camera = center_camera

func _on_area_3d_body_exited(body: Node3D) -> void:
	orbit_camera.make_current()
	await get_tree().create_timer(camera_switch_input_change_delay).timeout
	player.active_movement_camera = orbit_camera
