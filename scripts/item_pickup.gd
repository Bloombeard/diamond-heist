extends Node3D

enum Pickups {ARMOR, SWORD, JUMP, DASH, SPIN, BUBBLE, BOMB, CUBE, LINK}

signal play_dialog(dialog_to_play)

@export var pickup_type: Pickups

@onready var music_player := $"../MusicPlayer"
@onready var player: CharacterBody3D = $"../Player"
@onready var dialog_system: Control = $DialogSystem

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body == player:
		match pickup_type:
			Pickups.ARMOR:
				PlayerVariables.max_armor += 1
				PlayerVariables.armor = PlayerVariables.max_armor
				print(PlayerVariables.max_armor)
			Pickups.SWORD:
				PlayerVariables.has_sword = true
				play_dialog.emit("SWORD_INTRO")
				print("SWORD")
			Pickups.JUMP: 
				PlayerVariables.has_jump = true
				print("JUMP")
			Pickups.DASH:
				PlayerVariables.has_dash = true
				print("DASH")
			Pickups.SPIN:
				PlayerVariables.has_spin = true
				print("SPIN")
			Pickups.BUBBLE:
				PlayerVariables.has_bubble = true
				play_dialog.emit("BUBBLE_PICKUP_DIALOG")
				print("BUBBLE")
			Pickups.BOMB:
				PlayerVariables.has_bomb = true
				play_dialog.emit("BOMB_PICKUP_DIALOG")
				print("BOMB")
			Pickups.CUBE:
				PlayerVariables.has_cube = true
				play_dialog.emit("ICE_BRIDGE_PICKUP_DIALOG")
				print("CUBE")
			Pickups.LINK:
				PlayerVariables.has_link = true
				print("LINK")
		
		if(pickup_type != Pickups.SWORD):
			music_player.play_jingle()
			$Area3D.queue_free()
			$CSGSphere3D.queue_free()
			$OmniLight3D.queue_free()
			await get_tree().create_timer(3).timeout
			music_player.stop_jingle()
		queue_free()
