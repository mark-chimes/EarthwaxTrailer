extends Node2D

# onready var arrow = get_node("Arrow")
onready var start = get_node("Arrow")

onready var Arrow =  preload("res://experiment/arrow/Arrow2.tscn")

export var travel_time = 2.0
export var time_between_attacks = 2.0
export var time_between_waves = 2.0
const frames = 7

var arrow

func _ready():
	for i in range(0, 100):
		arrow_to_target($End)
		yield(get_tree().create_timer(time_between_attacks), "timeout")
		arrow_to_target($End2)
		yield(get_tree().create_timer(time_between_attacks), "timeout")
		arrow_to_target($End3)
		yield(get_tree().create_timer(time_between_waves), "timeout")

func arrow_to_target(target): 
	arrow = Arrow.instance()
	var start_x = start.position.x
	var end_x = target.position.x
	var total_dist = end_x - start_x
	arrow.position.x = start_x 
	arrow.position.y = start.position.y
	print("travel_time before: " + str(travel_time))
	print("total_dist: " + str(total_dist))
	var new_travel_time = travel_time * total_dist / 720.0
	print("travel_time after: " + str(new_travel_time))
	
	arrow.horizontal_speed = total_dist / new_travel_time
	arrow.end_x = end_x
	arrow.vertical_speed = -arrow.horizontal_speed
	arrow.vertical_acc = -2*arrow.vertical_speed / (new_travel_time)
	arrow.rot_dist = total_dist / (frames + 1)
	arrow.is_flying = true
	
	add_child(arrow)
	fire_arrow_anim()
	
func fire_arrow_anim(): 
	$Archer/AnimatedSprite.play("attack")
	$Archer/AnimatedSprite.frame = 0
		
func _on_AnimatedSprite_animation_finished():
	if $Archer/AnimatedSprite.animation == "attack":
		$Archer/AnimatedSprite.play("idle")
