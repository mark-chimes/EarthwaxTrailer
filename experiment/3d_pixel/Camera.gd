extends Camera

const SPEED_MOD = 1

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var hor_dir
	var ver_dir
	var z_dir
	
	if Input.is_action_pressed("ui_right"):
		hor_dir = 1
	elif Input.is_action_pressed("ui_left"):
		hor_dir = -1
	else:
		hor_dir = 0
		
	if Input.is_action_pressed("ui_up"):
		if Input.is_action_pressed("ctrl"):
			ver_dir = 0
			z_dir = -2
		else: 
			ver_dir = 1
			z_dir = 0
	elif Input.is_action_pressed("ui_down"):
		if Input.is_action_pressed("ctrl"):
			ver_dir = 0
			z_dir = 2
		else: 
			ver_dir = -1
			z_dir = 0
	else: 
		ver_dir = 0
		z_dir = 0
		
	var speed_mult = SPEED_MOD
	if Input.is_action_pressed("run"):
		speed_mult *= 3
		
	translation.x += delta * hor_dir * speed_mult
	translation.y += delta * ver_dir * speed_mult
	translation.z += delta * z_dir * speed_mult

	
