@tool
class_name RageboxFallingStoneBridge
extends Node2D

## One row of individually collapsing stones. The node origin is the top of the bridge.

@export_range(1, 12, 1) var stone_count := 5 : set = set_stone_count
@export var stone_width := 36.0 : set = set_stone_width
@export var stone_gap := 0.0 : set = set_stone_gap
@export var stone_height := 24.0 : set = set_stone_height
@export var fall_delay := 0.08
@export var fall_distance := 180.0
@export var indoor_style := false
@export var collapse_start := 0
@export var collapse_end := -1

const INK := Color("241c35")
const STONE := Color("8fa7b1")
const STONE_LIGHT := Color("d9e2e3")
const STONE_DARK := Color("526b75")
const INDOOR_BRICK := Color("f5f5f5")
const INDOOR_SHADE := Color("b8b8b8")
const INDOOR_DARK := Color("777777")

var stones: Array[StaticBody2D] = []
var collisions: Array[CollisionShape2D] = []
var fallen: Array[bool] = []

func _ready() -> void:
    _build_stones()
    queue_redraw()

func _process(_delta: float) -> void:
    if Engine.is_editor_hint() or fallen.is_empty():
        return
    # The stones are drawn by this parent, while their positions are tweened
    # on the child bodies. Redraw every frame once the chain has started so
    # the visual stones follow the animated collisions.
    if fallen.has(true):
        queue_redraw()
    var player: RageboxPlayer = get_tree().current_scene.get_node_or_null("Player") as RageboxPlayer
    if player == null or not player.has_method("die"):
        return
    # The player origin is at the feet. Polling this contact as well as the
    # Area2D makes the collapse reliable when the feet land exactly on a seam.
    var local_x: float = player.global_position.x - global_position.x
    var local_y: float = player.global_position.y - global_position.y
    if player.velocity.y < 0.0 or local_y < -30.0 or local_y > 30.0:
        return
    for index in range(stone_count):
        if index >= fallen.size() or fallen[index]:
            continue
        var stone_start := index * (stone_width + stone_gap)
        var stone_end := stone_start + stone_width
        if local_x >= stone_start and local_x <= stone_end and local_y >= -6.0 and local_y <= 10.0:
            _collapse_chain_from(index)
            return

func check_player_contact(player: RageboxPlayer) -> void:
    if player == null or player.velocity.y < 0.0:
        return
    var local_x := player.global_position.x - global_position.x
    var local_y := player.global_position.y - global_position.y
    if local_y < -30.0 or local_y > 30.0:
        return
    for index in range(stone_count):
        if index >= fallen.size() or fallen[index]:
            continue
        var stone_start := index * (stone_width + stone_gap)
        if local_x >= stone_start and local_x <= stone_start + stone_width:
            _collapse_chain_from(index)
            return

func set_stone_count(value: int) -> void:
    stone_count = clampi(value, 1, 12)
    _build_stones()
    queue_redraw()

func set_stone_width(value: float) -> void:
    stone_width = maxf(value, 12.0)
    _build_stones()
    queue_redraw()

func set_stone_gap(value: float) -> void:
    stone_gap = maxf(value, 0.0)
    _build_stones()
    queue_redraw()

func set_stone_height(value: float) -> void:
    stone_height = maxf(value, 10.0)
    _build_stones()
    queue_redraw()

func bridge_width() -> float:
    return stone_count * stone_width + maxi(stone_count - 1, 0) * stone_gap

func _build_stones() -> void:
    if not is_inside_tree():
        return
    for child in get_children():
        if child is StaticBody2D or child is Area2D:
            child.queue_free()
    stones.clear()
    collisions.clear()
    fallen.clear()
    for index in range(stone_count):
        var x := index * (stone_width + stone_gap)
        var body := StaticBody2D.new()
        body.name = "FallingBridgeStone_%02d" % (index + 1)
        body.position = Vector2(x + stone_width / 2.0, stone_height / 2.0)
        var collision := CollisionShape2D.new()
        var shape := RectangleShape2D.new()
        shape.size = Vector2(stone_width, stone_height)
        collision.shape = shape
        body.add_child(collision)
        add_child(body)
        stones.append(body)
        collisions.append(collision)
        fallen.append(false)

        var trigger := Area2D.new()
        trigger.name = "StoneTrigger_%02d" % (index + 1)
        trigger.position = Vector2(x + stone_width / 2.0, 0)
        var trigger_collision := CollisionShape2D.new()
        var trigger_shape := RectangleShape2D.new()
        trigger_shape.size = Vector2(stone_width, 12.0)
        trigger_collision.shape = trigger_shape
        trigger.add_child(trigger_collision)
        trigger.body_entered.connect(_on_stone_body_entered.bind(index))
        add_child(trigger)

func _on_stone_body_entered(body: Node2D, index: int) -> void:
    if index >= fallen.size() or fallen[index] or not body.has_method("die"):
        return
    _collapse_chain_from(index)

func _collapse_chain_from(start_index: int) -> void:
    var first := maxi(start_index, collapse_start)
    var last := collapse_end if collapse_end >= 0 else stone_count - 1
    for index in range(first, last + 1):
        if index >= fallen.size() or fallen[index]:
            continue
        fallen[index] = true
        if fall_delay > 0.0:
            await get_tree().create_timer(fall_delay).timeout
        if not is_inside_tree() or index >= stones.size():
            return
        _collapse_stone(index)

func _collapse_stone(index: int) -> void:
    collisions[index].disabled = true
    var tween := create_tween()
    tween.tween_property(stones[index], "position:y", stones[index].position.y + fall_distance, 0.38).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)

func _draw() -> void:
    for index in range(stone_count):
        var x := index * (stone_width + stone_gap)
        var y := 0.0
        if index < stones.size() and is_instance_valid(stones[index]):
            x = stones[index].position.x - stone_width / 2.0
            y = stones[index].position.y - stone_height / 2.0
        var rect := Rect2(x, y, stone_width, stone_height)
        if indoor_style:
            # Exactly the same skin as the stable indoor bridge stones.
            draw_rect(rect, INDOOR_BRICK)
            draw_line(Vector2(rect.position.x, rect.position.y + 14), Vector2(rect.end.x, rect.position.y + 14), INDOOR_DARK, 2.0)
        else:
            draw_rect(rect, INK)
            draw_rect(Rect2(rect.position + Vector2(3, 3), rect.size - Vector2(6, 6)), STONE)
            draw_line(Vector2(rect.position.x + 4, rect.position.y + 5), Vector2(rect.end.x - 5, rect.position.y + 5), STONE_LIGHT, 3.0)
            draw_line(Vector2(rect.position.x + 6, rect.end.y - 5), Vector2(rect.end.x - 6, rect.end.y - 5), STONE_DARK, 2.0)
