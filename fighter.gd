extends CharacterBody2D


const SPEED := 150.0
const ANIMATION_SPEED := SPEED / 75.0
const JUMP_VELOCITY := -300.0
const GRAVITY := 600.0
const CLIMB_SPEED := 75.0
const CLIMB_ANIMATION_SPEED := CLIMB_SPEED / 53.0
const SPRITE_SHIFT := 3

enum STATES {AIR, GROUND, CLIMB, CLIMB_TO_GROUND, GROUND_TO_CLIMB}

@onready var sprite: Sprite2D = $Sprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var timer: Timer = $Timer

var state = STATES.AIR
#var state_machine
var legs_on_ladder: bool = false
var head_on_ladder: bool = false
var sprite_moved: bool = false


func _ready():
#	state_machine = $AnimationTree.get("parameters/playback")
	pass


func _physics_process(delta):
#	$Label.text = STATES.keys()[state]
#	$Label.text = state_machine.get_current_node()
	$Label.text = animation_player.current_animation + " (" + str(sprite.frame) + ")"

	if Input.is_action_just_pressed("esc"):
		get_tree().quit()

	match state:
		STATES.AIR:
			velocity.y += GRAVITY * delta
			if sprite_moved:
				sprite.position.y += SPRITE_SHIFT
				sprite_moved = false
			
			if is_on_floor():
				state = STATES.GROUND
			else:
				pass
			move_and_slide()

		STATES.GROUND:
			velocity.y += GRAVITY * delta
			if sprite_moved:
				sprite.position.y += SPRITE_SHIFT
				sprite_moved = false
			
			if is_on_floor():
				if Input.is_action_pressed("ui_up") and head_on_ladder:
					state = STATES.CLIMB
					velocity.y = -CLIMB_SPEED
					velocity.x = 0
					animation_player.play("Climb", -1, CLIMB_ANIMATION_SPEED)
				elif Input.is_action_just_pressed("ui_accept"):
					velocity.y = JUMP_VELOCITY
					state = STATES.AIR
					animation_player.play("Jump", -1, 1.5)
				elif Input.is_action_just_pressed("ui_down") and legs_on_ladder and not head_on_ladder:
					velocity.y = CLIMB_SPEED
					velocity.x = 0
					state = STATES.GROUND_TO_CLIMB
					animation_player.play("Climb", -1, -CLIMB_ANIMATION_SPEED)
					collision_shape.disabled = true
					timer.start()
				else:
					var direction = Input.get_axis("ui_left", "ui_right")
					if direction:
						velocity.x = direction * SPEED
						if direction > 0:
							sprite.flip_h = false
						else:
							sprite.flip_h = true
						if Input.is_action_pressed("shift"):
							velocity.x *= SPRITE_SHIFT
							animation_player.play("Run", -1, ANIMATION_SPEED)
						else:
							animation_player.play("Walk", -1, ANIMATION_SPEED)
					else:
						velocity.x = move_toward(velocity.x, 0, SPEED/10)
						if velocity.x == 0:
							animation_player.play("Idle")
							pass
				move_and_slide()
			else:
				state = STATES.AIR
				fall_animation()

		STATES.CLIMB:
			if is_on_floor():
				state = STATES.GROUND
			elif legs_on_ladder:# and body_on_ladder:
				if Input.is_action_pressed("ui_up"):
					if sprite_moved:
						sprite.position.y += SPRITE_SHIFT
						sprite_moved = false
					velocity.y = -CLIMB_SPEED
					if head_on_ladder:
						animation_player.play("Climb", -1, CLIMB_ANIMATION_SPEED)
					else:
						animation_player.play("ClimbToGround", -1, CLIMB_ANIMATION_SPEED)
					move_and_slide()
				elif Input.is_action_pressed("ui_down"):
					if not sprite_moved:
						sprite.position.y -= SPRITE_SHIFT
						sprite_moved = true
					velocity.y = CLIMB_SPEED
					if head_on_ladder:
						animation_player.play("Climb", -1, -CLIMB_ANIMATION_SPEED)
					else:
						animation_player.play("ClimbToGround", -1, -CLIMB_ANIMATION_SPEED)
					move_and_slide()
				elif Input.is_action_just_pressed("ui_accept"):
					state = STATES.AIR
					fall_animation()
				else:
					velocity.y = 0
					animation_player.pause()
			else:
				if Input.is_action_pressed("ui_up"):
					velocity.y = GRAVITY * delta
					state = STATES.CLIMB_TO_GROUND
					move_and_slide()
#				else:
#					state = STATES.AIR
#					fall_animation()
		
		STATES.CLIMB_TO_GROUND:
			if is_on_floor():
				state = STATES.GROUND
			move_and_slide()

		STATES.GROUND_TO_CLIMB:
			sprite.position.y -= SPRITE_SHIFT #надо двигать спрайт!!!
			sprite_moved = true
			state = STATES.CLIMB


func fall_animation():
	animation_player.play("Jump")
	animation_player.seek(.7, true)


func _on_timer_timeout() -> void:
	collision_shape.disabled = false


func _on_legs_on_ladder_area_entered(_area: Area2D) -> void:
	legs_on_ladder = true


func _on_legs_on_ladder_area_exited(_area: Area2D) -> void:
	legs_on_ladder = false


func _on_head_on_ladder_area_entered(_area: Area2D) -> void:
	head_on_ladder = true


func _on_head_on_ladder_area_exited(_area: Area2D) -> void:
	head_on_ladder = false
