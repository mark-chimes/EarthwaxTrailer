extends Object

# Assume no gaps in a given lane
var creature_lanes = []
var num_lanes = 0

var adding_lane_index = 0
var adding_band_index = 0
var rng
var EMPTY_SLOT = Node.new()

func initialize(init_num_lanes): 
	rng = RandomNumberGenerator.new()
	rng.randomize()
	num_lanes = init_num_lanes
	for _i in range(0, num_lanes): 
		creature_lanes.append([])
		
#does not return empty slots, should probably be renamed
func get_lane(lane_index): 
	var creatures = []
	for creature in creature_lanes[lane_index]:
		if creature != EMPTY_SLOT:
			creatures.append(creature)
	return creatures

func has_creature_at(band_index, lane_index): 
	if lane_index >= len(creature_lanes) or lane_index < 0: 
		#creature not in lane
		return false
	var lane = creature_lanes[lane_index]
	if (band_index >= len(lane) or band_index < 0):
		#creature not in band
		return false
	if lane[band_index] == EMPTY_SLOT:
		return false
	return true

func get_frontline_at_lane(lane_index): 
	return get_creature_band_lane(0, lane_index)

func has_frontline_at_lane(lane_index): 
	return has_creature_at(0, lane_index)

func get_creature_band_lane(band_index, lane_index): 
	if not has_creature_at(band_index, lane_index):
		printerr("Attempting to access null creature in b:" + str(band_index) + ", l:" + str(lane_index))
		return
	var lane = creature_lanes[lane_index]
	var creature = lane[band_index]
	return creature

func get_all_creatures():
	# TODO optimize?  
	var all_creatures = []
	for lane in creature_lanes:
		for creature in lane: 
			if creature != EMPTY_SLOT:
				all_creatures.append(creature)
	return all_creatures
	
# Pass in a list of funcrefs each of which takes in a creature and return a bool
# If all of the funcrefs return true, then the creature is acceptable 
func get_creatures_satisfying_all(filters): 
	var filtered_creatures = []
	for creature in get_all_creatures():
		var satisfies_all_filters = true
		for filter in filters:
			if not filter.call_func(creature):
				satisfies_all_filters = false
		if satisfies_all_filters:
			filtered_creatures.append(creature)	
	return filtered_creatures

# Pass in a single funcref which takes in a creature and returns a bool
func get_creatures_satisfying(filter): 
	var filtered_creatures = []
	for creature in get_all_creatures():
		if filter.call_func(creature):
			filtered_creatures.append(creature)	
	return filtered_creatures

func get_front_creatures(): 
	var front_creatures = []
	for lane in creature_lanes: 
		if len(lane) > 0:
			if lane[0] != EMPTY_SLOT:
				front_creatures.append(lane[0])
	return front_creatures

# Only use this on an army at spawn
func add_creature(creature): 
	if adding_lane_index >= num_lanes:
		adding_band_index += 1
		adding_lane_index = 0	
	creature.set_band_lane(adding_band_index, adding_lane_index)
	creature_lanes[adding_lane_index].append(creature)
	adding_lane_index += 1

func add_creature_to_lane(creature, lane_index): 
	var lane = creature_lanes[lane_index]
	creature.set_band_lane(len(lane), lane_index)
	lane.append(creature)

func get_num_creatures_in_lane(lane):
	var num_creatures = 0
	for creature in lane:
		if creature != EMPTY_SLOT:
			num_creatures += 1
	return num_creatures

func add_empty_slot_to_end_of_lane_DEBUG(lane_index):
	var lane = creature_lanes[lane_index]
	lane.append(EMPTY_SLOT)
	

func add_creature_to_smallest_lane(creature): 
	var smallest_lane_index = 0
	var smallest_length = get_num_creatures_in_lane(creature_lanes[0])
	
	for lane_index in range(len(creature_lanes)): 
		var lane = creature_lanes[lane_index]
		if get_num_creatures_in_lane(lane) < smallest_length:
			smallest_lane_index = lane_index
			smallest_length = get_num_creatures_in_lane(creature_lanes[lane_index])
			
	var lane = creature_lanes[smallest_lane_index]
	creature.set_band_lane(len(lane), smallest_lane_index)
	lane.append(creature)
	
func has_creatures(): 
	for lane in creature_lanes: 
		if len(lane) > 0:
			return true
	return false

# TODO this should be handled in a battle API not in army grid
# TODO Change how range works to take the creature's position into account
func get_archery_target(lane_index, attack_range): 
	var lane = creature_lanes[lane_index] 
	if len(lane) == 0: 
		return null # no valid target
	
	var max_shot = min(len(lane)-1, attack_range)
	var target_index = rng.randi_range(0, max_shot) 
	if lane[target_index] == EMPTY_SLOT:
		return null
	return lane[target_index]

func swap_creatures(creature1, creature2):
	var hold_band = creature1.band
	var hold_lane = creature1.lane
	creature_lanes[creature1.lane][creature1.band] = creature2
	creature_lanes[creature2.lane][creature2.band] = creature1
	creature1.set_band_lane(creature2.band, creature2.lane)
	creature2.set_band_lane(hold_band, hold_lane)
