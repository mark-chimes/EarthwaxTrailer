extends Node
signal creatures_ready(creatures)

var State = preload("res://desert_strike/State.gd")

# TODO this should work on logic based on buildings and research
export var spawn_time = 1 # time between spawns
export var time_since_spawn = 0 # time since last spawn
export var creature_name = "null"
var faction_dir = State.Dir.RIGHT
export(PackedScene) var creature_type = null

onready var squad_spawner = $SquadSpawner

	# TODO Connect signal
func _ready():
	pass # Replace with function body.

func _process(delta): 
	time_since_spawn += delta
	if time_since_spawn >= spawn_time:  
		time_since_spawn -= spawn_time
		print("Creating creature: " + str(creature_name))
		var creatures = squad_spawner.generate_squad(creature_type, 50, faction_dir)
		# TODO is a string for name the best way of doing this?
		emit_signal("creatures_ready", creatures)
		
