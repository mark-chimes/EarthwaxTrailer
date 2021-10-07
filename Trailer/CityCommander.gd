extends Node2D

const speed = 80

var talk_timer = 0

var is_left = false

enum State { 
	IDLE, WALK, TALK
}

var state = State.IDLE

func _ready(): 
	go_left()
	$AnimatedSprite.play("idle")
	$AnimatedSprite2.play("idle")
	
func _process(delta):
	if state == State.WALK:
		walk_process(delta)
	elif state == State.TALK: 
		if talk_timer > 0: 
			talk_timer -= delta
		if talk_timer <= 0: 
			begin_idling()

func walk_process(delta): 
	pass


func begin_walking(): 
	# $AnimatedSprite.play("walk")
	$AnimatedSprite.play("walk")
	$AnimatedSprite2.play("walk")
	$Label.visible = false
	state = State.WALK

func go_right(): 
	is_left = false
	
	$AnimatedSprite.scale.x = -1
	$AnimatedSprite2.scale.x = -1
#	$AnimatedSprite.flip_h = false
#	$AnimatedSprite2.flip_h = false
		
func go_left(): 
	is_left = true
	$AnimatedSprite.scale.x = 1
	$AnimatedSprite2.scale.x = 1
#	$AnimatedSprite.flip_h = true
#	$AnimatedSprite2.flip_h = true
	
func say(message, time): 
	$Label.text = message
	talk_timer = time
	begin_talking()

func begin_talking(): 
	state = State.TALK
	$AnimatedSprite.play("talk")
	$AnimatedSprite2.play("talk")
	$Label.visible = true

func begin_idling(): 
	state = State.IDLE
	$AnimatedSprite.play("idle")
	$AnimatedSprite2.play("idle")
	$Label.visible = false
	
