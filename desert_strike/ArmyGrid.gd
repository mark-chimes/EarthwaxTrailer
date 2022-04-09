extends Object

# Assume no gaps in a given lane
var creature_lanes = []
var num_lanes = 0

var adding_lane_index = 0
var adding_band_index = 0
var rng

func initialize(init_num_lanes): 
	rng = RandomNumberGenerator.new()
	rng.randomize()
	num_lanes = init_num_lanes
	for _i in range(0, num_lanes): 
		creature_lanes.append([])
		
func get_lane(lane_index): 
	return creature_lanes[lane_index]

func get_lane_length(lane_index): 
	return len(creature_lanes[lane_index])

func has_creature_at(band_index, lane_index): 
	if lane_index >= len(creature_lanes): 
		return false
	var lane = creature_lanes[lane_index]
	return (band_index < len(lane))

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
			all_creatures.append(creature)
	return all_creatures

func get_front_creatures(): 
	var front_creatures = []
	for lane in creature_lanes: 
		if len(lane) > 0:
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

func add_creature_to_shortest_lane(creature): 
	var shortest_lane_index = 0
	var shortest_length = len(creature_lanes[0])
	
	for lane_index in range(len(creature_lanes)): 
		var lane = creature_lanes[lane_index]
		if len(lane) < shortest_length:
			shortest_lane_index = lane_index
			shortest_length = len(creature_lanes[lane_index])
			
	var lane = creature_lanes[shortest_lane_index]
	creature.set_band_lane(len(lane), shortest_lane_index)
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
	return lane[target_index]

func swap_creatures(creature1, creature2):
	var hold_band = creature1.band
	var hold_lane = creature1.lane
	creature_lanes[creature1.lane][creature1.band] = creature2
	creature_lanes[creature2.lane][creature2.band] = creature1
	creature1.set_band_lane(creature2.band, creature2.lane)
	creature2.set_band_lane(hold_band, hold_lane)
