extends Node3D

enum Pickups {ARMOR, SWORD, JUMP, DASH, SPIN, BUBBLE, BOMB, CUBE, LINK}

signal play_dialog(dialog_to_play)

@export var pickup_type: Pickups

@onready var music_player := $"../MusicPlayer"
@onready var player: CharacterBody3D = $"../Player"
@onready var dialog_system: Control = $DialogSystem

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body == player:
		queue_free()
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
				print("BUBBLE")
			Pickups.BOMB:
				PlayerVariables.has_bomb = true
				print("BOMB")
			Pickups.CUBE:
				PlayerVariables.has_cube = true
				print("CUBE")
			Pickups.LINK:
				PlayerVariables.has_link = true
				print("LINK")
		
		music_player.play_jingle()
		get_tree().paused = true
		# await get_tree().create_timer(1).timeout
		get_tree().paused = false
		music_player.stop_jingle()
