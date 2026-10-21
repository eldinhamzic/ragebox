@tool
class_name RageboxSledgehammer
extends Node2D

@export var facing := 1.0
@export var show_anchor := false

func _ready() -> void:
    queue_redraw()

func _process(_delta: float) -> void:
    if Engine.is_editor_hint():
        queue_redraw()

func _draw() -> void:
    var side := -1.0 if facing < 0.0 else 1.0
    draw_set_transform(Vector2.ZERO, 0.0, Vector2(side, 1.0))

    var outline := Color("24283a")
    var wood_dark := Color("70432f")
    var wood := Color("b86f43")
    var wood_light := Color("e0a05a")
    var steel_dark := Color("4e6075")
    var steel := Color("a9bcc9")
    var steel_light := Color("e5f3f4")

    # Long handle with a rounded grip.
    draw_rect(Rect2(-4, -8, 8, 92), outline)
    draw_rect(Rect2(-2, -6, 4, 88), wood)
    draw_rect(Rect2(-1, -6, 2, 88), wood_light)
    draw_rect(Rect2(-6, 72, 12, 12), outline)
    draw_rect(Rect2(-4, 73, 8, 8), wood_dark)
    draw_line(Vector2(-3, 76), Vector2(3, 76), wood_light, 2)

    # Heavy metal head, bevelled to read at small scale.
    draw_rect(Rect2(-26, -25, 52, 30), outline)
    draw_rect(Rect2(-23, -22, 46, 24), steel_dark)
    draw_rect(Rect2(-20, -19, 40, 17), steel)
    draw_rect(Rect2(-17, -17, 34, 5), steel_light)
    draw_rect(Rect2(-26, -21, 8, 22), outline)
    draw_rect(Rect2(18, -21, 8, 22), outline)
    draw_rect(Rect2(-23, -18, 5, 16), steel)
    draw_rect(Rect2(18, -18, 5, 16), steel)
    draw_line(Vector2(-16, 0), Vector2(16, 0), steel_dark, 2)

    if show_anchor:
        draw_circle(Vector2.ZERO, 3, Color("f05ab2"))

