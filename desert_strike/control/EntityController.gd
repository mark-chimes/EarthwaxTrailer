extends Node2D

# TODO move functionality into other classes
# When the armies encounter each other, spawn an adjudicator
# pass the armies to the adjudicator 

var State = preload("res://desert_strike/State.gd")

const BATTLE_SEP = 10
const NUM_LANES = 4
onready var rng = RandomNumberGenerator.new()

var SpeechSystem = preload("res://desert_strike/SpeechSystem.gd")
var BuildingPlace = preload("res://desert_strike/building/BuildingPlace.tscn") 
var Farm = preload("res://desert_strike/building/Farm.tscn") 
var ArcheryTargets = preload("res://desert_strike/building/ArcheryTargets.tscn") 
var ArcheryTarget = preload("res://desert_strike/building/ArcheryTarget.tscn") 
var FarmerAtHut = preload("res://desert_strike/building/FarmerAtHut.tscn") 
var ArcherAtHut = preload("res://desert_strike/building/ArcherAtHut.tscn") 
var Checkpoint = preload("res://desert_strike/Checkpoint.tscn")

var checkpoints = [] # TOOD allow for multiple checkpoints

onready var parallax_engine = get_parent().get_node("ParallaxEngine")

const TIME_BETWEEN_WAVES = 60

var wave_timer = 0 
var wave_num = 1

var income_ui = null 
var money_ui = null 
# TODO This isn't the right way to do this - should use signals and a parent object
var income = 0 
var money = 0

func _ready():
	# TODO when armies encounter each other, they should be converted between army types
	# I.e., Formation or Deployment
	
	$HumanArmy.connect("defeat", self, "_human_defeat")
	$GlutArmy.connect("defeat", self, "_glut_defeat")
	
	$HumanArmy.set_army_start_offset(20)
	$GlutArmy.set_army_start_offset(60)
	$HumanArmy.start_army()
	$GlutArmy.start_army()
	
	rng.randomize()
	create_building_places()
	create_checkpoints()
	
	adjust_income(1)
	adjust_money(20)

	
func _process(delta):
	wave_spawn(delta)
	battle_start()
	check_checkpoints(delta)

func wave_spawn(delta): 
	# TODO Waves for already-defeated armies.
	if wave_timer >= TIME_BETWEEN_WAVES: 
		
		# Find last owned checkpoint
		var furthest_checkpoint = null
		var furthest_dist = 1000000000
		for checkpoint in checkpoints: 
			if checkpoint.real_pos.x < furthest_dist:
				if checkpoint.check_ownership() == -1:
					furthest_checkpoint = checkpoint
					furthest_dist = checkpoint.real_pos.x
		if furthest_checkpoint == null: 
			$GlutArmy.set_army_start_offset(140)
		else: 
			$GlutArmy.set_army_start_offset(furthest_dist)
		
		furthest_checkpoint = null
		furthest_dist = -1000000000
		for checkpoint in checkpoints: 
			if checkpoint.real_pos.x > furthest_dist:
				if checkpoint.check_ownership() == 1:
					furthest_checkpoint = checkpoint
					furthest_dist = checkpoint.real_pos.x
		if furthest_checkpoint == null: 
			$HumanArmy.set_army_start_offset(0)
		else: 
			$HumanArmy.set_army_start_offset(furthest_dist)
		
		
		
		# new wave
		$HumanArmy.spawn_new_wave(wave_num)
		$GlutArmy.spawn_new_wave(wave_num)
		if $HumanArmy.get_state() == State.Army.DIE: 
			$HumanArmy.march()
		if $GlutArmy.get_state() == State.Army.DIE: 
			$GlutArmy.march()
		wave_num += 1
		wave_timer = 0
		adjust_money(income)
	else: 
		wave_timer += delta

func battle_start():
	# TODO Do we want a separate entity and battle controller? 
	if $HumanArmy.get_state() == State.Army.BATTLE or $HumanArmy.get_state() == State.Army.DIE\
			or $GlutArmy.get_state() == State.Army.BATTLE or $GlutArmy.get_state() == State.Army.DIE:
		return
	
	if abs($HumanArmy.get_pos() - $GlutArmy.get_pos()) < BATTLE_SEP:
		var battlefront_base = ($HumanArmy.get_pos() + $GlutArmy.get_pos())/2
		var battlefronts = []
		# TODO RANDOM
		for i in range(0,NUM_LANES): 
			var offset = rng.randf_range(-0.2, 0.2)
			battlefronts.append(battlefront_base + offset)
		
		$HumanArmy.battle(battlefronts, $GlutArmy.army_grid)
		$GlutArmy.battle(battlefronts, $HumanArmy.army_grid)
		$HumanArmy.connect("front_line_ready", $GlutArmy, "_on_front_line_ready")
		$GlutArmy.connect("front_line_ready", $HumanArmy, "_on_front_line_ready")
		$HumanArmy.connect("creature_death", $GlutArmy, "_on_enemy_creature_death")
		$GlutArmy.connect("creature_death", $HumanArmy, "_on_enemy_creature_death")
		$HumanArmy.connect("attack", $GlutArmy, "_on_get_attacked")
		$GlutArmy.connect("attack", $HumanArmy, "_on_get_attacked")
		$HumanArmy.connect("projectile_attack", $GlutArmy, "_on_enemy_projectile_attack")
		$GlutArmy.connect("projectile_attack", $HumanArmy, "_on_enemy_projectile_attack")
		
		# SPEECH
		var human_speech_system = SpeechSystem.new()
		var glut_speech_system = SpeechSystem.new()
		$HumanArmy.set_speech_system(human_speech_system)
		$GlutArmy.set_speech_system(glut_speech_system)
		$HumanArmy.connect("many_deaths", self, "_on_many_human_deaths")
		$GlutArmy.connect("many_deaths", self, "_on_many_glut_deaths")
		$HumanArmy.say("Prepare for Trouble!")
		$HumanArmy.say("And make it double!")
		$GlutArmy.say("GRRR")
		# $GlutArmy.set_speech_system(speech_system)
		# display_test_text()	

func check_checkpoints(delta): 
	if $HumanArmy.get_state() == State.Army.BATTLE or $GlutArmy.get_state() == State.Army.BATTLE:
		return
	
	# TODO this is a really hacky way to check checkpoints and set their states
	# We need to: 
	# - Use a direction
	# - Have a specific state for capturing a checkpoint
	# - Have a nice way to know what's the next checkpoint they should target 
	# 		(rather than checking through the whole array)
	# - Keep track of what checkpoint the army is busy trying to capture
	# - Be able to go back to a checkpoint we've passed
	
	if $GlutArmy.get_state() != State.Army.DIE:
		var closest_checkpoint = null
		var closest_dist = -1000000000
		for checkpoint in checkpoints: 
			if checkpoint.real_pos.x > closest_dist:
				if checkpoint.check_ownership() > -1:
					closest_checkpoint = checkpoint
					closest_dist = checkpoint.real_pos.x
		if closest_checkpoint == null: 
			$GlutArmy.idle()
		else:
			if $GlutArmy.get_pos() < closest_checkpoint.real_pos.x - 4:
				if closest_checkpoint.check_ownership() > -1:
					$GlutArmy.idle()
					closest_checkpoint.modify_ownership(-5 * delta)
					# TODO move this out? 
				else: 
					if $GlutArmy.get_state() != State.Army.MARCH: # TODO use "capture" state
						$GlutArmy.march() # TODO this should only happen once
			else: 
				if $GlutArmy.get_state() != State.Army.MARCH: # TODO use "capture" state
					$GlutArmy.march() # TODO this should only happen once	
		
	if $HumanArmy.get_state() != State.Army.DIE:
		var closest_checkpoint = null
		var closest_dist = 1000000000
		for checkpoint in checkpoints: 
			if checkpoint.real_pos.x < closest_dist:
				if checkpoint.check_ownership() < 1:
					closest_checkpoint = checkpoint
					closest_dist = checkpoint.real_pos.x
		if closest_checkpoint == null: 
			$HumanArmy.idle()
		else: 
			if $HumanArmy.get_pos() > closest_checkpoint.real_pos.x + 4:
				if closest_checkpoint.check_ownership() < 1:
					$HumanArmy.idle()
					closest_checkpoint.modify_ownership(5 * delta)
				else: 
					if $HumanArmy.get_state() != State.Army.MARCH: # TODO use "capture" state
						$HumanArmy.march() # TODO this should only happen once
			else: 
				if $HumanArmy.get_state() != State.Army.MARCH: # TODO use "capture" state
					$HumanArmy.march() # TODO this should only happen once
				
				
func create_building_places(): 
	# TODO Should this function be happening in the entity controller?
	create_building_places_at(range(0, -121, -12))


func create_building_places_at(x_poses):
	for x_pos in x_poses: 
		create_building_place_at(x_pos)

func create_building_place_at(x_pos): 
	var building_place = BuildingPlace.instance()
	building_place.real_pos.z = 9
	building_place.real_pos.x = x_pos
	add_child(building_place)
	building_place.connect("place_structure", self, "_on_building_place_structure")
	parallax_engine.add_object_to_parallax_world(building_place)
	building_place.set_parallax_engine(parallax_engine) # TODO this is hacky and wrong

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
	
func _on_building_place_structure(building_place): 

	var new_building
	var new_person
	if building_place.building_state == "farm": 
		if money < 2: 
			return
		adjust_money(-2)
		
		for i in range(0,3):
			new_building = Farm.instance()
			new_building.real_pos.z = 48 + i*8
			new_building.real_pos.x = building_place.real_pos.x
			add_child(new_building)
			parallax_engine.add_object_to_parallax_world(new_building)
		new_person = FarmerAtHut.instance()
		$HumanArmy.add_farmers_to_spawn(2)
		adjust_income(1)
	else: 
		if money < 2: 
			return
		adjust_money(-2)
		new_person = ArcherAtHut.instance()
		$HumanArmy.add_archers_to_spawn(2)

		new_building = ArcheryTargets.instance()
		new_building.real_pos.z = 48
		new_building.real_pos.x = building_place.real_pos.x
		add_child(new_building)
		parallax_engine.add_object_to_parallax_world(new_building)
		
		new_building = ArcheryTarget.instance()
		new_building.real_pos.z = 64
		new_building.real_pos.x = building_place.real_pos.x
		add_child(new_building)
		parallax_engine.add_object_to_parallax_world(new_building)

	new_person.connect("destroy_structure", self, "_on_person_at_hut_destroy_structure")
	new_person.set_connected_structure(new_building)
	new_person.real_pos.z = building_place.real_pos.z
	new_person.real_pos.x = building_place.real_pos.x
	new_person.set_parallax_engine(parallax_engine)
	parallax_engine.add_object_to_parallax_world(new_person)
	add_child(new_person)
	
	parallax_engine.remove_object(building_place)

func adjust_income(increase): 
	income += increase

func adjust_money(increase): 
	money += increase

func _on_person_at_hut_destroy_structure(person_at_hut): 
	create_building_place_at(person_at_hut.real_pos.x)
	parallax_engine.remove_object(person_at_hut.connected_structure)
	parallax_engine.remove_object(person_at_hut)
	
func _human_defeat():
	$GlutArmy.say("jajajajaja")
	$GlutArmy.march()
	$HumanArmy.die()
	disconnect_signals()
	
func _glut_defeat():
	$HumanArmy.say("They are dead! We've won!")
	$HumanArmy.march()
	$GlutArmy.die()
	disconnect_signals()

func disconnect_signals(): 
	$HumanArmy.disconnect("front_line_ready", $GlutArmy, "_on_front_line_ready")
	$GlutArmy.disconnect("front_line_ready", $HumanArmy, "_on_front_line_ready")
	$HumanArmy.disconnect("creature_death", $GlutArmy, "_on_enemy_creature_death")
	$GlutArmy.disconnect("creature_death", $HumanArmy, "_on_enemy_creature_death")
	$HumanArmy.disconnect("attack", $GlutArmy, "_on_get_attacked")
	$GlutArmy.disconnect("attack", $HumanArmy, "_on_get_attacked")
	$HumanArmy.disconnect("projectile_attack", $GlutArmy, "_on_enemy_projectile_attack")
	$GlutArmy.disconnect("projectile_attack", $HumanArmy, "_on_enemy_projectile_attack")
	$HumanArmy.disconnect("many_deaths", self, "_on_many_human_deaths")
	$GlutArmy.disconnect("many_deaths", self, "_on_many_glut_deaths")
	
func _on_many_human_deaths(): 
	$HumanArmy.say("Many of us have died, but hold the line!")
	
func _on_many_glut_deaths(): 
	$HumanArmy.say("They can be killed! Their numbers wane!")	
	$GlutArmy.say("Blegh")

func display_test_text(): 
	$HumanArmy.say("Hello there!")
	yield(get_tree().create_timer(2), "timeout")
	$HumanArmy.say("Let's wait awhile!")
	yield(get_tree().create_timer(5), "timeout")
	$HumanArmy.say("Now wait a little time")
	yield(get_tree().create_timer(1), "timeout")
	$HumanArmy.say("Wait not much")
	yield(get_tree().create_timer(0.5), "timeout")
	$HumanArmy.say("At all")
	yield(get_tree().create_timer(0.5), "timeout")
	$HumanArmy.say("The first text...")
	$HumanArmy.say("...and the second text.")
	yield(get_tree().create_timer(2), "timeout")
	$HumanArmy.say("A")
	$HumanArmy.say("Bunch")
	$HumanArmy.say("of")
	$HumanArmy.say("text")
	$HumanArmy.say("at")
	$HumanArmy.say("once.")	
