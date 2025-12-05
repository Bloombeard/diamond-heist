extends Node2D


func _on_start_button_pressed() -> void:
	pass # Replace with function body.


func _on_options_button_pressed() -> void:
	pass # Replace with function body.


func _on_quit_button_pressed() -> void:
	get_tree().quit()

func _on_dev_vault_start_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/vault.tscn")

func _on_dev_arena_start_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/test_arena.tscn")
