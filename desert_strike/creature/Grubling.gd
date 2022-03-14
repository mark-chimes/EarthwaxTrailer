extends "res://parallax/util/ParallaxObject.gd"
signal death
#onready var rng = RandomNumberGenerator.new()
var rng

enum Dir {
	LEFT = -1,
	RIGHT = 1,
}

enum State {
	WALK,
	FIGHT,
	IDLE,
	DIE,
}

var state = State.IDLE
var dir = Dir.RIGHT
var is_in_combat = false

func set_rng(new_rng): 
	rng = new_rng

func _process(delta):
	match state:
		State.WALK:
			real_pos.x -= delta * 20
		State.IDLE:
			pass
		State.FIGHT:
			pass
		State.DIE:
			pass

func set_state(new_state, new_dir):
	if state == State.DIE:
		return
	state = new_state
	dir = new_dir
	match state:
		State.WALK:
			$AnimatedSprite.play("walk")
		State.FIGHT:
			$AnimatedSprite.play("attack")
			$AnimatedSprite.flip_h = (dir == Dir.RIGHT)
			var fight_time = rng.randf_range(1,3)
			yield(get_tree().create_timer(fight_time), "timeout")
			set_state(State.IDLE, dir)
		State.IDLE:
			$AnimatedSprite.play("idle")
		State.DIE:
			print("Grubling died")
			$AnimatedSprite.play("die")
			$AnimatedSprite.flip_h = (dir == Dir.RIGHT)
			emit_signal("death")
			yield($AnimatedSprite, "animation_finished")
			$AnimatedSprite.frame = $AnimatedSprite.frames.get_frame_count("die")
			$AnimatedSprite.playing = false
	$AnimatedSprite.flip_h = (dir == Dir.RIGHT)
