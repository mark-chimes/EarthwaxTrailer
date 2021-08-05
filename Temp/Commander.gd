extends Node2D

const speed = 80

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
		pass

func walk_process(delta): 
	if position.x < 256:
		position.x += speed * delta
	else: 
		begin_talking()

func begin_walking(): 
	# $AnimatedSprite.play("walk")
	$AnimatedSprite.play("walk")
	state = State.WALK
		
func begin_talking(): 
	state = State.TALK
	$AnimatedSprite.speed_scale = 1
	$AnimatedSprite.frame = 0
	$AnimatedSprite.play("talk")
	$Label.visible = true
	$Label.text = "This will be \n an excellent place \n to setup a farm!"
