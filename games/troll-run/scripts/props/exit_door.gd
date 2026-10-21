@tool
class_name RageboxExitDoor
extends Node2D

signal opened

@export var door_size := Vector2(72, 120)
@export var interaction_distance := 18.0

var trigger: Area2D
var trigger_shape: CollisionShape2D
var opened_once := false
var door_offset := 0.0

func _ready() -> void:
    _sync_trigger()
    queue_redraw()

func _process(_delta: float) -> void:
    if Engine.is_editor_hint():
        queue_redraw()
        return
    if opened_once:
        queue_redraw()
        return
    var player: RageboxPlayer = get_tree().current_scene.get_node_or_null("Player") as RageboxPlayer
    if player == null or not player.has_method("die"):
        return
    var half_width := door_size.x * 0.5 + interaction_distance
    if absf(player.global_position.x - global_position.x) <= half_width and player.global_position.y >= global_position.y - 12.0 and player.global_position.y <= global_position.y + 18.0:
        _open_for_body(player)

func _sync_trigger() -> void:
    if not is_inside_tree():
        return
    if trigger == null:
        trigger = Area2D.new()
        trigger.name = "Trigger"
        trigger_shape = CollisionShape2D.new()
        trigger.add_child(trigger_shape)
        add_child(trigger)
        trigger.body_entered.connect(_on_body_entered)
    var shape := RectangleShape2D.new()
    shape.size = Vector2(door_size.x + interaction_distance * 2.0, door_size.y)
    trigger_shape.shape = shape
    trigger_shape.position = Vector2(0, -door_size.y / 2.0)

func _on_body_entered(body: Node2D) -> void:
    _open_for_body(body)

func _open_for_body(body: Node2D) -> void:
    if opened_once or not body.has_method("die"):
        return
    opened_once = true
    trigger.monitoring = false
    body.visible = false
    var tween := create_tween()
    tween.tween_property(self, "door_offset", -door_size.y, 0.32).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
    tween.tween_callback(func() -> void: opened.emit())

func _draw() -> void:
    var outline := Color("24283a")
    var door := Color("79c9a8")
    var door_light := Color("b7f0ca")
    draw_rect(Rect2(-door_size.x / 2.0, -door_size.y, door_size.x, door_size.y), outline)
    draw_rect(Rect2(-door_size.x / 2.0 + 5, -door_size.y + 5 + door_offset, door_size.x - 10, door_size.y - 5), door)
    draw_rect(Rect2(-door_size.x / 2.0 + 9, -door_size.y + 9 + door_offset, door_size.x - 18, 7), door_light)
    draw_circle(Vector2(door_size.x / 4.0, -door_size.y / 2.0 + door_offset), 3, Color("d9af52"))
    draw_string(ThemeDB.fallback_font, Vector2(-20, -door_size.y / 2.0 + 6 + door_offset), "OPEN", HORIZONTAL_ALIGNMENT_LEFT, -1, 10, outline)
