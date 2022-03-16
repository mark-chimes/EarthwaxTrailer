extends "res://parallax/util/ParallaxObject.gd"

var HealthBar = preload("res://desert_strike/HealthBar.tscn")

signal death
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
var sprite_dir = Dir.RIGHT
var dir = Dir.RIGHT
var is_in_combat = false
var mute = true

var health = 10
onready var health_bar = HealthBar.instance()
var MAX_HEALTH = 10
var show_health = true

func _ready(): 
	init_health_bar()

func init_health_bar(): 
	add_child(health_bar)
	health_bar.init_health_bar(MAX_HEALTH)
	if not show_health: 
		health_bar.visible = false

func update_health_bar(new_health): 
	health_bar.update_health(new_health)

func set_rng(new_rng): 
	rng = new_rng
	rng.randomize()

func _process(delta):
	match state:
		State.WALK:
			health -= delta
			update_health_bar(health)
			real_pos.x += delta * 5 * dir
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
			$AnimatedSprite.flip_h = (dir != sprite_dir)
			var fight_time = rng.randf_range(1,3)
			yield(get_tree().create_timer(fight_time), "timeout")
			set_state(State.DIE, dir)
		State.IDLE:
			$AnimatedSprite.play("idle")
		State.DIE:
			$AnimatedSprite.play("die")
			$AnimatedSprite.flip_h = (dir != sprite_dir)
			emit_signal("death")
			play_sound_death()
			yield($AnimatedSprite, "animation_finished")
			$AnimatedSprite.frame = $AnimatedSprite.frames.get_frame_count("die")
			$AnimatedSprite.playing = false
	$AnimatedSprite.flip_h = (dir != sprite_dir)


func play_sound_death():
	if mute: 
		return
	var sounds = $SoundDie.get_children()
	sounds[rng.randi() % sounds.size()].play()

func play_sound_attack():
	if mute: 
		return
	if state != State.FIGHT:
		return
	var sounds = $SoundAttack.get_children()
	sounds[rng.randi() % sounds.size()].play()
