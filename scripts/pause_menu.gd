extends Control

@onready var resumeButton := $MarginContainer/VBoxContainer/resume_button

func _ready() -> void:
	visible = true
	get_tree().paused = true

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("pause"):
		if get_tree().paused:
			visible = false
			get_tree().paused = false
		else:
			visible = true
			get_tree().paused = true
