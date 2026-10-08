extends CharacterBody2D
## Physics only. Feet are the origin; the presentation never modifies this body.
const Visual = preload("res://scripts/player_visual.gd")
const MAX_SPEED = 140.0
const GROUND_ACCEL = 1500.0
const GROUND_BRAKE = 2300.0
const GROUND_FRICTION = 520.0
const AIR_ACCEL = 950.0
const AIR_BRAKE = 1300.0
const JUMP_SPEED = 720.0
const GRAVITY = 1750.0 # Phaser world 900 + player boost 850.
const RETRY_DELAY = 0.560
# Phaser's 30x42 sprite has an 18x50 centered body: bottom = sprite.y + 25.
const SPAWN = Vector2(100, 425)
signal died
var visual: Node2D
var dead = false
var retry_left = 0.0
var jump_was_down = false
var facing = 1.0

func _ready() -> void:
	collision_layer = 2
	collision_mask = 1
	floor_snap_length = 0.0
	safe_margin = 0.001
	var shape = RectangleShape2D.new()
	shape.size = Vector2(18, 50)
	var collider = CollisionShape2D.new()
	collider.shape = shape
	collider.position.y = -25
	add_child(collider)
	visual = Visual.new()
	add_child(visual)
	position = SPAWN

static func horizontal_speed(current: float, direction: float, grounded: bool, dt: float) -> float:
	if direction == 0:
		return move_toward(current, 0.0, GROUND_FRICTION * dt) if grounded else current
	var reversing = absf(current) > 1 and signf(current) != direction
	var acceleration = (GROUND_BRAKE if reversing else GROUND_ACCEL) if grounded else (AIR_BRAKE if reversing else AIR_ACCEL)
	return clampf(move_toward(current, direction * MAX_SPEED, acceleration * dt), -MAX_SPEED, MAX_SPEED)

func _physics_process(delta: float) -> void:
	if dead:
		retry_left -= delta
		visual.advance(delta, Vector2.ZERO, false, facing)
		if retry_left <= 0:
			reset_player()
		return
	var grounded = is_on_floor()
	var left = Input.is_action_pressed("move_left")
	var right = Input.is_action_pressed("move_right")
	var direction = 0.0 if left == right else (-1.0 if left else 1.0)
	velocity.x = horizontal_speed(velocity.x, direction, grounded, delta)
	if direction != 0:
		facing = direction
	var jump_down = Input.is_action_pressed("jump")
	if jump_down and not jump_was_down and grounded:
		velocity.y = -JUMP_SPEED
	jump_was_down = jump_down
	velocity.y += GRAVITY * delta
	move_and_slide()
	visual.advance(delta, velocity, is_on_floor(), facing)
	# Original death check: sprite center > 540+18, feet = center+25.
	if position.y > 583:
		kill()

func kill() -> void:
	if dead:
		return
	dead = true
	velocity = Vector2.ZERO
	retry_left = RETRY_DELAY
	visual.play_death()
	died.emit()

func reset_player() -> void:
	position = SPAWN
	velocity = Vector2.ZERO
	dead = false
	jump_was_down = false
	visual.reset_visual()
	# Refresh CharacterBody's cached floor contacts after teleport.
	move_and_slide()
