extends Node2D
var FunctionTimerScript = load("res://trailer/utils/timing/FunctionTimer.gd")

signal shoot_first_arrow
signal shoot_arrows
signal people_enter

var has_scene_started = false

var function_timer
var has_ended

# Called when the node enters the scene tree for the first time.
func _ready():
	function_timer = FunctionTimerScript.new()
	function_timer.add_function_after(0, funcref(self, 'initial_rabbits'))
	function_timer.add_function_after(1, funcref($Rabbit3, 'start_idling')) #1
	function_timer.add_function_after(1, funcref($Rabbit1, 'start_hopping')) #2
	function_timer.add_function_after(1, funcref($Rabbit2, 'start_hopping')) #3
	function_timer.add_function_after(1, funcref($Rabbit2, 'start_grazing')) #4
	function_timer.add_function_after(1, funcref($Rabbit1, 'start_idling')) #5
	function_timer.add_function_after(1, funcref($Rabbit3, 'start_hopping')) #6
	function_timer.add_function_after(1, funcref(self, 'alert_all_rabbits')) #7
	function_timer.add_function_after(2, funcref(self, 'sprint_all_rabbits')) #9
	function_timer.add_function_after(0.7, funcref($Rabbit1, 'start_dying')) #9.7
	function_timer.add_function_after(0.1, funcref($Rabbit2, 'start_dying')) #9.8
	function_timer.add_function_after(0, funcref($Rabbit3, 'start_dying')) #9.8
	function_timer.add_function_after(0.1, funcref($Rabbit4, 'start_dying')) #9.9
	
func start_scene(): 
	has_scene_started = true

func initial_rabbits(): 
	$Rabbit1.start_idling()
	$Rabbit2.start_hopping()
	$Rabbit3.start_sprinting()
	$Rabbit3.start_grazing()

func alert_all_rabbits(): 
	$Rabbit1.start_alert()	
	$Rabbit2.start_alert()	
	$Rabbit3.start_alert()	
	$Rabbit4.start_alert()	

func sprint_all_rabbits(): 
	$Rabbit1.start_sprinting()	
	$Rabbit2.start_sprinting()	
	$Rabbit3.start_sprinting()	
	$Rabbit4.start_sprinting()	


func _process(delta):
	if has_scene_started == false: 
		return
	
	if not has_ended:
		var could_perform_action = function_timer.tick_process(delta)
		has_ended = not could_perform_action
