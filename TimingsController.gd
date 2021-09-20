extends Node2D

var timer = 0

var switch = 1

signal shoot_first_arrow
signal shoot_arrows
signal people_enter
var has_scene_started = false

# Called when the node enters the scene tree for the first time.
func _ready():
	switch = 6
	
func start_scene(): 
	has_scene_started = true
	$Rabbits.start_scene()
	$Rat.start_scene()
	
func _process(delta):
	if not has_scene_started:
		return
	timer += delta
	if timer >= 6 and switch == 6:
		emit_signal("shoot_first_arrow")
		switch = 9
	if timer >= 9 and switch == 9:
		emit_signal("shoot_arrows")
		switch = 11
	if timer >= 11 and switch == 11:
		emit_signal("people_enter")
		switch += 1
