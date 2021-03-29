extends DirectionalLight


func _process(delta):
	rotate(Vector3(1, 1, 0), 0.5 * delta)
