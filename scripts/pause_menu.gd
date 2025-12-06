extends Control

@onready var resumeButton := $MarginContainer/VBoxContainer/resume_button

func _ready() -> void:
	visible = false
	get_tree().paused = false
	resumeButton.grab_focus()

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("pause"):
		if get_tree().paused:
			visible = false
			get_tree().paused = false
		else:
			visible = true
			get_tree().paused = true
			resumeButton.grab_focus()

func _on_resume_button_pressed() -> void:
	visible = false
	get_tree().paused = false

func _on_quit_button_pressed() -> void:
	print('quit button pressed')
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
