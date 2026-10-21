@tool
extends Node2D

## Block 02, Level 05: double-jump platform, contact spikes, then two timed platforms.

@export_file("*.tscn") var next_level_path := ""
const LEVEL_WIDTH := 960.0
const LEVEL_HEIGHT := 540.0
const CEILING := Rect2(0, 0, LEVEL_WIDTH, 108)
const START_GROUND := Rect2(0, 450, 360, 90)
const RAISED_PLATFORM := Rect2(480, 300, 160, 24)
const EXIT_GROUND := Rect2(850, 450, 110, 90)
const BRICK := Color("f5f5f5")
const BRICK_SHADE := Color("b8b8b8")
const BRICK_DARK := Color("777777")
var spikes_triggered := false
var completed := false

func _ready() -> void:
    if not Engine.is_editor_hint():
        _add_collision(CEILING, "IndoorCeiling")
        _add_collision(START_GROUND, "StartGround")
        _add_collision(RAISED_PLATFORM, "RaisedPlatform")
        _add_collision(EXIT_GROUND, "ExitGround")
        $Player.died.connect(_on_player_died)
        var camera: Camera2D = $Player.get_node("Camera2D")
        camera.position = Vector2.ZERO
        camera.limit_right = LEVEL_WIDTH
        camera.limit_bottom = LEVEL_HEIGHT
    queue_redraw()

func _process(_delta: float) -> void:
    if Engine.is_editor_hint() or completed:
        return
    var player: RageboxPlayer = $Player
    if not spikes_triggered and player.global_position.x >= 560.0 and player.global_position.x <= 640.0 and not player.is_on_floor() and player.velocity.y > 0.0 and player.global_position.y >= 236.0 and player.global_position.y < 300.0:
        spikes_triggered = true
        $PlatformSpikes.activate_now()
    if player.global_position.x >= LEVEL_WIDTH - 12.0:
        completed = true
        get_tree().change_scene_to_file(next_level_path)

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

func _on_player_died() -> void:
    await get_tree().create_timer(0.8).timeout
    if is_inside_tree():
        GameState.restart_block()

func _draw() -> void:
    draw_rect(Rect2(0, 0, LEVEL_WIDTH, LEVEL_HEIGHT), Color("05070d"))
    _draw_bricks(CEILING)
    _draw_bricks(START_GROUND)
    _draw_bricks(RAISED_PLATFORM)
    _draw_bricks(EXIT_GROUND)

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
