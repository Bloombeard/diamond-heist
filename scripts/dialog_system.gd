extends Control

@onready var background = $CanvasLayer/background
@onready var speaker_name = $CanvasLayer/speaker_name
@onready var dialog_text = $CanvasLayer/dialogue
@onready var animation_player = $CanvasLayer/AnimationPlayer
@onready var active_line_index = 0

var is_dialog_active := false
var dialog_text_array

func _ready() -> void:
	background.visible = false
	speaker_name.visible = false
	
func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("dialog_next_line") and is_dialog_active:
		active_line_index += 1
		play_line_of_dialog()

func _on_item_pickup_play_dialog(dialog_to_play: Variant) -> void:
	toggle_dialog()
	dialog_text_array = DialogConstants[dialog_to_play]
	#var total_lines = DialogConstants.dialog_to_play.length - 1
	play_line_of_dialog()
	
func play_line_of_dialog() -> void:
	dialog_text.text = dialog_text_array[active_line_index]
	animation_player.play("scroll")

func toggle_dialog() -> void:
	background.visible = !background.visible
	speaker_name.visible = !background.visible
	is_dialog_active = !is_dialog_active
