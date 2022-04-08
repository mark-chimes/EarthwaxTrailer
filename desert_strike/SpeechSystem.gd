extends Node

var army_grid
var rng

func set_rng(new_rng): 
	rng = new_rng

func set_army_grid(new_army_grid):
	army_grid = new_army_grid
	
func say(text): 
	var all_creatures = army_grid.get_all_creatures()
	var num_creatures = len(all_creatures)
	var random_creature_index = rng.randi_range(0, num_creatures-1)
	var random_creature = all_creatures[random_creature_index]
	var num_tries = 0 
	while(random_creature.is_speaking() and num_tries < num_creatures/2): 
		random_creature_index = rng.randi_range(0, num_creatures-1)
		random_creature = all_creatures[random_creature_index]
	random_creature.say(text)
