@tool
class_name RageboxFlyingHammer
extends Node2D

signal strike_completed

@export_enum("From Left", "From Right", "From Above", "From Below") var attack_direction := "From Left" : set = set_attack_direction
@export var trigger_radius := 150.0
@export var warning_time := 0.18
@export var flight_time := 0.24
@export var return_time := 0.35
@export var active := true

var trigger: Area2D
var hitbox: Area2D
var home_position := Vector2.ZERO
var armed := false
var flying := false

func _ready() -> void:
    home_position = global_position
    rotation = _direction_rotation()
    if not Engine.is_editor_hint() and active:
        _build_areas()
    queue_redraw()

func set_attack_direction(value: String) -> void:
    attack_direction = value
    rotation = _direction_rotation()
    queue_redraw()

func _build_areas() -> void:
    trigger = Area2D.new()
    trigger.name = "Trigger"
    var trigger_shape_node := CollisionShape2D.new()
    var trigger_shape := CircleShape2D.new()
    trigger_shape.radius = trigger_radius
    trigger_shape_node.shape = trigger_shape
    trigger.add_child(trigger_shape_node)
    add_child(trigger)
    trigger.body_entered.connect(_on_trigger_body_entered)

    hitbox = Area2D.new()
    hitbox.name = "ImpactHitbox"
    hitbox.monitoring = false
    var hit_shape_node := CollisionShape2D.new()
    var hit_shape := RectangleShape2D.new()
    hit_shape.size = Vector2(42, 34)
    hit_shape_node.shape = hit_shape
    hit_shape_node.position = Vector2(0, -26)
    hitbox.add_child(hit_shape_node)
    add_child(hitbox)
    hitbox.body_entered.connect(_on_hitbox_body_entered)

func _direction_rotation() -> float:
    match attack_direction:
        "From Right":
            return -PI / 2.0
        "From Above":
            return 0.0
        "From Below":
            return PI
        _:
            return PI / 2.0

func _on_trigger_body_entered(body: Node2D) -> void:
    if armed or flying or not body.has_method("die"):
        return
    armed = true
    await get_tree().create_timer(warning_time).timeout
    if not is_instance_valid(body) or body.get("dead") == true:
        _reset()
        return
    flying = true
    hitbox.monitoring = true
    var target := body.global_position
    var tween := create_tween()
    tween.tween_property(self, "global_position", target, flight_time).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
    tween.tween_callback(_return_home)

func strike_target(target: Vector2) -> void:
    if not active or flying:
        return
    flying = true
    var tween := create_tween()
    tween.tween_property(self, "global_position", target, flight_time).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
    tween.tween_callback(_return_home)

func _on_hitbox_body_entered(body: Node2D) -> void:
    if body.has_method("die"):
        body.die()

func _return_home() -> void:
    hitbox.monitoring = false
    visible = false
    await get_tree().create_timer(0.12).timeout
    global_position = home_position
    visible = true
    var tween := create_tween()
    tween.tween_interval(return_time)
    tween.tween_callback(func() -> void:
        _reset()
        strike_completed.emit()
    )

func _reset() -> void:
    hitbox.monitoring = false
    global_position = home_position
    rotation = _direction_rotation()
    armed = false
    flying = false
    visible = true
