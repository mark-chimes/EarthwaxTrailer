extends Object

var holding_object
var parallax_objects_list
var rng

func init_values(init_holding_object, init_parallax_objects_list):
	holding_object = init_holding_object
	parallax_objects_list = init_parallax_objects_list
	rng = RandomNumberGenerator.new()

func create_single_object(object_type, x_pos, z_pos, custom_array): 
	var obj = object_type.instance()
	holding_object.add_child(obj)
	obj.real_pos.x = x_pos
	obj.real_pos.z = z_pos
	parallax_objects_list.append(obj)
	if custom_array != null: 
		custom_array.append(obj)

func create_objects_in_rectangle(object_type, num_x, num_z, x_offset, z_offset,
	x_distance, z_distance, should_randomize, custom_array): 
	for z in range(num_z):
		for x in range(num_x):
			var obj = object_type.instance()
			holding_object.add_child(obj)
			obj.real_pos.x = x * x_distance + x_offset
			obj.real_pos.z = z * z_distance + z_offset
			if should_randomize: 
				obj.real_pos.x += randf()*16 - 32
				obj.real_pos.z += randf() - 0.5
			parallax_objects_list.append(obj)
			if custom_array != null: 
				custom_array.append(obj)
				

func create_objects_in_rectangle_randoff(object_type, num_x, num_z, x_offset, z_offset, randoff_x,
	x_distance, z_distance, should_randomize, custom_array): 

	for z in range(num_z):
		var x_shift = randf()*randoff_x
		for x in range(num_x):
			var obj = object_type.instance()
			var should_flip = rng.randi_range(0,1)
			if should_flip == 0: 
				obj.scale.x = -obj.scale.x
			holding_object.add_child(obj)
			obj.real_pos.x = x * x_distance + x_offset
			obj.real_pos.z = z * z_distance + z_offset
			obj.real_pos.x += x_shift
			if should_randomize: 
				obj.real_pos.z += randf() - 0.5
			parallax_objects_list.append(obj)
			if custom_array != null: 
				custom_array.append(obj)
