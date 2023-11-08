extends SquadSpawner

onready var Archer = load("res://desert_strike/creature/Archer.tscn")
onready var Farmer = load("res://desert_strike/creature/Farmer.tscn")

var num_farmers_to_spawn = 2
var num_archers_to_spawn = 4

func generate_starting_squad():
	army_dir = State.Dir.RIGHT
	set_army_start_offset(-2)
	initialize_army()
	add_new_creatures(Farmer, num_farmers_to_spawn)
	add_new_creatures(Archer,num_archers_to_spawn)
	return army_grid.get_all_creatures()

func generate_extra_squad():
	army_dir = State.Dir.RIGHT
	set_army_start_offset(-10)
	initialize_army()
	add_new_creatures(Farmer, num_farmers_to_spawn)
	add_new_creatures(Archer,num_archers_to_spawn)
	return army_grid.get_all_creatures()
