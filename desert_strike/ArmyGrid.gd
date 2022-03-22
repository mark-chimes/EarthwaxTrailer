extends Object

# Assume no gaps in a given lane
var creature_lanes = []
var num_lanes = 0

var adding_lane_index = 0
var adding_band_index = 0

func initialize(init_num_lanes): 
	num_lanes = init_num_lanes
	for i in range(0, num_lanes): 
		creature_lanes.append([])
		
func get_lane(lane_index): 
	return creature_lanes[lane_index]

func get_lane_length(lane_index): 
	return len(creature_lanes[lane_index])

func get_creature_band_lane(band_index, lane_index): 
	var lane = creature_lanes[lane_index]
	var creature = lane[band_index]
	# TODO What if no creature there? 
	return creature

func get_all_creatures():
	# TODO optimize?  
	var all_creatures = []
	for lane in creature_lanes:
		for creature in lane: 
			all_creatures.append(creature)
	return all_creatures

# Only use this on an army at spawn
func add_creature(creature): 
	if adding_lane_index >= num_lanes:
		adding_band_index += 1
		adding_lane_index = 0	
	creature.set_band_lane(adding_band_index, adding_lane_index)
	creature_lanes[adding_lane_index].append(creature)
	adding_lane_index += 1
