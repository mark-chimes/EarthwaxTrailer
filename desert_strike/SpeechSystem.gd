extends Object

var army_grid
var rng

const MAX_SPEAKERS = 3
const TIME_TO_SPEAK = 3
var num_speaking = 0

func set_rng(new_rng): 
	rng = new_rng

func set_army_grid(new_army_grid):
	army_grid = new_army_grid
	
func say(text): 
	if num_speaking >= MAX_SPEAKERS:
		return
	num_speaking += 1
	display_text(text)
	
func display_text(text):
	var all_creatures = army_grid.get_all_creatures()
	var num_creatures = len(all_creatures)
	var random_creature_index = rng.randi_range(0, num_creatures-1)
	var random_creature = all_creatures[random_creature_index]
	var num_tries = 0 
	# Finds a creature that isn't speaking - 
	# TODO filter these out in the army grid already
	while(random_creature.is_speaking() and num_tries < num_creatures/2): 
		random_creature_index = rng.randi_range(0, num_creatures-1)
		random_creature = all_creatures[random_creature_index]
	random_creature.say(text)
	random_creature.connect("done_speaking", self, "_on_creature_done_speaking")
	
func _on_creature_done_speaking(creature): 
	creature.disconnect("done_speaking", self, "_on_creature_done_speaking")
	num_speaking -= 1
