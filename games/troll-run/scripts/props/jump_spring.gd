@tool
class_name RageboxJumpSpring
extends Node2D

@export var bounce_velocity := -720.0
@export var spring_width := 34.0
@export var active := true : set = set_active

var trigger: Area2D

func _ready() -> void:
    if not Engine.is_editor_hint():
        trigger = Area2D.new()
        var shape_node := CollisionShape2D.new()
        var shape := RectangleShape2D.new()
        shape.size = Vector2(spring_width, 22)
        shape_node.shape = shape
        shape_node.position = Vector2(0, -11)
        trigger.add_child(shape_node)
        add_child(trigger)
        trigger.body_entered.connect(_on_body_entered)
        trigger.monitoring = active
    queue_redraw()

func _on_body_entered(body: Node2D) -> void:
    if not active:
        return
    if body.has_method("bounce"):
        body.bounce(bounce_velocity)
    elif body.get("velocity") != null:
        var body_velocity: Vector2 = body.get("velocity")
        body_velocity.y = bounce_velocity
        body.set("velocity", body_velocity)

func activate() -> void:
    set_active(true)

func set_active(value: bool) -> void:
    active = value
    if is_instance_valid(trigger):
        trigger.monitoring = active

func _draw() -> void:
    var outline := Color("24283a")
    draw_rect(Rect2(-20, -5, 40, 10), outline)
    draw_rect(Rect2(-16, -3, 32, 6), Color("e44758"))
    draw_line(Vector2(-13, -3), Vector2(-7, -20), Color("d7dce1"), 3)
    draw_line(Vector2(-7, -20), Vector2(0, -3), Color("d7dce1"), 3)
    draw_line(Vector2(0, -3), Vector2(7, -20), Color("d7dce1"), 3)
    draw_line(Vector2(7, -20), Vector2(13, -3), Color("d7dce1"), 3)
