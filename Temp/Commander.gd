extends Node2D

const speed = 80

var talk_timer = 0

var is_left = false

enum State { 
	IDLE, WALK, TALK
}

var state = State.IDLE

func _ready(): 
	$AnimatedSprite.play("walk")

func _process(delta):
	if state == State.WALK:
		walk_process(delta)
	elif state == State.TALK: 
		if talk_timer > 0: 
			talk_timer -= delta
		if talk_timer <= 0: 
			begin_idling()

func walk_process(delta): 
	if is_left: 
		position.x -= speed * delta
	else: 
		if position.x < 256:
			position.x += speed * delta
		else: 
			begin_talking()

func begin_walking(): 
	# $AnimatedSprite.play("walk")
	$AnimatedSprite.play("walk")
	$Label.visible = false
	state = State.WALK

func go_right(): 
	is_left = false
	$AnimatedSprite.flip_h = false
	
func go_left(): 
	is_left = true
	$AnimatedSprite.flip_h = true
	
func begin_talking(): 
	state = State.TALK
	$AnimatedSprite.play("talk")
	$Label.visible = true
	$Label.text = "This will be \n an excellent place \n to start a farm!"
	talk_timer = 4

func begin_idling(): 
	state = State.IDLE
	$AnimatedSprite.play("idle")
	$Label.visible = false
	
