extends Node3D

@onready var hitbox = $hitbox

func _physics_process(delta: float) -> void:
	if hitbox.has_overlapping_areas():
		queue_free()
