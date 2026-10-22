@tool
class_name RageboxTerrainPiece
extends Node2D

@export_enum("Ground", "Brick Floor", "Outdoor Water Gap", "Indoor Black Gap") var piece_type := "Ground" : set = set_piece_type
@export var piece_size := Vector2(144, 90) : set = set_piece_size
@export_enum("Solid", "Drop On Touch", "Drop On Landing") var platform_behavior := "Solid" : set = set_platform_behavior
@export_enum("Default", "Block 3") var ground_palette := "Default"
@export var show_anchor := false

var solid_body: StaticBody2D
var collision: CollisionShape2D
var top_zone: Area2D
var top_shape: CollisionShape2D
var death_zone: Area2D
var death_shape: CollisionShape2D
var drop_started := false

func _ready() -> void:
    _sync_collision()
    queue_redraw()

func set_piece_type(value: String) -> void:
    piece_type = value
    _sync_collision()
    queue_redraw()

func set_piece_size(value: Vector2) -> void:
    piece_size = Vector2(maxf(value.x, 24.0), maxf(value.y, 12.0))
    _sync_collision()
    queue_redraw()

func set_platform_behavior(value: String) -> void:
    platform_behavior = value
    _sync_collision()

func _sync_collision() -> void:
    if not is_inside_tree():
        return
    if solid_body == null:
        solid_body = StaticBody2D.new()
        solid_body.name = "SolidCollision"
        collision = CollisionShape2D.new()
        collision.name = "CollisionShape2D"
        solid_body.add_child(collision)
        add_child(solid_body)
    if top_zone == null:
        top_zone = Area2D.new()
        top_zone.name = "DropTrigger"
        top_shape = CollisionShape2D.new()
        top_shape.name = "TopShape"
        top_zone.add_child(top_shape)
        add_child(top_zone)
        top_zone.body_entered.connect(_on_top_body_entered)
    if death_zone == null:
        death_zone = Area2D.new()
        death_zone.name = "DeathZone"
        death_shape = CollisionShape2D.new()
        death_shape.name = "DeathShape"
        death_zone.add_child(death_shape)
        add_child(death_zone)
        death_zone.body_entered.connect(_on_death_zone_body_entered)
    var solid := piece_type == "Ground" or piece_type == "Brick Floor"
    collision.disabled = not solid
    top_zone.monitoring = solid and platform_behavior != "Solid" and not drop_started
    death_zone.monitoring = not solid
    if solid:
        var shape := RectangleShape2D.new()
        shape.size = piece_size
        collision.shape = shape
        collision.position = piece_size / 2.0
        var top_area_shape := RectangleShape2D.new()
        top_area_shape.size = Vector2(piece_size.x, 14.0)
        top_shape.shape = top_area_shape
        top_shape.position = Vector2(piece_size.x / 2.0, -5.0)
    else:
        var gap_shape := RectangleShape2D.new()
        gap_shape.size = piece_size
        death_shape.shape = gap_shape
        death_shape.position = piece_size / 2.0

func _on_death_zone_body_entered(body: Node2D) -> void:
    if body.has_method("fall_into_hole"):
        body.fall_into_hole()
    elif body.has_method("die"):
        body.die()

func _on_top_body_entered(body: Node2D) -> void:
    if drop_started or platform_behavior == "Solid":
        return
    if not body.has_method("die") or body.global_position.y > global_position.y + 8.0:
        return
    if platform_behavior == "Drop On Landing":
        await get_tree().physics_frame
        if not is_instance_valid(body) or not body.is_on_floor():
            return
    drop_now()

func drop_now() -> void:
    if drop_started or platform_behavior == "Solid":
        return
    drop_started = true
    top_zone.monitoring = false
    await get_tree().create_timer(0.12).timeout
    if not is_inside_tree():
        return
    collision.disabled = true
    var tween := create_tween()
    tween.set_parallel(true)
    tween.tween_property(self, "position", position + Vector2(0, piece_size.y + 70.0), 0.42).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
    tween.tween_property(self, "rotation", 0.08, 0.42)
    tween.set_parallel(false)
    tween.tween_callback(func() -> void:
        if is_inside_tree():
            visible = false
    )

func _draw() -> void:
    if piece_type == "Ground":
        _draw_ground()
    elif piece_type == "Brick Floor":
        _draw_brick_floor()
    elif piece_type == "Outdoor Water Gap":
        _draw_water_gap()
    else:
        _draw_black_gap()
    if show_anchor:
        draw_circle(Vector2.ZERO, 4, Color("f05ab2"))

func _draw_ground() -> void:
    var dirt := Color("9b5d3f")
    var dark_dirt := Color("68402f")
    var grass := Color("4cae68")
    var grass_light := Color("8bd36d")
    if ground_palette == "Block 3":
        dirt = Color("263d32")
        dark_dirt = Color("17251f")
        grass = Color("4cae68")
        grass_light = Color("8bd36d")
    # Ground pieces are seamless so a drop section cannot be identified.
    draw_rect(Rect2(Vector2.ZERO, piece_size), dirt)
    draw_rect(Rect2(0, 0, piece_size.x, 14), grass)
    draw_rect(Rect2(0, 0, piece_size.x, 4), grass_light)
    for x in range(12, int(piece_size.x), 34):
        draw_line(Vector2(x, 22), Vector2(x + 7, 32), dark_dirt, 3)
        draw_line(Vector2(x + 16, piece_size.y - 24), Vector2(x + 23, piece_size.y - 12), dark_dirt, 2)

func _draw_brick_floor() -> void:
    # Match the exact indoor brick style used by Block 2 ceilings and floors.
    var brick := Color("f5f5f5")
    var shade := Color("b8b8b8")
    var dark := Color("777777")
    draw_rect(Rect2(Vector2.ZERO, piece_size), brick)
    draw_line(Vector2(0, 14), Vector2(piece_size.x, 14), dark, 2.0)
    var row := 0
    var y := 30.0
    while y < piece_size.y - 3.0:
        draw_line(Vector2(0, y), Vector2(piece_size.x, y), shade, 2.0)
        var offset := 0.0 if row % 2 == 0 else 18.0
        var x := offset
        while x < piece_size.x:
            draw_line(Vector2(x, y - 14), Vector2(x, y), shade, 2.0)
            x += 36.0
        y += 16.0
        row += 1

func _draw_water_gap() -> void:
    var outline := Color("263247")
    var water_height := piece_size.y * 0.30
    var water_y := piece_size.y - water_height
    draw_rect(Rect2(0, water_y, piece_size.x, water_height), outline)
    draw_rect(Rect2(4, water_y + 5, piece_size.x - 8, water_height - 5), Color("237fa2"))
    draw_rect(Rect2(4, water_y + 5, piece_size.x - 8, 6), Color("73d7dc"))
    for x in range(14, int(piece_size.x) - 10, 34):
        draw_line(Vector2(x, water_y + 18), Vector2(x + 15, water_y + 18), Color("a6eff0"), 2)

func _draw_black_gap() -> void:
    draw_rect(Rect2(Vector2.ZERO, piece_size), Color("263247"))
    draw_rect(Rect2(5, 5, piece_size.x - 10, piece_size.y - 5), Color("05070d"))
    draw_line(Vector2(8, 8), Vector2(piece_size.x - 8, 8), Color("46506a"), 2)
    draw_line(Vector2(12, piece_size.y - 12), Vector2(piece_size.x - 18, piece_size.y - 12), Color("101627"), 3)
