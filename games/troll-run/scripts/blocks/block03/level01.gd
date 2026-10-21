@tool
extends Node2D

@export_file("*.tscn") var next_level_path := "res://scenes/blocks/block03/Level02.tscn"
const W := 960.0
const H := 540.0
const GROUND := Rect2(0, 450, 480, 90)
const END_GROUND := Rect2(780, 450, 180, 90)
var hammer_started := false
var lightning := false
var spikes_started := false
var hammer_target_x := 350.0

func _ready() -> void:
    if not Engine.is_editor_hint():
        $Player.died.connect(_on_died)
        $Hammer.strike_completed.connect(func() -> void:
            $Hammer.visible = false
        )
    queue_redraw()

func _process(_delta: float) -> void:
    if Engine.is_editor_hint() or hammer_started:
        return
    var p: RageboxPlayer = $Player
    if not spikes_started and p.global_position.x >= 145.0:
        spikes_started = true
        $Spikes.activate_now()
    if p.global_position.x >= 330.0:
        hammer_started = true
        hammer_target_x = p.global_position.x
        lightning = true
        queue_redraw()
        await get_tree().create_timer(0.1).timeout
        lightning = false
        queue_redraw()
        $Hammer.visible = true
        # The hammer hitbox is above its target point; aim into the floor so
        # the hammer head visibly embeds in the ground on impact.
        $Hammer.strike_target(Vector2(hammer_target_x, 450.0))

func _add_collision(rect: Rect2, name: String) -> void:
    var body := StaticBody2D.new()
    body.name = name
    body.position = rect.position + rect.size / 2.0
    var shape_node := CollisionShape2D.new()
    var shape := RectangleShape2D.new()
    shape.size = rect.size
    shape_node.shape = shape
    body.add_child(shape_node)
    add_child(body)

func _on_died() -> void:
    await get_tree().create_timer(0.8).timeout
    if is_inside_tree(): GameState.restart_block()

func _draw() -> void:
    draw_rect(Rect2(0, 0, W, H), Color("07101d"))
    draw_circle(Vector2(820, 90), 38, Color("c7d3df"))
    if lightning:
        var bolt := PackedVector2Array([
            Vector2(hammer_target_x + 18.0, 340),
            Vector2(hammer_target_x - 8.0, 378),
            Vector2(hammer_target_x + 7.0, 378),
            Vector2(hammer_target_x - 14.0, 420),
            Vector2(hammer_target_x, 420),
            Vector2(hammer_target_x, 450),
        ])
        draw_polyline(bolt, Color("ffffff"), 7.0, true)
        draw_polyline(bolt, Color("79d8ff"), 3.0, true)

func _draw_ground(rect: Rect2) -> void:
    var outline := Color("3b2a2a")
    var dirt := Color("9b5d3f")
    var dark_dirt := Color("68402f")
    draw_rect(rect, outline)
    draw_rect(Rect2(rect.position + Vector2(4, 12), rect.size - Vector2(8, 16)), dirt)
    draw_rect(Rect2(rect.position, Vector2(rect.size.x, 14)), Color("4cae68"))
    draw_rect(Rect2(rect.position, Vector2(rect.size.x, 4)), Color("8bd36d"))
    for x in range(int(rect.position.x) + 12, int(rect.end.x), 34):
        draw_line(Vector2(x, rect.position.y + 22), Vector2(x + 7, rect.position.y + 32), dark_dirt, 3)
