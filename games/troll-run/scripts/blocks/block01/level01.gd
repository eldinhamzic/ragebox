@tool
extends Node2D

@export_enum("Indoor Black", "Day", "Night") var background_style := "Indoor Black" : set = set_background_style
@export_file("*.tscn") var next_level_path := "res://scenes/blocks/block01/Level02.tscn"

const LEVEL_WIDTH := 960.0
const LEVEL_HEIGHT := 540.0
const INK := Color("241c35")
const INTERIOR_END := LEVEL_WIDTH
const WALL := Color("b9c7cf")
const WALL_LIGHT := Color("edf3f4")
const WALL_ACCENT := Color("8fa7b1")
const BRICK := Color("f7faf8")
const BRICK_SHADE := Color("d3dfe0")
const GRASS := Color("4cae68")
const GRASS_LIGHT := Color("8bd36d")
const DIRT := Color("9b5d3f")
const DIRT_DARK := Color("68402f")
const TILE_SIZE := 24
const STARS := [
    Vector2(48, 72), Vector2(112, 118), Vector2(184, 58), Vector2(264, 96),
    Vector2(344, 42), Vector2(438, 82), Vector2(526, 54), Vector2(604, 126),
    Vector2(694, 68), Vector2(782, 112), Vector2(864, 48), Vector2(924, 142),
]

# Level 01 is intentionally a calm onboarding run: one flat floor from spawn
# to the exit, with no gaps, slopes, platforms, or hazards.
var platforms := [
    Rect2(0, 450, LEVEL_WIDTH, 90),
]
var deaths := 0
var started_at := 0
var completed := false

func set_background_style(value: String) -> void:
    background_style = value
    queue_redraw()

func _ready() -> void:
    if not Engine.is_editor_hint():
        _build_collisions()
        var camera: Camera2D = $Player.get_node("Camera2D")
        camera.limit_right = LEVEL_WIDTH
        camera.limit_bottom = LEVEL_HEIGHT
        $Player.died.connect(_on_player_died)
        if has_node("ExitDoor"):
            $ExitDoor.opened.connect(_on_exit_door_opened)
        started_at = Time.get_ticks_msec()
    queue_redraw()

func _process(_delta: float) -> void:
    if Engine.is_editor_hint() or completed or has_node("ExitDoor"):
        return
    if $Player.global_position.x >= LEVEL_WIDTH - 12.0:
        _complete_level()

func _on_player_died() -> void:
    deaths += 1
    GameState.restart_block()

func _on_exit_door_opened() -> void:
    _complete_level()

func _complete_level() -> void:
    if completed:
        return
    completed = true
    if next_level_path != "":
        get_tree().change_scene_to_file(next_level_path)
        return
    _send_result({"time": (Time.get_ticks_msec() - started_at) / 1000.0, "deaths": deaths})

func _send_result(payload: Dictionary) -> void:
    if OS.has_feature("web"):
        JavaScriptBridge.eval("window.parent.postMessage({type:'ragebox-result',result:" + JSON.stringify(payload) + "}, '*');")

func _build_collisions() -> void:
    for platform in platforms:
        var body := StaticBody2D.new()
        body.position = platform.position + platform.size / 2.0
        var shape_node := CollisionShape2D.new()
        var shape := RectangleShape2D.new()
        shape.size = platform.size
        shape_node.shape = shape
        body.add_child(shape_node)
        add_child(body)

func _draw() -> void:
    _draw_background()

    for platform in platforms:
        _draw_platform(platform)

func _draw_background() -> void:
    if background_style == "Indoor Black":
        draw_rect(Rect2(0, 0, LEVEL_WIDTH, LEVEL_HEIGHT), Color("05070d"))
    elif background_style == "Night":
        draw_rect(Rect2(0, 0, LEVEL_WIDTH, LEVEL_HEIGHT), Color("050811"))
        draw_rect(Rect2(0, 0, LEVEL_WIDTH, 300), Color("0b1427"))
        for star in STARS:
            draw_circle(star, 3, Color("fff3b0"))
            draw_circle(star, 1, Color("ffffff"))
        draw_circle(Vector2(820, 96), 34, Color("f6f0cf"))
        draw_circle(Vector2(834, 86), 34, Color("0b1427"))
    else:
        draw_rect(Rect2(0, 0, LEVEL_WIDTH, LEVEL_HEIGHT), Color("7bcbea"))
        draw_circle(Vector2(820, 86), 42, Color("fff0aa"))
        _draw_cloud(Vector2(150, 108), 1.0)
        _draw_cloud(Vector2(490, 78), 0.8)
        _draw_cloud(Vector2(760, 170), 1.15)

func _draw_cloud(origin: Vector2, scale := 1.0) -> void:
    var cloud := Color("ffffff", 0.86)
    draw_circle(origin + Vector2(-28, 4) * scale, 18 * scale, cloud)
    draw_circle(origin + Vector2(0, -7) * scale, 26 * scale, cloud)
    draw_circle(origin + Vector2(29, 4) * scale, 17 * scale, cloud)
    draw_rect(Rect2(origin + Vector2(-30, 4) * scale, Vector2(60, 18) * scale), cloud)

func _draw_platform(platform: Rect2) -> void:
    if platform.position.y > 400:
        _draw_ground(platform)
    elif platform.position.x >= INTERIOR_END:
        _draw_grass_ledge(platform)
    else:
        _draw_white_bricks(platform)

func _draw_white_bricks(platform: Rect2) -> void:
    draw_rect(platform, INK)
    draw_rect(Rect2(platform.position + Vector2(5, 5), platform.size - Vector2(10, 10)), BRICK)
    draw_rect(Rect2(platform.position, Vector2(platform.size.x, 7)), Color("ffffff"))
    var rows: int = maxi(1, int((platform.size.y - 10) / 14))
    for row in range(rows):
        var y := platform.position.y + 10 + row * 14
        draw_line(Vector2(platform.position.x + 5, y), Vector2(platform.end.x - 5, y), BRICK_SHADE, 2)
        var offset := 0.0 if row % 2 == 0 else 14.0
        var x := platform.position.x + 5 - offset
        while x < platform.end.x:
            draw_line(Vector2(x, y), Vector2(x, min(y + 14, platform.end.y - 5)), BRICK_SHADE, 2)
            x += 28.0

func _draw_ground(platform: Rect2) -> void:
    draw_rect(platform, DIRT_DARK)
    draw_rect(Rect2(platform.position.x, platform.position.y + 10, platform.size.x, platform.size.y - 10), DIRT)
    draw_rect(Rect2(platform.position.x, platform.position.y, platform.size.x, 12), GRASS)
    draw_rect(Rect2(platform.position.x, platform.position.y, platform.size.x, 4), GRASS_LIGHT)
    for x in range(int(platform.position.x) + 10, int(platform.end.x), 34):
        draw_line(Vector2(x, platform.position.y + 18), Vector2(x + 6, platform.position.y + 28), DIRT_DARK, 3)
        draw_line(Vector2(x + 18, platform.position.y + 40), Vector2(x + 25, platform.position.y + 50), DIRT_DARK, 2)

func _draw_grass_ledge(platform: Rect2) -> void:
    draw_rect(platform, DIRT_DARK)
    draw_rect(Rect2(platform.position + Vector2(4, 5), platform.size - Vector2(8, 5)), DIRT)
    draw_rect(Rect2(platform.position, Vector2(platform.size.x, 9)), GRASS)
    draw_rect(Rect2(platform.position, Vector2(platform.size.x, 3)), GRASS_LIGHT)
    for x in range(int(platform.position.x) + 12, int(platform.end.x), 28):
        draw_line(Vector2(x, platform.position.y + 12), Vector2(x + 5, platform.position.y + 18), DIRT_DARK, 2)
