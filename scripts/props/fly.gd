@tool
class_name RageboxFly
extends Node2D

@export var facing := 1.0 : set = set_facing

func set_facing(value: float) -> void:
    facing = -1.0 if value < 0.0 else 1.0
    queue_redraw()

func _ready() -> void:
    queue_redraw()

func _draw() -> void:
    draw_set_transform(Vector2.ZERO, 0.0, Vector2(facing, 1.0))
    draw_ellipse(Vector2(-7, -5), Vector2(8, 4), Color("d8f5f4", 0.75))
    draw_ellipse(Vector2(7, -5), Vector2(8, 4), Color("d8f5f4", 0.75))
    draw_circle(Vector2.ZERO, 6, Color("24283a"))
    draw_circle(Vector2(5, -1), 2, Color("e9c85d"))
    draw_line(Vector2(-4, 4), Vector2(-9, 10), Color("24283a"), 2)
    draw_line(Vector2(1, 4), Vector2(7, 10), Color("24283a"), 2)
    draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func draw_ellipse(center: Vector2, radius: Vector2, color: Color) -> void:
    var points := PackedVector2Array()
    for index in range(16):
        var angle := TAU * float(index) / 16.0
        points.append(center + Vector2(cos(angle) * radius.x, sin(angle) * radius.y))
    draw_colored_polygon(points, color)

