extends Node2D

signal defeat
signal attack(band, lane, damage)
signal front_line_ready(shared_lane)
signal creature_death(band, lane)
signal many_deaths

var ArmyGrid = preload("res://desert_strike/ArmyGrid.gd")
var State = preload("res://desert_strike/State.gd")

var num_deaths = 0
const DEATH_TRIGGER_NUM = 8

# var creature = preload("res://desert_strike/creature/creature.tscn")
var Creature
onready var parallax_engine = get_parent().get_parent().get_node("ParallaxEngine")
onready var rng = RandomNumberGenerator.new()

var battlefronts = []

onready var army_grid = ArmyGrid.new()
var enemy_army_grid
var use_slow_arrows_on_short_dist = true

var speech_system = null

# TODO Special parallax converter subobject for grid army positions to real positions. 


var state = State.Army.IDLE

const BANDS_SPAWNED = 1
const NUM_LANES = 4
const DISTANCE_BETWEEN_LANES = 4
const ARMY_HALF_SEP = 40
const BAND_SEP = 3
const STARTING_BAND_SEP = 8
const ARMY_START_OFFSET = 80
const FIGHT_SEP = 1
const END_POS_DELTA = 0.1

var dead_creatures = 0
var defeat_threshold = NUM_LANES
var army_dir = State.Dir.RIGHT

func initialize_army(): 
	rng.set_seed(hash("42069"))
	army_grid.initialize(NUM_LANES)
	state = State.Army.MARCH

func _on_creature_attack(attacker): 
	if attacker.is_ranged and attacker.band != 0:
		# Ranged attack
		if attacker.ranged_target_band == null or attacker.ranged_target_lane == null: 
			printerr("Ranged attacker at " + str(attacker.band) + ", " + str(attacker.lane) + " targeting null")
			
		if not enemy_army_grid.has_creature_at(attacker.ranged_target_band, attacker.ranged_target_lane):
			return
		emit_signal("attack", attacker.ranged_target_band, attacker.ranged_target_lane, attacker.ranged_damage)
	else: 	
		# melee attack so band is 0
		emit_signal("attack", 0, attacker.lane, attacker.melee_damage)
	
func _on_get_attacked(band_index, lane_index, damage): 
	if not army_grid.has_creature_at(band_index, lane_index): 
		printerr("Null creature being attacked in band_lane (" + str(band_index) + ", " + str(lane_index) + ")")
		return
	army_grid.get_creature_band_lane(band_index, lane_index).take_damage(damage)
		
func get_pos():
	var creatures = army_grid.get_front_creatures()
	if creatures.empty():
		return ARMY_HALF_SEP

	var front_pos = creatures[0].real_pos.x
	if army_dir == State.Dir.RIGHT:
		for creature in creatures: 
			if creature.real_pos.x > front_pos:
				front_pos = creature.real_pos.x
	else: 
		for creature in creatures: 
			if creature.real_pos.x < front_pos:
				front_pos = creature.real_pos.x
	return front_pos



func add_new_creatures(CreatureType, num_creatures): 
	var new_creatures = [] 
	for i in range(0, num_creatures):
		create_and_add_creature(new_creatures, CreatureType)
	if state == State.Army.BATTLE:
		position_army()
	else:
		for creature in new_creatures:
			creature.set_state(State.Creature.MARCH, army_dir)
	return new_creatures

func create_and_add_creature_to_lane_DEBUG(CreatureType, lane_index): 
	var creature = CreatureType.instance()
	army_grid.add_creature_to_lane(creature, lane_index)
	var z_pos = (creature.lane * DISTANCE_BETWEEN_LANES) + 3 
	creature.parallax_engine = parallax_engine
	creature.real_pos.z = z_pos
	add_child(creature)
	creature.dir = army_dir
	creature.real_pos.x = (-army_dir * ARMY_HALF_SEP) \
			+ (-army_dir * creature.band * STARTING_BAND_SEP) + rng.randf_range(-2, 2)\
			+ ARMY_START_OFFSET
	parallax_engine.add_object_to_parallax_world(creature)	
	creature.connect("creature_positioned", self, "_on_creature_positioned")
	creature.connect("attack", self, "_on_creature_attack")
	creature.connect("death", self, "_on_creature_death")
	creature.connect("disappear", parallax_engine, "_on_object_disappear")
	creature.connect("ready_to_swap", self, "_on_creature_ready_to_swap")
	creature.connect("swap_with_booking", self, "_on_creature_swap_with_booking")
	if creature.is_ranged: 
		creature.connect("fire_projectile", self, "_on_creature_fire_projectile")
	creature.set_state(State.Creature.MARCH, army_dir)

func create_and_add_creature(creatures_arr, CreatureType): 
	var creature = CreatureType.instance()
	army_grid.add_creature_to_smallest_lane(creature)
	var z_pos = (creature.lane * DISTANCE_BETWEEN_LANES) + 3 
	creature.parallax_engine = parallax_engine
	creature.real_pos.z = z_pos
	add_child(creature)
	creature.dir = army_dir
	creature.real_pos.x = (-army_dir * ARMY_HALF_SEP) \
			+ (-army_dir * creature.band * STARTING_BAND_SEP) + rng.randf_range(-2, 2)\
			+ ARMY_START_OFFSET
	parallax_engine.add_object_to_parallax_world(creature)	
	creatures_arr.append(creature)
	creature.connect("creature_positioned", self, "_on_creature_positioned")
	creature.connect("attack", self, "_on_creature_attack")
	creature.connect("death", self, "_on_creature_death")
	creature.connect("disappear", parallax_engine, "_on_object_disappear")
	creature.connect("ready_to_swap", self, "_on_creature_ready_to_swap")
	creature.connect("swap_with_booking", self, "_on_creature_swap_with_booking")
	if creature.is_ranged: 
		creature.connect("fire_projectile", self, "_on_creature_fire_projectile")


	

func _on_creature_fire_projectile(archer_pos, target_band, target_lane, projectile): 
	var start_x = archer_pos.x
	
	var lane_offset = FIGHT_SEP + target_lane*1.0/10
	var end_x =  battlefronts[target_lane] + (army_dir * (lane_offset + target_band * BAND_SEP))
	var total_dist = end_x - start_x
	projectile.real_pos.y = -1.5
	projectile.real_pos.x = start_x 
	projectile.real_pos.z = archer_pos.z
	var frames = 7
	var travel_time
	if use_slow_arrows_on_short_dist:
		travel_time = sqrt(total_dist) / 4.0
	else:
		travel_time = total_dist / 20.0
		
	projectile.horizontal_speed = total_dist / travel_time
	
	projectile.start_x = start_x
	projectile.end_x = end_x
	projectile.vertical_speed = -projectile.horizontal_speed
	projectile.vertical_acc = -2*projectile.vertical_speed / (travel_time)
	projectile.rot_dist = total_dist / (frames + 1)
	projectile.is_flying = true
	
	add_child(projectile)
	parallax_engine.add_object_to_parallax_world(projectile)
	projectile.connect("disappear", parallax_engine, "_on_projectile_disappear")
	
func battle(new_battlefronts, new_enemy_army_grid):
	state = State.Army.BATTLE
	battlefronts = new_battlefronts
	enemy_army_grid = new_enemy_army_grid
	position_army()

func get_state():
	return state
	
func _on_creature_ready_to_swap(creature):

#	if dude behind you is good:
#		dude = dude behind you
#	elif dude diagonal is good:
#		dude = dude diagonal
#	elif dude otherdiagonal is good:
#		dude = dude other diagonal
#	else:
#		return
#	dude logic
##
#
#
#	
	if creature.state == State.Creature.DIE: 
		printerr("Dead creature ready to swap: " + creature.debug_name + "(" + str(creature.band) + ", " + str(creature.lane) + ")")
	if creature == null: 
		return
	var  other_creature
	if dude_is_good(creature, creature.band + 1, creature.lane):
		other_creature = army_grid.get_creature_band_lane(creature.band + 1, creature.lane)
	elif dude_is_good(creature, creature.band + 1, creature.lane + 1):
		other_creature = army_grid.get_creature_band_lane(creature.band + 1, creature.lane + 1)
	elif dude_is_good(creature, creature.band + 1, creature.lane - 1):
		other_creature = army_grid.get_creature_band_lane(creature.band + 1, creature.lane - 1)
	else:
		return
	if not creature.is_ready_to_swap: 
		printerr("Asked for swap without being ready")
		return
	if not other_creature.is_ready_to_swap: 
		creature.book_swap(other_creature)
		# Book
		return
	army_grid.swap_creatures(creature, other_creature)
	position_creature(creature)
	position_creature(other_creature)

func dude_is_good(creature, dudeband, dudelane):
	if not army_grid.has_creature_at(dudeband, dudelane):
		return false
	var dude = army_grid.get_creature_band_lane(dudeband, dudelane)
	# TODO getting freed instances
	if dude.is_booked or dude.is_booking:
		return false
	return dude.priority > creature.priority

func _on_creature_swap_with_booking(booked_creature, booking_creature): 

	if booked_creature != null and booking_creature != null: 
		army_grid.swap_creatures(booked_creature, booking_creature)
	if booked_creature != null:
		if booked_creature.state == State.Creature.DIE: 
			printerr("booked_creature dead but swapping: " + booked_creature.debug_name + "(" + str(booked_creature.band) + ", " + str(booked_creature.lane) + ")")
		position_creature(booked_creature)
	if booking_creature != null:
		if booking_creature.state == State.Creature.DIE: 
			printerr("booking_creature dead but swapping: " + booking_creature.debug_name + "(" + str(booking_creature.band) + ", " + str(booking_creature.lane) + ")")
		position_creature(booking_creature)

func _on_creature_death(dead_creature):
	# TODO Create and add corpse
	# create_and_add_corpse(dead_creature.corpse_type)
	var band_index = dead_creature.band
	var lane_index =  dead_creature.lane
	var creature_x = 	dead_creature.real_pos.x
	var creature_z = 	dead_creature.real_pos.z
	
	var CorpseType = dead_creature.get_corpse()
	create_and_add_corpse(CorpseType, creature_x, creature_z)
	
	print(dead_creature.debug_name + " army death at (" + str(band_index) + ", " + str(lane_index) + ")")
	emit_signal("creature_death", band_index, lane_index)
	dead_creature.disconnect("attack", self, "_on_creature_attack")
	dead_creature.disconnect("death", self, "_on_creature_death")

	army_grid.remove_creature(band_index, lane_index)
	move_creature_into_empty_slot(band_index, lane_index)

	# TODO defeat and routing mechanics: 
	if not has_creatures(): 
		print("NO CREATURES!")
		emit_signal("defeat")

#	num_deaths += 1
#
#	if num_deaths >= DEATH_TRIGGER_NUM: 
#		num_deaths = 0
#		emit_signal("many_deaths")


	
func create_and_add_corpse(CorpseType, corpse_x, corpse_z): 
	var corpse = CorpseType.instance()
	corpse.real_pos.x = corpse_x
	corpse.real_pos.z = corpse_z
	add_child(corpse)
	parallax_engine.add_object_to_parallax_world(corpse)
	corpse.connect("disappear", parallax_engine, "_on_object_disappear")
	
func move_creature_into_empty_slot(band, lane): 
	# print("Army grid moving creature into empty slot at (" + str(band) + ", " + str(lane) + ")")
	var  creature = null
	if dude_is_good2(band + 1, lane):
		creature = army_grid.get_creature_band_lane(band + 1, lane)
	elif dude_is_good2(band + 1, lane + 1):
		creature = army_grid.get_creature_band_lane(band + 1, lane + 1)
	elif dude_is_good2(band + 1, lane - 1):
		creature = army_grid.get_creature_band_lane(band + 1, lane - 1)
	if creature == null: 
		# print("Found no elible creature at (" + str(band) + ", " + str(lane) + ")")
		# army_grid.remove_slot(band, lane) # TODO hacky
		yield(get_tree().create_timer(0.5), "timeout")
		# print("Trying again (" + str(band) + ", " + str(lane) + ")")
		move_creature_into_empty_slot(band, lane)
		return
	# print("Found creature (" + str(creature) + ")")
	# print("...with name \"" + creature.debug_name + "\" at position (" + str(creature.band) + ", " + str(creature.lane) + ")")
	var new_band = creature.band
	var new_lane = creature.lane
		
	creature.break_bookings()
	army_grid.move_creature_into_empty_slot(creature, band, lane)
	position_creature(creature)
	
	yield(get_tree().create_timer(0.5), "timeout")
	# print("Trying after success (" + str(new_band) + ", " + str(new_lane) + ")")
	move_creature_into_empty_slot(new_band, new_lane)

func dude_is_good2(dudeband, dudelane): 
	if not army_grid.has_creature_at(dudeband, dudelane):
		return false
	return true
	
func idle():
	state = State.Army.IDLE
	for creature in army_grid.get_all_creatures():
		creature.set_state(State.Creature.IDLE, army_dir)

func march():
	state = State.Army.MARCH
	for creature in army_grid.get_all_creatures():
		creature.set_state(State.Creature.MARCH, army_dir)

func position_creature(creature):
	var target_walk_x = get_target_x_from_band_lane(creature.band, creature.lane)
	var target_walk_z = get_target_z_from_band_lane(creature.band, creature.lane)
	creature.walk_to(target_walk_x, target_walk_z)

func _on_creature_positioned(creature):
	if creature.band == 0:
		if not enemy_army_grid.has_frontline_at_lane(creature.lane): 
			creature.set_state(State.Creature.IDLE, army_dir)
			return
		var enemy_creature = enemy_army_grid.get_frontline_at_lane(creature.lane)

		if enemy_creature.state == State.Creature.AWAIT_FIGHT:
			creature_fight(creature)
		else:
			creature.set_state(State.Creature.AWAIT_FIGHT, army_dir)
		emit_signal("front_line_ready", creature.lane)
	else:
		if creature.is_ranged: 
			var enemy_creature = enemy_army_grid.get_archery_target(creature.lane, creature.attack_range)
			if enemy_creature == null:
				creature.set_state(State.Creature.IDLE, army_dir)
				return
			# TODO wait for enemy to get into position etc. 
			creature_fire_arrow(creature, enemy_creature.band, enemy_creature.lane)
		else: 
			creature.set_state(State.Creature.IDLE, army_dir)

func has_creatures(): 
	return army_grid.has_creatures()

func get_target_x_from_band_lane(band, lane):
	var lane_offset = FIGHT_SEP + lane*1.0/10
	return battlefronts[lane] - (army_dir * (lane_offset + band * BAND_SEP))

func get_target_z_from_band_lane(band, lane):
	return (lane * DISTANCE_BETWEEN_LANES) + 3 

func _on_front_line_ready(shared_lane):
	var creature = army_grid.get_creature_band_lane(0, shared_lane)
	if creature.is_positioned(): 
		if creature.state == State.Creature.AWAIT_FIGHT:
			creature_fight(creature)
	else: 
		position_creature(creature)
	
func creature_fight(creature):
	creature.set_state(State.Creature.FIGHT, army_dir)
	
func creature_fire_arrow(creature, enemy_band, enemy_lane):
	enemy_band > enemy_lane # Try to crash if this is null
	creature.set_archery_target_band_lane(enemy_band, enemy_lane) 
	creature.set_state(State.Creature.FIGHT, army_dir)
	
func _on_enemy_creature_death(band_index, lane_index):
	if band_index == 0: 
		position_lane(lane_index)

func position_army(): 
	for creature in army_grid.get_all_creatures():
		position_creature(creature)

func position_lane(lane_index): 
	for creature in army_grid.get_lane(lane_index): 
		position_creature(creature)
		
func should_creature_1_be_further_back(creature1, creature2): 
	# higher priority to the front
	# but front is a lower index
	if creature1.state in [State.Creature.FIGHT, State.Creature.AWAIT_FIGHT]\
			and not creature2.state in [State.Creature.FIGHT, State.Creature.AWAIT_FIGHT]:
		return false
		
	if not creature1.state in [State.Creature.FIGHT, State.Creature.AWAIT_FIGHT]\
			and creature2.state in [State.Creature.FIGHT, State.Creature.AWAIT_FIGHT]: 
		return true
		
	return creature1.priority < creature2.priority

func set_speech_system(new_speech_system): 
	speech_system = new_speech_system
	speech_system.set_army_grid(army_grid)
	speech_system.set_rng(rng)

func say(text): 
	if speech_system == null: 
		return
	speech_system.say(text)

func say_with_creature(text, filter): 
	if speech_system == null: 
		return
	speech_system.say_with_creature(text, filter)
