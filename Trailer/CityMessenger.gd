extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var target_pos
var x_speed  = 100
var talk_timer = 0

enum State { 
	IDLE, RUN, TALK
}
var state = State.IDLE

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _process(delta):
	if state == State.RUN: 
		if position.x >= target_pos:
			position.x -= x_speed*delta
		else: 
			begin_idling()
	elif state == State.TALK: 
		if talk_timer > 0: 
			talk_timer -= delta
		if talk_timer <= 0: 
			begin_idling()
			
			
func say(message, time): 
	$Label.text = message
	talk_timer = time
	begin_talking()

func begin_talking(): 
	state = State.TALK
	$AnimatedSprite.play("talk")
	$AnimatedSprite2.play("talk")
	$Label.visible = true

func run_left_to(final_pos): 
	state = State.RUN
	target_pos = final_pos
	$AnimatedSprite.play("run")
	$AnimatedSprite2.play("run")

func begin_idling(): 
	state = State.IDLE
	$AnimatedSprite.play("idle")
	$AnimatedSprite2.play("idle")
	$Label.visible = false
