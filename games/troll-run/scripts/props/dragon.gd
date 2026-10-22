@tool
class_name RageboxDragon
extends Node2D

@export var facing := 1.0 : set = set_facing

func set_facing(value: float) -> void:
    facing = -1.0 if value < 0.0 else 1.0
    queue_redraw()

func _ready() -> void:
    queue_redraw()

func _draw() -> void:
    draw_set_transform(Vector2.ZERO, 0.0, Vector2(facing, 1.0))
    var outline := Color("24283a")
    var body_color := Color("65b86a")
    var wing := Color("3e875e")
    draw_colored_polygon(PackedVector2Array([Vector2(-20, -4), Vector2(-42, -28), Vector2(-14, -20)]), wing)
    draw_colored_polygon(PackedVector2Array([Vector2(3, -8), Vector2(19, -32), Vector2(24, -3)]), wing)
    draw_rect(Rect2(-22, -14, 42, 24), outline)
    draw_rect(Rect2(-18, -11, 34, 17), body_color)
    draw_rect(Rect2(10, -23, 22, 17), outline)
    draw_rect(Rect2(13, -20, 16, 11), body_color)
    draw_circle(Vector2(24, -15), 2, Color("f3d15b"))
    draw_line(Vector2(30, -8), Vector2(42, -4), Color("e05b4d"), 3)
    draw_line(Vector2(42, -4), Vector2(50, -8), Color("e05b4d"), 2)
    draw_line(Vector2(-12, 8), Vector2(-16, 19), outline, 4)
    draw_line(Vector2(7, 8), Vector2(12, 19), outline, 4)
    draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

