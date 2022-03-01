extends Node2D

var FunctionTimerScript = load("res://trailer/utils/timing/FunctionTimer.gd")

var has_scene_started = false
var has_ended = false

var function_timer


# Called when the node enters the scene tree for the first time.
func _ready():
	function_timer = FunctionTimerScript.new()
	function_timer.add_function_after(1, funcref(self, 'messenger_runs_in'))
	function_timer.add_function_after(3, funcref(self, 'city_commander_admires_city'))
	function_timer.add_function_after(2, funcref(self, 'messenger_speaks'))
	function_timer.add_function_after(6, funcref(self, 'commander_huh'))
		
	has_scene_started = true

func city_commander_admires_city(): 
	$CityCommander.say("Ah, the city is coming along great!", 5)

func commander_huh(): 
	$CityCommander.say("Huh? Did someone say something?", 5)

func messenger_runs_in(): 
	$Messenger.run_left_to(320)

func messenger_speaks(): 
	$Messenger.say("SIRE! WE WERE ATTACKED!", 4)

func _process(delta):
	if not has_scene_started or has_ended:
		return
		
	var could_perform_action = function_timer.tick_process(delta)
	has_ended = not could_perform_action
