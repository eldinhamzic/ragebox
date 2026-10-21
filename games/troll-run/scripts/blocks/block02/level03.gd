@tool
extends Node2D

## Block 02, Level 03: a timed piano trap followed by a safe stairway choice.

@export_file("*.tscn") var next_level_path := ""

const LEVEL_WIDTH := 960.0
const LEVEL_HEIGHT := 540.0
const CEILING_HEIGHT := 108.0
const START_GROUND := Rect2(0, 450, 180, 90)
const END_GROUND := Rect2(840, 450, 120, 90)
const FLYING_PLATFORM := Rect2(260, 280, 180, 24)

const BRICK := Color("f5f5f5")
const BRICK_SHADE := Color("b8b8b8")
const BRICK_DARK := Color("777777")

var platform_body: StaticBody2D
var platform_collision: CollisionShape2D
const EXIT_PLATFORM_1 := Rect2(620, 360, 110, 24)
const EXIT_PLATFORM_2 := Rect2(760, 420, 120, 24)
var exit_platform_bodies: Array[StaticBody2D] = []
var exit_spikes: RageboxTripleSpikes
var platform_started := false
var piano_started := false
var stairs_created := false
var trap_timer_active := false
var trap_time_left := 0.0
var deaths := 0
var started_at := 0
var completed := false

func _ready() -> void:
    if not Engine.is_editor_hint():
        _build_collisions()
        _set_button_active($TrapButton, false)
        _set_button_active($SafeButton, false)
        $Piano.visible = false
        $ExitStairs.visible = false
        $ExitStairs.visible = false
        $StartButton.pressed.connect(_on_start_button_pressed)
        $TrapButton.pressed.connect(_on_trap_button_pressed)
        $SafeButton.pressed.connect(_on_safe_button_pressed)
        var camera: Camera2D = $Player.get_node("Camera2D")
        camera.position = Vector2.ZERO
        camera.limit_right = LEVEL_WIDTH
        camera.limit_bottom = LEVEL_HEIGHT
        $Player.died.connect(_on_player_died)
        started_at = Time.get_ticks_msec()
    queue_redraw()

func _process(_delta: float) -> void:
    if Engine.is_editor_hint() or completed:
        return
    if $Player.global_position.x >= LEVEL_WIDTH - 12.0:
        _complete_level()
    if trap_timer_active and not piano_started and not stairs_created:
        trap_time_left = maxf(trap_time_left - _delta, 0.0)
        if trap_time_left <= 0.0:
            trap_timer_active = false
            _set_button_active($TrapButton, false)
            _drop_trap_button()
            _drop_safe_button()
        queue_redraw()
    if platform_started:
        queue_redraw()

func _build_collisions() -> void:
    _add_collision(Rect2(0, 0, LEVEL_WIDTH, CEILING_HEIGHT), "IndoorCeiling")
    _add_collision(START_GROUND, "StartGround")
    _add_collision(END_GROUND, "EndGround")
    platform_body = StaticBody2D.new()
    platform_body.name = "RisingStablePlatform"
    platform_body.position = Vector2(410, 600)
    platform_collision = CollisionShape2D.new()
    var shape := RectangleShape2D.new()
    shape.size = FLYING_PLATFORM.size
    platform_collision.shape = shape
    platform_collision.disabled = true
    platform_body.add_child(platform_collision)
    add_child(platform_body)

func _add_collision(rect: Rect2, node_name: String) -> void:
    var body := StaticBody2D.new()
    body.name = node_name
    body.position = rect.position + rect.size / 2.0
    var collision := CollisionShape2D.new()
    var shape := RectangleShape2D.new()
    shape.size = rect.size
    collision.shape = shape
    body.add_child(collision)
    add_child(body)

func _on_start_button_pressed() -> void:
    if platform_started:
        return
    platform_started = true
    var tween := create_tween()
    tween.tween_property(platform_body, "position:y", FLYING_PLATFORM.position.y + FLYING_PLATFORM.size.y / 2.0, 0.45).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
    tween.tween_callback(func() -> void:
        platform_collision.disabled = false
    )
    await get_tree().create_timer(1.0).timeout
    if is_inside_tree() and not piano_started and not stairs_created:
        _set_button_active($TrapButton, true)
        trap_timer_active = true
        trap_time_left = 5.0

func _on_trap_button_pressed() -> void:
    if piano_started or stairs_created:
        return
    piano_started = true
    trap_timer_active = false
    _set_button_active($TrapButton, false)
    var player: RageboxPlayer = $Player
    $Piano.global_position.x = player.global_position.x
    $Piano.visible = true
    var tween := create_tween()
    tween.tween_property($Piano, "global_position:y", player.global_position.y - 62.0, 0.12)
    tween.tween_callback(func() -> void:
        if is_instance_valid(player):
            player.die()
    )

func _on_safe_button_pressed() -> void:
    if piano_started or stairs_created:
        return
    stairs_created = true
    trap_timer_active = false
    _set_button_active($SafeButton, false)
    $ExitStairs.visible = false
    $ExitStairs.active = false
    _create_exit_platforms()
    for body in exit_platform_bodies:
        body.process_mode = Node.PROCESS_MODE_INHERIT
    exit_spikes.visible = true
    exit_spikes.activate_now()

func _set_button_active(button: RageboxRedButton, active: bool) -> void:
    button.visible = active
    if button.trigger != null:
        button.trigger.monitoring = active

func _drop_trap_button() -> void:
    if not is_instance_valid($TrapButton) or not $TrapButton.visible:
        return
    var tween := create_tween()
    tween.set_parallel(true)
    tween.tween_property($TrapButton, "position:y", $TrapButton.position.y + 260.0, 0.35).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
    tween.tween_property($TrapButton, "rotation", 0.75, 0.35)
    tween.set_parallel(false)
    tween.tween_callback(func() -> void:
        $TrapButton.visible = false
    )

func _drop_safe_button() -> void:
    if not is_instance_valid($SafeButton):
        return
    $SafeButton.position = Vector2(350, 72)
    $SafeButton.rotation = -0.5
    $SafeButton.visible = true
    if $SafeButton.trigger != null:
        $SafeButton.trigger.monitoring = false
    var tween := create_tween()
    tween.set_parallel(true)
    tween.tween_property($SafeButton, "position", Vector2(350, FLYING_PLATFORM.position.y), 0.45).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
    tween.tween_property($SafeButton, "rotation", 0.0, 0.45)
    tween.set_parallel(false)
    tween.tween_callback(func() -> void:
        _set_button_active($SafeButton, true)
    )

func _on_player_died() -> void:
    deaths += 1
    await get_tree().create_timer(0.8).timeout
    if is_inside_tree():
        GameState.restart_block()

func _complete_level() -> void:
    if completed:
        return
    completed = true
    if next_level_path != "":
        get_tree().change_scene_to_file(next_level_path)
        return
    GameState.complete_block()

func _draw() -> void:
    draw_rect(Rect2(0, 0, LEVEL_WIDTH, LEVEL_HEIGHT), Color("05070d"))
    _draw_bricks(Rect2(0, 0, LEVEL_WIDTH, CEILING_HEIGHT))
    _draw_bricks(START_GROUND)
    _draw_bricks(END_GROUND)
    if platform_started and is_instance_valid(platform_body):
        var platform_rect := FLYING_PLATFORM
        platform_rect.position = platform_body.position - platform_rect.size / 2.0
        _draw_bricks(platform_rect)
    if stairs_created:
        _draw_exit_platforms()
    if trap_timer_active:
        _draw_trap_timer()

func _draw_trap_timer() -> void:
    var center := Vector2(480, 68)
    var radius := 42.0
    var progress := clampf(trap_time_left / 5.0, 0.0, 1.0)
    draw_circle(center, radius + 4.0, Color("171b29"))
    draw_circle(center, radius, Color("4a1f2a"))
    draw_arc(center, radius - 4.0, -PI / 2.0, -PI / 2.0 + TAU * progress, 48, Color("e23d4d"), 6.0, true)
    draw_circle(center, 3.0, Color("ffffff"))
    draw_line(center, center + Vector2(0, -22), Color("ffffff"), 2.0)
    var angle := -PI / 2.0 + TAU * progress
    draw_line(center, center + Vector2(cos(angle), sin(angle)) * 26.0, Color("ffffff"), 2.0)

func _draw_bricks(rect: Rect2) -> void:
    draw_rect(rect, BRICK)
    draw_line(Vector2(rect.position.x, rect.position.y + 14), Vector2(rect.end.x, rect.position.y + 14), BRICK_DARK, 2.0)
    var row := 0
    var y := rect.position.y + 30.0
    while y < rect.end.y - 3.0:
        draw_line(Vector2(rect.position.x, y), Vector2(rect.end.x, y), BRICK_SHADE, 2.0)
        var offset := 0.0 if row % 2 == 0 else 18.0
        var x := rect.position.x + offset
        while x < rect.end.x:
            draw_line(Vector2(x, y - 14), Vector2(x, y), BRICK_SHADE, 2.0)
            x += 36.0
        y += 16.0
        row += 1

func _create_exit_platforms() -> void:
    if not exit_platform_bodies.is_empty():
        return
    for data in [EXIT_PLATFORM_1, EXIT_PLATFORM_2]:
        var body := StaticBody2D.new()
        body.position = data.position + data.size / 2.0
        var collision := CollisionShape2D.new()
        var shape := RectangleShape2D.new()
        shape.size = data.size
        collision.shape = shape
        body.add_child(collision)
        body.process_mode = Node.PROCESS_MODE_DISABLED
        add_child(body)
        exit_platform_bodies.append(body)
    exit_spikes = preload("res://scenes/props/TripleSpikes.tscn").instantiate()
    exit_spikes.name = "ExitPlatformSpikes"
    exit_spikes.position = Vector2(EXIT_PLATFORM_2.position.x + 30.0, EXIT_PLATFORM_2.position.y)
    exit_spikes.hidden_until_trigger = true
    exit_spikes.visible = false
    add_child(exit_spikes)

func _draw_exit_platforms() -> void:
    _draw_bricks(EXIT_PLATFORM_1)
    _draw_bricks(EXIT_PLATFORM_2)
