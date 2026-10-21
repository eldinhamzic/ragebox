@tool
extends Node2D

## Indoor Level 01 of Block 06: white brick floors over a black room.

@export_file("*.tscn") var next_level_path := ""

const LEVEL_WIDTH := 960.0
const LEVEL_HEIGHT := 540.0
const INDOOR_CEILING_HEIGHT := 108.0 # Default indoor ceiling: 20% from the top.
const START_TOP := 450.0
const FALLING := Rect2(120, 450, 120, 90)
const SAFE_GROUND := Rect2(240, 450, 180, 90)
const GROUND_SPIKES_X := 400.0
const SPIKE_FLYING := Rect2(512, 330, 96, 24)
const SAFE_FLYING := Rect2(700, 390, 84, 24)
const EXIT_GROUND := Rect2(840, 450, 120, 90)

const BRICK := Color("f5f5f5")
const BRICK_LIGHT := Color("ffffff")
const BRICK_SHADE := Color("c8c8c8")
const BRICK_DARK := Color("8f8f8f")
const INK := Color("05070d")

var falling_body: StaticBody2D
var falling_collision: CollisionShape2D
var falling_started := false
var ground_spikes_triggered := false
var flying_spikes_triggered := false
var deaths := 0
var started_at := 0
var completed := false

func _ready() -> void:
    if not Engine.is_editor_hint():
        _build_collisions()
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
    var player: RageboxPlayer = $Player
    if not falling_started and player.is_on_floor() and player.global_position.x >= FALLING.position.x and player.global_position.x <= FALLING.end.x and player.global_position.y >= FALLING.position.y - 24.0:
        _start_falling_platform()
    if not ground_spikes_triggered and player.global_position.x >= GROUND_SPIKES_X - 48.0 and player.global_position.x <= GROUND_SPIKES_X and player.is_on_floor():
        ground_spikes_triggered = true
        $GroundSpikes.activate_now()
    if not flying_spikes_triggered and player.global_position.x >= SPIKE_FLYING.position.x and player.global_position.x <= SPIKE_FLYING.end.x and not player.is_on_floor() and player.velocity.y > 0.0 and player.global_position.y >= SPIKE_FLYING.position.y - 64.0 and player.global_position.y < SPIKE_FLYING.position.y:
        flying_spikes_triggered = true
        $FlyingPlatformSpikes.activate_now()
    if falling_started:
        queue_redraw()
    if player.global_position.x >= LEVEL_WIDTH - 12.0:
        _on_exit_opened()

func _build_collisions() -> void:
    _add_static_rect(Rect2(0, 0, LEVEL_WIDTH, INDOOR_CEILING_HEIGHT), "IndoorCeiling")
    _add_static_rect(Rect2(0, START_TOP, 120, LEVEL_HEIGHT - START_TOP), "StartBrickFloor")
    _add_static_rect(SAFE_GROUND, "SafeBrickFloor")
    _add_static_rect(SPIKE_FLYING, "SpikeFlyingBrick")
    _add_static_rect(SAFE_FLYING, "SafeFlyingBrick")
    _add_static_rect(EXIT_GROUND, "ExitBrickFloor")

    falling_body = StaticBody2D.new()
    falling_body.name = "FallingIndoorBrickFloor"
    falling_body.position = FALLING.position + FALLING.size / 2.0
    falling_collision = CollisionShape2D.new()
    var shape := RectangleShape2D.new()
    shape.size = FALLING.size
    falling_collision.shape = shape
    falling_body.add_child(falling_collision)
    add_child(falling_body)

func _add_static_rect(rect: Rect2, node_name: String) -> void:
    var body := StaticBody2D.new()
    body.name = node_name
    body.position = rect.position + rect.size / 2.0
    var collision := CollisionShape2D.new()
    var shape := RectangleShape2D.new()
    shape.size = rect.size
    collision.shape = shape
    body.add_child(collision)
    add_child(body)

func _start_falling_platform() -> void:
    if falling_started:
        return
    falling_started = true
    await get_tree().create_timer(0.08).timeout
    if not is_inside_tree():
        return
    falling_collision.disabled = true
    var tween := create_tween()
    tween.tween_property(falling_body, "position:y", falling_body.position.y + 220.0, 0.42).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)

func _on_player_died() -> void:
    deaths += 1
    await get_tree().create_timer(0.8).timeout
    if is_inside_tree():
        GameState.restart_block()

func _on_exit_opened() -> void:
    if completed:
        return
    completed = true
    if next_level_path != "":
        get_tree().change_scene_to_file(next_level_path)
        return
    GameState.complete_block()

func _draw() -> void:
    draw_rect(Rect2(0, 0, LEVEL_WIDTH, LEVEL_HEIGHT), Color("05070d"))
    _draw_bricks(Rect2(0, 0, LEVEL_WIDTH, INDOOR_CEILING_HEIGHT))
    # Start, falling, and safe floor share one seamless brick skin until it drops.
    if not falling_started:
        _draw_bricks(Rect2(0, START_TOP, 420, LEVEL_HEIGHT - START_TOP))
    else:
        _draw_bricks(Rect2(0, START_TOP, 120, LEVEL_HEIGHT - START_TOP))
        _draw_bricks(SAFE_GROUND)
    _draw_bricks(SAFE_GROUND)
    _draw_bricks(SPIKE_FLYING)
    _draw_bricks(SAFE_FLYING)
    _draw_bricks(EXIT_GROUND)
    var falling_rect := FALLING
    if is_instance_valid(falling_body):
        falling_rect.position = falling_body.position - falling_rect.size / 2.0
    if falling_started:
        _draw_bricks(falling_rect)

func _draw_bricks(rect: Rect2) -> void:
    draw_rect(rect, BRICK)
    draw_line(Vector2(rect.position.x, rect.position.y + 14), Vector2(rect.end.x, rect.position.y + 14), BRICK_DARK, 2.0)
    draw_line(Vector2(rect.position.x, rect.position.y + 15), Vector2(rect.end.x, rect.position.y + 15), BRICK_LIGHT, 1.0)
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
