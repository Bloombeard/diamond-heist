extends Control

@onready var background = $CanvasLayer/background
@onready var speaker_name = $CanvasLayer/speaker_name
@onready var dialog_text = $CanvasLayer/dialogue
@onready var animation_player = $CanvasLayer/AnimationPlayer
@onready var active_line_index = 0
@onready var player: CharacterBody3D = $"../Player"

signal trigger_end_menu

var is_dialog_active := false
var dialog_text_array
var total_lines = 0
var is_finish_line_dialog = false

func _ready() -> void:
	background.visible = false
	speaker_name.visible = false
	dialog_text.visible = false
	print(speaker_name.visible)
	
func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("dialog_next_line") and is_dialog_active:
		if animation_player.is_playing():
			animation_player.stop()
			dialog_text.visible_ratio = 1.0
		elif active_line_index < total_lines:
			active_line_index += 1
			play_line_of_dialog()
		else:
			toggle_dialog()

func _on_item_pickup_play_dialog(dialog_to_play: Variant) -> void:
	toggle_dialog()
	active_line_index = 0
	dialog_text_array = DialogConstants[dialog_to_play]
	total_lines = DialogConstants[dialog_to_play].size() - 1
	play_line_of_dialog()
	
func play_line_of_dialog() -> void:
	dialog_text.text = dialog_text_array[active_line_index]
	animation_player.play("scroll")

func toggle_dialog() -> void:
	dialog_text.visible = !dialog_text.visible
	background.visible = !background.visible
	speaker_name.visible = !speaker_name.visible
	
	if is_finish_line_dialog and get_tree().paused:
		trigger_end_menu.emit()
	else:
		get_tree().paused = !is_dialog_active

	is_dialog_active = !is_dialog_active

func _on_finish_line_area_body_entered(body: Node3D) -> void:
	if body == player:
		toggle_dialog()
		active_line_index = 0
		dialog_text_array = DialogConstants.YOU_WIN_DIALOG
		total_lines = DialogConstants.YOU_WIN_DIALOG.size() - 1
		is_finish_line_dialog = true
		play_line_of_dialog()
