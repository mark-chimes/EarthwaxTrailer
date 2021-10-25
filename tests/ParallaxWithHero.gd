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
const SPEED_MOD = 5
var Spearman = preload("res://tests/ParallaxMan.tscn")
var Chicken = preload("res://tests/ParallaxChicken.tscn")
var Grass = preload("res://plants/Grasses.tscn")
var Tree = preload("res://tests/DistantForestTile.tscn")
var Flower = preload("res://plants/Flowers.tscn")
var num_chickens = 12
var num_spearmen = 8
var num_trees = 16

var num_grass = 1200
var grass_x_off = 0 
var grass_z_off = -2
var grass_x_mult = 80
var grass_z_mult = 8

var player_real_pos_x = 0
var rng = RandomNumberGenerator.new()

var lawn = []
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
		var tree = Tree.instance()
		add_child(tree)
		tree.real_pos_x = dist_x
		tree.real_pos_z = dist_z
		all_parallax_objects.push_front(tree)

	dist_z = 0
	for x in range(num_chickens):
		dist_x = - num_chickens
		for j in range(num_chickens):
			var chicken = Chicken.instance()
			add_child(chicken)
			chicken.real_pos_x = dist_x * 1.5 + randf()
			chicken.real_pos_z = dist_z * 1.5 + randf()
			all_parallax_objects.push_front(chicken)
			dist_x += 1
		dist_z += 1
	dist_z = 0
	for i in range(num_spearmen):
		dist_x = 0
		for j in range(num_spearmen): 
			var spearman = Spearman.instance()
			add_child(spearman)
			spearman.real_pos_x = dist_x
			spearman.real_pos_z = dist_z
			all_parallax_objects.push_front(spearman)
			dist_x += 1.5
		dist_z += 1.5

	my_func(num_grass, grass_x_off, grass_z_off, grass_x_mult - 1, grass_z_mult - 1)
	my_func(num_grass/2, grass_x_off, grass_z_off+6, grass_x_mult - 1, grass_z_mult - 1)
	my_func(num_grass/2, grass_x_off, grass_z_off+12, grass_x_mult - 1, grass_z_mult*2 - 1)
#	my_func(num_grass/4, grass_x_off, grass_z_off+16, grass_x_mult - 1, grass_z_mult*2 - 1)


func _process(delta):
	if Input.is_action_pressed("ui_right"):
		dir = Dir.RIGHT
		$HeroParallax/AnimatedSprite.play("walk")
		$HeroParallax/AnimatedSprite.scale.x = -2
		$HeroParallax/Shadow.scale.x = -2
		player_real_pos_x += delta * dir * SPEED_MOD
	elif Input.is_action_pressed("ui_left"):
		dir = Dir.LEFT
		$HeroParallax/AnimatedSprite.play("walk")
		$HeroParallax/AnimatedSprite.scale.x = 2
		$HeroParallax/Shadow.scale.x = 2
		player_real_pos_x += delta * dir * SPEED_MOD
	else:
		dir = Dir.NONE
		$HeroParallax/AnimatedSprite.play("idle")
	print(player_real_pos_x)
	
	for parallax_obj in all_parallax_objects:
		parallax_obj.real_pos_x += delta * dir * SPEED_MOD
		parallax_obj.position.x = z_and_x_to_x_converter(parallax_obj.real_pos_z, parallax_obj.real_pos_x)
		parallax_obj.position.y = z_and_x_to_y_converter(parallax_obj.real_pos_z, parallax_obj.real_pos_x)
		parallax_obj.z_index = -parallax_obj.real_pos_z * 10
	for grass in lawn:
		if dir == Dir.NONE:
			grass.get_node("AnimatedSprite").animation = "unfiltered"
			grass.get_node("AnimatedSprite").frame = grass.plant_num
		elif grass.is_grass:
			grass.get_node("AnimatedSprite").animation = "filtered"
			grass.get_node("AnimatedSprite").frame = grass.plant_num
		grass.real_pos_x += delta * dir * SPEED_MOD
		grass.position.x = z_and_x_to_x_converter(grass.real_pos_z, grass.real_pos_x)
		grass.position.y = z_and_x_to_y_converter(grass.real_pos_z, grass.real_pos_x)
		grass.z_index = -grass.real_pos_z * 10


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
		print("(" + str(xs[i]) + ", " + str(ys[i]) + ")")


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
	grass.get_node("AnimatedSprite").animation = "filtered"
	grass.get_node("AnimatedSprite").frame = grass.plant_num
	add_child(grass)
	grass.real_pos_x = x
	grass.real_pos_z = z
	lawn.push_front(grass)


func gamma(dim): 
	var x=1.0000
	for i in range(20):
		x = x-(pow(x,dim+1)-x-1)/((dim+1)*pow(x,dim)-1)
	return x
