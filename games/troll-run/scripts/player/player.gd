@tool
class_name RageboxPlayer
extends CharacterBody2D

signal died

## Tuned so the unobstructed start-to-exit run takes roughly five seconds.
@export var max_speed := 190.0
@export var acceleration := 980.0
@export var air_acceleration := 680.0
## Deliberately loose braking: about 0.5s of slide from full speed to rest.
@export var braking := 380.0
@export var gravity := 1500.0
@export var jump_velocity := -510.0
@export var crouch_speed_multiplier := 0.55

const COYOTE_TIME := 0.11
const JUMP_BUFFER_TIME := 0.14
const SHORT_HOP_MULTIPLIER := 0.45

var dead := false
var falling_into_hole := false
var facing := 1.0
var animation_state := "idle"
var coyote_timer := 0.0
var jump_buffer_timer := 0.0
var run_phase := 0.0
var death_parts: Array[Dictionary] = []
var death_alpha := 1.0
var jumps_left := 2
var spawn_position := Vector2.ZERO
var crouching := false
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

func _ready() -> void:
    spawn_position = global_position
    floor_max_angle = deg_to_rad(80.0)
    queue_redraw()

func _physics_process(delta: float) -> void:
    if Engine.is_editor_hint():
        return
    if falling_into_hole:
        return
    if dead:
        _update_death_parts(delta)
        queue_redraw()
        return
    var direction := Input.get_axis("move_left", "move_right")
    var wants_crouch := Input.is_action_pressed("crouch") and is_on_floor()
    _set_crouching(wants_crouch)
    var slope_difficulty := _get_slope_difficulty()
    var downhill_direction := _get_downhill_direction()
    var uphill_factor := 1.0 - slope_difficulty if downhill_direction != 0.0 and direction * downhill_direction < 0.0 else 1.0
    coyote_timer = COYOTE_TIME if is_on_floor() else maxf(coyote_timer - delta, 0.0)
    jump_buffer_timer = JUMP_BUFFER_TIME if Input.is_action_just_pressed("jump") else maxf(jump_buffer_timer - delta, 0.0)

    if absf(direction) > 0.01:
        facing = sign(direction)
        var slope_speed_factor := 1.0
        if downhill_direction != 0.0:
            # The same slope ratio slows uphill movement and speeds downhill movement.
            slope_speed_factor = 1.0 + slope_difficulty if direction == downhill_direction else 1.0 - slope_difficulty
        var target_speed := direction * max_speed * slope_speed_factor * (crouch_speed_multiplier if crouching else 1.0)
        var rate := acceleration if is_on_floor() else air_acceleration
        velocity.x = move_toward(velocity.x, target_speed, rate * uphill_factor * delta)
    else:
        var downhill_speed := downhill_direction * max_speed * slope_difficulty
        var stop_target := downhill_speed if downhill_direction != 0.0 else 0.0
        var stop_rate := acceleration * 0.65 if downhill_direction != 0.0 else braking
        velocity.x = move_toward(velocity.x, stop_target, (stop_rate if is_on_floor() else air_acceleration * 0.45) * delta)

    if not is_on_floor():
        velocity.y += gravity * delta
    else:
        jumps_left = 2
    if jump_buffer_timer > 0.0 and coyote_timer > 0.0:
        velocity.y = jump_velocity * uphill_factor
        jump_buffer_timer = 0.0
        coyote_timer = 0.0
        jumps_left = 1
    elif Input.is_action_just_pressed("jump") and jumps_left > 0:
        # Second jump is intentionally 20% stronger for a clear mid-air correction.
        velocity.y = jump_velocity * uphill_factor * 1.2
        jumps_left = 0
    if Input.is_action_just_released("jump") and velocity.y < -120.0:
        velocity.y *= SHORT_HOP_MULTIPLIER

    move_and_slide()
    if global_position.y > 620.0:
        die()
    _update_animation(delta, direction)
    queue_redraw()

func _get_slope_difficulty() -> float:
    if not is_on_floor():
        return 0.0
    var normal := get_floor_normal()
    var slope_angle := acos(clampf(normal.dot(Vector2.UP), -1.0, 1.0))
    return clampf(rad_to_deg(slope_angle) / 90.0, 0.0, 0.8)

func _get_downhill_direction() -> float:
    if not is_on_floor():
        return 0.0
    var normal := get_floor_normal()
    # In Godot, Vector2.UP points to negative Y. A top normal pointing right
    # means the surface falls towards the right; a top normal pointing left
    # means it falls towards the left.
    if normal.x < -0.05:
        return -1.0
    if normal.x > 0.05:
        return 1.0
    return 0.0

func _update_animation(delta: float, direction: float) -> void:
    if not is_on_floor():
        animation_state = "jump" if velocity.y < 0.0 else "fall"
    elif absf(velocity.x) > 25.0:
        animation_state = "run"
    elif crouching:
        animation_state = "crouch"
    else:
        animation_state = "idle"
    if animation_state == "run":
        run_phase += delta * (12.0 + absf(velocity.x) * 0.035)
    elif absf(direction) < 0.01:
        run_phase = 0.0

func _set_crouching(value: bool) -> void:
    if crouching == value:
        return
    crouching = value
    var capsule := collision_shape.shape as CapsuleShape2D
    if capsule == null:
        return
    capsule.height = 24.0 if crouching else 42.0
    collision_shape.position.y = -12.0 if crouching else -21.0

func die() -> void:
    if dead or falling_into_hole:
        return
    dead = true
    animation_state = "death"
    velocity = Vector2.ZERO
    death_alpha = 1.0
    _create_death_parts()
    queue_redraw()
    died.emit()
    await get_tree().create_timer(0.78).timeout
    global_position = spawn_position
    velocity = Vector2.ZERO
    dead = false
    animation_state = "idle"
    death_parts.clear()
    death_alpha = 1.0
    queue_redraw()

func fall_into_hole() -> void:
    if dead or falling_into_hole:
        return
    falling_into_hole = true
    velocity = Vector2.ZERO
    visible = false
    died.emit()
    await get_tree().create_timer(0.18).timeout
    global_position = spawn_position
    velocity = Vector2.ZERO
    visible = true
    falling_into_hole = false

func bounce(strength: float) -> void:
    if dead or falling_into_hole:
        return
    velocity.y = strength
    jumps_left = 1

func _create_death_parts() -> void:
    death_parts = [
        {"kind": "head", "position": Vector2(0, -42), "velocity": Vector2(randf_range(-105.0, 105.0), -190.0), "rotation": 0.0, "spin": randf_range(-8.0, 8.0)},
        {"kind": "body", "position": Vector2(0, -17), "velocity": Vector2(randf_range(-75.0, 75.0), -145.0), "rotation": 0.0, "spin": randf_range(-5.0, 5.0)},
        {"kind": "arm", "position": Vector2(-15, -18), "velocity": Vector2(randf_range(-180.0, -70.0), -165.0), "rotation": 0.0, "spin": randf_range(-10.0, 10.0)},
        {"kind": "arm", "position": Vector2(15, -18), "velocity": Vector2(randf_range(70.0, 180.0), -170.0), "rotation": 0.0, "spin": randf_range(-10.0, 10.0)},
        {"kind": "leg", "position": Vector2(-6, 3), "velocity": Vector2(randf_range(-120.0, -30.0), -95.0), "rotation": 0.0, "spin": randf_range(-8.0, 8.0)},
        {"kind": "leg", "position": Vector2(6, 3), "velocity": Vector2(randf_range(30.0, 120.0), -105.0), "rotation": 0.0, "spin": randf_range(-8.0, 8.0)},
    ]
    # Small square fragments make every visible death read as a pixel disintegration,
    # regardless of which trap called die().
    for index in range(18):
        var angle := TAU * float(index) / 18.0 + randf_range(-0.18, 0.18)
        var speed := randf_range(90.0, 250.0)
        death_parts.append({
            "kind": "shard",
            "position": Vector2(randf_range(-9.0, 9.0), randf_range(-40.0, 8.0)),
            "velocity": Vector2(cos(angle) * speed, sin(angle) * speed - 90.0),
            "rotation": randf_range(-0.5, 0.5),
            "spin": randf_range(-12.0, 12.0),
            "size": randf_range(2.0, 5.0),
            "color": [Color("e65b45"), Color("356b9e"), Color("f0bd91"), Color("24283a")][index % 4],
        })

func _update_death_parts(delta: float) -> void:
    death_alpha = maxf(death_alpha - delta * 1.15, 0.0)
    for index in range(death_parts.size()):
        var part := death_parts[index]
        var part_velocity: Vector2 = part["velocity"]
        part_velocity.y += 620.0 * delta
        part["position"] = part["position"] + part_velocity * delta
        part["velocity"] = part_velocity
        part["rotation"] = float(part["rotation"]) + float(part["spin"]) * delta
        death_parts[index] = part

func _draw_death_parts() -> void:
    for part in death_parts:
        var kind: String = part["kind"]
        draw_set_transform(part["position"], float(part["rotation"]), Vector2.ONE)
        if kind == "head":
            draw_rect(Rect2(-10, -10, 20, 17), _death_color("24283a"))
            draw_rect(Rect2(-7, -7, 14, 11), _death_color("f0bd91"))
            draw_rect(Rect2(-9, -12, 18, 5), _death_color("c9413c"))
        elif kind == "body":
            draw_rect(Rect2(-11, -13, 22, 24), _death_color("24283a"))
            draw_rect(Rect2(-8, -10, 16, 17), _death_color("356b9e"))
            draw_rect(Rect2(-6, -8, 10, 6), _death_color("6eb1c2"))
        elif kind == "arm":
            draw_rect(Rect2(-5, -11, 10, 22), _death_color("24283a"))
            draw_rect(Rect2(-3, -8, 6, 14), _death_color("c9413c"))
        elif kind == "leg":
            draw_rect(Rect2(-5, -9, 10, 18), _death_color("24283a"))
            draw_rect(Rect2(-7, 5, 14, 5), _death_color("1b2233"))
        else:
            var shard_size: float = part["size"]
            var shard_color: Color = part["color"]
            shard_color.a = death_alpha
            draw_rect(Rect2(-shard_size * 0.5, -shard_size * 0.5, shard_size, shard_size), shard_color)
    draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func _death_color(hex_value: String) -> Color:
    var color := Color(hex_value)
    color.a = death_alpha
    return color

func _draw() -> void:
    var bob := sin(run_phase) * 2.0 if animation_state == "run" else 0.0
    var side := facing
    var ink := Color("24283a")
    var skin := Color("f0bd91")
    var cap := Color("c9413c")
    var denim := Color("356b9e")
    var boot := Color("1b2233")

    if animation_state == "death":
        _draw_death_parts()
        return

    var step := sin(run_phase) * 5.0 if animation_state == "run" else 0.0
    var arm_y := -29.0 if animation_state == "jump" else -14.0
    if crouching:
        draw_set_transform(Vector2(0, 3), 0.0, Vector2(1.0, 0.68))
    # Original small side-profile platform hero: cap, overalls, moustache and boots.
    draw_rect(Rect2(-12 * side, -22 + bob, 6 * side, 15), ink)
    draw_rect(Rect2(-10 * side, -21 + bob, 4 * side, 11), cap)
    draw_rect(Rect2(-10 * side, -25 + bob, 20 * side, 19), ink)
    draw_rect(Rect2(-7 * side, -23 + bob, 15 * side, 14), denim)
    draw_rect(Rect2(-4 * side, -21 + bob, 10 * side, 7), Color("6eb1c2"))
    draw_rect(Rect2(-6 * side, -10 + bob, 14 * side, 5), Color("dfb04f"))
    # Head, nose and brim face the direction of travel.
    draw_rect(Rect2(-8 * side, -39 + bob, 17 * side, 15), ink)
    draw_rect(Rect2(-6 * side, -36 + bob, 13 * side, 11), skin)
    draw_rect(Rect2(5 * side, -33 + bob, 5 * side, 5), skin)
    draw_rect(Rect2(7 * side, -32 + bob, 2 * side, 2), Color("d98c73"))
    draw_rect(Rect2(-10 * side, -42 + bob, 18 * side, 6), cap)
    draw_rect(Rect2(2 * side, -38 + bob, 10 * side, 3), Color("a92f38"))
    draw_rect(Rect2(-6 * side, -44 + bob, 13 * side, 4), Color("e65b45"))
    draw_rect(Rect2(6 * side, -32 + bob, 2 * side, 2), ink)
    draw_rect(Rect2(3 * side, -27 + bob, 7 * side, 3), ink)
    draw_rect(Rect2(6 * side, -25 + bob, 4 * side, 2), ink)
    # Two chunky legs and boots.
    draw_rect(Rect2((-5 + step) * side, -5 + bob, 7 * side, 11), ink)
    draw_rect(Rect2((3 - step) * side, -5 + bob, 7 * side, 11), ink)
    draw_rect(Rect2((-8 + step) * side, 5 + bob, 11 * side, 5), boot)
    draw_rect(Rect2((1 - step) * side, 5 + bob, 12 * side, 5), boot)
    draw_rect(Rect2(7 * side, arm_y, 6 * side, 12), ink)
    draw_rect(Rect2(9 * side, arm_y + 2, 5 * side, 8), cap)
    draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
