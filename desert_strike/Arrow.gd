extends "res://parallax/util/ParallaxObject.gd"
signal disappear(this)
signal attack(this)

var horizontal_speed
var vertical_speed
var vertical_acc 
var rot_dist
var is_flying
var end_x
var start_x

var ranged_target_band
var ranged_target_lane
var ranged_damage

const DISAPPEAR_TIME = 3

func _ready(): 
	is_projectile = true

func _process(delta):
	if not is_flying: 
		return
		
	if real_pos.x >= end_x: 
		is_flying = false
		emit_signal("attack", self)
		disappear_after_timeout()
		return
		
	real_pos.x += delta*horizontal_speed
	real_pos.y += delta*vertical_speed
	vertical_speed += vertical_acc * delta
	var next_frame = floor((real_pos.x - start_x) / rot_dist)
	get_node("AnimatedSprite").frame = next_frame

func disappear_after_timeout(): 
	#$AnimatedSprite.modulate = Color8(1,0,0,1)
	yield(get_tree().create_timer(DISAPPEAR_TIME), "timeout")
	emit_signal("disappear", self)

