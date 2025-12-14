extends MeshInstance3D

@onready var statem = $state_machine
@onready var music = $"../../../MusicPlayer"
@onready var hitbox = $hitbox
@onready var player = $"../../../Player"

var pattern := Dictionary()
var slasher: Node3D
var combo_counter: int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	statem.iframes = 10


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if combo_counter == 0:
		pattern.clear()
		rune_clear()
	elif combo_counter == 60:
		combo_counter = 0
		music.rune_off()
	else:
		combo_counter += 1
	
	if statem.invuln:
		hitbox.monitoring = false
	else:
		hitbox.monitoring = true
	
	var bubble = $StaticBody3D/Bubble
	var bomb = $StaticBody3D/Bomb
	var cube = $StaticBody3D/Cube
	var cube_area = $StaticBody3D/Cube/CubeArea
	match statem.ded_state:
			statem.DED_BOMB:
				statem.ded_length = 60
				if statem.ded_counter == statem.ded_length - 20:
					bomb.monitoring = true
					bomb.monitorable = true
					bomb.visible = true
			statem.DED_BUBBLE:
				bubble.set_deferred("disabled", false)
				bubble.visible = true
				statem.ded_length = 480
				if statem.ded_counter > 60:
					global_position.y = global_position.y + 0.07
			statem.DED_CUBE:
				statem.ded_length = 100
				cube_area.monitoring = true
				cube_area.monitorable = true
				cube.set_deferred("disabled", false)
				cube.visible = true
				if cube_area.has_overlapping_areas():
					var collision = cube_area.get_overlapping_areas()
					for collision_object in collision:
						if collision_object.get_collision_layer_value(5):
							statem.ded_state = statem.DED_NONE
			statem.DED_NONE:
				bomb.monitoring = false
				bomb.monitorable = false
				bomb.visible = false
				bubble.set_deferred("disabled", true)
				bubble.visible = false
				cube_area.monitoring = false
				cube_area.monitorable = false
				cube.set_deferred("disabled", true)
				cube.visible = false
				statem.ded_counter = 0
				statem.state = statem.STAGGERED
	

func _on_hitbox_area_entered(area: Area3D) -> void:
	slasher = area.get_parent()
	print(slasher.get_parent().get_parent())
	
	if slasher.get_parent().get_parent() == player:
		combo_counter = 1
		
		if statem.state != statem.DEAD:
			statem.invuln = true
			
			$body_hit_sound.play()
			statem.stg_length = 60
			statem.state = statem.STAGGERED
		
			if PlayerVariables.has_sword:
				var slash = slasher.slash
				match slash:
					Vector2(1.0,0), Vector2(-1.0,0):
						pattern.set("we", true)
						$Rune/WE.visible = true
					Vector2(0,1.0), Vector2(0,-1.0):
						pattern.set("ns", true)
						$Rune/NS.visible = true
					Vector2(-1,-1):
						pattern.set("nw",true)
						$Rune/NW.visible = true
					Vector2(1,-1):
						pattern.set("ne",true)
						$Rune/NE.visible = true
					Vector2(1,1):
						pattern.set("se",true)
						$Rune/SE.visible = true
					Vector2(-1,1):
						pattern.set("sw",true)
						$Rune/SW.visible = true
				rune_handling(slasher)


func rune_handling(slasher) -> void:
	# rune pattern processing
	if pattern.size() > 0:
		music.rune_on()
	
	if pattern.size() == 4:
		if pattern.has_all(["ns", "nw", "ne", "we"]) and PlayerVariables.has_bubble:
			statem.state = statem.DEAD
			statem.ded_state = statem.DED_BUBBLE
			slasher.combo_counter = 0
			pattern.clear()
		elif pattern.has_all(["we", "ns", "nw", "se"]) and PlayerVariables.has_bomb:
			statem.state = statem.DEAD
			statem.ded_state = statem.DED_BOMB
			slasher.combo_counter = 0
			pattern.clear()
		elif pattern.has_all(["we", "sw", "ne", "se"]) and PlayerVariables.has_cube:
			statem.state = statem.DEAD
			statem.ded_state = statem.DED_CUBE
			slasher.combo_counter = 0
			pattern.clear()

func rune_clear() -> void:
	$Rune/WE.visible = false
	$Rune/NS.visible = false
	$Rune/SW.visible = false
	$Rune/SE.visible = false
	$Rune/NW.visible = false
	$Rune/NE.visible = false
