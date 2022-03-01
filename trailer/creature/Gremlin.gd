extends Node2D

var speed = 0
var full_speed = 50

export var pos_offset = 0
export var speed_offset = 0

const movement_back = 350
var end_x = 0
var is_readying_chase = false

func _ready(): 
	end_x = position.x
	#var pos_offset = rand_range(0, 200) #TODO HARDCODE
	#var speed_offset = rand_range(0, 20) # TODO HARDCODE
	position.x += movement_back + pos_offset
	full_speed = full_speed + speed_offset
	speed = full_speed
	#print("pos_offset: " + str(pos_offset)) 
	#print("speed_offset: " + str(speed_offset)) 
	
enum State { 
	IDLE, WALK, ATTACK, CHASE, DIE, DEAD
}

var state = State.IDLE

func _process(delta):
	if state == State.WALK:
		walk_process(delta)
	elif state == State.CHASE:
		chase_process(delta)
	elif state == State.ATTACK:
		attack_process(delta)
		
func walk_process(delta): 
	if position.x > end_x:
		position.x -= speed * delta
	else: 
		begin_attack()

func chase_process(delta): 
	if speed < full_speed: 
		speed += full_speed*delta
	position.x -= speed * delta

func attack_process(delta): 
	pass

func begin_walk(): 
	state = State.WALK
	$AnimatedSprite.play("walk")

func ready_chase(): 
	is_readying_chase = true

func begin_chase(): 
	speed = 0
	state = State.CHASE
	$AnimatedSprite.play("walk")

func begin_attack(): 
	state = State.ATTACK
	$AnimatedSprite.play("attack")
	
func begin_dying(): 
	state = State.DIE
	$AnimatedSprite.play("die")

func dead(): 
	state = State.DEAD
	$AnimatedSprite.play("dead")

func _on_AnimatedSprite_animation_finished():
	if is_readying_chase and state == State.ATTACK: 
		begin_chase()
		is_readying_chase = false
	if state == State.DIE: 
		dead()
