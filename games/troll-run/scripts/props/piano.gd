@tool
class_name RageboxPiano
extends Node2D

@export var facing := 1.0 : set = set_facing
@export var show_anchor := false

func _ready() -> void:
    queue_redraw()

func set_facing(value: float) -> void:
    facing = -1.0 if value < 0.0 else 1.0
    queue_redraw()

func _process(_delta: float) -> void:
    if Engine.is_editor_hint():
        queue_redraw()

func _draw() -> void:
    draw_set_transform(Vector2.ZERO, 0.0, Vector2(facing, 1.0))

    var outline := Color("20283a")
    var wood := Color("583d42")
    var wood_light := Color("8b5b51")
    var key := Color("fffdf2")
    var key_shadow := Color("d8d7cd")
    var black_key := Color("171b29")

    # Upright cabinet and rounded top.
    draw_rect(Rect2(-62, -62, 124, 82), outline)
    draw_rect(Rect2(-58, -58, 116, 74), wood)
    draw_rect(Rect2(-52, -53, 104, 8), wood_light)
    draw_rect(Rect2(-48, -42, 96, 24), Color("46333d"))
    draw_rect(Rect2(-44, -39, 88, 18), Color("2e2d3a"))

    # Keyboard shelf, white keys and black keys.
    draw_rect(Rect2(-64, -20, 128, 30), outline)
    draw_rect(Rect2(-59, -16, 118, 21), key)
    for x in range(-52, 56, 13):
        draw_line(Vector2(x, -16), Vector2(x, 5), key_shadow, 1)
    for x in [-45, -32, -6, 7, 20, 46]:
        draw_rect(Rect2(x, -16, 7, 12), black_key)
    draw_rect(Rect2(-61, 5, 122, 5), wood_light)

    # Legs, feet and pedals.
    draw_rect(Rect2(-50, 10, 10, 49), outline)
    draw_rect(Rect2(40, 10, 10, 49), outline)
    draw_rect(Rect2(-47, 12, 5, 44), wood_light)
    draw_rect(Rect2(43, 12, 5, 44), wood_light)
    draw_rect(Rect2(-57, 55, 24, 7), outline)
    draw_rect(Rect2(33, 55, 24, 7), outline)
    draw_line(Vector2(-9, 55), Vector2(-4, 42), Color("c7a86e"), 3)
    draw_line(Vector2(9, 55), Vector2(4, 42), Color("c7a86e"), 3)

    if show_anchor:
        draw_circle(Vector2.ZERO, 3, Color("f05ab2"))

