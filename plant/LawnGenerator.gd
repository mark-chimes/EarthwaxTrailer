extends Node

# TODO CREATE THIS CLASS

var rng = RandomNumberGenerator.new()
var Flower = preload("res://plants/Flowers.tscn")
var parent
var plants_array

func initialize_lawn_generator(the_parent, the_plants_array): 
	parent = the_parent
	plants_array = the_plants_array

func add_random_plant_to_lawn_at(x, z): 
	var num = rng.randi_range(0, 4)
	var plant = Flower.instance()
	plant.plant_num = num

	parent.add_child(plant)
	plant.real_pos.x = x
	plant.real_pos.z = z
	
	if plant.real_pos.z > 20: 
		plant.get_node("AnimatedSprite2").visible = true
		plant.get_node("AnimatedSprite").visible = false
		plant.get_node("AnimatedSprite2").animation = "filtered"
		plant.get_node("AnimatedSprite2").frame = plant.plant_num	
	elif plant.real_pos.z > 15 and plant.real_pos.z <= 20:
		var is_close = rng.randi_range(0,4)
		if is_close == 0:
			plant.get_node("AnimatedSprite").visible = true
			plant.get_node("AnimatedSprite2").visible = false
			plant.get_node("AnimatedSprite").animation = "filtered"
			plant.get_node("AnimatedSprite").frame = plant.plant_num
			plant.get_node("AnimatedSprite").get_node("AnimatedSprite").frame = plant.plant_num
		else: 
			plant.get_node("AnimatedSprite2").visible = true
			plant.get_node("AnimatedSprite").visible = false
			plant.get_node("AnimatedSprite2").animation = "filtered"
			plant.get_node("AnimatedSprite2").frame = plant.plant_num	
	else: 
		plant.get_node("AnimatedSprite").visible = true
		plant.get_node("AnimatedSprite2").visible = false
		plant.get_node("AnimatedSprite").animation = "filtered"
		plant.get_node("AnimatedSprite").frame = plant.plant_num
		plant.get_node("AnimatedSprite").get_node("AnimatedSprite").frame = plant.plant_num
	
	plants_array.push_front(plant)
