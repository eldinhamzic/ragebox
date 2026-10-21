@tool
extends Node2D

## Level 02 is a fixed-screen uphill run.
## The ground is a solid mass from the surface to the bottom of the scene.

@export_enum("Indoor Black", "Day", "Night") var background_style := "Day" : set = set_background_style
@export_file("*.tscn") var next_level_path := ""

const LEVEL_WIDTH := 960.0
const LEVEL_HEIGHT := 540.0
const START_X := 96.0
const TARGET_X := 672.0
const START_TOP := 450.0
const TARGET_TOP := 162.0 # The target is 30% down from the top of the scene.
const GRASS := Color("4cae68")
const GRASS_LIGHT := Color("8bd36d")
const DIRT := Color("9b5d3f")
const DIRT_DARK := Color("68402f")

var terrain_polygon := PackedVector2Array()
var surface_points := PackedVector2Array()
var deaths := 0
var started_at := 0
var completed := false

func _ready() -> void:
    _build_terrain()
    if not Engine.is_editor_hint():
        _build_collision()
        var camera: Camera2D = $Player.get_node("Camera2D")
        # Keep the camera locked to the same 960x540 frame as Level 01.
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

func set_background_style(value: String) -> void:
    background_style = value
    queue_redraw()

func _build_terrain() -> void:
    surface_points = PackedVector2Array([
        Vector2(0, START_TOP),
        Vector2(START_X, START_TOP),
        Vector2(TARGET_X, TARGET_TOP),
        Vector2(LEVEL_WIDTH, TARGET_TOP),
    ])
    terrain_polygon = PackedVector2Array([
        Vector2(0, LEVEL_HEIGHT), Vector2(LEVEL_WIDTH, LEVEL_HEIGHT),
        surface_points[3], surface_points[2], surface_points[1], surface_points[0],
    ])

func _build_collision() -> void:
    var body := StaticBody2D.new()
    body.name = "ContinuousGroundCollision"
    var collision := CollisionPolygon2D.new()
    collision.polygon = terrain_polygon
    body.add_child(collision)
    add_child(body)

func _on_player_died() -> void:
    deaths += 1
    GameState.restart_block()

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

func _draw() -> void:
    _draw_background()
    draw_colored_polygon(terrain_polygon, DIRT_DARK)
    _draw_terrain_fill()
    for index in range(surface_points.size() - 1):
        draw_line(surface_points[index], surface_points[index + 1], GRASS, 12.0)
        draw_line(surface_points[index], surface_points[index + 1], GRASS_LIGHT, 4.0)

func _draw_background() -> void:
    if background_style == "Night":
        draw_rect(Rect2(0, 0, LEVEL_WIDTH, LEVEL_HEIGHT), Color("0b1427"))
    elif background_style == "Indoor Black":
        draw_rect(Rect2(0, 0, LEVEL_WIDTH, LEVEL_HEIGHT), Color("05070d"))
    else:
        draw_rect(Rect2(0, 0, LEVEL_WIDTH, LEVEL_HEIGHT), Color("7bcbea"))
        draw_circle(Vector2(820, 86), 42, Color("fff0aa"))
        _draw_cloud(Vector2(150, 108), 1.0)
        _draw_cloud(Vector2(490, 78), 0.8)
        _draw_cloud(Vector2(760, 170), 1.15)

func _draw_cloud(origin: Vector2, cloud_scale := 1.0) -> void:
    var cloud := Color("ffffff", 0.86)
    draw_circle(origin + Vector2(-28, 4) * cloud_scale, 18 * cloud_scale, cloud)
    draw_circle(origin + Vector2(0, -7) * cloud_scale, 26 * cloud_scale, cloud)
    draw_circle(origin + Vector2(29, 4) * cloud_scale, 17 * cloud_scale, cloud)
    draw_rect(Rect2(origin + Vector2(-30, 4) * cloud_scale, Vector2(60, 18) * cloud_scale), cloud)

func _draw_terrain_fill() -> void:
    for x in range(12, int(LEVEL_WIDTH), 34):
        var top_y := _surface_y_at(float(x))
        draw_line(Vector2(x, top_y + 28), Vector2(x + 7, minf(top_y + 42, LEVEL_HEIGHT - 8)), DIRT, 3.0)
        draw_line(Vector2(x + 16, top_y + 72), Vector2(x + 23, minf(top_y + 86, LEVEL_HEIGHT - 8)), DIRT, 2.0)

func _surface_y_at(x: float) -> float:
    if x <= START_X:
        return START_TOP
    if x <= TARGET_X:
        return lerpf(START_TOP, TARGET_TOP, (x - START_X) / (TARGET_X - START_X))
    return TARGET_TOP
