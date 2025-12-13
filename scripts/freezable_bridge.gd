extends Node3D

@onready var hitbox = $hitbox
@onready var bridge = $bridge

func _physics_process(delta: float) -> void:
	if hitbox.has_overlapping_areas():
		hitbox.monitoring = false
		hitbox.monitorable = false
		bridge.use_collision = true
		$crystal_bridge.visible = true
