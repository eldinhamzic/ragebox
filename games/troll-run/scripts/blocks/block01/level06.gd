@tool
extends Node2D

## Level 06: small landing platforms, one delayed collapse, and a spike landing trap.

@export_enum("Indoor Black", "Day", "Night") var background_style := "Day" : set = set_background_style
@export_file("*.tscn") var next_level_path := ""

const LEVEL_WIDTH := 960.0
const LEVEL_HEIGHT := 540.0
const START_TOP := 450.0
const FINISH_TOP := 450.0
const P1 := Rect2(165, 380, 110, 24)
const P2 := Rect2(350, 320, 120, 24)
const P3_LEFT := Rect2(555, 370, 80, 24)
const P3_RIGHT := Rect2(635, 370, 80, 24)
const FALLING_PLATFORM := P1
const GRASS := Color("4cae68")
const GRASS_LIGHT := Color("8bd36d")
const DIRT := Color("9b5d3f")
const DIRT_DARK := Color("68402f")

var falling_body: StaticBody2D
var falling_collision: CollisionShape2D
var falling_started := false
var spikes_triggered := false
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
        $ExitLift.opened.connect(_on_exit_opened)
        $Player.died.connect(_on_player_died)
        started_at = Time.get_ticks_msec()
    queue_redraw()

func _process(_delta: float) -> void:
    if Engine.is_editor_hint() or completed:
        return
    var player: RageboxPlayer = $Player
    if not falling_started and player.is_on_floor() and player.global_position.x >= FALLING_PLATFORM.position.x and player.global_position.x <= FALLING_PLATFORM.end.x and player.global_position.y >= FALLING_PLATFORM.position.y - 24.0:
        _start_falling_platform()
    # Trigger the spikes only while descending toward the left half of platform 3.
    if not spikes_triggered and player.global_position.x >= P3_LEFT.position.x and player.global_position.x <= P3_LEFT.end.x and not player.is_on_floor() and player.velocity.y > 0.0 and player.global_position.y >= P3_LEFT.position.y - 68.0 and player.global_position.y < P3_LEFT.position.y:
        spikes_triggered = true
        $ThirdPlatformSpikes.activate_now()
    if falling_started:
        queue_redraw()

func set_background_style(value: String) -> void:
    background_style = value
    queue_redraw()

func _build_collisions() -> void:
    _add_ground_collision(Rect2(0, START_TOP, 120, LEVEL_HEIGHT - START_TOP))
    _add_ground_collision(Rect2(840, FINISH_TOP, 120, LEVEL_HEIGHT - FINISH_TOP))
    _add_platform_collision(P2, "SafePlatform")
    _add_platform_collision(P3_LEFT, "SpikePlatformLeft")
    _add_platform_collision(P3_RIGHT, "SafePlatformRight")

    falling_body = StaticBody2D.new()
    falling_body.name = "FallingFirstPlatform"
    falling_body.position = FALLING_PLATFORM.position + FALLING_PLATFORM.size / 2.0
    falling_collision = CollisionShape2D.new()
    var falling_shape := RectangleShape2D.new()
    falling_shape.size = FALLING_PLATFORM.size
    falling_collision.shape = falling_shape
    falling_body.add_child(falling_collision)
    add_child(falling_body)


func _add_ground_collision(rect: Rect2) -> void:
    var body := StaticBody2D.new()
    body.position = rect.position + rect.size / 2.0
    var collision := CollisionShape2D.new()
    var shape := RectangleShape2D.new()
    shape.size = rect.size
    collision.shape = shape
    body.add_child(collision)
    add_child(body)

func _add_platform_collision(rect: Rect2, node_name: String) -> void:
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
    _complete_level()

func _complete_level() -> void:
    if completed:
        return
    completed = true
    if next_level_path == "" or next_level_path == "res://scenes/BlockTransition.tscn":
        GameState.complete_block()
    else:
        get_tree().change_scene_to_file(next_level_path)

func _send_result(payload: Dictionary) -> void:
    if OS.has_feature("web"):
        JavaScriptBridge.eval("window.parent.postMessage({type:'ragebox-result',result:" + JSON.stringify(payload) + "}, '*');")

func _draw() -> void:
    _draw_background()
    _draw_ground(Rect2(0, START_TOP, 120, LEVEL_HEIGHT - START_TOP))
    _draw_ground(Rect2(840, FINISH_TOP, 120, LEVEL_HEIGHT - FINISH_TOP))
    _draw_platform(P2)
    _draw_platform(P3_LEFT)
    _draw_platform(P3_RIGHT)
    var falling_rect := FALLING_PLATFORM
    if is_instance_valid(falling_body):
        falling_rect.position = falling_body.position - falling_rect.size / 2.0
    _draw_platform(falling_rect)

func _draw_ground(rect: Rect2) -> void:
    draw_rect(rect, DIRT_DARK)
    draw_rect(Rect2(rect.position + Vector2(0, 10), rect.size - Vector2(0, 10)), DIRT)
    draw_rect(Rect2(rect.position, Vector2(rect.size.x, 12)), GRASS)
    draw_rect(Rect2(rect.position, Vector2(rect.size.x, 4)), GRASS_LIGHT)

func _draw_platform(rect: Rect2) -> void:
    draw_rect(rect, DIRT_DARK)
    draw_rect(Rect2(rect.position + Vector2(3, 7), rect.size - Vector2(6, 7)), DIRT)
    draw_rect(Rect2(rect.position, Vector2(rect.size.x, 8)), GRASS)
    draw_rect(Rect2(rect.position, Vector2(rect.size.x, 3)), GRASS_LIGHT)

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
