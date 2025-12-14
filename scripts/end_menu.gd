extends Control

@onready var quit_button := $quit_button

func _ready() -> void:
	visible = false

func _on_dialog_system_trigger_end_menu() -> void:
	visible = true
	await get_tree().create_timer(1).timeout
	quit_button.grab_focus()

func _on_quit_button_pressed() -> void:
	get_tree().quit()

func _on_play_again_button_pressed() -> void:
	get_tree().reload_current_scene()
