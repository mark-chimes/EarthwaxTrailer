extends Node

signal add_creatures_to_world(creatures)

# TODO this is using node name, maybe we make it a reference later
export(State.Dir) var faction_dir = State.Dir.RIGHT

onready var architect = $Architect
onready var barracks = $Barracks
onready var warlord = $Warlord

func _ready():
	barracks.faction_dir = faction_dir
	warlord.faction_dir = faction_dir

# TODO THIS IS JUST TEMPORARY
func add_units_to_spawn(unit_type, num_units): 
	pass

func _on_Barracks_creatures_ready(creatures):
	# TODO this also needs information on WHERE the creatures are spawning
	# (i.e., at which barracks or which base)
	emit_signal("add_creatures_to_world", creatures)
	warlord.add_creatures(creatures)
