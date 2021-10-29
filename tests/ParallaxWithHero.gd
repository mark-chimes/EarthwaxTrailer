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
var PosGenerator = preload("res://parallax/RandomPositionGenerator.gd")
var num_chickens_x = 4
var num_chickens_z = 4
var num_waves = 10
var num_spearmen_x = 0#24
var num_spearmen_z = 0#24
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
var parallax_objects = []
var spearmen = []
var chickens = []

enum Dir {
	LEFT = 1,
	RIGHT = -1,
	NONE = 0,
}
var dir = Dir.RIGHT

var is_hero_in_row_1 = true

func _ready():
	dir = Dir.NONE

	create_objects_in_rectangle(DistantForestTile, num_trees, 2, 
		-300, 150, 34, 1, true, [])

	create_objects_in_rectangle(Chicken, num_chickens_x, num_chickens_z, 
		-num_chickens_x*1.5, 0, 1.5, 1.5, true, chickens)
	
	create_objects_in_rectangle(Wave, 3, num_waves, 
		-num_waves/2, -4.8, 1.5, 1, true, waves)
			
	create_objects_in_rectangle(Spearman, num_spearmen_x, num_spearmen_z, 
		100, 0, 1.5, 1.5, false, spearmen)
			
	create_building([BuildingBack, BuildingFront, BuildingWheel], -20, 72) 

	generate_lawn() 
	
	for parallax_obj in parallax_objects:
		parallax_obj.position.y = z_to_y_converter(parallax_obj.real_pos.z)
		parallax_obj.z_index = -parallax_obj.real_pos.z * 10

func _process(delta):
	hero_world_movement(delta)
	wave_movement(delta)
	position_stuff_on_screen(delta)

func position_stuff_on_screen(delta): 
	for grass in lawn:
		grass.position.x = z_and_x_to_x_converter(player_real_pos_x, grass.real_pos.z, grass.real_pos.x)
	for parallax_obj in parallax_objects:
		parallax_obj.position.x = z_and_x_to_x_converter(player_real_pos_x, parallax_obj.real_pos.z, parallax_obj.real_pos.x)

func wave_movement(delta): 	
	for wave in waves: 
		wave.real_pos.x += delta

func hero_world_movement(delta): 
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

	player_real_pos_x = player_real_pos_x + (delta * dir * SPEED_MOD)

func create_objects_in_rectangle(object_type, num_x, num_z, x_offset, z_offset,
	x_distance, z_distance, should_randomize, custom_array): 
	var dist_z = 0
	for z in range(num_z):
		for x in range(num_x):
			var obj = object_type.instance()
			add_child(obj)
			obj.real_pos.x = x * x_distance + x_offset
			obj.real_pos.z = z * z_distance + z_offset
			if should_randomize: 
				obj.real_pos.x += randf() - 0.5
				obj.real_pos.z += randf() - 0.5
			parallax_objects.append(obj)
			if custom_array != null: 
				custom_array.append(obj)

func create_building(building_parts, x, far_z):
	var z = far_z 
	for Building in building_parts: 
		var building = Building.instance()
		add_child(building)
		building.real_pos.x = -20
		building.real_pos.z = z
		parallax_objects.push_front(building)
		z -= 2	
			
func generate_lawn(): 
	create_plants(num_grass, grass_x_off, grass_z_off, grass_x_mult - 1, grass_z_mult - 1)
	create_plants(num_grass/2, grass_x_off, grass_z_off+6, grass_x_mult - 1, grass_z_mult - 1)
	create_plants(num_grass/2, grass_x_off, grass_z_off+12, grass_x_mult - 1, grass_z_mult*2 - 1)
#	my_func(num_grass/4, grass_x_off, grass_z_off+16, grass_x_mult - 1, grass_z_mult*2 - 1)	

	for grass in lawn:
		grass.position.y = z_to_y_converter(grass.real_pos.z)
		grass.z_index = -grass.real_pos.z * 10

func draw_line_to_middle(phys_obj): 
	draw_line(
		Vector2(phys_obj.position.x,phys_obj.position.y), 
		Vector2(SCREEN_MID_X, HORIZON), 
		Color(255, 0, 0), 
		1)

func z_to_y_converter(z_pos):
	z_pos = z_pos * Z_UNIT + 1
	return HORIZON + HORIZON_HEIGHT / z_pos
	
func z_and_x_to_x_converter(hero_x_pos, z_pos, x_pos):
	x_pos = (x_pos + hero_x_pos) * X_UNIT * 1.0
	z_pos = z_pos * Z_UNIT + 1
	return SCREEN_MID_X + x_pos / z_pos



	
func create_plants(n, x_off, y_off, x_mult, y_mult): 
	var positions = PosGenerator.generate_random_positions(n, x_off, y_off, x_mult, y_mult)
	for pos in positions: 
		add_random_plant_to_lawn_at(pos[0] + randf(), pos[1])
		
func add_random_plant_to_lawn_at(x, z): 
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
