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
var fight_loc_x = -100

#func _ready(): 
#	rng.randomize()

func set_rng(new_rng): 
	rng = new_rng

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

func set_state(new_state, new_dir):
	if state == State.DIE:
		return
	state = new_state
	dir = new_dir
	match state:
		State.WALK:
			$AnimatedSprite.play("walk")
		State.FIGHT:
			$AnimatedSprite.connect("animation_finished", self, "play_sound_attack")
			$AnimatedSprite.play("attack")
			$AnimatedSprite.flip_h = (dir == Dir.LEFT)
			var fight_time = rng.randf_range(3,5)
			print(fight_time)
			yield(get_tree().create_timer(fight_time), "timeout")
			set_state(State.DIE, dir)
		State.IDLE:
			$AnimatedSprite.play("idle")
		State.DIE:
			$AnimatedSprite.play("die")
			$AnimatedSprite.flip_h = (dir == Dir.LEFT)
			emit_signal("death")
			play_sound_death()
			yield($AnimatedSprite, "animation_finished")
			$AnimatedSprite.frame = $AnimatedSprite.frames.get_frame_count("die")
			$AnimatedSprite.playing = false
	$AnimatedSprite.flip_h = (dir == Dir.LEFT)

func play_sound_death():
	var sounds = $SoundDie.get_children()
	sounds[randi() % sounds.size()].play()

func play_sound_attack():
	if state != State.FIGHT:
		return
	print("attack")
	var sounds = $SoundAttack.get_children()
	sounds[randi() % sounds.size()].play()
