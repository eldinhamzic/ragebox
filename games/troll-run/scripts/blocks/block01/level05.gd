@tool
extends Node2D

## Level 05 is a continuous run across small earth islands and collapsing stone bridges.

@export_enum("Indoor Black", "Day", "Night") var background_style := "Day" : set = set_background_style
@export_file("*.tscn") var next_level_path := ""

const LEVEL_WIDTH := 960.0
const LEVEL_HEIGHT := 540.0
const GROUND_TOP := 450.0
const GRASS := Color("4cae68")
const GRASS_LIGHT := Color("8bd36d")
const DIRT := Color("9b5d3f")
const DIRT_DARK := Color("68402f")

var ground_sections: Array[Rect2] = [
    Rect2(0, 450, 180, 90),
    Rect2(840, 450, 120, 90),
]
var bridge_scene: PackedScene = preload("res://scenes/props/FallingStoneBridge.tscn")
var bridges: Array[Node2D] = []
var center_ground: StaticBody2D
var center_collision: CollisionShape2D
var center_started := false
var deaths := 0
var started_at := 0
var completed := false

func _ready() -> void:
    _build_bridges()
    _build_center_ground()
    if not Engine.is_editor_hint():
        _build_ground_collisions()
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
    for bridge in bridges:
        if is_instance_valid(bridge) and bridge.has_method("check_player_contact"):
            bridge.check_player_contact(player)
    if center_started:
        queue_redraw()
    if $Player.global_position.x >= LEVEL_WIDTH - 12.0:
        _complete_level()

func set_background_style(value: String) -> void:
    background_style = value
    queue_redraw()

func _build_bridges() -> void:
    if not bridges.is_empty():
        return
    _add_bridge(Vector2(180, 450), 5, 36.0)
    _add_bridge(Vector2(480, 450), 10, 36.0)

func _add_bridge(bridge_position: Vector2, count: int, width: float) -> void:
    var bridge := bridge_scene.instantiate()
    bridge.stone_count = count
    bridge.stone_width = width
    bridge.stone_gap = 0.0
    bridge.position = bridge_position
    bridge.name = "FallingStoneBridge_%02d" % (bridges.size() + 1)
    add_child(bridge)
    bridges.append(bridge)

func _build_ground_collisions() -> void:
    for index in range(ground_sections.size()):
        var body := StaticBody2D.new()
        body.name = "EarthIslandCollision_%02d" % (index + 1)
        body.position = ground_sections[index].position + ground_sections[index].size / 2.0
        var collision := CollisionShape2D.new()
        var shape := RectangleShape2D.new()
        shape.size = ground_sections[index].size
        collision.shape = shape
        body.add_child(collision)
        add_child(body)

func _build_center_ground() -> void:
    center_ground = StaticBody2D.new()
    center_ground.name = "FallingCenterEarth"
    center_ground.set_meta("description", "Central earth island that collapses on contact")
    center_ground.position = Vector2(420, 495)
    center_collision = CollisionShape2D.new()
    var center_shape := RectangleShape2D.new()
    center_shape.size = Vector2(120, 90)
    center_collision.shape = center_shape
    center_ground.add_child(center_collision)
    add_child(center_ground)

    var trigger := Area2D.new()
    trigger.name = "FallingCenterEarthTrigger"
    trigger.position = Vector2(420, 450)
    var trigger_collision := CollisionShape2D.new()
    var trigger_shape := RectangleShape2D.new()
    trigger_shape.size = Vector2(120, 16)
    trigger_collision.shape = trigger_shape
    trigger.add_child(trigger_collision)
    trigger.body_entered.connect(_on_center_ground_body_entered)
    add_child(trigger)

func _on_center_ground_body_entered(body: Node2D) -> void:
    if center_started or not body.has_method("die"):
        return
    if body.global_position.y > 464.0:
        return
    center_started = true
    await get_tree().create_timer(0.1).timeout
    if not is_inside_tree():
        return
    center_collision.disabled = true
    var tween := create_tween()
    tween.tween_property(center_ground, "position:y", center_ground.position.y + 180.0, 0.42).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)

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

func _send_result(payload: Dictionary) -> void:
    if OS.has_feature("web"):
        JavaScriptBridge.eval("window.parent.postMessage({type:'ragebox-result',result:" + JSON.stringify(payload) + "}, '*');")

func _draw() -> void:
    _draw_background()
    for section in ground_sections:
        _draw_ground(section)
    _draw_center_ground()

func _draw_center_ground() -> void:
    var center := Vector2(420, 495)
    if is_instance_valid(center_ground):
        center = center_ground.position
    _draw_ground(Rect2(center - Vector2(60, 45), Vector2(120, 90)))

func _draw_ground(section: Rect2) -> void:
    draw_rect(section, DIRT_DARK)
    draw_rect(Rect2(section.position + Vector2(0, 10), Vector2(section.size.x, section.size.y - 10)), DIRT)
    draw_rect(Rect2(section.position, Vector2(section.size.x, 12)), GRASS)
    draw_rect(Rect2(section.position, Vector2(section.size.x, 4)), GRASS_LIGHT)
    for x in range(int(section.position.x) + 12, int(section.end.x), 34):
        draw_line(Vector2(x, section.position.y + 28), Vector2(x + 7, minf(section.position.y + 42, section.end.y - 8)), DIRT_DARK, 3.0)

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
