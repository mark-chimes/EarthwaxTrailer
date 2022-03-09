extends "res://parallax/util/ParallaxObject.gd"
signal death
onready var rng = RandomNumberGenerator.new()

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

func _ready(): 
	rng.randomize()

func _process(delta):
	match state:
		State.WALK:
			real_pos.x += delta * 20
		State.IDLE:
			pass
		State.FIGHT:
			pass
		State.DIE:
			pass

func set_state(new_state, dir):
	if state == State.DIE:
		return
	state = new_state
	match state:
		State.WALK:
			$AnimatedSprite.play("walk")
		State.FIGHT:
			$AnimatedSprite.play("attack")
			$AnimatedSprite.flip_h = (dir == Dir.LEFT)
			var fight_time = rng.randf_range(3,5)
			print(fight_time)
			yield(get_tree().create_timer(fight_time), "timeout")
			set_state(State.DIE, dir)
		State.IDLE:
			$AnimatedSprite.play("idle")
		State.DIE:
			$AnimatedSprite.play("death")
			$AnimatedSprite.flip_h = (dir == Dir.LEFT)
			emit_signal("death")
			yield($AnimatedSprite, "animation_finished")
			$AnimatedSprite.frame = $AnimatedSprite.frames.get_frame_count("death")
			$AnimatedSprite.playing = false
	$AnimatedSprite.flip_h = (dir == Dir.LEFT)
