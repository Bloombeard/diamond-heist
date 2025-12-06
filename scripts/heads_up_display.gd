extends CanvasLayer


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$armor.text = str(PlayerVariables.armor)
	$arm1.visible = false
	$arm2.visible = false
	$arm3.visible = false
	$arm4.visible = false
	$arm5.visible = false
	$arm6.visible = false
	if PlayerVariables.armor >= 1:
		$arm1.visible = true
	if PlayerVariables.armor >= 2:
		$arm2.visible = true
	if PlayerVariables.armor >= 3:
		$arm3.visible = true
	if PlayerVariables.armor >= 4:
		$arm4.visible = true
	if PlayerVariables.armor >= 5:
		$arm5.visible = true
	if PlayerVariables.armor >= 6:
		$arm6.visible = true
