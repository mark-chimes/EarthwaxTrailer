extends Node2D

# TODO this is more of a battle controller than an entity controller at this point
var State = preload("res://desert_strike/State.gd")

const BATTLE_SEP = 10
const NUM_LANES = 4
onready var rng = RandomNumberGenerator.new()


var SpeechSystem = preload("res://desert_strike/SpeechSystem.gd")
var BuildingPlace = preload("res://desert_strike/building/BuildingPlace.tscn") 
onready var parallax_engine = get_parent().get_node("ParallaxEngine")

const TIME_BETWEEN_WAVES = 15

var wave_timer = 0 

func _ready():
	$ArmyHuman.connect("defeat", self, "_human_defeat")
	$ArmyGlut.connect("defeat", self, "_glut_defeat")
	rng.randomize()
	create_building_places()

func _process(delta):
	wave_spawn(delta)
	battle_start()

func wave_spawn(delta): 
	# TODO Waves for already-defeated armies.
	if wave_timer >= TIME_BETWEEN_WAVES: 
		# new wave
		$ArmyHuman.spawn_new_wave()
		$ArmyGlut.spawn_new_wave()
		wave_timer = 0
	else: 
		wave_timer += delta
		
func battle_start():
	# TODO Do we want a separate entity and battle controller? 
	if $ArmyHuman.get_state() == State.Army.BATTLE or $ArmyHuman.get_state() == State.Army.DIE\
			or $ArmyGlut.get_state() == State.Army.BATTLE or $ArmyGlut.get_state() == State.Army.DIE:
		return
	
	if abs($ArmyHuman.get_pos() - $ArmyGlut.get_pos()) < BATTLE_SEP:
		var battlefront_base = ($ArmyHuman.get_pos() + $ArmyGlut.get_pos())/2
		var battlefronts = []
		# TODO RANDOM
		for i in range(0,NUM_LANES): 
			var offset = rng.randf_range(-0.2, 0.2)
			battlefronts.append(battlefront_base + offset)
		
		$ArmyHuman.battle(battlefronts, $ArmyGlut.army_grid)
		$ArmyGlut.battle(battlefronts, $ArmyHuman.army_grid)
		$ArmyHuman.connect("front_line_ready", $ArmyGlut, "_on_front_line_ready")
		$ArmyGlut.connect("front_line_ready", $ArmyHuman, "_on_front_line_ready")
		$ArmyHuman.connect("creature_death", $ArmyGlut, "_on_enemy_creature_death")
		$ArmyGlut.connect("creature_death", $ArmyHuman, "_on_enemy_creature_death")
		$ArmyHuman.connect("attack", $ArmyGlut, "_on_get_attacked")
		$ArmyGlut.connect("attack", $ArmyHuman, "_on_get_attacked")
		
		# SPEECH
		var human_speech_system = SpeechSystem.new()
		var glut_speech_system = SpeechSystem.new()
		$ArmyHuman.set_speech_system(human_speech_system)
		$ArmyGlut.set_speech_system(glut_speech_system)
		$ArmyHuman.connect("many_deaths", self, "_on_many_human_deaths")
		$ArmyGlut.connect("many_deaths", self, "_on_many_glut_deaths")
		$ArmyHuman.say("Prepare for battle!")
		$ArmyGlut.say("GRRR")
		# $ArmyGlut.set_speech_system(speech_system)
		# display_test_text()	

func create_building_places():
	# TODO Should this function be happening in the entity controller?
	var building_place = BuildingPlace.instance()
	building_place.real_pos.z = 9
	building_place.real_pos.x = -40
	add_child(building_place)
	parallax_engine.add_object_to_parallax_world(building_place)
	building_place.set_parallax_engine(parallax_engine) # TODO this is hacky and wrong

func _human_defeat():
	$ArmyGlut.say("jajajajaja")
	start_marching()
	
func _glut_defeat():
	$ArmyHuman.say("They are dead! We've won!")
	start_marching()

func start_marching(): 
	$ArmyHuman.march()
	$ArmyGlut.march()
	$ArmyHuman.disconnect("front_line_ready", $ArmyGlut, "_on_front_line_ready")
	$ArmyGlut.disconnect("front_line_ready", $ArmyHuman, "_on_front_line_ready")
	$ArmyHuman.disconnect("creature_death", $ArmyGlut, "_on_enemy_creature_death")
	$ArmyGlut.disconnect("creature_death", $ArmyHuman, "_on_enemy_creature_death")
	$ArmyHuman.disconnect("attack", $ArmyGlut, "_on_get_attacked")
	$ArmyGlut.disconnect("attack", $ArmyHuman, "_on_get_attacked")
	$ArmyHuman.disconnect("many_deaths", self, "_on_many_human_deaths")
	$ArmyGlut.disconnect("many_deaths", self, "_on_many_glut_deaths")
	
func _on_many_human_deaths(): 
	$ArmyHuman.say("Many of us have died, but hold the line!")
	
func _on_many_glut_deaths(): 
	$ArmyHuman.say("They can be killed! Their numbers wane!")	
	$ArmyGlut.say("Blegh")

func display_test_text(): 
	$ArmyHuman.say("Hello there!")
	yield(get_tree().create_timer(2), "timeout")
	$ArmyHuman.say("Let's wait awhile!")
	yield(get_tree().create_timer(5), "timeout")
	$ArmyHuman.say("Now wait a little time")
	yield(get_tree().create_timer(1), "timeout")
	$ArmyHuman.say("Wait not much")
	yield(get_tree().create_timer(0.5), "timeout")
	$ArmyHuman.say("At all")
	yield(get_tree().create_timer(0.5), "timeout")
	$ArmyHuman.say("The first text...")
	$ArmyHuman.say("...and the second text.")
	yield(get_tree().create_timer(2), "timeout")
	$ArmyHuman.say("A")
	$ArmyHuman.say("Bunch")
	$ArmyHuman.say("of")
	$ArmyHuman.say("text")
	$ArmyHuman.say("at")
	$ArmyHuman.say("once.")	
