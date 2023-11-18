extends Node2D
signal creatures_added_to_world(creatures)

# TODO move functionality into other classes
# When the armies encounter each other, spawn an adjudicator
# pass the armies to the adjudicator 

var State = preload("res://desert_strike/State.gd")

const BATTLE_SEP = 10
const NUM_LANES = 4
onready var rng = RandomNumberGenerator.new()

var Checkpoint = preload("res://desert_strike/Checkpoint.tscn")

var checkpoints = [] # TOOD allow for multiple checkpoints

onready var parallax_engine = get_parent().get_node("Renderables/ParallaxEngine")

const TIME_BETWEEN_WAVES = 60

var wave_timer = 0 
var wave_num = 1

onready var factions = [$HumanFaction, $GlutFaction]
onready var player_faction = $HumanFaction

func _ready():
	# TODO when armies encounter each other, they should be converted between army types
	# I.e., Formation or Deployment
#
#	$HumanArmy.connect("defeat", self, "_human_defeat")
#	$GlutArmy.connect("defeat", self, "_glut_defeat")
#
#	$HumanArmy.set_army_start_offset(20)
#	$GlutArmy.set_army_start_offset(60)
#	$HumanArmy.start_army()
#	$GlutArmy.start_army()
#
	rng.randomize()
	create_checkpoints()
	
var tick_timer = 1.0

func _process(delta):
	pass
		
func create_checkpoints(): 
	create_checkpoint(10, 1)
	create_checkpoint(40, 0)
	create_checkpoint(70, -1)
	create_checkpoint(100, -1)
	create_checkpoint(130, -1)
	
func create_checkpoint(checkpoint_pos, ownership): 
	var checkpoint = Checkpoint.instance()
	checkpoint.real_pos.z = 40
	checkpoint.real_pos.x = checkpoint_pos
	checkpoint.set_ownership(ownership)
	checkpoints.append(checkpoint)
	add_child(checkpoint)
	parallax_engine.add_object_to_parallax_world(checkpoint)
	

func _on_Faction_add_creatures_to_world(creatures):
	# creatures is a grid, but we need a list to iterate
	emit_signal("creatures_added_to_world", creatures.get_all_creatures())
