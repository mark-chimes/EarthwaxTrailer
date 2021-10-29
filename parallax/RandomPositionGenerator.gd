extends Reference

static func generate_random_positions(n, x_off, y_off, x_mult, y_mult): 
	var g = gamma(2)
	var my_seed = 0.5
	
	var alpha_x = fmod(pow(1/g, 1), 1.0)
	var alpha_y = fmod(pow(1/g, 2), 1.0)
	
	var positions = []
	var x_cur = my_seed
	var y_cur = my_seed 

	for i in range(n): 
		var pos = []
		x_cur = fmod(x_cur + alpha_x, 1)
		y_cur = fmod(y_cur + alpha_y, 1)
		pos.append(x_off + x_cur*x_mult)
		pos.append(y_off + y_cur*y_mult)
		positions.append(pos)
		
	return positions

static func gamma(dim): 
	var x=1.0000
	for i in range(20):
		x = x-(pow(x,dim+1)-x-1)/((dim+1)*pow(x,dim)-1)
	return x
