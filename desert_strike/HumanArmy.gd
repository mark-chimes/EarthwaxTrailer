extends "res://desert_strike/Army.gd"

onready var Archer = load("res://desert_strike/creature/Archer.tscn")
onready var Farmer = load("res://desert_strike/creature/Farmer.tscn")

signal many_dead_farmers
signal many_dead_archers

const ARCHER_DEATH_TRIGGER_NUM = 4
const FARMER_DEATH_TRIGGER_NUM = 4

var dead_farmers = 0
var dead_archers = 0

var num_farmers_to_spawn = 4
var num_archers_to_spawn = 0


func _ready(): 
	army_dir = State.Dir.RIGHT
	initialize_army()
	spawn_first_wave()

func spawn_first_wave(): 
	add_new_creatures(Farmer, num_farmers_to_spawn)
	add_new_creatures(Archer,num_archers_to_spawn)

func spawn_new_wave(_wave_num): 
	add_new_creatures(Farmer, num_farmers_to_spawn)
	add_new_creatures(Archer, num_archers_to_spawn)

func _on_creature_death(dead_creature): 
	# TODO janky hacky temp code
	print(dead_creature.debug_name + " human death")
	._on_creature_death(dead_creature)
	if is_archer(dead_creature): 
		dead_archers += 1
		if dead_archers >= ARCHER_DEATH_TRIGGER_NUM: 
			say_with_creature("They are killing our ranged units!", funcref(self, "is_farmer"))
			dead_archers = 0
	else: 
		dead_farmers += 1
		if dead_farmers >= FARMER_DEATH_TRIGGER_NUM: 
			say_with_creature("Our farmers are dying!", funcref(self, "is_archer"))
			dead_farmers = 0

func is_archer(creature): 
	return creature.is_ranged

func is_farmer(creature): 
	return not creature.is_ranged

func add_farmers_to_spawn(num_extra):
	num_farmers_to_spawn += num_extra

func add_archers_to_spawn(num_extra):
	num_archers_to_spawn += num_extra
		
