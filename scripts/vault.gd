extends Node3D

@export var camera_switch_input_change_delay := 1

@onready var hallway_camera: Camera3D = $hallway_camera
@onready var vault_camera: Camera3D = $vault_camera
@onready var outside_follow_camera: Camera3D = $outside_follow_camera/PathFollow3D/Camera3D
@onready var player: CharacterBody3D = $Player

func _ready() -> void:
	hallway_camera.make_current()
	player.active_movement_camera = hallway_camera

func change_camera(new_camera: Camera3D) -> void:
	if new_camera != player.active_movement_camera:
		get_tree().paused = true
		player.active_movement_camera = new_camera
		new_camera.make_current()
		await get_tree().create_timer(camera_switch_input_change_delay).timeout
		get_tree().paused = false
	
func _on_vault_area_body_entered(body: Node3D) -> void:
	if body == player:
		change_camera(vault_camera)

func _on_hallway_area_body_entered(body: Node3D) -> void:
	if body == player:
		change_camera(hallway_camera)

func _on_outside_area_body_entered(body: Node3D) -> void:
	if body == player:
		change_camera(outside_follow_camera)
