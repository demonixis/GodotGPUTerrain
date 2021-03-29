extends Spatial

func _ready():
	var VR = ARVRServer.find_interface("Oculus")
	if VR and VR.initialize():
		var viewport = get_viewport()
		viewport.arvr = true
		viewport.hdr = false
		
		OS.vsync_enabled = false
		Engine.target_fps = 72
