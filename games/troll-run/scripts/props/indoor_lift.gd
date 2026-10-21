@tool
class_name RageboxIndoorLift
extends Node2D

signal opened

@export var lift_size := Vector2(72, 20)
@export var interaction_distance := 18.0
@export var travel_distance := 180.0
@export var indoor_style := true

const BLACK := Color("05070d")
const BRICK := Color("f5f5f5")
const BRICK_SHADE := Color("b8b8b8")
const BRICK_DARK := Color("777777")

var trigger: Area2D
var trigger_shape: CollisionShape2D
var opened_once := false
var unlocked := true
var lift_offset := 0.0

func _ready() -> void:
    _sync_trigger()
    queue_redraw()

func _process(_delta: float) -> void:
    if Engine.is_editor_hint():
        queue_redraw()
        return
    if opened_once or not unlocked:
        queue_redraw()
        return
    var player: RageboxPlayer = get_tree().current_scene.get_node_or_null("Player") as RageboxPlayer
    if player == null or not player.has_method("die"):
        return
    var half_width := lift_size.x * 0.5 + interaction_distance
    if absf(player.global_position.x - global_position.x) <= half_width and player.global_position.y >= global_position.y - 12.0 and player.global_position.y <= global_position.y + 18.0:
        _open_for_player(player)

func _sync_trigger() -> void:
    if not is_inside_tree():
        return
    if trigger == null:
        trigger = Area2D.new()
        trigger.name = "LiftTrigger"
        trigger_shape = CollisionShape2D.new()
        trigger.add_child(trigger_shape)
        add_child(trigger)
        trigger.body_entered.connect(_on_body_entered)
    var shape := RectangleShape2D.new()
    shape.size = Vector2(lift_size.x + interaction_distance * 2.0, lift_size.y + 18.0)
    trigger_shape.shape = shape
    trigger_shape.position = Vector2(0, -lift_size.y / 2.0)
    trigger.monitoring = unlocked

func _on_body_entered(body: Node2D) -> void:
    _open_for_player(body)

func open_for_player(player: Node2D) -> void:
    _open_for_player(player)

func unlock() -> void:
    unlocked = true
    if trigger != null:
        trigger.monitoring = true

func _open_for_player(player: Node2D) -> void:
    if opened_once or not player.has_method("die"):
        return
    opened_once = true
    if trigger != null:
        trigger.monitoring = false
    if player is CharacterBody2D:
        player.set_physics_process(false)
    var tween := create_tween()
    tween.set_parallel(true)
    tween.tween_property(self, "lift_offset", travel_distance, 0.8).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
    tween.tween_property(player, "global_position:y", player.global_position.y + travel_distance, 0.8).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
    tween.set_parallel(false)
    tween.tween_callback(func() -> void: opened.emit())

func _draw() -> void:
    # Dark shaft below the floor, with a brick rim and a descending lift plate.
    if indoor_style:
        draw_rect(Rect2(-lift_size.x / 2.0 - 10.0, -2.0, lift_size.x + 20.0, travel_distance + 24.0), BLACK)
    draw_rect(Rect2(-lift_size.x / 2.0 - 10.0, -8.0, 10.0, 24.0), BRICK_SHADE)
    draw_rect(Rect2(lift_size.x / 2.0, -8.0, 10.0, 24.0), BRICK_SHADE)
    var plate := Rect2(Vector2(-lift_size.x / 2.0, -lift_size.y + lift_offset), lift_size)
    draw_rect(plate, BRICK_SHADE)
    draw_rect(Rect2(plate.position + Vector2(3, 3), plate.size - Vector2(6, 6)), BRICK)
    draw_line(Vector2(plate.position.x, plate.position.y + 9), Vector2(plate.end.x, plate.position.y + 9), BRICK_DARK, 2.0)
