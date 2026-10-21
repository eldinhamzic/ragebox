@tool
extends Node2D

## Block 02, Level 02: a bridge that becomes unstable only after its midpoint.

@export_file("*.tscn") var next_level_path := ""

const LEVEL_WIDTH := 960.0
const LEVEL_HEIGHT := 540.0
const INDOOR_CEILING_HEIGHT := 108.0
const GROUND_TOP := 450.0
const START_GROUND := Rect2(0, 450, 180, 90)
const STABLE_BRIDGE := Rect2(180, 450, 324, 24)
const FALLING_BRIDGE_START_X := 504.0
const END_GROUND := Rect2(864, 450, 96, 90)
const STONE_WIDTH := 36.0
const STABLE_STONES := 9
const FALLING_STONES := 10
const BRICK := Color("f5f5f5")
const BRICK_SHADE := Color("b8b8b8")
const BRICK_DARK := Color("777777")

var bridge_scene: PackedScene = preload("res://scenes/props/FallingStoneBridge.tscn")
var falling_bridge: Node2D
var piano_fall_started := false
var deaths := 0
var started_at := 0
var completed := false

func _ready() -> void:
    _build_falling_bridge()
    if not Engine.is_editor_hint():
        _build_collisions()
        var camera: Camera2D = $Player.get_node("Camera2D")
        camera.position = Vector2.ZERO
        camera.limit_right = LEVEL_WIDTH
        camera.limit_bottom = LEVEL_HEIGHT
        $Player.died.connect(_on_player_died)
        $TrapButton.pressed.connect(_on_trap_button_pressed)
        $Piano.visible = false
        started_at = Time.get_ticks_msec()
    queue_redraw()

func _build_falling_bridge() -> void:
    if is_instance_valid(falling_bridge):
        return
    falling_bridge = bridge_scene.instantiate()
    falling_bridge.stone_count = FALLING_STONES
    falling_bridge.stone_width = STONE_WIDTH
    falling_bridge.stone_gap = 0.0
    falling_bridge.indoor_style = true
    falling_bridge.position = Vector2(FALLING_BRIDGE_START_X, GROUND_TOP)
    falling_bridge.name = "FallingSecondHalfBridge"
    add_child(falling_bridge)

func _build_collisions() -> void:
    _add_collision(Rect2(0, 0, LEVEL_WIDTH, INDOOR_CEILING_HEIGHT), "IndoorCeiling")
    _add_collision(START_GROUND, "StartGround")
    _add_collision(END_GROUND, "EndGround")
    for index in range(STABLE_STONES):
        _add_collision(Rect2(180.0 + index * STONE_WIDTH, GROUND_TOP, STONE_WIDTH, 24.0), "StableBridgeStone_%02d" % (index + 1))

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

func _process(_delta: float) -> void:
    if Engine.is_editor_hint() or completed:
        return
    if $Player.global_position.x >= LEVEL_WIDTH - 12.0:
        _on_exit_opened()

func _on_trap_button_pressed() -> void:
    if piano_fall_started:
        return
    piano_fall_started = true
    var player: RageboxPlayer = $Player
    var target_x := player.global_position.x
    var target_y := player.global_position.y - 62.0
    $Piano.global_position.x = target_x
    $Piano.visible = true
    var tween := create_tween()
    tween.tween_property($Piano, "global_position:y", target_y, 0.12).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
    tween.tween_callback(func() -> void:
        if is_instance_valid(player):
            player.die()
    )

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
    _draw_ground(START_GROUND)
    _draw_ground(END_GROUND)
    for index in range(STABLE_STONES):
        _draw_stone(Vector2(180.0 + index * STONE_WIDTH, GROUND_TOP))

func _draw_ground(rect: Rect2) -> void:
    _draw_bricks(rect)

func _draw_stone(position: Vector2) -> void:
    var rect := Rect2(position, Vector2(STONE_WIDTH, 24))
    _draw_bricks(rect)

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
