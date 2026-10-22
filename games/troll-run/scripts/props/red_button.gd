@tool
class_name RageboxRedButton
extends Node2D

signal pressed
@export var button_size := Vector2(42, 18)
var is_pressed := false
var trigger: Area2D

func _ready() -> void:
    if not Engine.is_editor_hint():
        trigger = Area2D.new()
        var shape_node := CollisionShape2D.new()
        var shape := RectangleShape2D.new()
        shape.size = Vector2(button_size.x, 32)
        shape_node.shape = shape
        shape_node.position = Vector2(0, -16)
        trigger.add_child(shape_node)
        add_child(trigger)
        trigger.body_entered.connect(_on_body_entered)
    queue_redraw()

func _on_body_entered(body: Node2D) -> void:
    if is_pressed or not body.has_method("die"):
        return
    is_pressed = true
    pressed.emit()
    queue_redraw()

func _draw() -> void:
    var outline := Color("24283a")
    draw_rect(Rect2(-button_size.x / 2.0, -8, button_size.x, 12), outline)
    draw_rect(Rect2(-button_size.x / 2.0 + 4, -5, button_size.x - 8, 8), Color("5e2635"))
    var y := -12.0 if not is_pressed else -8.0
    draw_rect(Rect2(-button_size.x / 2.0 + 7, y, button_size.x - 14, 10), outline)
    draw_rect(Rect2(-button_size.x / 2.0 + 9, y + 2, button_size.x - 18, 6), Color("e23d4d"))

