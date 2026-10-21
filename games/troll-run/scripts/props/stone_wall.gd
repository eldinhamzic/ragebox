@tool
class_name RageboxStoneWall
extends Node2D

@export var wall_size := Vector2(72, 190) : set = set_wall_size
@export var indoor_style := false : set = set_indoor_style

func _ready() -> void:
    _sync_collision()
    queue_redraw()

func set_wall_size(value: Vector2) -> void:
    wall_size = Vector2(maxf(value.x, 24.0), maxf(value.y, 48.0))
    _sync_collision()
    queue_redraw()

func set_indoor_style(value: bool) -> void:
    indoor_style = value
    queue_redraw()

func _sync_collision() -> void:
    if not is_inside_tree():
        return
    var body := get_node_or_null("SolidCollision") as StaticBody2D
    if body == null:
        body = StaticBody2D.new()
        body.name = "SolidCollision"
        var collision := CollisionShape2D.new()
        collision.name = "CollisionShape2D"
        body.add_child(collision)
        add_child(body)
    var shape := RectangleShape2D.new()
    shape.size = wall_size
    var collision := body.get_node("CollisionShape2D") as CollisionShape2D
    collision.shape = shape
    collision.position = wall_size / 2.0

func _draw() -> void:
    var base := Color("f5f5f5") if indoor_style else Color("c98b5b")
    var shade := Color("b8b8b8") if indoor_style else Color("8b563f")
    var dark := Color("777777") if indoor_style else Color("553629")
    draw_rect(Rect2(Vector2.ZERO, wall_size), dark)
    draw_rect(Rect2(4, 4, wall_size.x - 8, wall_size.y - 8), base)
    var row := 0
    var y := 18.0
    while y < wall_size.y - 4.0:
        draw_line(Vector2(4, y), Vector2(wall_size.x - 4, y), shade, 2.0)
        var offset := 0.0 if row % 2 == 0 else 18.0
        var x := 4.0 + offset
        while x < wall_size.x - 4.0:
            draw_line(Vector2(x, y - 14), Vector2(x, y), shade, 2.0)
            x += 36.0
        y += 16.0
        row += 1
