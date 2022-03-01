extends Object

class Timed_Function:
	var active_time: float
	var to_activate: FuncRef
	
var timed_functions = []
var next_timed_function = null
var greatest_time = 0
var timer = 0

func _add_function_at_time(active_time, func_to_activate): 
	timed_functions.push_back(function_timer_for(active_time, func_to_activate))
	
func add_function_after(extra_time, func_to_activate):
	if timed_functions.empty():
		_add_function_at_time(extra_time, func_to_activate)
		return
	var last_time = timed_functions.back().active_time
	_add_function_at_time(last_time + extra_time, func_to_activate)
	greatest_time = last_time + extra_time

static func function_timer_for(active_time, to_activate): 
	var timed_func = Timed_Function.new()
	timed_func.active_time = active_time
	timed_func.to_activate = to_activate
	return timed_func

func tick_process(delta): 
	timer += delta
	return perform_action_at_time(timer)

func perform_action_at_time(timer): 
	# print("PERFORM ACTION AT TIME: " + str(timer))
	if next_timed_function == null: 
		if timed_functions.empty():
			return false
		next_timed_function = timed_functions.pop_front()
	if timer >= next_timed_function.active_time: 
		next_timed_function.to_activate.call_func()
		if timed_functions.empty():
			next_timed_function = null
			return false
		next_timed_function = timed_functions.pop_front()
	return true
