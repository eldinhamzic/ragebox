@tool
extends Node2D

## Block 02, Level 06: four offset indoor brick platforms and an exit lift.

@export_file("*.tscn") var next_level_path := ""
const LEVEL_WIDTH := 960.0
const LEVEL_HEIGHT := 540.0
const CEILING := Rect2(0, 0, LEVEL_WIDTH, 108)
const START_GROUND := Rect2(0, 450, 220, 90)
const PLATFORM_1 := Rect2(290, 390, 72, 24)
const PLATFORM_2 := Rect2(362, 320, 72, 24)
const PLATFORM_3 := Rect2(434, 250, 72, 24)
const PLATFORM_4 := Rect2(506, 180, 72, 24)
const DESCENT_PLATFORM_1 := Rect2(590, 250, 72, 24)
const DESCENT_PLATFORM_2 := Rect2(700, 350, 72, 24)
const EXIT_GROUND := Rect2(840, 450, 120, 90)
const BRICK := Color("f5f5f5")
const BRICK_SHADE := Color("b8b8b8")
const BRICK_DARK := Color("777777")
var completed := false
var first_platform_body: StaticBody2D
var first_platform_collision: CollisionShape2D
var hammer_triggered := false
var platform_broken := false
var lightning_visible := false
var descent_platforms_created := false

func _ready() -> void:
    if not Engine.is_editor_hint():
        _add_collision(CEILING, "IndoorCeiling")
        _add_collision(START_GROUND, "StartGround")
        first_platform_body = _add_collision(PLATFORM_1, "FirstPlatform")
        first_platform_collision = first_platform_body.get_child(0) as CollisionShape2D
        _add_collision(PLATFORM_4, "HighestPlatform")
        _add_collision(EXIT_GROUND, "ExitGround")
        $ExitButton.pressed.connect(_open_lift)
        $ExitLift.opened.connect(_on_exit_opened)
        $Player.died.connect(_on_player_died)
        var camera: Camera2D = $Player.get_node("Camera2D")
        camera.position = Vector2.ZERO
        camera.limit_right = LEVEL_WIDTH
        camera.limit_bottom = LEVEL_HEIGHT
    queue_redraw()

func _process(_delta: float) -> void:
    if Engine.is_editor_hint() or completed or hammer_triggered:
        return
    var player: RageboxPlayer = $Player
    if player.is_on_floor() and player.global_position.x >= PLATFORM_1.position.x and player.global_position.x <= PLATFORM_1.end.x:
        _strike_first_platform()

func _add_collision(rect: Rect2, node_name: String) -> StaticBody2D:
    var body := StaticBody2D.new()
    body.name = node_name
    body.position = rect.position + rect.size / 2.0
    var collision := CollisionShape2D.new()
    var shape := RectangleShape2D.new()
    shape.size = rect.size
    collision.shape = shape
    body.add_child(collision)
    add_child(body)
    return body

func _strike_first_platform() -> void:
    if hammer_triggered:
        return
    hammer_triggered = true
    lightning_visible = true
    queue_redraw()
    await get_tree().create_timer(0.8).timeout
    if not is_inside_tree():
        return
    lightning_visible = false
    $FlyingHammer.visible = true
    $FlyingHammer.strike_target(Vector2(PLATFORM_1.position.x + PLATFORM_1.size.x / 2.0, PLATFORM_1.position.y))
    await get_tree().create_timer(0.24).timeout
    if is_inside_tree() and is_instance_valid(first_platform_collision):
        first_platform_collision.disabled = true
        platform_broken = true
        queue_redraw()

func _open_lift() -> void:
    if not completed:
        _create_descent_platforms()
        $ExitLift.unlock()

func _create_descent_platforms() -> void:
    if descent_platforms_created:
        return
    descent_platforms_created = true
    _add_collision(DESCENT_PLATFORM_1, "DescentPlatform1")
    _add_collision(DESCENT_PLATFORM_2, "DescentPlatform2")
    queue_redraw()

func _on_exit_opened() -> void:
    if completed:
        return
    completed = true
    if next_level_path != "":
        get_tree().change_scene_to_file(next_level_path)
    else:
        GameState.complete_block()

func _on_player_died() -> void:
    await get_tree().create_timer(0.8).timeout
    if is_inside_tree():
        GameState.restart_block()

func _draw() -> void:
    draw_rect(Rect2(0, 0, LEVEL_WIDTH, LEVEL_HEIGHT), Color("05070d"))
    _draw_bricks(CEILING)
    _draw_bricks(START_GROUND)
    if not platform_broken:
        _draw_bricks(PLATFORM_1)
    _draw_bricks(PLATFORM_4)
    _draw_bricks(EXIT_GROUND)
    if descent_platforms_created:
        _draw_bricks(DESCENT_PLATFORM_1)
        _draw_bricks(DESCENT_PLATFORM_2)
    if lightning_visible:
        _draw_lightning()

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
            draw_line(Vector2(x, y - 14.0), Vector2(x, y), BRICK_SHADE, 2.0)
            x += 36.0
        y += 16.0
        row += 1

func _draw_lightning() -> void:
    var points := PackedVector2Array([
        Vector2(900, 18), Vector2(870, 62), Vector2(884, 62),
        Vector2(830, 118), Vector2(846, 118), Vector2(790, 180),
        Vector2(804, 180), Vector2(326, 390),
    ])
    draw_polyline(points, Color("ffffff", 0.9), 9.0, true)
    draw_polyline(points, Color("79d8ff"), 4.0, true)
    draw_circle(Vector2(326, 390), 18.0, Color("79d8ff", 0.22))
