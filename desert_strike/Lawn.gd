extends Node2D

# Imports
var DistantForestTile = preload("res://decor/forest/distant/DistantForestTile.tscn")
var Flower = preload("res://decor/flower/Flower.tscn")
var Grass = preload("res://decor/grass/Grass.tscn")
var PosGenerator = preload("res://parallax/util/RandomPositionGenerator.gd")
var GrassStrip = preload("res://decor/grass/GrassStrip.tscn")
var GrassMud = preload("res://decor/grass/GrassMudStrip.tscn")
var ReedStrip = preload("res://decor/reed/ReedStrip.tscn")
var MudStrip = preload("res://decor/mud/MudStrip.tscn")
var Rat = preload("res://entity/creature/animal/rat/parallax/ParallaxRat.tscn")

var rng = RandomNumberGenerator.new()
onready var parallax_engine = get_parent().get_node("ParallaxEngine")

# Parallax Lists
var grass_strips = []
var reed_strips = []

func _ready():
	#parallax_engine._ready()
	make_reeds()
	generate_lawn() 
	make_tree_line()

func make_tree_line(): 
	parallax_engine.create_objects_in_rectangle(DistantForestTile, 120, 1, 
		-400, 150, 34, 1, false, [])

func make_reeds(): 
	parallax_engine.create_objects_in_rectangle_randoff(MudStrip, 3, 10, 
			-100, -1.5, 0, 120, 0.3, false, reed_strips)	

	parallax_engine.create_objects_in_rectangle_randoff(ReedStrip, 3, 3, 
			-100, -1.8, 0, 120, 0.7, true, reed_strips)	

func generate_lawn(): 
	var grass_muds = []
	parallax_engine.create_objects_in_rectangle_back(GrassMud, 10, 240, -100, 2, 30, 1, true, grass_muds)
	for grassmud in grass_muds: 
		parallax_engine.z_scale(grassmud)
	var plants_x_width = 200
	var plants_x_off = -plants_x_width / 2
	var plants_z_off = 3
	var plants_z_length = 32
	var plants_x_sep = 12
	var plants_z_sep = 4
	create_plants(plants_x_off, plants_z_off, 
			plants_x_width, plants_z_length, plants_x_sep, plants_z_sep)

func create_plants(x_off, z_off, x_width, z_length, x_sep, z_sep): 
	var positions = PosGenerator.generate_random_positions_sep_wid(
		x_off, z_off, x_width, z_length, x_sep, z_sep)
	for pos in positions: 
		add_random_plant_to_lawn_at(pos[0], pos[1])

func add_random_plant_to_lawn_at(x, z): 
	var num1 = rng.randi_range(0, 4)
	var plant
	if num1 == 0:
		plant = Flower.instance()
		var num = rng.randi_range(0, 4)
		plant.plant_num = num
	else: 
		plant = Grass.instance()
		var num = rng.randi_range(0, 2)
		plant.plant_num = num
	add_child(plant)
	plant.real_pos.x = x
	plant.real_pos.z = z
	if plant.real_pos.z > 20: 
		plant.get_node("AnimatedSprite2").visible = true
		plant.get_node("AnimatedSprite").visible = false
		plant.get_node("AnimatedSprite2").animation = "unfiltered"
		plant.get_node("AnimatedSprite2").frame = plant.plant_num	
	elif plant.real_pos.z > 15 and plant.real_pos.z <= 20:
		var is_close = rng.randi_range(0,4)
		if is_close == 0:
			plant.get_node("AnimatedSprite2").visible = true
			# plant.get_node("AnimatedSprite2").visible = false
			plant.get_node("AnimatedSprite2").animation = "unfiltered"
			plant.get_node("AnimatedSprite2").frame = plant.plant_num
			plant.get_node("AnimatedSprite2").get_node("AnimatedSprite3").frame = plant.plant_num
		else: 
			plant.get_node("AnimatedSprite2").visible = true
			#plant.get_node("AnimatedSprite").visible = false
			plant.get_node("AnimatedSprite2").animation = "unfiltered"
			plant.get_node("AnimatedSprite2").frame = plant.plant_num	
	else: 
		plant.get_node("AnimatedSprite2").visible = true
		#plant.get_node("AnimatedSprite2").visible = false
		plant.get_node("AnimatedSprite2").animation = "unfiltered"
		plant.get_node("AnimatedSprite2").frame = plant.plant_num
		plant.get_node("AnimatedSprite2").get_node("AnimatedSprite3").frame = plant.plant_num
	parallax_engine.add_object_to_parallax_world(plant)
