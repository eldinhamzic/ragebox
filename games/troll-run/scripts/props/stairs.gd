@tool
class_name RageboxStairs
extends Node2D

@export_enum("Indoor Brick", "Outdoor Grass") var stair_style := "Indoor Brick" : set = set_stair_style
@export_range(2, 10, 1) var step_count := 4 : set = set_step_count
@export var step_width := 32.0 : set = set_step_width
@export var step_height := 20.0 : set = set_step_height
@export var active := true : set = set_active
@export var descending := false : set = set_descending

var solid_body: StaticBody2D

func _ready() -> void:
    _sync_collision()
    queue_redraw()

func set_stair_style(value: String) -> void:
    stair_style = value
    queue_redraw()

func set_step_count(value: int) -> void:
    step_count = clampi(value, 2, 10)
    _sync_collision()
    queue_redraw()

func set_step_width(value: float) -> void:
    step_width = maxf(value, 12.0)
    _sync_collision()
    queue_redraw()

func set_step_height(value: float) -> void:
    step_height = maxf(value, 8.0)
    _sync_collision()
    queue_redraw()

func set_active(value: bool) -> void:
    active = value
    if solid_body != null:
        for child in solid_body.get_children():
            if child is CollisionShape2D:
                child.disabled = not active
    queue_redraw()

func set_descending(value: bool) -> void:
    descending = value
    _sync_collision()
    queue_redraw()

func _sync_collision() -> void:
    if not is_inside_tree():
        return
    if solid_body == null:
        solid_body = StaticBody2D.new()
        solid_body.name = "StairCollision"
        add_child(solid_body)
    for child in solid_body.get_children():
        child.queue_free()
    var total_height := step_count * step_height
    for index in range(step_count):
        var height := (step_count - index) * step_height if descending else (index + 1) * step_height
        var shape_node := CollisionShape2D.new()
        var shape := RectangleShape2D.new()
        shape.size = Vector2(step_width, height)
        shape_node.shape = shape
        shape_node.disabled = not active
        shape_node.position = Vector2(index * step_width + step_width / 2.0, total_height - height / 2.0)
        solid_body.add_child(shape_node)

func _draw() -> void:
    var total_height := step_count * step_height
    var outline := Color("263247")
    for index in range(step_count):
        var height := (step_count - index) * step_height if descending else (index + 1) * step_height
        var rect := Rect2(index * step_width, total_height - height, step_width, height)
        if stair_style == "Indoor Brick":
            _draw_brick_step(rect, outline)
        else:
            _draw_grass_step(rect, outline)

func _draw_brick_step(rect: Rect2, outline: Color) -> void:
    draw_rect(rect, outline)
    draw_rect(Rect2(rect.position + Vector2(3, 3), rect.size - Vector2(6, 6)), Color("f7faf8"))
    draw_rect(Rect2(rect.position, Vector2(rect.size.x, 5)), Color("ffffff"))
    draw_line(Vector2(rect.position.x + 4, rect.end.y - 8), Vector2(rect.end.x - 4, rect.end.y - 8), Color("d3dfe0"), 2)

func _draw_grass_step(rect: Rect2, outline: Color) -> void:
    draw_rect(rect, outline)
    draw_rect(Rect2(rect.position + Vector2(3, 7), rect.size - Vector2(6, 10)), Color("9b5d3f"))
    draw_rect(Rect2(rect.position, Vector2(rect.size.x, 9)), Color("4cae68"))
    draw_rect(Rect2(rect.position, Vector2(rect.size.x, 3)), Color("8bd36d"))
