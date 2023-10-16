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
	say_with_creature(text, funcref(self, "return_true"))

# Says the text with a creature that satisfies the filter
func say_with_creature(text, creature_filter): 
	if num_speaking >= MAX_SPEAKERS:
		return
	num_speaking += 1
	display_text_on_creature_satisfying(text, creature_filter)

# Private func
func display_text_on_creature_satisfying(text, filter):
	if not army_grid.has_creatures():
		printerr("Trying to get an empty army to say " + text)
		return
		
	var all_creatures = army_grid.get_creatures_satisfying_all([
		funcref(self, "is_creature_able_to_speak"), filter])
	var num_creatures = len(all_creatures)
	if num_creatures == 0: 
		return
	var random_creature_index = rng.randi_range(0, num_creatures-1)
	var random_creature = all_creatures[random_creature_index]
	random_creature.say(text)
	random_creature.connect("done_speaking", self, "_on_creature_done_speaking")	
	
func is_creature_able_to_speak(creature): 
	return not creature.is_speaking() 
	
# In order to not filter on anything
func return_true(_creature):
	return true

func _on_creature_done_speaking(creature): 
	creature.disconnect("done_speaking", self, "_on_creature_done_speaking")
	num_speaking -= 1
