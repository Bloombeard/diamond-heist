extends Node3D

@export var camera_switch_input_change_delay := 1

@onready var vault_camera: Camera3D = $vault_camera
@onready var hallway_camera: Camera3D = $rooma_camera/PathFollow3D/Camera3D
@onready var roomb_camera: Camera3D = $roomb_camera
@onready var roomd_camera: Camera3D = $roomd_camera/PathFollow3D/Camera3D
@onready var roome_camera: Camera3D = $roome_camera
@onready var roome_camera2: Camera3D = $roome_camera2
@onready var roomf_camera: Camera3D = $roomf_camera/PathFollow3D/Camera3D
@onready var roomg_camera: Camera3D = $roomg_camera
@onready var roomh_camera: Camera3D = $roomh_camera
@onready var roomj_camera: Camera3D = $roomj_camera
@onready var outside_follow_camera: Camera3D = $roomc_follow_camera/PathFollow3D/Camera3D
@onready var player: CharacterBody3D = $Player

func _ready() -> void:
	vault_camera.make_current()
	player.active_movement_camera = vault_camera
	PlayerVariables.has_bomb = false
	PlayerVariables.has_bubble = false
	PlayerVariables.has_cube = false
	PlayerVariables.max_armor = 4
	PlayerVariables.armor = PlayerVariables.max_armor

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


func _on_roomb_area_body_entered(body: Node3D) -> void:
	if body == player:
		change_camera(roomb_camera)


func _on_roomd_area_body_entered(body: Node3D) -> void:
	if body == player:
		change_camera(roomd_camera)


func _on_roome_area_body_entered(body: Node3D) -> void:
	if body == player:
		change_camera(roome_camera)


func _on_roomf_area_body_entered(body: Node3D) -> void:
	if body == player:
		change_camera(roomf_camera)


func _on_roomg_area_body_entered(body: Node3D) -> void:
	if body == player:
		change_camera(roomg_camera)


func _on_roomh_areah_body_entered(body: Node3D) -> void:
	if body == player:
		change_camera(roomh_camera)


func _on_roomh_areah_2_body_entered(body: Node3D) -> void:
	if body == player:
		change_camera(roomj_camera)


func _on_roome_area_2_body_entered(body: Node3D) -> void:
	if body == player:
		change_camera(roome_camera2)
