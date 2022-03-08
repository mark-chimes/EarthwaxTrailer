extends "res://parallax/util/ParallaxObject.gd"

enum Dir {
	LEFT = -1,
	RIGHT = 1,
}

enum State {
	WALK,
	FIGHT,
	IDLE,
}

var state = State.IDLE

func _process(delta):
	print(state)
	match state:
		State.WALK:
			real_pos.x -= delta * 20
		State.IDLE:
			pass
		State.FIGHT:
			pass

func set_state(new_state, dir):
	state = new_state
	match state:
		State.WALK:
			$AnimatedSprite.play("walk")
		State.FIGHT:
			$AnimatedSprite.play("attack")
		State.IDLE:
			$AnimatedSprite.play("idle")
	$AnimatedSprite.flip_h = (dir == Dir.RIGHT)
