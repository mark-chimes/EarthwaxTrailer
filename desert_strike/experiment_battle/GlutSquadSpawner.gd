extends SquadSpawner

var Grubling = load("res://desert_strike/creature/Grubling.tscn")

func generate_starting_squad():
	army_dir = State.Dir.LEFT
	set_army_start_offset(2)
	initialize_army()
	add_new_creatures(Grubling, 8)
	return army_grid.get_all_creatures()

func generate_starting_squad_grid_for_marching():
	army_dir = State.Dir.LEFT
	set_army_start_offset(10)
	initialize_army()
	add_new_creatures(Grubling, 8)
	return army_grid

func generate_extra_squad(): 
	army_dir = State.Dir.LEFT
	set_army_start_offset(-8)
	initialize_army()
	add_new_creatures(Grubling, 8)
	return army_grid.get_all_creatures()
