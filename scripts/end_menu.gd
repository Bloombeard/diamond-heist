extends Control

@onready var resumeButton := $MarginContainer/VBoxContainer/resume_button

func _ready() -> void:
	visible = false

func _on_dialog_system_trigger_end_menu() -> void:
	visible = true
