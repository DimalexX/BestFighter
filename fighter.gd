extends CharacterBody2D


const SPEED = 150.0
const JUMP_VELOCITY = -300.0
const GRAVITY = 600
const CLIMB_SPEED = 64

enum STATES {AIR, GROUND, CLIMB}

@onready var sprite: Sprite2D = $Sprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var state = STATES.AIR
#var state_machine

func _ready():
#	state_machine = $AnimationTree.get("parameters/playback")
	pass


func _physics_process(delta):
#	$Label.text = STATES.keys()[state]
#	$Label.text = state_machine.get_current_node()
	$Label.text = animation_player.current_animation
	

	match state:
		STATES.AIR:
			velocity.y += GRAVITY * delta
			if is_on_floor():
				state = STATES.GROUND
			else:
				pass
			move_and_slide()

		STATES.GROUND:
			velocity.y += GRAVITY * delta

			if Input.is_action_pressed("climb"):
				state = STATES.CLIMB
				velocity.y = -CLIMB_SPEED
				animation_player.play("Climb")
			
			elif Input.is_action_just_pressed("ui_accept") and is_on_floor():
				velocity.y = JUMP_VELOCITY
				state = STATES.AIR
				animation_player.play("Jump")
			else:
				var direction = Input.get_axis("ui_left", "ui_right")
				if direction:
					velocity.x = direction * SPEED
					if direction > 0:
						sprite.flip_h = false
					else:
						sprite.flip_h = true
					if Input.is_action_pressed("shift"):
						velocity.x *= 3
						animation_player.play("Run", -1, SPEED/75)
					else:
						animation_player.play("Walk", -1, SPEED/75)
				else:
					velocity.x = move_toward(velocity.x, 0, SPEED/10)
					if velocity.x == 0:
						animation_player.play("Idle")
						pass
			move_and_slide()
		
		STATES.CLIMB:
			if Input.is_action_pressed("climb"):
				move_and_slide()
			else:
				state = STATES.AIR
				fall_animation()
				

func fall_animation():
	animation_player.play("Jump")
	animation_player.seek(.7, true)


