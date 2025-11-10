extends PhantomCameraManager

@onready var cameraArray = get_phantom_cameras_3d()

func switch_to_vault_camera() -> void:
	for camera in cameraArray:
		print(camera)
	
