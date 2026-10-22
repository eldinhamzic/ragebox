@tool
extends Node2D

## Level 03 is a fixed-screen downhill run.
## The ground is a solid mass from the surface to the bottom of the scene.

@export_enum("Indoor Black", "Day", "Night") var background_style := "Day" : set = set_background_style
@export_file("*.tscn") var next_level_path := ""

const LEVEL_WIDTH := 960.0
const LEVEL_HEIGHT := 540.0
const START_X := 96.0
const TARGET_X := 672.0
const DROP_END_X := 816.0 # First half of the remaining flat section.
const START_TOP := 162.0 # 30% down from the top of the 540px scene.
const TARGET_TOP := 450.0
const GRASS := Color("4cae68")
const GRASS_LIGHT := Color("8bd36d")
const DIRT := Color("9b5d3f")
const DIRT_DARK := Color("68402f")

var terrain_polygons: Array[PackedVector2Array] = []
var surface_points := PackedVector2Array()
var drop_platform: StaticBody2D
var drop_collision: CollisionShape2D
var drop_started := false
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
    if drop_started:
        queue_redraw()
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
    # Leave a real hole below the collapsing half; the solid ground is split
    # into the left slope mass and the stable final half of the finish.
    terrain_polygons = [
        PackedVector2Array([
            Vector2(0, LEVEL_HEIGHT), Vector2(TARGET_X, LEVEL_HEIGHT),
            surface_points[2], surface_points[1], surface_points[0],
        ]),
        PackedVector2Array([
            Vector2(DROP_END_X, LEVEL_HEIGHT), Vector2(LEVEL_WIDTH, LEVEL_HEIGHT),
            surface_points[3], Vector2(DROP_END_X, TARGET_TOP),
        ]),
    ]

func _build_collision() -> void:
    for index in range(terrain_polygons.size()):
        var body := StaticBody2D.new()
        body.name = "GroundCollision_%d" % index
        var collision := CollisionPolygon2D.new()
        collision.polygon = terrain_polygons[index]
        body.add_child(collision)
        add_child(body)

    drop_platform = StaticBody2D.new()
    drop_platform.name = "FallingGroundSection"
    drop_platform.set_meta("description", "Falling ground section")
    drop_platform.position = Vector2((TARGET_X + DROP_END_X) / 2.0, TARGET_TOP + (LEVEL_HEIGHT - TARGET_TOP) / 2.0)
    drop_collision = CollisionShape2D.new()
    var drop_shape := RectangleShape2D.new()
    drop_shape.size = Vector2(DROP_END_X - TARGET_X, LEVEL_HEIGHT - TARGET_TOP)
    drop_collision.shape = drop_shape
    drop_platform.add_child(drop_collision)
    add_child(drop_platform)

    var trigger := Area2D.new()
    trigger.name = "CollapsingFinishTrigger"
    trigger.position = Vector2((TARGET_X + DROP_END_X) / 2.0, TARGET_TOP)
    var trigger_shape := CollisionShape2D.new()
    var trigger_rect := RectangleShape2D.new()
    trigger_rect.size = Vector2(DROP_END_X - TARGET_X, 16.0)
    trigger_shape.shape = trigger_rect
    trigger.add_child(trigger_shape)
    trigger.body_entered.connect(_on_drop_trigger_body_entered)
    add_child(trigger)

func _on_drop_trigger_body_entered(body: Node2D) -> void:
    if drop_started or not body.has_method("die"):
        return
    if body.global_position.y > TARGET_TOP + 14.0:
        return
    drop_started = true
    await get_tree().create_timer(0.5).timeout
    if not is_inside_tree():
        return
    drop_collision.disabled = true
    var tween := create_tween()
    tween.tween_property(drop_platform, "position:y", drop_platform.position.y + 170.0, 0.42).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)

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
    _send_result({"time": (Time.get_ticks_msec() - started_at) / 1000.0, "deaths": deaths})

func _send_result(payload: Dictionary) -> void:
    if OS.has_feature("web"):
        JavaScriptBridge.eval("window.parent.postMessage({type:'ragebox-result',result:" + JSON.stringify(payload) + "}, '*');")

func _draw() -> void:
    _draw_background()
    for polygon in terrain_polygons:
        draw_colored_polygon(polygon, DIRT_DARK)
    var drop_center := Vector2((TARGET_X + DROP_END_X) / 2.0, TARGET_TOP + (LEVEL_HEIGHT - TARGET_TOP) / 2.0)
    if is_instance_valid(drop_platform):
        drop_center = drop_platform.position
    var drop_size := Vector2(DROP_END_X - TARGET_X, LEVEL_HEIGHT - TARGET_TOP)
    var drop_rect := Rect2(drop_center - drop_size / 2.0, drop_size)
    draw_rect(drop_rect, DIRT_DARK)
    _draw_terrain_fill()
    for index in range(surface_points.size() - 1):
        if drop_started and index == 2:
            draw_line(Vector2(DROP_END_X, TARGET_TOP), surface_points[3], GRASS, 12.0)
            draw_line(Vector2(DROP_END_X, TARGET_TOP), surface_points[3], GRASS_LIGHT, 4.0)
            continue
        draw_line(surface_points[index], surface_points[index + 1], GRASS, 12.0)
        draw_line(surface_points[index], surface_points[index + 1], GRASS_LIGHT, 4.0)
    if drop_started and is_instance_valid(drop_platform):
        var dropped_top := drop_platform.position.y - drop_size.y / 2.0
        draw_line(Vector2(TARGET_X, dropped_top), Vector2(DROP_END_X, dropped_top), GRASS, 12.0)
        draw_line(Vector2(TARGET_X, dropped_top), Vector2(DROP_END_X, dropped_top), GRASS_LIGHT, 4.0)

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
        if x >= TARGET_X and x < DROP_END_X and is_instance_valid(drop_platform):
            top_y += drop_platform.position.y - (TARGET_TOP + (LEVEL_HEIGHT - TARGET_TOP) / 2.0)
        draw_line(Vector2(x, top_y + 28), Vector2(x + 7, minf(top_y + 42, LEVEL_HEIGHT - 8)), DIRT, 3.0)
        draw_line(Vector2(x + 16, top_y + 72), Vector2(x + 23, minf(top_y + 86, LEVEL_HEIGHT - 8)), DIRT, 2.0)

func _surface_y_at(x: float) -> float:
    if x <= START_X:
        return START_TOP
    if x <= TARGET_X:
        return lerpf(START_TOP, TARGET_TOP, (x - START_X) / (TARGET_X - START_X))
    return TARGET_TOP
