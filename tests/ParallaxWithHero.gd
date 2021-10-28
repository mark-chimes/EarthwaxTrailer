extends Node2D
const HORIZON_ACTUAL = 390
const HORIZON = HORIZON_ACTUAL - 50
const SCREEN_MAX_X = 1920
const SCREEN_MAX_Y = 1080
const SCREEN_MID_X = SCREEN_MAX_X / 2
const Z_ORIGIN_Y_OFFSET = SCREEN_MAX_Y - 178
const HORIZON_HEIGHT = Z_ORIGIN_Y_OFFSET - HORIZON 
const X_UNIT = 32.0
const Z_UNIT = 0.05
const SPEED_MOD = 25
var Spearman = preload("res://tests/ParallaxMan.tscn")
var Chicken = preload("res://tests/ParallaxChicken.tscn")
var Grass = preload("res://plants/Grasses.tscn")
var DistantForestTile = preload("res://tests/DistantForestTile.tscn")
var Flower = preload("res://plants/Flowers.tscn")
var Wave = preload("res://tests/ParallaxWave.tscn")
var BuildingFront = preload("res://buildings/BuildingFront.tscn")
var BuildingBack = preload("res://buildings/BuildingBack.tscn")
var BuildingWheel = preload("res://buildings/BuildingWheel.tscn")
var num_chickens = 0#12
var num_waves = 0
var num_spearmen = 0#24
var num_trees = 16

var num_grass = 3000
var grass_x_off = -20 
var grass_z_off = -1
var grass_x_mult = 80
var grass_z_mult = 16

var player_real_pos_x = 0
var rng = RandomNumberGenerator.new()

var lawn = []
var waves = []
var all_parallax_objects = []
enum Dir {
	LEFT = 1,
	RIGHT = -1,
	NONE = 0,
}
var dir = Dir.RIGHT

func _ready():
	dir = Dir.NONE
	var dist_z = 150
	var dist_x = -300
	for x in range(num_trees):
		dist_x += 34
		var tree = DistantForestTile.instance()
		add_child(tree)
		tree.real_pos.x = dist_x
		tree.real_pos.z = dist_z
		all_parallax_objects.push_front(tree)

	dist_z = 0
	for x in range(num_chickens):
		dist_x = - num_chickens
		for j in range(num_chickens):
			var chicken = Chicken.instance()
			add_child(chicken)
			chicken.real_pos.x = dist_x * 1.5 + randf()
			chicken.real_pos.z = dist_z * 1.5 + randf()
			all_parallax_objects.push_front(chicken)
			dist_x += 1
		dist_z += 1

	
	dist_z = -4.8
	for x in range(3):
		dist_x = - num_waves/2
		for j in range(num_waves):
			var wave = Wave.instance()
			add_child(wave)
			wave.real_pos.x = dist_x * 1.5 + randf()
			wave.real_pos.z = dist_z  + randf()
			all_parallax_objects.push_front(wave)
			waves.append(wave)
			dist_x += 1
		dist_z += 1
	dist_z = 0	
	
	for i in range(num_spearmen):
		dist_x = 0
		for j in range(num_spearmen): 
			var spearman = Spearman.instance()
			add_child(spearman)
			spearman.real_pos.x = dist_x
			spearman.real_pos.z = dist_z
			all_parallax_objects.push_front(spearman)
			dist_x += 1.5
		dist_z += 1.5
		
	var building_back = BuildingBack.instance()
	add_child(building_back)
	building_back.real_pos.x = -20
	building_back.real_pos.z = 72
	all_parallax_objects.push_front(building_back)		

	var building_front = BuildingFront.instance()
	add_child(building_front)
	building_front.real_pos.x = -20
	building_front.real_pos.z = 70
	all_parallax_objects.push_front(building_front)

	var building_wheel = BuildingWheel.instance()
	add_child(building_wheel)
	building_wheel.real_pos.x = -20
	building_wheel.real_pos.z = 68
	all_parallax_objects.push_front(building_wheel)
	my_func(num_grass, grass_x_off, grass_z_off, grass_x_mult - 1, grass_z_mult - 1)
	my_func(num_grass/2, grass_x_off, grass_z_off+6, grass_x_mult - 1, grass_z_mult - 1)
	my_func(num_grass/2, grass_x_off, grass_z_off+12, grass_x_mult - 1, grass_z_mult*2 - 1)
#	my_func(num_grass/4, grass_x_off, grass_z_off+16, grass_x_mult - 1, grass_z_mult*2 - 1)

var has_printed = false

var is_hero_in_row_1 = true

func _process(delta):
	if Input.is_action_pressed("ui_right"):
		dir = Dir.RIGHT
		$HeroParallax/AnimatedSprite.play("walk")
		$HeroParallax/AnimatedSprite.scale.x = -2
		$HeroParallax/Shadow.scale.x = -2
		$HeroParallax2/AnimatedSprite.play("walk")
		$HeroParallax2/AnimatedSprite.scale.x = -2
		$HeroParallax2/Shadow.scale.x = -2
		player_real_pos_x += delta * dir * SPEED_MOD
	elif Input.is_action_pressed("ui_left"):
		dir = Dir.LEFT
		$HeroParallax/AnimatedSprite.play("walk")
		$HeroParallax/AnimatedSprite.scale.x = 2
		$HeroParallax/Shadow.scale.x = 2
		$HeroParallax2/AnimatedSprite.play("walk")
		$HeroParallax2/AnimatedSprite.scale.x = 2
		$HeroParallax2/Shadow.scale.x = 2
		player_real_pos_x += delta * dir * SPEED_MOD

	else:
		dir = Dir.NONE
		$HeroParallax/AnimatedSprite.play("idle")
		$HeroParallax2/AnimatedSprite.play("idle")
	# print(player_real_pos_x)
	
	if Input.is_action_pressed("ui_up"):
		if $HeroParallax.position.y > 832:
			$HeroParallax.position.y = 832
			$HeroParallax.z_index = -8
		if $HeroParallax2.position.y > 832:
			$HeroParallax2.position.y = 832
			$HeroParallax2.z_index = -8			
			is_hero_in_row_1 = false
	if Input.is_action_pressed("ui_down"):
		if $HeroParallax.position.y < 896:
			$HeroParallax.position.y = 896
			$HeroParallax.z_index = -1
		if $HeroParallax2.position.y < 896:
			$HeroParallax2.position.y = 896
			$HeroParallax2.z_index = -1
			is_hero_in_row_1 = true
	
	for wave in waves: 
		wave.real_pos.x += delta
	for parallax_obj in all_parallax_objects:
		parallax_obj.real_pos.x += delta * dir * SPEED_MOD
		parallax_obj.position.x = z_and_x_to_x_converter(parallax_obj.real_pos.z, parallax_obj.real_pos.x)
		parallax_obj.position.y = z_and_x_to_y_converter(parallax_obj.real_pos.z, parallax_obj.real_pos.x)
		parallax_obj.z_index = -parallax_obj.real_pos.z * 10
#		if not has_printed: 
#			print("Name: ", parallax_obj.name)
			

		
		for i in range(16, 40):
			var the_name = "@ParallaxMan@" + str(i)
			if i == 16: 
				the_name = "ParallaxMan"
			if parallax_obj.name == the_name:
				if is_hero_in_row_1 and parallax_obj.position.x > 832 and parallax_obj.position.x < 1088:
					if parallax_obj.real_pos.z > -1:
						parallax_obj.real_pos.z -= 4*delta
				else: 
					if parallax_obj.real_pos.z < 0:
						parallax_obj.real_pos.z += 1*delta
		
		for i in range(41, 65):
			var the_name = "@ParallaxMan@" + str(i)
			if parallax_obj.name == the_name:
				if parallax_obj.position.x > 832 and parallax_obj.position.x < 1088:
					if not is_hero_in_row_1:
						if parallax_obj.real_pos.z > 0.5:
							parallax_obj.real_pos.z -= 4*delta
					else: #is_hero_in_row_1
						if parallax_obj.real_pos.z < 2.5:
							parallax_obj.real_pos.z += 1*delta
				else: 
					if parallax_obj.real_pos.z > 1.498:
						parallax_obj.real_pos.z -= 1*delta
					if  parallax_obj.real_pos.z < 1.502:
						parallax_obj.real_pos.z += 1*delta
						
				# print("Z INDEX: ", parallax_obj.z_index)
	has_printed = true
	
	for grass in lawn:
#		if dir == Dir.NONE:
#			grass.get_node("AnimatedSprite").animation = "unfiltered"
#			grass.get_node("AnimatedSprite").frame = grass.plant_num
#		elif grass.is_grass:
#			grass.get_node("AnimatedSprite").animation = "filtered"
#			grass.get_node("AnimatedSprite").frame = grass.plant_num
		grass.real_pos.x += delta * dir * SPEED_MOD
		grass.position.x = z_and_x_to_x_converter(grass.real_pos.z, grass.real_pos.x)
		grass.position.y = z_and_x_to_y_converter(grass.real_pos.z, grass.real_pos.x)
		grass.z_index = -grass.real_pos.z * 10
		


func draw_line_to_middle(phys_obj): 
	draw_line(
		Vector2(phys_obj.position.x,phys_obj.position.y), 
		Vector2(SCREEN_MID_X, HORIZON), 
		Color(255, 0, 0), 
		1)

func z_and_x_to_y_converter(z_pos, x_pos):
	z_pos = z_pos * Z_UNIT + 1
	x_pos = x_pos / X_UNIT
	var dist = sqrt(z_pos * z_pos + x_pos * x_pos)
	return HORIZON + HORIZON_HEIGHT / z_pos


func z_and_x_to_x_converter(z_pos, x_pos):
	x_pos = x_pos * X_UNIT * 1.0
	z_pos = z_pos * Z_UNIT + 1
	return SCREEN_MID_X + x_pos / z_pos

func my_func(n, x_off, y_off, x_mult, y_mult): 
	var g = gamma(2)
	var my_seed = 0.5
	
	var alpha_x = fmod(pow(1/g, 1), 1.0)
	var alpha_y = fmod(pow(1/g, 2), 1.0)
	
	var xs = []
	var ys = []
	
	var x_cur = my_seed
	var y_cur = my_seed 
	

	for i in range(n): 
		x_cur = fmod(x_cur + alpha_x, 1)
		y_cur = fmod(y_cur + alpha_y, 1)
		xs.push_back(x_off + x_cur*x_mult)
		ys.push_back(y_off + y_cur*y_mult)
	
	for i in range(n):
		add_grass(xs[i] + randf(), ys[i])
		# print("(" + str(xs[i]) + ", " + str(ys[i]) + ")")


func add_grass(x, z): 
	var flowerng = rng.randi_range(0, 40)
	var grass
	var num
	if flowerng == 0:
		grass = Flower.instance()
		num = rng.randi_range(0, 4)
	else:
		grass = Grass.instance()
		num = rng.randi_range(0, 2)
	grass.plant_num = num

	add_child(grass)
	grass.real_pos.x = x
	grass.real_pos.z = z
	

	
	if grass.real_pos.z > 20: 
		grass.get_node("AnimatedSprite2").visible = true
		grass.get_node("AnimatedSprite").visible = false
		grass.get_node("AnimatedSprite2").animation = "filtered"
		grass.get_node("AnimatedSprite2").frame = grass.plant_num	
	elif grass.real_pos.z > 15 and grass.real_pos.z <= 20:
		var is_close = rng.randi_range(0,4)
		if is_close == 0:
			grass.get_node("AnimatedSprite").visible = true
			grass.get_node("AnimatedSprite2").visible = false
			grass.get_node("AnimatedSprite").animation = "filtered"
			grass.get_node("AnimatedSprite").frame = grass.plant_num
		else: 
			grass.get_node("AnimatedSprite2").visible = true
			grass.get_node("AnimatedSprite").visible = false
			grass.get_node("AnimatedSprite2").animation = "filtered"
			grass.get_node("AnimatedSprite2").frame = grass.plant_num	

	else: 
		grass.get_node("AnimatedSprite").visible = true
		grass.get_node("AnimatedSprite2").visible = false
		grass.get_node("AnimatedSprite").animation = "filtered"
		grass.get_node("AnimatedSprite").frame = grass.plant_num
	
	lawn.push_front(grass)


func gamma(dim): 
	var x=1.0000
	for i in range(20):
		x = x-(pow(x,dim+1)-x-1)/((dim+1)*pow(x,dim)-1)
	return x
