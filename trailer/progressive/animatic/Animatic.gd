extends Node2D


var FunctionTimerScript = load("res://trailer/utils/timing/FunctionTimer.gd")
var function_timer
var has_scene_started = false
var has_ended = false

var is_grass1_moving = false
var is_grass2_moving = false

var is_buildings_moving = false
var is_soldiers_moving = false


const knight_speed = 100
# Called when the node enters the scene tree for the first time.
func _ready():
	$AudioStreamPlayer.playing = true
	$spear_and_gremlin.visible = false
	$fade_logo.set_to_black()

	$Knight.visible = false
	$Building.visible = false
	$Army.visible = false
	$Battle.visible = false
	$DeadBattle.visible = false
		
	function_timer = FunctionTimerScript.new()
	function_timer.add_function_after(1.8, funcref(self, 'start_the_trailer'))
	function_timer.add_function_after(10, funcref($fade, 'start_fading'))
	function_timer.add_function_after(1, funcref(self, 'start_attacking'))
	function_timer.add_function_after(10, funcref($fade, 'start_fading'))
	function_timer.add_function_after(1, funcref(self, 'show_knight_trotting'))
	function_timer.add_function_after(9.5, funcref($fade, 'start_fading'))
	function_timer.add_function_after(1, funcref(self, 'show_buildings'))
	function_timer.add_function_after(9.5, funcref($fade, 'start_fading'))
	function_timer.add_function_after(1, funcref(self, 'show_army'))
	function_timer.add_function_after(9.5, funcref($fade, 'start_fading'))
	function_timer.add_function_after(1, funcref(self, 'show_battle'))
	function_timer.add_function_after(10, funcref($fade, 'start_fading'))
	function_timer.add_function_after(1, funcref(self, 'show_dead_battle'))
	function_timer.add_function_after(8, funcref($fade_logo, 'set_to_black'))
	has_scene_started = true


func start_the_trailer(): 
	$walking.visible = true
	is_grass1_moving = true
	$fade_logo.fade_from_black()

func start_attacking(): 
	is_grass1_moving = false
	$walking.visible = false
	$spear_and_gremlin.visible = true
	$spear_and_gremlin/Gremlin1.begin_attack()
	$spear_and_gremlin/Gremlin1.position.x = 798
	$spear_and_gremlin/Farmer.begin_farming()
	$spear_and_gremlin/Farmer.position.x = 738

func show_knight_trotting(): 
	$spear_and_gremlin.visible = false
	$Knight.visible = true
	$Knight/AnimatedSprite.play("trot")
	is_grass2_moving = true
	
func show_buildings(): 
	$Knight.visible = false
	$Building.visible = true
	$Building/Knight/AnimatedSprite.play("trot")
	$Building/Tent/AnimatedSprite.play("default")
	$Building/Tent/Builders/AnimatedSprite.play("default")
	$Building/Tent/Builders/AnimatedSprite2.play("default")
	is_buildings_moving = true

func show_army(): 
	$Building.visible = false
	$Army.visible = true
	$Army/Knight/AnimatedSprite.play("trot")
	is_soldiers_moving = true

func show_battle(): 
	$Army.visible = false
	$Battle.visible = true
	$Battle/Soldiers/Knight/AnimatedSprite.play("talk")
	
func show_dead_battle(): 
	$Battle.visible = false
	$DeadBattle.visible = true
	$DeadBattle/Knight/AnimatedSprite.play("idle")

func _process(delta):
	if not has_scene_started or has_ended:
		return
		
	var could_perform_action = function_timer.tick_process(delta)
	has_ended = not could_perform_action
	
	if is_grass1_moving: 
		$walking/grass_strip_test.position.x -= delta * knight_speed
		$walking/Boulder_transparent.position.x -= delta * knight_speed
		$walking/Gremlin_on_grass.position.x -= delta * knight_speed * 2
		
	if is_grass2_moving: 
		$Knight/grass_strip_test.position.x -= delta * knight_speed
