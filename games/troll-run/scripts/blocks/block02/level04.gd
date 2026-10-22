@tool
extends Node2D

## Block 02, Level 04: optional piano trap, then a spring-assisted stone wall.

@export_file("*.tscn") var next_level_path := ""
const LEVEL_WIDTH := 960.0
const LEVEL_HEIGHT := 540.0
const CEILING := Rect2(0, 0, LEVEL_WIDTH, 108)
const GROUND := Rect2(0, 450, LEVEL_WIDTH, 90)
const WALL_PLATFORM := Rect2(650, 300, 170, 24)
const BRICK := Color("f5f5f5")
const BRICK_SHADE := Color("b8b8b8")
const BRICK_DARK := Color("777777")
var completed := false

func _ready() -> void:
    if not Engine.is_editor_hint():
        _add_collision(CEILING, "IndoorCeiling")
        _add_collision(GROUND, "StableIndoorGround")
        $Wall.wall_size = Vector2(72, 150)
        $Wall.indoor_style = true
        $Wall.position = Vector2(700, 324)
        $WallPlatform.position = WALL_PLATFORM.position + WALL_PLATFORM.size / 2.0
        $Player.died.connect(_on_player_died)
        $Piano.visible = false
        $FirstButton.pressed.connect(_drop_piano)
        $SecondButton.pressed.connect(_activate_spring)
        $Spring.active = false
        var camera: Camera2D = $Player.get_node("Camera2D")
        camera.position = Vector2.ZERO
        camera.limit_right = LEVEL_WIDTH
        camera.limit_bottom = LEVEL_HEIGHT
    queue_redraw()

func _process(_delta: float) -> void:
    if Engine.is_editor_hint() or completed:
        return
    if $Player.global_position.x >= LEVEL_WIDTH - 12.0:
        completed = true
        get_tree().change_scene_to_file(next_level_path)

func _drop_piano() -> void:
    var player: RageboxPlayer = $Player
    $Piano.global_position.x = player.global_position.x
    $Piano.visible = true
    var tween := create_tween()
    tween.tween_property($Piano, "global_position:y", player.global_position.y - 62.0, 0.12)
    tween.tween_callback(func() -> void: player.die())

func _activate_spring() -> void:
    $Spring.activate()

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
    _draw_bricks(GROUND)
    _draw_bricks(WALL_PLATFORM)

func _draw_bricks(rect: Rect2) -> void:
    draw_rect(rect, BRICK)
    draw_line(Vector2(rect.position.x, rect.position.y + 14), Vector2(rect.end.x, rect.position.y + 14), BRICK_DARK, 2.0)
    var y := rect.position.y + 30.0
    while y < rect.end.y - 3.0:
        draw_line(Vector2(rect.position.x, y), Vector2(rect.end.x, y), BRICK_SHADE, 2.0)
        y += 16.0

